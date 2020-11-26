
obj/user/init.debug:     file format elf32-i386


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
  80002c:	e8 82 03 00 00       	call   8003b3 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <sum>:

char bss[6000];

int
sum(const char *s, int n)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 75 08             	mov    0x8(%ebp),%esi
  80003b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i, tot = 0;
	for (i = 0; i < n; i++)
  80003e:	85 db                	test   %ebx,%ebx
  800040:	7e 1a                	jle    80005c <sum+0x29>
  800042:	b8 00 00 00 00       	mov    $0x0,%eax
  800047:	ba 00 00 00 00       	mov    $0x0,%edx
		tot ^= i * s[i];
  80004c:	0f be 0c 16          	movsbl (%esi,%edx,1),%ecx
  800050:	0f af ca             	imul   %edx,%ecx
  800053:	31 c8                	xor    %ecx,%eax

int
sum(const char *s, int n)
{
	int i, tot = 0;
	for (i = 0; i < n; i++)
  800055:	42                   	inc    %edx
  800056:	39 d3                	cmp    %edx,%ebx
  800058:	75 f2                	jne    80004c <sum+0x19>
  80005a:	eb 05                	jmp    800061 <sum+0x2e>
char bss[6000];

int
sum(const char *s, int n)
{
	int i, tot = 0;
  80005c:	b8 00 00 00 00       	mov    $0x0,%eax
	for (i = 0; i < n; i++)
		tot ^= i * s[i];
	return tot;
}
  800061:	5b                   	pop    %ebx
  800062:	5e                   	pop    %esi
  800063:	5d                   	pop    %ebp
  800064:	c3                   	ret    

00800065 <umain>:

void
umain(int argc, char **argv)
{
  800065:	55                   	push   %ebp
  800066:	89 e5                	mov    %esp,%ebp
  800068:	57                   	push   %edi
  800069:	56                   	push   %esi
  80006a:	53                   	push   %ebx
  80006b:	81 ec 18 01 00 00    	sub    $0x118,%esp
  800071:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i, r, x, want;
	char args[256];

	cprintf("init: running\n");
  800074:	68 40 26 80 00       	push   $0x802640
  800079:	e8 76 04 00 00       	call   8004f4 <cprintf>

	want = 0xf989e;
	if ((x = sum((char*)&data, sizeof data)) != want)
  80007e:	83 c4 08             	add    $0x8,%esp
  800081:	68 70 17 00 00       	push   $0x1770
  800086:	68 00 30 80 00       	push   $0x803000
  80008b:	e8 a3 ff ff ff       	call   800033 <sum>
  800090:	83 c4 10             	add    $0x10,%esp
  800093:	3d 9e 98 0f 00       	cmp    $0xf989e,%eax
  800098:	74 18                	je     8000b2 <umain+0x4d>
		cprintf("init: data is not initialized: got sum %08x wanted %08x\n",
  80009a:	83 ec 04             	sub    $0x4,%esp
  80009d:	68 9e 98 0f 00       	push   $0xf989e
  8000a2:	50                   	push   %eax
  8000a3:	68 08 27 80 00       	push   $0x802708
  8000a8:	e8 47 04 00 00       	call   8004f4 <cprintf>
  8000ad:	83 c4 10             	add    $0x10,%esp
  8000b0:	eb 10                	jmp    8000c2 <umain+0x5d>
			x, want);
	else
		cprintf("init: data seems okay\n");
  8000b2:	83 ec 0c             	sub    $0xc,%esp
  8000b5:	68 4f 26 80 00       	push   $0x80264f
  8000ba:	e8 35 04 00 00       	call   8004f4 <cprintf>
  8000bf:	83 c4 10             	add    $0x10,%esp
	if ((x = sum(bss, sizeof bss)) != 0)
  8000c2:	83 ec 08             	sub    $0x8,%esp
  8000c5:	68 70 17 00 00       	push   $0x1770
  8000ca:	68 20 50 80 00       	push   $0x805020
  8000cf:	e8 5f ff ff ff       	call   800033 <sum>
  8000d4:	83 c4 10             	add    $0x10,%esp
  8000d7:	85 c0                	test   %eax,%eax
  8000d9:	74 13                	je     8000ee <umain+0x89>
		cprintf("bss is not initialized: wanted sum 0 got %08x\n", x);
  8000db:	83 ec 08             	sub    $0x8,%esp
  8000de:	50                   	push   %eax
  8000df:	68 44 27 80 00       	push   $0x802744
  8000e4:	e8 0b 04 00 00       	call   8004f4 <cprintf>
  8000e9:	83 c4 10             	add    $0x10,%esp
  8000ec:	eb 10                	jmp    8000fe <umain+0x99>
	else
		cprintf("init: bss seems okay\n");
  8000ee:	83 ec 0c             	sub    $0xc,%esp
  8000f1:	68 66 26 80 00       	push   $0x802666
  8000f6:	e8 f9 03 00 00       	call   8004f4 <cprintf>
  8000fb:	83 c4 10             	add    $0x10,%esp

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
  8000fe:	83 ec 08             	sub    $0x8,%esp
  800101:	68 7c 26 80 00       	push   $0x80267c
  800106:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80010c:	50                   	push   %eax
  80010d:	e8 e2 09 00 00       	call   800af4 <strcat>
	for (i = 0; i < argc; i++) {
  800112:	83 c4 10             	add    $0x10,%esp
  800115:	85 ff                	test   %edi,%edi
  800117:	7e 3e                	jle    800157 <umain+0xf2>
  800119:	bb 00 00 00 00       	mov    $0x0,%ebx
		strcat(args, " '");
  80011e:	8d b5 e8 fe ff ff    	lea    -0x118(%ebp),%esi
  800124:	83 ec 08             	sub    $0x8,%esp
  800127:	68 88 26 80 00       	push   $0x802688
  80012c:	56                   	push   %esi
  80012d:	e8 c2 09 00 00       	call   800af4 <strcat>
		strcat(args, argv[i]);
  800132:	83 c4 08             	add    $0x8,%esp
  800135:	8b 45 0c             	mov    0xc(%ebp),%eax
  800138:	ff 34 98             	pushl  (%eax,%ebx,4)
  80013b:	56                   	push   %esi
  80013c:	e8 b3 09 00 00       	call   800af4 <strcat>
		strcat(args, "'");
  800141:	83 c4 08             	add    $0x8,%esp
  800144:	68 89 26 80 00       	push   $0x802689
  800149:	56                   	push   %esi
  80014a:	e8 a5 09 00 00       	call   800af4 <strcat>
	else
		cprintf("init: bss seems okay\n");

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
	for (i = 0; i < argc; i++) {
  80014f:	43                   	inc    %ebx
  800150:	83 c4 10             	add    $0x10,%esp
  800153:	39 df                	cmp    %ebx,%edi
  800155:	75 cd                	jne    800124 <umain+0xbf>
		strcat(args, " '");
		strcat(args, argv[i]);
		strcat(args, "'");
	}
	cprintf("%s\n", args);
  800157:	83 ec 08             	sub    $0x8,%esp
  80015a:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  800160:	50                   	push   %eax
  800161:	68 8b 26 80 00       	push   $0x80268b
  800166:	e8 89 03 00 00       	call   8004f4 <cprintf>

	cprintf("init: running sh\n");
  80016b:	c7 04 24 8f 26 80 00 	movl   $0x80268f,(%esp)
  800172:	e8 7d 03 00 00       	call   8004f4 <cprintf>

	// being run directly from kernel, so no file descriptors open yet
	close(0);
  800177:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80017e:	e8 9b 11 00 00       	call   80131e <close>
	if ((r = opencons()) < 0)
  800183:	e8 d9 01 00 00       	call   800361 <opencons>
  800188:	83 c4 10             	add    $0x10,%esp
  80018b:	85 c0                	test   %eax,%eax
  80018d:	79 12                	jns    8001a1 <umain+0x13c>
		panic("opencons: %e", r);
  80018f:	50                   	push   %eax
  800190:	68 a1 26 80 00       	push   $0x8026a1
  800195:	6a 37                	push   $0x37
  800197:	68 ae 26 80 00       	push   $0x8026ae
  80019c:	e8 7b 02 00 00       	call   80041c <_panic>
	if (r != 0)
  8001a1:	85 c0                	test   %eax,%eax
  8001a3:	74 12                	je     8001b7 <umain+0x152>
		panic("first opencons used fd %d", r);
  8001a5:	50                   	push   %eax
  8001a6:	68 ba 26 80 00       	push   $0x8026ba
  8001ab:	6a 39                	push   $0x39
  8001ad:	68 ae 26 80 00       	push   $0x8026ae
  8001b2:	e8 65 02 00 00       	call   80041c <_panic>
	if ((r = dup(0, 1)) < 0)
  8001b7:	83 ec 08             	sub    $0x8,%esp
  8001ba:	6a 01                	push   $0x1
  8001bc:	6a 00                	push   $0x0
  8001be:	e8 a9 11 00 00       	call   80136c <dup>
  8001c3:	83 c4 10             	add    $0x10,%esp
  8001c6:	85 c0                	test   %eax,%eax
  8001c8:	79 12                	jns    8001dc <umain+0x177>
		panic("dup: %e", r);
  8001ca:	50                   	push   %eax
  8001cb:	68 d4 26 80 00       	push   $0x8026d4
  8001d0:	6a 3b                	push   $0x3b
  8001d2:	68 ae 26 80 00       	push   $0x8026ae
  8001d7:	e8 40 02 00 00       	call   80041c <_panic>
	while (1) {
		cprintf("init: starting sh\n");
  8001dc:	83 ec 0c             	sub    $0xc,%esp
  8001df:	68 dc 26 80 00       	push   $0x8026dc
  8001e4:	e8 0b 03 00 00       	call   8004f4 <cprintf>
		r = spawnl("/sh", "sh", (char*)0);
  8001e9:	83 c4 0c             	add    $0xc,%esp
  8001ec:	6a 00                	push   $0x0
  8001ee:	68 f0 26 80 00       	push   $0x8026f0
  8001f3:	68 ef 26 80 00       	push   $0x8026ef
  8001f8:	e8 e3 1b 00 00       	call   801de0 <spawnl>
		if (r < 0) {
  8001fd:	83 c4 10             	add    $0x10,%esp
  800200:	85 c0                	test   %eax,%eax
  800202:	79 13                	jns    800217 <umain+0x1b2>
			cprintf("init: spawn sh: %e\n", r);
  800204:	83 ec 08             	sub    $0x8,%esp
  800207:	50                   	push   %eax
  800208:	68 f3 26 80 00       	push   $0x8026f3
  80020d:	e8 e2 02 00 00       	call   8004f4 <cprintf>
			continue;
  800212:	83 c4 10             	add    $0x10,%esp
  800215:	eb c5                	jmp    8001dc <umain+0x177>
		}
		wait(r);
  800217:	83 ec 0c             	sub    $0xc,%esp
  80021a:	50                   	push   %eax
  80021b:	e8 b8 1f 00 00       	call   8021d8 <wait>
  800220:	83 c4 10             	add    $0x10,%esp
  800223:	eb b7                	jmp    8001dc <umain+0x177>

00800225 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800225:	55                   	push   %ebp
  800226:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800228:	b8 00 00 00 00       	mov    $0x0,%eax
  80022d:	5d                   	pop    %ebp
  80022e:	c3                   	ret    

0080022f <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80022f:	55                   	push   %ebp
  800230:	89 e5                	mov    %esp,%ebp
  800232:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800235:	68 73 27 80 00       	push   $0x802773
  80023a:	ff 75 0c             	pushl  0xc(%ebp)
  80023d:	e8 97 08 00 00       	call   800ad9 <strcpy>
	return 0;
}
  800242:	b8 00 00 00 00       	mov    $0x0,%eax
  800247:	c9                   	leave  
  800248:	c3                   	ret    

00800249 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800249:	55                   	push   %ebp
  80024a:	89 e5                	mov    %esp,%ebp
  80024c:	57                   	push   %edi
  80024d:	56                   	push   %esi
  80024e:	53                   	push   %ebx
  80024f:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800255:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800259:	74 45                	je     8002a0 <devcons_write+0x57>
  80025b:	b8 00 00 00 00       	mov    $0x0,%eax
  800260:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800265:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80026b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80026e:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  800270:	83 fb 7f             	cmp    $0x7f,%ebx
  800273:	76 05                	jbe    80027a <devcons_write+0x31>
			m = sizeof(buf) - 1;
  800275:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  80027a:	83 ec 04             	sub    $0x4,%esp
  80027d:	53                   	push   %ebx
  80027e:	03 45 0c             	add    0xc(%ebp),%eax
  800281:	50                   	push   %eax
  800282:	57                   	push   %edi
  800283:	e8 1e 0a 00 00       	call   800ca6 <memmove>
		sys_cputs(buf, m);
  800288:	83 c4 08             	add    $0x8,%esp
  80028b:	53                   	push   %ebx
  80028c:	57                   	push   %edi
  80028d:	e8 fb 0b 00 00       	call   800e8d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800292:	01 de                	add    %ebx,%esi
  800294:	89 f0                	mov    %esi,%eax
  800296:	83 c4 10             	add    $0x10,%esp
  800299:	3b 75 10             	cmp    0x10(%ebp),%esi
  80029c:	72 cd                	jb     80026b <devcons_write+0x22>
  80029e:	eb 05                	jmp    8002a5 <devcons_write+0x5c>
  8002a0:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8002a5:	89 f0                	mov    %esi,%eax
  8002a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002aa:	5b                   	pop    %ebx
  8002ab:	5e                   	pop    %esi
  8002ac:	5f                   	pop    %edi
  8002ad:	5d                   	pop    %ebp
  8002ae:	c3                   	ret    

008002af <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8002af:	55                   	push   %ebp
  8002b0:	89 e5                	mov    %esp,%ebp
  8002b2:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8002b5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8002b9:	75 07                	jne    8002c2 <devcons_read+0x13>
  8002bb:	eb 23                	jmp    8002e0 <devcons_read+0x31>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8002bd:	e8 68 0c 00 00       	call   800f2a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8002c2:	e8 e4 0b 00 00       	call   800eab <sys_cgetc>
  8002c7:	85 c0                	test   %eax,%eax
  8002c9:	74 f2                	je     8002bd <devcons_read+0xe>
		sys_yield();
	if (c < 0)
  8002cb:	85 c0                	test   %eax,%eax
  8002cd:	78 1d                	js     8002ec <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8002cf:	83 f8 04             	cmp    $0x4,%eax
  8002d2:	74 13                	je     8002e7 <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  8002d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002d7:	88 02                	mov    %al,(%edx)
	return 1;
  8002d9:	b8 01 00 00 00       	mov    $0x1,%eax
  8002de:	eb 0c                	jmp    8002ec <devcons_read+0x3d>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8002e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8002e5:	eb 05                	jmp    8002ec <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8002e7:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8002ec:	c9                   	leave  
  8002ed:	c3                   	ret    

008002ee <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8002ee:	55                   	push   %ebp
  8002ef:	89 e5                	mov    %esp,%ebp
  8002f1:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8002f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f7:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8002fa:	6a 01                	push   $0x1
  8002fc:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8002ff:	50                   	push   %eax
  800300:	e8 88 0b 00 00       	call   800e8d <sys_cputs>
}
  800305:	83 c4 10             	add    $0x10,%esp
  800308:	c9                   	leave  
  800309:	c3                   	ret    

0080030a <getchar>:

int
getchar(void)
{
  80030a:	55                   	push   %ebp
  80030b:	89 e5                	mov    %esp,%ebp
  80030d:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800310:	6a 01                	push   $0x1
  800312:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800315:	50                   	push   %eax
  800316:	6a 00                	push   $0x0
  800318:	e8 39 11 00 00       	call   801456 <read>
	if (r < 0)
  80031d:	83 c4 10             	add    $0x10,%esp
  800320:	85 c0                	test   %eax,%eax
  800322:	78 0f                	js     800333 <getchar+0x29>
		return r;
	if (r < 1)
  800324:	85 c0                	test   %eax,%eax
  800326:	7e 06                	jle    80032e <getchar+0x24>
		return -E_EOF;
	return c;
  800328:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80032c:	eb 05                	jmp    800333 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80032e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800333:	c9                   	leave  
  800334:	c3                   	ret    

00800335 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800335:	55                   	push   %ebp
  800336:	89 e5                	mov    %esp,%ebp
  800338:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80033b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80033e:	50                   	push   %eax
  80033f:	ff 75 08             	pushl  0x8(%ebp)
  800342:	e8 8e 0e 00 00       	call   8011d5 <fd_lookup>
  800347:	83 c4 10             	add    $0x10,%esp
  80034a:	85 c0                	test   %eax,%eax
  80034c:	78 11                	js     80035f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80034e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800351:	8b 15 70 47 80 00    	mov    0x804770,%edx
  800357:	39 10                	cmp    %edx,(%eax)
  800359:	0f 94 c0             	sete   %al
  80035c:	0f b6 c0             	movzbl %al,%eax
}
  80035f:	c9                   	leave  
  800360:	c3                   	ret    

00800361 <opencons>:

int
opencons(void)
{
  800361:	55                   	push   %ebp
  800362:	89 e5                	mov    %esp,%ebp
  800364:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800367:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80036a:	50                   	push   %eax
  80036b:	e8 f1 0d 00 00       	call   801161 <fd_alloc>
  800370:	83 c4 10             	add    $0x10,%esp
  800373:	85 c0                	test   %eax,%eax
  800375:	78 3a                	js     8003b1 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800377:	83 ec 04             	sub    $0x4,%esp
  80037a:	68 07 04 00 00       	push   $0x407
  80037f:	ff 75 f4             	pushl  -0xc(%ebp)
  800382:	6a 00                	push   $0x0
  800384:	e8 c0 0b 00 00       	call   800f49 <sys_page_alloc>
  800389:	83 c4 10             	add    $0x10,%esp
  80038c:	85 c0                	test   %eax,%eax
  80038e:	78 21                	js     8003b1 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800390:	8b 15 70 47 80 00    	mov    0x804770,%edx
  800396:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800399:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80039b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80039e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8003a5:	83 ec 0c             	sub    $0xc,%esp
  8003a8:	50                   	push   %eax
  8003a9:	e8 8c 0d 00 00       	call   80113a <fd2num>
  8003ae:	83 c4 10             	add    $0x10,%esp
}
  8003b1:	c9                   	leave  
  8003b2:	c3                   	ret    

008003b3 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8003b3:	55                   	push   %ebp
  8003b4:	89 e5                	mov    %esp,%ebp
  8003b6:	56                   	push   %esi
  8003b7:	53                   	push   %ebx
  8003b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8003bb:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8003be:	e8 48 0b 00 00       	call   800f0b <sys_getenvid>
  8003c3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8003c8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8003cf:	c1 e0 07             	shl    $0x7,%eax
  8003d2:	29 d0                	sub    %edx,%eax
  8003d4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8003d9:	a3 90 67 80 00       	mov    %eax,0x806790

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8003de:	85 db                	test   %ebx,%ebx
  8003e0:	7e 07                	jle    8003e9 <libmain+0x36>
		binaryname = argv[0];
  8003e2:	8b 06                	mov    (%esi),%eax
  8003e4:	a3 8c 47 80 00       	mov    %eax,0x80478c

	// call user main routine
	umain(argc, argv);
  8003e9:	83 ec 08             	sub    $0x8,%esp
  8003ec:	56                   	push   %esi
  8003ed:	53                   	push   %ebx
  8003ee:	e8 72 fc ff ff       	call   800065 <umain>

	// exit gracefully
	exit();
  8003f3:	e8 0a 00 00 00       	call   800402 <exit>
}
  8003f8:	83 c4 10             	add    $0x10,%esp
  8003fb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8003fe:	5b                   	pop    %ebx
  8003ff:	5e                   	pop    %esi
  800400:	5d                   	pop    %ebp
  800401:	c3                   	ret    

00800402 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800402:	55                   	push   %ebp
  800403:	89 e5                	mov    %esp,%ebp
  800405:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800408:	e8 3c 0f 00 00       	call   801349 <close_all>
	sys_env_destroy(0);
  80040d:	83 ec 0c             	sub    $0xc,%esp
  800410:	6a 00                	push   $0x0
  800412:	e8 b3 0a 00 00       	call   800eca <sys_env_destroy>
}
  800417:	83 c4 10             	add    $0x10,%esp
  80041a:	c9                   	leave  
  80041b:	c3                   	ret    

0080041c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80041c:	55                   	push   %ebp
  80041d:	89 e5                	mov    %esp,%ebp
  80041f:	56                   	push   %esi
  800420:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800421:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800424:	8b 35 8c 47 80 00    	mov    0x80478c,%esi
  80042a:	e8 dc 0a 00 00       	call   800f0b <sys_getenvid>
  80042f:	83 ec 0c             	sub    $0xc,%esp
  800432:	ff 75 0c             	pushl  0xc(%ebp)
  800435:	ff 75 08             	pushl  0x8(%ebp)
  800438:	56                   	push   %esi
  800439:	50                   	push   %eax
  80043a:	68 8c 27 80 00       	push   $0x80278c
  80043f:	e8 b0 00 00 00       	call   8004f4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800444:	83 c4 18             	add    $0x18,%esp
  800447:	53                   	push   %ebx
  800448:	ff 75 10             	pushl  0x10(%ebp)
  80044b:	e8 53 00 00 00       	call   8004a3 <vcprintf>
	cprintf("\n");
  800450:	c7 04 24 50 2c 80 00 	movl   $0x802c50,(%esp)
  800457:	e8 98 00 00 00       	call   8004f4 <cprintf>
  80045c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80045f:	cc                   	int3   
  800460:	eb fd                	jmp    80045f <_panic+0x43>

00800462 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800462:	55                   	push   %ebp
  800463:	89 e5                	mov    %esp,%ebp
  800465:	53                   	push   %ebx
  800466:	83 ec 04             	sub    $0x4,%esp
  800469:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80046c:	8b 13                	mov    (%ebx),%edx
  80046e:	8d 42 01             	lea    0x1(%edx),%eax
  800471:	89 03                	mov    %eax,(%ebx)
  800473:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800476:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80047a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80047f:	75 1a                	jne    80049b <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800481:	83 ec 08             	sub    $0x8,%esp
  800484:	68 ff 00 00 00       	push   $0xff
  800489:	8d 43 08             	lea    0x8(%ebx),%eax
  80048c:	50                   	push   %eax
  80048d:	e8 fb 09 00 00       	call   800e8d <sys_cputs>
		b->idx = 0;
  800492:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800498:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80049b:	ff 43 04             	incl   0x4(%ebx)
}
  80049e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004a1:	c9                   	leave  
  8004a2:	c3                   	ret    

008004a3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004a3:	55                   	push   %ebp
  8004a4:	89 e5                	mov    %esp,%ebp
  8004a6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8004ac:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004b3:	00 00 00 
	b.cnt = 0;
  8004b6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004bd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004c0:	ff 75 0c             	pushl  0xc(%ebp)
  8004c3:	ff 75 08             	pushl  0x8(%ebp)
  8004c6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8004cc:	50                   	push   %eax
  8004cd:	68 62 04 80 00       	push   $0x800462
  8004d2:	e8 54 01 00 00       	call   80062b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8004d7:	83 c4 08             	add    $0x8,%esp
  8004da:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8004e0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8004e6:	50                   	push   %eax
  8004e7:	e8 a1 09 00 00       	call   800e8d <sys_cputs>

	return b.cnt;
}
  8004ec:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8004f2:	c9                   	leave  
  8004f3:	c3                   	ret    

