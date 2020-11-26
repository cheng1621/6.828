
obj/user/testshell.debug:     file format elf32-i386


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
  80002c:	e8 60 04 00 00       	call   800491 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <wrong>:
	breakpoint();
}

void
wrong(int rfd, int kfd, int off)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	81 ec 84 00 00 00    	sub    $0x84,%esp
  80003f:	8b 75 08             	mov    0x8(%ebp),%esi
  800042:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800045:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char buf[100];
	int n;

	seek(rfd, off);
  800048:	53                   	push   %ebx
  800049:	56                   	push   %esi
  80004a:	e8 1e 19 00 00       	call   80196d <seek>
	seek(kfd, off);
  80004f:	83 c4 08             	add    $0x8,%esp
  800052:	53                   	push   %ebx
  800053:	57                   	push   %edi
  800054:	e8 14 19 00 00       	call   80196d <seek>

	cprintf("shell produced incorrect output.\n");
  800059:	c7 04 24 a0 2a 80 00 	movl   $0x802aa0,(%esp)
  800060:	e8 6d 05 00 00       	call   8005d2 <cprintf>
	cprintf("expected:\n===\n");
  800065:	c7 04 24 0b 2b 80 00 	movl   $0x802b0b,(%esp)
  80006c:	e8 61 05 00 00       	call   8005d2 <cprintf>
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800071:	83 c4 10             	add    $0x10,%esp
  800074:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  800077:	eb 0d                	jmp    800086 <wrong+0x53>
		sys_cputs(buf, n);
  800079:	83 ec 08             	sub    $0x8,%esp
  80007c:	50                   	push   %eax
  80007d:	53                   	push   %ebx
  80007e:	e8 e8 0e 00 00       	call   800f6b <sys_cputs>
  800083:	83 c4 10             	add    $0x10,%esp
	seek(rfd, off);
	seek(kfd, off);

	cprintf("shell produced incorrect output.\n");
	cprintf("expected:\n===\n");
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800086:	83 ec 04             	sub    $0x4,%esp
  800089:	6a 63                	push   $0x63
  80008b:	53                   	push   %ebx
  80008c:	57                   	push   %edi
  80008d:	e8 7d 17 00 00       	call   80180f <read>
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	85 c0                	test   %eax,%eax
  800097:	7f e0                	jg     800079 <wrong+0x46>
		sys_cputs(buf, n);
	cprintf("===\ngot:\n===\n");
  800099:	83 ec 0c             	sub    $0xc,%esp
  80009c:	68 1a 2b 80 00       	push   $0x802b1a
  8000a1:	e8 2c 05 00 00       	call   8005d2 <cprintf>
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  8000ac:	eb 0d                	jmp    8000bb <wrong+0x88>
		sys_cputs(buf, n);
  8000ae:	83 ec 08             	sub    $0x8,%esp
  8000b1:	50                   	push   %eax
  8000b2:	53                   	push   %ebx
  8000b3:	e8 b3 0e 00 00       	call   800f6b <sys_cputs>
  8000b8:	83 c4 10             	add    $0x10,%esp
	cprintf("shell produced incorrect output.\n");
	cprintf("expected:\n===\n");
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
		sys_cputs(buf, n);
	cprintf("===\ngot:\n===\n");
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000bb:	83 ec 04             	sub    $0x4,%esp
  8000be:	6a 63                	push   $0x63
  8000c0:	53                   	push   %ebx
  8000c1:	56                   	push   %esi
  8000c2:	e8 48 17 00 00       	call   80180f <read>
  8000c7:	83 c4 10             	add    $0x10,%esp
  8000ca:	85 c0                	test   %eax,%eax
  8000cc:	7f e0                	jg     8000ae <wrong+0x7b>
		sys_cputs(buf, n);
	cprintf("===\n");
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	68 15 2b 80 00       	push   $0x802b15
  8000d6:	e8 f7 04 00 00       	call   8005d2 <cprintf>
	exit();
  8000db:	e8 00 04 00 00       	call   8004e0 <exit>
}
  8000e0:	83 c4 10             	add    $0x10,%esp
  8000e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000e6:	5b                   	pop    %ebx
  8000e7:	5e                   	pop    %esi
  8000e8:	5f                   	pop    %edi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <umain>:

void wrong(int, int, int);

void
umain(int argc, char **argv)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	57                   	push   %edi
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	83 ec 38             	sub    $0x38,%esp
	char c1, c2;
	int r, rfd, wfd, kfd, n1, n2, off, nloff;
	int pfds[2];

	close(0);
  8000f4:	6a 00                	push   $0x0
  8000f6:	e8 dc 15 00 00       	call   8016d7 <close>
	close(1);
  8000fb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800102:	e8 d0 15 00 00       	call   8016d7 <close>
	opencons();
  800107:	e8 33 03 00 00       	call   80043f <opencons>
	opencons();
  80010c:	e8 2e 03 00 00       	call   80043f <opencons>

	if ((rfd = open("testshell.sh", O_RDONLY)) < 0)
  800111:	83 c4 08             	add    $0x8,%esp
  800114:	6a 00                	push   $0x0
  800116:	68 28 2b 80 00       	push   $0x802b28
  80011b:	e8 f0 1a 00 00       	call   801c10 <open>
  800120:	89 c3                	mov    %eax,%ebx
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	85 c0                	test   %eax,%eax
  800127:	79 12                	jns    80013b <umain+0x50>
		panic("open testshell.sh: %e", rfd);
  800129:	50                   	push   %eax
  80012a:	68 35 2b 80 00       	push   $0x802b35
  80012f:	6a 13                	push   $0x13
  800131:	68 4b 2b 80 00       	push   $0x802b4b
  800136:	e8 bf 03 00 00       	call   8004fa <_panic>
	if ((wfd = pipe(pfds)) < 0)
  80013b:	83 ec 0c             	sub    $0xc,%esp
  80013e:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800141:	50                   	push   %eax
  800142:	e8 ca 22 00 00       	call   802411 <pipe>
  800147:	83 c4 10             	add    $0x10,%esp
  80014a:	85 c0                	test   %eax,%eax
  80014c:	79 12                	jns    800160 <umain+0x75>
		panic("pipe: %e", wfd);
  80014e:	50                   	push   %eax
  80014f:	68 5c 2b 80 00       	push   $0x802b5c
  800154:	6a 15                	push   $0x15
  800156:	68 4b 2b 80 00       	push   $0x802b4b
  80015b:	e8 9a 03 00 00       	call   8004fa <_panic>
	wfd = pfds[1];
  800160:	8b 75 e0             	mov    -0x20(%ebp),%esi

	cprintf("running sh -x < testshell.sh | cat\n");
  800163:	83 ec 0c             	sub    $0xc,%esp
  800166:	68 c4 2a 80 00       	push   $0x802ac4
  80016b:	e8 62 04 00 00       	call   8005d2 <cprintf>
	if ((r = fork()) < 0)
  800170:	e8 92 11 00 00       	call   801307 <fork>
  800175:	83 c4 10             	add    $0x10,%esp
  800178:	85 c0                	test   %eax,%eax
  80017a:	79 12                	jns    80018e <umain+0xa3>
		panic("fork: %e", r);
  80017c:	50                   	push   %eax
  80017d:	68 65 2b 80 00       	push   $0x802b65
  800182:	6a 1a                	push   $0x1a
  800184:	68 4b 2b 80 00       	push   $0x802b4b
  800189:	e8 6c 03 00 00       	call   8004fa <_panic>
	if (r == 0) {
  80018e:	85 c0                	test   %eax,%eax
  800190:	75 7d                	jne    80020f <umain+0x124>
		dup(rfd, 0);
  800192:	83 ec 08             	sub    $0x8,%esp
  800195:	6a 00                	push   $0x0
  800197:	53                   	push   %ebx
  800198:	e8 88 15 00 00       	call   801725 <dup>
		dup(wfd, 1);
  80019d:	83 c4 08             	add    $0x8,%esp
  8001a0:	6a 01                	push   $0x1
  8001a2:	56                   	push   %esi
  8001a3:	e8 7d 15 00 00       	call   801725 <dup>
		close(rfd);
  8001a8:	89 1c 24             	mov    %ebx,(%esp)
  8001ab:	e8 27 15 00 00       	call   8016d7 <close>
		close(wfd);
  8001b0:	89 34 24             	mov    %esi,(%esp)
  8001b3:	e8 1f 15 00 00       	call   8016d7 <close>
		if ((r = spawnl("/sh", "sh", "-x", 0)) < 0)
  8001b8:	6a 00                	push   $0x0
  8001ba:	68 6e 2b 80 00       	push   $0x802b6e
  8001bf:	68 32 2b 80 00       	push   $0x802b32
  8001c4:	68 71 2b 80 00       	push   $0x802b71
  8001c9:	e8 cb 1f 00 00       	call   802199 <spawnl>
  8001ce:	89 c7                	mov    %eax,%edi
  8001d0:	83 c4 20             	add    $0x20,%esp
  8001d3:	85 c0                	test   %eax,%eax
  8001d5:	79 12                	jns    8001e9 <umain+0xfe>
			panic("spawn: %e", r);
  8001d7:	50                   	push   %eax
  8001d8:	68 75 2b 80 00       	push   $0x802b75
  8001dd:	6a 21                	push   $0x21
  8001df:	68 4b 2b 80 00       	push   $0x802b4b
  8001e4:	e8 11 03 00 00       	call   8004fa <_panic>
		close(0);
  8001e9:	83 ec 0c             	sub    $0xc,%esp
  8001ec:	6a 00                	push   $0x0
  8001ee:	e8 e4 14 00 00       	call   8016d7 <close>
		close(1);
  8001f3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8001fa:	e8 d8 14 00 00       	call   8016d7 <close>
		wait(r);
  8001ff:	89 3c 24             	mov    %edi,(%esp)
  800202:	e8 8a 23 00 00       	call   802591 <wait>
		exit();
  800207:	e8 d4 02 00 00       	call   8004e0 <exit>
  80020c:	83 c4 10             	add    $0x10,%esp
	}
	close(rfd);
  80020f:	83 ec 0c             	sub    $0xc,%esp
  800212:	53                   	push   %ebx
  800213:	e8 bf 14 00 00       	call   8016d7 <close>
	close(wfd);
  800218:	89 34 24             	mov    %esi,(%esp)
  80021b:	e8 b7 14 00 00       	call   8016d7 <close>

	rfd = pfds[0];
  800220:	8b 7d dc             	mov    -0x24(%ebp),%edi
	if ((kfd = open("testshell.key", O_RDONLY)) < 0)
  800223:	83 c4 08             	add    $0x8,%esp
  800226:	6a 00                	push   $0x0
  800228:	68 7f 2b 80 00       	push   $0x802b7f
  80022d:	e8 de 19 00 00       	call   801c10 <open>
  800232:	89 c6                	mov    %eax,%esi
  800234:	83 c4 10             	add    $0x10,%esp
  800237:	85 c0                	test   %eax,%eax
  800239:	79 12                	jns    80024d <umain+0x162>
		panic("open testshell.key for reading: %e", kfd);
  80023b:	50                   	push   %eax
  80023c:	68 e8 2a 80 00       	push   $0x802ae8
  800241:	6a 2c                	push   $0x2c
  800243:	68 4b 2b 80 00       	push   $0x802b4b
  800248:	e8 ad 02 00 00       	call   8004fa <_panic>
  80024d:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  800254:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)

	nloff = 0;
	for (off=0;; off++) {
		n1 = read(rfd, &c1, 1);
  80025b:	83 ec 04             	sub    $0x4,%esp
  80025e:	6a 01                	push   $0x1
  800260:	8d 45 e7             	lea    -0x19(%ebp),%eax
  800263:	50                   	push   %eax
  800264:	57                   	push   %edi
  800265:	e8 a5 15 00 00       	call   80180f <read>
  80026a:	89 c3                	mov    %eax,%ebx
		n2 = read(kfd, &c2, 1);
  80026c:	83 c4 0c             	add    $0xc,%esp
  80026f:	6a 01                	push   $0x1
  800271:	8d 45 e6             	lea    -0x1a(%ebp),%eax
  800274:	50                   	push   %eax
  800275:	56                   	push   %esi
  800276:	e8 94 15 00 00       	call   80180f <read>
		if (n1 < 0)
  80027b:	83 c4 10             	add    $0x10,%esp
  80027e:	85 db                	test   %ebx,%ebx
  800280:	79 12                	jns    800294 <umain+0x1a9>
			panic("reading testshell.out: %e", n1);
  800282:	53                   	push   %ebx
  800283:	68 8d 2b 80 00       	push   $0x802b8d
  800288:	6a 33                	push   $0x33
  80028a:	68 4b 2b 80 00       	push   $0x802b4b
  80028f:	e8 66 02 00 00       	call   8004fa <_panic>
		if (n2 < 0)
  800294:	85 c0                	test   %eax,%eax
  800296:	79 12                	jns    8002aa <umain+0x1bf>
			panic("reading testshell.key: %e", n2);
  800298:	50                   	push   %eax
  800299:	68 a7 2b 80 00       	push   $0x802ba7
  80029e:	6a 35                	push   $0x35
  8002a0:	68 4b 2b 80 00       	push   $0x802b4b
  8002a5:	e8 50 02 00 00       	call   8004fa <_panic>
		if (n1 == 0 && n2 == 0)
  8002aa:	85 db                	test   %ebx,%ebx
  8002ac:	75 06                	jne    8002b4 <umain+0x1c9>
  8002ae:	85 c0                	test   %eax,%eax
  8002b0:	75 14                	jne    8002c6 <umain+0x1db>
  8002b2:	eb 36                	jmp    8002ea <umain+0x1ff>
			break;
		if (n1 != 1 || n2 != 1 || c1 != c2)
  8002b4:	83 fb 01             	cmp    $0x1,%ebx
  8002b7:	75 0d                	jne    8002c6 <umain+0x1db>
  8002b9:	83 f8 01             	cmp    $0x1,%eax
  8002bc:	75 08                	jne    8002c6 <umain+0x1db>
  8002be:	8a 45 e6             	mov    -0x1a(%ebp),%al
  8002c1:	38 45 e7             	cmp    %al,-0x19(%ebp)
  8002c4:	74 10                	je     8002d6 <umain+0x1eb>
			wrong(rfd, kfd, nloff);
  8002c6:	83 ec 04             	sub    $0x4,%esp
  8002c9:	ff 75 d0             	pushl  -0x30(%ebp)
  8002cc:	56                   	push   %esi
  8002cd:	57                   	push   %edi
  8002ce:	e8 60 fd ff ff       	call   800033 <wrong>
  8002d3:	83 c4 10             	add    $0x10,%esp
		if (c1 == '\n')
  8002d6:	80 7d e7 0a          	cmpb   $0xa,-0x19(%ebp)
  8002da:	75 06                	jne    8002e2 <umain+0x1f7>
			nloff = off+1;
  8002dc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002df:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002e2:	ff 45 d4             	incl   -0x2c(%ebp)
	}
  8002e5:	e9 71 ff ff ff       	jmp    80025b <umain+0x170>
	cprintf("shell ran correctly\n");
  8002ea:	83 ec 0c             	sub    $0xc,%esp
  8002ed:	68 c1 2b 80 00       	push   $0x802bc1
  8002f2:	e8 db 02 00 00       	call   8005d2 <cprintf>
static __inline uint64_t read_tsc(void) __attribute__((always_inline));

static __inline void
breakpoint(void)
{
	__asm __volatile("int3");
  8002f7:	cc                   	int3   

	breakpoint();
}
  8002f8:	83 c4 10             	add    $0x10,%esp
  8002fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002fe:	5b                   	pop    %ebx
  8002ff:	5e                   	pop    %esi
  800300:	5f                   	pop    %edi
  800301:	5d                   	pop    %ebp
  800302:	c3                   	ret    

00800303 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800303:	55                   	push   %ebp
  800304:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800306:	b8 00 00 00 00       	mov    $0x0,%eax
  80030b:	5d                   	pop    %ebp
  80030c:	c3                   	ret    

0080030d <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80030d:	55                   	push   %ebp
  80030e:	89 e5                	mov    %esp,%ebp
  800310:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800313:	68 d6 2b 80 00       	push   $0x802bd6
  800318:	ff 75 0c             	pushl  0xc(%ebp)
  80031b:	e8 97 08 00 00       	call   800bb7 <strcpy>
	return 0;
}
  800320:	b8 00 00 00 00       	mov    $0x0,%eax
  800325:	c9                   	leave  
  800326:	c3                   	ret    

00800327 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800327:	55                   	push   %ebp
  800328:	89 e5                	mov    %esp,%ebp
  80032a:	57                   	push   %edi
  80032b:	56                   	push   %esi
  80032c:	53                   	push   %ebx
  80032d:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800333:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800337:	74 45                	je     80037e <devcons_write+0x57>
  800339:	b8 00 00 00 00       	mov    $0x0,%eax
  80033e:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800343:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800349:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80034c:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  80034e:	83 fb 7f             	cmp    $0x7f,%ebx
  800351:	76 05                	jbe    800358 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  800353:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800358:	83 ec 04             	sub    $0x4,%esp
  80035b:	53                   	push   %ebx
  80035c:	03 45 0c             	add    0xc(%ebp),%eax
  80035f:	50                   	push   %eax
  800360:	57                   	push   %edi
  800361:	e8 1e 0a 00 00       	call   800d84 <memmove>
		sys_cputs(buf, m);
  800366:	83 c4 08             	add    $0x8,%esp
  800369:	53                   	push   %ebx
  80036a:	57                   	push   %edi
  80036b:	e8 fb 0b 00 00       	call   800f6b <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800370:	01 de                	add    %ebx,%esi
  800372:	89 f0                	mov    %esi,%eax
  800374:	83 c4 10             	add    $0x10,%esp
  800377:	3b 75 10             	cmp    0x10(%ebp),%esi
  80037a:	72 cd                	jb     800349 <devcons_write+0x22>
  80037c:	eb 05                	jmp    800383 <devcons_write+0x5c>
  80037e:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800383:	89 f0                	mov    %esi,%eax
  800385:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800388:	5b                   	pop    %ebx
  800389:	5e                   	pop    %esi
  80038a:	5f                   	pop    %edi
  80038b:	5d                   	pop    %ebp
  80038c:	c3                   	ret    

0080038d <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80038d:	55                   	push   %ebp
  80038e:	89 e5                	mov    %esp,%ebp
  800390:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  800393:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800397:	75 07                	jne    8003a0 <devcons_read+0x13>
  800399:	eb 23                	jmp    8003be <devcons_read+0x31>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80039b:	e8 68 0c 00 00       	call   801008 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8003a0:	e8 e4 0b 00 00       	call   800f89 <sys_cgetc>
  8003a5:	85 c0                	test   %eax,%eax
  8003a7:	74 f2                	je     80039b <devcons_read+0xe>
		sys_yield();
	if (c < 0)
  8003a9:	85 c0                	test   %eax,%eax
  8003ab:	78 1d                	js     8003ca <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8003ad:	83 f8 04             	cmp    $0x4,%eax
  8003b0:	74 13                	je     8003c5 <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  8003b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003b5:	88 02                	mov    %al,(%edx)
	return 1;
  8003b7:	b8 01 00 00 00       	mov    $0x1,%eax
  8003bc:	eb 0c                	jmp    8003ca <devcons_read+0x3d>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8003be:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c3:	eb 05                	jmp    8003ca <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8003c5:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8003ca:	c9                   	leave  
  8003cb:	c3                   	ret    

008003cc <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8003cc:	55                   	push   %ebp
  8003cd:	89 e5                	mov    %esp,%ebp
  8003cf:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8003d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d5:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8003d8:	6a 01                	push   $0x1
  8003da:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8003dd:	50                   	push   %eax
  8003de:	e8 88 0b 00 00       	call   800f6b <sys_cputs>
}
  8003e3:	83 c4 10             	add    $0x10,%esp
  8003e6:	c9                   	leave  
  8003e7:	c3                   	ret    

008003e8 <getchar>:

int
getchar(void)
{
  8003e8:	55                   	push   %ebp
  8003e9:	89 e5                	mov    %esp,%ebp
  8003eb:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8003ee:	6a 01                	push   $0x1
  8003f0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8003f3:	50                   	push   %eax
  8003f4:	6a 00                	push   $0x0
  8003f6:	e8 14 14 00 00       	call   80180f <read>
	if (r < 0)
  8003fb:	83 c4 10             	add    $0x10,%esp
  8003fe:	85 c0                	test   %eax,%eax
  800400:	78 0f                	js     800411 <getchar+0x29>
		return r;
	if (r < 1)
  800402:	85 c0                	test   %eax,%eax
  800404:	7e 06                	jle    80040c <getchar+0x24>
		return -E_EOF;
	return c;
  800406:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80040a:	eb 05                	jmp    800411 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80040c:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800411:	c9                   	leave  
  800412:	c3                   	ret    

00800413 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800413:	55                   	push   %ebp
  800414:	89 e5                	mov    %esp,%ebp
  800416:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800419:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80041c:	50                   	push   %eax
  80041d:	ff 75 08             	pushl  0x8(%ebp)
  800420:	e8 69 11 00 00       	call   80158e <fd_lookup>
  800425:	83 c4 10             	add    $0x10,%esp
  800428:	85 c0                	test   %eax,%eax
  80042a:	78 11                	js     80043d <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80042c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80042f:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800435:	39 10                	cmp    %edx,(%eax)
  800437:	0f 94 c0             	sete   %al
  80043a:	0f b6 c0             	movzbl %al,%eax
}
  80043d:	c9                   	leave  
  80043e:	c3                   	ret    

0080043f <opencons>:

int
opencons(void)
{
  80043f:	55                   	push   %ebp
  800440:	89 e5                	mov    %esp,%ebp
  800442:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800445:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800448:	50                   	push   %eax
  800449:	e8 cc 10 00 00       	call   80151a <fd_alloc>
  80044e:	83 c4 10             	add    $0x10,%esp
  800451:	85 c0                	test   %eax,%eax
  800453:	78 3a                	js     80048f <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800455:	83 ec 04             	sub    $0x4,%esp
  800458:	68 07 04 00 00       	push   $0x407
  80045d:	ff 75 f4             	pushl  -0xc(%ebp)
  800460:	6a 00                	push   $0x0
  800462:	e8 c0 0b 00 00       	call   801027 <sys_page_alloc>
  800467:	83 c4 10             	add    $0x10,%esp
  80046a:	85 c0                	test   %eax,%eax
  80046c:	78 21                	js     80048f <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80046e:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800474:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800477:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800479:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80047c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800483:	83 ec 0c             	sub    $0xc,%esp
  800486:	50                   	push   %eax
  800487:	e8 67 10 00 00       	call   8014f3 <fd2num>
  80048c:	83 c4 10             	add    $0x10,%esp
}
  80048f:	c9                   	leave  
  800490:	c3                   	ret    

00800491 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800491:	55                   	push   %ebp
  800492:	89 e5                	mov    %esp,%ebp
  800494:	56                   	push   %esi
  800495:	53                   	push   %ebx
  800496:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800499:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80049c:	e8 48 0b 00 00       	call   800fe9 <sys_getenvid>
  8004a1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8004a6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8004ad:	c1 e0 07             	shl    $0x7,%eax
  8004b0:	29 d0                	sub    %edx,%eax
  8004b2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8004b7:	a3 04 50 80 00       	mov    %eax,0x805004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8004bc:	85 db                	test   %ebx,%ebx
  8004be:	7e 07                	jle    8004c7 <libmain+0x36>
		binaryname = argv[0];
  8004c0:	8b 06                	mov    (%esi),%eax
  8004c2:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  8004c7:	83 ec 08             	sub    $0x8,%esp
  8004ca:	56                   	push   %esi
  8004cb:	53                   	push   %ebx
  8004cc:	e8 1a fc ff ff       	call   8000eb <umain>

	// exit gracefully
	exit();
  8004d1:	e8 0a 00 00 00       	call   8004e0 <exit>
}
  8004d6:	83 c4 10             	add    $0x10,%esp
  8004d9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004dc:	5b                   	pop    %ebx
  8004dd:	5e                   	pop    %esi
  8004de:	5d                   	pop    %ebp
  8004df:	c3                   	ret    

008004e0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8004e0:	55                   	push   %ebp
  8004e1:	89 e5                	mov    %esp,%ebp
  8004e3:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8004e6:	e8 17 12 00 00       	call   801702 <close_all>
	sys_env_destroy(0);
  8004eb:	83 ec 0c             	sub    $0xc,%esp
  8004ee:	6a 00                	push   $0x0
  8004f0:	e8 b3 0a 00 00       	call   800fa8 <sys_env_destroy>
}
  8004f5:	83 c4 10             	add    $0x10,%esp
  8004f8:	c9                   	leave  
  8004f9:	c3                   	ret    

008004fa <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8004fa:	55                   	push   %ebp
  8004fb:	89 e5                	mov    %esp,%ebp
  8004fd:	56                   	push   %esi
  8004fe:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8004ff:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800502:	8b 35 1c 40 80 00    	mov    0x80401c,%esi
  800508:	e8 dc 0a 00 00       	call   800fe9 <sys_getenvid>
  80050d:	83 ec 0c             	sub    $0xc,%esp
  800510:	ff 75 0c             	pushl  0xc(%ebp)
  800513:	ff 75 08             	pushl  0x8(%ebp)
  800516:	56                   	push   %esi
  800517:	50                   	push   %eax
  800518:	68 ec 2b 80 00       	push   $0x802bec
  80051d:	e8 b0 00 00 00       	call   8005d2 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800522:	83 c4 18             	add    $0x18,%esp
  800525:	53                   	push   %ebx
  800526:	ff 75 10             	pushl  0x10(%ebp)
  800529:	e8 53 00 00 00       	call   800581 <vcprintf>
	cprintf("\n");
  80052e:	c7 04 24 8b 2f 80 00 	movl   $0x802f8b,(%esp)
  800535:	e8 98 00 00 00       	call   8005d2 <cprintf>
  80053a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80053d:	cc                   	int3   
  80053e:	eb fd                	jmp    80053d <_panic+0x43>

00800540 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800540:	55                   	push   %ebp
  800541:	89 e5                	mov    %esp,%ebp
  800543:	53                   	push   %ebx
  800544:	83 ec 04             	sub    $0x4,%esp
  800547:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80054a:	8b 13                	mov    (%ebx),%edx
  80054c:	8d 42 01             	lea    0x1(%edx),%eax
  80054f:	89 03                	mov    %eax,(%ebx)
  800551:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800554:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800558:	3d ff 00 00 00       	cmp    $0xff,%eax
  80055d:	75 1a                	jne    800579 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80055f:	83 ec 08             	sub    $0x8,%esp
  800562:	68 ff 00 00 00       	push   $0xff
  800567:	8d 43 08             	lea    0x8(%ebx),%eax
  80056a:	50                   	push   %eax
  80056b:	e8 fb 09 00 00       	call   800f6b <sys_cputs>
		b->idx = 0;
  800570:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800576:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800579:	ff 43 04             	incl   0x4(%ebx)
}
  80057c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80057f:	c9                   	leave  
  800580:	c3                   	ret    