008004f4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8004f4:	55                   	push   %ebp
  8004f5:	89 e5                	mov    %esp,%ebp
  8004f7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8004fa:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8004fd:	50                   	push   %eax
  8004fe:	ff 75 08             	pushl  0x8(%ebp)
  800501:	e8 9d ff ff ff       	call   8004a3 <vcprintf>
	va_end(ap);

	return cnt;
}
  800506:	c9                   	leave  
  800507:	c3                   	ret    

00800508 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800508:	55                   	push   %ebp
  800509:	89 e5                	mov    %esp,%ebp
  80050b:	57                   	push   %edi
  80050c:	56                   	push   %esi
  80050d:	53                   	push   %ebx
  80050e:	83 ec 1c             	sub    $0x1c,%esp
  800511:	89 c6                	mov    %eax,%esi
  800513:	89 d7                	mov    %edx,%edi
  800515:	8b 45 08             	mov    0x8(%ebp),%eax
  800518:	8b 55 0c             	mov    0xc(%ebp),%edx
  80051b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80051e:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800521:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800524:	bb 00 00 00 00       	mov    $0x0,%ebx
  800529:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80052c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80052f:	39 d3                	cmp    %edx,%ebx
  800531:	72 11                	jb     800544 <printnum+0x3c>
  800533:	39 45 10             	cmp    %eax,0x10(%ebp)
  800536:	76 0c                	jbe    800544 <printnum+0x3c>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800538:	8b 45 14             	mov    0x14(%ebp),%eax
  80053b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80053e:	85 db                	test   %ebx,%ebx
  800540:	7f 37                	jg     800579 <printnum+0x71>
  800542:	eb 44                	jmp    800588 <printnum+0x80>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800544:	83 ec 0c             	sub    $0xc,%esp
  800547:	ff 75 18             	pushl  0x18(%ebp)
  80054a:	8b 45 14             	mov    0x14(%ebp),%eax
  80054d:	48                   	dec    %eax
  80054e:	50                   	push   %eax
  80054f:	ff 75 10             	pushl  0x10(%ebp)
  800552:	83 ec 08             	sub    $0x8,%esp
  800555:	ff 75 e4             	pushl  -0x1c(%ebp)
  800558:	ff 75 e0             	pushl  -0x20(%ebp)
  80055b:	ff 75 dc             	pushl  -0x24(%ebp)
  80055e:	ff 75 d8             	pushl  -0x28(%ebp)
  800561:	e8 62 1e 00 00       	call   8023c8 <__udivdi3>
  800566:	83 c4 18             	add    $0x18,%esp
  800569:	52                   	push   %edx
  80056a:	50                   	push   %eax
  80056b:	89 fa                	mov    %edi,%edx
  80056d:	89 f0                	mov    %esi,%eax
  80056f:	e8 94 ff ff ff       	call   800508 <printnum>
  800574:	83 c4 20             	add    $0x20,%esp
  800577:	eb 0f                	jmp    800588 <printnum+0x80>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800579:	83 ec 08             	sub    $0x8,%esp
  80057c:	57                   	push   %edi
  80057d:	ff 75 18             	pushl  0x18(%ebp)
  800580:	ff d6                	call   *%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800582:	83 c4 10             	add    $0x10,%esp
  800585:	4b                   	dec    %ebx
  800586:	75 f1                	jne    800579 <printnum+0x71>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800588:	83 ec 08             	sub    $0x8,%esp
  80058b:	57                   	push   %edi
  80058c:	83 ec 04             	sub    $0x4,%esp
  80058f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800592:	ff 75 e0             	pushl  -0x20(%ebp)
  800595:	ff 75 dc             	pushl  -0x24(%ebp)
  800598:	ff 75 d8             	pushl  -0x28(%ebp)
  80059b:	e8 38 1f 00 00       	call   8024d8 <__umoddi3>
  8005a0:	83 c4 14             	add    $0x14,%esp
  8005a3:	0f be 80 af 27 80 00 	movsbl 0x8027af(%eax),%eax
  8005aa:	50                   	push   %eax
  8005ab:	ff d6                	call   *%esi
}
  8005ad:	83 c4 10             	add    $0x10,%esp
  8005b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005b3:	5b                   	pop    %ebx
  8005b4:	5e                   	pop    %esi
  8005b5:	5f                   	pop    %edi
  8005b6:	5d                   	pop    %ebp
  8005b7:	c3                   	ret    

008005b8 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8005b8:	55                   	push   %ebp
  8005b9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8005bb:	83 fa 01             	cmp    $0x1,%edx
  8005be:	7e 0e                	jle    8005ce <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8005c0:	8b 10                	mov    (%eax),%edx
  8005c2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8005c5:	89 08                	mov    %ecx,(%eax)
  8005c7:	8b 02                	mov    (%edx),%eax
  8005c9:	8b 52 04             	mov    0x4(%edx),%edx
  8005cc:	eb 22                	jmp    8005f0 <getuint+0x38>
	else if (lflag)
  8005ce:	85 d2                	test   %edx,%edx
  8005d0:	74 10                	je     8005e2 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8005d2:	8b 10                	mov    (%eax),%edx
  8005d4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005d7:	89 08                	mov    %ecx,(%eax)
  8005d9:	8b 02                	mov    (%edx),%eax
  8005db:	ba 00 00 00 00       	mov    $0x0,%edx
  8005e0:	eb 0e                	jmp    8005f0 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8005e2:	8b 10                	mov    (%eax),%edx
  8005e4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005e7:	89 08                	mov    %ecx,(%eax)
  8005e9:	8b 02                	mov    (%edx),%eax
  8005eb:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8005f0:	5d                   	pop    %ebp
  8005f1:	c3                   	ret    

008005f2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005f2:	55                   	push   %ebp
  8005f3:	89 e5                	mov    %esp,%ebp
  8005f5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005f8:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8005fb:	8b 10                	mov    (%eax),%edx
  8005fd:	3b 50 04             	cmp    0x4(%eax),%edx
  800600:	73 0a                	jae    80060c <sprintputch+0x1a>
		*b->buf++ = ch;
  800602:	8d 4a 01             	lea    0x1(%edx),%ecx
  800605:	89 08                	mov    %ecx,(%eax)
  800607:	8b 45 08             	mov    0x8(%ebp),%eax
  80060a:	88 02                	mov    %al,(%edx)
}
  80060c:	5d                   	pop    %ebp
  80060d:	c3                   	ret    

0080060e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80060e:	55                   	push   %ebp
  80060f:	89 e5                	mov    %esp,%ebp
  800611:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800614:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800617:	50                   	push   %eax
  800618:	ff 75 10             	pushl  0x10(%ebp)
  80061b:	ff 75 0c             	pushl  0xc(%ebp)
  80061e:	ff 75 08             	pushl  0x8(%ebp)
  800621:	e8 05 00 00 00       	call   80062b <vprintfmt>
	va_end(ap);
}
  800626:	83 c4 10             	add    $0x10,%esp
  800629:	c9                   	leave  
  80062a:	c3                   	ret    

0080062b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80062b:	55                   	push   %ebp
  80062c:	89 e5                	mov    %esp,%ebp
  80062e:	57                   	push   %edi
  80062f:	56                   	push   %esi
  800630:	53                   	push   %ebx
  800631:	83 ec 2c             	sub    $0x2c,%esp
  800634:	8b 7d 08             	mov    0x8(%ebp),%edi
  800637:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80063a:	eb 03                	jmp    80063f <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  80063c:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  80063f:	8b 45 10             	mov    0x10(%ebp),%eax
  800642:	8d 70 01             	lea    0x1(%eax),%esi
  800645:	0f b6 00             	movzbl (%eax),%eax
  800648:	83 f8 25             	cmp    $0x25,%eax
  80064b:	74 25                	je     800672 <vprintfmt+0x47>
			if (ch == '\0')									//当然中间如果遇到'\0'，代表这个字符串的访问结束
  80064d:	85 c0                	test   %eax,%eax
  80064f:	75 0d                	jne    80065e <vprintfmt+0x33>
  800651:	e9 b5 03 00 00       	jmp    800a0b <vprintfmt+0x3e0>
  800656:	85 c0                	test   %eax,%eax
  800658:	0f 84 ad 03 00 00    	je     800a0b <vprintfmt+0x3e0>
				return;
			putch(ch, putdat);								//调用putch函数，把一个字符ch输出到putdat指针所指向的地址中所存放的值对应的地址处
  80065e:	83 ec 08             	sub    $0x8,%esp
  800661:	53                   	push   %ebx
  800662:	50                   	push   %eax
  800663:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  800665:	46                   	inc    %esi
  800666:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  80066a:	83 c4 10             	add    $0x10,%esp
  80066d:	83 f8 25             	cmp    $0x25,%eax
  800670:	75 e4                	jne    800656 <vprintfmt+0x2b>
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  800672:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  800676:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80067d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800684:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80068b:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800692:	eb 07                	jmp    80069b <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800694:	8b 75 10             	mov    0x10(%ebp),%esi

		// flag to pad on the right
		case '-':											//%后面的'-'代表要进行左对齐输出，右边填空格，如果省略代表右对齐
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
  800697:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80069b:	8d 46 01             	lea    0x1(%esi),%eax
  80069e:	89 45 10             	mov    %eax,0x10(%ebp)
  8006a1:	0f b6 16             	movzbl (%esi),%edx
  8006a4:	8a 06                	mov    (%esi),%al
  8006a6:	83 e8 23             	sub    $0x23,%eax
  8006a9:	3c 55                	cmp    $0x55,%al
  8006ab:	0f 87 03 03 00 00    	ja     8009b4 <vprintfmt+0x389>
  8006b1:	0f b6 c0             	movzbl %al,%eax
  8006b4:	ff 24 85 00 29 80 00 	jmp    *0x802900(,%eax,4)
  8006bb:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
			goto reswitch;									//处理下一个字符

		// flag to pad with 0's instead of spaces
		case '0':											//0--有0表示进行对齐输出时填0,如省略表示填入空格，并且如果为0，则一定是右对齐
			padc = '0';										//对其方式标志位变为0
  8006be:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  8006c2:	eb d7                	jmp    80069b <vprintfmt+0x70>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
				precision = precision * 10 + ch - '0';
  8006c4:	8d 42 d0             	lea    -0x30(%edx),%eax
  8006c7:	89 c1                	mov    %eax,%ecx
  8006c9:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  8006cc:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8006d0:	8d 50 d0             	lea    -0x30(%eax),%edx
  8006d3:	83 fa 09             	cmp    $0x9,%edx
  8006d6:	77 51                	ja     800729 <vprintfmt+0xfe>
  8006d8:	8b 75 10             	mov    0x10(%ebp),%esi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
  8006db:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8006dc:	8d 14 89             	lea    (%ecx,%ecx,4),%edx
  8006df:	01 d2                	add    %edx,%edx
  8006e1:	8d 4c 10 d0          	lea    -0x30(%eax,%edx,1),%ecx
				ch = *fmt;
  8006e5:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8006e8:	8d 50 d0             	lea    -0x30(%eax),%edx
  8006eb:	83 fa 09             	cmp    $0x9,%edx
  8006ee:	76 eb                	jbe    8006db <vprintfmt+0xb0>
  8006f0:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8006f3:	eb 37                	jmp    80072c <vprintfmt+0x101>
					break;
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
  8006f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f8:	8d 50 04             	lea    0x4(%eax),%edx
  8006fb:	89 55 14             	mov    %edx,0x14(%ebp)
  8006fe:	8b 00                	mov    (%eax),%eax
  800700:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800703:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
			goto process_precision;
  800706:	eb 24                	jmp    80072c <vprintfmt+0x101>
  800708:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80070c:	79 07                	jns    800715 <vprintfmt+0xea>
  80070e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800715:	8b 75 10             	mov    0x10(%ebp),%esi
  800718:	eb 81                	jmp    80069b <vprintfmt+0x70>
  80071a:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  80071d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800724:	e9 72 ff ff ff       	jmp    80069b <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800729:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:									//处理输出精度，把width字段赋值为刚刚计算出来的precision值，所以width应该是整数部分的有效数字位数
			if (width < 0)
  80072c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800730:	0f 89 65 ff ff ff    	jns    80069b <vprintfmt+0x70>
				width = precision, precision = -1;
  800736:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800739:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80073c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800743:	e9 53 ff ff ff       	jmp    80069b <vprintfmt+0x70>
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
  800748:	ff 45 d4             	incl   -0x2c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80074b:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
			goto reswitch;
  80074e:	e9 48 ff ff ff       	jmp    80069b <vprintfmt+0x70>

		// character
		case 'c':											//如果是'c'代表显示一个字符
			putch(va_arg(ap, int), putdat);					//调用输出一个字符到内存的函数putch
  800753:	8b 45 14             	mov    0x14(%ebp),%eax
  800756:	8d 50 04             	lea    0x4(%eax),%edx
  800759:	89 55 14             	mov    %edx,0x14(%ebp)
  80075c:	83 ec 08             	sub    $0x8,%esp
  80075f:	53                   	push   %ebx
  800760:	ff 30                	pushl  (%eax)
  800762:	ff d7                	call   *%edi
			break;
  800764:	83 c4 10             	add    $0x10,%esp
  800767:	e9 d3 fe ff ff       	jmp    80063f <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80076c:	8b 45 14             	mov    0x14(%ebp),%eax
  80076f:	8d 50 04             	lea    0x4(%eax),%edx
  800772:	89 55 14             	mov    %edx,0x14(%ebp)
  800775:	8b 00                	mov    (%eax),%eax
  800777:	85 c0                	test   %eax,%eax
  800779:	79 02                	jns    80077d <vprintfmt+0x152>
  80077b:	f7 d8                	neg    %eax
  80077d:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80077f:	83 f8 0f             	cmp    $0xf,%eax
  800782:	7f 0b                	jg     80078f <vprintfmt+0x164>
  800784:	8b 04 85 60 2a 80 00 	mov    0x802a60(,%eax,4),%eax
  80078b:	85 c0                	test   %eax,%eax
  80078d:	75 15                	jne    8007a4 <vprintfmt+0x179>
				printfmt(putch, putdat, "error %d", err);
  80078f:	52                   	push   %edx
  800790:	68 c7 27 80 00       	push   $0x8027c7
  800795:	53                   	push   %ebx
  800796:	57                   	push   %edi
  800797:	e8 72 fe ff ff       	call   80060e <printfmt>
  80079c:	83 c4 10             	add    $0x10,%esp
  80079f:	e9 9b fe ff ff       	jmp    80063f <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  8007a4:	50                   	push   %eax
  8007a5:	68 7f 2b 80 00       	push   $0x802b7f
  8007aa:	53                   	push   %ebx
  8007ab:	57                   	push   %edi
  8007ac:	e8 5d fe ff ff       	call   80060e <printfmt>
  8007b1:	83 c4 10             	add    $0x10,%esp
  8007b4:	e9 86 fe ff ff       	jmp    80063f <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8007b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bc:	8d 50 04             	lea    0x4(%eax),%edx
  8007bf:	89 55 14             	mov    %edx,0x14(%ebp)
  8007c2:	8b 00                	mov    (%eax),%eax
  8007c4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8007c7:	85 c0                	test   %eax,%eax
  8007c9:	75 07                	jne    8007d2 <vprintfmt+0x1a7>
				p = "(null)";
  8007cb:	c7 45 d4 c0 27 80 00 	movl   $0x8027c0,-0x2c(%ebp)
			if (width > 0 && padc != '-')
  8007d2:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8007d5:	85 f6                	test   %esi,%esi
  8007d7:	0f 8e fb 01 00 00    	jle    8009d8 <vprintfmt+0x3ad>
  8007dd:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  8007e1:	0f 84 09 02 00 00    	je     8009f0 <vprintfmt+0x3c5>
				for (width -= strnlen(p, precision); width > 0; width--)
  8007e7:	83 ec 08             	sub    $0x8,%esp
  8007ea:	ff 75 d0             	pushl  -0x30(%ebp)
  8007ed:	ff 75 d4             	pushl  -0x2c(%ebp)
  8007f0:	e8 ad 02 00 00       	call   800aa2 <strnlen>
  8007f5:	89 f1                	mov    %esi,%ecx
  8007f7:	29 c1                	sub    %eax,%ecx
  8007f9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8007fc:	83 c4 10             	add    $0x10,%esp
  8007ff:	85 c9                	test   %ecx,%ecx
  800801:	0f 8e d1 01 00 00    	jle    8009d8 <vprintfmt+0x3ad>
					putch(padc, putdat);
  800807:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  80080b:	83 ec 08             	sub    $0x8,%esp
  80080e:	53                   	push   %ebx
  80080f:	56                   	push   %esi
  800810:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800812:	83 c4 10             	add    $0x10,%esp
  800815:	ff 4d e4             	decl   -0x1c(%ebp)
  800818:	75 f1                	jne    80080b <vprintfmt+0x1e0>
  80081a:	e9 b9 01 00 00       	jmp    8009d8 <vprintfmt+0x3ad>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80081f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800823:	74 19                	je     80083e <vprintfmt+0x213>
  800825:	0f be c0             	movsbl %al,%eax
  800828:	83 e8 20             	sub    $0x20,%eax
  80082b:	83 f8 5e             	cmp    $0x5e,%eax
  80082e:	76 0e                	jbe    80083e <vprintfmt+0x213>
					putch('?', putdat);
  800830:	83 ec 08             	sub    $0x8,%esp
  800833:	53                   	push   %ebx
  800834:	6a 3f                	push   $0x3f
  800836:	ff 55 08             	call   *0x8(%ebp)
  800839:	83 c4 10             	add    $0x10,%esp
  80083c:	eb 0b                	jmp    800849 <vprintfmt+0x21e>
				else
					putch(ch, putdat);
  80083e:	83 ec 08             	sub    $0x8,%esp
  800841:	53                   	push   %ebx
  800842:	52                   	push   %edx
  800843:	ff 55 08             	call   *0x8(%ebp)
  800846:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800849:	ff 4d e4             	decl   -0x1c(%ebp)
  80084c:	46                   	inc    %esi
  80084d:	8a 46 ff             	mov    -0x1(%esi),%al
  800850:	0f be d0             	movsbl %al,%edx
  800853:	85 d2                	test   %edx,%edx
  800855:	75 1c                	jne    800873 <vprintfmt+0x248>
  800857:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80085a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80085e:	7f 1f                	jg     80087f <vprintfmt+0x254>
  800860:	e9 da fd ff ff       	jmp    80063f <vprintfmt+0x14>
  800865:	89 7d 08             	mov    %edi,0x8(%ebp)
  800868:	8b 7d d0             	mov    -0x30(%ebp),%edi
  80086b:	eb 06                	jmp    800873 <vprintfmt+0x248>
  80086d:	89 7d 08             	mov    %edi,0x8(%ebp)
  800870:	8b 7d d0             	mov    -0x30(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800873:	85 ff                	test   %edi,%edi
  800875:	78 a8                	js     80081f <vprintfmt+0x1f4>
  800877:	4f                   	dec    %edi
  800878:	79 a5                	jns    80081f <vprintfmt+0x1f4>
  80087a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80087d:	eb db                	jmp    80085a <vprintfmt+0x22f>
  80087f:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800882:	83 ec 08             	sub    $0x8,%esp
  800885:	53                   	push   %ebx
  800886:	6a 20                	push   $0x20
  800888:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80088a:	4e                   	dec    %esi
  80088b:	83 c4 10             	add    $0x10,%esp
  80088e:	85 f6                	test   %esi,%esi
  800890:	7f f0                	jg     800882 <vprintfmt+0x257>
  800892:	e9 a8 fd ff ff       	jmp    80063f <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800897:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  80089b:	7e 16                	jle    8008b3 <vprintfmt+0x288>
		return va_arg(*ap, long long);
  80089d:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a0:	8d 50 08             	lea    0x8(%eax),%edx
  8008a3:	89 55 14             	mov    %edx,0x14(%ebp)
  8008a6:	8b 50 04             	mov    0x4(%eax),%edx
  8008a9:	8b 00                	mov    (%eax),%eax
  8008ab:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008ae:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8008b1:	eb 34                	jmp    8008e7 <vprintfmt+0x2bc>
	else if (lflag)
  8008b3:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8008b7:	74 18                	je     8008d1 <vprintfmt+0x2a6>
		return va_arg(*ap, long);
  8008b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8008bc:	8d 50 04             	lea    0x4(%eax),%edx
  8008bf:	89 55 14             	mov    %edx,0x14(%ebp)
  8008c2:	8b 30                	mov    (%eax),%esi
  8008c4:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8008c7:	89 f0                	mov    %esi,%eax
  8008c9:	c1 f8 1f             	sar    $0x1f,%eax
  8008cc:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8008cf:	eb 16                	jmp    8008e7 <vprintfmt+0x2bc>
	else
		return va_arg(*ap, int);
  8008d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d4:	8d 50 04             	lea    0x4(%eax),%edx
  8008d7:	89 55 14             	mov    %edx,0x14(%ebp)
  8008da:	8b 30                	mov    (%eax),%esi
  8008dc:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8008df:	89 f0                	mov    %esi,%eax
  8008e1:	c1 f8 1f             	sar    $0x1f,%eax
  8008e4:	89 45 dc             	mov    %eax,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8008e7:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8008ea:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
  8008ed:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8008f1:	0f 89 8a 00 00 00    	jns    800981 <vprintfmt+0x356>
				putch('-', putdat);
  8008f7:	83 ec 08             	sub    $0x8,%esp
  8008fa:	53                   	push   %ebx
  8008fb:	6a 2d                	push   $0x2d
  8008fd:	ff d7                	call   *%edi
				num = -(long long) num;
  8008ff:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800902:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800905:	f7 d8                	neg    %eax
  800907:	83 d2 00             	adc    $0x0,%edx
  80090a:	f7 da                	neg    %edx
  80090c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80090f:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800914:	eb 70                	jmp    800986 <vprintfmt+0x35b>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800916:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800919:	8d 45 14             	lea    0x14(%ebp),%eax
  80091c:	e8 97 fc ff ff       	call   8005b8 <getuint>
			base = 10;
  800921:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800926:	eb 5e                	jmp    800986 <vprintfmt+0x35b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  800928:	83 ec 08             	sub    $0x8,%esp
  80092b:	53                   	push   %ebx
  80092c:	6a 30                	push   $0x30
  80092e:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  800930:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800933:	8d 45 14             	lea    0x14(%ebp),%eax
  800936:	e8 7d fc ff ff       	call   8005b8 <getuint>
			base = 8;
			goto number;
  80093b:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  80093e:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800943:	eb 41                	jmp    800986 <vprintfmt+0x35b>
		// pointer
		case 'p':
			putch('0', putdat);
  800945:	83 ec 08             	sub    $0x8,%esp
  800948:	53                   	push   %ebx
  800949:	6a 30                	push   $0x30
  80094b:	ff d7                	call   *%edi
			putch('x', putdat);
  80094d:	83 c4 08             	add    $0x8,%esp
  800950:	53                   	push   %ebx
  800951:	6a 78                	push   $0x78
  800953:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800955:	8b 45 14             	mov    0x14(%ebp),%eax
  800958:	8d 50 04             	lea    0x4(%eax),%edx
  80095b:	89 55 14             	mov    %edx,0x14(%ebp)
			goto number;
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80095e:	8b 00                	mov    (%eax),%eax
  800960:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800965:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800968:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80096d:	eb 17                	jmp    800986 <vprintfmt+0x35b>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80096f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800972:	8d 45 14             	lea    0x14(%ebp),%eax
  800975:	e8 3e fc ff ff       	call   8005b8 <getuint>
			base = 16;
  80097a:	b9 10 00 00 00       	mov    $0x10,%ecx
  80097f:	eb 05                	jmp    800986 <vprintfmt+0x35b>
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800981:	b9 0a 00 00 00       	mov    $0xa,%ecx
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800986:	83 ec 0c             	sub    $0xc,%esp
  800989:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  80098d:	56                   	push   %esi
  80098e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800991:	51                   	push   %ecx
  800992:	52                   	push   %edx
  800993:	50                   	push   %eax
  800994:	89 da                	mov    %ebx,%edx
  800996:	89 f8                	mov    %edi,%eax
  800998:	e8 6b fb ff ff       	call   800508 <printnum>
			break;
  80099d:	83 c4 20             	add    $0x20,%esp
  8009a0:	e9 9a fc ff ff       	jmp    80063f <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8009a5:	83 ec 08             	sub    $0x8,%esp
  8009a8:	53                   	push   %ebx
  8009a9:	52                   	push   %edx
  8009aa:	ff d7                	call   *%edi
			break;
  8009ac:	83 c4 10             	add    $0x10,%esp
  8009af:	e9 8b fc ff ff       	jmp    80063f <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8009b4:	83 ec 08             	sub    $0x8,%esp
  8009b7:	53                   	push   %ebx
  8009b8:	6a 25                	push   $0x25
  8009ba:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009bc:	83 c4 10             	add    $0x10,%esp
  8009bf:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8009c3:	0f 84 73 fc ff ff    	je     80063c <vprintfmt+0x11>
  8009c9:	4e                   	dec    %esi
  8009ca:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8009ce:	75 f9                	jne    8009c9 <vprintfmt+0x39e>
  8009d0:	89 75 10             	mov    %esi,0x10(%ebp)
  8009d3:	e9 67 fc ff ff       	jmp    80063f <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009d8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8009db:	8d 70 01             	lea    0x1(%eax),%esi
  8009de:	8a 00                	mov    (%eax),%al
  8009e0:	0f be d0             	movsbl %al,%edx
  8009e3:	85 d2                	test   %edx,%edx
  8009e5:	0f 85 7a fe ff ff    	jne    800865 <vprintfmt+0x23a>
  8009eb:	e9 4f fc ff ff       	jmp    80063f <vprintfmt+0x14>
  8009f0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8009f3:	8d 70 01             	lea    0x1(%eax),%esi
  8009f6:	8a 00                	mov    (%eax),%al
  8009f8:	0f be d0             	movsbl %al,%edx
  8009fb:	85 d2                	test   %edx,%edx
  8009fd:	0f 85 6a fe ff ff    	jne    80086d <vprintfmt+0x242>
  800a03:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800a06:	e9 77 fe ff ff       	jmp    800882 <vprintfmt+0x257>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800a0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a0e:	5b                   	pop    %ebx
  800a0f:	5e                   	pop    %esi
  800a10:	5f                   	pop    %edi
  800a11:	5d                   	pop    %ebp
  800a12:	c3                   	ret    

00800a13 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a13:	55                   	push   %ebp
  800a14:	89 e5                	mov    %esp,%ebp
  800a16:	83 ec 18             	sub    $0x18,%esp
  800a19:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a1f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a22:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a26:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a29:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a30:	85 c0                	test   %eax,%eax
  800a32:	74 26                	je     800a5a <vsnprintf+0x47>
  800a34:	85 d2                	test   %edx,%edx
  800a36:	7e 29                	jle    800a61 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a38:	ff 75 14             	pushl  0x14(%ebp)
  800a3b:	ff 75 10             	pushl  0x10(%ebp)
  800a3e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a41:	50                   	push   %eax
  800a42:	68 f2 05 80 00       	push   $0x8005f2
  800a47:	e8 df fb ff ff       	call   80062b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a4c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a4f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a52:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a55:	83 c4 10             	add    $0x10,%esp
  800a58:	eb 0c                	jmp    800a66 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a5a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a5f:	eb 05                	jmp    800a66 <vsnprintf+0x53>
  800a61:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a66:	c9                   	leave  
  800a67:	c3                   	ret    

00800a68 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a68:	55                   	push   %ebp
  800a69:	89 e5                	mov    %esp,%ebp
  800a6b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a6e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a71:	50                   	push   %eax
  800a72:	ff 75 10             	pushl  0x10(%ebp)
  800a75:	ff 75 0c             	pushl  0xc(%ebp)
  800a78:	ff 75 08             	pushl  0x8(%ebp)
  800a7b:	e8 93 ff ff ff       	call   800a13 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a80:	c9                   	leave  
  800a81:	c3                   	ret    

00800a82 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a82:	55                   	push   %ebp
  800a83:	89 e5                	mov    %esp,%ebp
  800a85:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a88:	80 3a 00             	cmpb   $0x0,(%edx)
  800a8b:	74 0e                	je     800a9b <strlen+0x19>
  800a8d:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800a92:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a93:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a97:	75 f9                	jne    800a92 <strlen+0x10>
  800a99:	eb 05                	jmp    800aa0 <strlen+0x1e>
  800a9b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800aa0:	5d                   	pop    %ebp
  800aa1:	c3                   	ret    

00800aa2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800aa2:	55                   	push   %ebp
  800aa3:	89 e5                	mov    %esp,%ebp
  800aa5:	53                   	push   %ebx
  800aa6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800aa9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800aac:	85 c9                	test   %ecx,%ecx
  800aae:	74 1a                	je     800aca <strnlen+0x28>
  800ab0:	80 3b 00             	cmpb   $0x0,(%ebx)
  800ab3:	74 1c                	je     800ad1 <strnlen+0x2f>
  800ab5:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800aba:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800abc:	39 ca                	cmp    %ecx,%edx
  800abe:	74 16                	je     800ad6 <strnlen+0x34>
  800ac0:	42                   	inc    %edx
  800ac1:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800ac6:	75 f2                	jne    800aba <strnlen+0x18>
  800ac8:	eb 0c                	jmp    800ad6 <strnlen+0x34>
  800aca:	b8 00 00 00 00       	mov    $0x0,%eax
  800acf:	eb 05                	jmp    800ad6 <strnlen+0x34>
  800ad1:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800ad6:	5b                   	pop    %ebx
  800ad7:	5d                   	pop    %ebp
  800ad8:	c3                   	ret    

00800ad9 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800ad9:	55                   	push   %ebp
  800ada:	89 e5                	mov    %esp,%ebp
  800adc:	53                   	push   %ebx
  800add:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800ae3:	89 c2                	mov    %eax,%edx
  800ae5:	42                   	inc    %edx
  800ae6:	41                   	inc    %ecx
  800ae7:	8a 59 ff             	mov    -0x1(%ecx),%bl
  800aea:	88 5a ff             	mov    %bl,-0x1(%edx)
  800aed:	84 db                	test   %bl,%bl
  800aef:	75 f4                	jne    800ae5 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800af1:	5b                   	pop    %ebx
  800af2:	5d                   	pop    %ebp
  800af3:	c3                   	ret    

00800af4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800af4:	55                   	push   %ebp
  800af5:	89 e5                	mov    %esp,%ebp
  800af7:	53                   	push   %ebx
  800af8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800afb:	53                   	push   %ebx
  800afc:	e8 81 ff ff ff       	call   800a82 <strlen>
  800b01:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800b04:	ff 75 0c             	pushl  0xc(%ebp)
  800b07:	01 d8                	add    %ebx,%eax
  800b09:	50                   	push   %eax
  800b0a:	e8 ca ff ff ff       	call   800ad9 <strcpy>
	return dst;
}
  800b0f:	89 d8                	mov    %ebx,%eax
  800b11:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b14:	c9                   	leave  
  800b15:	c3                   	ret    