00800581 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800581:	55                   	push   %ebp
  800582:	89 e5                	mov    %esp,%ebp
  800584:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80058a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800591:	00 00 00 
	b.cnt = 0;
  800594:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80059b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80059e:	ff 75 0c             	pushl  0xc(%ebp)
  8005a1:	ff 75 08             	pushl  0x8(%ebp)
  8005a4:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8005aa:	50                   	push   %eax
  8005ab:	68 40 05 80 00       	push   $0x800540
  8005b0:	e8 54 01 00 00       	call   800709 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8005b5:	83 c4 08             	add    $0x8,%esp
  8005b8:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8005be:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8005c4:	50                   	push   %eax
  8005c5:	e8 a1 09 00 00       	call   800f6b <sys_cputs>

	return b.cnt;
}
  8005ca:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8005d0:	c9                   	leave  
  8005d1:	c3                   	ret    

008005d2 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8005d2:	55                   	push   %ebp
  8005d3:	89 e5                	mov    %esp,%ebp
  8005d5:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8005d8:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8005db:	50                   	push   %eax
  8005dc:	ff 75 08             	pushl  0x8(%ebp)
  8005df:	e8 9d ff ff ff       	call   800581 <vcprintf>
	va_end(ap);

	return cnt;
}
  8005e4:	c9                   	leave  
  8005e5:	c3                   	ret    

008005e6 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005e6:	55                   	push   %ebp
  8005e7:	89 e5                	mov    %esp,%ebp
  8005e9:	57                   	push   %edi
  8005ea:	56                   	push   %esi
  8005eb:	53                   	push   %ebx
  8005ec:	83 ec 1c             	sub    $0x1c,%esp
  8005ef:	89 c6                	mov    %eax,%esi
  8005f1:	89 d7                	mov    %edx,%edi
  8005f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8005f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005f9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005fc:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005ff:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800602:	bb 00 00 00 00       	mov    $0x0,%ebx
  800607:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80060a:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80060d:	39 d3                	cmp    %edx,%ebx
  80060f:	72 11                	jb     800622 <printnum+0x3c>
  800611:	39 45 10             	cmp    %eax,0x10(%ebp)
  800614:	76 0c                	jbe    800622 <printnum+0x3c>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800616:	8b 45 14             	mov    0x14(%ebp),%eax
  800619:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80061c:	85 db                	test   %ebx,%ebx
  80061e:	7f 37                	jg     800657 <printnum+0x71>
  800620:	eb 44                	jmp    800666 <printnum+0x80>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800622:	83 ec 0c             	sub    $0xc,%esp
  800625:	ff 75 18             	pushl  0x18(%ebp)
  800628:	8b 45 14             	mov    0x14(%ebp),%eax
  80062b:	48                   	dec    %eax
  80062c:	50                   	push   %eax
  80062d:	ff 75 10             	pushl  0x10(%ebp)
  800630:	83 ec 08             	sub    $0x8,%esp
  800633:	ff 75 e4             	pushl  -0x1c(%ebp)
  800636:	ff 75 e0             	pushl  -0x20(%ebp)
  800639:	ff 75 dc             	pushl  -0x24(%ebp)
  80063c:	ff 75 d8             	pushl  -0x28(%ebp)
  80063f:	e8 dc 21 00 00       	call   802820 <__udivdi3>
  800644:	83 c4 18             	add    $0x18,%esp
  800647:	52                   	push   %edx
  800648:	50                   	push   %eax
  800649:	89 fa                	mov    %edi,%edx
  80064b:	89 f0                	mov    %esi,%eax
  80064d:	e8 94 ff ff ff       	call   8005e6 <printnum>
  800652:	83 c4 20             	add    $0x20,%esp
  800655:	eb 0f                	jmp    800666 <printnum+0x80>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800657:	83 ec 08             	sub    $0x8,%esp
  80065a:	57                   	push   %edi
  80065b:	ff 75 18             	pushl  0x18(%ebp)
  80065e:	ff d6                	call   *%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800660:	83 c4 10             	add    $0x10,%esp
  800663:	4b                   	dec    %ebx
  800664:	75 f1                	jne    800657 <printnum+0x71>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800666:	83 ec 08             	sub    $0x8,%esp
  800669:	57                   	push   %edi
  80066a:	83 ec 04             	sub    $0x4,%esp
  80066d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800670:	ff 75 e0             	pushl  -0x20(%ebp)
  800673:	ff 75 dc             	pushl  -0x24(%ebp)
  800676:	ff 75 d8             	pushl  -0x28(%ebp)
  800679:	e8 b2 22 00 00       	call   802930 <__umoddi3>
  80067e:	83 c4 14             	add    $0x14,%esp
  800681:	0f be 80 0f 2c 80 00 	movsbl 0x802c0f(%eax),%eax
  800688:	50                   	push   %eax
  800689:	ff d6                	call   *%esi
}
  80068b:	83 c4 10             	add    $0x10,%esp
  80068e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800691:	5b                   	pop    %ebx
  800692:	5e                   	pop    %esi
  800693:	5f                   	pop    %edi
  800694:	5d                   	pop    %ebp
  800695:	c3                   	ret    

00800696 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800696:	55                   	push   %ebp
  800697:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800699:	83 fa 01             	cmp    $0x1,%edx
  80069c:	7e 0e                	jle    8006ac <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80069e:	8b 10                	mov    (%eax),%edx
  8006a0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8006a3:	89 08                	mov    %ecx,(%eax)
  8006a5:	8b 02                	mov    (%edx),%eax
  8006a7:	8b 52 04             	mov    0x4(%edx),%edx
  8006aa:	eb 22                	jmp    8006ce <getuint+0x38>
	else if (lflag)
  8006ac:	85 d2                	test   %edx,%edx
  8006ae:	74 10                	je     8006c0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8006b0:	8b 10                	mov    (%eax),%edx
  8006b2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006b5:	89 08                	mov    %ecx,(%eax)
  8006b7:	8b 02                	mov    (%edx),%eax
  8006b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8006be:	eb 0e                	jmp    8006ce <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8006c0:	8b 10                	mov    (%eax),%edx
  8006c2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006c5:	89 08                	mov    %ecx,(%eax)
  8006c7:	8b 02                	mov    (%edx),%eax
  8006c9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8006ce:	5d                   	pop    %ebp
  8006cf:	c3                   	ret    

008006d0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8006d0:	55                   	push   %ebp
  8006d1:	89 e5                	mov    %esp,%ebp
  8006d3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8006d6:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8006d9:	8b 10                	mov    (%eax),%edx
  8006db:	3b 50 04             	cmp    0x4(%eax),%edx
  8006de:	73 0a                	jae    8006ea <sprintputch+0x1a>
		*b->buf++ = ch;
  8006e0:	8d 4a 01             	lea    0x1(%edx),%ecx
  8006e3:	89 08                	mov    %ecx,(%eax)
  8006e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e8:	88 02                	mov    %al,(%edx)
}
  8006ea:	5d                   	pop    %ebp
  8006eb:	c3                   	ret    

008006ec <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8006ec:	55                   	push   %ebp
  8006ed:	89 e5                	mov    %esp,%ebp
  8006ef:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8006f2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8006f5:	50                   	push   %eax
  8006f6:	ff 75 10             	pushl  0x10(%ebp)
  8006f9:	ff 75 0c             	pushl  0xc(%ebp)
  8006fc:	ff 75 08             	pushl  0x8(%ebp)
  8006ff:	e8 05 00 00 00       	call   800709 <vprintfmt>
	va_end(ap);
}
  800704:	83 c4 10             	add    $0x10,%esp
  800707:	c9                   	leave  
  800708:	c3                   	ret    

00800709 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800709:	55                   	push   %ebp
  80070a:	89 e5                	mov    %esp,%ebp
  80070c:	57                   	push   %edi
  80070d:	56                   	push   %esi
  80070e:	53                   	push   %ebx
  80070f:	83 ec 2c             	sub    $0x2c,%esp
  800712:	8b 7d 08             	mov    0x8(%ebp),%edi
  800715:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800718:	eb 03                	jmp    80071d <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  80071a:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  80071d:	8b 45 10             	mov    0x10(%ebp),%eax
  800720:	8d 70 01             	lea    0x1(%eax),%esi
  800723:	0f b6 00             	movzbl (%eax),%eax
  800726:	83 f8 25             	cmp    $0x25,%eax
  800729:	74 25                	je     800750 <vprintfmt+0x47>
			if (ch == '\0')									//当然中间如果遇到'\0'，代表这个字符串的访问结束
  80072b:	85 c0                	test   %eax,%eax
  80072d:	75 0d                	jne    80073c <vprintfmt+0x33>
  80072f:	e9 b5 03 00 00       	jmp    800ae9 <vprintfmt+0x3e0>
  800734:	85 c0                	test   %eax,%eax
  800736:	0f 84 ad 03 00 00    	je     800ae9 <vprintfmt+0x3e0>
				return;
			putch(ch, putdat);								//调用putch函数，把一个字符ch输出到putdat指针所指向的地址中所存放的值对应的地址处
  80073c:	83 ec 08             	sub    $0x8,%esp
  80073f:	53                   	push   %ebx
  800740:	50                   	push   %eax
  800741:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  800743:	46                   	inc    %esi
  800744:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800748:	83 c4 10             	add    $0x10,%esp
  80074b:	83 f8 25             	cmp    $0x25,%eax
  80074e:	75 e4                	jne    800734 <vprintfmt+0x2b>
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  800750:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  800754:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80075b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800762:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800769:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800770:	eb 07                	jmp    800779 <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800772:	8b 75 10             	mov    0x10(%ebp),%esi

		// flag to pad on the right
		case '-':											//%后面的'-'代表要进行左对齐输出，右边填空格，如果省略代表右对齐
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
  800775:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800779:	8d 46 01             	lea    0x1(%esi),%eax
  80077c:	89 45 10             	mov    %eax,0x10(%ebp)
  80077f:	0f b6 16             	movzbl (%esi),%edx
  800782:	8a 06                	mov    (%esi),%al
  800784:	83 e8 23             	sub    $0x23,%eax
  800787:	3c 55                	cmp    $0x55,%al
  800789:	0f 87 03 03 00 00    	ja     800a92 <vprintfmt+0x389>
  80078f:	0f b6 c0             	movzbl %al,%eax
  800792:	ff 24 85 60 2d 80 00 	jmp    *0x802d60(,%eax,4)
  800799:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
			goto reswitch;									//处理下一个字符

		// flag to pad with 0's instead of spaces
		case '0':											//0--有0表示进行对齐输出时填0,如省略表示填入空格，并且如果为0，则一定是右对齐
			padc = '0';										//对其方式标志位变为0
  80079c:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  8007a0:	eb d7                	jmp    800779 <vprintfmt+0x70>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
				precision = precision * 10 + ch - '0';
  8007a2:	8d 42 d0             	lea    -0x30(%edx),%eax
  8007a5:	89 c1                	mov    %eax,%ecx
  8007a7:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  8007aa:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8007ae:	8d 50 d0             	lea    -0x30(%eax),%edx
  8007b1:	83 fa 09             	cmp    $0x9,%edx
  8007b4:	77 51                	ja     800807 <vprintfmt+0xfe>
  8007b6:	8b 75 10             	mov    0x10(%ebp),%esi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
  8007b9:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8007ba:	8d 14 89             	lea    (%ecx,%ecx,4),%edx
  8007bd:	01 d2                	add    %edx,%edx
  8007bf:	8d 4c 10 d0          	lea    -0x30(%eax,%edx,1),%ecx
				ch = *fmt;
  8007c3:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8007c6:	8d 50 d0             	lea    -0x30(%eax),%edx
  8007c9:	83 fa 09             	cmp    $0x9,%edx
  8007cc:	76 eb                	jbe    8007b9 <vprintfmt+0xb0>
  8007ce:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8007d1:	eb 37                	jmp    80080a <vprintfmt+0x101>
					break;
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
  8007d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d6:	8d 50 04             	lea    0x4(%eax),%edx
  8007d9:	89 55 14             	mov    %edx,0x14(%ebp)
  8007dc:	8b 00                	mov    (%eax),%eax
  8007de:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8007e1:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
			goto process_precision;
  8007e4:	eb 24                	jmp    80080a <vprintfmt+0x101>
  8007e6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007ea:	79 07                	jns    8007f3 <vprintfmt+0xea>
  8007ec:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8007f3:	8b 75 10             	mov    0x10(%ebp),%esi
  8007f6:	eb 81                	jmp    800779 <vprintfmt+0x70>
  8007f8:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  8007fb:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800802:	e9 72 ff ff ff       	jmp    800779 <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800807:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:									//处理输出精度，把width字段赋值为刚刚计算出来的precision值，所以width应该是整数部分的有效数字位数
			if (width < 0)
  80080a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80080e:	0f 89 65 ff ff ff    	jns    800779 <vprintfmt+0x70>
				width = precision, precision = -1;
  800814:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800817:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80081a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800821:	e9 53 ff ff ff       	jmp    800779 <vprintfmt+0x70>
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
  800826:	ff 45 d4             	incl   -0x2c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800829:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
			goto reswitch;
  80082c:	e9 48 ff ff ff       	jmp    800779 <vprintfmt+0x70>

		// character
		case 'c':											//如果是'c'代表显示一个字符
			putch(va_arg(ap, int), putdat);					//调用输出一个字符到内存的函数putch
  800831:	8b 45 14             	mov    0x14(%ebp),%eax
  800834:	8d 50 04             	lea    0x4(%eax),%edx
  800837:	89 55 14             	mov    %edx,0x14(%ebp)
  80083a:	83 ec 08             	sub    $0x8,%esp
  80083d:	53                   	push   %ebx
  80083e:	ff 30                	pushl  (%eax)
  800840:	ff d7                	call   *%edi
			break;
  800842:	83 c4 10             	add    $0x10,%esp
  800845:	e9 d3 fe ff ff       	jmp    80071d <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80084a:	8b 45 14             	mov    0x14(%ebp),%eax
  80084d:	8d 50 04             	lea    0x4(%eax),%edx
  800850:	89 55 14             	mov    %edx,0x14(%ebp)
  800853:	8b 00                	mov    (%eax),%eax
  800855:	85 c0                	test   %eax,%eax
  800857:	79 02                	jns    80085b <vprintfmt+0x152>
  800859:	f7 d8                	neg    %eax
  80085b:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80085d:	83 f8 0f             	cmp    $0xf,%eax
  800860:	7f 0b                	jg     80086d <vprintfmt+0x164>
  800862:	8b 04 85 c0 2e 80 00 	mov    0x802ec0(,%eax,4),%eax
  800869:	85 c0                	test   %eax,%eax
  80086b:	75 15                	jne    800882 <vprintfmt+0x179>
				printfmt(putch, putdat, "error %d", err);
  80086d:	52                   	push   %edx
  80086e:	68 27 2c 80 00       	push   $0x802c27
  800873:	53                   	push   %ebx
  800874:	57                   	push   %edi
  800875:	e8 72 fe ff ff       	call   8006ec <printfmt>
  80087a:	83 c4 10             	add    $0x10,%esp
  80087d:	e9 9b fe ff ff       	jmp    80071d <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  800882:	50                   	push   %eax
  800883:	68 c7 30 80 00       	push   $0x8030c7
  800888:	53                   	push   %ebx
  800889:	57                   	push   %edi
  80088a:	e8 5d fe ff ff       	call   8006ec <printfmt>
  80088f:	83 c4 10             	add    $0x10,%esp
  800892:	e9 86 fe ff ff       	jmp    80071d <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800897:	8b 45 14             	mov    0x14(%ebp),%eax
  80089a:	8d 50 04             	lea    0x4(%eax),%edx
  80089d:	89 55 14             	mov    %edx,0x14(%ebp)
  8008a0:	8b 00                	mov    (%eax),%eax
  8008a2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8008a5:	85 c0                	test   %eax,%eax
  8008a7:	75 07                	jne    8008b0 <vprintfmt+0x1a7>
				p = "(null)";
  8008a9:	c7 45 d4 20 2c 80 00 	movl   $0x802c20,-0x2c(%ebp)
			if (width > 0 && padc != '-')
  8008b0:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8008b3:	85 f6                	test   %esi,%esi
  8008b5:	0f 8e fb 01 00 00    	jle    800ab6 <vprintfmt+0x3ad>
  8008bb:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  8008bf:	0f 84 09 02 00 00    	je     800ace <vprintfmt+0x3c5>
				for (width -= strnlen(p, precision); width > 0; width--)
  8008c5:	83 ec 08             	sub    $0x8,%esp
  8008c8:	ff 75 d0             	pushl  -0x30(%ebp)
  8008cb:	ff 75 d4             	pushl  -0x2c(%ebp)
  8008ce:	e8 ad 02 00 00       	call   800b80 <strnlen>
  8008d3:	89 f1                	mov    %esi,%ecx
  8008d5:	29 c1                	sub    %eax,%ecx
  8008d7:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8008da:	83 c4 10             	add    $0x10,%esp
  8008dd:	85 c9                	test   %ecx,%ecx
  8008df:	0f 8e d1 01 00 00    	jle    800ab6 <vprintfmt+0x3ad>
					putch(padc, putdat);
  8008e5:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8008e9:	83 ec 08             	sub    $0x8,%esp
  8008ec:	53                   	push   %ebx
  8008ed:	56                   	push   %esi
  8008ee:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008f0:	83 c4 10             	add    $0x10,%esp
  8008f3:	ff 4d e4             	decl   -0x1c(%ebp)
  8008f6:	75 f1                	jne    8008e9 <vprintfmt+0x1e0>
  8008f8:	e9 b9 01 00 00       	jmp    800ab6 <vprintfmt+0x3ad>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8008fd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800901:	74 19                	je     80091c <vprintfmt+0x213>
  800903:	0f be c0             	movsbl %al,%eax
  800906:	83 e8 20             	sub    $0x20,%eax
  800909:	83 f8 5e             	cmp    $0x5e,%eax
  80090c:	76 0e                	jbe    80091c <vprintfmt+0x213>
					putch('?', putdat);
  80090e:	83 ec 08             	sub    $0x8,%esp
  800911:	53                   	push   %ebx
  800912:	6a 3f                	push   $0x3f
  800914:	ff 55 08             	call   *0x8(%ebp)
  800917:	83 c4 10             	add    $0x10,%esp
  80091a:	eb 0b                	jmp    800927 <vprintfmt+0x21e>
				else
					putch(ch, putdat);
  80091c:	83 ec 08             	sub    $0x8,%esp
  80091f:	53                   	push   %ebx
  800920:	52                   	push   %edx
  800921:	ff 55 08             	call   *0x8(%ebp)
  800924:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800927:	ff 4d e4             	decl   -0x1c(%ebp)
  80092a:	46                   	inc    %esi
  80092b:	8a 46 ff             	mov    -0x1(%esi),%al
  80092e:	0f be d0             	movsbl %al,%edx
  800931:	85 d2                	test   %edx,%edx
  800933:	75 1c                	jne    800951 <vprintfmt+0x248>
  800935:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800938:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80093c:	7f 1f                	jg     80095d <vprintfmt+0x254>
  80093e:	e9 da fd ff ff       	jmp    80071d <vprintfmt+0x14>
  800943:	89 7d 08             	mov    %edi,0x8(%ebp)
  800946:	8b 7d d0             	mov    -0x30(%ebp),%edi
  800949:	eb 06                	jmp    800951 <vprintfmt+0x248>
  80094b:	89 7d 08             	mov    %edi,0x8(%ebp)
  80094e:	8b 7d d0             	mov    -0x30(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800951:	85 ff                	test   %edi,%edi
  800953:	78 a8                	js     8008fd <vprintfmt+0x1f4>
  800955:	4f                   	dec    %edi
  800956:	79 a5                	jns    8008fd <vprintfmt+0x1f4>
  800958:	8b 7d 08             	mov    0x8(%ebp),%edi
  80095b:	eb db                	jmp    800938 <vprintfmt+0x22f>
  80095d:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800960:	83 ec 08             	sub    $0x8,%esp
  800963:	53                   	push   %ebx
  800964:	6a 20                	push   $0x20
  800966:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800968:	4e                   	dec    %esi
  800969:	83 c4 10             	add    $0x10,%esp
  80096c:	85 f6                	test   %esi,%esi
  80096e:	7f f0                	jg     800960 <vprintfmt+0x257>
  800970:	e9 a8 fd ff ff       	jmp    80071d <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800975:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  800979:	7e 16                	jle    800991 <vprintfmt+0x288>
		return va_arg(*ap, long long);
  80097b:	8b 45 14             	mov    0x14(%ebp),%eax
  80097e:	8d 50 08             	lea    0x8(%eax),%edx
  800981:	89 55 14             	mov    %edx,0x14(%ebp)
  800984:	8b 50 04             	mov    0x4(%eax),%edx
  800987:	8b 00                	mov    (%eax),%eax
  800989:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80098c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80098f:	eb 34                	jmp    8009c5 <vprintfmt+0x2bc>
	else if (lflag)
  800991:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800995:	74 18                	je     8009af <vprintfmt+0x2a6>
		return va_arg(*ap, long);
  800997:	8b 45 14             	mov    0x14(%ebp),%eax
  80099a:	8d 50 04             	lea    0x4(%eax),%edx
  80099d:	89 55 14             	mov    %edx,0x14(%ebp)
  8009a0:	8b 30                	mov    (%eax),%esi
  8009a2:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8009a5:	89 f0                	mov    %esi,%eax
  8009a7:	c1 f8 1f             	sar    $0x1f,%eax
  8009aa:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8009ad:	eb 16                	jmp    8009c5 <vprintfmt+0x2bc>
	else
		return va_arg(*ap, int);
  8009af:	8b 45 14             	mov    0x14(%ebp),%eax
  8009b2:	8d 50 04             	lea    0x4(%eax),%edx
  8009b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8009b8:	8b 30                	mov    (%eax),%esi
  8009ba:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8009bd:	89 f0                	mov    %esi,%eax
  8009bf:	c1 f8 1f             	sar    $0x1f,%eax
  8009c2:	89 45 dc             	mov    %eax,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8009c5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8009c8:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
  8009cb:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8009cf:	0f 89 8a 00 00 00    	jns    800a5f <vprintfmt+0x356>
				putch('-', putdat);
  8009d5:	83 ec 08             	sub    $0x8,%esp
  8009d8:	53                   	push   %ebx
  8009d9:	6a 2d                	push   $0x2d
  8009db:	ff d7                	call   *%edi
				num = -(long long) num;
  8009dd:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8009e0:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8009e3:	f7 d8                	neg    %eax
  8009e5:	83 d2 00             	adc    $0x0,%edx
  8009e8:	f7 da                	neg    %edx
  8009ea:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8009ed:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8009f2:	eb 70                	jmp    800a64 <vprintfmt+0x35b>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8009f4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8009f7:	8d 45 14             	lea    0x14(%ebp),%eax
  8009fa:	e8 97 fc ff ff       	call   800696 <getuint>
			base = 10;
  8009ff:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800a04:	eb 5e                	jmp    800a64 <vprintfmt+0x35b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  800a06:	83 ec 08             	sub    $0x8,%esp
  800a09:	53                   	push   %ebx
  800a0a:	6a 30                	push   $0x30
  800a0c:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  800a0e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800a11:	8d 45 14             	lea    0x14(%ebp),%eax
  800a14:	e8 7d fc ff ff       	call   800696 <getuint>
			base = 8;
			goto number;
  800a19:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800a1c:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800a21:	eb 41                	jmp    800a64 <vprintfmt+0x35b>
		// pointer
		case 'p':
			putch('0', putdat);
  800a23:	83 ec 08             	sub    $0x8,%esp
  800a26:	53                   	push   %ebx
  800a27:	6a 30                	push   $0x30
  800a29:	ff d7                	call   *%edi
			putch('x', putdat);
  800a2b:	83 c4 08             	add    $0x8,%esp
  800a2e:	53                   	push   %ebx
  800a2f:	6a 78                	push   $0x78
  800a31:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a33:	8b 45 14             	mov    0x14(%ebp),%eax
  800a36:	8d 50 04             	lea    0x4(%eax),%edx
  800a39:	89 55 14             	mov    %edx,0x14(%ebp)
			goto number;
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a3c:	8b 00                	mov    (%eax),%eax
  800a3e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800a43:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a46:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800a4b:	eb 17                	jmp    800a64 <vprintfmt+0x35b>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a4d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800a50:	8d 45 14             	lea    0x14(%ebp),%eax
  800a53:	e8 3e fc ff ff       	call   800696 <getuint>
			base = 16;
  800a58:	b9 10 00 00 00       	mov    $0x10,%ecx
  800a5d:	eb 05                	jmp    800a64 <vprintfmt+0x35b>
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800a5f:	b9 0a 00 00 00       	mov    $0xa,%ecx
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a64:	83 ec 0c             	sub    $0xc,%esp
  800a67:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800a6b:	56                   	push   %esi
  800a6c:	ff 75 e4             	pushl  -0x1c(%ebp)
  800a6f:	51                   	push   %ecx
  800a70:	52                   	push   %edx
  800a71:	50                   	push   %eax
  800a72:	89 da                	mov    %ebx,%edx
  800a74:	89 f8                	mov    %edi,%eax
  800a76:	e8 6b fb ff ff       	call   8005e6 <printnum>
			break;
  800a7b:	83 c4 20             	add    $0x20,%esp
  800a7e:	e9 9a fc ff ff       	jmp    80071d <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a83:	83 ec 08             	sub    $0x8,%esp
  800a86:	53                   	push   %ebx
  800a87:	52                   	push   %edx
  800a88:	ff d7                	call   *%edi
			break;
  800a8a:	83 c4 10             	add    $0x10,%esp
  800a8d:	e9 8b fc ff ff       	jmp    80071d <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a92:	83 ec 08             	sub    $0x8,%esp
  800a95:	53                   	push   %ebx
  800a96:	6a 25                	push   $0x25
  800a98:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a9a:	83 c4 10             	add    $0x10,%esp
  800a9d:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800aa1:	0f 84 73 fc ff ff    	je     80071a <vprintfmt+0x11>
  800aa7:	4e                   	dec    %esi
  800aa8:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800aac:	75 f9                	jne    800aa7 <vprintfmt+0x39e>
  800aae:	89 75 10             	mov    %esi,0x10(%ebp)
  800ab1:	e9 67 fc ff ff       	jmp    80071d <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800ab6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800ab9:	8d 70 01             	lea    0x1(%eax),%esi
  800abc:	8a 00                	mov    (%eax),%al
  800abe:	0f be d0             	movsbl %al,%edx
  800ac1:	85 d2                	test   %edx,%edx
  800ac3:	0f 85 7a fe ff ff    	jne    800943 <vprintfmt+0x23a>
  800ac9:	e9 4f fc ff ff       	jmp    80071d <vprintfmt+0x14>
  800ace:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800ad1:	8d 70 01             	lea    0x1(%eax),%esi
  800ad4:	8a 00                	mov    (%eax),%al
  800ad6:	0f be d0             	movsbl %al,%edx
  800ad9:	85 d2                	test   %edx,%edx
  800adb:	0f 85 6a fe ff ff    	jne    80094b <vprintfmt+0x242>
  800ae1:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800ae4:	e9 77 fe ff ff       	jmp    800960 <vprintfmt+0x257>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800ae9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800aec:	5b                   	pop    %ebx
  800aed:	5e                   	pop    %esi
  800aee:	5f                   	pop    %edi
  800aef:	5d                   	pop    %ebp
  800af0:	c3                   	ret    

00800af1 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800af1:	55                   	push   %ebp
  800af2:	89 e5                	mov    %esp,%ebp
  800af4:	83 ec 18             	sub    $0x18,%esp
  800af7:	8b 45 08             	mov    0x8(%ebp),%eax
  800afa:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800afd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b00:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800b04:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800b07:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b0e:	85 c0                	test   %eax,%eax
  800b10:	74 26                	je     800b38 <vsnprintf+0x47>
  800b12:	85 d2                	test   %edx,%edx
  800b14:	7e 29                	jle    800b3f <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b16:	ff 75 14             	pushl  0x14(%ebp)
  800b19:	ff 75 10             	pushl  0x10(%ebp)
  800b1c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b1f:	50                   	push   %eax
  800b20:	68 d0 06 80 00       	push   $0x8006d0
  800b25:	e8 df fb ff ff       	call   800709 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b2a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b2d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b30:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b33:	83 c4 10             	add    $0x10,%esp
  800b36:	eb 0c                	jmp    800b44 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800b38:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b3d:	eb 05                	jmp    800b44 <vsnprintf+0x53>
  800b3f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800b44:	c9                   	leave  
  800b45:	c3                   	ret    

00800b46 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b46:	55                   	push   %ebp
  800b47:	89 e5                	mov    %esp,%ebp
  800b49:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b4c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800b4f:	50                   	push   %eax
  800b50:	ff 75 10             	pushl  0x10(%ebp)
  800b53:	ff 75 0c             	pushl  0xc(%ebp)
  800b56:	ff 75 08             	pushl  0x8(%ebp)
  800b59:	e8 93 ff ff ff       	call   800af1 <vsnprintf>
	va_end(ap);

	return rc;
}
  800b5e:	c9                   	leave  
  800b5f:	c3                   	ret    

00800b60 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b60:	55                   	push   %ebp
  800b61:	89 e5                	mov    %esp,%ebp
  800b63:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b66:	80 3a 00             	cmpb   $0x0,(%edx)
  800b69:	74 0e                	je     800b79 <strlen+0x19>
  800b6b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800b70:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b71:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b75:	75 f9                	jne    800b70 <strlen+0x10>
  800b77:	eb 05                	jmp    800b7e <strlen+0x1e>
  800b79:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800b7e:	5d                   	pop    %ebp
  800b7f:	c3                   	ret    

00800b80 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b80:	55                   	push   %ebp
  800b81:	89 e5                	mov    %esp,%ebp
  800b83:	53                   	push   %ebx
  800b84:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b87:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b8a:	85 c9                	test   %ecx,%ecx
  800b8c:	74 1a                	je     800ba8 <strnlen+0x28>
  800b8e:	80 3b 00             	cmpb   $0x0,(%ebx)
  800b91:	74 1c                	je     800baf <strnlen+0x2f>
  800b93:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800b98:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b9a:	39 ca                	cmp    %ecx,%edx
  800b9c:	74 16                	je     800bb4 <strnlen+0x34>
  800b9e:	42                   	inc    %edx
  800b9f:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800ba4:	75 f2                	jne    800b98 <strnlen+0x18>
  800ba6:	eb 0c                	jmp    800bb4 <strnlen+0x34>
  800ba8:	b8 00 00 00 00       	mov    $0x0,%eax
  800bad:	eb 05                	jmp    800bb4 <strnlen+0x34>
  800baf:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800bb4:	5b                   	pop    %ebx
  800bb5:	5d                   	pop    %ebp
  800bb6:	c3                   	ret    

00800bb7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800bb7:	55                   	push   %ebp
  800bb8:	89 e5                	mov    %esp,%ebp
  800bba:	53                   	push   %ebx
  800bbb:	8b 45 08             	mov    0x8(%ebp),%eax
  800bbe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800bc1:	89 c2                	mov    %eax,%edx
  800bc3:	42                   	inc    %edx
  800bc4:	41                   	inc    %ecx
  800bc5:	8a 59 ff             	mov    -0x1(%ecx),%bl
  800bc8:	88 5a ff             	mov    %bl,-0x1(%edx)
  800bcb:	84 db                	test   %bl,%bl
  800bcd:	75 f4                	jne    800bc3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800bcf:	5b                   	pop    %ebx
  800bd0:	5d                   	pop    %ebp
  800bd1:	c3                   	ret    

00800bd2 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800bd2:	55                   	push   %ebp
  800bd3:	89 e5                	mov    %esp,%ebp
  800bd5:	53                   	push   %ebx
  800bd6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800bd9:	53                   	push   %ebx
  800bda:	e8 81 ff ff ff       	call   800b60 <strlen>
  800bdf:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800be2:	ff 75 0c             	pushl  0xc(%ebp)
  800be5:	01 d8                	add    %ebx,%eax
  800be7:	50                   	push   %eax
  800be8:	e8 ca ff ff ff       	call   800bb7 <strcpy>
	return dst;
}
  800bed:	89 d8                	mov    %ebx,%eax
  800bef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bf2:	c9                   	leave  
  800bf3:	c3                   	ret    

00800bf4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800bf4:	55                   	push   %ebp
  800bf5:	89 e5                	mov    %esp,%ebp
  800bf7:	56                   	push   %esi
  800bf8:	53                   	push   %ebx
  800bf9:	8b 75 08             	mov    0x8(%ebp),%esi
  800bfc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bff:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c02:	85 db                	test   %ebx,%ebx
  800c04:	74 14                	je     800c1a <strncpy+0x26>
  800c06:	01 f3                	add    %esi,%ebx
  800c08:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800c0a:	41                   	inc    %ecx
  800c0b:	8a 02                	mov    (%edx),%al
  800c0d:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800c10:	80 3a 01             	cmpb   $0x1,(%edx)
  800c13:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c16:	39 cb                	cmp    %ecx,%ebx
  800c18:	75 f0                	jne    800c0a <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800c1a:	89 f0                	mov    %esi,%eax
  800c1c:	5b                   	pop    %ebx
  800c1d:	5e                   	pop    %esi
  800c1e:	5d                   	pop    %ebp
  800c1f:	c3                   	ret    

00800c20 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c20:	55                   	push   %ebp
  800c21:	89 e5                	mov    %esp,%ebp
  800c23:	53                   	push   %ebx
  800c24:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c27:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c2a:	85 c0                	test   %eax,%eax
  800c2c:	74 30                	je     800c5e <strlcpy+0x3e>
		while (--size > 0 && *src != '\0')
  800c2e:	48                   	dec    %eax
  800c2f:	74 20                	je     800c51 <strlcpy+0x31>
  800c31:	8a 0b                	mov    (%ebx),%cl
  800c33:	84 c9                	test   %cl,%cl
  800c35:	74 1f                	je     800c56 <strlcpy+0x36>
  800c37:	8d 53 01             	lea    0x1(%ebx),%edx
  800c3a:	01 c3                	add    %eax,%ebx
  800c3c:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
  800c3f:	40                   	inc    %eax
  800c40:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c43:	39 da                	cmp    %ebx,%edx
  800c45:	74 12                	je     800c59 <strlcpy+0x39>
  800c47:	42                   	inc    %edx
  800c48:	8a 4a ff             	mov    -0x1(%edx),%cl
  800c4b:	84 c9                	test   %cl,%cl
  800c4d:	75 f0                	jne    800c3f <strlcpy+0x1f>
  800c4f:	eb 08                	jmp    800c59 <strlcpy+0x39>
  800c51:	8b 45 08             	mov    0x8(%ebp),%eax
  800c54:	eb 03                	jmp    800c59 <strlcpy+0x39>
  800c56:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
		*dst = '\0';
  800c59:	c6 00 00             	movb   $0x0,(%eax)
  800c5c:	eb 03                	jmp    800c61 <strlcpy+0x41>
  800c5e:	8b 45 08             	mov    0x8(%ebp),%eax
	}
	return dst - dst_in;
  800c61:	2b 45 08             	sub    0x8(%ebp),%eax
}
  800c64:	5b                   	pop    %ebx
  800c65:	5d                   	pop    %ebp
  800c66:	c3                   	ret    

00800c67 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c67:	55                   	push   %ebp
  800c68:	89 e5                	mov    %esp,%ebp
  800c6a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c6d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c70:	8a 01                	mov    (%ecx),%al
  800c72:	84 c0                	test   %al,%al
  800c74:	74 10                	je     800c86 <strcmp+0x1f>
  800c76:	3a 02                	cmp    (%edx),%al
  800c78:	75 0c                	jne    800c86 <strcmp+0x1f>
		p++, q++;
  800c7a:	41                   	inc    %ecx
  800c7b:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800c7c:	8a 01                	mov    (%ecx),%al
  800c7e:	84 c0                	test   %al,%al
  800c80:	74 04                	je     800c86 <strcmp+0x1f>
  800c82:	3a 02                	cmp    (%edx),%al
  800c84:	74 f4                	je     800c7a <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c86:	0f b6 c0             	movzbl %al,%eax
  800c89:	0f b6 12             	movzbl (%edx),%edx
  800c8c:	29 d0                	sub    %edx,%eax
}
  800c8e:	5d                   	pop    %ebp
  800c8f:	c3                   	ret    

00800c90 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c90:	55                   	push   %ebp
  800c91:	89 e5                	mov    %esp,%ebp
  800c93:	56                   	push   %esi
  800c94:	53                   	push   %ebx
  800c95:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800c98:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c9b:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800c9e:	85 f6                	test   %esi,%esi
  800ca0:	74 23                	je     800cc5 <strncmp+0x35>
  800ca2:	8a 03                	mov    (%ebx),%al
  800ca4:	84 c0                	test   %al,%al
  800ca6:	74 2b                	je     800cd3 <strncmp+0x43>
  800ca8:	3a 02                	cmp    (%edx),%al
  800caa:	75 27                	jne    800cd3 <strncmp+0x43>
  800cac:	8d 43 01             	lea    0x1(%ebx),%eax
  800caf:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800cb1:	89 c3                	mov    %eax,%ebx
  800cb3:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800cb4:	39 c6                	cmp    %eax,%esi
  800cb6:	74 14                	je     800ccc <strncmp+0x3c>
  800cb8:	8a 08                	mov    (%eax),%cl
  800cba:	84 c9                	test   %cl,%cl
  800cbc:	74 15                	je     800cd3 <strncmp+0x43>
  800cbe:	40                   	inc    %eax
  800cbf:	3a 0a                	cmp    (%edx),%cl
  800cc1:	74 ee                	je     800cb1 <strncmp+0x21>
  800cc3:	eb 0e                	jmp    800cd3 <strncmp+0x43>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800cc5:	b8 00 00 00 00       	mov    $0x0,%eax
  800cca:	eb 0f                	jmp    800cdb <strncmp+0x4b>
  800ccc:	b8 00 00 00 00       	mov    $0x0,%eax
  800cd1:	eb 08                	jmp    800cdb <strncmp+0x4b>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800cd3:	0f b6 03             	movzbl (%ebx),%eax
  800cd6:	0f b6 12             	movzbl (%edx),%edx
  800cd9:	29 d0                	sub    %edx,%eax
}
  800cdb:	5b                   	pop    %ebx
  800cdc:	5e                   	pop    %esi
  800cdd:	5d                   	pop    %ebp
  800cde:	c3                   	ret    

00800cdf <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800cdf:	55                   	push   %ebp
  800ce0:	89 e5                	mov    %esp,%ebp
  800ce2:	53                   	push   %ebx
  800ce3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800ce9:	8a 10                	mov    (%eax),%dl
  800ceb:	84 d2                	test   %dl,%dl
  800ced:	74 1a                	je     800d09 <strchr+0x2a>
  800cef:	88 d9                	mov    %bl,%cl
		if (*s == c)
  800cf1:	38 d3                	cmp    %dl,%bl
  800cf3:	75 06                	jne    800cfb <strchr+0x1c>
  800cf5:	eb 17                	jmp    800d0e <strchr+0x2f>
  800cf7:	38 ca                	cmp    %cl,%dl
  800cf9:	74 13                	je     800d0e <strchr+0x2f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800cfb:	40                   	inc    %eax
  800cfc:	8a 10                	mov    (%eax),%dl
  800cfe:	84 d2                	test   %dl,%dl
  800d00:	75 f5                	jne    800cf7 <strchr+0x18>
		if (*s == c)
			return (char *) s;
	return 0;
  800d02:	b8 00 00 00 00       	mov    $0x0,%eax
  800d07:	eb 05                	jmp    800d0e <strchr+0x2f>
  800d09:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d0e:	5b                   	pop    %ebx
  800d0f:	5d                   	pop    %ebp
  800d10:	c3                   	ret    

00800d11 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d11:	55                   	push   %ebp
  800d12:	89 e5                	mov    %esp,%ebp
  800d14:	53                   	push   %ebx
  800d15:	8b 45 08             	mov    0x8(%ebp),%eax
  800d18:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800d1b:	8a 10                	mov    (%eax),%dl
  800d1d:	84 d2                	test   %dl,%dl
  800d1f:	74 13                	je     800d34 <strfind+0x23>
  800d21:	88 d9                	mov    %bl,%cl
		if (*s == c)
  800d23:	38 d3                	cmp    %dl,%bl
  800d25:	75 06                	jne    800d2d <strfind+0x1c>
  800d27:	eb 0b                	jmp    800d34 <strfind+0x23>
  800d29:	38 ca                	cmp    %cl,%dl
  800d2b:	74 07                	je     800d34 <strfind+0x23>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800d2d:	40                   	inc    %eax
  800d2e:	8a 10                	mov    (%eax),%dl
  800d30:	84 d2                	test   %dl,%dl
  800d32:	75 f5                	jne    800d29 <strfind+0x18>
		if (*s == c)
			break;
	return (char *) s;
}
  800d34:	5b                   	pop    %ebx
  800d35:	5d                   	pop    %ebp
  800d36:	c3                   	ret    

00800d37 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d37:	55                   	push   %ebp
  800d38:	89 e5                	mov    %esp,%ebp
  800d3a:	57                   	push   %edi
  800d3b:	56                   	push   %esi
  800d3c:	53                   	push   %ebx
  800d3d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d40:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800d43:	85 c9                	test   %ecx,%ecx
  800d45:	74 36                	je     800d7d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d47:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d4d:	75 28                	jne    800d77 <memset+0x40>
  800d4f:	f6 c1 03             	test   $0x3,%cl
  800d52:	75 23                	jne    800d77 <memset+0x40>
		c &= 0xFF;
  800d54:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d58:	89 d3                	mov    %edx,%ebx
  800d5a:	c1 e3 08             	shl    $0x8,%ebx
  800d5d:	89 d6                	mov    %edx,%esi
  800d5f:	c1 e6 18             	shl    $0x18,%esi
  800d62:	89 d0                	mov    %edx,%eax
  800d64:	c1 e0 10             	shl    $0x10,%eax
  800d67:	09 f0                	or     %esi,%eax
  800d69:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800d6b:	89 d8                	mov    %ebx,%eax
  800d6d:	09 d0                	or     %edx,%eax
  800d6f:	c1 e9 02             	shr    $0x2,%ecx
  800d72:	fc                   	cld    
  800d73:	f3 ab                	rep stos %eax,%es:(%edi)
  800d75:	eb 06                	jmp    800d7d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d77:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d7a:	fc                   	cld    
  800d7b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d7d:	89 f8                	mov    %edi,%eax
  800d7f:	5b                   	pop    %ebx
  800d80:	5e                   	pop    %esi
  800d81:	5f                   	pop    %edi
  800d82:	5d                   	pop    %ebp
  800d83:	c3                   	ret    

00800d84 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d84:	55                   	push   %ebp
  800d85:	89 e5                	mov    %esp,%ebp
  800d87:	57                   	push   %edi
  800d88:	56                   	push   %esi
  800d89:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d8f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d92:	39 c6                	cmp    %eax,%esi
  800d94:	73 33                	jae    800dc9 <memmove+0x45>
  800d96:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d99:	39 d0                	cmp    %edx,%eax
  800d9b:	73 2c                	jae    800dc9 <memmove+0x45>
		s += n;
		d += n;
  800d9d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800da0:	89 d6                	mov    %edx,%esi
  800da2:	09 fe                	or     %edi,%esi
  800da4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800daa:	75 13                	jne    800dbf <memmove+0x3b>
  800dac:	f6 c1 03             	test   $0x3,%cl
  800daf:	75 0e                	jne    800dbf <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800db1:	83 ef 04             	sub    $0x4,%edi
  800db4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800db7:	c1 e9 02             	shr    $0x2,%ecx
  800dba:	fd                   	std    
  800dbb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800dbd:	eb 07                	jmp    800dc6 <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800dbf:	4f                   	dec    %edi
  800dc0:	8d 72 ff             	lea    -0x1(%edx),%esi
  800dc3:	fd                   	std    
  800dc4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800dc6:	fc                   	cld    
  800dc7:	eb 1d                	jmp    800de6 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800dc9:	89 f2                	mov    %esi,%edx
  800dcb:	09 c2                	or     %eax,%edx
  800dcd:	f6 c2 03             	test   $0x3,%dl
  800dd0:	75 0f                	jne    800de1 <memmove+0x5d>
  800dd2:	f6 c1 03             	test   $0x3,%cl
  800dd5:	75 0a                	jne    800de1 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
  800dd7:	c1 e9 02             	shr    $0x2,%ecx
  800dda:	89 c7                	mov    %eax,%edi
  800ddc:	fc                   	cld    
  800ddd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ddf:	eb 05                	jmp    800de6 <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800de1:	89 c7                	mov    %eax,%edi
  800de3:	fc                   	cld    
  800de4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800de6:	5e                   	pop    %esi
  800de7:	5f                   	pop    %edi
  800de8:	5d                   	pop    %ebp
  800de9:	c3                   	ret    

00800dea <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800dea:	55                   	push   %ebp
  800deb:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ded:	ff 75 10             	pushl  0x10(%ebp)
  800df0:	ff 75 0c             	pushl  0xc(%ebp)
  800df3:	ff 75 08             	pushl  0x8(%ebp)
  800df6:	e8 89 ff ff ff       	call   800d84 <memmove>
}
  800dfb:	c9                   	leave  
  800dfc:	c3                   	ret    

00800dfd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800dfd:	55                   	push   %ebp
  800dfe:	89 e5                	mov    %esp,%ebp
  800e00:	57                   	push   %edi
  800e01:	56                   	push   %esi
  800e02:	53                   	push   %ebx
  800e03:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800e06:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e09:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e0c:	85 c0                	test   %eax,%eax
  800e0e:	74 33                	je     800e43 <memcmp+0x46>
  800e10:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800e13:	8a 13                	mov    (%ebx),%dl
  800e15:	8a 0e                	mov    (%esi),%cl
  800e17:	38 ca                	cmp    %cl,%dl
  800e19:	75 13                	jne    800e2e <memcmp+0x31>
  800e1b:	b8 00 00 00 00       	mov    $0x0,%eax
  800e20:	eb 16                	jmp    800e38 <memcmp+0x3b>
  800e22:	8a 54 03 01          	mov    0x1(%ebx,%eax,1),%dl
  800e26:	40                   	inc    %eax
  800e27:	8a 0c 06             	mov    (%esi,%eax,1),%cl
  800e2a:	38 ca                	cmp    %cl,%dl
  800e2c:	74 0a                	je     800e38 <memcmp+0x3b>
			return (int) *s1 - (int) *s2;
  800e2e:	0f b6 c2             	movzbl %dl,%eax
  800e31:	0f b6 c9             	movzbl %cl,%ecx
  800e34:	29 c8                	sub    %ecx,%eax
  800e36:	eb 10                	jmp    800e48 <memcmp+0x4b>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e38:	39 f8                	cmp    %edi,%eax
  800e3a:	75 e6                	jne    800e22 <memcmp+0x25>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800e3c:	b8 00 00 00 00       	mov    $0x0,%eax
  800e41:	eb 05                	jmp    800e48 <memcmp+0x4b>
  800e43:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e48:	5b                   	pop    %ebx
  800e49:	5e                   	pop    %esi
  800e4a:	5f                   	pop    %edi
  800e4b:	5d                   	pop    %ebp
  800e4c:	c3                   	ret    

00800e4d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e4d:	55                   	push   %ebp
  800e4e:	89 e5                	mov    %esp,%ebp
  800e50:	53                   	push   %ebx
  800e51:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800e54:	89 d0                	mov    %edx,%eax
  800e56:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800e59:	39 c2                	cmp    %eax,%edx
  800e5b:	73 1b                	jae    800e78 <memfind+0x2b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e5d:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800e61:	0f b6 0a             	movzbl (%edx),%ecx
  800e64:	39 d9                	cmp    %ebx,%ecx
  800e66:	75 09                	jne    800e71 <memfind+0x24>
  800e68:	eb 12                	jmp    800e7c <memfind+0x2f>
  800e6a:	0f b6 0a             	movzbl (%edx),%ecx
  800e6d:	39 d9                	cmp    %ebx,%ecx
  800e6f:	74 0f                	je     800e80 <memfind+0x33>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e71:	42                   	inc    %edx
  800e72:	39 d0                	cmp    %edx,%eax
  800e74:	75 f4                	jne    800e6a <memfind+0x1d>
  800e76:	eb 0a                	jmp    800e82 <memfind+0x35>
  800e78:	89 d0                	mov    %edx,%eax
  800e7a:	eb 06                	jmp    800e82 <memfind+0x35>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e7c:	89 d0                	mov    %edx,%eax
  800e7e:	eb 02                	jmp    800e82 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e80:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800e82:	5b                   	pop    %ebx
  800e83:	5d                   	pop    %ebp
  800e84:	c3                   	ret    

00800e85 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e85:	55                   	push   %ebp
  800e86:	89 e5                	mov    %esp,%ebp
  800e88:	57                   	push   %edi
  800e89:	56                   	push   %esi
  800e8a:	53                   	push   %ebx
  800e8b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e8e:	eb 01                	jmp    800e91 <strtol+0xc>
		s++;
  800e90:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e91:	8a 01                	mov    (%ecx),%al
  800e93:	3c 20                	cmp    $0x20,%al
  800e95:	74 f9                	je     800e90 <strtol+0xb>
  800e97:	3c 09                	cmp    $0x9,%al
  800e99:	74 f5                	je     800e90 <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  800e9b:	3c 2b                	cmp    $0x2b,%al
  800e9d:	75 08                	jne    800ea7 <strtol+0x22>
		s++;
  800e9f:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ea0:	bf 00 00 00 00       	mov    $0x0,%edi
  800ea5:	eb 11                	jmp    800eb8 <strtol+0x33>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ea7:	3c 2d                	cmp    $0x2d,%al
  800ea9:	75 08                	jne    800eb3 <strtol+0x2e>
		s++, neg = 1;
  800eab:	41                   	inc    %ecx
  800eac:	bf 01 00 00 00       	mov    $0x1,%edi
  800eb1:	eb 05                	jmp    800eb8 <strtol+0x33>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800eb3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800eb8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ebc:	0f 84 87 00 00 00    	je     800f49 <strtol+0xc4>
  800ec2:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800ec6:	75 27                	jne    800eef <strtol+0x6a>
  800ec8:	80 39 30             	cmpb   $0x30,(%ecx)
  800ecb:	75 22                	jne    800eef <strtol+0x6a>
  800ecd:	e9 88 00 00 00       	jmp    800f5a <strtol+0xd5>
		s += 2, base = 16;
  800ed2:	83 c1 02             	add    $0x2,%ecx
  800ed5:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800edc:	eb 11                	jmp    800eef <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
  800ede:	41                   	inc    %ecx
  800edf:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800ee6:	eb 07                	jmp    800eef <strtol+0x6a>
	else if (base == 0)
		base = 10;
  800ee8:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  800eef:	b8 00 00 00 00       	mov    $0x0,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ef4:	8a 11                	mov    (%ecx),%dl
  800ef6:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800ef9:	80 fb 09             	cmp    $0x9,%bl
  800efc:	77 08                	ja     800f06 <strtol+0x81>
			dig = *s - '0';
  800efe:	0f be d2             	movsbl %dl,%edx
  800f01:	83 ea 30             	sub    $0x30,%edx
  800f04:	eb 22                	jmp    800f28 <strtol+0xa3>
		else if (*s >= 'a' && *s <= 'z')
  800f06:	8d 72 9f             	lea    -0x61(%edx),%esi
  800f09:	89 f3                	mov    %esi,%ebx
  800f0b:	80 fb 19             	cmp    $0x19,%bl
  800f0e:	77 08                	ja     800f18 <strtol+0x93>
			dig = *s - 'a' + 10;
  800f10:	0f be d2             	movsbl %dl,%edx
  800f13:	83 ea 57             	sub    $0x57,%edx
  800f16:	eb 10                	jmp    800f28 <strtol+0xa3>
		else if (*s >= 'A' && *s <= 'Z')
  800f18:	8d 72 bf             	lea    -0x41(%edx),%esi
  800f1b:	89 f3                	mov    %esi,%ebx
  800f1d:	80 fb 19             	cmp    $0x19,%bl
  800f20:	77 14                	ja     800f36 <strtol+0xb1>
			dig = *s - 'A' + 10;
  800f22:	0f be d2             	movsbl %dl,%edx
  800f25:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800f28:	3b 55 10             	cmp    0x10(%ebp),%edx
  800f2b:	7d 09                	jge    800f36 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800f2d:	41                   	inc    %ecx
  800f2e:	0f af 45 10          	imul   0x10(%ebp),%eax
  800f32:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800f34:	eb be                	jmp    800ef4 <strtol+0x6f>

	if (endptr)
  800f36:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f3a:	74 05                	je     800f41 <strtol+0xbc>
		*endptr = (char *) s;
  800f3c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f3f:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800f41:	85 ff                	test   %edi,%edi
  800f43:	74 21                	je     800f66 <strtol+0xe1>
  800f45:	f7 d8                	neg    %eax
  800f47:	eb 1d                	jmp    800f66 <strtol+0xe1>
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f49:	80 39 30             	cmpb   $0x30,(%ecx)
  800f4c:	75 9a                	jne    800ee8 <strtol+0x63>
  800f4e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800f52:	0f 84 7a ff ff ff    	je     800ed2 <strtol+0x4d>
  800f58:	eb 84                	jmp    800ede <strtol+0x59>
  800f5a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800f5e:	0f 84 6e ff ff ff    	je     800ed2 <strtol+0x4d>
  800f64:	eb 89                	jmp    800eef <strtol+0x6a>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  800f66:	5b                   	pop    %ebx
  800f67:	5e                   	pop    %esi
  800f68:	5f                   	pop    %edi
  800f69:	5d                   	pop    %ebp
  800f6a:	c3                   	ret    