00800b16 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b16:	55                   	push   %ebp
  800b17:	89 e5                	mov    %esp,%ebp
  800b19:	56                   	push   %esi
  800b1a:	53                   	push   %ebx
  800b1b:	8b 75 08             	mov    0x8(%ebp),%esi
  800b1e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b21:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b24:	85 db                	test   %ebx,%ebx
  800b26:	74 14                	je     800b3c <strncpy+0x26>
  800b28:	01 f3                	add    %esi,%ebx
  800b2a:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800b2c:	41                   	inc    %ecx
  800b2d:	8a 02                	mov    (%edx),%al
  800b2f:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b32:	80 3a 01             	cmpb   $0x1,(%edx)
  800b35:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b38:	39 cb                	cmp    %ecx,%ebx
  800b3a:	75 f0                	jne    800b2c <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b3c:	89 f0                	mov    %esi,%eax
  800b3e:	5b                   	pop    %ebx
  800b3f:	5e                   	pop    %esi
  800b40:	5d                   	pop    %ebp
  800b41:	c3                   	ret    

00800b42 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b42:	55                   	push   %ebp
  800b43:	89 e5                	mov    %esp,%ebp
  800b45:	53                   	push   %ebx
  800b46:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b49:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b4c:	85 c0                	test   %eax,%eax
  800b4e:	74 30                	je     800b80 <strlcpy+0x3e>
		while (--size > 0 && *src != '\0')
  800b50:	48                   	dec    %eax
  800b51:	74 20                	je     800b73 <strlcpy+0x31>
  800b53:	8a 0b                	mov    (%ebx),%cl
  800b55:	84 c9                	test   %cl,%cl
  800b57:	74 1f                	je     800b78 <strlcpy+0x36>
  800b59:	8d 53 01             	lea    0x1(%ebx),%edx
  800b5c:	01 c3                	add    %eax,%ebx
  800b5e:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
  800b61:	40                   	inc    %eax
  800b62:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800b65:	39 da                	cmp    %ebx,%edx
  800b67:	74 12                	je     800b7b <strlcpy+0x39>
  800b69:	42                   	inc    %edx
  800b6a:	8a 4a ff             	mov    -0x1(%edx),%cl
  800b6d:	84 c9                	test   %cl,%cl
  800b6f:	75 f0                	jne    800b61 <strlcpy+0x1f>
  800b71:	eb 08                	jmp    800b7b <strlcpy+0x39>
  800b73:	8b 45 08             	mov    0x8(%ebp),%eax
  800b76:	eb 03                	jmp    800b7b <strlcpy+0x39>
  800b78:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
		*dst = '\0';
  800b7b:	c6 00 00             	movb   $0x0,(%eax)
  800b7e:	eb 03                	jmp    800b83 <strlcpy+0x41>
  800b80:	8b 45 08             	mov    0x8(%ebp),%eax
	}
	return dst - dst_in;
  800b83:	2b 45 08             	sub    0x8(%ebp),%eax
}
  800b86:	5b                   	pop    %ebx
  800b87:	5d                   	pop    %ebp
  800b88:	c3                   	ret    

00800b89 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b89:	55                   	push   %ebp
  800b8a:	89 e5                	mov    %esp,%ebp
  800b8c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b8f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b92:	8a 01                	mov    (%ecx),%al
  800b94:	84 c0                	test   %al,%al
  800b96:	74 10                	je     800ba8 <strcmp+0x1f>
  800b98:	3a 02                	cmp    (%edx),%al
  800b9a:	75 0c                	jne    800ba8 <strcmp+0x1f>
		p++, q++;
  800b9c:	41                   	inc    %ecx
  800b9d:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b9e:	8a 01                	mov    (%ecx),%al
  800ba0:	84 c0                	test   %al,%al
  800ba2:	74 04                	je     800ba8 <strcmp+0x1f>
  800ba4:	3a 02                	cmp    (%edx),%al
  800ba6:	74 f4                	je     800b9c <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ba8:	0f b6 c0             	movzbl %al,%eax
  800bab:	0f b6 12             	movzbl (%edx),%edx
  800bae:	29 d0                	sub    %edx,%eax
}
  800bb0:	5d                   	pop    %ebp
  800bb1:	c3                   	ret    

00800bb2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800bb2:	55                   	push   %ebp
  800bb3:	89 e5                	mov    %esp,%ebp
  800bb5:	56                   	push   %esi
  800bb6:	53                   	push   %ebx
  800bb7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800bba:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bbd:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800bc0:	85 f6                	test   %esi,%esi
  800bc2:	74 23                	je     800be7 <strncmp+0x35>
  800bc4:	8a 03                	mov    (%ebx),%al
  800bc6:	84 c0                	test   %al,%al
  800bc8:	74 2b                	je     800bf5 <strncmp+0x43>
  800bca:	3a 02                	cmp    (%edx),%al
  800bcc:	75 27                	jne    800bf5 <strncmp+0x43>
  800bce:	8d 43 01             	lea    0x1(%ebx),%eax
  800bd1:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800bd3:	89 c3                	mov    %eax,%ebx
  800bd5:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800bd6:	39 c6                	cmp    %eax,%esi
  800bd8:	74 14                	je     800bee <strncmp+0x3c>
  800bda:	8a 08                	mov    (%eax),%cl
  800bdc:	84 c9                	test   %cl,%cl
  800bde:	74 15                	je     800bf5 <strncmp+0x43>
  800be0:	40                   	inc    %eax
  800be1:	3a 0a                	cmp    (%edx),%cl
  800be3:	74 ee                	je     800bd3 <strncmp+0x21>
  800be5:	eb 0e                	jmp    800bf5 <strncmp+0x43>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800be7:	b8 00 00 00 00       	mov    $0x0,%eax
  800bec:	eb 0f                	jmp    800bfd <strncmp+0x4b>
  800bee:	b8 00 00 00 00       	mov    $0x0,%eax
  800bf3:	eb 08                	jmp    800bfd <strncmp+0x4b>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800bf5:	0f b6 03             	movzbl (%ebx),%eax
  800bf8:	0f b6 12             	movzbl (%edx),%edx
  800bfb:	29 d0                	sub    %edx,%eax
}
  800bfd:	5b                   	pop    %ebx
  800bfe:	5e                   	pop    %esi
  800bff:	5d                   	pop    %ebp
  800c00:	c3                   	ret    

00800c01 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c01:	55                   	push   %ebp
  800c02:	89 e5                	mov    %esp,%ebp
  800c04:	53                   	push   %ebx
  800c05:	8b 45 08             	mov    0x8(%ebp),%eax
  800c08:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800c0b:	8a 10                	mov    (%eax),%dl
  800c0d:	84 d2                	test   %dl,%dl
  800c0f:	74 1a                	je     800c2b <strchr+0x2a>
  800c11:	88 d9                	mov    %bl,%cl
		if (*s == c)
  800c13:	38 d3                	cmp    %dl,%bl
  800c15:	75 06                	jne    800c1d <strchr+0x1c>
  800c17:	eb 17                	jmp    800c30 <strchr+0x2f>
  800c19:	38 ca                	cmp    %cl,%dl
  800c1b:	74 13                	je     800c30 <strchr+0x2f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c1d:	40                   	inc    %eax
  800c1e:	8a 10                	mov    (%eax),%dl
  800c20:	84 d2                	test   %dl,%dl
  800c22:	75 f5                	jne    800c19 <strchr+0x18>
		if (*s == c)
			return (char *) s;
	return 0;
  800c24:	b8 00 00 00 00       	mov    $0x0,%eax
  800c29:	eb 05                	jmp    800c30 <strchr+0x2f>
  800c2b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c30:	5b                   	pop    %ebx
  800c31:	5d                   	pop    %ebp
  800c32:	c3                   	ret    

00800c33 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	53                   	push   %ebx
  800c37:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800c3d:	8a 10                	mov    (%eax),%dl
  800c3f:	84 d2                	test   %dl,%dl
  800c41:	74 13                	je     800c56 <strfind+0x23>
  800c43:	88 d9                	mov    %bl,%cl
		if (*s == c)
  800c45:	38 d3                	cmp    %dl,%bl
  800c47:	75 06                	jne    800c4f <strfind+0x1c>
  800c49:	eb 0b                	jmp    800c56 <strfind+0x23>
  800c4b:	38 ca                	cmp    %cl,%dl
  800c4d:	74 07                	je     800c56 <strfind+0x23>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800c4f:	40                   	inc    %eax
  800c50:	8a 10                	mov    (%eax),%dl
  800c52:	84 d2                	test   %dl,%dl
  800c54:	75 f5                	jne    800c4b <strfind+0x18>
		if (*s == c)
			break;
	return (char *) s;
}
  800c56:	5b                   	pop    %ebx
  800c57:	5d                   	pop    %ebp
  800c58:	c3                   	ret    

00800c59 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c59:	55                   	push   %ebp
  800c5a:	89 e5                	mov    %esp,%ebp
  800c5c:	57                   	push   %edi
  800c5d:	56                   	push   %esi
  800c5e:	53                   	push   %ebx
  800c5f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c62:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c65:	85 c9                	test   %ecx,%ecx
  800c67:	74 36                	je     800c9f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c69:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c6f:	75 28                	jne    800c99 <memset+0x40>
  800c71:	f6 c1 03             	test   $0x3,%cl
  800c74:	75 23                	jne    800c99 <memset+0x40>
		c &= 0xFF;
  800c76:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c7a:	89 d3                	mov    %edx,%ebx
  800c7c:	c1 e3 08             	shl    $0x8,%ebx
  800c7f:	89 d6                	mov    %edx,%esi
  800c81:	c1 e6 18             	shl    $0x18,%esi
  800c84:	89 d0                	mov    %edx,%eax
  800c86:	c1 e0 10             	shl    $0x10,%eax
  800c89:	09 f0                	or     %esi,%eax
  800c8b:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800c8d:	89 d8                	mov    %ebx,%eax
  800c8f:	09 d0                	or     %edx,%eax
  800c91:	c1 e9 02             	shr    $0x2,%ecx
  800c94:	fc                   	cld    
  800c95:	f3 ab                	rep stos %eax,%es:(%edi)
  800c97:	eb 06                	jmp    800c9f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c99:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c9c:	fc                   	cld    
  800c9d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c9f:	89 f8                	mov    %edi,%eax
  800ca1:	5b                   	pop    %ebx
  800ca2:	5e                   	pop    %esi
  800ca3:	5f                   	pop    %edi
  800ca4:	5d                   	pop    %ebp
  800ca5:	c3                   	ret    

00800ca6 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ca6:	55                   	push   %ebp
  800ca7:	89 e5                	mov    %esp,%ebp
  800ca9:	57                   	push   %edi
  800caa:	56                   	push   %esi
  800cab:	8b 45 08             	mov    0x8(%ebp),%eax
  800cae:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cb1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800cb4:	39 c6                	cmp    %eax,%esi
  800cb6:	73 33                	jae    800ceb <memmove+0x45>
  800cb8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800cbb:	39 d0                	cmp    %edx,%eax
  800cbd:	73 2c                	jae    800ceb <memmove+0x45>
		s += n;
		d += n;
  800cbf:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cc2:	89 d6                	mov    %edx,%esi
  800cc4:	09 fe                	or     %edi,%esi
  800cc6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ccc:	75 13                	jne    800ce1 <memmove+0x3b>
  800cce:	f6 c1 03             	test   $0x3,%cl
  800cd1:	75 0e                	jne    800ce1 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800cd3:	83 ef 04             	sub    $0x4,%edi
  800cd6:	8d 72 fc             	lea    -0x4(%edx),%esi
  800cd9:	c1 e9 02             	shr    $0x2,%ecx
  800cdc:	fd                   	std    
  800cdd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800cdf:	eb 07                	jmp    800ce8 <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ce1:	4f                   	dec    %edi
  800ce2:	8d 72 ff             	lea    -0x1(%edx),%esi
  800ce5:	fd                   	std    
  800ce6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ce8:	fc                   	cld    
  800ce9:	eb 1d                	jmp    800d08 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ceb:	89 f2                	mov    %esi,%edx
  800ced:	09 c2                	or     %eax,%edx
  800cef:	f6 c2 03             	test   $0x3,%dl
  800cf2:	75 0f                	jne    800d03 <memmove+0x5d>
  800cf4:	f6 c1 03             	test   $0x3,%cl
  800cf7:	75 0a                	jne    800d03 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
  800cf9:	c1 e9 02             	shr    $0x2,%ecx
  800cfc:	89 c7                	mov    %eax,%edi
  800cfe:	fc                   	cld    
  800cff:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d01:	eb 05                	jmp    800d08 <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d03:	89 c7                	mov    %eax,%edi
  800d05:	fc                   	cld    
  800d06:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d08:	5e                   	pop    %esi
  800d09:	5f                   	pop    %edi
  800d0a:	5d                   	pop    %ebp
  800d0b:	c3                   	ret    

00800d0c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d0c:	55                   	push   %ebp
  800d0d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800d0f:	ff 75 10             	pushl  0x10(%ebp)
  800d12:	ff 75 0c             	pushl  0xc(%ebp)
  800d15:	ff 75 08             	pushl  0x8(%ebp)
  800d18:	e8 89 ff ff ff       	call   800ca6 <memmove>
}
  800d1d:	c9                   	leave  
  800d1e:	c3                   	ret    

00800d1f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d1f:	55                   	push   %ebp
  800d20:	89 e5                	mov    %esp,%ebp
  800d22:	57                   	push   %edi
  800d23:	56                   	push   %esi
  800d24:	53                   	push   %ebx
  800d25:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800d28:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d2b:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d2e:	85 c0                	test   %eax,%eax
  800d30:	74 33                	je     800d65 <memcmp+0x46>
  800d32:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800d35:	8a 13                	mov    (%ebx),%dl
  800d37:	8a 0e                	mov    (%esi),%cl
  800d39:	38 ca                	cmp    %cl,%dl
  800d3b:	75 13                	jne    800d50 <memcmp+0x31>
  800d3d:	b8 00 00 00 00       	mov    $0x0,%eax
  800d42:	eb 16                	jmp    800d5a <memcmp+0x3b>
  800d44:	8a 54 03 01          	mov    0x1(%ebx,%eax,1),%dl
  800d48:	40                   	inc    %eax
  800d49:	8a 0c 06             	mov    (%esi,%eax,1),%cl
  800d4c:	38 ca                	cmp    %cl,%dl
  800d4e:	74 0a                	je     800d5a <memcmp+0x3b>
			return (int) *s1 - (int) *s2;
  800d50:	0f b6 c2             	movzbl %dl,%eax
  800d53:	0f b6 c9             	movzbl %cl,%ecx
  800d56:	29 c8                	sub    %ecx,%eax
  800d58:	eb 10                	jmp    800d6a <memcmp+0x4b>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d5a:	39 f8                	cmp    %edi,%eax
  800d5c:	75 e6                	jne    800d44 <memcmp+0x25>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d5e:	b8 00 00 00 00       	mov    $0x0,%eax
  800d63:	eb 05                	jmp    800d6a <memcmp+0x4b>
  800d65:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d6a:	5b                   	pop    %ebx
  800d6b:	5e                   	pop    %esi
  800d6c:	5f                   	pop    %edi
  800d6d:	5d                   	pop    %ebp
  800d6e:	c3                   	ret    