00800f6b <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800f6b:	55                   	push   %ebp
  800f6c:	89 e5                	mov    %esp,%ebp
  800f6e:	57                   	push   %edi
  800f6f:	56                   	push   %esi
  800f70:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f71:	b8 00 00 00 00       	mov    $0x0,%eax
  800f76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f79:	8b 55 08             	mov    0x8(%ebp),%edx
  800f7c:	89 c3                	mov    %eax,%ebx
  800f7e:	89 c7                	mov    %eax,%edi
  800f80:	89 c6                	mov    %eax,%esi
  800f82:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800f84:	5b                   	pop    %ebx
  800f85:	5e                   	pop    %esi
  800f86:	5f                   	pop    %edi
  800f87:	5d                   	pop    %ebp
  800f88:	c3                   	ret    

00800f89 <sys_cgetc>:

int
sys_cgetc(void)
{
  800f89:	55                   	push   %ebp
  800f8a:	89 e5                	mov    %esp,%ebp
  800f8c:	57                   	push   %edi
  800f8d:	56                   	push   %esi
  800f8e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f8f:	ba 00 00 00 00       	mov    $0x0,%edx
  800f94:	b8 01 00 00 00       	mov    $0x1,%eax
  800f99:	89 d1                	mov    %edx,%ecx
  800f9b:	89 d3                	mov    %edx,%ebx
  800f9d:	89 d7                	mov    %edx,%edi
  800f9f:	89 d6                	mov    %edx,%esi
  800fa1:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800fa3:	5b                   	pop    %ebx
  800fa4:	5e                   	pop    %esi
  800fa5:	5f                   	pop    %edi
  800fa6:	5d                   	pop    %ebp
  800fa7:	c3                   	ret    

00800fa8 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800fa8:	55                   	push   %ebp
  800fa9:	89 e5                	mov    %esp,%ebp
  800fab:	57                   	push   %edi
  800fac:	56                   	push   %esi
  800fad:	53                   	push   %ebx
  800fae:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fb1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fb6:	b8 03 00 00 00       	mov    $0x3,%eax
  800fbb:	8b 55 08             	mov    0x8(%ebp),%edx
  800fbe:	89 cb                	mov    %ecx,%ebx
  800fc0:	89 cf                	mov    %ecx,%edi
  800fc2:	89 ce                	mov    %ecx,%esi
  800fc4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fc6:	85 c0                	test   %eax,%eax
  800fc8:	7e 17                	jle    800fe1 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fca:	83 ec 0c             	sub    $0xc,%esp
  800fcd:	50                   	push   %eax
  800fce:	6a 03                	push   $0x3
  800fd0:	68 1f 2f 80 00       	push   $0x802f1f
  800fd5:	6a 23                	push   $0x23
  800fd7:	68 3c 2f 80 00       	push   $0x802f3c
  800fdc:	e8 19 f5 ff ff       	call   8004fa <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800fe1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fe4:	5b                   	pop    %ebx
  800fe5:	5e                   	pop    %esi
  800fe6:	5f                   	pop    %edi
  800fe7:	5d                   	pop    %ebp
  800fe8:	c3                   	ret    

00800fe9 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800fe9:	55                   	push   %ebp
  800fea:	89 e5                	mov    %esp,%ebp
  800fec:	57                   	push   %edi
  800fed:	56                   	push   %esi
  800fee:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fef:	ba 00 00 00 00       	mov    $0x0,%edx
  800ff4:	b8 02 00 00 00       	mov    $0x2,%eax
  800ff9:	89 d1                	mov    %edx,%ecx
  800ffb:	89 d3                	mov    %edx,%ebx
  800ffd:	89 d7                	mov    %edx,%edi
  800fff:	89 d6                	mov    %edx,%esi
  801001:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801003:	5b                   	pop    %ebx
  801004:	5e                   	pop    %esi
  801005:	5f                   	pop    %edi
  801006:	5d                   	pop    %ebp
  801007:	c3                   	ret    

00801008 <sys_yield>:

void
sys_yield(void)
{
  801008:	55                   	push   %ebp
  801009:	89 e5                	mov    %esp,%ebp
  80100b:	57                   	push   %edi
  80100c:	56                   	push   %esi
  80100d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80100e:	ba 00 00 00 00       	mov    $0x0,%edx
  801013:	b8 0b 00 00 00       	mov    $0xb,%eax
  801018:	89 d1                	mov    %edx,%ecx
  80101a:	89 d3                	mov    %edx,%ebx
  80101c:	89 d7                	mov    %edx,%edi
  80101e:	89 d6                	mov    %edx,%esi
  801020:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801022:	5b                   	pop    %ebx
  801023:	5e                   	pop    %esi
  801024:	5f                   	pop    %edi
  801025:	5d                   	pop    %ebp
  801026:	c3                   	ret    

00801027 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801027:	55                   	push   %ebp
  801028:	89 e5                	mov    %esp,%ebp
  80102a:	57                   	push   %edi
  80102b:	56                   	push   %esi
  80102c:	53                   	push   %ebx
  80102d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801030:	be 00 00 00 00       	mov    $0x0,%esi
  801035:	b8 04 00 00 00       	mov    $0x4,%eax
  80103a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80103d:	8b 55 08             	mov    0x8(%ebp),%edx
  801040:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801043:	89 f7                	mov    %esi,%edi
  801045:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801047:	85 c0                	test   %eax,%eax
  801049:	7e 17                	jle    801062 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80104b:	83 ec 0c             	sub    $0xc,%esp
  80104e:	50                   	push   %eax
  80104f:	6a 04                	push   $0x4
  801051:	68 1f 2f 80 00       	push   $0x802f1f
  801056:	6a 23                	push   $0x23
  801058:	68 3c 2f 80 00       	push   $0x802f3c
  80105d:	e8 98 f4 ff ff       	call   8004fa <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801062:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801065:	5b                   	pop    %ebx
  801066:	5e                   	pop    %esi
  801067:	5f                   	pop    %edi
  801068:	5d                   	pop    %ebp
  801069:	c3                   	ret    

0080106a <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80106a:	55                   	push   %ebp
  80106b:	89 e5                	mov    %esp,%ebp
  80106d:	57                   	push   %edi
  80106e:	56                   	push   %esi
  80106f:	53                   	push   %ebx
  801070:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801073:	b8 05 00 00 00       	mov    $0x5,%eax
  801078:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80107b:	8b 55 08             	mov    0x8(%ebp),%edx
  80107e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801081:	8b 7d 14             	mov    0x14(%ebp),%edi
  801084:	8b 75 18             	mov    0x18(%ebp),%esi
  801087:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801089:	85 c0                	test   %eax,%eax
  80108b:	7e 17                	jle    8010a4 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80108d:	83 ec 0c             	sub    $0xc,%esp
  801090:	50                   	push   %eax
  801091:	6a 05                	push   $0x5
  801093:	68 1f 2f 80 00       	push   $0x802f1f
  801098:	6a 23                	push   $0x23
  80109a:	68 3c 2f 80 00       	push   $0x802f3c
  80109f:	e8 56 f4 ff ff       	call   8004fa <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8010a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010a7:	5b                   	pop    %ebx
  8010a8:	5e                   	pop    %esi
  8010a9:	5f                   	pop    %edi
  8010aa:	5d                   	pop    %ebp
  8010ab:	c3                   	ret    

008010ac <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8010ac:	55                   	push   %ebp
  8010ad:	89 e5                	mov    %esp,%ebp
  8010af:	57                   	push   %edi
  8010b0:	56                   	push   %esi
  8010b1:	53                   	push   %ebx
  8010b2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010b5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010ba:	b8 06 00 00 00       	mov    $0x6,%eax
  8010bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8010c5:	89 df                	mov    %ebx,%edi
  8010c7:	89 de                	mov    %ebx,%esi
  8010c9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010cb:	85 c0                	test   %eax,%eax
  8010cd:	7e 17                	jle    8010e6 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010cf:	83 ec 0c             	sub    $0xc,%esp
  8010d2:	50                   	push   %eax
  8010d3:	6a 06                	push   $0x6
  8010d5:	68 1f 2f 80 00       	push   $0x802f1f
  8010da:	6a 23                	push   $0x23
  8010dc:	68 3c 2f 80 00       	push   $0x802f3c
  8010e1:	e8 14 f4 ff ff       	call   8004fa <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8010e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010e9:	5b                   	pop    %ebx
  8010ea:	5e                   	pop    %esi
  8010eb:	5f                   	pop    %edi
  8010ec:	5d                   	pop    %ebp
  8010ed:	c3                   	ret    

008010ee <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8010ee:	55                   	push   %ebp
  8010ef:	89 e5                	mov    %esp,%ebp
  8010f1:	57                   	push   %edi
  8010f2:	56                   	push   %esi
  8010f3:	53                   	push   %ebx
  8010f4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010f7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010fc:	b8 08 00 00 00       	mov    $0x8,%eax
  801101:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801104:	8b 55 08             	mov    0x8(%ebp),%edx
  801107:	89 df                	mov    %ebx,%edi
  801109:	89 de                	mov    %ebx,%esi
  80110b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80110d:	85 c0                	test   %eax,%eax
  80110f:	7e 17                	jle    801128 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801111:	83 ec 0c             	sub    $0xc,%esp
  801114:	50                   	push   %eax
  801115:	6a 08                	push   $0x8
  801117:	68 1f 2f 80 00       	push   $0x802f1f
  80111c:	6a 23                	push   $0x23
  80111e:	68 3c 2f 80 00       	push   $0x802f3c
  801123:	e8 d2 f3 ff ff       	call   8004fa <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801128:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80112b:	5b                   	pop    %ebx
  80112c:	5e                   	pop    %esi
  80112d:	5f                   	pop    %edi
  80112e:	5d                   	pop    %ebp
  80112f:	c3                   	ret    

00801130 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801130:	55                   	push   %ebp
  801131:	89 e5                	mov    %esp,%ebp
  801133:	57                   	push   %edi
  801134:	56                   	push   %esi
  801135:	53                   	push   %ebx
  801136:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801139:	bb 00 00 00 00       	mov    $0x0,%ebx
  80113e:	b8 09 00 00 00       	mov    $0x9,%eax
  801143:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801146:	8b 55 08             	mov    0x8(%ebp),%edx
  801149:	89 df                	mov    %ebx,%edi
  80114b:	89 de                	mov    %ebx,%esi
  80114d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80114f:	85 c0                	test   %eax,%eax
  801151:	7e 17                	jle    80116a <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801153:	83 ec 0c             	sub    $0xc,%esp
  801156:	50                   	push   %eax
  801157:	6a 09                	push   $0x9
  801159:	68 1f 2f 80 00       	push   $0x802f1f
  80115e:	6a 23                	push   $0x23
  801160:	68 3c 2f 80 00       	push   $0x802f3c
  801165:	e8 90 f3 ff ff       	call   8004fa <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80116a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80116d:	5b                   	pop    %ebx
  80116e:	5e                   	pop    %esi
  80116f:	5f                   	pop    %edi
  801170:	5d                   	pop    %ebp
  801171:	c3                   	ret    

00801172 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801172:	55                   	push   %ebp
  801173:	89 e5                	mov    %esp,%ebp
  801175:	57                   	push   %edi
  801176:	56                   	push   %esi
  801177:	53                   	push   %ebx
  801178:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80117b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801180:	b8 0a 00 00 00       	mov    $0xa,%eax
  801185:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801188:	8b 55 08             	mov    0x8(%ebp),%edx
  80118b:	89 df                	mov    %ebx,%edi
  80118d:	89 de                	mov    %ebx,%esi
  80118f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801191:	85 c0                	test   %eax,%eax
  801193:	7e 17                	jle    8011ac <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801195:	83 ec 0c             	sub    $0xc,%esp
  801198:	50                   	push   %eax
  801199:	6a 0a                	push   $0xa
  80119b:	68 1f 2f 80 00       	push   $0x802f1f
  8011a0:	6a 23                	push   $0x23
  8011a2:	68 3c 2f 80 00       	push   $0x802f3c
  8011a7:	e8 4e f3 ff ff       	call   8004fa <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8011ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011af:	5b                   	pop    %ebx
  8011b0:	5e                   	pop    %esi
  8011b1:	5f                   	pop    %edi
  8011b2:	5d                   	pop    %ebp
  8011b3:	c3                   	ret    

008011b4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8011b4:	55                   	push   %ebp
  8011b5:	89 e5                	mov    %esp,%ebp
  8011b7:	57                   	push   %edi
  8011b8:	56                   	push   %esi
  8011b9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011ba:	be 00 00 00 00       	mov    $0x0,%esi
  8011bf:	b8 0c 00 00 00       	mov    $0xc,%eax
  8011c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8011ca:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011cd:	8b 7d 14             	mov    0x14(%ebp),%edi
  8011d0:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8011d2:	5b                   	pop    %ebx
  8011d3:	5e                   	pop    %esi
  8011d4:	5f                   	pop    %edi
  8011d5:	5d                   	pop    %ebp
  8011d6:	c3                   	ret    

008011d7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8011d7:	55                   	push   %ebp
  8011d8:	89 e5                	mov    %esp,%ebp
  8011da:	57                   	push   %edi
  8011db:	56                   	push   %esi
  8011dc:	53                   	push   %ebx
  8011dd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011e0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011e5:	b8 0d 00 00 00       	mov    $0xd,%eax
  8011ea:	8b 55 08             	mov    0x8(%ebp),%edx
  8011ed:	89 cb                	mov    %ecx,%ebx
  8011ef:	89 cf                	mov    %ecx,%edi
  8011f1:	89 ce                	mov    %ecx,%esi
  8011f3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011f5:	85 c0                	test   %eax,%eax
  8011f7:	7e 17                	jle    801210 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011f9:	83 ec 0c             	sub    $0xc,%esp
  8011fc:	50                   	push   %eax
  8011fd:	6a 0d                	push   $0xd
  8011ff:	68 1f 2f 80 00       	push   $0x802f1f
  801204:	6a 23                	push   $0x23
  801206:	68 3c 2f 80 00       	push   $0x802f3c
  80120b:	e8 ea f2 ff ff       	call   8004fa <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801210:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801213:	5b                   	pop    %ebx
  801214:	5e                   	pop    %esi
  801215:	5f                   	pop    %edi
  801216:	5d                   	pop    %ebp
  801217:	c3                   	ret    

00801218 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801218:	55                   	push   %ebp
  801219:	89 e5                	mov    %esp,%ebp
  80121b:	56                   	push   %esi
  80121c:	53                   	push   %ebx
  80121d:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801220:	8b 18                	mov    (%eax),%ebx
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).
	
	if((err & FEC_WR) == 0){
  801222:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801226:	75 14                	jne    80123c <pgfault+0x24>
		panic("pgfault not cause by write \n");
  801228:	83 ec 04             	sub    $0x4,%esp
  80122b:	68 4a 2f 80 00       	push   $0x802f4a
  801230:	6a 1c                	push   $0x1c
  801232:	68 67 2f 80 00       	push   $0x802f67
  801237:	e8 be f2 ff ff       	call   8004fa <_panic>
	}
 
	if ((uvpt[PGNUM(addr)] & PTE_COW) == 0) 
  80123c:	89 d8                	mov    %ebx,%eax
  80123e:	c1 e8 0c             	shr    $0xc,%eax
  801241:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801248:	f6 c4 08             	test   $0x8,%ah
  80124b:	75 14                	jne    801261 <pgfault+0x49>
    {
        panic("pgfault not cause by COW \n");
  80124d:	83 ec 04             	sub    $0x4,%esp
  801250:	68 72 2f 80 00       	push   $0x802f72
  801255:	6a 21                	push   $0x21
  801257:	68 67 2f 80 00       	push   $0x802f67
  80125c:	e8 99 f2 ff ff       	call   8004fa <_panic>
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.
	envid_t eid = sys_getenvid();
  801261:	e8 83 fd ff ff       	call   800fe9 <sys_getenvid>
  801266:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(eid,(void*)PFTEMP,PTE_P|PTE_W|PTE_U)) < 0)
  801268:	83 ec 04             	sub    $0x4,%esp
  80126b:	6a 07                	push   $0x7
  80126d:	68 00 f0 7f 00       	push   $0x7ff000
  801272:	50                   	push   %eax
  801273:	e8 af fd ff ff       	call   801027 <sys_page_alloc>
  801278:	83 c4 10             	add    $0x10,%esp
  80127b:	85 c0                	test   %eax,%eax
  80127d:	79 14                	jns    801293 <pgfault+0x7b>
		panic("page alloction failed.\n");
  80127f:	83 ec 04             	sub    $0x4,%esp
  801282:	68 8d 2f 80 00       	push   $0x802f8d
  801287:	6a 2d                	push   $0x2d
  801289:	68 67 2f 80 00       	push   $0x802f67
  80128e:	e8 67 f2 ff ff       	call   8004fa <_panic>
	addr = ROUNDDOWN(addr,PGSIZE);
  801293:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP,addr,PGSIZE);
  801299:	83 ec 04             	sub    $0x4,%esp
  80129c:	68 00 10 00 00       	push   $0x1000
  8012a1:	53                   	push   %ebx
  8012a2:	68 00 f0 7f 00       	push   $0x7ff000
  8012a7:	e8 d8 fa ff ff       	call   800d84 <memmove>
	if ((r = sys_page_map(eid, PFTEMP, eid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  8012ac:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  8012b3:	53                   	push   %ebx
  8012b4:	56                   	push   %esi
  8012b5:	68 00 f0 7f 00       	push   $0x7ff000
  8012ba:	56                   	push   %esi
  8012bb:	e8 aa fd ff ff       	call   80106a <sys_page_map>
  8012c0:	83 c4 20             	add    $0x20,%esp
  8012c3:	85 c0                	test   %eax,%eax
  8012c5:	79 12                	jns    8012d9 <pgfault+0xc1>
        panic("pgfault: page map failed %e\n", r);
  8012c7:	50                   	push   %eax
  8012c8:	68 a5 2f 80 00       	push   $0x802fa5
  8012cd:	6a 31                	push   $0x31
  8012cf:	68 67 2f 80 00       	push   $0x802f67
  8012d4:	e8 21 f2 ff ff       	call   8004fa <_panic>
	if ((r = sys_page_unmap(eid, PFTEMP)) < 0)
  8012d9:	83 ec 08             	sub    $0x8,%esp
  8012dc:	68 00 f0 7f 00       	push   $0x7ff000
  8012e1:	56                   	push   %esi
  8012e2:	e8 c5 fd ff ff       	call   8010ac <sys_page_unmap>
  8012e7:	83 c4 10             	add    $0x10,%esp
  8012ea:	85 c0                	test   %eax,%eax
  8012ec:	79 12                	jns    801300 <pgfault+0xe8>
        panic("pgfault: page unmap failed %e\n", r);
  8012ee:	50                   	push   %eax
  8012ef:	68 14 30 80 00       	push   $0x803014
  8012f4:	6a 33                	push   $0x33
  8012f6:	68 67 2f 80 00       	push   $0x802f67
  8012fb:	e8 fa f1 ff ff       	call   8004fa <_panic>
	// LAB 4: Your code here.

	// panic("pgfault not implemented");
}
  801300:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801303:	5b                   	pop    %ebx
  801304:	5e                   	pop    %esi
  801305:	5d                   	pop    %ebp
  801306:	c3                   	ret    

00801307 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801307:	55                   	push   %ebp
  801308:	89 e5                	mov    %esp,%ebp
  80130a:	57                   	push   %edi
  80130b:	56                   	push   %esi
  80130c:	53                   	push   %ebx
  80130d:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	struct PageInfo* pg = NULL;
	set_pgfault_handler(pgfault);
  801310:	68 18 12 80 00       	push   $0x801218
  801315:	e8 f3 12 00 00       	call   80260d <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80131a:	b8 07 00 00 00       	mov    $0x7,%eax
  80131f:	cd 30                	int    $0x30
  801321:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801324:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t eid = sys_exofork();
	if (eid < 0) panic("fork fault.\n");
  801327:	83 c4 10             	add    $0x10,%esp
  80132a:	85 c0                	test   %eax,%eax
  80132c:	79 14                	jns    801342 <fork+0x3b>
  80132e:	83 ec 04             	sub    $0x4,%esp
  801331:	68 c2 2f 80 00       	push   $0x802fc2
  801336:	6a 71                	push   $0x71
  801338:	68 67 2f 80 00       	push   $0x802f67
  80133d:	e8 b8 f1 ff ff       	call   8004fa <_panic>
	if (eid == 0){
  801342:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801346:	75 25                	jne    80136d <fork+0x66>
		thisenv = &envs[ENVX(sys_getenvid())];
  801348:	e8 9c fc ff ff       	call   800fe9 <sys_getenvid>
  80134d:	25 ff 03 00 00       	and    $0x3ff,%eax
  801352:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801359:	c1 e0 07             	shl    $0x7,%eax
  80135c:	29 d0                	sub    %edx,%eax
  80135e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801363:	a3 04 50 80 00       	mov    %eax,0x805004
		return eid;
  801368:	e9 61 01 00 00       	jmp    8014ce <fork+0x1c7>
  80136d:	bb 00 00 80 00       	mov    $0x800000,%ebx
	}
	// copy something to the child page.
	for (uintptr_t i = UTEXT;i <= USTACKTOP;i += PGSIZE){
		if (uvpd[PDX(i)] & PTE_P && (uvpt[PGNUM(i)] & PTE_P)){
  801372:	89 d8                	mov    %ebx,%eax
  801374:	c1 e8 16             	shr    $0x16,%eax
  801377:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80137e:	a8 01                	test   $0x1,%al
  801380:	74 52                	je     8013d4 <fork+0xcd>
  801382:	89 de                	mov    %ebx,%esi
  801384:	c1 ee 0c             	shr    $0xc,%esi
  801387:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80138e:	a8 01                	test   $0x1,%al
  801390:	74 42                	je     8013d4 <fork+0xcd>
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.
	envid_t myenvid = sys_getenvid();
  801392:	e8 52 fc ff ff       	call   800fe9 <sys_getenvid>
  801397:	89 c7                	mov    %eax,%edi
	pte_t pte = uvpt[pn];
  801399:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	int perm = PTE_U | PTE_P;
	if(pte & PTE_W || pte & PTE_COW)
  8013a0:	a9 02 08 00 00       	test   $0x802,%eax
  8013a5:	0f 85 de 00 00 00    	jne    801489 <fork+0x182>
  8013ab:	e9 fb 00 00 00       	jmp    8014ab <fork+0x1a4>
		perm |= PTE_COW;
	if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),envid,(void*)(pn*PGSIZE),perm))<0){
		panic("duppage fault :%e\n",r);
  8013b0:	50                   	push   %eax
  8013b1:	68 cf 2f 80 00       	push   $0x802fcf
  8013b6:	6a 50                	push   $0x50
  8013b8:	68 67 2f 80 00       	push   $0x802f67
  8013bd:	e8 38 f1 ff ff       	call   8004fa <_panic>
	}
	if(perm & PTE_COW){
		if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),myenvid,(void*)(pn*PGSIZE),perm))<0)
			panic("duppage fault :%e\n",r);
  8013c2:	50                   	push   %eax
  8013c3:	68 cf 2f 80 00       	push   $0x802fcf
  8013c8:	6a 54                	push   $0x54
  8013ca:	68 67 2f 80 00       	push   $0x802f67
  8013cf:	e8 26 f1 ff ff       	call   8004fa <_panic>
	if (eid == 0){
		thisenv = &envs[ENVX(sys_getenvid())];
		return eid;
	}
	// copy something to the child page.
	for (uintptr_t i = UTEXT;i <= USTACKTOP;i += PGSIZE){
  8013d4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8013da:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  8013e0:	75 90                	jne    801372 <fork+0x6b>
		if (uvpd[PDX(i)] & PTE_P && (uvpt[PGNUM(i)] & PTE_P)){
			duppage(eid,PGNUM(i));
		}
	}
	int r = sys_page_alloc(eid,(void*)(UXSTACKTOP-PGSIZE),PTE_U|PTE_P|PTE_W);
  8013e2:	83 ec 04             	sub    $0x4,%esp
  8013e5:	6a 07                	push   $0x7
  8013e7:	68 00 f0 bf ee       	push   $0xeebff000
  8013ec:	ff 75 e0             	pushl  -0x20(%ebp)
  8013ef:	e8 33 fc ff ff       	call   801027 <sys_page_alloc>
	if (r < 0) panic("fork fault.\n");
  8013f4:	83 c4 10             	add    $0x10,%esp
  8013f7:	85 c0                	test   %eax,%eax
  8013f9:	79 14                	jns    80140f <fork+0x108>
  8013fb:	83 ec 04             	sub    $0x4,%esp
  8013fe:	68 c2 2f 80 00       	push   $0x802fc2
  801403:	6a 7d                	push   $0x7d
  801405:	68 67 2f 80 00       	push   $0x802f67
  80140a:	e8 eb f0 ff ff       	call   8004fa <_panic>

	extern void _pgfault_upcall();
    r = sys_env_set_pgfault_upcall(eid, _pgfault_upcall);
  80140f:	83 ec 08             	sub    $0x8,%esp
  801412:	68 85 26 80 00       	push   $0x802685
  801417:	ff 75 e0             	pushl  -0x20(%ebp)
  80141a:	e8 53 fd ff ff       	call   801172 <sys_env_set_pgfault_upcall>
    if (r < 0) panic("fork fault 3\n");
  80141f:	83 c4 10             	add    $0x10,%esp
  801422:	85 c0                	test   %eax,%eax
  801424:	79 17                	jns    80143d <fork+0x136>
  801426:	83 ec 04             	sub    $0x4,%esp
  801429:	68 e2 2f 80 00       	push   $0x802fe2
  80142e:	68 81 00 00 00       	push   $0x81
  801433:	68 67 2f 80 00       	push   $0x802f67
  801438:	e8 bd f0 ff ff       	call   8004fa <_panic>

	if ((r = sys_env_set_status(eid, ENV_RUNNABLE)) < 0)
  80143d:	83 ec 08             	sub    $0x8,%esp
  801440:	6a 02                	push   $0x2
  801442:	ff 75 e0             	pushl  -0x20(%ebp)
  801445:	e8 a4 fc ff ff       	call   8010ee <sys_env_set_status>
  80144a:	83 c4 10             	add    $0x10,%esp
  80144d:	85 c0                	test   %eax,%eax
  80144f:	79 7d                	jns    8014ce <fork+0x1c7>
        panic("fork fault 4\n");
  801451:	83 ec 04             	sub    $0x4,%esp
  801454:	68 f0 2f 80 00       	push   $0x802ff0
  801459:	68 84 00 00 00       	push   $0x84
  80145e:	68 67 2f 80 00       	push   $0x802f67
  801463:	e8 92 f0 ff ff       	call   8004fa <_panic>
		perm |= PTE_COW;
	if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),envid,(void*)(pn*PGSIZE),perm))<0){
		panic("duppage fault :%e\n",r);
	}
	if(perm & PTE_COW){
		if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),myenvid,(void*)(pn*PGSIZE),perm))<0)
  801468:	83 ec 0c             	sub    $0xc,%esp
  80146b:	68 05 08 00 00       	push   $0x805
  801470:	56                   	push   %esi
  801471:	57                   	push   %edi
  801472:	56                   	push   %esi
  801473:	57                   	push   %edi
  801474:	e8 f1 fb ff ff       	call   80106a <sys_page_map>
  801479:	83 c4 20             	add    $0x20,%esp
  80147c:	85 c0                	test   %eax,%eax
  80147e:	0f 89 50 ff ff ff    	jns    8013d4 <fork+0xcd>
  801484:	e9 39 ff ff ff       	jmp    8013c2 <fork+0xbb>
	envid_t myenvid = sys_getenvid();
	pte_t pte = uvpt[pn];
	int perm = PTE_U | PTE_P;
	if(pte & PTE_W || pte & PTE_COW)
		perm |= PTE_COW;
	if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),envid,(void*)(pn*PGSIZE),perm))<0){
  801489:	c1 e6 0c             	shl    $0xc,%esi
  80148c:	83 ec 0c             	sub    $0xc,%esp
  80148f:	68 05 08 00 00       	push   $0x805
  801494:	56                   	push   %esi
  801495:	ff 75 e4             	pushl  -0x1c(%ebp)
  801498:	56                   	push   %esi
  801499:	57                   	push   %edi
  80149a:	e8 cb fb ff ff       	call   80106a <sys_page_map>
  80149f:	83 c4 20             	add    $0x20,%esp
  8014a2:	85 c0                	test   %eax,%eax
  8014a4:	79 c2                	jns    801468 <fork+0x161>
  8014a6:	e9 05 ff ff ff       	jmp    8013b0 <fork+0xa9>
  8014ab:	c1 e6 0c             	shl    $0xc,%esi
  8014ae:	83 ec 0c             	sub    $0xc,%esp
  8014b1:	6a 05                	push   $0x5
  8014b3:	56                   	push   %esi
  8014b4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014b7:	56                   	push   %esi
  8014b8:	57                   	push   %edi
  8014b9:	e8 ac fb ff ff       	call   80106a <sys_page_map>
  8014be:	83 c4 20             	add    $0x20,%esp
  8014c1:	85 c0                	test   %eax,%eax
  8014c3:	0f 89 0b ff ff ff    	jns    8013d4 <fork+0xcd>
  8014c9:	e9 e2 fe ff ff       	jmp    8013b0 <fork+0xa9>
    if (r < 0) panic("fork fault 3\n");

	if ((r = sys_env_set_status(eid, ENV_RUNNABLE)) < 0)
        panic("fork fault 4\n");
    return eid;
}
  8014ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8014d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014d4:	5b                   	pop    %ebx
  8014d5:	5e                   	pop    %esi
  8014d6:	5f                   	pop    %edi
  8014d7:	5d                   	pop    %ebp
  8014d8:	c3                   	ret    

008014d9 <sfork>:

// Challenge!
int
sfork(void)
{
  8014d9:	55                   	push   %ebp
  8014da:	89 e5                	mov    %esp,%ebp
  8014dc:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8014df:	68 fe 2f 80 00       	push   $0x802ffe
  8014e4:	68 8c 00 00 00       	push   $0x8c
  8014e9:	68 67 2f 80 00       	push   $0x802f67
  8014ee:	e8 07 f0 ff ff       	call   8004fa <_panic>

008014f3 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8014f3:	55                   	push   %ebp
  8014f4:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8014f9:	05 00 00 00 30       	add    $0x30000000,%eax
  8014fe:	c1 e8 0c             	shr    $0xc,%eax
}
  801501:	5d                   	pop    %ebp
  801502:	c3                   	ret    

00801503 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801503:	55                   	push   %ebp
  801504:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801506:	8b 45 08             	mov    0x8(%ebp),%eax
  801509:	05 00 00 00 30       	add    $0x30000000,%eax
  80150e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801513:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801518:	5d                   	pop    %ebp
  801519:	c3                   	ret    

0080151a <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80151a:	55                   	push   %ebp
  80151b:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80151d:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801522:	a8 01                	test   $0x1,%al
  801524:	74 34                	je     80155a <fd_alloc+0x40>
  801526:	a1 00 00 74 ef       	mov    0xef740000,%eax
  80152b:	a8 01                	test   $0x1,%al
  80152d:	74 32                	je     801561 <fd_alloc+0x47>
  80152f:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801534:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801536:	89 c2                	mov    %eax,%edx
  801538:	c1 ea 16             	shr    $0x16,%edx
  80153b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801542:	f6 c2 01             	test   $0x1,%dl
  801545:	74 1f                	je     801566 <fd_alloc+0x4c>
  801547:	89 c2                	mov    %eax,%edx
  801549:	c1 ea 0c             	shr    $0xc,%edx
  80154c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801553:	f6 c2 01             	test   $0x1,%dl
  801556:	75 1a                	jne    801572 <fd_alloc+0x58>
  801558:	eb 0c                	jmp    801566 <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80155a:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  80155f:	eb 05                	jmp    801566 <fd_alloc+0x4c>
  801561:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  801566:	8b 45 08             	mov    0x8(%ebp),%eax
  801569:	89 08                	mov    %ecx,(%eax)
			return 0;
  80156b:	b8 00 00 00 00       	mov    $0x0,%eax
  801570:	eb 1a                	jmp    80158c <fd_alloc+0x72>
  801572:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801577:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80157c:	75 b6                	jne    801534 <fd_alloc+0x1a>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80157e:	8b 45 08             	mov    0x8(%ebp),%eax
  801581:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  801587:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80158c:	5d                   	pop    %ebp
  80158d:	c3                   	ret    

0080158e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80158e:	55                   	push   %ebp
  80158f:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801591:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  801595:	77 39                	ja     8015d0 <fd_lookup+0x42>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801597:	8b 45 08             	mov    0x8(%ebp),%eax
  80159a:	c1 e0 0c             	shl    $0xc,%eax
  80159d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8015a2:	89 c2                	mov    %eax,%edx
  8015a4:	c1 ea 16             	shr    $0x16,%edx
  8015a7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8015ae:	f6 c2 01             	test   $0x1,%dl
  8015b1:	74 24                	je     8015d7 <fd_lookup+0x49>
  8015b3:	89 c2                	mov    %eax,%edx
  8015b5:	c1 ea 0c             	shr    $0xc,%edx
  8015b8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8015bf:	f6 c2 01             	test   $0x1,%dl
  8015c2:	74 1a                	je     8015de <fd_lookup+0x50>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8015c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015c7:	89 02                	mov    %eax,(%edx)
	return 0;
  8015c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8015ce:	eb 13                	jmp    8015e3 <fd_lookup+0x55>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8015d0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015d5:	eb 0c                	jmp    8015e3 <fd_lookup+0x55>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8015d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015dc:	eb 05                	jmp    8015e3 <fd_lookup+0x55>
  8015de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8015e3:	5d                   	pop    %ebp
  8015e4:	c3                   	ret    

008015e5 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8015e5:	55                   	push   %ebp
  8015e6:	89 e5                	mov    %esp,%ebp
  8015e8:	53                   	push   %ebx
  8015e9:	83 ec 04             	sub    $0x4,%esp
  8015ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8015f2:	3b 05 20 40 80 00    	cmp    0x804020,%eax
  8015f8:	75 1e                	jne    801618 <dev_lookup+0x33>
  8015fa:	eb 0e                	jmp    80160a <dev_lookup+0x25>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8015fc:	b8 3c 40 80 00       	mov    $0x80403c,%eax
  801601:	eb 0c                	jmp    80160f <dev_lookup+0x2a>
  801603:	b8 00 40 80 00       	mov    $0x804000,%eax
  801608:	eb 05                	jmp    80160f <dev_lookup+0x2a>
  80160a:	b8 20 40 80 00       	mov    $0x804020,%eax
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  80160f:	89 03                	mov    %eax,(%ebx)
			return 0;
  801611:	b8 00 00 00 00       	mov    $0x0,%eax
  801616:	eb 36                	jmp    80164e <dev_lookup+0x69>
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801618:	3b 05 3c 40 80 00    	cmp    0x80403c,%eax
  80161e:	74 dc                	je     8015fc <dev_lookup+0x17>
  801620:	3b 05 00 40 80 00    	cmp    0x804000,%eax
  801626:	74 db                	je     801603 <dev_lookup+0x1e>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801628:	8b 15 04 50 80 00    	mov    0x805004,%edx
  80162e:	8b 52 48             	mov    0x48(%edx),%edx
  801631:	83 ec 04             	sub    $0x4,%esp
  801634:	50                   	push   %eax
  801635:	52                   	push   %edx
  801636:	68 34 30 80 00       	push   $0x803034
  80163b:	e8 92 ef ff ff       	call   8005d2 <cprintf>
	*dev = 0;
  801640:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801646:	83 c4 10             	add    $0x10,%esp
  801649:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80164e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801651:	c9                   	leave  
  801652:	c3                   	ret    

00801653 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801653:	55                   	push   %ebp
  801654:	89 e5                	mov    %esp,%ebp
  801656:	56                   	push   %esi
  801657:	53                   	push   %ebx
  801658:	83 ec 10             	sub    $0x10,%esp
  80165b:	8b 75 08             	mov    0x8(%ebp),%esi
  80165e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801661:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801664:	50                   	push   %eax
  801665:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80166b:	c1 e8 0c             	shr    $0xc,%eax
  80166e:	50                   	push   %eax
  80166f:	e8 1a ff ff ff       	call   80158e <fd_lookup>
  801674:	83 c4 08             	add    $0x8,%esp
  801677:	85 c0                	test   %eax,%eax
  801679:	78 05                	js     801680 <fd_close+0x2d>
	    || fd != fd2)
  80167b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80167e:	74 06                	je     801686 <fd_close+0x33>
		return (must_exist ? r : 0);
  801680:	84 db                	test   %bl,%bl
  801682:	74 47                	je     8016cb <fd_close+0x78>
  801684:	eb 4a                	jmp    8016d0 <fd_close+0x7d>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801686:	83 ec 08             	sub    $0x8,%esp
  801689:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80168c:	50                   	push   %eax
  80168d:	ff 36                	pushl  (%esi)
  80168f:	e8 51 ff ff ff       	call   8015e5 <dev_lookup>
  801694:	89 c3                	mov    %eax,%ebx
  801696:	83 c4 10             	add    $0x10,%esp
  801699:	85 c0                	test   %eax,%eax
  80169b:	78 1c                	js     8016b9 <fd_close+0x66>
		if (dev->dev_close)
  80169d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016a0:	8b 40 10             	mov    0x10(%eax),%eax
  8016a3:	85 c0                	test   %eax,%eax
  8016a5:	74 0d                	je     8016b4 <fd_close+0x61>
			r = (*dev->dev_close)(fd);
  8016a7:	83 ec 0c             	sub    $0xc,%esp
  8016aa:	56                   	push   %esi
  8016ab:	ff d0                	call   *%eax
  8016ad:	89 c3                	mov    %eax,%ebx
  8016af:	83 c4 10             	add    $0x10,%esp
  8016b2:	eb 05                	jmp    8016b9 <fd_close+0x66>
		else
			r = 0;
  8016b4:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8016b9:	83 ec 08             	sub    $0x8,%esp
  8016bc:	56                   	push   %esi
  8016bd:	6a 00                	push   $0x0
  8016bf:	e8 e8 f9 ff ff       	call   8010ac <sys_page_unmap>
	return r;
  8016c4:	83 c4 10             	add    $0x10,%esp
  8016c7:	89 d8                	mov    %ebx,%eax
  8016c9:	eb 05                	jmp    8016d0 <fd_close+0x7d>
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
  8016cb:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
	return r;
}
  8016d0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016d3:	5b                   	pop    %ebx
  8016d4:	5e                   	pop    %esi
  8016d5:	5d                   	pop    %ebp
  8016d6:	c3                   	ret    

008016d7 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8016d7:	55                   	push   %ebp
  8016d8:	89 e5                	mov    %esp,%ebp
  8016da:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016e0:	50                   	push   %eax
  8016e1:	ff 75 08             	pushl  0x8(%ebp)
  8016e4:	e8 a5 fe ff ff       	call   80158e <fd_lookup>
  8016e9:	83 c4 08             	add    $0x8,%esp
  8016ec:	85 c0                	test   %eax,%eax
  8016ee:	78 10                	js     801700 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8016f0:	83 ec 08             	sub    $0x8,%esp
  8016f3:	6a 01                	push   $0x1
  8016f5:	ff 75 f4             	pushl  -0xc(%ebp)
  8016f8:	e8 56 ff ff ff       	call   801653 <fd_close>
  8016fd:	83 c4 10             	add    $0x10,%esp
}
  801700:	c9                   	leave  
  801701:	c3                   	ret    

00801702 <close_all>:

void
close_all(void)
{
  801702:	55                   	push   %ebp
  801703:	89 e5                	mov    %esp,%ebp
  801705:	53                   	push   %ebx
  801706:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801709:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80170e:	83 ec 0c             	sub    $0xc,%esp
  801711:	53                   	push   %ebx
  801712:	e8 c0 ff ff ff       	call   8016d7 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801717:	43                   	inc    %ebx
  801718:	83 c4 10             	add    $0x10,%esp
  80171b:	83 fb 20             	cmp    $0x20,%ebx
  80171e:	75 ee                	jne    80170e <close_all+0xc>
		close(i);
}
  801720:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801723:	c9                   	leave  
  801724:	c3                   	ret    

00801725 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801725:	55                   	push   %ebp
  801726:	89 e5                	mov    %esp,%ebp
  801728:	57                   	push   %edi
  801729:	56                   	push   %esi
  80172a:	53                   	push   %ebx
  80172b:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80172e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801731:	50                   	push   %eax
  801732:	ff 75 08             	pushl  0x8(%ebp)
  801735:	e8 54 fe ff ff       	call   80158e <fd_lookup>
  80173a:	83 c4 08             	add    $0x8,%esp
  80173d:	85 c0                	test   %eax,%eax
  80173f:	0f 88 c2 00 00 00    	js     801807 <dup+0xe2>
		return r;
	close(newfdnum);
  801745:	83 ec 0c             	sub    $0xc,%esp
  801748:	ff 75 0c             	pushl  0xc(%ebp)
  80174b:	e8 87 ff ff ff       	call   8016d7 <close>

	newfd = INDEX2FD(newfdnum);
  801750:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801753:	c1 e3 0c             	shl    $0xc,%ebx
  801756:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80175c:	83 c4 04             	add    $0x4,%esp
  80175f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801762:	e8 9c fd ff ff       	call   801503 <fd2data>
  801767:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801769:	89 1c 24             	mov    %ebx,(%esp)
  80176c:	e8 92 fd ff ff       	call   801503 <fd2data>
  801771:	83 c4 10             	add    $0x10,%esp
  801774:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801776:	89 f0                	mov    %esi,%eax
  801778:	c1 e8 16             	shr    $0x16,%eax
  80177b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801782:	a8 01                	test   $0x1,%al
  801784:	74 35                	je     8017bb <dup+0x96>
  801786:	89 f0                	mov    %esi,%eax
  801788:	c1 e8 0c             	shr    $0xc,%eax
  80178b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801792:	f6 c2 01             	test   $0x1,%dl
  801795:	74 24                	je     8017bb <dup+0x96>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801797:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80179e:	83 ec 0c             	sub    $0xc,%esp
  8017a1:	25 07 0e 00 00       	and    $0xe07,%eax
  8017a6:	50                   	push   %eax
  8017a7:	57                   	push   %edi
  8017a8:	6a 00                	push   $0x0
  8017aa:	56                   	push   %esi
  8017ab:	6a 00                	push   $0x0
  8017ad:	e8 b8 f8 ff ff       	call   80106a <sys_page_map>
  8017b2:	89 c6                	mov    %eax,%esi
  8017b4:	83 c4 20             	add    $0x20,%esp
  8017b7:	85 c0                	test   %eax,%eax
  8017b9:	78 2c                	js     8017e7 <dup+0xc2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8017bb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8017be:	89 d0                	mov    %edx,%eax
  8017c0:	c1 e8 0c             	shr    $0xc,%eax
  8017c3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8017ca:	83 ec 0c             	sub    $0xc,%esp
  8017cd:	25 07 0e 00 00       	and    $0xe07,%eax
  8017d2:	50                   	push   %eax
  8017d3:	53                   	push   %ebx
  8017d4:	6a 00                	push   $0x0
  8017d6:	52                   	push   %edx
  8017d7:	6a 00                	push   $0x0
  8017d9:	e8 8c f8 ff ff       	call   80106a <sys_page_map>
  8017de:	89 c6                	mov    %eax,%esi
  8017e0:	83 c4 20             	add    $0x20,%esp
  8017e3:	85 c0                	test   %eax,%eax
  8017e5:	79 1d                	jns    801804 <dup+0xdf>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8017e7:	83 ec 08             	sub    $0x8,%esp
  8017ea:	53                   	push   %ebx
  8017eb:	6a 00                	push   $0x0
  8017ed:	e8 ba f8 ff ff       	call   8010ac <sys_page_unmap>
	sys_page_unmap(0, nva);
  8017f2:	83 c4 08             	add    $0x8,%esp
  8017f5:	57                   	push   %edi
  8017f6:	6a 00                	push   $0x0
  8017f8:	e8 af f8 ff ff       	call   8010ac <sys_page_unmap>
	return r;
  8017fd:	83 c4 10             	add    $0x10,%esp
  801800:	89 f0                	mov    %esi,%eax
  801802:	eb 03                	jmp    801807 <dup+0xe2>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801804:	8b 45 0c             	mov    0xc(%ebp),%eax

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801807:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80180a:	5b                   	pop    %ebx
  80180b:	5e                   	pop    %esi
  80180c:	5f                   	pop    %edi
  80180d:	5d                   	pop    %ebp
  80180e:	c3                   	ret    

0080180f <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80180f:	55                   	push   %ebp
  801810:	89 e5                	mov    %esp,%ebp
  801812:	53                   	push   %ebx
  801813:	83 ec 14             	sub    $0x14,%esp
  801816:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801819:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80181c:	50                   	push   %eax
  80181d:	53                   	push   %ebx
  80181e:	e8 6b fd ff ff       	call   80158e <fd_lookup>
  801823:	83 c4 08             	add    $0x8,%esp
  801826:	85 c0                	test   %eax,%eax
  801828:	78 67                	js     801891 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80182a:	83 ec 08             	sub    $0x8,%esp
  80182d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801830:	50                   	push   %eax
  801831:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801834:	ff 30                	pushl  (%eax)
  801836:	e8 aa fd ff ff       	call   8015e5 <dev_lookup>
  80183b:	83 c4 10             	add    $0x10,%esp
  80183e:	85 c0                	test   %eax,%eax
  801840:	78 4f                	js     801891 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801842:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801845:	8b 42 08             	mov    0x8(%edx),%eax
  801848:	83 e0 03             	and    $0x3,%eax
  80184b:	83 f8 01             	cmp    $0x1,%eax
  80184e:	75 21                	jne    801871 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801850:	a1 04 50 80 00       	mov    0x805004,%eax
  801855:	8b 40 48             	mov    0x48(%eax),%eax
  801858:	83 ec 04             	sub    $0x4,%esp
  80185b:	53                   	push   %ebx
  80185c:	50                   	push   %eax
  80185d:	68 75 30 80 00       	push   $0x803075
  801862:	e8 6b ed ff ff       	call   8005d2 <cprintf>
		return -E_INVAL;
  801867:	83 c4 10             	add    $0x10,%esp
  80186a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80186f:	eb 20                	jmp    801891 <read+0x82>
	}
	if (!dev->dev_read)
  801871:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801874:	8b 40 08             	mov    0x8(%eax),%eax
  801877:	85 c0                	test   %eax,%eax
  801879:	74 11                	je     80188c <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80187b:	83 ec 04             	sub    $0x4,%esp
  80187e:	ff 75 10             	pushl  0x10(%ebp)
  801881:	ff 75 0c             	pushl  0xc(%ebp)
  801884:	52                   	push   %edx
  801885:	ff d0                	call   *%eax
  801887:	83 c4 10             	add    $0x10,%esp
  80188a:	eb 05                	jmp    801891 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80188c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801891:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801894:	c9                   	leave  
  801895:	c3                   	ret    

00801896 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801896:	55                   	push   %ebp
  801897:	89 e5                	mov    %esp,%ebp
  801899:	57                   	push   %edi
  80189a:	56                   	push   %esi
  80189b:	53                   	push   %ebx
  80189c:	83 ec 0c             	sub    $0xc,%esp
  80189f:	8b 7d 08             	mov    0x8(%ebp),%edi
  8018a2:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8018a5:	85 f6                	test   %esi,%esi
  8018a7:	74 31                	je     8018da <readn+0x44>
  8018a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8018ae:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8018b3:	83 ec 04             	sub    $0x4,%esp
  8018b6:	89 f2                	mov    %esi,%edx
  8018b8:	29 c2                	sub    %eax,%edx
  8018ba:	52                   	push   %edx
  8018bb:	03 45 0c             	add    0xc(%ebp),%eax
  8018be:	50                   	push   %eax
  8018bf:	57                   	push   %edi
  8018c0:	e8 4a ff ff ff       	call   80180f <read>
		if (m < 0)
  8018c5:	83 c4 10             	add    $0x10,%esp
  8018c8:	85 c0                	test   %eax,%eax
  8018ca:	78 17                	js     8018e3 <readn+0x4d>
			return m;
		if (m == 0)
  8018cc:	85 c0                	test   %eax,%eax
  8018ce:	74 11                	je     8018e1 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8018d0:	01 c3                	add    %eax,%ebx
  8018d2:	89 d8                	mov    %ebx,%eax
  8018d4:	39 f3                	cmp    %esi,%ebx
  8018d6:	72 db                	jb     8018b3 <readn+0x1d>
  8018d8:	eb 09                	jmp    8018e3 <readn+0x4d>
  8018da:	b8 00 00 00 00       	mov    $0x0,%eax
  8018df:	eb 02                	jmp    8018e3 <readn+0x4d>
  8018e1:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8018e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018e6:	5b                   	pop    %ebx
  8018e7:	5e                   	pop    %esi
  8018e8:	5f                   	pop    %edi
  8018e9:	5d                   	pop    %ebp
  8018ea:	c3                   	ret    

008018eb <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8018eb:	55                   	push   %ebp
  8018ec:	89 e5                	mov    %esp,%ebp
  8018ee:	53                   	push   %ebx
  8018ef:	83 ec 14             	sub    $0x14,%esp
  8018f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018f5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018f8:	50                   	push   %eax
  8018f9:	53                   	push   %ebx
  8018fa:	e8 8f fc ff ff       	call   80158e <fd_lookup>
  8018ff:	83 c4 08             	add    $0x8,%esp
  801902:	85 c0                	test   %eax,%eax
  801904:	78 62                	js     801968 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801906:	83 ec 08             	sub    $0x8,%esp
  801909:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80190c:	50                   	push   %eax
  80190d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801910:	ff 30                	pushl  (%eax)
  801912:	e8 ce fc ff ff       	call   8015e5 <dev_lookup>
  801917:	83 c4 10             	add    $0x10,%esp
  80191a:	85 c0                	test   %eax,%eax
  80191c:	78 4a                	js     801968 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80191e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801921:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801925:	75 21                	jne    801948 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801927:	a1 04 50 80 00       	mov    0x805004,%eax
  80192c:	8b 40 48             	mov    0x48(%eax),%eax
  80192f:	83 ec 04             	sub    $0x4,%esp
  801932:	53                   	push   %ebx
  801933:	50                   	push   %eax
  801934:	68 91 30 80 00       	push   $0x803091
  801939:	e8 94 ec ff ff       	call   8005d2 <cprintf>
		return -E_INVAL;
  80193e:	83 c4 10             	add    $0x10,%esp
  801941:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801946:	eb 20                	jmp    801968 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801948:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80194b:	8b 52 0c             	mov    0xc(%edx),%edx
  80194e:	85 d2                	test   %edx,%edx
  801950:	74 11                	je     801963 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801952:	83 ec 04             	sub    $0x4,%esp
  801955:	ff 75 10             	pushl  0x10(%ebp)
  801958:	ff 75 0c             	pushl  0xc(%ebp)
  80195b:	50                   	push   %eax
  80195c:	ff d2                	call   *%edx
  80195e:	83 c4 10             	add    $0x10,%esp
  801961:	eb 05                	jmp    801968 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801963:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801968:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80196b:	c9                   	leave  
  80196c:	c3                   	ret    

0080196d <seek>:

int
seek(int fdnum, off_t offset)
{
  80196d:	55                   	push   %ebp
  80196e:	89 e5                	mov    %esp,%ebp
  801970:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801973:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801976:	50                   	push   %eax
  801977:	ff 75 08             	pushl  0x8(%ebp)
  80197a:	e8 0f fc ff ff       	call   80158e <fd_lookup>
  80197f:	83 c4 08             	add    $0x8,%esp
  801982:	85 c0                	test   %eax,%eax
  801984:	78 0e                	js     801994 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801986:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801989:	8b 55 0c             	mov    0xc(%ebp),%edx
  80198c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80198f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801994:	c9                   	leave  
  801995:	c3                   	ret    

00801996 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801996:	55                   	push   %ebp
  801997:	89 e5                	mov    %esp,%ebp
  801999:	53                   	push   %ebx
  80199a:	83 ec 14             	sub    $0x14,%esp
  80199d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019a0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019a3:	50                   	push   %eax
  8019a4:	53                   	push   %ebx
  8019a5:	e8 e4 fb ff ff       	call   80158e <fd_lookup>
  8019aa:	83 c4 08             	add    $0x8,%esp
  8019ad:	85 c0                	test   %eax,%eax
  8019af:	78 5f                	js     801a10 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019b1:	83 ec 08             	sub    $0x8,%esp
  8019b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019b7:	50                   	push   %eax
  8019b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019bb:	ff 30                	pushl  (%eax)
  8019bd:	e8 23 fc ff ff       	call   8015e5 <dev_lookup>
  8019c2:	83 c4 10             	add    $0x10,%esp
  8019c5:	85 c0                	test   %eax,%eax
  8019c7:	78 47                	js     801a10 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8019c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019cc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8019d0:	75 21                	jne    8019f3 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8019d2:	a1 04 50 80 00       	mov    0x805004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8019d7:	8b 40 48             	mov    0x48(%eax),%eax
  8019da:	83 ec 04             	sub    $0x4,%esp
  8019dd:	53                   	push   %ebx
  8019de:	50                   	push   %eax
  8019df:	68 54 30 80 00       	push   $0x803054
  8019e4:	e8 e9 eb ff ff       	call   8005d2 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8019e9:	83 c4 10             	add    $0x10,%esp
  8019ec:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8019f1:	eb 1d                	jmp    801a10 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  8019f3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019f6:	8b 52 18             	mov    0x18(%edx),%edx
  8019f9:	85 d2                	test   %edx,%edx
  8019fb:	74 0e                	je     801a0b <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8019fd:	83 ec 08             	sub    $0x8,%esp
  801a00:	ff 75 0c             	pushl  0xc(%ebp)
  801a03:	50                   	push   %eax
  801a04:	ff d2                	call   *%edx
  801a06:	83 c4 10             	add    $0x10,%esp
  801a09:	eb 05                	jmp    801a10 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801a0b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801a10:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a13:	c9                   	leave  
  801a14:	c3                   	ret    

00801a15 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801a15:	55                   	push   %ebp
  801a16:	89 e5                	mov    %esp,%ebp
  801a18:	53                   	push   %ebx
  801a19:	83 ec 14             	sub    $0x14,%esp
  801a1c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a1f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a22:	50                   	push   %eax
  801a23:	ff 75 08             	pushl  0x8(%ebp)
  801a26:	e8 63 fb ff ff       	call   80158e <fd_lookup>
  801a2b:	83 c4 08             	add    $0x8,%esp
  801a2e:	85 c0                	test   %eax,%eax
  801a30:	78 52                	js     801a84 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a32:	83 ec 08             	sub    $0x8,%esp
  801a35:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a38:	50                   	push   %eax
  801a39:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a3c:	ff 30                	pushl  (%eax)
  801a3e:	e8 a2 fb ff ff       	call   8015e5 <dev_lookup>
  801a43:	83 c4 10             	add    $0x10,%esp
  801a46:	85 c0                	test   %eax,%eax
  801a48:	78 3a                	js     801a84 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  801a4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a4d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801a51:	74 2c                	je     801a7f <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801a53:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801a56:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801a5d:	00 00 00 
	stat->st_isdir = 0;
  801a60:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a67:	00 00 00 
	stat->st_dev = dev;
  801a6a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801a70:	83 ec 08             	sub    $0x8,%esp
  801a73:	53                   	push   %ebx
  801a74:	ff 75 f0             	pushl  -0x10(%ebp)
  801a77:	ff 50 14             	call   *0x14(%eax)
  801a7a:	83 c4 10             	add    $0x10,%esp
  801a7d:	eb 05                	jmp    801a84 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801a7f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801a84:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a87:	c9                   	leave  
  801a88:	c3                   	ret    

00801a89 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801a89:	55                   	push   %ebp
  801a8a:	89 e5                	mov    %esp,%ebp
  801a8c:	56                   	push   %esi
  801a8d:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a8e:	83 ec 08             	sub    $0x8,%esp
  801a91:	6a 00                	push   $0x0
  801a93:	ff 75 08             	pushl  0x8(%ebp)
  801a96:	e8 75 01 00 00       	call   801c10 <open>
  801a9b:	89 c3                	mov    %eax,%ebx
  801a9d:	83 c4 10             	add    $0x10,%esp
  801aa0:	85 c0                	test   %eax,%eax
  801aa2:	78 1d                	js     801ac1 <stat+0x38>
		return fd;
	r = fstat(fd, stat);
  801aa4:	83 ec 08             	sub    $0x8,%esp
  801aa7:	ff 75 0c             	pushl  0xc(%ebp)
  801aaa:	50                   	push   %eax
  801aab:	e8 65 ff ff ff       	call   801a15 <fstat>
  801ab0:	89 c6                	mov    %eax,%esi
	close(fd);
  801ab2:	89 1c 24             	mov    %ebx,(%esp)
  801ab5:	e8 1d fc ff ff       	call   8016d7 <close>
	return r;
  801aba:	83 c4 10             	add    $0x10,%esp
  801abd:	89 f0                	mov    %esi,%eax
  801abf:	eb 00                	jmp    801ac1 <stat+0x38>
}
  801ac1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ac4:	5b                   	pop    %ebx
  801ac5:	5e                   	pop    %esi
  801ac6:	5d                   	pop    %ebp
  801ac7:	c3                   	ret    

00801ac8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801ac8:	55                   	push   %ebp
  801ac9:	89 e5                	mov    %esp,%ebp
  801acb:	56                   	push   %esi
  801acc:	53                   	push   %ebx
  801acd:	89 c6                	mov    %eax,%esi
  801acf:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801ad1:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801ad8:	75 12                	jne    801aec <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801ada:	83 ec 0c             	sub    $0xc,%esp
  801add:	6a 01                	push   $0x1
  801adf:	e8 9b 0c 00 00       	call   80277f <ipc_find_env>
  801ae4:	a3 00 50 80 00       	mov    %eax,0x805000
  801ae9:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801aec:	6a 07                	push   $0x7
  801aee:	68 00 60 80 00       	push   $0x806000
  801af3:	56                   	push   %esi
  801af4:	ff 35 00 50 80 00    	pushl  0x805000
  801afa:	e8 21 0c 00 00       	call   802720 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801aff:	83 c4 0c             	add    $0xc,%esp
  801b02:	6a 00                	push   $0x0
  801b04:	53                   	push   %ebx
  801b05:	6a 00                	push   $0x0
  801b07:	e8 9f 0b 00 00       	call   8026ab <ipc_recv>
}
  801b0c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b0f:	5b                   	pop    %ebx
  801b10:	5e                   	pop    %esi
  801b11:	5d                   	pop    %ebp
  801b12:	c3                   	ret    

00801b13 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801b13:	55                   	push   %ebp
  801b14:	89 e5                	mov    %esp,%ebp
  801b16:	53                   	push   %ebx
  801b17:	83 ec 04             	sub    $0x4,%esp
  801b1a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801b1d:	8b 45 08             	mov    0x8(%ebp),%eax
  801b20:	8b 40 0c             	mov    0xc(%eax),%eax
  801b23:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801b28:	ba 00 00 00 00       	mov    $0x0,%edx
  801b2d:	b8 05 00 00 00       	mov    $0x5,%eax
  801b32:	e8 91 ff ff ff       	call   801ac8 <fsipc>
  801b37:	85 c0                	test   %eax,%eax
  801b39:	78 2c                	js     801b67 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801b3b:	83 ec 08             	sub    $0x8,%esp
  801b3e:	68 00 60 80 00       	push   $0x806000
  801b43:	53                   	push   %ebx
  801b44:	e8 6e f0 ff ff       	call   800bb7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801b49:	a1 80 60 80 00       	mov    0x806080,%eax
  801b4e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b54:	a1 84 60 80 00       	mov    0x806084,%eax
  801b59:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b5f:	83 c4 10             	add    $0x10,%esp
  801b62:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b67:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b6a:	c9                   	leave  
  801b6b:	c3                   	ret    

00801b6c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801b6c:	55                   	push   %ebp
  801b6d:	89 e5                	mov    %esp,%ebp
  801b6f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801b72:	8b 45 08             	mov    0x8(%ebp),%eax
  801b75:	8b 40 0c             	mov    0xc(%eax),%eax
  801b78:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801b7d:	ba 00 00 00 00       	mov    $0x0,%edx
  801b82:	b8 06 00 00 00       	mov    $0x6,%eax
  801b87:	e8 3c ff ff ff       	call   801ac8 <fsipc>
}
  801b8c:	c9                   	leave  
  801b8d:	c3                   	ret    

00801b8e <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801b8e:	55                   	push   %ebp
  801b8f:	89 e5                	mov    %esp,%ebp
  801b91:	56                   	push   %esi
  801b92:	53                   	push   %ebx
  801b93:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b96:	8b 45 08             	mov    0x8(%ebp),%eax
  801b99:	8b 40 0c             	mov    0xc(%eax),%eax
  801b9c:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801ba1:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801ba7:	ba 00 00 00 00       	mov    $0x0,%edx
  801bac:	b8 03 00 00 00       	mov    $0x3,%eax
  801bb1:	e8 12 ff ff ff       	call   801ac8 <fsipc>
  801bb6:	89 c3                	mov    %eax,%ebx
  801bb8:	85 c0                	test   %eax,%eax
  801bba:	78 4b                	js     801c07 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801bbc:	39 c6                	cmp    %eax,%esi
  801bbe:	73 16                	jae    801bd6 <devfile_read+0x48>
  801bc0:	68 ae 30 80 00       	push   $0x8030ae
  801bc5:	68 b5 30 80 00       	push   $0x8030b5
  801bca:	6a 7a                	push   $0x7a
  801bcc:	68 ca 30 80 00       	push   $0x8030ca
  801bd1:	e8 24 e9 ff ff       	call   8004fa <_panic>
	assert(r <= PGSIZE);
  801bd6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801bdb:	7e 16                	jle    801bf3 <devfile_read+0x65>
  801bdd:	68 d5 30 80 00       	push   $0x8030d5
  801be2:	68 b5 30 80 00       	push   $0x8030b5
  801be7:	6a 7b                	push   $0x7b
  801be9:	68 ca 30 80 00       	push   $0x8030ca
  801bee:	e8 07 e9 ff ff       	call   8004fa <_panic>
	memmove(buf, &fsipcbuf, r);
  801bf3:	83 ec 04             	sub    $0x4,%esp
  801bf6:	50                   	push   %eax
  801bf7:	68 00 60 80 00       	push   $0x806000
  801bfc:	ff 75 0c             	pushl  0xc(%ebp)
  801bff:	e8 80 f1 ff ff       	call   800d84 <memmove>
	return r;
  801c04:	83 c4 10             	add    $0x10,%esp
}
  801c07:	89 d8                	mov    %ebx,%eax
  801c09:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c0c:	5b                   	pop    %ebx
  801c0d:	5e                   	pop    %esi
  801c0e:	5d                   	pop    %ebp
  801c0f:	c3                   	ret    

00801c10 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801c10:	55                   	push   %ebp
  801c11:	89 e5                	mov    %esp,%ebp
  801c13:	53                   	push   %ebx
  801c14:	83 ec 20             	sub    $0x20,%esp
  801c17:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801c1a:	53                   	push   %ebx
  801c1b:	e8 40 ef ff ff       	call   800b60 <strlen>
  801c20:	83 c4 10             	add    $0x10,%esp
  801c23:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801c28:	7f 63                	jg     801c8d <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801c2a:	83 ec 0c             	sub    $0xc,%esp
  801c2d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c30:	50                   	push   %eax
  801c31:	e8 e4 f8 ff ff       	call   80151a <fd_alloc>
  801c36:	83 c4 10             	add    $0x10,%esp
  801c39:	85 c0                	test   %eax,%eax
  801c3b:	78 55                	js     801c92 <open+0x82>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801c3d:	83 ec 08             	sub    $0x8,%esp
  801c40:	53                   	push   %ebx
  801c41:	68 00 60 80 00       	push   $0x806000
  801c46:	e8 6c ef ff ff       	call   800bb7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801c4b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c4e:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801c53:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c56:	b8 01 00 00 00       	mov    $0x1,%eax
  801c5b:	e8 68 fe ff ff       	call   801ac8 <fsipc>
  801c60:	89 c3                	mov    %eax,%ebx
  801c62:	83 c4 10             	add    $0x10,%esp
  801c65:	85 c0                	test   %eax,%eax
  801c67:	79 14                	jns    801c7d <open+0x6d>
		fd_close(fd, 0);
  801c69:	83 ec 08             	sub    $0x8,%esp
  801c6c:	6a 00                	push   $0x0
  801c6e:	ff 75 f4             	pushl  -0xc(%ebp)
  801c71:	e8 dd f9 ff ff       	call   801653 <fd_close>
		return r;
  801c76:	83 c4 10             	add    $0x10,%esp
  801c79:	89 d8                	mov    %ebx,%eax
  801c7b:	eb 15                	jmp    801c92 <open+0x82>
	}

	return fd2num(fd);
  801c7d:	83 ec 0c             	sub    $0xc,%esp
  801c80:	ff 75 f4             	pushl  -0xc(%ebp)
  801c83:	e8 6b f8 ff ff       	call   8014f3 <fd2num>
  801c88:	83 c4 10             	add    $0x10,%esp
  801c8b:	eb 05                	jmp    801c92 <open+0x82>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c8d:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801c92:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c95:	c9                   	leave  
  801c96:	c3                   	ret    

00801c97 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801c97:	55                   	push   %ebp
  801c98:	89 e5                	mov    %esp,%ebp
  801c9a:	57                   	push   %edi
  801c9b:	56                   	push   %esi
  801c9c:	53                   	push   %ebx
  801c9d:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801ca3:	6a 00                	push   $0x0
  801ca5:	ff 75 08             	pushl  0x8(%ebp)
  801ca8:	e8 63 ff ff ff       	call   801c10 <open>
  801cad:	89 c1                	mov    %eax,%ecx
  801caf:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801cb5:	83 c4 10             	add    $0x10,%esp
  801cb8:	85 c0                	test   %eax,%eax
  801cba:	0f 88 6f 04 00 00    	js     80212f <spawn+0x498>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801cc0:	83 ec 04             	sub    $0x4,%esp
  801cc3:	68 00 02 00 00       	push   $0x200
  801cc8:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801cce:	50                   	push   %eax
  801ccf:	51                   	push   %ecx
  801cd0:	e8 c1 fb ff ff       	call   801896 <readn>
  801cd5:	83 c4 10             	add    $0x10,%esp
  801cd8:	3d 00 02 00 00       	cmp    $0x200,%eax
  801cdd:	75 0c                	jne    801ceb <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  801cdf:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801ce6:	45 4c 46 
  801ce9:	74 33                	je     801d1e <spawn+0x87>
		close(fd);
  801ceb:	83 ec 0c             	sub    $0xc,%esp
  801cee:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801cf4:	e8 de f9 ff ff       	call   8016d7 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801cf9:	83 c4 0c             	add    $0xc,%esp
  801cfc:	68 7f 45 4c 46       	push   $0x464c457f
  801d01:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801d07:	68 e1 30 80 00       	push   $0x8030e1
  801d0c:	e8 c1 e8 ff ff       	call   8005d2 <cprintf>
		return -E_NOT_EXEC;
  801d11:	83 c4 10             	add    $0x10,%esp
  801d14:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801d19:	e9 71 04 00 00       	jmp    80218f <spawn+0x4f8>
  801d1e:	b8 07 00 00 00       	mov    $0x7,%eax
  801d23:	cd 30                	int    $0x30
  801d25:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801d2b:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801d31:	85 c0                	test   %eax,%eax
  801d33:	0f 88 fe 03 00 00    	js     802137 <spawn+0x4a0>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801d39:	89 c6                	mov    %eax,%esi
  801d3b:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801d41:	8d 04 b5 00 00 00 00 	lea    0x0(,%esi,4),%eax
  801d48:	c1 e6 07             	shl    $0x7,%esi
  801d4b:	29 c6                	sub    %eax,%esi
  801d4d:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801d53:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801d59:	b9 11 00 00 00       	mov    $0x11,%ecx
  801d5e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801d60:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801d66:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801d6c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d6f:	8b 00                	mov    (%eax),%eax
  801d71:	85 c0                	test   %eax,%eax
  801d73:	74 3a                	je     801daf <spawn+0x118>
  801d75:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d7a:	be 00 00 00 00       	mov    $0x0,%esi
  801d7f:	8b 7d 0c             	mov    0xc(%ebp),%edi
		string_size += strlen(argv[argc]) + 1;
  801d82:	83 ec 0c             	sub    $0xc,%esp
  801d85:	50                   	push   %eax
  801d86:	e8 d5 ed ff ff       	call   800b60 <strlen>
  801d8b:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801d8f:	43                   	inc    %ebx
  801d90:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801d97:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801d9a:	83 c4 10             	add    $0x10,%esp
  801d9d:	85 c0                	test   %eax,%eax
  801d9f:	75 e1                	jne    801d82 <spawn+0xeb>
  801da1:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801da7:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
  801dad:	eb 1e                	jmp    801dcd <spawn+0x136>
  801daf:	c7 85 80 fd ff ff 00 	movl   $0x0,-0x280(%ebp)
  801db6:	00 00 00 
  801db9:	c7 85 88 fd ff ff 00 	movl   $0x0,-0x278(%ebp)
  801dc0:	00 00 00 
  801dc3:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801dc8:	be 00 00 00 00       	mov    $0x0,%esi
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801dcd:	bf 00 10 40 00       	mov    $0x401000,%edi
  801dd2:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801dd4:	89 fa                	mov    %edi,%edx
  801dd6:	83 e2 fc             	and    $0xfffffffc,%edx
  801dd9:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801de0:	29 c2                	sub    %eax,%edx
  801de2:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801de8:	8d 42 f8             	lea    -0x8(%edx),%eax
  801deb:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801df0:	0f 86 51 03 00 00    	jbe    802147 <spawn+0x4b0>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801df6:	83 ec 04             	sub    $0x4,%esp
  801df9:	6a 07                	push   $0x7
  801dfb:	68 00 00 40 00       	push   $0x400000
  801e00:	6a 00                	push   $0x0
  801e02:	e8 20 f2 ff ff       	call   801027 <sys_page_alloc>
  801e07:	83 c4 10             	add    $0x10,%esp
  801e0a:	85 c0                	test   %eax,%eax
  801e0c:	0f 88 3c 03 00 00    	js     80214e <spawn+0x4b7>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801e12:	85 db                	test   %ebx,%ebx
  801e14:	7e 44                	jle    801e5a <spawn+0x1c3>
  801e16:	be 00 00 00 00       	mov    $0x0,%esi
  801e1b:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801e21:	8b 5d 0c             	mov    0xc(%ebp),%ebx
		argv_store[i] = UTEMP2USTACK(string_store);
  801e24:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801e2a:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801e30:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801e33:	83 ec 08             	sub    $0x8,%esp
  801e36:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801e39:	57                   	push   %edi
  801e3a:	e8 78 ed ff ff       	call   800bb7 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801e3f:	83 c4 04             	add    $0x4,%esp
  801e42:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801e45:	e8 16 ed ff ff       	call   800b60 <strlen>
  801e4a:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801e4e:	46                   	inc    %esi
  801e4f:	83 c4 10             	add    $0x10,%esp
  801e52:	3b b5 90 fd ff ff    	cmp    -0x270(%ebp),%esi
  801e58:	75 ca                	jne    801e24 <spawn+0x18d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801e5a:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801e60:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801e66:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801e6d:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801e73:	74 19                	je     801e8e <spawn+0x1f7>
  801e75:	68 58 31 80 00       	push   $0x803158
  801e7a:	68 b5 30 80 00       	push   $0x8030b5
  801e7f:	68 f1 00 00 00       	push   $0xf1
  801e84:	68 fb 30 80 00       	push   $0x8030fb
  801e89:	e8 6c e6 ff ff       	call   8004fa <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801e8e:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801e94:	89 c8                	mov    %ecx,%eax
  801e96:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801e9b:	89 41 fc             	mov    %eax,-0x4(%ecx)
	argv_store[-2] = argc;
  801e9e:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801ea4:	89 41 f8             	mov    %eax,-0x8(%ecx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801ea7:	8d 81 f8 cf 7f ee    	lea    -0x11803008(%ecx),%eax
  801ead:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801eb3:	83 ec 0c             	sub    $0xc,%esp
  801eb6:	6a 07                	push   $0x7
  801eb8:	68 00 d0 bf ee       	push   $0xeebfd000
  801ebd:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801ec3:	68 00 00 40 00       	push   $0x400000
  801ec8:	6a 00                	push   $0x0
  801eca:	e8 9b f1 ff ff       	call   80106a <sys_page_map>
  801ecf:	89 c3                	mov    %eax,%ebx
  801ed1:	83 c4 20             	add    $0x20,%esp
  801ed4:	85 c0                	test   %eax,%eax
  801ed6:	0f 88 a1 02 00 00    	js     80217d <spawn+0x4e6>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801edc:	83 ec 08             	sub    $0x8,%esp
  801edf:	68 00 00 40 00       	push   $0x400000
  801ee4:	6a 00                	push   $0x0
  801ee6:	e8 c1 f1 ff ff       	call   8010ac <sys_page_unmap>
  801eeb:	89 c3                	mov    %eax,%ebx
  801eed:	83 c4 10             	add    $0x10,%esp
  801ef0:	85 c0                	test   %eax,%eax
  801ef2:	0f 88 85 02 00 00    	js     80217d <spawn+0x4e6>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801ef8:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801efe:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801f05:	89 85 78 fd ff ff    	mov    %eax,-0x288(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801f0b:	66 83 bd 14 fe ff ff 	cmpw   $0x0,-0x1ec(%ebp)
  801f12:	00 
  801f13:	0f 84 ab 01 00 00    	je     8020c4 <spawn+0x42d>
  801f19:	c7 85 80 fd ff ff 00 	movl   $0x0,-0x280(%ebp)
  801f20:	00 00 00 
		if (ph->p_type != ELF_PROG_LOAD)
  801f23:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  801f29:	83 38 01             	cmpl   $0x1,(%eax)
  801f2c:	0f 85 70 01 00 00    	jne    8020a2 <spawn+0x40b>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801f32:	89 c1                	mov    %eax,%ecx
  801f34:	8b 40 18             	mov    0x18(%eax),%eax
  801f37:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801f3a:	83 f8 01             	cmp    $0x1,%eax
  801f3d:	19 c0                	sbb    %eax,%eax
  801f3f:	83 e0 fe             	and    $0xfffffffe,%eax
  801f42:	83 c0 07             	add    $0x7,%eax
  801f45:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801f4b:	89 c8                	mov    %ecx,%eax
  801f4d:	8b 49 04             	mov    0x4(%ecx),%ecx
  801f50:	89 8d 7c fd ff ff    	mov    %ecx,-0x284(%ebp)
  801f56:	8b 50 10             	mov    0x10(%eax),%edx
  801f59:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)
  801f5f:	8b 78 14             	mov    0x14(%eax),%edi
  801f62:	89 bd 90 fd ff ff    	mov    %edi,-0x270(%ebp)
  801f68:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801f6b:	89 f0                	mov    %esi,%eax
  801f6d:	25 ff 0f 00 00       	and    $0xfff,%eax
  801f72:	74 1a                	je     801f8e <spawn+0x2f7>
		va -= i;
  801f74:	29 c6                	sub    %eax,%esi
		memsz += i;
  801f76:	01 c7                	add    %eax,%edi
  801f78:	89 bd 90 fd ff ff    	mov    %edi,-0x270(%ebp)
		filesz += i;
  801f7e:	01 c2                	add    %eax,%edx
  801f80:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)
		fileoffset -= i;
  801f86:	29 c1                	sub    %eax,%ecx
  801f88:	89 8d 7c fd ff ff    	mov    %ecx,-0x284(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801f8e:	83 bd 90 fd ff ff 00 	cmpl   $0x0,-0x270(%ebp)
  801f95:	0f 84 07 01 00 00    	je     8020a2 <spawn+0x40b>
  801f9b:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (i >= filesz) {
  801fa0:	39 9d 94 fd ff ff    	cmp    %ebx,-0x26c(%ebp)
  801fa6:	77 27                	ja     801fcf <spawn+0x338>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801fa8:	83 ec 04             	sub    $0x4,%esp
  801fab:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801fb1:	56                   	push   %esi
  801fb2:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801fb8:	e8 6a f0 ff ff       	call   801027 <sys_page_alloc>
  801fbd:	83 c4 10             	add    $0x10,%esp
  801fc0:	85 c0                	test   %eax,%eax
  801fc2:	0f 89 c2 00 00 00    	jns    80208a <spawn+0x3f3>
  801fc8:	89 c3                	mov    %eax,%ebx
  801fca:	e9 8d 01 00 00       	jmp    80215c <spawn+0x4c5>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801fcf:	83 ec 04             	sub    $0x4,%esp
  801fd2:	6a 07                	push   $0x7
  801fd4:	68 00 00 40 00       	push   $0x400000
  801fd9:	6a 00                	push   $0x0
  801fdb:	e8 47 f0 ff ff       	call   801027 <sys_page_alloc>
  801fe0:	83 c4 10             	add    $0x10,%esp
  801fe3:	85 c0                	test   %eax,%eax
  801fe5:	0f 88 67 01 00 00    	js     802152 <spawn+0x4bb>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801feb:	83 ec 08             	sub    $0x8,%esp
  801fee:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801ff4:	01 d8                	add    %ebx,%eax
  801ff6:	50                   	push   %eax
  801ff7:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801ffd:	e8 6b f9 ff ff       	call   80196d <seek>
  802002:	83 c4 10             	add    $0x10,%esp
  802005:	85 c0                	test   %eax,%eax
  802007:	0f 88 49 01 00 00    	js     802156 <spawn+0x4bf>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  80200d:	83 ec 04             	sub    $0x4,%esp
  802010:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  802016:	29 d8                	sub    %ebx,%eax
  802018:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80201d:	76 05                	jbe    802024 <spawn+0x38d>
  80201f:	b8 00 10 00 00       	mov    $0x1000,%eax
  802024:	50                   	push   %eax
  802025:	68 00 00 40 00       	push   $0x400000
  80202a:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802030:	e8 61 f8 ff ff       	call   801896 <readn>
  802035:	83 c4 10             	add    $0x10,%esp
  802038:	85 c0                	test   %eax,%eax
  80203a:	0f 88 1a 01 00 00    	js     80215a <spawn+0x4c3>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  802040:	83 ec 0c             	sub    $0xc,%esp
  802043:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  802049:	56                   	push   %esi
  80204a:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  802050:	68 00 00 40 00       	push   $0x400000
  802055:	6a 00                	push   $0x0
  802057:	e8 0e f0 ff ff       	call   80106a <sys_page_map>
  80205c:	83 c4 20             	add    $0x20,%esp
  80205f:	85 c0                	test   %eax,%eax
  802061:	79 15                	jns    802078 <spawn+0x3e1>
				panic("spawn: sys_page_map data: %e", r);
  802063:	50                   	push   %eax
  802064:	68 07 31 80 00       	push   $0x803107
  802069:	68 24 01 00 00       	push   $0x124
  80206e:	68 fb 30 80 00       	push   $0x8030fb
  802073:	e8 82 e4 ff ff       	call   8004fa <_panic>
			sys_page_unmap(0, UTEMP);
  802078:	83 ec 08             	sub    $0x8,%esp
  80207b:	68 00 00 40 00       	push   $0x400000
  802080:	6a 00                	push   $0x0
  802082:	e8 25 f0 ff ff       	call   8010ac <sys_page_unmap>
  802087:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  80208a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802090:	81 c6 00 10 00 00    	add    $0x1000,%esi
  802096:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  80209c:	0f 82 fe fe ff ff    	jb     801fa0 <spawn+0x309>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8020a2:	ff 85 80 fd ff ff    	incl   -0x280(%ebp)
  8020a8:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  8020ae:	83 85 78 fd ff ff 20 	addl   $0x20,-0x288(%ebp)
  8020b5:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  8020bc:	39 d0                	cmp    %edx,%eax
  8020be:	0f 8f 5f fe ff ff    	jg     801f23 <spawn+0x28c>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  8020c4:	83 ec 0c             	sub    $0xc,%esp
  8020c7:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8020cd:	e8 05 f6 ff ff       	call   8016d7 <close>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  8020d2:	83 c4 08             	add    $0x8,%esp
  8020d5:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  8020db:	50                   	push   %eax
  8020dc:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8020e2:	e8 49 f0 ff ff       	call   801130 <sys_env_set_trapframe>
  8020e7:	83 c4 10             	add    $0x10,%esp
  8020ea:	85 c0                	test   %eax,%eax
  8020ec:	79 15                	jns    802103 <spawn+0x46c>
		panic("sys_env_set_trapframe: %e", r);
  8020ee:	50                   	push   %eax
  8020ef:	68 24 31 80 00       	push   $0x803124
  8020f4:	68 85 00 00 00       	push   $0x85
  8020f9:	68 fb 30 80 00       	push   $0x8030fb
  8020fe:	e8 f7 e3 ff ff       	call   8004fa <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  802103:	83 ec 08             	sub    $0x8,%esp
  802106:	6a 02                	push   $0x2
  802108:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80210e:	e8 db ef ff ff       	call   8010ee <sys_env_set_status>
  802113:	83 c4 10             	add    $0x10,%esp
  802116:	85 c0                	test   %eax,%eax
  802118:	79 25                	jns    80213f <spawn+0x4a8>
		panic("sys_env_set_status: %e", r);
  80211a:	50                   	push   %eax
  80211b:	68 3e 31 80 00       	push   $0x80313e
  802120:	68 88 00 00 00       	push   $0x88
  802125:	68 fb 30 80 00       	push   $0x8030fb
  80212a:	e8 cb e3 ff ff       	call   8004fa <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  80212f:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  802135:	eb 58                	jmp    80218f <spawn+0x4f8>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  802137:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  80213d:	eb 50                	jmp    80218f <spawn+0x4f8>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  80213f:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  802145:	eb 48                	jmp    80218f <spawn+0x4f8>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  802147:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  80214c:	eb 41                	jmp    80218f <spawn+0x4f8>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  80214e:	89 c3                	mov    %eax,%ebx
  802150:	eb 3d                	jmp    80218f <spawn+0x4f8>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802152:	89 c3                	mov    %eax,%ebx
  802154:	eb 06                	jmp    80215c <spawn+0x4c5>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802156:	89 c3                	mov    %eax,%ebx
  802158:	eb 02                	jmp    80215c <spawn+0x4c5>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  80215a:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  80215c:	83 ec 0c             	sub    $0xc,%esp
  80215f:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802165:	e8 3e ee ff ff       	call   800fa8 <sys_env_destroy>
	close(fd);
  80216a:	83 c4 04             	add    $0x4,%esp
  80216d:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802173:	e8 5f f5 ff ff       	call   8016d7 <close>
	return r;
  802178:	83 c4 10             	add    $0x10,%esp
  80217b:	eb 12                	jmp    80218f <spawn+0x4f8>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  80217d:	83 ec 08             	sub    $0x8,%esp
  802180:	68 00 00 40 00       	push   $0x400000
  802185:	6a 00                	push   $0x0
  802187:	e8 20 ef ff ff       	call   8010ac <sys_page_unmap>
  80218c:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  80218f:	89 d8                	mov    %ebx,%eax
  802191:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802194:	5b                   	pop    %ebx
  802195:	5e                   	pop    %esi
  802196:	5f                   	pop    %edi
  802197:	5d                   	pop    %ebp
  802198:	c3                   	ret    

00802199 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  802199:	55                   	push   %ebp
  80219a:	89 e5                	mov    %esp,%ebp
  80219c:	57                   	push   %edi
  80219d:	56                   	push   %esi
  80219e:	53                   	push   %ebx
  80219f:	83 ec 1c             	sub    $0x1c,%esp
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8021a2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8021a6:	74 5f                	je     802207 <spawnl+0x6e>
  8021a8:	8d 45 14             	lea    0x14(%ebp),%eax
  8021ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8021b0:	eb 02                	jmp    8021b4 <spawnl+0x1b>
		argc++;
  8021b2:	89 ca                	mov    %ecx,%edx
  8021b4:	8d 4a 01             	lea    0x1(%edx),%ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8021b7:	83 c0 04             	add    $0x4,%eax
  8021ba:	83 78 fc 00          	cmpl   $0x0,-0x4(%eax)
  8021be:	75 f2                	jne    8021b2 <spawnl+0x19>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  8021c0:	8d 04 95 1e 00 00 00 	lea    0x1e(,%edx,4),%eax
  8021c7:	83 e0 f0             	and    $0xfffffff0,%eax
  8021ca:	29 c4                	sub    %eax,%esp
  8021cc:	8d 44 24 03          	lea    0x3(%esp),%eax
  8021d0:	c1 e8 02             	shr    $0x2,%eax
  8021d3:	8d 34 85 00 00 00 00 	lea    0x0(,%eax,4),%esi
  8021da:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  8021dc:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8021df:	89 3c 85 00 00 00 00 	mov    %edi,0x0(,%eax,4)
	argv[argc+1] = NULL;
  8021e6:	c7 44 96 08 00 00 00 	movl   $0x0,0x8(%esi,%edx,4)
  8021ed:	00 

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  8021ee:	89 ce                	mov    %ecx,%esi
  8021f0:	85 c9                	test   %ecx,%ecx
  8021f2:	74 23                	je     802217 <spawnl+0x7e>
  8021f4:	b8 00 00 00 00       	mov    $0x0,%eax
		argv[i+1] = va_arg(vl, const char *);
  8021f9:	40                   	inc    %eax
  8021fa:	8b 54 85 0c          	mov    0xc(%ebp,%eax,4),%edx
  8021fe:	89 14 83             	mov    %edx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802201:	39 f0                	cmp    %esi,%eax
  802203:	75 f4                	jne    8021f9 <spawnl+0x60>
  802205:	eb 10                	jmp    802217 <spawnl+0x7e>
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
	argv[0] = arg0;
  802207:	8b 45 0c             	mov    0xc(%ebp),%eax
  80220a:	89 45 e0             	mov    %eax,-0x20(%ebp)
	argv[argc+1] = NULL;
  80220d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802214:	8d 5d e0             	lea    -0x20(%ebp),%ebx
	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802217:	83 ec 08             	sub    $0x8,%esp
  80221a:	53                   	push   %ebx
  80221b:	ff 75 08             	pushl  0x8(%ebp)
  80221e:	e8 74 fa ff ff       	call   801c97 <spawn>
}
  802223:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802226:	5b                   	pop    %ebx
  802227:	5e                   	pop    %esi
  802228:	5f                   	pop    %edi
  802229:	5d                   	pop    %ebp
  80222a:	c3                   	ret    

0080222b <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80222b:	55                   	push   %ebp
  80222c:	89 e5                	mov    %esp,%ebp
  80222e:	56                   	push   %esi
  80222f:	53                   	push   %ebx
  802230:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802233:	83 ec 0c             	sub    $0xc,%esp
  802236:	ff 75 08             	pushl  0x8(%ebp)
  802239:	e8 c5 f2 ff ff       	call   801503 <fd2data>
  80223e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802240:	83 c4 08             	add    $0x8,%esp
  802243:	68 80 31 80 00       	push   $0x803180
  802248:	53                   	push   %ebx
  802249:	e8 69 e9 ff ff       	call   800bb7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80224e:	8b 46 04             	mov    0x4(%esi),%eax
  802251:	2b 06                	sub    (%esi),%eax
  802253:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802259:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802260:	00 00 00 
	stat->st_dev = &devpipe;
  802263:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  80226a:	40 80 00 
	return 0;
}
  80226d:	b8 00 00 00 00       	mov    $0x0,%eax
  802272:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802275:	5b                   	pop    %ebx
  802276:	5e                   	pop    %esi
  802277:	5d                   	pop    %ebp
  802278:	c3                   	ret    