00800d6f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d6f:	55                   	push   %ebp
  800d70:	89 e5                	mov    %esp,%ebp
  800d72:	53                   	push   %ebx
  800d73:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800d76:	89 d0                	mov    %edx,%eax
  800d78:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800d7b:	39 c2                	cmp    %eax,%edx
  800d7d:	73 1b                	jae    800d9a <memfind+0x2b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d7f:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800d83:	0f b6 0a             	movzbl (%edx),%ecx
  800d86:	39 d9                	cmp    %ebx,%ecx
  800d88:	75 09                	jne    800d93 <memfind+0x24>
  800d8a:	eb 12                	jmp    800d9e <memfind+0x2f>
  800d8c:	0f b6 0a             	movzbl (%edx),%ecx
  800d8f:	39 d9                	cmp    %ebx,%ecx
  800d91:	74 0f                	je     800da2 <memfind+0x33>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d93:	42                   	inc    %edx
  800d94:	39 d0                	cmp    %edx,%eax
  800d96:	75 f4                	jne    800d8c <memfind+0x1d>
  800d98:	eb 0a                	jmp    800da4 <memfind+0x35>
  800d9a:	89 d0                	mov    %edx,%eax
  800d9c:	eb 06                	jmp    800da4 <memfind+0x35>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d9e:	89 d0                	mov    %edx,%eax
  800da0:	eb 02                	jmp    800da4 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800da2:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800da4:	5b                   	pop    %ebx
  800da5:	5d                   	pop    %ebp
  800da6:	c3                   	ret    

00800da7 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800da7:	55                   	push   %ebp
  800da8:	89 e5                	mov    %esp,%ebp
  800daa:	57                   	push   %edi
  800dab:	56                   	push   %esi
  800dac:	53                   	push   %ebx
  800dad:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800db0:	eb 01                	jmp    800db3 <strtol+0xc>
		s++;
  800db2:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800db3:	8a 01                	mov    (%ecx),%al
  800db5:	3c 20                	cmp    $0x20,%al
  800db7:	74 f9                	je     800db2 <strtol+0xb>
  800db9:	3c 09                	cmp    $0x9,%al
  800dbb:	74 f5                	je     800db2 <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  800dbd:	3c 2b                	cmp    $0x2b,%al
  800dbf:	75 08                	jne    800dc9 <strtol+0x22>
		s++;
  800dc1:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800dc2:	bf 00 00 00 00       	mov    $0x0,%edi
  800dc7:	eb 11                	jmp    800dda <strtol+0x33>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800dc9:	3c 2d                	cmp    $0x2d,%al
  800dcb:	75 08                	jne    800dd5 <strtol+0x2e>
		s++, neg = 1;
  800dcd:	41                   	inc    %ecx
  800dce:	bf 01 00 00 00       	mov    $0x1,%edi
  800dd3:	eb 05                	jmp    800dda <strtol+0x33>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800dd5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800dda:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800dde:	0f 84 87 00 00 00    	je     800e6b <strtol+0xc4>
  800de4:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800de8:	75 27                	jne    800e11 <strtol+0x6a>
  800dea:	80 39 30             	cmpb   $0x30,(%ecx)
  800ded:	75 22                	jne    800e11 <strtol+0x6a>
  800def:	e9 88 00 00 00       	jmp    800e7c <strtol+0xd5>
		s += 2, base = 16;
  800df4:	83 c1 02             	add    $0x2,%ecx
  800df7:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800dfe:	eb 11                	jmp    800e11 <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
  800e00:	41                   	inc    %ecx
  800e01:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800e08:	eb 07                	jmp    800e11 <strtol+0x6a>
	else if (base == 0)
		base = 10;
  800e0a:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  800e11:	b8 00 00 00 00       	mov    $0x0,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e16:	8a 11                	mov    (%ecx),%dl
  800e18:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800e1b:	80 fb 09             	cmp    $0x9,%bl
  800e1e:	77 08                	ja     800e28 <strtol+0x81>
			dig = *s - '0';
  800e20:	0f be d2             	movsbl %dl,%edx
  800e23:	83 ea 30             	sub    $0x30,%edx
  800e26:	eb 22                	jmp    800e4a <strtol+0xa3>
		else if (*s >= 'a' && *s <= 'z')
  800e28:	8d 72 9f             	lea    -0x61(%edx),%esi
  800e2b:	89 f3                	mov    %esi,%ebx
  800e2d:	80 fb 19             	cmp    $0x19,%bl
  800e30:	77 08                	ja     800e3a <strtol+0x93>
			dig = *s - 'a' + 10;
  800e32:	0f be d2             	movsbl %dl,%edx
  800e35:	83 ea 57             	sub    $0x57,%edx
  800e38:	eb 10                	jmp    800e4a <strtol+0xa3>
		else if (*s >= 'A' && *s <= 'Z')
  800e3a:	8d 72 bf             	lea    -0x41(%edx),%esi
  800e3d:	89 f3                	mov    %esi,%ebx
  800e3f:	80 fb 19             	cmp    $0x19,%bl
  800e42:	77 14                	ja     800e58 <strtol+0xb1>
			dig = *s - 'A' + 10;
  800e44:	0f be d2             	movsbl %dl,%edx
  800e47:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800e4a:	3b 55 10             	cmp    0x10(%ebp),%edx
  800e4d:	7d 09                	jge    800e58 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800e4f:	41                   	inc    %ecx
  800e50:	0f af 45 10          	imul   0x10(%ebp),%eax
  800e54:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800e56:	eb be                	jmp    800e16 <strtol+0x6f>

	if (endptr)
  800e58:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e5c:	74 05                	je     800e63 <strtol+0xbc>
		*endptr = (char *) s;
  800e5e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e61:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800e63:	85 ff                	test   %edi,%edi
  800e65:	74 21                	je     800e88 <strtol+0xe1>
  800e67:	f7 d8                	neg    %eax
  800e69:	eb 1d                	jmp    800e88 <strtol+0xe1>
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e6b:	80 39 30             	cmpb   $0x30,(%ecx)
  800e6e:	75 9a                	jne    800e0a <strtol+0x63>
  800e70:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800e74:	0f 84 7a ff ff ff    	je     800df4 <strtol+0x4d>
  800e7a:	eb 84                	jmp    800e00 <strtol+0x59>
  800e7c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800e80:	0f 84 6e ff ff ff    	je     800df4 <strtol+0x4d>
  800e86:	eb 89                	jmp    800e11 <strtol+0x6a>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  800e88:	5b                   	pop    %ebx
  800e89:	5e                   	pop    %esi
  800e8a:	5f                   	pop    %edi
  800e8b:	5d                   	pop    %ebp
  800e8c:	c3                   	ret    

00800e8d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800e8d:	55                   	push   %ebp
  800e8e:	89 e5                	mov    %esp,%ebp
  800e90:	57                   	push   %edi
  800e91:	56                   	push   %esi
  800e92:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e93:	b8 00 00 00 00       	mov    $0x0,%eax
  800e98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9e:	89 c3                	mov    %eax,%ebx
  800ea0:	89 c7                	mov    %eax,%edi
  800ea2:	89 c6                	mov    %eax,%esi
  800ea4:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ea6:	5b                   	pop    %ebx
  800ea7:	5e                   	pop    %esi
  800ea8:	5f                   	pop    %edi
  800ea9:	5d                   	pop    %ebp
  800eaa:	c3                   	ret    

00800eab <sys_cgetc>:

int
sys_cgetc(void)
{
  800eab:	55                   	push   %ebp
  800eac:	89 e5                	mov    %esp,%ebp
  800eae:	57                   	push   %edi
  800eaf:	56                   	push   %esi
  800eb0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb1:	ba 00 00 00 00       	mov    $0x0,%edx
  800eb6:	b8 01 00 00 00       	mov    $0x1,%eax
  800ebb:	89 d1                	mov    %edx,%ecx
  800ebd:	89 d3                	mov    %edx,%ebx
  800ebf:	89 d7                	mov    %edx,%edi
  800ec1:	89 d6                	mov    %edx,%esi
  800ec3:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ec5:	5b                   	pop    %ebx
  800ec6:	5e                   	pop    %esi
  800ec7:	5f                   	pop    %edi
  800ec8:	5d                   	pop    %ebp
  800ec9:	c3                   	ret    

00800eca <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800eca:	55                   	push   %ebp
  800ecb:	89 e5                	mov    %esp,%ebp
  800ecd:	57                   	push   %edi
  800ece:	56                   	push   %esi
  800ecf:	53                   	push   %ebx
  800ed0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ed8:	b8 03 00 00 00       	mov    $0x3,%eax
  800edd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee0:	89 cb                	mov    %ecx,%ebx
  800ee2:	89 cf                	mov    %ecx,%edi
  800ee4:	89 ce                	mov    %ecx,%esi
  800ee6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ee8:	85 c0                	test   %eax,%eax
  800eea:	7e 17                	jle    800f03 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eec:	83 ec 0c             	sub    $0xc,%esp
  800eef:	50                   	push   %eax
  800ef0:	6a 03                	push   $0x3
  800ef2:	68 bf 2a 80 00       	push   $0x802abf
  800ef7:	6a 23                	push   $0x23
  800ef9:	68 dc 2a 80 00       	push   $0x802adc
  800efe:	e8 19 f5 ff ff       	call   80041c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800f03:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f06:	5b                   	pop    %ebx
  800f07:	5e                   	pop    %esi
  800f08:	5f                   	pop    %edi
  800f09:	5d                   	pop    %ebp
  800f0a:	c3                   	ret    

00800f0b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800f0b:	55                   	push   %ebp
  800f0c:	89 e5                	mov    %esp,%ebp
  800f0e:	57                   	push   %edi
  800f0f:	56                   	push   %esi
  800f10:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f11:	ba 00 00 00 00       	mov    $0x0,%edx
  800f16:	b8 02 00 00 00       	mov    $0x2,%eax
  800f1b:	89 d1                	mov    %edx,%ecx
  800f1d:	89 d3                	mov    %edx,%ebx
  800f1f:	89 d7                	mov    %edx,%edi
  800f21:	89 d6                	mov    %edx,%esi
  800f23:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f25:	5b                   	pop    %ebx
  800f26:	5e                   	pop    %esi
  800f27:	5f                   	pop    %edi
  800f28:	5d                   	pop    %ebp
  800f29:	c3                   	ret    

00800f2a <sys_yield>:

void
sys_yield(void)
{
  800f2a:	55                   	push   %ebp
  800f2b:	89 e5                	mov    %esp,%ebp
  800f2d:	57                   	push   %edi
  800f2e:	56                   	push   %esi
  800f2f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f30:	ba 00 00 00 00       	mov    $0x0,%edx
  800f35:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f3a:	89 d1                	mov    %edx,%ecx
  800f3c:	89 d3                	mov    %edx,%ebx
  800f3e:	89 d7                	mov    %edx,%edi
  800f40:	89 d6                	mov    %edx,%esi
  800f42:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f44:	5b                   	pop    %ebx
  800f45:	5e                   	pop    %esi
  800f46:	5f                   	pop    %edi
  800f47:	5d                   	pop    %ebp
  800f48:	c3                   	ret    

00800f49 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f49:	55                   	push   %ebp
  800f4a:	89 e5                	mov    %esp,%ebp
  800f4c:	57                   	push   %edi
  800f4d:	56                   	push   %esi
  800f4e:	53                   	push   %ebx
  800f4f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f52:	be 00 00 00 00       	mov    $0x0,%esi
  800f57:	b8 04 00 00 00       	mov    $0x4,%eax
  800f5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f5f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f62:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f65:	89 f7                	mov    %esi,%edi
  800f67:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f69:	85 c0                	test   %eax,%eax
  800f6b:	7e 17                	jle    800f84 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f6d:	83 ec 0c             	sub    $0xc,%esp
  800f70:	50                   	push   %eax
  800f71:	6a 04                	push   $0x4
  800f73:	68 bf 2a 80 00       	push   $0x802abf
  800f78:	6a 23                	push   $0x23
  800f7a:	68 dc 2a 80 00       	push   $0x802adc
  800f7f:	e8 98 f4 ff ff       	call   80041c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f84:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f87:	5b                   	pop    %ebx
  800f88:	5e                   	pop    %esi
  800f89:	5f                   	pop    %edi
  800f8a:	5d                   	pop    %ebp
  800f8b:	c3                   	ret    

00800f8c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f8c:	55                   	push   %ebp
  800f8d:	89 e5                	mov    %esp,%ebp
  800f8f:	57                   	push   %edi
  800f90:	56                   	push   %esi
  800f91:	53                   	push   %ebx
  800f92:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f95:	b8 05 00 00 00       	mov    $0x5,%eax
  800f9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fa3:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fa6:	8b 75 18             	mov    0x18(%ebp),%esi
  800fa9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fab:	85 c0                	test   %eax,%eax
  800fad:	7e 17                	jle    800fc6 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800faf:	83 ec 0c             	sub    $0xc,%esp
  800fb2:	50                   	push   %eax
  800fb3:	6a 05                	push   $0x5
  800fb5:	68 bf 2a 80 00       	push   $0x802abf
  800fba:	6a 23                	push   $0x23
  800fbc:	68 dc 2a 80 00       	push   $0x802adc
  800fc1:	e8 56 f4 ff ff       	call   80041c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800fc6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fc9:	5b                   	pop    %ebx
  800fca:	5e                   	pop    %esi
  800fcb:	5f                   	pop    %edi
  800fcc:	5d                   	pop    %ebp
  800fcd:	c3                   	ret    

00800fce <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800fce:	55                   	push   %ebp
  800fcf:	89 e5                	mov    %esp,%ebp
  800fd1:	57                   	push   %edi
  800fd2:	56                   	push   %esi
  800fd3:	53                   	push   %ebx
  800fd4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fd7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fdc:	b8 06 00 00 00       	mov    $0x6,%eax
  800fe1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fe4:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe7:	89 df                	mov    %ebx,%edi
  800fe9:	89 de                	mov    %ebx,%esi
  800feb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fed:	85 c0                	test   %eax,%eax
  800fef:	7e 17                	jle    801008 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ff1:	83 ec 0c             	sub    $0xc,%esp
  800ff4:	50                   	push   %eax
  800ff5:	6a 06                	push   $0x6
  800ff7:	68 bf 2a 80 00       	push   $0x802abf
  800ffc:	6a 23                	push   $0x23
  800ffe:	68 dc 2a 80 00       	push   $0x802adc
  801003:	e8 14 f4 ff ff       	call   80041c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801008:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80100b:	5b                   	pop    %ebx
  80100c:	5e                   	pop    %esi
  80100d:	5f                   	pop    %edi
  80100e:	5d                   	pop    %ebp
  80100f:	c3                   	ret    

00801010 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801010:	55                   	push   %ebp
  801011:	89 e5                	mov    %esp,%ebp
  801013:	57                   	push   %edi
  801014:	56                   	push   %esi
  801015:	53                   	push   %ebx
  801016:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801019:	bb 00 00 00 00       	mov    $0x0,%ebx
  80101e:	b8 08 00 00 00       	mov    $0x8,%eax
  801023:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801026:	8b 55 08             	mov    0x8(%ebp),%edx
  801029:	89 df                	mov    %ebx,%edi
  80102b:	89 de                	mov    %ebx,%esi
  80102d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80102f:	85 c0                	test   %eax,%eax
  801031:	7e 17                	jle    80104a <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801033:	83 ec 0c             	sub    $0xc,%esp
  801036:	50                   	push   %eax
  801037:	6a 08                	push   $0x8
  801039:	68 bf 2a 80 00       	push   $0x802abf
  80103e:	6a 23                	push   $0x23
  801040:	68 dc 2a 80 00       	push   $0x802adc
  801045:	e8 d2 f3 ff ff       	call   80041c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80104a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80104d:	5b                   	pop    %ebx
  80104e:	5e                   	pop    %esi
  80104f:	5f                   	pop    %edi
  801050:	5d                   	pop    %ebp
  801051:	c3                   	ret    

00801052 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801052:	55                   	push   %ebp
  801053:	89 e5                	mov    %esp,%ebp
  801055:	57                   	push   %edi
  801056:	56                   	push   %esi
  801057:	53                   	push   %ebx
  801058:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80105b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801060:	b8 09 00 00 00       	mov    $0x9,%eax
  801065:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801068:	8b 55 08             	mov    0x8(%ebp),%edx
  80106b:	89 df                	mov    %ebx,%edi
  80106d:	89 de                	mov    %ebx,%esi
  80106f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801071:	85 c0                	test   %eax,%eax
  801073:	7e 17                	jle    80108c <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801075:	83 ec 0c             	sub    $0xc,%esp
  801078:	50                   	push   %eax
  801079:	6a 09                	push   $0x9
  80107b:	68 bf 2a 80 00       	push   $0x802abf
  801080:	6a 23                	push   $0x23
  801082:	68 dc 2a 80 00       	push   $0x802adc
  801087:	e8 90 f3 ff ff       	call   80041c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80108c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80108f:	5b                   	pop    %ebx
  801090:	5e                   	pop    %esi
  801091:	5f                   	pop    %edi
  801092:	5d                   	pop    %ebp
  801093:	c3                   	ret    

00801094 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801094:	55                   	push   %ebp
  801095:	89 e5                	mov    %esp,%ebp
  801097:	57                   	push   %edi
  801098:	56                   	push   %esi
  801099:	53                   	push   %ebx
  80109a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80109d:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010a2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8010ad:	89 df                	mov    %ebx,%edi
  8010af:	89 de                	mov    %ebx,%esi
  8010b1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010b3:	85 c0                	test   %eax,%eax
  8010b5:	7e 17                	jle    8010ce <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010b7:	83 ec 0c             	sub    $0xc,%esp
  8010ba:	50                   	push   %eax
  8010bb:	6a 0a                	push   $0xa
  8010bd:	68 bf 2a 80 00       	push   $0x802abf
  8010c2:	6a 23                	push   $0x23
  8010c4:	68 dc 2a 80 00       	push   $0x802adc
  8010c9:	e8 4e f3 ff ff       	call   80041c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8010ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d1:	5b                   	pop    %ebx
  8010d2:	5e                   	pop    %esi
  8010d3:	5f                   	pop    %edi
  8010d4:	5d                   	pop    %ebp
  8010d5:	c3                   	ret    

008010d6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010d6:	55                   	push   %ebp
  8010d7:	89 e5                	mov    %esp,%ebp
  8010d9:	57                   	push   %edi
  8010da:	56                   	push   %esi
  8010db:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010dc:	be 00 00 00 00       	mov    $0x0,%esi
  8010e1:	b8 0c 00 00 00       	mov    $0xc,%eax
  8010e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8010ec:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010ef:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010f2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8010f4:	5b                   	pop    %ebx
  8010f5:	5e                   	pop    %esi
  8010f6:	5f                   	pop    %edi
  8010f7:	5d                   	pop    %ebp
  8010f8:	c3                   	ret    

008010f9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8010f9:	55                   	push   %ebp
  8010fa:	89 e5                	mov    %esp,%ebp
  8010fc:	57                   	push   %edi
  8010fd:	56                   	push   %esi
  8010fe:	53                   	push   %ebx
  8010ff:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801102:	b9 00 00 00 00       	mov    $0x0,%ecx
  801107:	b8 0d 00 00 00       	mov    $0xd,%eax
  80110c:	8b 55 08             	mov    0x8(%ebp),%edx
  80110f:	89 cb                	mov    %ecx,%ebx
  801111:	89 cf                	mov    %ecx,%edi
  801113:	89 ce                	mov    %ecx,%esi
  801115:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801117:	85 c0                	test   %eax,%eax
  801119:	7e 17                	jle    801132 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80111b:	83 ec 0c             	sub    $0xc,%esp
  80111e:	50                   	push   %eax
  80111f:	6a 0d                	push   $0xd
  801121:	68 bf 2a 80 00       	push   $0x802abf
  801126:	6a 23                	push   $0x23
  801128:	68 dc 2a 80 00       	push   $0x802adc
  80112d:	e8 ea f2 ff ff       	call   80041c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801132:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801135:	5b                   	pop    %ebx
  801136:	5e                   	pop    %esi
  801137:	5f                   	pop    %edi
  801138:	5d                   	pop    %ebp
  801139:	c3                   	ret    

0080113a <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80113a:	55                   	push   %ebp
  80113b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80113d:	8b 45 08             	mov    0x8(%ebp),%eax
  801140:	05 00 00 00 30       	add    $0x30000000,%eax
  801145:	c1 e8 0c             	shr    $0xc,%eax
}
  801148:	5d                   	pop    %ebp
  801149:	c3                   	ret    

0080114a <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80114a:	55                   	push   %ebp
  80114b:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80114d:	8b 45 08             	mov    0x8(%ebp),%eax
  801150:	05 00 00 00 30       	add    $0x30000000,%eax
  801155:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80115a:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80115f:	5d                   	pop    %ebp
  801160:	c3                   	ret    

00801161 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801161:	55                   	push   %ebp
  801162:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801164:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801169:	a8 01                	test   $0x1,%al
  80116b:	74 34                	je     8011a1 <fd_alloc+0x40>
  80116d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801172:	a8 01                	test   $0x1,%al
  801174:	74 32                	je     8011a8 <fd_alloc+0x47>
  801176:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80117b:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80117d:	89 c2                	mov    %eax,%edx
  80117f:	c1 ea 16             	shr    $0x16,%edx
  801182:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801189:	f6 c2 01             	test   $0x1,%dl
  80118c:	74 1f                	je     8011ad <fd_alloc+0x4c>
  80118e:	89 c2                	mov    %eax,%edx
  801190:	c1 ea 0c             	shr    $0xc,%edx
  801193:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80119a:	f6 c2 01             	test   $0x1,%dl
  80119d:	75 1a                	jne    8011b9 <fd_alloc+0x58>
  80119f:	eb 0c                	jmp    8011ad <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8011a1:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8011a6:	eb 05                	jmp    8011ad <fd_alloc+0x4c>
  8011a8:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8011ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b0:	89 08                	mov    %ecx,(%eax)
			return 0;
  8011b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8011b7:	eb 1a                	jmp    8011d3 <fd_alloc+0x72>
  8011b9:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011be:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011c3:	75 b6                	jne    80117b <fd_alloc+0x1a>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  8011ce:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011d3:	5d                   	pop    %ebp
  8011d4:	c3                   	ret    

008011d5 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011d5:	55                   	push   %ebp
  8011d6:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011d8:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  8011dc:	77 39                	ja     801217 <fd_lookup+0x42>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011de:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e1:	c1 e0 0c             	shl    $0xc,%eax
  8011e4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011e9:	89 c2                	mov    %eax,%edx
  8011eb:	c1 ea 16             	shr    $0x16,%edx
  8011ee:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011f5:	f6 c2 01             	test   $0x1,%dl
  8011f8:	74 24                	je     80121e <fd_lookup+0x49>
  8011fa:	89 c2                	mov    %eax,%edx
  8011fc:	c1 ea 0c             	shr    $0xc,%edx
  8011ff:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801206:	f6 c2 01             	test   $0x1,%dl
  801209:	74 1a                	je     801225 <fd_lookup+0x50>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80120b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80120e:	89 02                	mov    %eax,(%edx)
	return 0;
  801210:	b8 00 00 00 00       	mov    $0x0,%eax
  801215:	eb 13                	jmp    80122a <fd_lookup+0x55>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801217:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80121c:	eb 0c                	jmp    80122a <fd_lookup+0x55>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80121e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801223:	eb 05                	jmp    80122a <fd_lookup+0x55>
  801225:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80122a:	5d                   	pop    %ebp
  80122b:	c3                   	ret    

0080122c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80122c:	55                   	push   %ebp
  80122d:	89 e5                	mov    %esp,%ebp
  80122f:	53                   	push   %ebx
  801230:	83 ec 04             	sub    $0x4,%esp
  801233:	8b 45 08             	mov    0x8(%ebp),%eax
  801236:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801239:	3b 05 90 47 80 00    	cmp    0x804790,%eax
  80123f:	75 1e                	jne    80125f <dev_lookup+0x33>
  801241:	eb 0e                	jmp    801251 <dev_lookup+0x25>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801243:	b8 ac 47 80 00       	mov    $0x8047ac,%eax
  801248:	eb 0c                	jmp    801256 <dev_lookup+0x2a>
  80124a:	b8 70 47 80 00       	mov    $0x804770,%eax
  80124f:	eb 05                	jmp    801256 <dev_lookup+0x2a>
  801251:	b8 90 47 80 00       	mov    $0x804790,%eax
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801256:	89 03                	mov    %eax,(%ebx)
			return 0;
  801258:	b8 00 00 00 00       	mov    $0x0,%eax
  80125d:	eb 36                	jmp    801295 <dev_lookup+0x69>
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80125f:	3b 05 ac 47 80 00    	cmp    0x8047ac,%eax
  801265:	74 dc                	je     801243 <dev_lookup+0x17>
  801267:	3b 05 70 47 80 00    	cmp    0x804770,%eax
  80126d:	74 db                	je     80124a <dev_lookup+0x1e>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80126f:	8b 15 90 67 80 00    	mov    0x806790,%edx
  801275:	8b 52 48             	mov    0x48(%edx),%edx
  801278:	83 ec 04             	sub    $0x4,%esp
  80127b:	50                   	push   %eax
  80127c:	52                   	push   %edx
  80127d:	68 ec 2a 80 00       	push   $0x802aec
  801282:	e8 6d f2 ff ff       	call   8004f4 <cprintf>
	*dev = 0;
  801287:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80128d:	83 c4 10             	add    $0x10,%esp
  801290:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801295:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801298:	c9                   	leave  
  801299:	c3                   	ret    

0080129a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80129a:	55                   	push   %ebp
  80129b:	89 e5                	mov    %esp,%ebp
  80129d:	56                   	push   %esi
  80129e:	53                   	push   %ebx
  80129f:	83 ec 10             	sub    $0x10,%esp
  8012a2:	8b 75 08             	mov    0x8(%ebp),%esi
  8012a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012ab:	50                   	push   %eax
  8012ac:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012b2:	c1 e8 0c             	shr    $0xc,%eax
  8012b5:	50                   	push   %eax
  8012b6:	e8 1a ff ff ff       	call   8011d5 <fd_lookup>
  8012bb:	83 c4 08             	add    $0x8,%esp
  8012be:	85 c0                	test   %eax,%eax
  8012c0:	78 05                	js     8012c7 <fd_close+0x2d>
	    || fd != fd2)
  8012c2:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012c5:	74 06                	je     8012cd <fd_close+0x33>
		return (must_exist ? r : 0);
  8012c7:	84 db                	test   %bl,%bl
  8012c9:	74 47                	je     801312 <fd_close+0x78>
  8012cb:	eb 4a                	jmp    801317 <fd_close+0x7d>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012cd:	83 ec 08             	sub    $0x8,%esp
  8012d0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012d3:	50                   	push   %eax
  8012d4:	ff 36                	pushl  (%esi)
  8012d6:	e8 51 ff ff ff       	call   80122c <dev_lookup>
  8012db:	89 c3                	mov    %eax,%ebx
  8012dd:	83 c4 10             	add    $0x10,%esp
  8012e0:	85 c0                	test   %eax,%eax
  8012e2:	78 1c                	js     801300 <fd_close+0x66>
		if (dev->dev_close)
  8012e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012e7:	8b 40 10             	mov    0x10(%eax),%eax
  8012ea:	85 c0                	test   %eax,%eax
  8012ec:	74 0d                	je     8012fb <fd_close+0x61>
			r = (*dev->dev_close)(fd);
  8012ee:	83 ec 0c             	sub    $0xc,%esp
  8012f1:	56                   	push   %esi
  8012f2:	ff d0                	call   *%eax
  8012f4:	89 c3                	mov    %eax,%ebx
  8012f6:	83 c4 10             	add    $0x10,%esp
  8012f9:	eb 05                	jmp    801300 <fd_close+0x66>
		else
			r = 0;
  8012fb:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801300:	83 ec 08             	sub    $0x8,%esp
  801303:	56                   	push   %esi
  801304:	6a 00                	push   $0x0
  801306:	e8 c3 fc ff ff       	call   800fce <sys_page_unmap>
	return r;
  80130b:	83 c4 10             	add    $0x10,%esp
  80130e:	89 d8                	mov    %ebx,%eax
  801310:	eb 05                	jmp    801317 <fd_close+0x7d>
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
  801312:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
	return r;
}
  801317:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80131a:	5b                   	pop    %ebx
  80131b:	5e                   	pop    %esi
  80131c:	5d                   	pop    %ebp
  80131d:	c3                   	ret    