00802279 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802279:	55                   	push   %ebp
  80227a:	89 e5                	mov    %esp,%ebp
  80227c:	53                   	push   %ebx
  80227d:	83 ec 0c             	sub    $0xc,%esp
  802280:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802283:	53                   	push   %ebx
  802284:	6a 00                	push   $0x0
  802286:	e8 21 ee ff ff       	call   8010ac <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80228b:	89 1c 24             	mov    %ebx,(%esp)
  80228e:	e8 70 f2 ff ff       	call   801503 <fd2data>
  802293:	83 c4 08             	add    $0x8,%esp
  802296:	50                   	push   %eax
  802297:	6a 00                	push   $0x0
  802299:	e8 0e ee ff ff       	call   8010ac <sys_page_unmap>
}
  80229e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8022a1:	c9                   	leave  
  8022a2:	c3                   	ret    

008022a3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8022a3:	55                   	push   %ebp
  8022a4:	89 e5                	mov    %esp,%ebp
  8022a6:	57                   	push   %edi
  8022a7:	56                   	push   %esi
  8022a8:	53                   	push   %ebx
  8022a9:	83 ec 1c             	sub    $0x1c,%esp
  8022ac:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8022af:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8022b1:	a1 04 50 80 00       	mov    0x805004,%eax
  8022b6:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8022b9:	83 ec 0c             	sub    $0xc,%esp
  8022bc:	ff 75 e0             	pushl  -0x20(%ebp)
  8022bf:	e8 16 05 00 00       	call   8027da <pageref>
  8022c4:	89 c3                	mov    %eax,%ebx
  8022c6:	89 3c 24             	mov    %edi,(%esp)
  8022c9:	e8 0c 05 00 00       	call   8027da <pageref>
  8022ce:	83 c4 10             	add    $0x10,%esp
  8022d1:	39 c3                	cmp    %eax,%ebx
  8022d3:	0f 94 c1             	sete   %cl
  8022d6:	0f b6 c9             	movzbl %cl,%ecx
  8022d9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8022dc:	8b 15 04 50 80 00    	mov    0x805004,%edx
  8022e2:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8022e5:	39 ce                	cmp    %ecx,%esi
  8022e7:	74 1b                	je     802304 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8022e9:	39 c3                	cmp    %eax,%ebx
  8022eb:	75 c4                	jne    8022b1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8022ed:	8b 42 58             	mov    0x58(%edx),%eax
  8022f0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8022f3:	50                   	push   %eax
  8022f4:	56                   	push   %esi
  8022f5:	68 87 31 80 00       	push   $0x803187
  8022fa:	e8 d3 e2 ff ff       	call   8005d2 <cprintf>
  8022ff:	83 c4 10             	add    $0x10,%esp
  802302:	eb ad                	jmp    8022b1 <_pipeisclosed+0xe>
	}
}
  802304:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802307:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80230a:	5b                   	pop    %ebx
  80230b:	5e                   	pop    %esi
  80230c:	5f                   	pop    %edi
  80230d:	5d                   	pop    %ebp
  80230e:	c3                   	ret    

0080230f <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80230f:	55                   	push   %ebp
  802310:	89 e5                	mov    %esp,%ebp
  802312:	57                   	push   %edi
  802313:	56                   	push   %esi
  802314:	53                   	push   %ebx
  802315:	83 ec 18             	sub    $0x18,%esp
  802318:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80231b:	56                   	push   %esi
  80231c:	e8 e2 f1 ff ff       	call   801503 <fd2data>
  802321:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802323:	83 c4 10             	add    $0x10,%esp
  802326:	bf 00 00 00 00       	mov    $0x0,%edi
  80232b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80232f:	75 42                	jne    802373 <devpipe_write+0x64>
  802331:	eb 4e                	jmp    802381 <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802333:	89 da                	mov    %ebx,%edx
  802335:	89 f0                	mov    %esi,%eax
  802337:	e8 67 ff ff ff       	call   8022a3 <_pipeisclosed>
  80233c:	85 c0                	test   %eax,%eax
  80233e:	75 46                	jne    802386 <devpipe_write+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802340:	e8 c3 ec ff ff       	call   801008 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802345:	8b 53 04             	mov    0x4(%ebx),%edx
  802348:	8b 03                	mov    (%ebx),%eax
  80234a:	83 c0 20             	add    $0x20,%eax
  80234d:	39 c2                	cmp    %eax,%edx
  80234f:	73 e2                	jae    802333 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802351:	8b 45 0c             	mov    0xc(%ebp),%eax
  802354:	8a 0c 38             	mov    (%eax,%edi,1),%cl
  802357:	89 d0                	mov    %edx,%eax
  802359:	25 1f 00 00 80       	and    $0x8000001f,%eax
  80235e:	79 05                	jns    802365 <devpipe_write+0x56>
  802360:	48                   	dec    %eax
  802361:	83 c8 e0             	or     $0xffffffe0,%eax
  802364:	40                   	inc    %eax
  802365:	88 4c 03 08          	mov    %cl,0x8(%ebx,%eax,1)
		p->p_wpos++;
  802369:	42                   	inc    %edx
  80236a:	89 53 04             	mov    %edx,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80236d:	47                   	inc    %edi
  80236e:	39 7d 10             	cmp    %edi,0x10(%ebp)
  802371:	74 0e                	je     802381 <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802373:	8b 53 04             	mov    0x4(%ebx),%edx
  802376:	8b 03                	mov    (%ebx),%eax
  802378:	83 c0 20             	add    $0x20,%eax
  80237b:	39 c2                	cmp    %eax,%edx
  80237d:	73 b4                	jae    802333 <devpipe_write+0x24>
  80237f:	eb d0                	jmp    802351 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802381:	8b 45 10             	mov    0x10(%ebp),%eax
  802384:	eb 05                	jmp    80238b <devpipe_write+0x7c>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802386:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80238b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80238e:	5b                   	pop    %ebx
  80238f:	5e                   	pop    %esi
  802390:	5f                   	pop    %edi
  802391:	5d                   	pop    %ebp
  802392:	c3                   	ret    

00802393 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802393:	55                   	push   %ebp
  802394:	89 e5                	mov    %esp,%ebp
  802396:	57                   	push   %edi
  802397:	56                   	push   %esi
  802398:	53                   	push   %ebx
  802399:	83 ec 18             	sub    $0x18,%esp
  80239c:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80239f:	57                   	push   %edi
  8023a0:	e8 5e f1 ff ff       	call   801503 <fd2data>
  8023a5:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8023a7:	83 c4 10             	add    $0x10,%esp
  8023aa:	be 00 00 00 00       	mov    $0x0,%esi
  8023af:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8023b3:	75 3d                	jne    8023f2 <devpipe_read+0x5f>
  8023b5:	eb 48                	jmp    8023ff <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  8023b7:	89 f0                	mov    %esi,%eax
  8023b9:	eb 4e                	jmp    802409 <devpipe_read+0x76>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8023bb:	89 da                	mov    %ebx,%edx
  8023bd:	89 f8                	mov    %edi,%eax
  8023bf:	e8 df fe ff ff       	call   8022a3 <_pipeisclosed>
  8023c4:	85 c0                	test   %eax,%eax
  8023c6:	75 3c                	jne    802404 <devpipe_read+0x71>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8023c8:	e8 3b ec ff ff       	call   801008 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8023cd:	8b 03                	mov    (%ebx),%eax
  8023cf:	3b 43 04             	cmp    0x4(%ebx),%eax
  8023d2:	74 e7                	je     8023bb <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8023d4:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8023d9:	79 05                	jns    8023e0 <devpipe_read+0x4d>
  8023db:	48                   	dec    %eax
  8023dc:	83 c8 e0             	or     $0xffffffe0,%eax
  8023df:	40                   	inc    %eax
  8023e0:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8023e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8023e7:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8023ea:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8023ec:	46                   	inc    %esi
  8023ed:	39 75 10             	cmp    %esi,0x10(%ebp)
  8023f0:	74 0d                	je     8023ff <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
  8023f2:	8b 03                	mov    (%ebx),%eax
  8023f4:	3b 43 04             	cmp    0x4(%ebx),%eax
  8023f7:	75 db                	jne    8023d4 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8023f9:	85 f6                	test   %esi,%esi
  8023fb:	75 ba                	jne    8023b7 <devpipe_read+0x24>
  8023fd:	eb bc                	jmp    8023bb <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8023ff:	8b 45 10             	mov    0x10(%ebp),%eax
  802402:	eb 05                	jmp    802409 <devpipe_read+0x76>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802404:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802409:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80240c:	5b                   	pop    %ebx
  80240d:	5e                   	pop    %esi
  80240e:	5f                   	pop    %edi
  80240f:	5d                   	pop    %ebp
  802410:	c3                   	ret    

00802411 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802411:	55                   	push   %ebp
  802412:	89 e5                	mov    %esp,%ebp
  802414:	56                   	push   %esi
  802415:	53                   	push   %ebx
  802416:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802419:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80241c:	50                   	push   %eax
  80241d:	e8 f8 f0 ff ff       	call   80151a <fd_alloc>
  802422:	83 c4 10             	add    $0x10,%esp
  802425:	85 c0                	test   %eax,%eax
  802427:	0f 88 2a 01 00 00    	js     802557 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80242d:	83 ec 04             	sub    $0x4,%esp
  802430:	68 07 04 00 00       	push   $0x407
  802435:	ff 75 f4             	pushl  -0xc(%ebp)
  802438:	6a 00                	push   $0x0
  80243a:	e8 e8 eb ff ff       	call   801027 <sys_page_alloc>
  80243f:	83 c4 10             	add    $0x10,%esp
  802442:	85 c0                	test   %eax,%eax
  802444:	0f 88 0d 01 00 00    	js     802557 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80244a:	83 ec 0c             	sub    $0xc,%esp
  80244d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802450:	50                   	push   %eax
  802451:	e8 c4 f0 ff ff       	call   80151a <fd_alloc>
  802456:	89 c3                	mov    %eax,%ebx
  802458:	83 c4 10             	add    $0x10,%esp
  80245b:	85 c0                	test   %eax,%eax
  80245d:	0f 88 e2 00 00 00    	js     802545 <pipe+0x134>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802463:	83 ec 04             	sub    $0x4,%esp
  802466:	68 07 04 00 00       	push   $0x407
  80246b:	ff 75 f0             	pushl  -0x10(%ebp)
  80246e:	6a 00                	push   $0x0
  802470:	e8 b2 eb ff ff       	call   801027 <sys_page_alloc>
  802475:	89 c3                	mov    %eax,%ebx
  802477:	83 c4 10             	add    $0x10,%esp
  80247a:	85 c0                	test   %eax,%eax
  80247c:	0f 88 c3 00 00 00    	js     802545 <pipe+0x134>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802482:	83 ec 0c             	sub    $0xc,%esp
  802485:	ff 75 f4             	pushl  -0xc(%ebp)
  802488:	e8 76 f0 ff ff       	call   801503 <fd2data>
  80248d:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80248f:	83 c4 0c             	add    $0xc,%esp
  802492:	68 07 04 00 00       	push   $0x407
  802497:	50                   	push   %eax
  802498:	6a 00                	push   $0x0
  80249a:	e8 88 eb ff ff       	call   801027 <sys_page_alloc>
  80249f:	89 c3                	mov    %eax,%ebx
  8024a1:	83 c4 10             	add    $0x10,%esp
  8024a4:	85 c0                	test   %eax,%eax
  8024a6:	0f 88 89 00 00 00    	js     802535 <pipe+0x124>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8024ac:	83 ec 0c             	sub    $0xc,%esp
  8024af:	ff 75 f0             	pushl  -0x10(%ebp)
  8024b2:	e8 4c f0 ff ff       	call   801503 <fd2data>
  8024b7:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8024be:	50                   	push   %eax
  8024bf:	6a 00                	push   $0x0
  8024c1:	56                   	push   %esi
  8024c2:	6a 00                	push   $0x0
  8024c4:	e8 a1 eb ff ff       	call   80106a <sys_page_map>
  8024c9:	89 c3                	mov    %eax,%ebx
  8024cb:	83 c4 20             	add    $0x20,%esp
  8024ce:	85 c0                	test   %eax,%eax
  8024d0:	78 55                	js     802527 <pipe+0x116>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8024d2:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  8024d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024db:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8024dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024e0:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8024e7:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  8024ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8024f0:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8024f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8024f5:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8024fc:	83 ec 0c             	sub    $0xc,%esp
  8024ff:	ff 75 f4             	pushl  -0xc(%ebp)
  802502:	e8 ec ef ff ff       	call   8014f3 <fd2num>
  802507:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80250a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80250c:	83 c4 04             	add    $0x4,%esp
  80250f:	ff 75 f0             	pushl  -0x10(%ebp)
  802512:	e8 dc ef ff ff       	call   8014f3 <fd2num>
  802517:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80251a:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80251d:	83 c4 10             	add    $0x10,%esp
  802520:	b8 00 00 00 00       	mov    $0x0,%eax
  802525:	eb 30                	jmp    802557 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  802527:	83 ec 08             	sub    $0x8,%esp
  80252a:	56                   	push   %esi
  80252b:	6a 00                	push   $0x0
  80252d:	e8 7a eb ff ff       	call   8010ac <sys_page_unmap>
  802532:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802535:	83 ec 08             	sub    $0x8,%esp
  802538:	ff 75 f0             	pushl  -0x10(%ebp)
  80253b:	6a 00                	push   $0x0
  80253d:	e8 6a eb ff ff       	call   8010ac <sys_page_unmap>
  802542:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802545:	83 ec 08             	sub    $0x8,%esp
  802548:	ff 75 f4             	pushl  -0xc(%ebp)
  80254b:	6a 00                	push   $0x0
  80254d:	e8 5a eb ff ff       	call   8010ac <sys_page_unmap>
  802552:	83 c4 10             	add    $0x10,%esp
  802555:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  802557:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80255a:	5b                   	pop    %ebx
  80255b:	5e                   	pop    %esi
  80255c:	5d                   	pop    %ebp
  80255d:	c3                   	ret    

0080255e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80255e:	55                   	push   %ebp
  80255f:	89 e5                	mov    %esp,%ebp
  802561:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802564:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802567:	50                   	push   %eax
  802568:	ff 75 08             	pushl  0x8(%ebp)
  80256b:	e8 1e f0 ff ff       	call   80158e <fd_lookup>
  802570:	83 c4 10             	add    $0x10,%esp
  802573:	85 c0                	test   %eax,%eax
  802575:	78 18                	js     80258f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802577:	83 ec 0c             	sub    $0xc,%esp
  80257a:	ff 75 f4             	pushl  -0xc(%ebp)
  80257d:	e8 81 ef ff ff       	call   801503 <fd2data>
	return _pipeisclosed(fd, p);
  802582:	89 c2                	mov    %eax,%edx
  802584:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802587:	e8 17 fd ff ff       	call   8022a3 <_pipeisclosed>
  80258c:	83 c4 10             	add    $0x10,%esp
}
  80258f:	c9                   	leave  
  802590:	c3                   	ret    

00802591 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802591:	55                   	push   %ebp
  802592:	89 e5                	mov    %esp,%ebp
  802594:	56                   	push   %esi
  802595:	53                   	push   %ebx
  802596:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802599:	85 f6                	test   %esi,%esi
  80259b:	75 16                	jne    8025b3 <wait+0x22>
  80259d:	68 9f 31 80 00       	push   $0x80319f
  8025a2:	68 b5 30 80 00       	push   $0x8030b5
  8025a7:	6a 09                	push   $0x9
  8025a9:	68 aa 31 80 00       	push   $0x8031aa
  8025ae:	e8 47 df ff ff       	call   8004fa <_panic>
	e = &envs[ENVX(envid)];
  8025b3:	89 f3                	mov    %esi,%ebx
  8025b5:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8025bb:	8d 14 9d 00 00 00 00 	lea    0x0(,%ebx,4),%edx
  8025c2:	89 d8                	mov    %ebx,%eax
  8025c4:	c1 e0 07             	shl    $0x7,%eax
  8025c7:	29 d0                	sub    %edx,%eax
  8025c9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8025ce:	8b 40 48             	mov    0x48(%eax),%eax
  8025d1:	39 c6                	cmp    %eax,%esi
  8025d3:	75 31                	jne    802606 <wait+0x75>
  8025d5:	89 d8                	mov    %ebx,%eax
  8025d7:	c1 e0 07             	shl    $0x7,%eax
  8025da:	29 d0                	sub    %edx,%eax
  8025dc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8025e1:	8b 40 54             	mov    0x54(%eax),%eax
  8025e4:	85 c0                	test   %eax,%eax
  8025e6:	74 1e                	je     802606 <wait+0x75>
  8025e8:	c1 e3 07             	shl    $0x7,%ebx
  8025eb:	29 d3                	sub    %edx,%ebx
  8025ed:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
		sys_yield();
  8025f3:	e8 10 ea ff ff       	call   801008 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8025f8:	8b 43 48             	mov    0x48(%ebx),%eax
  8025fb:	39 c6                	cmp    %eax,%esi
  8025fd:	75 07                	jne    802606 <wait+0x75>
  8025ff:	8b 43 54             	mov    0x54(%ebx),%eax
  802602:	85 c0                	test   %eax,%eax
  802604:	75 ed                	jne    8025f3 <wait+0x62>
		sys_yield();
}
  802606:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802609:	5b                   	pop    %ebx
  80260a:	5e                   	pop    %esi
  80260b:	5d                   	pop    %ebp
  80260c:	c3                   	ret    