0080131e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80131e:	55                   	push   %ebp
  80131f:	89 e5                	mov    %esp,%ebp
  801321:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801324:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801327:	50                   	push   %eax
  801328:	ff 75 08             	pushl  0x8(%ebp)
  80132b:	e8 a5 fe ff ff       	call   8011d5 <fd_lookup>
  801330:	83 c4 08             	add    $0x8,%esp
  801333:	85 c0                	test   %eax,%eax
  801335:	78 10                	js     801347 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801337:	83 ec 08             	sub    $0x8,%esp
  80133a:	6a 01                	push   $0x1
  80133c:	ff 75 f4             	pushl  -0xc(%ebp)
  80133f:	e8 56 ff ff ff       	call   80129a <fd_close>
  801344:	83 c4 10             	add    $0x10,%esp
}
  801347:	c9                   	leave  
  801348:	c3                   	ret    

00801349 <close_all>:

void
close_all(void)
{
  801349:	55                   	push   %ebp
  80134a:	89 e5                	mov    %esp,%ebp
  80134c:	53                   	push   %ebx
  80134d:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801350:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801355:	83 ec 0c             	sub    $0xc,%esp
  801358:	53                   	push   %ebx
  801359:	e8 c0 ff ff ff       	call   80131e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80135e:	43                   	inc    %ebx
  80135f:	83 c4 10             	add    $0x10,%esp
  801362:	83 fb 20             	cmp    $0x20,%ebx
  801365:	75 ee                	jne    801355 <close_all+0xc>
		close(i);
}
  801367:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80136a:	c9                   	leave  
  80136b:	c3                   	ret    

0080136c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80136c:	55                   	push   %ebp
  80136d:	89 e5                	mov    %esp,%ebp
  80136f:	57                   	push   %edi
  801370:	56                   	push   %esi
  801371:	53                   	push   %ebx
  801372:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801375:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801378:	50                   	push   %eax
  801379:	ff 75 08             	pushl  0x8(%ebp)
  80137c:	e8 54 fe ff ff       	call   8011d5 <fd_lookup>
  801381:	83 c4 08             	add    $0x8,%esp
  801384:	85 c0                	test   %eax,%eax
  801386:	0f 88 c2 00 00 00    	js     80144e <dup+0xe2>
		return r;
	close(newfdnum);
  80138c:	83 ec 0c             	sub    $0xc,%esp
  80138f:	ff 75 0c             	pushl  0xc(%ebp)
  801392:	e8 87 ff ff ff       	call   80131e <close>

	newfd = INDEX2FD(newfdnum);
  801397:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80139a:	c1 e3 0c             	shl    $0xc,%ebx
  80139d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013a3:	83 c4 04             	add    $0x4,%esp
  8013a6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013a9:	e8 9c fd ff ff       	call   80114a <fd2data>
  8013ae:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  8013b0:	89 1c 24             	mov    %ebx,(%esp)
  8013b3:	e8 92 fd ff ff       	call   80114a <fd2data>
  8013b8:	83 c4 10             	add    $0x10,%esp
  8013bb:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013bd:	89 f0                	mov    %esi,%eax
  8013bf:	c1 e8 16             	shr    $0x16,%eax
  8013c2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013c9:	a8 01                	test   $0x1,%al
  8013cb:	74 35                	je     801402 <dup+0x96>
  8013cd:	89 f0                	mov    %esi,%eax
  8013cf:	c1 e8 0c             	shr    $0xc,%eax
  8013d2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013d9:	f6 c2 01             	test   $0x1,%dl
  8013dc:	74 24                	je     801402 <dup+0x96>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013de:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013e5:	83 ec 0c             	sub    $0xc,%esp
  8013e8:	25 07 0e 00 00       	and    $0xe07,%eax
  8013ed:	50                   	push   %eax
  8013ee:	57                   	push   %edi
  8013ef:	6a 00                	push   $0x0
  8013f1:	56                   	push   %esi
  8013f2:	6a 00                	push   $0x0
  8013f4:	e8 93 fb ff ff       	call   800f8c <sys_page_map>
  8013f9:	89 c6                	mov    %eax,%esi
  8013fb:	83 c4 20             	add    $0x20,%esp
  8013fe:	85 c0                	test   %eax,%eax
  801400:	78 2c                	js     80142e <dup+0xc2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801402:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801405:	89 d0                	mov    %edx,%eax
  801407:	c1 e8 0c             	shr    $0xc,%eax
  80140a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801411:	83 ec 0c             	sub    $0xc,%esp
  801414:	25 07 0e 00 00       	and    $0xe07,%eax
  801419:	50                   	push   %eax
  80141a:	53                   	push   %ebx
  80141b:	6a 00                	push   $0x0
  80141d:	52                   	push   %edx
  80141e:	6a 00                	push   $0x0
  801420:	e8 67 fb ff ff       	call   800f8c <sys_page_map>
  801425:	89 c6                	mov    %eax,%esi
  801427:	83 c4 20             	add    $0x20,%esp
  80142a:	85 c0                	test   %eax,%eax
  80142c:	79 1d                	jns    80144b <dup+0xdf>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80142e:	83 ec 08             	sub    $0x8,%esp
  801431:	53                   	push   %ebx
  801432:	6a 00                	push   $0x0
  801434:	e8 95 fb ff ff       	call   800fce <sys_page_unmap>
	sys_page_unmap(0, nva);
  801439:	83 c4 08             	add    $0x8,%esp
  80143c:	57                   	push   %edi
  80143d:	6a 00                	push   $0x0
  80143f:	e8 8a fb ff ff       	call   800fce <sys_page_unmap>
	return r;
  801444:	83 c4 10             	add    $0x10,%esp
  801447:	89 f0                	mov    %esi,%eax
  801449:	eb 03                	jmp    80144e <dup+0xe2>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80144b:	8b 45 0c             	mov    0xc(%ebp),%eax

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80144e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801451:	5b                   	pop    %ebx
  801452:	5e                   	pop    %esi
  801453:	5f                   	pop    %edi
  801454:	5d                   	pop    %ebp
  801455:	c3                   	ret    

00801456 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801456:	55                   	push   %ebp
  801457:	89 e5                	mov    %esp,%ebp
  801459:	53                   	push   %ebx
  80145a:	83 ec 14             	sub    $0x14,%esp
  80145d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801460:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801463:	50                   	push   %eax
  801464:	53                   	push   %ebx
  801465:	e8 6b fd ff ff       	call   8011d5 <fd_lookup>
  80146a:	83 c4 08             	add    $0x8,%esp
  80146d:	85 c0                	test   %eax,%eax
  80146f:	78 67                	js     8014d8 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801471:	83 ec 08             	sub    $0x8,%esp
  801474:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801477:	50                   	push   %eax
  801478:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80147b:	ff 30                	pushl  (%eax)
  80147d:	e8 aa fd ff ff       	call   80122c <dev_lookup>
  801482:	83 c4 10             	add    $0x10,%esp
  801485:	85 c0                	test   %eax,%eax
  801487:	78 4f                	js     8014d8 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801489:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80148c:	8b 42 08             	mov    0x8(%edx),%eax
  80148f:	83 e0 03             	and    $0x3,%eax
  801492:	83 f8 01             	cmp    $0x1,%eax
  801495:	75 21                	jne    8014b8 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801497:	a1 90 67 80 00       	mov    0x806790,%eax
  80149c:	8b 40 48             	mov    0x48(%eax),%eax
  80149f:	83 ec 04             	sub    $0x4,%esp
  8014a2:	53                   	push   %ebx
  8014a3:	50                   	push   %eax
  8014a4:	68 2d 2b 80 00       	push   $0x802b2d
  8014a9:	e8 46 f0 ff ff       	call   8004f4 <cprintf>
		return -E_INVAL;
  8014ae:	83 c4 10             	add    $0x10,%esp
  8014b1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014b6:	eb 20                	jmp    8014d8 <read+0x82>
	}
	if (!dev->dev_read)
  8014b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014bb:	8b 40 08             	mov    0x8(%eax),%eax
  8014be:	85 c0                	test   %eax,%eax
  8014c0:	74 11                	je     8014d3 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014c2:	83 ec 04             	sub    $0x4,%esp
  8014c5:	ff 75 10             	pushl  0x10(%ebp)
  8014c8:	ff 75 0c             	pushl  0xc(%ebp)
  8014cb:	52                   	push   %edx
  8014cc:	ff d0                	call   *%eax
  8014ce:	83 c4 10             	add    $0x10,%esp
  8014d1:	eb 05                	jmp    8014d8 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014d3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8014d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014db:	c9                   	leave  
  8014dc:	c3                   	ret    

008014dd <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014dd:	55                   	push   %ebp
  8014de:	89 e5                	mov    %esp,%ebp
  8014e0:	57                   	push   %edi
  8014e1:	56                   	push   %esi
  8014e2:	53                   	push   %ebx
  8014e3:	83 ec 0c             	sub    $0xc,%esp
  8014e6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014e9:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014ec:	85 f6                	test   %esi,%esi
  8014ee:	74 31                	je     801521 <readn+0x44>
  8014f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8014f5:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014fa:	83 ec 04             	sub    $0x4,%esp
  8014fd:	89 f2                	mov    %esi,%edx
  8014ff:	29 c2                	sub    %eax,%edx
  801501:	52                   	push   %edx
  801502:	03 45 0c             	add    0xc(%ebp),%eax
  801505:	50                   	push   %eax
  801506:	57                   	push   %edi
  801507:	e8 4a ff ff ff       	call   801456 <read>
		if (m < 0)
  80150c:	83 c4 10             	add    $0x10,%esp
  80150f:	85 c0                	test   %eax,%eax
  801511:	78 17                	js     80152a <readn+0x4d>
			return m;
		if (m == 0)
  801513:	85 c0                	test   %eax,%eax
  801515:	74 11                	je     801528 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801517:	01 c3                	add    %eax,%ebx
  801519:	89 d8                	mov    %ebx,%eax
  80151b:	39 f3                	cmp    %esi,%ebx
  80151d:	72 db                	jb     8014fa <readn+0x1d>
  80151f:	eb 09                	jmp    80152a <readn+0x4d>
  801521:	b8 00 00 00 00       	mov    $0x0,%eax
  801526:	eb 02                	jmp    80152a <readn+0x4d>
  801528:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80152a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80152d:	5b                   	pop    %ebx
  80152e:	5e                   	pop    %esi
  80152f:	5f                   	pop    %edi
  801530:	5d                   	pop    %ebp
  801531:	c3                   	ret    

00801532 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801532:	55                   	push   %ebp
  801533:	89 e5                	mov    %esp,%ebp
  801535:	53                   	push   %ebx
  801536:	83 ec 14             	sub    $0x14,%esp
  801539:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80153c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80153f:	50                   	push   %eax
  801540:	53                   	push   %ebx
  801541:	e8 8f fc ff ff       	call   8011d5 <fd_lookup>
  801546:	83 c4 08             	add    $0x8,%esp
  801549:	85 c0                	test   %eax,%eax
  80154b:	78 62                	js     8015af <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80154d:	83 ec 08             	sub    $0x8,%esp
  801550:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801553:	50                   	push   %eax
  801554:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801557:	ff 30                	pushl  (%eax)
  801559:	e8 ce fc ff ff       	call   80122c <dev_lookup>
  80155e:	83 c4 10             	add    $0x10,%esp
  801561:	85 c0                	test   %eax,%eax
  801563:	78 4a                	js     8015af <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801565:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801568:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80156c:	75 21                	jne    80158f <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80156e:	a1 90 67 80 00       	mov    0x806790,%eax
  801573:	8b 40 48             	mov    0x48(%eax),%eax
  801576:	83 ec 04             	sub    $0x4,%esp
  801579:	53                   	push   %ebx
  80157a:	50                   	push   %eax
  80157b:	68 49 2b 80 00       	push   $0x802b49
  801580:	e8 6f ef ff ff       	call   8004f4 <cprintf>
		return -E_INVAL;
  801585:	83 c4 10             	add    $0x10,%esp
  801588:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80158d:	eb 20                	jmp    8015af <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80158f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801592:	8b 52 0c             	mov    0xc(%edx),%edx
  801595:	85 d2                	test   %edx,%edx
  801597:	74 11                	je     8015aa <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801599:	83 ec 04             	sub    $0x4,%esp
  80159c:	ff 75 10             	pushl  0x10(%ebp)
  80159f:	ff 75 0c             	pushl  0xc(%ebp)
  8015a2:	50                   	push   %eax
  8015a3:	ff d2                	call   *%edx
  8015a5:	83 c4 10             	add    $0x10,%esp
  8015a8:	eb 05                	jmp    8015af <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015aa:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8015af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015b2:	c9                   	leave  
  8015b3:	c3                   	ret    

008015b4 <seek>:

int
seek(int fdnum, off_t offset)
{
  8015b4:	55                   	push   %ebp
  8015b5:	89 e5                	mov    %esp,%ebp
  8015b7:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015ba:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015bd:	50                   	push   %eax
  8015be:	ff 75 08             	pushl  0x8(%ebp)
  8015c1:	e8 0f fc ff ff       	call   8011d5 <fd_lookup>
  8015c6:	83 c4 08             	add    $0x8,%esp
  8015c9:	85 c0                	test   %eax,%eax
  8015cb:	78 0e                	js     8015db <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015d0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015d3:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015d6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015db:	c9                   	leave  
  8015dc:	c3                   	ret    

008015dd <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015dd:	55                   	push   %ebp
  8015de:	89 e5                	mov    %esp,%ebp
  8015e0:	53                   	push   %ebx
  8015e1:	83 ec 14             	sub    $0x14,%esp
  8015e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015e7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015ea:	50                   	push   %eax
  8015eb:	53                   	push   %ebx
  8015ec:	e8 e4 fb ff ff       	call   8011d5 <fd_lookup>
  8015f1:	83 c4 08             	add    $0x8,%esp
  8015f4:	85 c0                	test   %eax,%eax
  8015f6:	78 5f                	js     801657 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015f8:	83 ec 08             	sub    $0x8,%esp
  8015fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015fe:	50                   	push   %eax
  8015ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801602:	ff 30                	pushl  (%eax)
  801604:	e8 23 fc ff ff       	call   80122c <dev_lookup>
  801609:	83 c4 10             	add    $0x10,%esp
  80160c:	85 c0                	test   %eax,%eax
  80160e:	78 47                	js     801657 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801610:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801613:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801617:	75 21                	jne    80163a <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801619:	a1 90 67 80 00       	mov    0x806790,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80161e:	8b 40 48             	mov    0x48(%eax),%eax
  801621:	83 ec 04             	sub    $0x4,%esp
  801624:	53                   	push   %ebx
  801625:	50                   	push   %eax
  801626:	68 0c 2b 80 00       	push   $0x802b0c
  80162b:	e8 c4 ee ff ff       	call   8004f4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801630:	83 c4 10             	add    $0x10,%esp
  801633:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801638:	eb 1d                	jmp    801657 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  80163a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80163d:	8b 52 18             	mov    0x18(%edx),%edx
  801640:	85 d2                	test   %edx,%edx
  801642:	74 0e                	je     801652 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801644:	83 ec 08             	sub    $0x8,%esp
  801647:	ff 75 0c             	pushl  0xc(%ebp)
  80164a:	50                   	push   %eax
  80164b:	ff d2                	call   *%edx
  80164d:	83 c4 10             	add    $0x10,%esp
  801650:	eb 05                	jmp    801657 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801652:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801657:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80165a:	c9                   	leave  
  80165b:	c3                   	ret    

0080165c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80165c:	55                   	push   %ebp
  80165d:	89 e5                	mov    %esp,%ebp
  80165f:	53                   	push   %ebx
  801660:	83 ec 14             	sub    $0x14,%esp
  801663:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801666:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801669:	50                   	push   %eax
  80166a:	ff 75 08             	pushl  0x8(%ebp)
  80166d:	e8 63 fb ff ff       	call   8011d5 <fd_lookup>
  801672:	83 c4 08             	add    $0x8,%esp
  801675:	85 c0                	test   %eax,%eax
  801677:	78 52                	js     8016cb <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801679:	83 ec 08             	sub    $0x8,%esp
  80167c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80167f:	50                   	push   %eax
  801680:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801683:	ff 30                	pushl  (%eax)
  801685:	e8 a2 fb ff ff       	call   80122c <dev_lookup>
  80168a:	83 c4 10             	add    $0x10,%esp
  80168d:	85 c0                	test   %eax,%eax
  80168f:	78 3a                	js     8016cb <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  801691:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801694:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801698:	74 2c                	je     8016c6 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80169a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80169d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016a4:	00 00 00 
	stat->st_isdir = 0;
  8016a7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016ae:	00 00 00 
	stat->st_dev = dev;
  8016b1:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016b7:	83 ec 08             	sub    $0x8,%esp
  8016ba:	53                   	push   %ebx
  8016bb:	ff 75 f0             	pushl  -0x10(%ebp)
  8016be:	ff 50 14             	call   *0x14(%eax)
  8016c1:	83 c4 10             	add    $0x10,%esp
  8016c4:	eb 05                	jmp    8016cb <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016c6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ce:	c9                   	leave  
  8016cf:	c3                   	ret    

008016d0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016d0:	55                   	push   %ebp
  8016d1:	89 e5                	mov    %esp,%ebp
  8016d3:	56                   	push   %esi
  8016d4:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016d5:	83 ec 08             	sub    $0x8,%esp
  8016d8:	6a 00                	push   $0x0
  8016da:	ff 75 08             	pushl  0x8(%ebp)
  8016dd:	e8 75 01 00 00       	call   801857 <open>
  8016e2:	89 c3                	mov    %eax,%ebx
  8016e4:	83 c4 10             	add    $0x10,%esp
  8016e7:	85 c0                	test   %eax,%eax
  8016e9:	78 1d                	js     801708 <stat+0x38>
		return fd;
	r = fstat(fd, stat);
  8016eb:	83 ec 08             	sub    $0x8,%esp
  8016ee:	ff 75 0c             	pushl  0xc(%ebp)
  8016f1:	50                   	push   %eax
  8016f2:	e8 65 ff ff ff       	call   80165c <fstat>
  8016f7:	89 c6                	mov    %eax,%esi
	close(fd);
  8016f9:	89 1c 24             	mov    %ebx,(%esp)
  8016fc:	e8 1d fc ff ff       	call   80131e <close>
	return r;
  801701:	83 c4 10             	add    $0x10,%esp
  801704:	89 f0                	mov    %esi,%eax
  801706:	eb 00                	jmp    801708 <stat+0x38>
}
  801708:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80170b:	5b                   	pop    %ebx
  80170c:	5e                   	pop    %esi
  80170d:	5d                   	pop    %ebp
  80170e:	c3                   	ret    

0080170f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80170f:	55                   	push   %ebp
  801710:	89 e5                	mov    %esp,%ebp
  801712:	56                   	push   %esi
  801713:	53                   	push   %ebx
  801714:	89 c6                	mov    %eax,%esi
  801716:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801718:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80171f:	75 12                	jne    801733 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801721:	83 ec 0c             	sub    $0xc,%esp
  801724:	6a 01                	push   $0x1
  801726:	e8 fd 0b 00 00       	call   802328 <ipc_find_env>
  80172b:	a3 00 50 80 00       	mov    %eax,0x805000
  801730:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801733:	6a 07                	push   $0x7
  801735:	68 00 70 80 00       	push   $0x807000
  80173a:	56                   	push   %esi
  80173b:	ff 35 00 50 80 00    	pushl  0x805000
  801741:	e8 83 0b 00 00       	call   8022c9 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801746:	83 c4 0c             	add    $0xc,%esp
  801749:	6a 00                	push   $0x0
  80174b:	53                   	push   %ebx
  80174c:	6a 00                	push   $0x0
  80174e:	e8 01 0b 00 00       	call   802254 <ipc_recv>
}
  801753:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801756:	5b                   	pop    %ebx
  801757:	5e                   	pop    %esi
  801758:	5d                   	pop    %ebp
  801759:	c3                   	ret    

0080175a <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80175a:	55                   	push   %ebp
  80175b:	89 e5                	mov    %esp,%ebp
  80175d:	53                   	push   %ebx
  80175e:	83 ec 04             	sub    $0x4,%esp
  801761:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801764:	8b 45 08             	mov    0x8(%ebp),%eax
  801767:	8b 40 0c             	mov    0xc(%eax),%eax
  80176a:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80176f:	ba 00 00 00 00       	mov    $0x0,%edx
  801774:	b8 05 00 00 00       	mov    $0x5,%eax
  801779:	e8 91 ff ff ff       	call   80170f <fsipc>
  80177e:	85 c0                	test   %eax,%eax
  801780:	78 2c                	js     8017ae <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801782:	83 ec 08             	sub    $0x8,%esp
  801785:	68 00 70 80 00       	push   $0x807000
  80178a:	53                   	push   %ebx
  80178b:	e8 49 f3 ff ff       	call   800ad9 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801790:	a1 80 70 80 00       	mov    0x807080,%eax
  801795:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80179b:	a1 84 70 80 00       	mov    0x807084,%eax
  8017a0:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017a6:	83 c4 10             	add    $0x10,%esp
  8017a9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017b1:	c9                   	leave  
  8017b2:	c3                   	ret    

008017b3 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017b3:	55                   	push   %ebp
  8017b4:	89 e5                	mov    %esp,%ebp
  8017b6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8017bc:	8b 40 0c             	mov    0xc(%eax),%eax
  8017bf:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  8017c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c9:	b8 06 00 00 00       	mov    $0x6,%eax
  8017ce:	e8 3c ff ff ff       	call   80170f <fsipc>
}
  8017d3:	c9                   	leave  
  8017d4:	c3                   	ret    

008017d5 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017d5:	55                   	push   %ebp
  8017d6:	89 e5                	mov    %esp,%ebp
  8017d8:	56                   	push   %esi
  8017d9:	53                   	push   %ebx
  8017da:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e0:	8b 40 0c             	mov    0xc(%eax),%eax
  8017e3:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  8017e8:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f3:	b8 03 00 00 00       	mov    $0x3,%eax
  8017f8:	e8 12 ff ff ff       	call   80170f <fsipc>
  8017fd:	89 c3                	mov    %eax,%ebx
  8017ff:	85 c0                	test   %eax,%eax
  801801:	78 4b                	js     80184e <devfile_read+0x79>
		return r;
	assert(r <= n);
  801803:	39 c6                	cmp    %eax,%esi
  801805:	73 16                	jae    80181d <devfile_read+0x48>
  801807:	68 66 2b 80 00       	push   $0x802b66
  80180c:	68 6d 2b 80 00       	push   $0x802b6d
  801811:	6a 7a                	push   $0x7a
  801813:	68 82 2b 80 00       	push   $0x802b82
  801818:	e8 ff eb ff ff       	call   80041c <_panic>
	assert(r <= PGSIZE);
  80181d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801822:	7e 16                	jle    80183a <devfile_read+0x65>
  801824:	68 8d 2b 80 00       	push   $0x802b8d
  801829:	68 6d 2b 80 00       	push   $0x802b6d
  80182e:	6a 7b                	push   $0x7b
  801830:	68 82 2b 80 00       	push   $0x802b82
  801835:	e8 e2 eb ff ff       	call   80041c <_panic>
	memmove(buf, &fsipcbuf, r);
  80183a:	83 ec 04             	sub    $0x4,%esp
  80183d:	50                   	push   %eax
  80183e:	68 00 70 80 00       	push   $0x807000
  801843:	ff 75 0c             	pushl  0xc(%ebp)
  801846:	e8 5b f4 ff ff       	call   800ca6 <memmove>
	return r;
  80184b:	83 c4 10             	add    $0x10,%esp
}
  80184e:	89 d8                	mov    %ebx,%eax
  801850:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801853:	5b                   	pop    %ebx
  801854:	5e                   	pop    %esi
  801855:	5d                   	pop    %ebp
  801856:	c3                   	ret    

00801857 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801857:	55                   	push   %ebp
  801858:	89 e5                	mov    %esp,%ebp
  80185a:	53                   	push   %ebx
  80185b:	83 ec 20             	sub    $0x20,%esp
  80185e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801861:	53                   	push   %ebx
  801862:	e8 1b f2 ff ff       	call   800a82 <strlen>
  801867:	83 c4 10             	add    $0x10,%esp
  80186a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80186f:	7f 63                	jg     8018d4 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801871:	83 ec 0c             	sub    $0xc,%esp
  801874:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801877:	50                   	push   %eax
  801878:	e8 e4 f8 ff ff       	call   801161 <fd_alloc>
  80187d:	83 c4 10             	add    $0x10,%esp
  801880:	85 c0                	test   %eax,%eax
  801882:	78 55                	js     8018d9 <open+0x82>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801884:	83 ec 08             	sub    $0x8,%esp
  801887:	53                   	push   %ebx
  801888:	68 00 70 80 00       	push   $0x807000
  80188d:	e8 47 f2 ff ff       	call   800ad9 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801892:	8b 45 0c             	mov    0xc(%ebp),%eax
  801895:	a3 00 74 80 00       	mov    %eax,0x807400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80189a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80189d:	b8 01 00 00 00       	mov    $0x1,%eax
  8018a2:	e8 68 fe ff ff       	call   80170f <fsipc>
  8018a7:	89 c3                	mov    %eax,%ebx
  8018a9:	83 c4 10             	add    $0x10,%esp
  8018ac:	85 c0                	test   %eax,%eax
  8018ae:	79 14                	jns    8018c4 <open+0x6d>
		fd_close(fd, 0);
  8018b0:	83 ec 08             	sub    $0x8,%esp
  8018b3:	6a 00                	push   $0x0
  8018b5:	ff 75 f4             	pushl  -0xc(%ebp)
  8018b8:	e8 dd f9 ff ff       	call   80129a <fd_close>
		return r;
  8018bd:	83 c4 10             	add    $0x10,%esp
  8018c0:	89 d8                	mov    %ebx,%eax
  8018c2:	eb 15                	jmp    8018d9 <open+0x82>
	}

	return fd2num(fd);
  8018c4:	83 ec 0c             	sub    $0xc,%esp
  8018c7:	ff 75 f4             	pushl  -0xc(%ebp)
  8018ca:	e8 6b f8 ff ff       	call   80113a <fd2num>
  8018cf:	83 c4 10             	add    $0x10,%esp
  8018d2:	eb 05                	jmp    8018d9 <open+0x82>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8018d4:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8018d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018dc:	c9                   	leave  
  8018dd:	c3                   	ret    

008018de <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8018de:	55                   	push   %ebp
  8018df:	89 e5                	mov    %esp,%ebp
  8018e1:	57                   	push   %edi
  8018e2:	56                   	push   %esi
  8018e3:	53                   	push   %ebx
  8018e4:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8018ea:	6a 00                	push   $0x0
  8018ec:	ff 75 08             	pushl  0x8(%ebp)
  8018ef:	e8 63 ff ff ff       	call   801857 <open>
  8018f4:	89 c1                	mov    %eax,%ecx
  8018f6:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  8018fc:	83 c4 10             	add    $0x10,%esp
  8018ff:	85 c0                	test   %eax,%eax
  801901:	0f 88 6f 04 00 00    	js     801d76 <spawn+0x498>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801907:	83 ec 04             	sub    $0x4,%esp
  80190a:	68 00 02 00 00       	push   $0x200
  80190f:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801915:	50                   	push   %eax
  801916:	51                   	push   %ecx
  801917:	e8 c1 fb ff ff       	call   8014dd <readn>
  80191c:	83 c4 10             	add    $0x10,%esp
  80191f:	3d 00 02 00 00       	cmp    $0x200,%eax
  801924:	75 0c                	jne    801932 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  801926:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  80192d:	45 4c 46 
  801930:	74 33                	je     801965 <spawn+0x87>
		close(fd);
  801932:	83 ec 0c             	sub    $0xc,%esp
  801935:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80193b:	e8 de f9 ff ff       	call   80131e <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801940:	83 c4 0c             	add    $0xc,%esp
  801943:	68 7f 45 4c 46       	push   $0x464c457f
  801948:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  80194e:	68 99 2b 80 00       	push   $0x802b99
  801953:	e8 9c eb ff ff       	call   8004f4 <cprintf>
		return -E_NOT_EXEC;
  801958:	83 c4 10             	add    $0x10,%esp
  80195b:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801960:	e9 71 04 00 00       	jmp    801dd6 <spawn+0x4f8>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801965:	b8 07 00 00 00       	mov    $0x7,%eax
  80196a:	cd 30                	int    $0x30
  80196c:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801972:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801978:	85 c0                	test   %eax,%eax
  80197a:	0f 88 fe 03 00 00    	js     801d7e <spawn+0x4a0>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801980:	89 c6                	mov    %eax,%esi
  801982:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801988:	8d 04 b5 00 00 00 00 	lea    0x0(,%esi,4),%eax
  80198f:	c1 e6 07             	shl    $0x7,%esi
  801992:	29 c6                	sub    %eax,%esi
  801994:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  80199a:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8019a0:	b9 11 00 00 00       	mov    $0x11,%ecx
  8019a5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  8019a7:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8019ad:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8019b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019b6:	8b 00                	mov    (%eax),%eax
  8019b8:	85 c0                	test   %eax,%eax
  8019ba:	74 3a                	je     8019f6 <spawn+0x118>
  8019bc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019c1:	be 00 00 00 00       	mov    $0x0,%esi
  8019c6:	8b 7d 0c             	mov    0xc(%ebp),%edi
		string_size += strlen(argv[argc]) + 1;
  8019c9:	83 ec 0c             	sub    $0xc,%esp
  8019cc:	50                   	push   %eax
  8019cd:	e8 b0 f0 ff ff       	call   800a82 <strlen>
  8019d2:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8019d6:	43                   	inc    %ebx
  8019d7:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  8019de:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  8019e1:	83 c4 10             	add    $0x10,%esp
  8019e4:	85 c0                	test   %eax,%eax
  8019e6:	75 e1                	jne    8019c9 <spawn+0xeb>
  8019e8:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  8019ee:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
  8019f4:	eb 1e                	jmp    801a14 <spawn+0x136>
  8019f6:	c7 85 80 fd ff ff 00 	movl   $0x0,-0x280(%ebp)
  8019fd:	00 00 00 
  801a00:	c7 85 88 fd ff ff 00 	movl   $0x0,-0x278(%ebp)
  801a07:	00 00 00 
  801a0a:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801a0f:	be 00 00 00 00       	mov    $0x0,%esi
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801a14:	bf 00 10 40 00       	mov    $0x401000,%edi
  801a19:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801a1b:	89 fa                	mov    %edi,%edx
  801a1d:	83 e2 fc             	and    $0xfffffffc,%edx
  801a20:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801a27:	29 c2                	sub    %eax,%edx
  801a29:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801a2f:	8d 42 f8             	lea    -0x8(%edx),%eax
  801a32:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801a37:	0f 86 51 03 00 00    	jbe    801d8e <spawn+0x4b0>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801a3d:	83 ec 04             	sub    $0x4,%esp
  801a40:	6a 07                	push   $0x7
  801a42:	68 00 00 40 00       	push   $0x400000
  801a47:	6a 00                	push   $0x0
  801a49:	e8 fb f4 ff ff       	call   800f49 <sys_page_alloc>
  801a4e:	83 c4 10             	add    $0x10,%esp
  801a51:	85 c0                	test   %eax,%eax
  801a53:	0f 88 3c 03 00 00    	js     801d95 <spawn+0x4b7>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801a59:	85 db                	test   %ebx,%ebx
  801a5b:	7e 44                	jle    801aa1 <spawn+0x1c3>
  801a5d:	be 00 00 00 00       	mov    $0x0,%esi
  801a62:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801a68:	8b 5d 0c             	mov    0xc(%ebp),%ebx
		argv_store[i] = UTEMP2USTACK(string_store);
  801a6b:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801a71:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801a77:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801a7a:	83 ec 08             	sub    $0x8,%esp
  801a7d:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801a80:	57                   	push   %edi
  801a81:	e8 53 f0 ff ff       	call   800ad9 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801a86:	83 c4 04             	add    $0x4,%esp
  801a89:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801a8c:	e8 f1 ef ff ff       	call   800a82 <strlen>
  801a91:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801a95:	46                   	inc    %esi
  801a96:	83 c4 10             	add    $0x10,%esp
  801a99:	3b b5 90 fd ff ff    	cmp    -0x270(%ebp),%esi
  801a9f:	75 ca                	jne    801a6b <spawn+0x18d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801aa1:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801aa7:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801aad:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801ab4:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801aba:	74 19                	je     801ad5 <spawn+0x1f7>
  801abc:	68 10 2c 80 00       	push   $0x802c10
  801ac1:	68 6d 2b 80 00       	push   $0x802b6d
  801ac6:	68 f1 00 00 00       	push   $0xf1
  801acb:	68 b3 2b 80 00       	push   $0x802bb3
  801ad0:	e8 47 e9 ff ff       	call   80041c <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801ad5:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801adb:	89 c8                	mov    %ecx,%eax
  801add:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801ae2:	89 41 fc             	mov    %eax,-0x4(%ecx)
	argv_store[-2] = argc;
  801ae5:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801aeb:	89 41 f8             	mov    %eax,-0x8(%ecx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801aee:	8d 81 f8 cf 7f ee    	lea    -0x11803008(%ecx),%eax
  801af4:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801afa:	83 ec 0c             	sub    $0xc,%esp
  801afd:	6a 07                	push   $0x7
  801aff:	68 00 d0 bf ee       	push   $0xeebfd000
  801b04:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801b0a:	68 00 00 40 00       	push   $0x400000
  801b0f:	6a 00                	push   $0x0
  801b11:	e8 76 f4 ff ff       	call   800f8c <sys_page_map>
  801b16:	89 c3                	mov    %eax,%ebx
  801b18:	83 c4 20             	add    $0x20,%esp
  801b1b:	85 c0                	test   %eax,%eax
  801b1d:	0f 88 a1 02 00 00    	js     801dc4 <spawn+0x4e6>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801b23:	83 ec 08             	sub    $0x8,%esp
  801b26:	68 00 00 40 00       	push   $0x400000
  801b2b:	6a 00                	push   $0x0
  801b2d:	e8 9c f4 ff ff       	call   800fce <sys_page_unmap>
  801b32:	89 c3                	mov    %eax,%ebx
  801b34:	83 c4 10             	add    $0x10,%esp
  801b37:	85 c0                	test   %eax,%eax
  801b39:	0f 88 85 02 00 00    	js     801dc4 <spawn+0x4e6>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801b3f:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801b45:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801b4c:	89 85 78 fd ff ff    	mov    %eax,-0x288(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801b52:	66 83 bd 14 fe ff ff 	cmpw   $0x0,-0x1ec(%ebp)
  801b59:	00 
  801b5a:	0f 84 ab 01 00 00    	je     801d0b <spawn+0x42d>
  801b60:	c7 85 80 fd ff ff 00 	movl   $0x0,-0x280(%ebp)
  801b67:	00 00 00 
		if (ph->p_type != ELF_PROG_LOAD)
  801b6a:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  801b70:	83 38 01             	cmpl   $0x1,(%eax)
  801b73:	0f 85 70 01 00 00    	jne    801ce9 <spawn+0x40b>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801b79:	89 c1                	mov    %eax,%ecx
  801b7b:	8b 40 18             	mov    0x18(%eax),%eax
  801b7e:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801b81:	83 f8 01             	cmp    $0x1,%eax
  801b84:	19 c0                	sbb    %eax,%eax
  801b86:	83 e0 fe             	and    $0xfffffffe,%eax
  801b89:	83 c0 07             	add    $0x7,%eax
  801b8c:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801b92:	89 c8                	mov    %ecx,%eax
  801b94:	8b 49 04             	mov    0x4(%ecx),%ecx
  801b97:	89 8d 7c fd ff ff    	mov    %ecx,-0x284(%ebp)
  801b9d:	8b 50 10             	mov    0x10(%eax),%edx
  801ba0:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)
  801ba6:	8b 78 14             	mov    0x14(%eax),%edi
  801ba9:	89 bd 90 fd ff ff    	mov    %edi,-0x270(%ebp)
  801baf:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801bb2:	89 f0                	mov    %esi,%eax
  801bb4:	25 ff 0f 00 00       	and    $0xfff,%eax
  801bb9:	74 1a                	je     801bd5 <spawn+0x2f7>
		va -= i;
  801bbb:	29 c6                	sub    %eax,%esi
		memsz += i;
  801bbd:	01 c7                	add    %eax,%edi
  801bbf:	89 bd 90 fd ff ff    	mov    %edi,-0x270(%ebp)
		filesz += i;
  801bc5:	01 c2                	add    %eax,%edx
  801bc7:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)
		fileoffset -= i;
  801bcd:	29 c1                	sub    %eax,%ecx
  801bcf:	89 8d 7c fd ff ff    	mov    %ecx,-0x284(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801bd5:	83 bd 90 fd ff ff 00 	cmpl   $0x0,-0x270(%ebp)
  801bdc:	0f 84 07 01 00 00    	je     801ce9 <spawn+0x40b>
  801be2:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (i >= filesz) {
  801be7:	39 9d 94 fd ff ff    	cmp    %ebx,-0x26c(%ebp)
  801bed:	77 27                	ja     801c16 <spawn+0x338>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801bef:	83 ec 04             	sub    $0x4,%esp
  801bf2:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801bf8:	56                   	push   %esi
  801bf9:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801bff:	e8 45 f3 ff ff       	call   800f49 <sys_page_alloc>
  801c04:	83 c4 10             	add    $0x10,%esp
  801c07:	85 c0                	test   %eax,%eax
  801c09:	0f 89 c2 00 00 00    	jns    801cd1 <spawn+0x3f3>
  801c0f:	89 c3                	mov    %eax,%ebx
  801c11:	e9 8d 01 00 00       	jmp    801da3 <spawn+0x4c5>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801c16:	83 ec 04             	sub    $0x4,%esp
  801c19:	6a 07                	push   $0x7
  801c1b:	68 00 00 40 00       	push   $0x400000
  801c20:	6a 00                	push   $0x0
  801c22:	e8 22 f3 ff ff       	call   800f49 <sys_page_alloc>
  801c27:	83 c4 10             	add    $0x10,%esp
  801c2a:	85 c0                	test   %eax,%eax
  801c2c:	0f 88 67 01 00 00    	js     801d99 <spawn+0x4bb>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801c32:	83 ec 08             	sub    $0x8,%esp
  801c35:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801c3b:	01 d8                	add    %ebx,%eax
  801c3d:	50                   	push   %eax
  801c3e:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801c44:	e8 6b f9 ff ff       	call   8015b4 <seek>
  801c49:	83 c4 10             	add    $0x10,%esp
  801c4c:	85 c0                	test   %eax,%eax
  801c4e:	0f 88 49 01 00 00    	js     801d9d <spawn+0x4bf>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801c54:	83 ec 04             	sub    $0x4,%esp
  801c57:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801c5d:	29 d8                	sub    %ebx,%eax
  801c5f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801c64:	76 05                	jbe    801c6b <spawn+0x38d>
  801c66:	b8 00 10 00 00       	mov    $0x1000,%eax
  801c6b:	50                   	push   %eax
  801c6c:	68 00 00 40 00       	push   $0x400000
  801c71:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801c77:	e8 61 f8 ff ff       	call   8014dd <readn>
  801c7c:	83 c4 10             	add    $0x10,%esp
  801c7f:	85 c0                	test   %eax,%eax
  801c81:	0f 88 1a 01 00 00    	js     801da1 <spawn+0x4c3>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801c87:	83 ec 0c             	sub    $0xc,%esp
  801c8a:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801c90:	56                   	push   %esi
  801c91:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801c97:	68 00 00 40 00       	push   $0x400000
  801c9c:	6a 00                	push   $0x0
  801c9e:	e8 e9 f2 ff ff       	call   800f8c <sys_page_map>
  801ca3:	83 c4 20             	add    $0x20,%esp
  801ca6:	85 c0                	test   %eax,%eax
  801ca8:	79 15                	jns    801cbf <spawn+0x3e1>
				panic("spawn: sys_page_map data: %e", r);
  801caa:	50                   	push   %eax
  801cab:	68 bf 2b 80 00       	push   $0x802bbf
  801cb0:	68 24 01 00 00       	push   $0x124
  801cb5:	68 b3 2b 80 00       	push   $0x802bb3
  801cba:	e8 5d e7 ff ff       	call   80041c <_panic>
			sys_page_unmap(0, UTEMP);
  801cbf:	83 ec 08             	sub    $0x8,%esp
  801cc2:	68 00 00 40 00       	push   $0x400000
  801cc7:	6a 00                	push   $0x0
  801cc9:	e8 00 f3 ff ff       	call   800fce <sys_page_unmap>
  801cce:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801cd1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801cd7:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801cdd:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  801ce3:	0f 82 fe fe ff ff    	jb     801be7 <spawn+0x309>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801ce9:	ff 85 80 fd ff ff    	incl   -0x280(%ebp)
  801cef:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  801cf5:	83 85 78 fd ff ff 20 	addl   $0x20,-0x288(%ebp)
  801cfc:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801d03:	39 d0                	cmp    %edx,%eax
  801d05:	0f 8f 5f fe ff ff    	jg     801b6a <spawn+0x28c>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801d0b:	83 ec 0c             	sub    $0xc,%esp
  801d0e:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801d14:	e8 05 f6 ff ff       	call   80131e <close>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801d19:	83 c4 08             	add    $0x8,%esp
  801d1c:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801d22:	50                   	push   %eax
  801d23:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801d29:	e8 24 f3 ff ff       	call   801052 <sys_env_set_trapframe>
  801d2e:	83 c4 10             	add    $0x10,%esp
  801d31:	85 c0                	test   %eax,%eax
  801d33:	79 15                	jns    801d4a <spawn+0x46c>
		panic("sys_env_set_trapframe: %e", r);
  801d35:	50                   	push   %eax
  801d36:	68 dc 2b 80 00       	push   $0x802bdc
  801d3b:	68 85 00 00 00       	push   $0x85
  801d40:	68 b3 2b 80 00       	push   $0x802bb3
  801d45:	e8 d2 e6 ff ff       	call   80041c <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801d4a:	83 ec 08             	sub    $0x8,%esp
  801d4d:	6a 02                	push   $0x2
  801d4f:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801d55:	e8 b6 f2 ff ff       	call   801010 <sys_env_set_status>
  801d5a:	83 c4 10             	add    $0x10,%esp
  801d5d:	85 c0                	test   %eax,%eax
  801d5f:	79 25                	jns    801d86 <spawn+0x4a8>
		panic("sys_env_set_status: %e", r);
  801d61:	50                   	push   %eax
  801d62:	68 f6 2b 80 00       	push   $0x802bf6
  801d67:	68 88 00 00 00       	push   $0x88
  801d6c:	68 b3 2b 80 00       	push   $0x802bb3
  801d71:	e8 a6 e6 ff ff       	call   80041c <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801d76:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801d7c:	eb 58                	jmp    801dd6 <spawn+0x4f8>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801d7e:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801d84:	eb 50                	jmp    801dd6 <spawn+0x4f8>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801d86:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801d8c:	eb 48                	jmp    801dd6 <spawn+0x4f8>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801d8e:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801d93:	eb 41                	jmp    801dd6 <spawn+0x4f8>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801d95:	89 c3                	mov    %eax,%ebx
  801d97:	eb 3d                	jmp    801dd6 <spawn+0x4f8>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801d99:	89 c3                	mov    %eax,%ebx
  801d9b:	eb 06                	jmp    801da3 <spawn+0x4c5>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801d9d:	89 c3                	mov    %eax,%ebx
  801d9f:	eb 02                	jmp    801da3 <spawn+0x4c5>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801da1:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801da3:	83 ec 0c             	sub    $0xc,%esp
  801da6:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801dac:	e8 19 f1 ff ff       	call   800eca <sys_env_destroy>
	close(fd);
  801db1:	83 c4 04             	add    $0x4,%esp
  801db4:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801dba:	e8 5f f5 ff ff       	call   80131e <close>
	return r;
  801dbf:	83 c4 10             	add    $0x10,%esp
  801dc2:	eb 12                	jmp    801dd6 <spawn+0x4f8>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801dc4:	83 ec 08             	sub    $0x8,%esp
  801dc7:	68 00 00 40 00       	push   $0x400000
  801dcc:	6a 00                	push   $0x0
  801dce:	e8 fb f1 ff ff       	call   800fce <sys_page_unmap>
  801dd3:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801dd6:	89 d8                	mov    %ebx,%eax
  801dd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ddb:	5b                   	pop    %ebx
  801ddc:	5e                   	pop    %esi
  801ddd:	5f                   	pop    %edi
  801dde:	5d                   	pop    %ebp
  801ddf:	c3                   	ret    

00801de0 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801de0:	55                   	push   %ebp
  801de1:	89 e5                	mov    %esp,%ebp
  801de3:	57                   	push   %edi
  801de4:	56                   	push   %esi
  801de5:	53                   	push   %ebx
  801de6:	83 ec 1c             	sub    $0x1c,%esp
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801de9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ded:	74 5f                	je     801e4e <spawnl+0x6e>
  801def:	8d 45 14             	lea    0x14(%ebp),%eax
  801df2:	ba 00 00 00 00       	mov    $0x0,%edx
  801df7:	eb 02                	jmp    801dfb <spawnl+0x1b>
		argc++;
  801df9:	89 ca                	mov    %ecx,%edx
  801dfb:	8d 4a 01             	lea    0x1(%edx),%ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801dfe:	83 c0 04             	add    $0x4,%eax
  801e01:	83 78 fc 00          	cmpl   $0x0,-0x4(%eax)
  801e05:	75 f2                	jne    801df9 <spawnl+0x19>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801e07:	8d 04 95 1e 00 00 00 	lea    0x1e(,%edx,4),%eax
  801e0e:	83 e0 f0             	and    $0xfffffff0,%eax
  801e11:	29 c4                	sub    %eax,%esp
  801e13:	8d 44 24 03          	lea    0x3(%esp),%eax
  801e17:	c1 e8 02             	shr    $0x2,%eax
  801e1a:	8d 34 85 00 00 00 00 	lea    0x0(,%eax,4),%esi
  801e21:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801e23:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801e26:	89 3c 85 00 00 00 00 	mov    %edi,0x0(,%eax,4)
	argv[argc+1] = NULL;
  801e2d:	c7 44 96 08 00 00 00 	movl   $0x0,0x8(%esi,%edx,4)
  801e34:	00 

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801e35:	89 ce                	mov    %ecx,%esi
  801e37:	85 c9                	test   %ecx,%ecx
  801e39:	74 23                	je     801e5e <spawnl+0x7e>
  801e3b:	b8 00 00 00 00       	mov    $0x0,%eax
		argv[i+1] = va_arg(vl, const char *);
  801e40:	40                   	inc    %eax
  801e41:	8b 54 85 0c          	mov    0xc(%ebp,%eax,4),%edx
  801e45:	89 14 83             	mov    %edx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801e48:	39 f0                	cmp    %esi,%eax
  801e4a:	75 f4                	jne    801e40 <spawnl+0x60>
  801e4c:	eb 10                	jmp    801e5e <spawnl+0x7e>
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
	argv[0] = arg0;
  801e4e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e51:	89 45 e0             	mov    %eax,-0x20(%ebp)
	argv[argc+1] = NULL;
  801e54:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801e5b:	8d 5d e0             	lea    -0x20(%ebp),%ebx
	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801e5e:	83 ec 08             	sub    $0x8,%esp
  801e61:	53                   	push   %ebx
  801e62:	ff 75 08             	pushl  0x8(%ebp)
  801e65:	e8 74 fa ff ff       	call   8018de <spawn>
}
  801e6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e6d:	5b                   	pop    %ebx
  801e6e:	5e                   	pop    %esi
  801e6f:	5f                   	pop    %edi
  801e70:	5d                   	pop    %ebp
  801e71:	c3                   	ret    

00801e72 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e72:	55                   	push   %ebp
  801e73:	89 e5                	mov    %esp,%ebp
  801e75:	56                   	push   %esi
  801e76:	53                   	push   %ebx
  801e77:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e7a:	83 ec 0c             	sub    $0xc,%esp
  801e7d:	ff 75 08             	pushl  0x8(%ebp)
  801e80:	e8 c5 f2 ff ff       	call   80114a <fd2data>
  801e85:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801e87:	83 c4 08             	add    $0x8,%esp
  801e8a:	68 38 2c 80 00       	push   $0x802c38
  801e8f:	53                   	push   %ebx
  801e90:	e8 44 ec ff ff       	call   800ad9 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e95:	8b 46 04             	mov    0x4(%esi),%eax
  801e98:	2b 06                	sub    (%esi),%eax
  801e9a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ea0:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ea7:	00 00 00 
	stat->st_dev = &devpipe;
  801eaa:	c7 83 88 00 00 00 ac 	movl   $0x8047ac,0x88(%ebx)
  801eb1:	47 80 00 
	return 0;
}
  801eb4:	b8 00 00 00 00       	mov    $0x0,%eax
  801eb9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ebc:	5b                   	pop    %ebx
  801ebd:	5e                   	pop    %esi
  801ebe:	5d                   	pop    %ebp
  801ebf:	c3                   	ret    