0080260d <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80260d:	55                   	push   %ebp
  80260e:	89 e5                	mov    %esp,%ebp
  802610:	53                   	push   %ebx
  802611:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  802614:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  80261b:	75 5b                	jne    802678 <set_pgfault_handler+0x6b>
		// First time through!
		// LAB 4: Your code here.
		void *va = (void *)(UXSTACKTOP - PGSIZE);
		envid_t eid = sys_getenvid();
  80261d:	e8 c7 e9 ff ff       	call   800fe9 <sys_getenvid>
  802622:	89 c3                	mov    %eax,%ebx
		r = sys_page_alloc(eid,va,PTE_P | PTE_U | PTE_W);
  802624:	83 ec 04             	sub    $0x4,%esp
  802627:	6a 07                	push   $0x7
  802629:	68 00 f0 bf ee       	push   $0xeebff000
  80262e:	50                   	push   %eax
  80262f:	e8 f3 e9 ff ff       	call   801027 <sys_page_alloc>
		if(r<0) panic("set_pgfault_handler\n");
  802634:	83 c4 10             	add    $0x10,%esp
  802637:	85 c0                	test   %eax,%eax
  802639:	79 14                	jns    80264f <set_pgfault_handler+0x42>
  80263b:	83 ec 04             	sub    $0x4,%esp
  80263e:	68 b5 31 80 00       	push   $0x8031b5
  802643:	6a 23                	push   $0x23
  802645:	68 ca 31 80 00       	push   $0x8031ca
  80264a:	e8 ab de ff ff       	call   8004fa <_panic>
		r = sys_env_set_pgfault_upcall(eid,_pgfault_upcall);
  80264f:	83 ec 08             	sub    $0x8,%esp
  802652:	68 85 26 80 00       	push   $0x802685
  802657:	53                   	push   %ebx
  802658:	e8 15 eb ff ff       	call   801172 <sys_env_set_pgfault_upcall>
		if(r<0) panic("set_pgfault_handler\n");
  80265d:	83 c4 10             	add    $0x10,%esp
  802660:	85 c0                	test   %eax,%eax
  802662:	79 14                	jns    802678 <set_pgfault_handler+0x6b>
  802664:	83 ec 04             	sub    $0x4,%esp
  802667:	68 b5 31 80 00       	push   $0x8031b5
  80266c:	6a 25                	push   $0x25
  80266e:	68 ca 31 80 00       	push   $0x8031ca
  802673:	e8 82 de ff ff       	call   8004fa <_panic>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802678:	8b 45 08             	mov    0x8(%ebp),%eax
  80267b:	a3 00 70 80 00       	mov    %eax,0x807000
}
  802680:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802683:	c9                   	leave  
  802684:	c3                   	ret    

00802685 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802685:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802686:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  80268b:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80268d:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp,%ebx
  802690:	89 e3                	mov    %esp,%ebx
	movl 40(%esp),%eax 	// esp from utf_fault_va to utf_regs(end)
  802692:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp),%esp 	// 
  802696:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax
  80269a:	50                   	push   %eax
 
 
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx,%esp
  80269b:	89 dc                	mov    %ebx,%esp
	subl $4,48(%esp)
  80269d:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	popl %eax
  8026a2:	58                   	pop    %eax
	popl %eax
  8026a3:	58                   	pop    %eax
	popal
  8026a4:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4,%esp
  8026a5:	83 c4 04             	add    $0x4,%esp
	popfl
  8026a8:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8026a9:	5c                   	pop    %esp
 
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8026aa:	c3                   	ret    

008026ab <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8026ab:	55                   	push   %ebp
  8026ac:	89 e5                	mov    %esp,%ebp
  8026ae:	56                   	push   %esi
  8026af:	53                   	push   %ebx
  8026b0:	8b 75 08             	mov    0x8(%ebp),%esi
  8026b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8026b6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");
	int r;
    if (pg != NULL) {
  8026b9:	85 c0                	test   %eax,%eax
  8026bb:	74 0e                	je     8026cb <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  8026bd:	83 ec 0c             	sub    $0xc,%esp
  8026c0:	50                   	push   %eax
  8026c1:	e8 11 eb ff ff       	call   8011d7 <sys_ipc_recv>
  8026c6:	83 c4 10             	add    $0x10,%esp
  8026c9:	eb 10                	jmp    8026db <ipc_recv+0x30>
    } else {
        r = sys_ipc_recv((void *) UTOP);
  8026cb:	83 ec 0c             	sub    $0xc,%esp
  8026ce:	68 00 00 c0 ee       	push   $0xeec00000
  8026d3:	e8 ff ea ff ff       	call   8011d7 <sys_ipc_recv>
  8026d8:	83 c4 10             	add    $0x10,%esp
    }
    if (r < 0) {
  8026db:	85 c0                	test   %eax,%eax
  8026dd:	79 16                	jns    8026f5 <ipc_recv+0x4a>
        // failed
        if (from_env_store != NULL) *from_env_store = 0;
  8026df:	85 f6                	test   %esi,%esi
  8026e1:	74 06                	je     8026e9 <ipc_recv+0x3e>
  8026e3:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL) *perm_store = 0;
  8026e9:	85 db                	test   %ebx,%ebx
  8026eb:	74 2c                	je     802719 <ipc_recv+0x6e>
  8026ed:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8026f3:	eb 24                	jmp    802719 <ipc_recv+0x6e>
        return r;
    } else {
        if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  8026f5:	85 f6                	test   %esi,%esi
  8026f7:	74 0a                	je     802703 <ipc_recv+0x58>
  8026f9:	a1 04 50 80 00       	mov    0x805004,%eax
  8026fe:	8b 40 74             	mov    0x74(%eax),%eax
  802701:	89 06                	mov    %eax,(%esi)
        if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  802703:	85 db                	test   %ebx,%ebx
  802705:	74 0a                	je     802711 <ipc_recv+0x66>
  802707:	a1 04 50 80 00       	mov    0x805004,%eax
  80270c:	8b 40 78             	mov    0x78(%eax),%eax
  80270f:	89 03                	mov    %eax,(%ebx)
        return thisenv->env_ipc_value;
  802711:	a1 04 50 80 00       	mov    0x805004,%eax
  802716:	8b 40 70             	mov    0x70(%eax),%eax
    }
 
	return 0;
}
  802719:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80271c:	5b                   	pop    %ebx
  80271d:	5e                   	pop    %esi
  80271e:	5d                   	pop    %ebp
  80271f:	c3                   	ret    

00802720 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802720:	55                   	push   %ebp
  802721:	89 e5                	mov    %esp,%ebp
  802723:	57                   	push   %edi
  802724:	56                   	push   %esi
  802725:	53                   	push   %ebx
  802726:	83 ec 0c             	sub    $0xc,%esp
  802729:	8b 75 10             	mov    0x10(%ebp),%esi
  80272c:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;
    if (pg == NULL) pg = (void *)UTOP;
  80272f:	85 f6                	test   %esi,%esi
  802731:	75 05                	jne    802738 <ipc_send+0x18>
  802733:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
  802738:	57                   	push   %edi
  802739:	56                   	push   %esi
  80273a:	ff 75 0c             	pushl  0xc(%ebp)
  80273d:	ff 75 08             	pushl  0x8(%ebp)
  802740:	e8 6f ea ff ff       	call   8011b4 <sys_ipc_try_send>
  802745:	89 c3                	mov    %eax,%ebx
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
  802747:	83 c4 10             	add    $0x10,%esp
  80274a:	85 c0                	test   %eax,%eax
  80274c:	79 17                	jns    802765 <ipc_send+0x45>
  80274e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802751:	74 1d                	je     802770 <ipc_send+0x50>
  802753:	50                   	push   %eax
  802754:	68 d8 31 80 00       	push   $0x8031d8
  802759:	6a 40                	push   $0x40
  80275b:	68 ec 31 80 00       	push   $0x8031ec
  802760:	e8 95 dd ff ff       	call   8004fa <_panic>
        sys_yield();
  802765:	e8 9e e8 ff ff       	call   801008 <sys_yield>
    } while (r != 0);
  80276a:	85 db                	test   %ebx,%ebx
  80276c:	75 ca                	jne    802738 <ipc_send+0x18>
  80276e:	eb 07                	jmp    802777 <ipc_send+0x57>
	int r;
    if (pg == NULL) pg = (void *)UTOP;
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
        sys_yield();
  802770:	e8 93 e8 ff ff       	call   801008 <sys_yield>
  802775:	eb c1                	jmp    802738 <ipc_send+0x18>
    } while (r != 0);
}
  802777:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80277a:	5b                   	pop    %ebx
  80277b:	5e                   	pop    %esi
  80277c:	5f                   	pop    %edi
  80277d:	5d                   	pop    %ebp
  80277e:	c3                   	ret    

0080277f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80277f:	55                   	push   %ebp
  802780:	89 e5                	mov    %esp,%ebp
  802782:	53                   	push   %ebx
  802783:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802786:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  80278b:	39 c1                	cmp    %eax,%ecx
  80278d:	74 21                	je     8027b0 <ipc_find_env+0x31>
  80278f:	ba 01 00 00 00       	mov    $0x1,%edx
  802794:	8d 1c 95 00 00 00 00 	lea    0x0(,%edx,4),%ebx
  80279b:	89 d0                	mov    %edx,%eax
  80279d:	c1 e0 07             	shl    $0x7,%eax
  8027a0:	29 d8                	sub    %ebx,%eax
  8027a2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8027a7:	8b 40 50             	mov    0x50(%eax),%eax
  8027aa:	39 c8                	cmp    %ecx,%eax
  8027ac:	75 1b                	jne    8027c9 <ipc_find_env+0x4a>
  8027ae:	eb 05                	jmp    8027b5 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8027b0:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_type == type)
			return envs[i].env_id;
  8027b5:	8d 04 95 00 00 00 00 	lea    0x0(,%edx,4),%eax
  8027bc:	c1 e2 07             	shl    $0x7,%edx
  8027bf:	29 c2                	sub    %eax,%edx
  8027c1:	8b 82 48 00 c0 ee    	mov    -0x113fffb8(%edx),%eax
  8027c7:	eb 0e                	jmp    8027d7 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8027c9:	42                   	inc    %edx
  8027ca:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  8027d0:	75 c2                	jne    802794 <ipc_find_env+0x15>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8027d2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8027d7:	5b                   	pop    %ebx
  8027d8:	5d                   	pop    %ebp
  8027d9:	c3                   	ret    

008027da <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8027da:	55                   	push   %ebp
  8027db:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8027dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8027e0:	c1 e8 16             	shr    $0x16,%eax
  8027e3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8027ea:	a8 01                	test   $0x1,%al
  8027ec:	74 21                	je     80280f <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8027ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8027f1:	c1 e8 0c             	shr    $0xc,%eax
  8027f4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8027fb:	a8 01                	test   $0x1,%al
  8027fd:	74 17                	je     802816 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8027ff:	c1 e8 0c             	shr    $0xc,%eax
  802802:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802809:	ef 
  80280a:	0f b7 c0             	movzwl %ax,%eax
  80280d:	eb 0c                	jmp    80281b <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  80280f:	b8 00 00 00 00       	mov    $0x0,%eax
  802814:	eb 05                	jmp    80281b <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802816:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  80281b:	5d                   	pop    %ebp
  80281c:	c3                   	ret    
  80281d:	66 90                	xchg   %ax,%ax
  80281f:	90                   	nop

00802820 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802820:	55                   	push   %ebp
  802821:	57                   	push   %edi
  802822:	56                   	push   %esi
  802823:	53                   	push   %ebx
  802824:	83 ec 1c             	sub    $0x1c,%esp
  802827:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80282b:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  80282f:	8b 7c 24 38          	mov    0x38(%esp),%edi
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802833:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802837:	89 ca                	mov    %ecx,%edx
  const DWunion dd = {.ll = d};
  802839:	89 f8                	mov    %edi,%eax
  80283b:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80283f:	85 f6                	test   %esi,%esi
  802841:	75 2d                	jne    802870 <__udivdi3+0x50>
    {
      if (d0 > n1)
  802843:	39 cf                	cmp    %ecx,%edi
  802845:	77 65                	ja     8028ac <__udivdi3+0x8c>
  802847:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802849:	85 ff                	test   %edi,%edi
  80284b:	75 0b                	jne    802858 <__udivdi3+0x38>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80284d:	b8 01 00 00 00       	mov    $0x1,%eax
  802852:	31 d2                	xor    %edx,%edx
  802854:	f7 f7                	div    %edi
  802856:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802858:	31 d2                	xor    %edx,%edx
  80285a:	89 c8                	mov    %ecx,%eax
  80285c:	f7 f5                	div    %ebp
  80285e:	89 c1                	mov    %eax,%ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802860:	89 d8                	mov    %ebx,%eax
  802862:	f7 f5                	div    %ebp
  802864:	89 cf                	mov    %ecx,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802866:	89 fa                	mov    %edi,%edx
  802868:	83 c4 1c             	add    $0x1c,%esp
  80286b:	5b                   	pop    %ebx
  80286c:	5e                   	pop    %esi
  80286d:	5f                   	pop    %edi
  80286e:	5d                   	pop    %ebp
  80286f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802870:	39 ce                	cmp    %ecx,%esi
  802872:	77 28                	ja     80289c <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802874:	0f bd fe             	bsr    %esi,%edi
	  if (bm == 0)
  802877:	83 f7 1f             	xor    $0x1f,%edi
  80287a:	75 40                	jne    8028bc <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80287c:	39 ce                	cmp    %ecx,%esi
  80287e:	72 0a                	jb     80288a <__udivdi3+0x6a>
  802880:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802884:	0f 87 9e 00 00 00    	ja     802928 <__udivdi3+0x108>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80288a:	b8 01 00 00 00       	mov    $0x1,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80288f:	89 fa                	mov    %edi,%edx
  802891:	83 c4 1c             	add    $0x1c,%esp
  802894:	5b                   	pop    %ebx
  802895:	5e                   	pop    %esi
  802896:	5f                   	pop    %edi
  802897:	5d                   	pop    %ebp
  802898:	c3                   	ret    
  802899:	8d 76 00             	lea    0x0(%esi),%esi
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80289c:	31 ff                	xor    %edi,%edi
  80289e:	31 c0                	xor    %eax,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8028a0:	89 fa                	mov    %edi,%edx
  8028a2:	83 c4 1c             	add    $0x1c,%esp
  8028a5:	5b                   	pop    %ebx
  8028a6:	5e                   	pop    %esi
  8028a7:	5f                   	pop    %edi
  8028a8:	5d                   	pop    %ebp
  8028a9:	c3                   	ret    
  8028aa:	66 90                	xchg   %ax,%ax
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8028ac:	89 d8                	mov    %ebx,%eax
  8028ae:	f7 f7                	div    %edi
  8028b0:	31 ff                	xor    %edi,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8028b2:	89 fa                	mov    %edi,%edx
  8028b4:	83 c4 1c             	add    $0x1c,%esp
  8028b7:	5b                   	pop    %ebx
  8028b8:	5e                   	pop    %esi
  8028b9:	5f                   	pop    %edi
  8028ba:	5d                   	pop    %ebp
  8028bb:	c3                   	ret    
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8028bc:	bd 20 00 00 00       	mov    $0x20,%ebp
  8028c1:	89 eb                	mov    %ebp,%ebx
  8028c3:	29 fb                	sub    %edi,%ebx

	      d1 = (d1 << bm) | (d0 >> b);
  8028c5:	89 f9                	mov    %edi,%ecx
  8028c7:	d3 e6                	shl    %cl,%esi
  8028c9:	89 c5                	mov    %eax,%ebp
  8028cb:	88 d9                	mov    %bl,%cl
  8028cd:	d3 ed                	shr    %cl,%ebp
  8028cf:	89 e9                	mov    %ebp,%ecx
  8028d1:	09 f1                	or     %esi,%ecx
  8028d3:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
	      d0 = d0 << bm;
  8028d7:	89 f9                	mov    %edi,%ecx
  8028d9:	d3 e0                	shl    %cl,%eax
  8028db:	89 c5                	mov    %eax,%ebp
	      n2 = n1 >> b;
  8028dd:	89 d6                	mov    %edx,%esi
  8028df:	88 d9                	mov    %bl,%cl
  8028e1:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
  8028e3:	89 f9                	mov    %edi,%ecx
  8028e5:	d3 e2                	shl    %cl,%edx
  8028e7:	8b 44 24 08          	mov    0x8(%esp),%eax
  8028eb:	88 d9                	mov    %bl,%cl
  8028ed:	d3 e8                	shr    %cl,%eax
  8028ef:	09 c2                	or     %eax,%edx
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8028f1:	89 d0                	mov    %edx,%eax
  8028f3:	89 f2                	mov    %esi,%edx
  8028f5:	f7 74 24 0c          	divl   0xc(%esp)
  8028f9:	89 d6                	mov    %edx,%esi
  8028fb:	89 c3                	mov    %eax,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  8028fd:	f7 e5                	mul    %ebp

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8028ff:	39 d6                	cmp    %edx,%esi
  802901:	72 19                	jb     80291c <__udivdi3+0xfc>
  802903:	74 0b                	je     802910 <__udivdi3+0xf0>
  802905:	89 d8                	mov    %ebx,%eax
  802907:	31 ff                	xor    %edi,%edi
  802909:	e9 58 ff ff ff       	jmp    802866 <__udivdi3+0x46>
  80290e:	66 90                	xchg   %ax,%ax
  802910:	8b 54 24 08          	mov    0x8(%esp),%edx
  802914:	89 f9                	mov    %edi,%ecx
  802916:	d3 e2                	shl    %cl,%edx
  802918:	39 c2                	cmp    %eax,%edx
  80291a:	73 e9                	jae    802905 <__udivdi3+0xe5>
  80291c:	8d 43 ff             	lea    -0x1(%ebx),%eax
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80291f:	31 ff                	xor    %edi,%edi
  802921:	e9 40 ff ff ff       	jmp    802866 <__udivdi3+0x46>
  802926:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802928:	31 c0                	xor    %eax,%eax
  80292a:	e9 37 ff ff ff       	jmp    802866 <__udivdi3+0x46>
  80292f:	90                   	nop

00802930 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802930:	55                   	push   %ebp
  802931:	57                   	push   %edi
  802932:	56                   	push   %esi
  802933:	53                   	push   %ebx
  802934:	83 ec 1c             	sub    $0x1c,%esp
  802937:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80293b:	8b 74 24 34          	mov    0x34(%esp),%esi
  80293f:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802943:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  802947:	89 44 24 0c          	mov    %eax,0xc(%esp)
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80294b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80294f:	89 f3                	mov    %esi,%ebx
  const DWunion dd = {.ll = d};
  802951:	89 fa                	mov    %edi,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802953:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  n1 = nn.s.high;
  802957:	89 34 24             	mov    %esi,(%esp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80295a:	85 c0                	test   %eax,%eax
  80295c:	75 1a                	jne    802978 <__umoddi3+0x48>
    {
      if (d0 > n1)
  80295e:	39 f7                	cmp    %esi,%edi
  802960:	0f 86 a2 00 00 00    	jbe    802a08 <__umoddi3+0xd8>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802966:	89 c8                	mov    %ecx,%eax
  802968:	89 f2                	mov    %esi,%edx
  80296a:	f7 f7                	div    %edi
  80296c:	89 d0                	mov    %edx,%eax

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  80296e:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802970:	83 c4 1c             	add    $0x1c,%esp
  802973:	5b                   	pop    %ebx
  802974:	5e                   	pop    %esi
  802975:	5f                   	pop    %edi
  802976:	5d                   	pop    %ebp
  802977:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802978:	39 f0                	cmp    %esi,%eax
  80297a:	0f 87 ac 00 00 00    	ja     802a2c <__umoddi3+0xfc>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802980:	0f bd e8             	bsr    %eax,%ebp
	  if (bm == 0)
  802983:	83 f5 1f             	xor    $0x1f,%ebp
  802986:	0f 84 ac 00 00 00    	je     802a38 <__umoddi3+0x108>
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80298c:	bf 20 00 00 00       	mov    $0x20,%edi
  802991:	29 ef                	sub    %ebp,%edi
  802993:	89 fe                	mov    %edi,%esi
  802995:	89 7c 24 0c          	mov    %edi,0xc(%esp)

	      d1 = (d1 << bm) | (d0 >> b);
  802999:	89 e9                	mov    %ebp,%ecx
  80299b:	d3 e0                	shl    %cl,%eax
  80299d:	89 d7                	mov    %edx,%edi
  80299f:	89 f1                	mov    %esi,%ecx
  8029a1:	d3 ef                	shr    %cl,%edi
  8029a3:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  8029a5:	89 e9                	mov    %ebp,%ecx
  8029a7:	d3 e2                	shl    %cl,%edx
  8029a9:	89 14 24             	mov    %edx,(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8029ac:	89 d8                	mov    %ebx,%eax
  8029ae:	d3 e0                	shl    %cl,%eax
  8029b0:	89 c2                	mov    %eax,%edx
	      n0 = n0 << bm;
  8029b2:	8b 44 24 08          	mov    0x8(%esp),%eax
  8029b6:	d3 e0                	shl    %cl,%eax
  8029b8:	89 44 24 04          	mov    %eax,0x4(%esp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8029bc:	8b 44 24 08          	mov    0x8(%esp),%eax
  8029c0:	89 f1                	mov    %esi,%ecx
  8029c2:	d3 e8                	shr    %cl,%eax
  8029c4:	09 d0                	or     %edx,%eax
  8029c6:	d3 eb                	shr    %cl,%ebx
  8029c8:	89 da                	mov    %ebx,%edx
  8029ca:	f7 f7                	div    %edi
  8029cc:	89 d3                	mov    %edx,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  8029ce:	f7 24 24             	mull   (%esp)
  8029d1:	89 c6                	mov    %eax,%esi
  8029d3:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8029d5:	39 d3                	cmp    %edx,%ebx
  8029d7:	0f 82 87 00 00 00    	jb     802a64 <__umoddi3+0x134>
  8029dd:	0f 84 91 00 00 00    	je     802a74 <__umoddi3+0x144>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8029e3:	8b 54 24 04          	mov    0x4(%esp),%edx
  8029e7:	29 f2                	sub    %esi,%edx
  8029e9:	19 cb                	sbb    %ecx,%ebx
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8029eb:	89 d8                	mov    %ebx,%eax
  8029ed:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  8029f1:	d3 e0                	shl    %cl,%eax
  8029f3:	89 e9                	mov    %ebp,%ecx
  8029f5:	d3 ea                	shr    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8029f7:	09 d0                	or     %edx,%eax
  8029f9:	89 e9                	mov    %ebp,%ecx
  8029fb:	d3 eb                	shr    %cl,%ebx
  8029fd:	89 da                	mov    %ebx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8029ff:	83 c4 1c             	add    $0x1c,%esp
  802a02:	5b                   	pop    %ebx
  802a03:	5e                   	pop    %esi
  802a04:	5f                   	pop    %edi
  802a05:	5d                   	pop    %ebp
  802a06:	c3                   	ret    
  802a07:	90                   	nop
  802a08:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802a0a:	85 ff                	test   %edi,%edi
  802a0c:	75 0b                	jne    802a19 <__umoddi3+0xe9>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802a0e:	b8 01 00 00 00       	mov    $0x1,%eax
  802a13:	31 d2                	xor    %edx,%edx
  802a15:	f7 f7                	div    %edi
  802a17:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802a19:	89 f0                	mov    %esi,%eax
  802a1b:	31 d2                	xor    %edx,%edx
  802a1d:	f7 f5                	div    %ebp
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802a1f:	89 c8                	mov    %ecx,%eax
  802a21:	f7 f5                	div    %ebp
  802a23:	89 d0                	mov    %edx,%eax
  802a25:	e9 44 ff ff ff       	jmp    80296e <__umoddi3+0x3e>
  802a2a:	66 90                	xchg   %ax,%ax
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802a2c:	89 c8                	mov    %ecx,%eax
  802a2e:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802a30:	83 c4 1c             	add    $0x1c,%esp
  802a33:	5b                   	pop    %ebx
  802a34:	5e                   	pop    %esi
  802a35:	5f                   	pop    %edi
  802a36:	5d                   	pop    %ebp
  802a37:	c3                   	ret    

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802a38:	3b 04 24             	cmp    (%esp),%eax
  802a3b:	72 06                	jb     802a43 <__umoddi3+0x113>
  802a3d:	3b 7c 24 04          	cmp    0x4(%esp),%edi
  802a41:	77 0f                	ja     802a52 <__umoddi3+0x122>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802a43:	89 f2                	mov    %esi,%edx
  802a45:	29 f9                	sub    %edi,%ecx
  802a47:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  802a4b:	89 14 24             	mov    %edx,(%esp)
  802a4e:	89 4c 24 04          	mov    %ecx,0x4(%esp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802a52:	8b 44 24 04          	mov    0x4(%esp),%eax
  802a56:	8b 14 24             	mov    (%esp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802a59:	83 c4 1c             	add    $0x1c,%esp
  802a5c:	5b                   	pop    %ebx
  802a5d:	5e                   	pop    %esi
  802a5e:	5f                   	pop    %edi
  802a5f:	5d                   	pop    %ebp
  802a60:	c3                   	ret    
  802a61:	8d 76 00             	lea    0x0(%esi),%esi
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802a64:	2b 04 24             	sub    (%esp),%eax
  802a67:	19 fa                	sbb    %edi,%edx
  802a69:	89 d1                	mov    %edx,%ecx
  802a6b:	89 c6                	mov    %eax,%esi
  802a6d:	e9 71 ff ff ff       	jmp    8029e3 <__umoddi3+0xb3>
  802a72:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802a74:	39 44 24 04          	cmp    %eax,0x4(%esp)
  802a78:	72 ea                	jb     802a64 <__umoddi3+0x134>
  802a7a:	89 d9                	mov    %ebx,%ecx
  802a7c:	e9 62 ff ff ff       	jmp    8029e3 <__umoddi3+0xb3>