00801ec0 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ec0:	55                   	push   %ebp
  801ec1:	89 e5                	mov    %esp,%ebp
  801ec3:	53                   	push   %ebx
  801ec4:	83 ec 0c             	sub    $0xc,%esp
  801ec7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801eca:	53                   	push   %ebx
  801ecb:	6a 00                	push   $0x0
  801ecd:	e8 fc f0 ff ff       	call   800fce <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ed2:	89 1c 24             	mov    %ebx,(%esp)
  801ed5:	e8 70 f2 ff ff       	call   80114a <fd2data>
  801eda:	83 c4 08             	add    $0x8,%esp
  801edd:	50                   	push   %eax
  801ede:	6a 00                	push   $0x0
  801ee0:	e8 e9 f0 ff ff       	call   800fce <sys_page_unmap>
}
  801ee5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ee8:	c9                   	leave  
  801ee9:	c3                   	ret    

00801eea <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801eea:	55                   	push   %ebp
  801eeb:	89 e5                	mov    %esp,%ebp
  801eed:	57                   	push   %edi
  801eee:	56                   	push   %esi
  801eef:	53                   	push   %ebx
  801ef0:	83 ec 1c             	sub    $0x1c,%esp
  801ef3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ef6:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ef8:	a1 90 67 80 00       	mov    0x806790,%eax
  801efd:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801f00:	83 ec 0c             	sub    $0xc,%esp
  801f03:	ff 75 e0             	pushl  -0x20(%ebp)
  801f06:	e8 78 04 00 00       	call   802383 <pageref>
  801f0b:	89 c3                	mov    %eax,%ebx
  801f0d:	89 3c 24             	mov    %edi,(%esp)
  801f10:	e8 6e 04 00 00       	call   802383 <pageref>
  801f15:	83 c4 10             	add    $0x10,%esp
  801f18:	39 c3                	cmp    %eax,%ebx
  801f1a:	0f 94 c1             	sete   %cl
  801f1d:	0f b6 c9             	movzbl %cl,%ecx
  801f20:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801f23:	8b 15 90 67 80 00    	mov    0x806790,%edx
  801f29:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801f2c:	39 ce                	cmp    %ecx,%esi
  801f2e:	74 1b                	je     801f4b <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801f30:	39 c3                	cmp    %eax,%ebx
  801f32:	75 c4                	jne    801ef8 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f34:	8b 42 58             	mov    0x58(%edx),%eax
  801f37:	ff 75 e4             	pushl  -0x1c(%ebp)
  801f3a:	50                   	push   %eax
  801f3b:	56                   	push   %esi
  801f3c:	68 3f 2c 80 00       	push   $0x802c3f
  801f41:	e8 ae e5 ff ff       	call   8004f4 <cprintf>
  801f46:	83 c4 10             	add    $0x10,%esp
  801f49:	eb ad                	jmp    801ef8 <_pipeisclosed+0xe>
	}
}
  801f4b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f4e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f51:	5b                   	pop    %ebx
  801f52:	5e                   	pop    %esi
  801f53:	5f                   	pop    %edi
  801f54:	5d                   	pop    %ebp
  801f55:	c3                   	ret    

00801f56 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f56:	55                   	push   %ebp
  801f57:	89 e5                	mov    %esp,%ebp
  801f59:	57                   	push   %edi
  801f5a:	56                   	push   %esi
  801f5b:	53                   	push   %ebx
  801f5c:	83 ec 18             	sub    $0x18,%esp
  801f5f:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801f62:	56                   	push   %esi
  801f63:	e8 e2 f1 ff ff       	call   80114a <fd2data>
  801f68:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f6a:	83 c4 10             	add    $0x10,%esp
  801f6d:	bf 00 00 00 00       	mov    $0x0,%edi
  801f72:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f76:	75 42                	jne    801fba <devpipe_write+0x64>
  801f78:	eb 4e                	jmp    801fc8 <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801f7a:	89 da                	mov    %ebx,%edx
  801f7c:	89 f0                	mov    %esi,%eax
  801f7e:	e8 67 ff ff ff       	call   801eea <_pipeisclosed>
  801f83:	85 c0                	test   %eax,%eax
  801f85:	75 46                	jne    801fcd <devpipe_write+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801f87:	e8 9e ef ff ff       	call   800f2a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f8c:	8b 53 04             	mov    0x4(%ebx),%edx
  801f8f:	8b 03                	mov    (%ebx),%eax
  801f91:	83 c0 20             	add    $0x20,%eax
  801f94:	39 c2                	cmp    %eax,%edx
  801f96:	73 e2                	jae    801f7a <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f98:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f9b:	8a 0c 38             	mov    (%eax,%edi,1),%cl
  801f9e:	89 d0                	mov    %edx,%eax
  801fa0:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801fa5:	79 05                	jns    801fac <devpipe_write+0x56>
  801fa7:	48                   	dec    %eax
  801fa8:	83 c8 e0             	or     $0xffffffe0,%eax
  801fab:	40                   	inc    %eax
  801fac:	88 4c 03 08          	mov    %cl,0x8(%ebx,%eax,1)
		p->p_wpos++;
  801fb0:	42                   	inc    %edx
  801fb1:	89 53 04             	mov    %edx,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fb4:	47                   	inc    %edi
  801fb5:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801fb8:	74 0e                	je     801fc8 <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801fba:	8b 53 04             	mov    0x4(%ebx),%edx
  801fbd:	8b 03                	mov    (%ebx),%eax
  801fbf:	83 c0 20             	add    $0x20,%eax
  801fc2:	39 c2                	cmp    %eax,%edx
  801fc4:	73 b4                	jae    801f7a <devpipe_write+0x24>
  801fc6:	eb d0                	jmp    801f98 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801fc8:	8b 45 10             	mov    0x10(%ebp),%eax
  801fcb:	eb 05                	jmp    801fd2 <devpipe_write+0x7c>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801fcd:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801fd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fd5:	5b                   	pop    %ebx
  801fd6:	5e                   	pop    %esi
  801fd7:	5f                   	pop    %edi
  801fd8:	5d                   	pop    %ebp
  801fd9:	c3                   	ret    

00801fda <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801fda:	55                   	push   %ebp
  801fdb:	89 e5                	mov    %esp,%ebp
  801fdd:	57                   	push   %edi
  801fde:	56                   	push   %esi
  801fdf:	53                   	push   %ebx
  801fe0:	83 ec 18             	sub    $0x18,%esp
  801fe3:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801fe6:	57                   	push   %edi
  801fe7:	e8 5e f1 ff ff       	call   80114a <fd2data>
  801fec:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fee:	83 c4 10             	add    $0x10,%esp
  801ff1:	be 00 00 00 00       	mov    $0x0,%esi
  801ff6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ffa:	75 3d                	jne    802039 <devpipe_read+0x5f>
  801ffc:	eb 48                	jmp    802046 <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801ffe:	89 f0                	mov    %esi,%eax
  802000:	eb 4e                	jmp    802050 <devpipe_read+0x76>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802002:	89 da                	mov    %ebx,%edx
  802004:	89 f8                	mov    %edi,%eax
  802006:	e8 df fe ff ff       	call   801eea <_pipeisclosed>
  80200b:	85 c0                	test   %eax,%eax
  80200d:	75 3c                	jne    80204b <devpipe_read+0x71>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80200f:	e8 16 ef ff ff       	call   800f2a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802014:	8b 03                	mov    (%ebx),%eax
  802016:	3b 43 04             	cmp    0x4(%ebx),%eax
  802019:	74 e7                	je     802002 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80201b:	25 1f 00 00 80       	and    $0x8000001f,%eax
  802020:	79 05                	jns    802027 <devpipe_read+0x4d>
  802022:	48                   	dec    %eax
  802023:	83 c8 e0             	or     $0xffffffe0,%eax
  802026:	40                   	inc    %eax
  802027:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  80202b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80202e:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  802031:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802033:	46                   	inc    %esi
  802034:	39 75 10             	cmp    %esi,0x10(%ebp)
  802037:	74 0d                	je     802046 <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
  802039:	8b 03                	mov    (%ebx),%eax
  80203b:	3b 43 04             	cmp    0x4(%ebx),%eax
  80203e:	75 db                	jne    80201b <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802040:	85 f6                	test   %esi,%esi
  802042:	75 ba                	jne    801ffe <devpipe_read+0x24>
  802044:	eb bc                	jmp    802002 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802046:	8b 45 10             	mov    0x10(%ebp),%eax
  802049:	eb 05                	jmp    802050 <devpipe_read+0x76>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80204b:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802050:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802053:	5b                   	pop    %ebx
  802054:	5e                   	pop    %esi
  802055:	5f                   	pop    %edi
  802056:	5d                   	pop    %ebp
  802057:	c3                   	ret    

00802058 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802058:	55                   	push   %ebp
  802059:	89 e5                	mov    %esp,%ebp
  80205b:	56                   	push   %esi
  80205c:	53                   	push   %ebx
  80205d:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802060:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802063:	50                   	push   %eax
  802064:	e8 f8 f0 ff ff       	call   801161 <fd_alloc>
  802069:	83 c4 10             	add    $0x10,%esp
  80206c:	85 c0                	test   %eax,%eax
  80206e:	0f 88 2a 01 00 00    	js     80219e <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802074:	83 ec 04             	sub    $0x4,%esp
  802077:	68 07 04 00 00       	push   $0x407
  80207c:	ff 75 f4             	pushl  -0xc(%ebp)
  80207f:	6a 00                	push   $0x0
  802081:	e8 c3 ee ff ff       	call   800f49 <sys_page_alloc>
  802086:	83 c4 10             	add    $0x10,%esp
  802089:	85 c0                	test   %eax,%eax
  80208b:	0f 88 0d 01 00 00    	js     80219e <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802091:	83 ec 0c             	sub    $0xc,%esp
  802094:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802097:	50                   	push   %eax
  802098:	e8 c4 f0 ff ff       	call   801161 <fd_alloc>
  80209d:	89 c3                	mov    %eax,%ebx
  80209f:	83 c4 10             	add    $0x10,%esp
  8020a2:	85 c0                	test   %eax,%eax
  8020a4:	0f 88 e2 00 00 00    	js     80218c <pipe+0x134>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020aa:	83 ec 04             	sub    $0x4,%esp
  8020ad:	68 07 04 00 00       	push   $0x407
  8020b2:	ff 75 f0             	pushl  -0x10(%ebp)
  8020b5:	6a 00                	push   $0x0
  8020b7:	e8 8d ee ff ff       	call   800f49 <sys_page_alloc>
  8020bc:	89 c3                	mov    %eax,%ebx
  8020be:	83 c4 10             	add    $0x10,%esp
  8020c1:	85 c0                	test   %eax,%eax
  8020c3:	0f 88 c3 00 00 00    	js     80218c <pipe+0x134>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8020c9:	83 ec 0c             	sub    $0xc,%esp
  8020cc:	ff 75 f4             	pushl  -0xc(%ebp)
  8020cf:	e8 76 f0 ff ff       	call   80114a <fd2data>
  8020d4:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020d6:	83 c4 0c             	add    $0xc,%esp
  8020d9:	68 07 04 00 00       	push   $0x407
  8020de:	50                   	push   %eax
  8020df:	6a 00                	push   $0x0
  8020e1:	e8 63 ee ff ff       	call   800f49 <sys_page_alloc>
  8020e6:	89 c3                	mov    %eax,%ebx
  8020e8:	83 c4 10             	add    $0x10,%esp
  8020eb:	85 c0                	test   %eax,%eax
  8020ed:	0f 88 89 00 00 00    	js     80217c <pipe+0x124>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020f3:	83 ec 0c             	sub    $0xc,%esp
  8020f6:	ff 75 f0             	pushl  -0x10(%ebp)
  8020f9:	e8 4c f0 ff ff       	call   80114a <fd2data>
  8020fe:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802105:	50                   	push   %eax
  802106:	6a 00                	push   $0x0
  802108:	56                   	push   %esi
  802109:	6a 00                	push   $0x0
  80210b:	e8 7c ee ff ff       	call   800f8c <sys_page_map>
  802110:	89 c3                	mov    %eax,%ebx
  802112:	83 c4 20             	add    $0x20,%esp
  802115:	85 c0                	test   %eax,%eax
  802117:	78 55                	js     80216e <pipe+0x116>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802119:	8b 15 ac 47 80 00    	mov    0x8047ac,%edx
  80211f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802122:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802124:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802127:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80212e:	8b 15 ac 47 80 00    	mov    0x8047ac,%edx
  802134:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802137:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802139:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80213c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802143:	83 ec 0c             	sub    $0xc,%esp
  802146:	ff 75 f4             	pushl  -0xc(%ebp)
  802149:	e8 ec ef ff ff       	call   80113a <fd2num>
  80214e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802151:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802153:	83 c4 04             	add    $0x4,%esp
  802156:	ff 75 f0             	pushl  -0x10(%ebp)
  802159:	e8 dc ef ff ff       	call   80113a <fd2num>
  80215e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802161:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802164:	83 c4 10             	add    $0x10,%esp
  802167:	b8 00 00 00 00       	mov    $0x0,%eax
  80216c:	eb 30                	jmp    80219e <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  80216e:	83 ec 08             	sub    $0x8,%esp
  802171:	56                   	push   %esi
  802172:	6a 00                	push   $0x0
  802174:	e8 55 ee ff ff       	call   800fce <sys_page_unmap>
  802179:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80217c:	83 ec 08             	sub    $0x8,%esp
  80217f:	ff 75 f0             	pushl  -0x10(%ebp)
  802182:	6a 00                	push   $0x0
  802184:	e8 45 ee ff ff       	call   800fce <sys_page_unmap>
  802189:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80218c:	83 ec 08             	sub    $0x8,%esp
  80218f:	ff 75 f4             	pushl  -0xc(%ebp)
  802192:	6a 00                	push   $0x0
  802194:	e8 35 ee ff ff       	call   800fce <sys_page_unmap>
  802199:	83 c4 10             	add    $0x10,%esp
  80219c:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  80219e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021a1:	5b                   	pop    %ebx
  8021a2:	5e                   	pop    %esi
  8021a3:	5d                   	pop    %ebp
  8021a4:	c3                   	ret    

008021a5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8021a5:	55                   	push   %ebp
  8021a6:	89 e5                	mov    %esp,%ebp
  8021a8:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021ae:	50                   	push   %eax
  8021af:	ff 75 08             	pushl  0x8(%ebp)
  8021b2:	e8 1e f0 ff ff       	call   8011d5 <fd_lookup>
  8021b7:	83 c4 10             	add    $0x10,%esp
  8021ba:	85 c0                	test   %eax,%eax
  8021bc:	78 18                	js     8021d6 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8021be:	83 ec 0c             	sub    $0xc,%esp
  8021c1:	ff 75 f4             	pushl  -0xc(%ebp)
  8021c4:	e8 81 ef ff ff       	call   80114a <fd2data>
	return _pipeisclosed(fd, p);
  8021c9:	89 c2                	mov    %eax,%edx
  8021cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021ce:	e8 17 fd ff ff       	call   801eea <_pipeisclosed>
  8021d3:	83 c4 10             	add    $0x10,%esp
}
  8021d6:	c9                   	leave  
  8021d7:	c3                   	ret    

008021d8 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8021d8:	55                   	push   %ebp
  8021d9:	89 e5                	mov    %esp,%ebp
  8021db:	56                   	push   %esi
  8021dc:	53                   	push   %ebx
  8021dd:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  8021e0:	85 f6                	test   %esi,%esi
  8021e2:	75 16                	jne    8021fa <wait+0x22>
  8021e4:	68 57 2c 80 00       	push   $0x802c57
  8021e9:	68 6d 2b 80 00       	push   $0x802b6d
  8021ee:	6a 09                	push   $0x9
  8021f0:	68 62 2c 80 00       	push   $0x802c62
  8021f5:	e8 22 e2 ff ff       	call   80041c <_panic>
	e = &envs[ENVX(envid)];
  8021fa:	89 f3                	mov    %esi,%ebx
  8021fc:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802202:	8d 14 9d 00 00 00 00 	lea    0x0(,%ebx,4),%edx
  802209:	89 d8                	mov    %ebx,%eax
  80220b:	c1 e0 07             	shl    $0x7,%eax
  80220e:	29 d0                	sub    %edx,%eax
  802210:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802215:	8b 40 48             	mov    0x48(%eax),%eax
  802218:	39 c6                	cmp    %eax,%esi
  80221a:	75 31                	jne    80224d <wait+0x75>
  80221c:	89 d8                	mov    %ebx,%eax
  80221e:	c1 e0 07             	shl    $0x7,%eax
  802221:	29 d0                	sub    %edx,%eax
  802223:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802228:	8b 40 54             	mov    0x54(%eax),%eax
  80222b:	85 c0                	test   %eax,%eax
  80222d:	74 1e                	je     80224d <wait+0x75>
  80222f:	c1 e3 07             	shl    $0x7,%ebx
  802232:	29 d3                	sub    %edx,%ebx
  802234:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
		sys_yield();
  80223a:	e8 eb ec ff ff       	call   800f2a <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80223f:	8b 43 48             	mov    0x48(%ebx),%eax
  802242:	39 c6                	cmp    %eax,%esi
  802244:	75 07                	jne    80224d <wait+0x75>
  802246:	8b 43 54             	mov    0x54(%ebx),%eax
  802249:	85 c0                	test   %eax,%eax
  80224b:	75 ed                	jne    80223a <wait+0x62>
		sys_yield();
}
  80224d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802250:	5b                   	pop    %ebx
  802251:	5e                   	pop    %esi
  802252:	5d                   	pop    %ebp
  802253:	c3                   	ret    

00802254 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802254:	55                   	push   %ebp
  802255:	89 e5                	mov    %esp,%ebp
  802257:	56                   	push   %esi
  802258:	53                   	push   %ebx
  802259:	8b 75 08             	mov    0x8(%ebp),%esi
  80225c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80225f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");
	int r;
    if (pg != NULL) {
  802262:	85 c0                	test   %eax,%eax
  802264:	74 0e                	je     802274 <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  802266:	83 ec 0c             	sub    $0xc,%esp
  802269:	50                   	push   %eax
  80226a:	e8 8a ee ff ff       	call   8010f9 <sys_ipc_recv>
  80226f:	83 c4 10             	add    $0x10,%esp
  802272:	eb 10                	jmp    802284 <ipc_recv+0x30>
    } else {
        r = sys_ipc_recv((void *) UTOP);
  802274:	83 ec 0c             	sub    $0xc,%esp
  802277:	68 00 00 c0 ee       	push   $0xeec00000
  80227c:	e8 78 ee ff ff       	call   8010f9 <sys_ipc_recv>
  802281:	83 c4 10             	add    $0x10,%esp
    }
    if (r < 0) {
  802284:	85 c0                	test   %eax,%eax
  802286:	79 16                	jns    80229e <ipc_recv+0x4a>
        // failed
        if (from_env_store != NULL) *from_env_store = 0;
  802288:	85 f6                	test   %esi,%esi
  80228a:	74 06                	je     802292 <ipc_recv+0x3e>
  80228c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL) *perm_store = 0;
  802292:	85 db                	test   %ebx,%ebx
  802294:	74 2c                	je     8022c2 <ipc_recv+0x6e>
  802296:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80229c:	eb 24                	jmp    8022c2 <ipc_recv+0x6e>
        return r;
    } else {
        if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  80229e:	85 f6                	test   %esi,%esi
  8022a0:	74 0a                	je     8022ac <ipc_recv+0x58>
  8022a2:	a1 90 67 80 00       	mov    0x806790,%eax
  8022a7:	8b 40 74             	mov    0x74(%eax),%eax
  8022aa:	89 06                	mov    %eax,(%esi)
        if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  8022ac:	85 db                	test   %ebx,%ebx
  8022ae:	74 0a                	je     8022ba <ipc_recv+0x66>
  8022b0:	a1 90 67 80 00       	mov    0x806790,%eax
  8022b5:	8b 40 78             	mov    0x78(%eax),%eax
  8022b8:	89 03                	mov    %eax,(%ebx)
        return thisenv->env_ipc_value;
  8022ba:	a1 90 67 80 00       	mov    0x806790,%eax
  8022bf:	8b 40 70             	mov    0x70(%eax),%eax
    }
 
	return 0;
}
  8022c2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022c5:	5b                   	pop    %ebx
  8022c6:	5e                   	pop    %esi
  8022c7:	5d                   	pop    %ebp
  8022c8:	c3                   	ret    

008022c9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8022c9:	55                   	push   %ebp
  8022ca:	89 e5                	mov    %esp,%ebp
  8022cc:	57                   	push   %edi
  8022cd:	56                   	push   %esi
  8022ce:	53                   	push   %ebx
  8022cf:	83 ec 0c             	sub    $0xc,%esp
  8022d2:	8b 75 10             	mov    0x10(%ebp),%esi
  8022d5:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;
    if (pg == NULL) pg = (void *)UTOP;
  8022d8:	85 f6                	test   %esi,%esi
  8022da:	75 05                	jne    8022e1 <ipc_send+0x18>
  8022dc:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
  8022e1:	57                   	push   %edi
  8022e2:	56                   	push   %esi
  8022e3:	ff 75 0c             	pushl  0xc(%ebp)
  8022e6:	ff 75 08             	pushl  0x8(%ebp)
  8022e9:	e8 e8 ed ff ff       	call   8010d6 <sys_ipc_try_send>
  8022ee:	89 c3                	mov    %eax,%ebx
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
  8022f0:	83 c4 10             	add    $0x10,%esp
  8022f3:	85 c0                	test   %eax,%eax
  8022f5:	79 17                	jns    80230e <ipc_send+0x45>
  8022f7:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8022fa:	74 1d                	je     802319 <ipc_send+0x50>
  8022fc:	50                   	push   %eax
  8022fd:	68 6d 2c 80 00       	push   $0x802c6d
  802302:	6a 40                	push   $0x40
  802304:	68 81 2c 80 00       	push   $0x802c81
  802309:	e8 0e e1 ff ff       	call   80041c <_panic>
        sys_yield();
  80230e:	e8 17 ec ff ff       	call   800f2a <sys_yield>
    } while (r != 0);
  802313:	85 db                	test   %ebx,%ebx
  802315:	75 ca                	jne    8022e1 <ipc_send+0x18>
  802317:	eb 07                	jmp    802320 <ipc_send+0x57>
	int r;
    if (pg == NULL) pg = (void *)UTOP;
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
        sys_yield();
  802319:	e8 0c ec ff ff       	call   800f2a <sys_yield>
  80231e:	eb c1                	jmp    8022e1 <ipc_send+0x18>
    } while (r != 0);
}
  802320:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802323:	5b                   	pop    %ebx
  802324:	5e                   	pop    %esi
  802325:	5f                   	pop    %edi
  802326:	5d                   	pop    %ebp
  802327:	c3                   	ret    

00802328 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802328:	55                   	push   %ebp
  802329:	89 e5                	mov    %esp,%ebp
  80232b:	53                   	push   %ebx
  80232c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  80232f:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  802334:	39 c1                	cmp    %eax,%ecx
  802336:	74 21                	je     802359 <ipc_find_env+0x31>
  802338:	ba 01 00 00 00       	mov    $0x1,%edx
  80233d:	8d 1c 95 00 00 00 00 	lea    0x0(,%edx,4),%ebx
  802344:	89 d0                	mov    %edx,%eax
  802346:	c1 e0 07             	shl    $0x7,%eax
  802349:	29 d8                	sub    %ebx,%eax
  80234b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802350:	8b 40 50             	mov    0x50(%eax),%eax
  802353:	39 c8                	cmp    %ecx,%eax
  802355:	75 1b                	jne    802372 <ipc_find_env+0x4a>
  802357:	eb 05                	jmp    80235e <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802359:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_type == type)
			return envs[i].env_id;
  80235e:	8d 04 95 00 00 00 00 	lea    0x0(,%edx,4),%eax
  802365:	c1 e2 07             	shl    $0x7,%edx
  802368:	29 c2                	sub    %eax,%edx
  80236a:	8b 82 48 00 c0 ee    	mov    -0x113fffb8(%edx),%eax
  802370:	eb 0e                	jmp    802380 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802372:	42                   	inc    %edx
  802373:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  802379:	75 c2                	jne    80233d <ipc_find_env+0x15>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80237b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802380:	5b                   	pop    %ebx
  802381:	5d                   	pop    %ebp
  802382:	c3                   	ret    

00802383 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802383:	55                   	push   %ebp
  802384:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802386:	8b 45 08             	mov    0x8(%ebp),%eax
  802389:	c1 e8 16             	shr    $0x16,%eax
  80238c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802393:	a8 01                	test   $0x1,%al
  802395:	74 21                	je     8023b8 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802397:	8b 45 08             	mov    0x8(%ebp),%eax
  80239a:	c1 e8 0c             	shr    $0xc,%eax
  80239d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8023a4:	a8 01                	test   $0x1,%al
  8023a6:	74 17                	je     8023bf <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8023a8:	c1 e8 0c             	shr    $0xc,%eax
  8023ab:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8023b2:	ef 
  8023b3:	0f b7 c0             	movzwl %ax,%eax
  8023b6:	eb 0c                	jmp    8023c4 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8023b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8023bd:	eb 05                	jmp    8023c4 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8023bf:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8023c4:	5d                   	pop    %ebp
  8023c5:	c3                   	ret    
  8023c6:	66 90                	xchg   %ax,%ax

008023c8 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8023c8:	55                   	push   %ebp
  8023c9:	57                   	push   %edi
  8023ca:	56                   	push   %esi
  8023cb:	53                   	push   %ebx
  8023cc:	83 ec 1c             	sub    $0x1c,%esp
  8023cf:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8023d3:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8023d7:	8b 7c 24 38          	mov    0x38(%esp),%edi
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8023db:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023df:	89 ca                	mov    %ecx,%edx
  const DWunion dd = {.ll = d};
  8023e1:	89 f8                	mov    %edi,%eax
  8023e3:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8023e7:	85 f6                	test   %esi,%esi
  8023e9:	75 2d                	jne    802418 <__udivdi3+0x50>
    {
      if (d0 > n1)
  8023eb:	39 cf                	cmp    %ecx,%edi
  8023ed:	77 65                	ja     802454 <__udivdi3+0x8c>
  8023ef:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8023f1:	85 ff                	test   %edi,%edi
  8023f3:	75 0b                	jne    802400 <__udivdi3+0x38>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8023f5:	b8 01 00 00 00       	mov    $0x1,%eax
  8023fa:	31 d2                	xor    %edx,%edx
  8023fc:	f7 f7                	div    %edi
  8023fe:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802400:	31 d2                	xor    %edx,%edx
  802402:	89 c8                	mov    %ecx,%eax
  802404:	f7 f5                	div    %ebp
  802406:	89 c1                	mov    %eax,%ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802408:	89 d8                	mov    %ebx,%eax
  80240a:	f7 f5                	div    %ebp
  80240c:	89 cf                	mov    %ecx,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80240e:	89 fa                	mov    %edi,%edx
  802410:	83 c4 1c             	add    $0x1c,%esp
  802413:	5b                   	pop    %ebx
  802414:	5e                   	pop    %esi
  802415:	5f                   	pop    %edi
  802416:	5d                   	pop    %ebp
  802417:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802418:	39 ce                	cmp    %ecx,%esi
  80241a:	77 28                	ja     802444 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80241c:	0f bd fe             	bsr    %esi,%edi
	  if (bm == 0)
  80241f:	83 f7 1f             	xor    $0x1f,%edi
  802422:	75 40                	jne    802464 <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802424:	39 ce                	cmp    %ecx,%esi
  802426:	72 0a                	jb     802432 <__udivdi3+0x6a>
  802428:	3b 44 24 08          	cmp    0x8(%esp),%eax
  80242c:	0f 87 9e 00 00 00    	ja     8024d0 <__udivdi3+0x108>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802432:	b8 01 00 00 00       	mov    $0x1,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802437:	89 fa                	mov    %edi,%edx
  802439:	83 c4 1c             	add    $0x1c,%esp
  80243c:	5b                   	pop    %ebx
  80243d:	5e                   	pop    %esi
  80243e:	5f                   	pop    %edi
  80243f:	5d                   	pop    %ebp
  802440:	c3                   	ret    
  802441:	8d 76 00             	lea    0x0(%esi),%esi
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802444:	31 ff                	xor    %edi,%edi
  802446:	31 c0                	xor    %eax,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802448:	89 fa                	mov    %edi,%edx
  80244a:	83 c4 1c             	add    $0x1c,%esp
  80244d:	5b                   	pop    %ebx
  80244e:	5e                   	pop    %esi
  80244f:	5f                   	pop    %edi
  802450:	5d                   	pop    %ebp
  802451:	c3                   	ret    
  802452:	66 90                	xchg   %ax,%ax
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802454:	89 d8                	mov    %ebx,%eax
  802456:	f7 f7                	div    %edi
  802458:	31 ff                	xor    %edi,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80245a:	89 fa                	mov    %edi,%edx
  80245c:	83 c4 1c             	add    $0x1c,%esp
  80245f:	5b                   	pop    %ebx
  802460:	5e                   	pop    %esi
  802461:	5f                   	pop    %edi
  802462:	5d                   	pop    %ebp
  802463:	c3                   	ret    
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802464:	bd 20 00 00 00       	mov    $0x20,%ebp
  802469:	89 eb                	mov    %ebp,%ebx
  80246b:	29 fb                	sub    %edi,%ebx

	      d1 = (d1 << bm) | (d0 >> b);
  80246d:	89 f9                	mov    %edi,%ecx
  80246f:	d3 e6                	shl    %cl,%esi
  802471:	89 c5                	mov    %eax,%ebp
  802473:	88 d9                	mov    %bl,%cl
  802475:	d3 ed                	shr    %cl,%ebp
  802477:	89 e9                	mov    %ebp,%ecx
  802479:	09 f1                	or     %esi,%ecx
  80247b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
	      d0 = d0 << bm;
  80247f:	89 f9                	mov    %edi,%ecx
  802481:	d3 e0                	shl    %cl,%eax
  802483:	89 c5                	mov    %eax,%ebp
	      n2 = n1 >> b;
  802485:	89 d6                	mov    %edx,%esi
  802487:	88 d9                	mov    %bl,%cl
  802489:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
  80248b:	89 f9                	mov    %edi,%ecx
  80248d:	d3 e2                	shl    %cl,%edx
  80248f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802493:	88 d9                	mov    %bl,%cl
  802495:	d3 e8                	shr    %cl,%eax
  802497:	09 c2                	or     %eax,%edx
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802499:	89 d0                	mov    %edx,%eax
  80249b:	89 f2                	mov    %esi,%edx
  80249d:	f7 74 24 0c          	divl   0xc(%esp)
  8024a1:	89 d6                	mov    %edx,%esi
  8024a3:	89 c3                	mov    %eax,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  8024a5:	f7 e5                	mul    %ebp

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8024a7:	39 d6                	cmp    %edx,%esi
  8024a9:	72 19                	jb     8024c4 <__udivdi3+0xfc>
  8024ab:	74 0b                	je     8024b8 <__udivdi3+0xf0>
  8024ad:	89 d8                	mov    %ebx,%eax
  8024af:	31 ff                	xor    %edi,%edi
  8024b1:	e9 58 ff ff ff       	jmp    80240e <__udivdi3+0x46>
  8024b6:	66 90                	xchg   %ax,%ax
  8024b8:	8b 54 24 08          	mov    0x8(%esp),%edx
  8024bc:	89 f9                	mov    %edi,%ecx
  8024be:	d3 e2                	shl    %cl,%edx
  8024c0:	39 c2                	cmp    %eax,%edx
  8024c2:	73 e9                	jae    8024ad <__udivdi3+0xe5>
  8024c4:	8d 43 ff             	lea    -0x1(%ebx),%eax
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8024c7:	31 ff                	xor    %edi,%edi
  8024c9:	e9 40 ff ff ff       	jmp    80240e <__udivdi3+0x46>
  8024ce:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8024d0:	31 c0                	xor    %eax,%eax
  8024d2:	e9 37 ff ff ff       	jmp    80240e <__udivdi3+0x46>
  8024d7:	90                   	nop

008024d8 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8024d8:	55                   	push   %ebp
  8024d9:	57                   	push   %edi
  8024da:	56                   	push   %esi
  8024db:	53                   	push   %ebx
  8024dc:	83 ec 1c             	sub    $0x1c,%esp
  8024df:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8024e3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8024e7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8024eb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8024ef:	89 44 24 0c          	mov    %eax,0xc(%esp)
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8024f3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024f7:	89 f3                	mov    %esi,%ebx
  const DWunion dd = {.ll = d};
  8024f9:	89 fa                	mov    %edi,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8024fb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  n1 = nn.s.high;
  8024ff:	89 34 24             	mov    %esi,(%esp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802502:	85 c0                	test   %eax,%eax
  802504:	75 1a                	jne    802520 <__umoddi3+0x48>
    {
      if (d0 > n1)
  802506:	39 f7                	cmp    %esi,%edi
  802508:	0f 86 a2 00 00 00    	jbe    8025b0 <__umoddi3+0xd8>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80250e:	89 c8                	mov    %ecx,%eax
  802510:	89 f2                	mov    %esi,%edx
  802512:	f7 f7                	div    %edi
  802514:	89 d0                	mov    %edx,%eax

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802516:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802518:	83 c4 1c             	add    $0x1c,%esp
  80251b:	5b                   	pop    %ebx
  80251c:	5e                   	pop    %esi
  80251d:	5f                   	pop    %edi
  80251e:	5d                   	pop    %ebp
  80251f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802520:	39 f0                	cmp    %esi,%eax
  802522:	0f 87 ac 00 00 00    	ja     8025d4 <__umoddi3+0xfc>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802528:	0f bd e8             	bsr    %eax,%ebp
	  if (bm == 0)
  80252b:	83 f5 1f             	xor    $0x1f,%ebp
  80252e:	0f 84 ac 00 00 00    	je     8025e0 <__umoddi3+0x108>
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802534:	bf 20 00 00 00       	mov    $0x20,%edi
  802539:	29 ef                	sub    %ebp,%edi
  80253b:	89 fe                	mov    %edi,%esi
  80253d:	89 7c 24 0c          	mov    %edi,0xc(%esp)

	      d1 = (d1 << bm) | (d0 >> b);
  802541:	89 e9                	mov    %ebp,%ecx
  802543:	d3 e0                	shl    %cl,%eax
  802545:	89 d7                	mov    %edx,%edi
  802547:	89 f1                	mov    %esi,%ecx
  802549:	d3 ef                	shr    %cl,%edi
  80254b:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  80254d:	89 e9                	mov    %ebp,%ecx
  80254f:	d3 e2                	shl    %cl,%edx
  802551:	89 14 24             	mov    %edx,(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802554:	89 d8                	mov    %ebx,%eax
  802556:	d3 e0                	shl    %cl,%eax
  802558:	89 c2                	mov    %eax,%edx
	      n0 = n0 << bm;
  80255a:	8b 44 24 08          	mov    0x8(%esp),%eax
  80255e:	d3 e0                	shl    %cl,%eax
  802560:	89 44 24 04          	mov    %eax,0x4(%esp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802564:	8b 44 24 08          	mov    0x8(%esp),%eax
  802568:	89 f1                	mov    %esi,%ecx
  80256a:	d3 e8                	shr    %cl,%eax
  80256c:	09 d0                	or     %edx,%eax
  80256e:	d3 eb                	shr    %cl,%ebx
  802570:	89 da                	mov    %ebx,%edx
  802572:	f7 f7                	div    %edi
  802574:	89 d3                	mov    %edx,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  802576:	f7 24 24             	mull   (%esp)
  802579:	89 c6                	mov    %eax,%esi
  80257b:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80257d:	39 d3                	cmp    %edx,%ebx
  80257f:	0f 82 87 00 00 00    	jb     80260c <__umoddi3+0x134>
  802585:	0f 84 91 00 00 00    	je     80261c <__umoddi3+0x144>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80258b:	8b 54 24 04          	mov    0x4(%esp),%edx
  80258f:	29 f2                	sub    %esi,%edx
  802591:	19 cb                	sbb    %ecx,%ebx
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802593:	89 d8                	mov    %ebx,%eax
  802595:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  802599:	d3 e0                	shl    %cl,%eax
  80259b:	89 e9                	mov    %ebp,%ecx
  80259d:	d3 ea                	shr    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80259f:	09 d0                	or     %edx,%eax
  8025a1:	89 e9                	mov    %ebp,%ecx
  8025a3:	d3 eb                	shr    %cl,%ebx
  8025a5:	89 da                	mov    %ebx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8025a7:	83 c4 1c             	add    $0x1c,%esp
  8025aa:	5b                   	pop    %ebx
  8025ab:	5e                   	pop    %esi
  8025ac:	5f                   	pop    %edi
  8025ad:	5d                   	pop    %ebp
  8025ae:	c3                   	ret    
  8025af:	90                   	nop
  8025b0:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8025b2:	85 ff                	test   %edi,%edi
  8025b4:	75 0b                	jne    8025c1 <__umoddi3+0xe9>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8025b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8025bb:	31 d2                	xor    %edx,%edx
  8025bd:	f7 f7                	div    %edi
  8025bf:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8025c1:	89 f0                	mov    %esi,%eax
  8025c3:	31 d2                	xor    %edx,%edx
  8025c5:	f7 f5                	div    %ebp
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8025c7:	89 c8                	mov    %ecx,%eax
  8025c9:	f7 f5                	div    %ebp
  8025cb:	89 d0                	mov    %edx,%eax
  8025cd:	e9 44 ff ff ff       	jmp    802516 <__umoddi3+0x3e>
  8025d2:	66 90                	xchg   %ax,%ax
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8025d4:	89 c8                	mov    %ecx,%eax
  8025d6:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8025d8:	83 c4 1c             	add    $0x1c,%esp
  8025db:	5b                   	pop    %ebx
  8025dc:	5e                   	pop    %esi
  8025dd:	5f                   	pop    %edi
  8025de:	5d                   	pop    %ebp
  8025df:	c3                   	ret    

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8025e0:	3b 04 24             	cmp    (%esp),%eax
  8025e3:	72 06                	jb     8025eb <__umoddi3+0x113>
  8025e5:	3b 7c 24 04          	cmp    0x4(%esp),%edi
  8025e9:	77 0f                	ja     8025fa <__umoddi3+0x122>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8025eb:	89 f2                	mov    %esi,%edx
  8025ed:	29 f9                	sub    %edi,%ecx
  8025ef:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  8025f3:	89 14 24             	mov    %edx,(%esp)
  8025f6:	89 4c 24 04          	mov    %ecx,0x4(%esp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8025fa:	8b 44 24 04          	mov    0x4(%esp),%eax
  8025fe:	8b 14 24             	mov    (%esp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802601:	83 c4 1c             	add    $0x1c,%esp
  802604:	5b                   	pop    %ebx
  802605:	5e                   	pop    %esi
  802606:	5f                   	pop    %edi
  802607:	5d                   	pop    %ebp
  802608:	c3                   	ret    
  802609:	8d 76 00             	lea    0x0(%esi),%esi
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80260c:	2b 04 24             	sub    (%esp),%eax
  80260f:	19 fa                	sbb    %edi,%edx
  802611:	89 d1                	mov    %edx,%ecx
  802613:	89 c6                	mov    %eax,%esi
  802615:	e9 71 ff ff ff       	jmp    80258b <__umoddi3+0xb3>
  80261a:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80261c:	39 44 24 04          	cmp    %eax,0x4(%esp)
  802620:	72 ea                	jb     80260c <__umoddi3+0x134>
  802622:	89 d9                	mov    %ebx,%ecx
  802624:	e9 62 ff ff ff       	jmp    80258b <__umoddi3+0xb3>
