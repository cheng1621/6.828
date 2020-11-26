
obj/user/testkbd.debug:     file format elf32-i386


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
  80002c:	e8 44 02 00 00       	call   800275 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 04             	sub    $0x4,%esp
  80003a:	bb 0a 00 00 00       	mov    $0xa,%ebx
	int i, r;

	// Spin for a bit to let the console quiet
	for (i = 0; i < 10; ++i)
		sys_yield();
  80003f:	e8 ae 0e 00 00       	call   800ef2 <sys_yield>
umain(int argc, char **argv)
{
	int i, r;

	// Spin for a bit to let the console quiet
	for (i = 0; i < 10; ++i)
  800044:	4b                   	dec    %ebx
  800045:	75 f8                	jne    80003f <umain+0xc>
		sys_yield();

	close(0);
  800047:	83 ec 0c             	sub    $0xc,%esp
  80004a:	6a 00                	push   $0x0
  80004c:	e8 95 12 00 00       	call   8012e6 <close>
	if ((r = opencons()) < 0)
  800051:	e8 cd 01 00 00       	call   800223 <opencons>
  800056:	83 c4 10             	add    $0x10,%esp
  800059:	85 c0                	test   %eax,%eax
  80005b:	79 12                	jns    80006f <umain+0x3c>
		panic("opencons: %e", r);
  80005d:	50                   	push   %eax
  80005e:	68 00 21 80 00       	push   $0x802100
  800063:	6a 0f                	push   $0xf
  800065:	68 0d 21 80 00       	push   $0x80210d
  80006a:	e8 6f 02 00 00       	call   8002de <_panic>
	if (r != 0)
  80006f:	85 c0                	test   %eax,%eax
  800071:	74 12                	je     800085 <umain+0x52>
		panic("first opencons used fd %d", r);
  800073:	50                   	push   %eax
  800074:	68 1c 21 80 00       	push   $0x80211c
  800079:	6a 11                	push   $0x11
  80007b:	68 0d 21 80 00       	push   $0x80210d
  800080:	e8 59 02 00 00       	call   8002de <_panic>
	if ((r = dup(0, 1)) < 0)
  800085:	83 ec 08             	sub    $0x8,%esp
  800088:	6a 01                	push   $0x1
  80008a:	6a 00                	push   $0x0
  80008c:	e8 a3 12 00 00       	call   801334 <dup>
  800091:	83 c4 10             	add    $0x10,%esp
  800094:	85 c0                	test   %eax,%eax
  800096:	79 12                	jns    8000aa <umain+0x77>
		panic("dup: %e", r);
  800098:	50                   	push   %eax
  800099:	68 36 21 80 00       	push   $0x802136
  80009e:	6a 13                	push   $0x13
  8000a0:	68 0d 21 80 00       	push   $0x80210d
  8000a5:	e8 34 02 00 00       	call   8002de <_panic>

	for(;;){
		char *buf;

		buf = readline("Type a line: ");
  8000aa:	83 ec 0c             	sub    $0xc,%esp
  8000ad:	68 3e 21 80 00       	push   $0x80213e
  8000b2:	e8 8d 08 00 00       	call   800944 <readline>
		if (buf != NULL)
  8000b7:	83 c4 10             	add    $0x10,%esp
  8000ba:	85 c0                	test   %eax,%eax
  8000bc:	74 15                	je     8000d3 <umain+0xa0>
			fprintf(1, "%s\n", buf);
  8000be:	83 ec 04             	sub    $0x4,%esp
  8000c1:	50                   	push   %eax
  8000c2:	68 4c 21 80 00       	push   $0x80214c
  8000c7:	6a 01                	push   $0x1
  8000c9:	e8 bc 18 00 00       	call   80198a <fprintf>
  8000ce:	83 c4 10             	add    $0x10,%esp
  8000d1:	eb d7                	jmp    8000aa <umain+0x77>
		else
			fprintf(1, "(end of file received)\n");
  8000d3:	83 ec 08             	sub    $0x8,%esp
  8000d6:	68 50 21 80 00       	push   $0x802150
  8000db:	6a 01                	push   $0x1
  8000dd:	e8 a8 18 00 00       	call   80198a <fprintf>
  8000e2:	83 c4 10             	add    $0x10,%esp
  8000e5:	eb c3                	jmp    8000aa <umain+0x77>

008000e7 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8000ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ef:	5d                   	pop    %ebp
  8000f0:	c3                   	ret    

008000f1 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8000f1:	55                   	push   %ebp
  8000f2:	89 e5                	mov    %esp,%ebp
  8000f4:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8000f7:	68 68 21 80 00       	push   $0x802168
  8000fc:	ff 75 0c             	pushl  0xc(%ebp)
  8000ff:	e8 9d 09 00 00       	call   800aa1 <strcpy>
	return 0;
}
  800104:	b8 00 00 00 00       	mov    $0x0,%eax
  800109:	c9                   	leave  
  80010a:	c3                   	ret    

0080010b <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80010b:	55                   	push   %ebp
  80010c:	89 e5                	mov    %esp,%ebp
  80010e:	57                   	push   %edi
  80010f:	56                   	push   %esi
  800110:	53                   	push   %ebx
  800111:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800117:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80011b:	74 45                	je     800162 <devcons_write+0x57>
  80011d:	b8 00 00 00 00       	mov    $0x0,%eax
  800122:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800127:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80012d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800130:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  800132:	83 fb 7f             	cmp    $0x7f,%ebx
  800135:	76 05                	jbe    80013c <devcons_write+0x31>
			m = sizeof(buf) - 1;
  800137:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  80013c:	83 ec 04             	sub    $0x4,%esp
  80013f:	53                   	push   %ebx
  800140:	03 45 0c             	add    0xc(%ebp),%eax
  800143:	50                   	push   %eax
  800144:	57                   	push   %edi
  800145:	e8 24 0b 00 00       	call   800c6e <memmove>
		sys_cputs(buf, m);
  80014a:	83 c4 08             	add    $0x8,%esp
  80014d:	53                   	push   %ebx
  80014e:	57                   	push   %edi
  80014f:	e8 01 0d 00 00       	call   800e55 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800154:	01 de                	add    %ebx,%esi
  800156:	89 f0                	mov    %esi,%eax
  800158:	83 c4 10             	add    $0x10,%esp
  80015b:	3b 75 10             	cmp    0x10(%ebp),%esi
  80015e:	72 cd                	jb     80012d <devcons_write+0x22>
  800160:	eb 05                	jmp    800167 <devcons_write+0x5c>
  800162:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800167:	89 f0                	mov    %esi,%eax
  800169:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80016c:	5b                   	pop    %ebx
  80016d:	5e                   	pop    %esi
  80016e:	5f                   	pop    %edi
  80016f:	5d                   	pop    %ebp
  800170:	c3                   	ret    

00800171 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800171:	55                   	push   %ebp
  800172:	89 e5                	mov    %esp,%ebp
  800174:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  800177:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80017b:	75 07                	jne    800184 <devcons_read+0x13>
  80017d:	eb 23                	jmp    8001a2 <devcons_read+0x31>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80017f:	e8 6e 0d 00 00       	call   800ef2 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800184:	e8 ea 0c 00 00       	call   800e73 <sys_cgetc>
  800189:	85 c0                	test   %eax,%eax
  80018b:	74 f2                	je     80017f <devcons_read+0xe>
		sys_yield();
	if (c < 0)
  80018d:	85 c0                	test   %eax,%eax
  80018f:	78 1d                	js     8001ae <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800191:	83 f8 04             	cmp    $0x4,%eax
  800194:	74 13                	je     8001a9 <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  800196:	8b 55 0c             	mov    0xc(%ebp),%edx
  800199:	88 02                	mov    %al,(%edx)
	return 1;
  80019b:	b8 01 00 00 00       	mov    $0x1,%eax
  8001a0:	eb 0c                	jmp    8001ae <devcons_read+0x3d>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8001a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8001a7:	eb 05                	jmp    8001ae <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8001a9:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8001ae:	c9                   	leave  
  8001af:	c3                   	ret    

008001b0 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8001b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b9:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8001bc:	6a 01                	push   $0x1
  8001be:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8001c1:	50                   	push   %eax
  8001c2:	e8 8e 0c 00 00       	call   800e55 <sys_cputs>
}
  8001c7:	83 c4 10             	add    $0x10,%esp
  8001ca:	c9                   	leave  
  8001cb:	c3                   	ret    

008001cc <getchar>:

int
getchar(void)
{
  8001cc:	55                   	push   %ebp
  8001cd:	89 e5                	mov    %esp,%ebp
  8001cf:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8001d2:	6a 01                	push   $0x1
  8001d4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8001d7:	50                   	push   %eax
  8001d8:	6a 00                	push   $0x0
  8001da:	e8 3f 12 00 00       	call   80141e <read>
	if (r < 0)
  8001df:	83 c4 10             	add    $0x10,%esp
  8001e2:	85 c0                	test   %eax,%eax
  8001e4:	78 0f                	js     8001f5 <getchar+0x29>
		return r;
	if (r < 1)
  8001e6:	85 c0                	test   %eax,%eax
  8001e8:	7e 06                	jle    8001f0 <getchar+0x24>
		return -E_EOF;
	return c;
  8001ea:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8001ee:	eb 05                	jmp    8001f5 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8001f0:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8001f5:	c9                   	leave  
  8001f6:	c3                   	ret    

008001f7 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8001f7:	55                   	push   %ebp
  8001f8:	89 e5                	mov    %esp,%ebp
  8001fa:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8001fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800200:	50                   	push   %eax
  800201:	ff 75 08             	pushl  0x8(%ebp)
  800204:	e8 94 0f 00 00       	call   80119d <fd_lookup>
  800209:	83 c4 10             	add    $0x10,%esp
  80020c:	85 c0                	test   %eax,%eax
  80020e:	78 11                	js     800221 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800210:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800213:	8b 15 00 30 80 00    	mov    0x803000,%edx
  800219:	39 10                	cmp    %edx,(%eax)
  80021b:	0f 94 c0             	sete   %al
  80021e:	0f b6 c0             	movzbl %al,%eax
}
  800221:	c9                   	leave  
  800222:	c3                   	ret    

00800223 <opencons>:

int
opencons(void)
{
  800223:	55                   	push   %ebp
  800224:	89 e5                	mov    %esp,%ebp
  800226:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800229:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80022c:	50                   	push   %eax
  80022d:	e8 f7 0e 00 00       	call   801129 <fd_alloc>
  800232:	83 c4 10             	add    $0x10,%esp
  800235:	85 c0                	test   %eax,%eax
  800237:	78 3a                	js     800273 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800239:	83 ec 04             	sub    $0x4,%esp
  80023c:	68 07 04 00 00       	push   $0x407
  800241:	ff 75 f4             	pushl  -0xc(%ebp)
  800244:	6a 00                	push   $0x0
  800246:	e8 c6 0c 00 00       	call   800f11 <sys_page_alloc>
  80024b:	83 c4 10             	add    $0x10,%esp
  80024e:	85 c0                	test   %eax,%eax
  800250:	78 21                	js     800273 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800252:	8b 15 00 30 80 00    	mov    0x803000,%edx
  800258:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80025b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80025d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800260:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800267:	83 ec 0c             	sub    $0xc,%esp
  80026a:	50                   	push   %eax
  80026b:	e8 92 0e 00 00       	call   801102 <fd2num>
  800270:	83 c4 10             	add    $0x10,%esp
}
  800273:	c9                   	leave  
  800274:	c3                   	ret    

00800275 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800275:	55                   	push   %ebp
  800276:	89 e5                	mov    %esp,%ebp
  800278:	56                   	push   %esi
  800279:	53                   	push   %ebx
  80027a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80027d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800280:	e8 4e 0c 00 00       	call   800ed3 <sys_getenvid>
  800285:	25 ff 03 00 00       	and    $0x3ff,%eax
  80028a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800291:	c1 e0 07             	shl    $0x7,%eax
  800294:	29 d0                	sub    %edx,%eax
  800296:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80029b:	a3 04 44 80 00       	mov    %eax,0x804404

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002a0:	85 db                	test   %ebx,%ebx
  8002a2:	7e 07                	jle    8002ab <libmain+0x36>
		binaryname = argv[0];
  8002a4:	8b 06                	mov    (%esi),%eax
  8002a6:	a3 1c 30 80 00       	mov    %eax,0x80301c

	// call user main routine
	umain(argc, argv);
  8002ab:	83 ec 08             	sub    $0x8,%esp
  8002ae:	56                   	push   %esi
  8002af:	53                   	push   %ebx
  8002b0:	e8 7e fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8002b5:	e8 0a 00 00 00       	call   8002c4 <exit>
}
  8002ba:	83 c4 10             	add    $0x10,%esp
  8002bd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002c0:	5b                   	pop    %ebx
  8002c1:	5e                   	pop    %esi
  8002c2:	5d                   	pop    %ebp
  8002c3:	c3                   	ret    

008002c4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8002ca:	e8 42 10 00 00       	call   801311 <close_all>
	sys_env_destroy(0);
  8002cf:	83 ec 0c             	sub    $0xc,%esp
  8002d2:	6a 00                	push   $0x0
  8002d4:	e8 b9 0b 00 00       	call   800e92 <sys_env_destroy>
}
  8002d9:	83 c4 10             	add    $0x10,%esp
  8002dc:	c9                   	leave  
  8002dd:	c3                   	ret    

008002de <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002de:	55                   	push   %ebp
  8002df:	89 e5                	mov    %esp,%ebp
  8002e1:	56                   	push   %esi
  8002e2:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002e3:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002e6:	8b 35 1c 30 80 00    	mov    0x80301c,%esi
  8002ec:	e8 e2 0b 00 00       	call   800ed3 <sys_getenvid>
  8002f1:	83 ec 0c             	sub    $0xc,%esp
  8002f4:	ff 75 0c             	pushl  0xc(%ebp)
  8002f7:	ff 75 08             	pushl  0x8(%ebp)
  8002fa:	56                   	push   %esi
  8002fb:	50                   	push   %eax
  8002fc:	68 80 21 80 00       	push   $0x802180
  800301:	e8 b0 00 00 00       	call   8003b6 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800306:	83 c4 18             	add    $0x18,%esp
  800309:	53                   	push   %ebx
  80030a:	ff 75 10             	pushl  0x10(%ebp)
  80030d:	e8 53 00 00 00       	call   800365 <vcprintf>
	cprintf("\n");
  800312:	c7 04 24 66 21 80 00 	movl   $0x802166,(%esp)
  800319:	e8 98 00 00 00       	call   8003b6 <cprintf>
  80031e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800321:	cc                   	int3   
  800322:	eb fd                	jmp    800321 <_panic+0x43>

00800324 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800324:	55                   	push   %ebp
  800325:	89 e5                	mov    %esp,%ebp
  800327:	53                   	push   %ebx
  800328:	83 ec 04             	sub    $0x4,%esp
  80032b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80032e:	8b 13                	mov    (%ebx),%edx
  800330:	8d 42 01             	lea    0x1(%edx),%eax
  800333:	89 03                	mov    %eax,(%ebx)
  800335:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800338:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80033c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800341:	75 1a                	jne    80035d <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800343:	83 ec 08             	sub    $0x8,%esp
  800346:	68 ff 00 00 00       	push   $0xff
  80034b:	8d 43 08             	lea    0x8(%ebx),%eax
  80034e:	50                   	push   %eax
  80034f:	e8 01 0b 00 00       	call   800e55 <sys_cputs>
		b->idx = 0;
  800354:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80035a:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80035d:	ff 43 04             	incl   0x4(%ebx)
}
  800360:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800363:	c9                   	leave  
  800364:	c3                   	ret    

00800365 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800365:	55                   	push   %ebp
  800366:	89 e5                	mov    %esp,%ebp
  800368:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80036e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800375:	00 00 00 
	b.cnt = 0;
  800378:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80037f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800382:	ff 75 0c             	pushl  0xc(%ebp)
  800385:	ff 75 08             	pushl  0x8(%ebp)
  800388:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80038e:	50                   	push   %eax
  80038f:	68 24 03 80 00       	push   $0x800324
  800394:	e8 54 01 00 00       	call   8004ed <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800399:	83 c4 08             	add    $0x8,%esp
  80039c:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003a2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003a8:	50                   	push   %eax
  8003a9:	e8 a7 0a 00 00       	call   800e55 <sys_cputs>

	return b.cnt;
}
  8003ae:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003b4:	c9                   	leave  
  8003b5:	c3                   	ret    

008003b6 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003b6:	55                   	push   %ebp
  8003b7:	89 e5                	mov    %esp,%ebp
  8003b9:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003bc:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003bf:	50                   	push   %eax
  8003c0:	ff 75 08             	pushl  0x8(%ebp)
  8003c3:	e8 9d ff ff ff       	call   800365 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003c8:	c9                   	leave  
  8003c9:	c3                   	ret    

008003ca <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003ca:	55                   	push   %ebp
  8003cb:	89 e5                	mov    %esp,%ebp
  8003cd:	57                   	push   %edi
  8003ce:	56                   	push   %esi
  8003cf:	53                   	push   %ebx
  8003d0:	83 ec 1c             	sub    $0x1c,%esp
  8003d3:	89 c6                	mov    %eax,%esi
  8003d5:	89 d7                	mov    %edx,%edi
  8003d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003dd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003e0:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003e3:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8003e6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003eb:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8003ee:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8003f1:	39 d3                	cmp    %edx,%ebx
  8003f3:	72 11                	jb     800406 <printnum+0x3c>
  8003f5:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003f8:	76 0c                	jbe    800406 <printnum+0x3c>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fd:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800400:	85 db                	test   %ebx,%ebx
  800402:	7f 37                	jg     80043b <printnum+0x71>
  800404:	eb 44                	jmp    80044a <printnum+0x80>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800406:	83 ec 0c             	sub    $0xc,%esp
  800409:	ff 75 18             	pushl  0x18(%ebp)
  80040c:	8b 45 14             	mov    0x14(%ebp),%eax
  80040f:	48                   	dec    %eax
  800410:	50                   	push   %eax
  800411:	ff 75 10             	pushl  0x10(%ebp)
  800414:	83 ec 08             	sub    $0x8,%esp
  800417:	ff 75 e4             	pushl  -0x1c(%ebp)
  80041a:	ff 75 e0             	pushl  -0x20(%ebp)
  80041d:	ff 75 dc             	pushl  -0x24(%ebp)
  800420:	ff 75 d8             	pushl  -0x28(%ebp)
  800423:	e8 68 1a 00 00       	call   801e90 <__udivdi3>
  800428:	83 c4 18             	add    $0x18,%esp
  80042b:	52                   	push   %edx
  80042c:	50                   	push   %eax
  80042d:	89 fa                	mov    %edi,%edx
  80042f:	89 f0                	mov    %esi,%eax
  800431:	e8 94 ff ff ff       	call   8003ca <printnum>
  800436:	83 c4 20             	add    $0x20,%esp
  800439:	eb 0f                	jmp    80044a <printnum+0x80>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80043b:	83 ec 08             	sub    $0x8,%esp
  80043e:	57                   	push   %edi
  80043f:	ff 75 18             	pushl  0x18(%ebp)
  800442:	ff d6                	call   *%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800444:	83 c4 10             	add    $0x10,%esp
  800447:	4b                   	dec    %ebx
  800448:	75 f1                	jne    80043b <printnum+0x71>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80044a:	83 ec 08             	sub    $0x8,%esp
  80044d:	57                   	push   %edi
  80044e:	83 ec 04             	sub    $0x4,%esp
  800451:	ff 75 e4             	pushl  -0x1c(%ebp)
  800454:	ff 75 e0             	pushl  -0x20(%ebp)
  800457:	ff 75 dc             	pushl  -0x24(%ebp)
  80045a:	ff 75 d8             	pushl  -0x28(%ebp)
  80045d:	e8 3e 1b 00 00       	call   801fa0 <__umoddi3>
  800462:	83 c4 14             	add    $0x14,%esp
  800465:	0f be 80 a3 21 80 00 	movsbl 0x8021a3(%eax),%eax
  80046c:	50                   	push   %eax
  80046d:	ff d6                	call   *%esi
}
  80046f:	83 c4 10             	add    $0x10,%esp
  800472:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800475:	5b                   	pop    %ebx
  800476:	5e                   	pop    %esi
  800477:	5f                   	pop    %edi
  800478:	5d                   	pop    %ebp
  800479:	c3                   	ret    

0080047a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80047a:	55                   	push   %ebp
  80047b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80047d:	83 fa 01             	cmp    $0x1,%edx
  800480:	7e 0e                	jle    800490 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800482:	8b 10                	mov    (%eax),%edx
  800484:	8d 4a 08             	lea    0x8(%edx),%ecx
  800487:	89 08                	mov    %ecx,(%eax)
  800489:	8b 02                	mov    (%edx),%eax
  80048b:	8b 52 04             	mov    0x4(%edx),%edx
  80048e:	eb 22                	jmp    8004b2 <getuint+0x38>
	else if (lflag)
  800490:	85 d2                	test   %edx,%edx
  800492:	74 10                	je     8004a4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800494:	8b 10                	mov    (%eax),%edx
  800496:	8d 4a 04             	lea    0x4(%edx),%ecx
  800499:	89 08                	mov    %ecx,(%eax)
  80049b:	8b 02                	mov    (%edx),%eax
  80049d:	ba 00 00 00 00       	mov    $0x0,%edx
  8004a2:	eb 0e                	jmp    8004b2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004a4:	8b 10                	mov    (%eax),%edx
  8004a6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004a9:	89 08                	mov    %ecx,(%eax)
  8004ab:	8b 02                	mov    (%edx),%eax
  8004ad:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004b2:	5d                   	pop    %ebp
  8004b3:	c3                   	ret    

008004b4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004b4:	55                   	push   %ebp
  8004b5:	89 e5                	mov    %esp,%ebp
  8004b7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004ba:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8004bd:	8b 10                	mov    (%eax),%edx
  8004bf:	3b 50 04             	cmp    0x4(%eax),%edx
  8004c2:	73 0a                	jae    8004ce <sprintputch+0x1a>
		*b->buf++ = ch;
  8004c4:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004c7:	89 08                	mov    %ecx,(%eax)
  8004c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8004cc:	88 02                	mov    %al,(%edx)
}
  8004ce:	5d                   	pop    %ebp
  8004cf:	c3                   	ret    

008004d0 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004d0:	55                   	push   %ebp
  8004d1:	89 e5                	mov    %esp,%ebp
  8004d3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004d6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004d9:	50                   	push   %eax
  8004da:	ff 75 10             	pushl  0x10(%ebp)
  8004dd:	ff 75 0c             	pushl  0xc(%ebp)
  8004e0:	ff 75 08             	pushl  0x8(%ebp)
  8004e3:	e8 05 00 00 00       	call   8004ed <vprintfmt>
	va_end(ap);
}
  8004e8:	83 c4 10             	add    $0x10,%esp
  8004eb:	c9                   	leave  
  8004ec:	c3                   	ret    

008004ed <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004ed:	55                   	push   %ebp
  8004ee:	89 e5                	mov    %esp,%ebp
  8004f0:	57                   	push   %edi
  8004f1:	56                   	push   %esi
  8004f2:	53                   	push   %ebx
  8004f3:	83 ec 2c             	sub    $0x2c,%esp
  8004f6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004fc:	eb 03                	jmp    800501 <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  8004fe:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  800501:	8b 45 10             	mov    0x10(%ebp),%eax
  800504:	8d 70 01             	lea    0x1(%eax),%esi
  800507:	0f b6 00             	movzbl (%eax),%eax
  80050a:	83 f8 25             	cmp    $0x25,%eax
  80050d:	74 25                	je     800534 <vprintfmt+0x47>
			if (ch == '\0')									//当然中间如果遇到'\0'，代表这个字符串的访问结束
  80050f:	85 c0                	test   %eax,%eax
  800511:	75 0d                	jne    800520 <vprintfmt+0x33>
  800513:	e9 b5 03 00 00       	jmp    8008cd <vprintfmt+0x3e0>
  800518:	85 c0                	test   %eax,%eax
  80051a:	0f 84 ad 03 00 00    	je     8008cd <vprintfmt+0x3e0>
				return;
			putch(ch, putdat);								//调用putch函数，把一个字符ch输出到putdat指针所指向的地址中所存放的值对应的地址处
  800520:	83 ec 08             	sub    $0x8,%esp
  800523:	53                   	push   %ebx
  800524:	50                   	push   %eax
  800525:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  800527:	46                   	inc    %esi
  800528:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  80052c:	83 c4 10             	add    $0x10,%esp
  80052f:	83 f8 25             	cmp    $0x25,%eax
  800532:	75 e4                	jne    800518 <vprintfmt+0x2b>
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  800534:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  800538:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80053f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800546:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80054d:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800554:	eb 07                	jmp    80055d <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800556:	8b 75 10             	mov    0x10(%ebp),%esi

		// flag to pad on the right
		case '-':											//%后面的'-'代表要进行左对齐输出，右边填空格，如果省略代表右对齐
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
  800559:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80055d:	8d 46 01             	lea    0x1(%esi),%eax
  800560:	89 45 10             	mov    %eax,0x10(%ebp)
  800563:	0f b6 16             	movzbl (%esi),%edx
  800566:	8a 06                	mov    (%esi),%al
  800568:	83 e8 23             	sub    $0x23,%eax
  80056b:	3c 55                	cmp    $0x55,%al
  80056d:	0f 87 03 03 00 00    	ja     800876 <vprintfmt+0x389>
  800573:	0f b6 c0             	movzbl %al,%eax
  800576:	ff 24 85 e0 22 80 00 	jmp    *0x8022e0(,%eax,4)
  80057d:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
			goto reswitch;									//处理下一个字符

		// flag to pad with 0's instead of spaces
		case '0':											//0--有0表示进行对齐输出时填0,如省略表示填入空格，并且如果为0，则一定是右对齐
			padc = '0';										//对其方式标志位变为0
  800580:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  800584:	eb d7                	jmp    80055d <vprintfmt+0x70>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
				precision = precision * 10 + ch - '0';
  800586:	8d 42 d0             	lea    -0x30(%edx),%eax
  800589:	89 c1                	mov    %eax,%ecx
  80058b:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  80058e:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800592:	8d 50 d0             	lea    -0x30(%eax),%edx
  800595:	83 fa 09             	cmp    $0x9,%edx
  800598:	77 51                	ja     8005eb <vprintfmt+0xfe>
  80059a:	8b 75 10             	mov    0x10(%ebp),%esi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
  80059d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  80059e:	8d 14 89             	lea    (%ecx,%ecx,4),%edx
  8005a1:	01 d2                	add    %edx,%edx
  8005a3:	8d 4c 10 d0          	lea    -0x30(%eax,%edx,1),%ecx
				ch = *fmt;
  8005a7:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8005aa:	8d 50 d0             	lea    -0x30(%eax),%edx
  8005ad:	83 fa 09             	cmp    $0x9,%edx
  8005b0:	76 eb                	jbe    80059d <vprintfmt+0xb0>
  8005b2:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8005b5:	eb 37                	jmp    8005ee <vprintfmt+0x101>
					break;
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
  8005b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ba:	8d 50 04             	lea    0x4(%eax),%edx
  8005bd:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c0:	8b 00                	mov    (%eax),%eax
  8005c2:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8005c5:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
			goto process_precision;
  8005c8:	eb 24                	jmp    8005ee <vprintfmt+0x101>
  8005ca:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005ce:	79 07                	jns    8005d7 <vprintfmt+0xea>
  8005d0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8005d7:	8b 75 10             	mov    0x10(%ebp),%esi
  8005da:	eb 81                	jmp    80055d <vprintfmt+0x70>
  8005dc:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  8005df:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005e6:	e9 72 ff ff ff       	jmp    80055d <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8005eb:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:									//处理输出精度，把width字段赋值为刚刚计算出来的precision值，所以width应该是整数部分的有效数字位数
			if (width < 0)
  8005ee:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005f2:	0f 89 65 ff ff ff    	jns    80055d <vprintfmt+0x70>
				width = precision, precision = -1;
  8005f8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005fb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005fe:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800605:	e9 53 ff ff ff       	jmp    80055d <vprintfmt+0x70>
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
  80060a:	ff 45 d4             	incl   -0x2c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80060d:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
			goto reswitch;
  800610:	e9 48 ff ff ff       	jmp    80055d <vprintfmt+0x70>

		// character
		case 'c':											//如果是'c'代表显示一个字符
			putch(va_arg(ap, int), putdat);					//调用输出一个字符到内存的函数putch
  800615:	8b 45 14             	mov    0x14(%ebp),%eax
  800618:	8d 50 04             	lea    0x4(%eax),%edx
  80061b:	89 55 14             	mov    %edx,0x14(%ebp)
  80061e:	83 ec 08             	sub    $0x8,%esp
  800621:	53                   	push   %ebx
  800622:	ff 30                	pushl  (%eax)
  800624:	ff d7                	call   *%edi
			break;
  800626:	83 c4 10             	add    $0x10,%esp
  800629:	e9 d3 fe ff ff       	jmp    800501 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80062e:	8b 45 14             	mov    0x14(%ebp),%eax
  800631:	8d 50 04             	lea    0x4(%eax),%edx
  800634:	89 55 14             	mov    %edx,0x14(%ebp)
  800637:	8b 00                	mov    (%eax),%eax
  800639:	85 c0                	test   %eax,%eax
  80063b:	79 02                	jns    80063f <vprintfmt+0x152>
  80063d:	f7 d8                	neg    %eax
  80063f:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800641:	83 f8 0f             	cmp    $0xf,%eax
  800644:	7f 0b                	jg     800651 <vprintfmt+0x164>
  800646:	8b 04 85 40 24 80 00 	mov    0x802440(,%eax,4),%eax
  80064d:	85 c0                	test   %eax,%eax
  80064f:	75 15                	jne    800666 <vprintfmt+0x179>
				printfmt(putch, putdat, "error %d", err);
  800651:	52                   	push   %edx
  800652:	68 bb 21 80 00       	push   $0x8021bb
  800657:	53                   	push   %ebx
  800658:	57                   	push   %edi
  800659:	e8 72 fe ff ff       	call   8004d0 <printfmt>
  80065e:	83 c4 10             	add    $0x10,%esp
  800661:	e9 9b fe ff ff       	jmp    800501 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  800666:	50                   	push   %eax
  800667:	68 72 25 80 00       	push   $0x802572
  80066c:	53                   	push   %ebx
  80066d:	57                   	push   %edi
  80066e:	e8 5d fe ff ff       	call   8004d0 <printfmt>
  800673:	83 c4 10             	add    $0x10,%esp
  800676:	e9 86 fe ff ff       	jmp    800501 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80067b:	8b 45 14             	mov    0x14(%ebp),%eax
  80067e:	8d 50 04             	lea    0x4(%eax),%edx
  800681:	89 55 14             	mov    %edx,0x14(%ebp)
  800684:	8b 00                	mov    (%eax),%eax
  800686:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800689:	85 c0                	test   %eax,%eax
  80068b:	75 07                	jne    800694 <vprintfmt+0x1a7>
				p = "(null)";
  80068d:	c7 45 d4 b4 21 80 00 	movl   $0x8021b4,-0x2c(%ebp)
			if (width > 0 && padc != '-')
  800694:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800697:	85 f6                	test   %esi,%esi
  800699:	0f 8e fb 01 00 00    	jle    80089a <vprintfmt+0x3ad>
  80069f:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  8006a3:	0f 84 09 02 00 00    	je     8008b2 <vprintfmt+0x3c5>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a9:	83 ec 08             	sub    $0x8,%esp
  8006ac:	ff 75 d0             	pushl  -0x30(%ebp)
  8006af:	ff 75 d4             	pushl  -0x2c(%ebp)
  8006b2:	e8 b3 03 00 00       	call   800a6a <strnlen>
  8006b7:	89 f1                	mov    %esi,%ecx
  8006b9:	29 c1                	sub    %eax,%ecx
  8006bb:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8006be:	83 c4 10             	add    $0x10,%esp
  8006c1:	85 c9                	test   %ecx,%ecx
  8006c3:	0f 8e d1 01 00 00    	jle    80089a <vprintfmt+0x3ad>
					putch(padc, putdat);
  8006c9:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8006cd:	83 ec 08             	sub    $0x8,%esp
  8006d0:	53                   	push   %ebx
  8006d1:	56                   	push   %esi
  8006d2:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d4:	83 c4 10             	add    $0x10,%esp
  8006d7:	ff 4d e4             	decl   -0x1c(%ebp)
  8006da:	75 f1                	jne    8006cd <vprintfmt+0x1e0>
  8006dc:	e9 b9 01 00 00       	jmp    80089a <vprintfmt+0x3ad>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006e1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006e5:	74 19                	je     800700 <vprintfmt+0x213>
  8006e7:	0f be c0             	movsbl %al,%eax
  8006ea:	83 e8 20             	sub    $0x20,%eax
  8006ed:	83 f8 5e             	cmp    $0x5e,%eax
  8006f0:	76 0e                	jbe    800700 <vprintfmt+0x213>
					putch('?', putdat);
  8006f2:	83 ec 08             	sub    $0x8,%esp
  8006f5:	53                   	push   %ebx
  8006f6:	6a 3f                	push   $0x3f
  8006f8:	ff 55 08             	call   *0x8(%ebp)
  8006fb:	83 c4 10             	add    $0x10,%esp
  8006fe:	eb 0b                	jmp    80070b <vprintfmt+0x21e>
				else
					putch(ch, putdat);
  800700:	83 ec 08             	sub    $0x8,%esp
  800703:	53                   	push   %ebx
  800704:	52                   	push   %edx
  800705:	ff 55 08             	call   *0x8(%ebp)
  800708:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80070b:	ff 4d e4             	decl   -0x1c(%ebp)
  80070e:	46                   	inc    %esi
  80070f:	8a 46 ff             	mov    -0x1(%esi),%al
  800712:	0f be d0             	movsbl %al,%edx
  800715:	85 d2                	test   %edx,%edx
  800717:	75 1c                	jne    800735 <vprintfmt+0x248>
  800719:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80071c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800720:	7f 1f                	jg     800741 <vprintfmt+0x254>
  800722:	e9 da fd ff ff       	jmp    800501 <vprintfmt+0x14>
  800727:	89 7d 08             	mov    %edi,0x8(%ebp)
  80072a:	8b 7d d0             	mov    -0x30(%ebp),%edi
  80072d:	eb 06                	jmp    800735 <vprintfmt+0x248>
  80072f:	89 7d 08             	mov    %edi,0x8(%ebp)
  800732:	8b 7d d0             	mov    -0x30(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800735:	85 ff                	test   %edi,%edi
  800737:	78 a8                	js     8006e1 <vprintfmt+0x1f4>
  800739:	4f                   	dec    %edi
  80073a:	79 a5                	jns    8006e1 <vprintfmt+0x1f4>
  80073c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80073f:	eb db                	jmp    80071c <vprintfmt+0x22f>
  800741:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800744:	83 ec 08             	sub    $0x8,%esp
  800747:	53                   	push   %ebx
  800748:	6a 20                	push   $0x20
  80074a:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80074c:	4e                   	dec    %esi
  80074d:	83 c4 10             	add    $0x10,%esp
  800750:	85 f6                	test   %esi,%esi
  800752:	7f f0                	jg     800744 <vprintfmt+0x257>
  800754:	e9 a8 fd ff ff       	jmp    800501 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800759:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  80075d:	7e 16                	jle    800775 <vprintfmt+0x288>
		return va_arg(*ap, long long);
  80075f:	8b 45 14             	mov    0x14(%ebp),%eax
  800762:	8d 50 08             	lea    0x8(%eax),%edx
  800765:	89 55 14             	mov    %edx,0x14(%ebp)
  800768:	8b 50 04             	mov    0x4(%eax),%edx
  80076b:	8b 00                	mov    (%eax),%eax
  80076d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800770:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800773:	eb 34                	jmp    8007a9 <vprintfmt+0x2bc>
	else if (lflag)
  800775:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800779:	74 18                	je     800793 <vprintfmt+0x2a6>
		return va_arg(*ap, long);
  80077b:	8b 45 14             	mov    0x14(%ebp),%eax
  80077e:	8d 50 04             	lea    0x4(%eax),%edx
  800781:	89 55 14             	mov    %edx,0x14(%ebp)
  800784:	8b 30                	mov    (%eax),%esi
  800786:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800789:	89 f0                	mov    %esi,%eax
  80078b:	c1 f8 1f             	sar    $0x1f,%eax
  80078e:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800791:	eb 16                	jmp    8007a9 <vprintfmt+0x2bc>
	else
		return va_arg(*ap, int);
  800793:	8b 45 14             	mov    0x14(%ebp),%eax
  800796:	8d 50 04             	lea    0x4(%eax),%edx
  800799:	89 55 14             	mov    %edx,0x14(%ebp)
  80079c:	8b 30                	mov    (%eax),%esi
  80079e:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8007a1:	89 f0                	mov    %esi,%eax
  8007a3:	c1 f8 1f             	sar    $0x1f,%eax
  8007a6:	89 45 dc             	mov    %eax,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007a9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007ac:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
  8007af:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007b3:	0f 89 8a 00 00 00    	jns    800843 <vprintfmt+0x356>
				putch('-', putdat);
  8007b9:	83 ec 08             	sub    $0x8,%esp
  8007bc:	53                   	push   %ebx
  8007bd:	6a 2d                	push   $0x2d
  8007bf:	ff d7                	call   *%edi
				num = -(long long) num;
  8007c1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007c4:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8007c7:	f7 d8                	neg    %eax
  8007c9:	83 d2 00             	adc    $0x0,%edx
  8007cc:	f7 da                	neg    %edx
  8007ce:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8007d1:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007d6:	eb 70                	jmp    800848 <vprintfmt+0x35b>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007d8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8007db:	8d 45 14             	lea    0x14(%ebp),%eax
  8007de:	e8 97 fc ff ff       	call   80047a <getuint>
			base = 10;
  8007e3:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8007e8:	eb 5e                	jmp    800848 <vprintfmt+0x35b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  8007ea:	83 ec 08             	sub    $0x8,%esp
  8007ed:	53                   	push   %ebx
  8007ee:	6a 30                	push   $0x30
  8007f0:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  8007f2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8007f5:	8d 45 14             	lea    0x14(%ebp),%eax
  8007f8:	e8 7d fc ff ff       	call   80047a <getuint>
			base = 8;
			goto number;
  8007fd:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800800:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800805:	eb 41                	jmp    800848 <vprintfmt+0x35b>
		// pointer
		case 'p':
			putch('0', putdat);
  800807:	83 ec 08             	sub    $0x8,%esp
  80080a:	53                   	push   %ebx
  80080b:	6a 30                	push   $0x30
  80080d:	ff d7                	call   *%edi
			putch('x', putdat);
  80080f:	83 c4 08             	add    $0x8,%esp
  800812:	53                   	push   %ebx
  800813:	6a 78                	push   $0x78
  800815:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800817:	8b 45 14             	mov    0x14(%ebp),%eax
  80081a:	8d 50 04             	lea    0x4(%eax),%edx
  80081d:	89 55 14             	mov    %edx,0x14(%ebp)
			goto number;
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800820:	8b 00                	mov    (%eax),%eax
  800822:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800827:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80082a:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80082f:	eb 17                	jmp    800848 <vprintfmt+0x35b>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800831:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800834:	8d 45 14             	lea    0x14(%ebp),%eax
  800837:	e8 3e fc ff ff       	call   80047a <getuint>
			base = 16;
  80083c:	b9 10 00 00 00       	mov    $0x10,%ecx
  800841:	eb 05                	jmp    800848 <vprintfmt+0x35b>
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800843:	b9 0a 00 00 00       	mov    $0xa,%ecx
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800848:	83 ec 0c             	sub    $0xc,%esp
  80084b:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  80084f:	56                   	push   %esi
  800850:	ff 75 e4             	pushl  -0x1c(%ebp)
  800853:	51                   	push   %ecx
  800854:	52                   	push   %edx
  800855:	50                   	push   %eax
  800856:	89 da                	mov    %ebx,%edx
  800858:	89 f8                	mov    %edi,%eax
  80085a:	e8 6b fb ff ff       	call   8003ca <printnum>
			break;
  80085f:	83 c4 20             	add    $0x20,%esp
  800862:	e9 9a fc ff ff       	jmp    800501 <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800867:	83 ec 08             	sub    $0x8,%esp
  80086a:	53                   	push   %ebx
  80086b:	52                   	push   %edx
  80086c:	ff d7                	call   *%edi
			break;
  80086e:	83 c4 10             	add    $0x10,%esp
  800871:	e9 8b fc ff ff       	jmp    800501 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800876:	83 ec 08             	sub    $0x8,%esp
  800879:	53                   	push   %ebx
  80087a:	6a 25                	push   $0x25
  80087c:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80087e:	83 c4 10             	add    $0x10,%esp
  800881:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800885:	0f 84 73 fc ff ff    	je     8004fe <vprintfmt+0x11>
  80088b:	4e                   	dec    %esi
  80088c:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800890:	75 f9                	jne    80088b <vprintfmt+0x39e>
  800892:	89 75 10             	mov    %esi,0x10(%ebp)
  800895:	e9 67 fc ff ff       	jmp    800501 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80089a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80089d:	8d 70 01             	lea    0x1(%eax),%esi
  8008a0:	8a 00                	mov    (%eax),%al
  8008a2:	0f be d0             	movsbl %al,%edx
  8008a5:	85 d2                	test   %edx,%edx
  8008a7:	0f 85 7a fe ff ff    	jne    800727 <vprintfmt+0x23a>
  8008ad:	e9 4f fc ff ff       	jmp    800501 <vprintfmt+0x14>
  8008b2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8008b5:	8d 70 01             	lea    0x1(%eax),%esi
  8008b8:	8a 00                	mov    (%eax),%al
  8008ba:	0f be d0             	movsbl %al,%edx
  8008bd:	85 d2                	test   %edx,%edx
  8008bf:	0f 85 6a fe ff ff    	jne    80072f <vprintfmt+0x242>
  8008c5:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8008c8:	e9 77 fe ff ff       	jmp    800744 <vprintfmt+0x257>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  8008cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008d0:	5b                   	pop    %ebx
  8008d1:	5e                   	pop    %esi
  8008d2:	5f                   	pop    %edi
  8008d3:	5d                   	pop    %ebp
  8008d4:	c3                   	ret    

008008d5 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008d5:	55                   	push   %ebp
  8008d6:	89 e5                	mov    %esp,%ebp
  8008d8:	83 ec 18             	sub    $0x18,%esp
  8008db:	8b 45 08             	mov    0x8(%ebp),%eax
  8008de:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008e1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008e4:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008e8:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008eb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008f2:	85 c0                	test   %eax,%eax
  8008f4:	74 26                	je     80091c <vsnprintf+0x47>
  8008f6:	85 d2                	test   %edx,%edx
  8008f8:	7e 29                	jle    800923 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008fa:	ff 75 14             	pushl  0x14(%ebp)
  8008fd:	ff 75 10             	pushl  0x10(%ebp)
  800900:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800903:	50                   	push   %eax
  800904:	68 b4 04 80 00       	push   $0x8004b4
  800909:	e8 df fb ff ff       	call   8004ed <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80090e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800911:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800914:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800917:	83 c4 10             	add    $0x10,%esp
  80091a:	eb 0c                	jmp    800928 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80091c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800921:	eb 05                	jmp    800928 <vsnprintf+0x53>
  800923:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800928:	c9                   	leave  
  800929:	c3                   	ret    

0080092a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80092a:	55                   	push   %ebp
  80092b:	89 e5                	mov    %esp,%ebp
  80092d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800930:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800933:	50                   	push   %eax
  800934:	ff 75 10             	pushl  0x10(%ebp)
  800937:	ff 75 0c             	pushl  0xc(%ebp)
  80093a:	ff 75 08             	pushl  0x8(%ebp)
  80093d:	e8 93 ff ff ff       	call   8008d5 <vsnprintf>
	va_end(ap);

	return rc;
}
  800942:	c9                   	leave  
  800943:	c3                   	ret    

00800944 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  800944:	55                   	push   %ebp
  800945:	89 e5                	mov    %esp,%ebp
  800947:	57                   	push   %edi
  800948:	56                   	push   %esi
  800949:	53                   	push   %ebx
  80094a:	83 ec 0c             	sub    $0xc,%esp
  80094d:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  800950:	85 c0                	test   %eax,%eax
  800952:	74 13                	je     800967 <readline+0x23>
		fprintf(1, "%s", prompt);
  800954:	83 ec 04             	sub    $0x4,%esp
  800957:	50                   	push   %eax
  800958:	68 72 25 80 00       	push   $0x802572
  80095d:	6a 01                	push   $0x1
  80095f:	e8 26 10 00 00       	call   80198a <fprintf>
  800964:	83 c4 10             	add    $0x10,%esp
#endif

	i = 0;
	echoing = iscons(0);
  800967:	83 ec 0c             	sub    $0xc,%esp
  80096a:	6a 00                	push   $0x0
  80096c:	e8 86 f8 ff ff       	call   8001f7 <iscons>
  800971:	89 c7                	mov    %eax,%edi
  800973:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
  800976:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
  80097b:	e8 4c f8 ff ff       	call   8001cc <getchar>
  800980:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  800982:	85 c0                	test   %eax,%eax
  800984:	79 24                	jns    8009aa <readline+0x66>
			if (c != -E_EOF)
  800986:	83 f8 f8             	cmp    $0xfffffff8,%eax
  800989:	0f 84 90 00 00 00    	je     800a1f <readline+0xdb>
				cprintf("read error: %e\n", c);
  80098f:	83 ec 08             	sub    $0x8,%esp
  800992:	50                   	push   %eax
  800993:	68 9f 24 80 00       	push   $0x80249f
  800998:	e8 19 fa ff ff       	call   8003b6 <cprintf>
  80099d:	83 c4 10             	add    $0x10,%esp
			return NULL;
  8009a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8009a5:	e9 98 00 00 00       	jmp    800a42 <readline+0xfe>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  8009aa:	83 f8 08             	cmp    $0x8,%eax
  8009ad:	74 7d                	je     800a2c <readline+0xe8>
  8009af:	83 f8 7f             	cmp    $0x7f,%eax
  8009b2:	75 16                	jne    8009ca <readline+0x86>
  8009b4:	eb 70                	jmp    800a26 <readline+0xe2>
			if (echoing)
  8009b6:	85 ff                	test   %edi,%edi
  8009b8:	74 0d                	je     8009c7 <readline+0x83>
				cputchar('\b');
  8009ba:	83 ec 0c             	sub    $0xc,%esp
  8009bd:	6a 08                	push   $0x8
  8009bf:	e8 ec f7 ff ff       	call   8001b0 <cputchar>
  8009c4:	83 c4 10             	add    $0x10,%esp
			i--;
  8009c7:	4e                   	dec    %esi
  8009c8:	eb b1                	jmp    80097b <readline+0x37>
		} else if (c >= ' ' && i < BUFLEN-1) {
  8009ca:	83 f8 1f             	cmp    $0x1f,%eax
  8009cd:	7e 23                	jle    8009f2 <readline+0xae>
  8009cf:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  8009d5:	7f 1b                	jg     8009f2 <readline+0xae>
			if (echoing)
  8009d7:	85 ff                	test   %edi,%edi
  8009d9:	74 0c                	je     8009e7 <readline+0xa3>
				cputchar(c);
  8009db:	83 ec 0c             	sub    $0xc,%esp
  8009de:	53                   	push   %ebx
  8009df:	e8 cc f7 ff ff       	call   8001b0 <cputchar>
  8009e4:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
  8009e7:	88 9e 00 40 80 00    	mov    %bl,0x804000(%esi)
  8009ed:	8d 76 01             	lea    0x1(%esi),%esi
  8009f0:	eb 89                	jmp    80097b <readline+0x37>
		} else if (c == '\n' || c == '\r') {
  8009f2:	83 fb 0a             	cmp    $0xa,%ebx
  8009f5:	74 09                	je     800a00 <readline+0xbc>
  8009f7:	83 fb 0d             	cmp    $0xd,%ebx
  8009fa:	0f 85 7b ff ff ff    	jne    80097b <readline+0x37>
			if (echoing)
  800a00:	85 ff                	test   %edi,%edi
  800a02:	74 0d                	je     800a11 <readline+0xcd>
				cputchar('\n');
  800a04:	83 ec 0c             	sub    $0xc,%esp
  800a07:	6a 0a                	push   $0xa
  800a09:	e8 a2 f7 ff ff       	call   8001b0 <cputchar>
  800a0e:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
  800a11:	c6 86 00 40 80 00 00 	movb   $0x0,0x804000(%esi)
			return buf;
  800a18:	b8 00 40 80 00       	mov    $0x804000,%eax
  800a1d:	eb 23                	jmp    800a42 <readline+0xfe>
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  800a1f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a24:	eb 1c                	jmp    800a42 <readline+0xfe>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  800a26:	85 f6                	test   %esi,%esi
  800a28:	7f 8c                	jg     8009b6 <readline+0x72>
  800a2a:	eb 09                	jmp    800a35 <readline+0xf1>
  800a2c:	85 f6                	test   %esi,%esi
  800a2e:	7f 86                	jg     8009b6 <readline+0x72>
  800a30:	e9 46 ff ff ff       	jmp    80097b <readline+0x37>
			if (echoing)
				cputchar('\b');
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
  800a35:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  800a3b:	7e 9a                	jle    8009d7 <readline+0x93>
  800a3d:	e9 39 ff ff ff       	jmp    80097b <readline+0x37>
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
  800a42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a45:	5b                   	pop    %ebx
  800a46:	5e                   	pop    %esi
  800a47:	5f                   	pop    %edi
  800a48:	5d                   	pop    %ebp
  800a49:	c3                   	ret    

00800a4a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a4a:	55                   	push   %ebp
  800a4b:	89 e5                	mov    %esp,%ebp
  800a4d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a50:	80 3a 00             	cmpb   $0x0,(%edx)
  800a53:	74 0e                	je     800a63 <strlen+0x19>
  800a55:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800a5a:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a5b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a5f:	75 f9                	jne    800a5a <strlen+0x10>
  800a61:	eb 05                	jmp    800a68 <strlen+0x1e>
  800a63:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800a68:	5d                   	pop    %ebp
  800a69:	c3                   	ret    

00800a6a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a6a:	55                   	push   %ebp
  800a6b:	89 e5                	mov    %esp,%ebp
  800a6d:	53                   	push   %ebx
  800a6e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a74:	85 c9                	test   %ecx,%ecx
  800a76:	74 1a                	je     800a92 <strnlen+0x28>
  800a78:	80 3b 00             	cmpb   $0x0,(%ebx)
  800a7b:	74 1c                	je     800a99 <strnlen+0x2f>
  800a7d:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800a82:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a84:	39 ca                	cmp    %ecx,%edx
  800a86:	74 16                	je     800a9e <strnlen+0x34>
  800a88:	42                   	inc    %edx
  800a89:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800a8e:	75 f2                	jne    800a82 <strnlen+0x18>
  800a90:	eb 0c                	jmp    800a9e <strnlen+0x34>
  800a92:	b8 00 00 00 00       	mov    $0x0,%eax
  800a97:	eb 05                	jmp    800a9e <strnlen+0x34>
  800a99:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800a9e:	5b                   	pop    %ebx
  800a9f:	5d                   	pop    %ebp
  800aa0:	c3                   	ret    

00800aa1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800aa1:	55                   	push   %ebp
  800aa2:	89 e5                	mov    %esp,%ebp
  800aa4:	53                   	push   %ebx
  800aa5:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800aab:	89 c2                	mov    %eax,%edx
  800aad:	42                   	inc    %edx
  800aae:	41                   	inc    %ecx
  800aaf:	8a 59 ff             	mov    -0x1(%ecx),%bl
  800ab2:	88 5a ff             	mov    %bl,-0x1(%edx)
  800ab5:	84 db                	test   %bl,%bl
  800ab7:	75 f4                	jne    800aad <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800ab9:	5b                   	pop    %ebx
  800aba:	5d                   	pop    %ebp
  800abb:	c3                   	ret    

00800abc <strcat>:

char *
strcat(char *dst, const char *src)
{
  800abc:	55                   	push   %ebp
  800abd:	89 e5                	mov    %esp,%ebp
  800abf:	53                   	push   %ebx
  800ac0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800ac3:	53                   	push   %ebx
  800ac4:	e8 81 ff ff ff       	call   800a4a <strlen>
  800ac9:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800acc:	ff 75 0c             	pushl  0xc(%ebp)
  800acf:	01 d8                	add    %ebx,%eax
  800ad1:	50                   	push   %eax
  800ad2:	e8 ca ff ff ff       	call   800aa1 <strcpy>
	return dst;
}
  800ad7:	89 d8                	mov    %ebx,%eax
  800ad9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800adc:	c9                   	leave  
  800add:	c3                   	ret    

00800ade <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ade:	55                   	push   %ebp
  800adf:	89 e5                	mov    %esp,%ebp
  800ae1:	56                   	push   %esi
  800ae2:	53                   	push   %ebx
  800ae3:	8b 75 08             	mov    0x8(%ebp),%esi
  800ae6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ae9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800aec:	85 db                	test   %ebx,%ebx
  800aee:	74 14                	je     800b04 <strncpy+0x26>
  800af0:	01 f3                	add    %esi,%ebx
  800af2:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800af4:	41                   	inc    %ecx
  800af5:	8a 02                	mov    (%edx),%al
  800af7:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800afa:	80 3a 01             	cmpb   $0x1,(%edx)
  800afd:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b00:	39 cb                	cmp    %ecx,%ebx
  800b02:	75 f0                	jne    800af4 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b04:	89 f0                	mov    %esi,%eax
  800b06:	5b                   	pop    %ebx
  800b07:	5e                   	pop    %esi
  800b08:	5d                   	pop    %ebp
  800b09:	c3                   	ret    

00800b0a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b0a:	55                   	push   %ebp
  800b0b:	89 e5                	mov    %esp,%ebp
  800b0d:	53                   	push   %ebx
  800b0e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b11:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b14:	85 c0                	test   %eax,%eax
  800b16:	74 30                	je     800b48 <strlcpy+0x3e>
		while (--size > 0 && *src != '\0')
  800b18:	48                   	dec    %eax
  800b19:	74 20                	je     800b3b <strlcpy+0x31>
  800b1b:	8a 0b                	mov    (%ebx),%cl
  800b1d:	84 c9                	test   %cl,%cl
  800b1f:	74 1f                	je     800b40 <strlcpy+0x36>
  800b21:	8d 53 01             	lea    0x1(%ebx),%edx
  800b24:	01 c3                	add    %eax,%ebx
  800b26:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
  800b29:	40                   	inc    %eax
  800b2a:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800b2d:	39 da                	cmp    %ebx,%edx
  800b2f:	74 12                	je     800b43 <strlcpy+0x39>
  800b31:	42                   	inc    %edx
  800b32:	8a 4a ff             	mov    -0x1(%edx),%cl
  800b35:	84 c9                	test   %cl,%cl
  800b37:	75 f0                	jne    800b29 <strlcpy+0x1f>
  800b39:	eb 08                	jmp    800b43 <strlcpy+0x39>
  800b3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3e:	eb 03                	jmp    800b43 <strlcpy+0x39>
  800b40:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
		*dst = '\0';
  800b43:	c6 00 00             	movb   $0x0,(%eax)
  800b46:	eb 03                	jmp    800b4b <strlcpy+0x41>
  800b48:	8b 45 08             	mov    0x8(%ebp),%eax
	}
	return dst - dst_in;
  800b4b:	2b 45 08             	sub    0x8(%ebp),%eax
}
  800b4e:	5b                   	pop    %ebx
  800b4f:	5d                   	pop    %ebp
  800b50:	c3                   	ret    

00800b51 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b51:	55                   	push   %ebp
  800b52:	89 e5                	mov    %esp,%ebp
  800b54:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b57:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b5a:	8a 01                	mov    (%ecx),%al
  800b5c:	84 c0                	test   %al,%al
  800b5e:	74 10                	je     800b70 <strcmp+0x1f>
  800b60:	3a 02                	cmp    (%edx),%al
  800b62:	75 0c                	jne    800b70 <strcmp+0x1f>
		p++, q++;
  800b64:	41                   	inc    %ecx
  800b65:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b66:	8a 01                	mov    (%ecx),%al
  800b68:	84 c0                	test   %al,%al
  800b6a:	74 04                	je     800b70 <strcmp+0x1f>
  800b6c:	3a 02                	cmp    (%edx),%al
  800b6e:	74 f4                	je     800b64 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b70:	0f b6 c0             	movzbl %al,%eax
  800b73:	0f b6 12             	movzbl (%edx),%edx
  800b76:	29 d0                	sub    %edx,%eax
}
  800b78:	5d                   	pop    %ebp
  800b79:	c3                   	ret    

00800b7a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b7a:	55                   	push   %ebp
  800b7b:	89 e5                	mov    %esp,%ebp
  800b7d:	56                   	push   %esi
  800b7e:	53                   	push   %ebx
  800b7f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b82:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b85:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800b88:	85 f6                	test   %esi,%esi
  800b8a:	74 23                	je     800baf <strncmp+0x35>
  800b8c:	8a 03                	mov    (%ebx),%al
  800b8e:	84 c0                	test   %al,%al
  800b90:	74 2b                	je     800bbd <strncmp+0x43>
  800b92:	3a 02                	cmp    (%edx),%al
  800b94:	75 27                	jne    800bbd <strncmp+0x43>
  800b96:	8d 43 01             	lea    0x1(%ebx),%eax
  800b99:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800b9b:	89 c3                	mov    %eax,%ebx
  800b9d:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b9e:	39 c6                	cmp    %eax,%esi
  800ba0:	74 14                	je     800bb6 <strncmp+0x3c>
  800ba2:	8a 08                	mov    (%eax),%cl
  800ba4:	84 c9                	test   %cl,%cl
  800ba6:	74 15                	je     800bbd <strncmp+0x43>
  800ba8:	40                   	inc    %eax
  800ba9:	3a 0a                	cmp    (%edx),%cl
  800bab:	74 ee                	je     800b9b <strncmp+0x21>
  800bad:	eb 0e                	jmp    800bbd <strncmp+0x43>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800baf:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb4:	eb 0f                	jmp    800bc5 <strncmp+0x4b>
  800bb6:	b8 00 00 00 00       	mov    $0x0,%eax
  800bbb:	eb 08                	jmp    800bc5 <strncmp+0x4b>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800bbd:	0f b6 03             	movzbl (%ebx),%eax
  800bc0:	0f b6 12             	movzbl (%edx),%edx
  800bc3:	29 d0                	sub    %edx,%eax
}
  800bc5:	5b                   	pop    %ebx
  800bc6:	5e                   	pop    %esi
  800bc7:	5d                   	pop    %ebp
  800bc8:	c3                   	ret    

00800bc9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800bc9:	55                   	push   %ebp
  800bca:	89 e5                	mov    %esp,%ebp
  800bcc:	53                   	push   %ebx
  800bcd:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800bd3:	8a 10                	mov    (%eax),%dl
  800bd5:	84 d2                	test   %dl,%dl
  800bd7:	74 1a                	je     800bf3 <strchr+0x2a>
  800bd9:	88 d9                	mov    %bl,%cl
		if (*s == c)
  800bdb:	38 d3                	cmp    %dl,%bl
  800bdd:	75 06                	jne    800be5 <strchr+0x1c>
  800bdf:	eb 17                	jmp    800bf8 <strchr+0x2f>
  800be1:	38 ca                	cmp    %cl,%dl
  800be3:	74 13                	je     800bf8 <strchr+0x2f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800be5:	40                   	inc    %eax
  800be6:	8a 10                	mov    (%eax),%dl
  800be8:	84 d2                	test   %dl,%dl
  800bea:	75 f5                	jne    800be1 <strchr+0x18>
		if (*s == c)
			return (char *) s;
	return 0;
  800bec:	b8 00 00 00 00       	mov    $0x0,%eax
  800bf1:	eb 05                	jmp    800bf8 <strchr+0x2f>
  800bf3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bf8:	5b                   	pop    %ebx
  800bf9:	5d                   	pop    %ebp
  800bfa:	c3                   	ret    

00800bfb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bfb:	55                   	push   %ebp
  800bfc:	89 e5                	mov    %esp,%ebp
  800bfe:	53                   	push   %ebx
  800bff:	8b 45 08             	mov    0x8(%ebp),%eax
  800c02:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800c05:	8a 10                	mov    (%eax),%dl
  800c07:	84 d2                	test   %dl,%dl
  800c09:	74 13                	je     800c1e <strfind+0x23>
  800c0b:	88 d9                	mov    %bl,%cl
		if (*s == c)
  800c0d:	38 d3                	cmp    %dl,%bl
  800c0f:	75 06                	jne    800c17 <strfind+0x1c>
  800c11:	eb 0b                	jmp    800c1e <strfind+0x23>
  800c13:	38 ca                	cmp    %cl,%dl
  800c15:	74 07                	je     800c1e <strfind+0x23>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800c17:	40                   	inc    %eax
  800c18:	8a 10                	mov    (%eax),%dl
  800c1a:	84 d2                	test   %dl,%dl
  800c1c:	75 f5                	jne    800c13 <strfind+0x18>
		if (*s == c)
			break;
	return (char *) s;
}
  800c1e:	5b                   	pop    %ebx
  800c1f:	5d                   	pop    %ebp
  800c20:	c3                   	ret    

00800c21 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c21:	55                   	push   %ebp
  800c22:	89 e5                	mov    %esp,%ebp
  800c24:	57                   	push   %edi
  800c25:	56                   	push   %esi
  800c26:	53                   	push   %ebx
  800c27:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c2a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c2d:	85 c9                	test   %ecx,%ecx
  800c2f:	74 36                	je     800c67 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c31:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c37:	75 28                	jne    800c61 <memset+0x40>
  800c39:	f6 c1 03             	test   $0x3,%cl
  800c3c:	75 23                	jne    800c61 <memset+0x40>
		c &= 0xFF;
  800c3e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c42:	89 d3                	mov    %edx,%ebx
  800c44:	c1 e3 08             	shl    $0x8,%ebx
  800c47:	89 d6                	mov    %edx,%esi
  800c49:	c1 e6 18             	shl    $0x18,%esi
  800c4c:	89 d0                	mov    %edx,%eax
  800c4e:	c1 e0 10             	shl    $0x10,%eax
  800c51:	09 f0                	or     %esi,%eax
  800c53:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800c55:	89 d8                	mov    %ebx,%eax
  800c57:	09 d0                	or     %edx,%eax
  800c59:	c1 e9 02             	shr    $0x2,%ecx
  800c5c:	fc                   	cld    
  800c5d:	f3 ab                	rep stos %eax,%es:(%edi)
  800c5f:	eb 06                	jmp    800c67 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c61:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c64:	fc                   	cld    
  800c65:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c67:	89 f8                	mov    %edi,%eax
  800c69:	5b                   	pop    %ebx
  800c6a:	5e                   	pop    %esi
  800c6b:	5f                   	pop    %edi
  800c6c:	5d                   	pop    %ebp
  800c6d:	c3                   	ret    

00800c6e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c6e:	55                   	push   %ebp
  800c6f:	89 e5                	mov    %esp,%ebp
  800c71:	57                   	push   %edi
  800c72:	56                   	push   %esi
  800c73:	8b 45 08             	mov    0x8(%ebp),%eax
  800c76:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c79:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c7c:	39 c6                	cmp    %eax,%esi
  800c7e:	73 33                	jae    800cb3 <memmove+0x45>
  800c80:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c83:	39 d0                	cmp    %edx,%eax
  800c85:	73 2c                	jae    800cb3 <memmove+0x45>
		s += n;
		d += n;
  800c87:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c8a:	89 d6                	mov    %edx,%esi
  800c8c:	09 fe                	or     %edi,%esi
  800c8e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c94:	75 13                	jne    800ca9 <memmove+0x3b>
  800c96:	f6 c1 03             	test   $0x3,%cl
  800c99:	75 0e                	jne    800ca9 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800c9b:	83 ef 04             	sub    $0x4,%edi
  800c9e:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ca1:	c1 e9 02             	shr    $0x2,%ecx
  800ca4:	fd                   	std    
  800ca5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ca7:	eb 07                	jmp    800cb0 <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ca9:	4f                   	dec    %edi
  800caa:	8d 72 ff             	lea    -0x1(%edx),%esi
  800cad:	fd                   	std    
  800cae:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800cb0:	fc                   	cld    
  800cb1:	eb 1d                	jmp    800cd0 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cb3:	89 f2                	mov    %esi,%edx
  800cb5:	09 c2                	or     %eax,%edx
  800cb7:	f6 c2 03             	test   $0x3,%dl
  800cba:	75 0f                	jne    800ccb <memmove+0x5d>
  800cbc:	f6 c1 03             	test   $0x3,%cl
  800cbf:	75 0a                	jne    800ccb <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
  800cc1:	c1 e9 02             	shr    $0x2,%ecx
  800cc4:	89 c7                	mov    %eax,%edi
  800cc6:	fc                   	cld    
  800cc7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800cc9:	eb 05                	jmp    800cd0 <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ccb:	89 c7                	mov    %eax,%edi
  800ccd:	fc                   	cld    
  800cce:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800cd0:	5e                   	pop    %esi
  800cd1:	5f                   	pop    %edi
  800cd2:	5d                   	pop    %ebp
  800cd3:	c3                   	ret    

00800cd4 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800cd4:	55                   	push   %ebp
  800cd5:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800cd7:	ff 75 10             	pushl  0x10(%ebp)
  800cda:	ff 75 0c             	pushl  0xc(%ebp)
  800cdd:	ff 75 08             	pushl  0x8(%ebp)
  800ce0:	e8 89 ff ff ff       	call   800c6e <memmove>
}
  800ce5:	c9                   	leave  
  800ce6:	c3                   	ret    

00800ce7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	57                   	push   %edi
  800ceb:	56                   	push   %esi
  800cec:	53                   	push   %ebx
  800ced:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800cf0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cf3:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cf6:	85 c0                	test   %eax,%eax
  800cf8:	74 33                	je     800d2d <memcmp+0x46>
  800cfa:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800cfd:	8a 13                	mov    (%ebx),%dl
  800cff:	8a 0e                	mov    (%esi),%cl
  800d01:	38 ca                	cmp    %cl,%dl
  800d03:	75 13                	jne    800d18 <memcmp+0x31>
  800d05:	b8 00 00 00 00       	mov    $0x0,%eax
  800d0a:	eb 16                	jmp    800d22 <memcmp+0x3b>
  800d0c:	8a 54 03 01          	mov    0x1(%ebx,%eax,1),%dl
  800d10:	40                   	inc    %eax
  800d11:	8a 0c 06             	mov    (%esi,%eax,1),%cl
  800d14:	38 ca                	cmp    %cl,%dl
  800d16:	74 0a                	je     800d22 <memcmp+0x3b>
			return (int) *s1 - (int) *s2;
  800d18:	0f b6 c2             	movzbl %dl,%eax
  800d1b:	0f b6 c9             	movzbl %cl,%ecx
  800d1e:	29 c8                	sub    %ecx,%eax
  800d20:	eb 10                	jmp    800d32 <memcmp+0x4b>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d22:	39 f8                	cmp    %edi,%eax
  800d24:	75 e6                	jne    800d0c <memcmp+0x25>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d26:	b8 00 00 00 00       	mov    $0x0,%eax
  800d2b:	eb 05                	jmp    800d32 <memcmp+0x4b>
  800d2d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d32:	5b                   	pop    %ebx
  800d33:	5e                   	pop    %esi
  800d34:	5f                   	pop    %edi
  800d35:	5d                   	pop    %ebp
  800d36:	c3                   	ret    

00800d37 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d37:	55                   	push   %ebp
  800d38:	89 e5                	mov    %esp,%ebp
  800d3a:	53                   	push   %ebx
  800d3b:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800d3e:	89 d0                	mov    %edx,%eax
  800d40:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800d43:	39 c2                	cmp    %eax,%edx
  800d45:	73 1b                	jae    800d62 <memfind+0x2b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d47:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800d4b:	0f b6 0a             	movzbl (%edx),%ecx
  800d4e:	39 d9                	cmp    %ebx,%ecx
  800d50:	75 09                	jne    800d5b <memfind+0x24>
  800d52:	eb 12                	jmp    800d66 <memfind+0x2f>
  800d54:	0f b6 0a             	movzbl (%edx),%ecx
  800d57:	39 d9                	cmp    %ebx,%ecx
  800d59:	74 0f                	je     800d6a <memfind+0x33>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d5b:	42                   	inc    %edx
  800d5c:	39 d0                	cmp    %edx,%eax
  800d5e:	75 f4                	jne    800d54 <memfind+0x1d>
  800d60:	eb 0a                	jmp    800d6c <memfind+0x35>
  800d62:	89 d0                	mov    %edx,%eax
  800d64:	eb 06                	jmp    800d6c <memfind+0x35>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d66:	89 d0                	mov    %edx,%eax
  800d68:	eb 02                	jmp    800d6c <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d6a:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d6c:	5b                   	pop    %ebx
  800d6d:	5d                   	pop    %ebp
  800d6e:	c3                   	ret    

00800d6f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d6f:	55                   	push   %ebp
  800d70:	89 e5                	mov    %esp,%ebp
  800d72:	57                   	push   %edi
  800d73:	56                   	push   %esi
  800d74:	53                   	push   %ebx
  800d75:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d78:	eb 01                	jmp    800d7b <strtol+0xc>
		s++;
  800d7a:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d7b:	8a 01                	mov    (%ecx),%al
  800d7d:	3c 20                	cmp    $0x20,%al
  800d7f:	74 f9                	je     800d7a <strtol+0xb>
  800d81:	3c 09                	cmp    $0x9,%al
  800d83:	74 f5                	je     800d7a <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d85:	3c 2b                	cmp    $0x2b,%al
  800d87:	75 08                	jne    800d91 <strtol+0x22>
		s++;
  800d89:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d8a:	bf 00 00 00 00       	mov    $0x0,%edi
  800d8f:	eb 11                	jmp    800da2 <strtol+0x33>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d91:	3c 2d                	cmp    $0x2d,%al
  800d93:	75 08                	jne    800d9d <strtol+0x2e>
		s++, neg = 1;
  800d95:	41                   	inc    %ecx
  800d96:	bf 01 00 00 00       	mov    $0x1,%edi
  800d9b:	eb 05                	jmp    800da2 <strtol+0x33>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d9d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800da2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800da6:	0f 84 87 00 00 00    	je     800e33 <strtol+0xc4>
  800dac:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800db0:	75 27                	jne    800dd9 <strtol+0x6a>
  800db2:	80 39 30             	cmpb   $0x30,(%ecx)
  800db5:	75 22                	jne    800dd9 <strtol+0x6a>
  800db7:	e9 88 00 00 00       	jmp    800e44 <strtol+0xd5>
		s += 2, base = 16;
  800dbc:	83 c1 02             	add    $0x2,%ecx
  800dbf:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800dc6:	eb 11                	jmp    800dd9 <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
  800dc8:	41                   	inc    %ecx
  800dc9:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800dd0:	eb 07                	jmp    800dd9 <strtol+0x6a>
	else if (base == 0)
		base = 10;
  800dd2:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  800dd9:	b8 00 00 00 00       	mov    $0x0,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800dde:	8a 11                	mov    (%ecx),%dl
  800de0:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800de3:	80 fb 09             	cmp    $0x9,%bl
  800de6:	77 08                	ja     800df0 <strtol+0x81>
			dig = *s - '0';
  800de8:	0f be d2             	movsbl %dl,%edx
  800deb:	83 ea 30             	sub    $0x30,%edx
  800dee:	eb 22                	jmp    800e12 <strtol+0xa3>
		else if (*s >= 'a' && *s <= 'z')
  800df0:	8d 72 9f             	lea    -0x61(%edx),%esi
  800df3:	89 f3                	mov    %esi,%ebx
  800df5:	80 fb 19             	cmp    $0x19,%bl
  800df8:	77 08                	ja     800e02 <strtol+0x93>
			dig = *s - 'a' + 10;
  800dfa:	0f be d2             	movsbl %dl,%edx
  800dfd:	83 ea 57             	sub    $0x57,%edx
  800e00:	eb 10                	jmp    800e12 <strtol+0xa3>
		else if (*s >= 'A' && *s <= 'Z')
  800e02:	8d 72 bf             	lea    -0x41(%edx),%esi
  800e05:	89 f3                	mov    %esi,%ebx
  800e07:	80 fb 19             	cmp    $0x19,%bl
  800e0a:	77 14                	ja     800e20 <strtol+0xb1>
			dig = *s - 'A' + 10;
  800e0c:	0f be d2             	movsbl %dl,%edx
  800e0f:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800e12:	3b 55 10             	cmp    0x10(%ebp),%edx
  800e15:	7d 09                	jge    800e20 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800e17:	41                   	inc    %ecx
  800e18:	0f af 45 10          	imul   0x10(%ebp),%eax
  800e1c:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800e1e:	eb be                	jmp    800dde <strtol+0x6f>

	if (endptr)
  800e20:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e24:	74 05                	je     800e2b <strtol+0xbc>
		*endptr = (char *) s;
  800e26:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e29:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800e2b:	85 ff                	test   %edi,%edi
  800e2d:	74 21                	je     800e50 <strtol+0xe1>
  800e2f:	f7 d8                	neg    %eax
  800e31:	eb 1d                	jmp    800e50 <strtol+0xe1>
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e33:	80 39 30             	cmpb   $0x30,(%ecx)
  800e36:	75 9a                	jne    800dd2 <strtol+0x63>
  800e38:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800e3c:	0f 84 7a ff ff ff    	je     800dbc <strtol+0x4d>
  800e42:	eb 84                	jmp    800dc8 <strtol+0x59>
  800e44:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800e48:	0f 84 6e ff ff ff    	je     800dbc <strtol+0x4d>
  800e4e:	eb 89                	jmp    800dd9 <strtol+0x6a>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  800e50:	5b                   	pop    %ebx
  800e51:	5e                   	pop    %esi
  800e52:	5f                   	pop    %edi
  800e53:	5d                   	pop    %ebp
  800e54:	c3                   	ret    

00800e55 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800e55:	55                   	push   %ebp
  800e56:	89 e5                	mov    %esp,%ebp
  800e58:	57                   	push   %edi
  800e59:	56                   	push   %esi
  800e5a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e5b:	b8 00 00 00 00       	mov    $0x0,%eax
  800e60:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e63:	8b 55 08             	mov    0x8(%ebp),%edx
  800e66:	89 c3                	mov    %eax,%ebx
  800e68:	89 c7                	mov    %eax,%edi
  800e6a:	89 c6                	mov    %eax,%esi
  800e6c:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800e6e:	5b                   	pop    %ebx
  800e6f:	5e                   	pop    %esi
  800e70:	5f                   	pop    %edi
  800e71:	5d                   	pop    %ebp
  800e72:	c3                   	ret    

00800e73 <sys_cgetc>:

int
sys_cgetc(void)
{
  800e73:	55                   	push   %ebp
  800e74:	89 e5                	mov    %esp,%ebp
  800e76:	57                   	push   %edi
  800e77:	56                   	push   %esi
  800e78:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e79:	ba 00 00 00 00       	mov    $0x0,%edx
  800e7e:	b8 01 00 00 00       	mov    $0x1,%eax
  800e83:	89 d1                	mov    %edx,%ecx
  800e85:	89 d3                	mov    %edx,%ebx
  800e87:	89 d7                	mov    %edx,%edi
  800e89:	89 d6                	mov    %edx,%esi
  800e8b:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e8d:	5b                   	pop    %ebx
  800e8e:	5e                   	pop    %esi
  800e8f:	5f                   	pop    %edi
  800e90:	5d                   	pop    %ebp
  800e91:	c3                   	ret    

00800e92 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e92:	55                   	push   %ebp
  800e93:	89 e5                	mov    %esp,%ebp
  800e95:	57                   	push   %edi
  800e96:	56                   	push   %esi
  800e97:	53                   	push   %ebx
  800e98:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e9b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ea0:	b8 03 00 00 00       	mov    $0x3,%eax
  800ea5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea8:	89 cb                	mov    %ecx,%ebx
  800eaa:	89 cf                	mov    %ecx,%edi
  800eac:	89 ce                	mov    %ecx,%esi
  800eae:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eb0:	85 c0                	test   %eax,%eax
  800eb2:	7e 17                	jle    800ecb <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eb4:	83 ec 0c             	sub    $0xc,%esp
  800eb7:	50                   	push   %eax
  800eb8:	6a 03                	push   $0x3
  800eba:	68 af 24 80 00       	push   $0x8024af
  800ebf:	6a 23                	push   $0x23
  800ec1:	68 cc 24 80 00       	push   $0x8024cc
  800ec6:	e8 13 f4 ff ff       	call   8002de <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ecb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ece:	5b                   	pop    %ebx
  800ecf:	5e                   	pop    %esi
  800ed0:	5f                   	pop    %edi
  800ed1:	5d                   	pop    %ebp
  800ed2:	c3                   	ret    

00800ed3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ed3:	55                   	push   %ebp
  800ed4:	89 e5                	mov    %esp,%ebp
  800ed6:	57                   	push   %edi
  800ed7:	56                   	push   %esi
  800ed8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed9:	ba 00 00 00 00       	mov    $0x0,%edx
  800ede:	b8 02 00 00 00       	mov    $0x2,%eax
  800ee3:	89 d1                	mov    %edx,%ecx
  800ee5:	89 d3                	mov    %edx,%ebx
  800ee7:	89 d7                	mov    %edx,%edi
  800ee9:	89 d6                	mov    %edx,%esi
  800eeb:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800eed:	5b                   	pop    %ebx
  800eee:	5e                   	pop    %esi
  800eef:	5f                   	pop    %edi
  800ef0:	5d                   	pop    %ebp
  800ef1:	c3                   	ret    

00800ef2 <sys_yield>:

void
sys_yield(void)
{
  800ef2:	55                   	push   %ebp
  800ef3:	89 e5                	mov    %esp,%ebp
  800ef5:	57                   	push   %edi
  800ef6:	56                   	push   %esi
  800ef7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ef8:	ba 00 00 00 00       	mov    $0x0,%edx
  800efd:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f02:	89 d1                	mov    %edx,%ecx
  800f04:	89 d3                	mov    %edx,%ebx
  800f06:	89 d7                	mov    %edx,%edi
  800f08:	89 d6                	mov    %edx,%esi
  800f0a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f0c:	5b                   	pop    %ebx
  800f0d:	5e                   	pop    %esi
  800f0e:	5f                   	pop    %edi
  800f0f:	5d                   	pop    %ebp
  800f10:	c3                   	ret    

00800f11 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f11:	55                   	push   %ebp
  800f12:	89 e5                	mov    %esp,%ebp
  800f14:	57                   	push   %edi
  800f15:	56                   	push   %esi
  800f16:	53                   	push   %ebx
  800f17:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f1a:	be 00 00 00 00       	mov    $0x0,%esi
  800f1f:	b8 04 00 00 00       	mov    $0x4,%eax
  800f24:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f27:	8b 55 08             	mov    0x8(%ebp),%edx
  800f2a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f2d:	89 f7                	mov    %esi,%edi
  800f2f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f31:	85 c0                	test   %eax,%eax
  800f33:	7e 17                	jle    800f4c <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f35:	83 ec 0c             	sub    $0xc,%esp
  800f38:	50                   	push   %eax
  800f39:	6a 04                	push   $0x4
  800f3b:	68 af 24 80 00       	push   $0x8024af
  800f40:	6a 23                	push   $0x23
  800f42:	68 cc 24 80 00       	push   $0x8024cc
  800f47:	e8 92 f3 ff ff       	call   8002de <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f4c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f4f:	5b                   	pop    %ebx
  800f50:	5e                   	pop    %esi
  800f51:	5f                   	pop    %edi
  800f52:	5d                   	pop    %ebp
  800f53:	c3                   	ret    

00800f54 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f54:	55                   	push   %ebp
  800f55:	89 e5                	mov    %esp,%ebp
  800f57:	57                   	push   %edi
  800f58:	56                   	push   %esi
  800f59:	53                   	push   %ebx
  800f5a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f5d:	b8 05 00 00 00       	mov    $0x5,%eax
  800f62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f65:	8b 55 08             	mov    0x8(%ebp),%edx
  800f68:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f6b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f6e:	8b 75 18             	mov    0x18(%ebp),%esi
  800f71:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f73:	85 c0                	test   %eax,%eax
  800f75:	7e 17                	jle    800f8e <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f77:	83 ec 0c             	sub    $0xc,%esp
  800f7a:	50                   	push   %eax
  800f7b:	6a 05                	push   $0x5
  800f7d:	68 af 24 80 00       	push   $0x8024af
  800f82:	6a 23                	push   $0x23
  800f84:	68 cc 24 80 00       	push   $0x8024cc
  800f89:	e8 50 f3 ff ff       	call   8002de <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f8e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f91:	5b                   	pop    %ebx
  800f92:	5e                   	pop    %esi
  800f93:	5f                   	pop    %edi
  800f94:	5d                   	pop    %ebp
  800f95:	c3                   	ret    

00800f96 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f96:	55                   	push   %ebp
  800f97:	89 e5                	mov    %esp,%ebp
  800f99:	57                   	push   %edi
  800f9a:	56                   	push   %esi
  800f9b:	53                   	push   %ebx
  800f9c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f9f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fa4:	b8 06 00 00 00       	mov    $0x6,%eax
  800fa9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fac:	8b 55 08             	mov    0x8(%ebp),%edx
  800faf:	89 df                	mov    %ebx,%edi
  800fb1:	89 de                	mov    %ebx,%esi
  800fb3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fb5:	85 c0                	test   %eax,%eax
  800fb7:	7e 17                	jle    800fd0 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fb9:	83 ec 0c             	sub    $0xc,%esp
  800fbc:	50                   	push   %eax
  800fbd:	6a 06                	push   $0x6
  800fbf:	68 af 24 80 00       	push   $0x8024af
  800fc4:	6a 23                	push   $0x23
  800fc6:	68 cc 24 80 00       	push   $0x8024cc
  800fcb:	e8 0e f3 ff ff       	call   8002de <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800fd0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fd3:	5b                   	pop    %ebx
  800fd4:	5e                   	pop    %esi
  800fd5:	5f                   	pop    %edi
  800fd6:	5d                   	pop    %ebp
  800fd7:	c3                   	ret    

00800fd8 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800fd8:	55                   	push   %ebp
  800fd9:	89 e5                	mov    %esp,%ebp
  800fdb:	57                   	push   %edi
  800fdc:	56                   	push   %esi
  800fdd:	53                   	push   %ebx
  800fde:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fe1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fe6:	b8 08 00 00 00       	mov    $0x8,%eax
  800feb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fee:	8b 55 08             	mov    0x8(%ebp),%edx
  800ff1:	89 df                	mov    %ebx,%edi
  800ff3:	89 de                	mov    %ebx,%esi
  800ff5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ff7:	85 c0                	test   %eax,%eax
  800ff9:	7e 17                	jle    801012 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ffb:	83 ec 0c             	sub    $0xc,%esp
  800ffe:	50                   	push   %eax
  800fff:	6a 08                	push   $0x8
  801001:	68 af 24 80 00       	push   $0x8024af
  801006:	6a 23                	push   $0x23
  801008:	68 cc 24 80 00       	push   $0x8024cc
  80100d:	e8 cc f2 ff ff       	call   8002de <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801012:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801015:	5b                   	pop    %ebx
  801016:	5e                   	pop    %esi
  801017:	5f                   	pop    %edi
  801018:	5d                   	pop    %ebp
  801019:	c3                   	ret    

0080101a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80101a:	55                   	push   %ebp
  80101b:	89 e5                	mov    %esp,%ebp
  80101d:	57                   	push   %edi
  80101e:	56                   	push   %esi
  80101f:	53                   	push   %ebx
  801020:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801023:	bb 00 00 00 00       	mov    $0x0,%ebx
  801028:	b8 09 00 00 00       	mov    $0x9,%eax
  80102d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801030:	8b 55 08             	mov    0x8(%ebp),%edx
  801033:	89 df                	mov    %ebx,%edi
  801035:	89 de                	mov    %ebx,%esi
  801037:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801039:	85 c0                	test   %eax,%eax
  80103b:	7e 17                	jle    801054 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80103d:	83 ec 0c             	sub    $0xc,%esp
  801040:	50                   	push   %eax
  801041:	6a 09                	push   $0x9
  801043:	68 af 24 80 00       	push   $0x8024af
  801048:	6a 23                	push   $0x23
  80104a:	68 cc 24 80 00       	push   $0x8024cc
  80104f:	e8 8a f2 ff ff       	call   8002de <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801054:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801057:	5b                   	pop    %ebx
  801058:	5e                   	pop    %esi
  801059:	5f                   	pop    %edi
  80105a:	5d                   	pop    %ebp
  80105b:	c3                   	ret    

0080105c <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80105c:	55                   	push   %ebp
  80105d:	89 e5                	mov    %esp,%ebp
  80105f:	57                   	push   %edi
  801060:	56                   	push   %esi
  801061:	53                   	push   %ebx
  801062:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801065:	bb 00 00 00 00       	mov    $0x0,%ebx
  80106a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80106f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801072:	8b 55 08             	mov    0x8(%ebp),%edx
  801075:	89 df                	mov    %ebx,%edi
  801077:	89 de                	mov    %ebx,%esi
  801079:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80107b:	85 c0                	test   %eax,%eax
  80107d:	7e 17                	jle    801096 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80107f:	83 ec 0c             	sub    $0xc,%esp
  801082:	50                   	push   %eax
  801083:	6a 0a                	push   $0xa
  801085:	68 af 24 80 00       	push   $0x8024af
  80108a:	6a 23                	push   $0x23
  80108c:	68 cc 24 80 00       	push   $0x8024cc
  801091:	e8 48 f2 ff ff       	call   8002de <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801096:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801099:	5b                   	pop    %ebx
  80109a:	5e                   	pop    %esi
  80109b:	5f                   	pop    %edi
  80109c:	5d                   	pop    %ebp
  80109d:	c3                   	ret    

0080109e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80109e:	55                   	push   %ebp
  80109f:	89 e5                	mov    %esp,%ebp
  8010a1:	57                   	push   %edi
  8010a2:	56                   	push   %esi
  8010a3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010a4:	be 00 00 00 00       	mov    $0x0,%esi
  8010a9:	b8 0c 00 00 00       	mov    $0xc,%eax
  8010ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8010b4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010b7:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010ba:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8010bc:	5b                   	pop    %ebx
  8010bd:	5e                   	pop    %esi
  8010be:	5f                   	pop    %edi
  8010bf:	5d                   	pop    %ebp
  8010c0:	c3                   	ret    

008010c1 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8010c1:	55                   	push   %ebp
  8010c2:	89 e5                	mov    %esp,%ebp
  8010c4:	57                   	push   %edi
  8010c5:	56                   	push   %esi
  8010c6:	53                   	push   %ebx
  8010c7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010ca:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010cf:	b8 0d 00 00 00       	mov    $0xd,%eax
  8010d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8010d7:	89 cb                	mov    %ecx,%ebx
  8010d9:	89 cf                	mov    %ecx,%edi
  8010db:	89 ce                	mov    %ecx,%esi
  8010dd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010df:	85 c0                	test   %eax,%eax
  8010e1:	7e 17                	jle    8010fa <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010e3:	83 ec 0c             	sub    $0xc,%esp
  8010e6:	50                   	push   %eax
  8010e7:	6a 0d                	push   $0xd
  8010e9:	68 af 24 80 00       	push   $0x8024af
  8010ee:	6a 23                	push   $0x23
  8010f0:	68 cc 24 80 00       	push   $0x8024cc
  8010f5:	e8 e4 f1 ff ff       	call   8002de <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8010fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010fd:	5b                   	pop    %ebx
  8010fe:	5e                   	pop    %esi
  8010ff:	5f                   	pop    %edi
  801100:	5d                   	pop    %ebp
  801101:	c3                   	ret    

00801102 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801102:	55                   	push   %ebp
  801103:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801105:	8b 45 08             	mov    0x8(%ebp),%eax
  801108:	05 00 00 00 30       	add    $0x30000000,%eax
  80110d:	c1 e8 0c             	shr    $0xc,%eax
}
  801110:	5d                   	pop    %ebp
  801111:	c3                   	ret    

00801112 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801112:	55                   	push   %ebp
  801113:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801115:	8b 45 08             	mov    0x8(%ebp),%eax
  801118:	05 00 00 00 30       	add    $0x30000000,%eax
  80111d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801122:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801127:	5d                   	pop    %ebp
  801128:	c3                   	ret    

00801129 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801129:	55                   	push   %ebp
  80112a:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80112c:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801131:	a8 01                	test   $0x1,%al
  801133:	74 34                	je     801169 <fd_alloc+0x40>
  801135:	a1 00 00 74 ef       	mov    0xef740000,%eax
  80113a:	a8 01                	test   $0x1,%al
  80113c:	74 32                	je     801170 <fd_alloc+0x47>
  80113e:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801143:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801145:	89 c2                	mov    %eax,%edx
  801147:	c1 ea 16             	shr    $0x16,%edx
  80114a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801151:	f6 c2 01             	test   $0x1,%dl
  801154:	74 1f                	je     801175 <fd_alloc+0x4c>
  801156:	89 c2                	mov    %eax,%edx
  801158:	c1 ea 0c             	shr    $0xc,%edx
  80115b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801162:	f6 c2 01             	test   $0x1,%dl
  801165:	75 1a                	jne    801181 <fd_alloc+0x58>
  801167:	eb 0c                	jmp    801175 <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801169:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  80116e:	eb 05                	jmp    801175 <fd_alloc+0x4c>
  801170:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  801175:	8b 45 08             	mov    0x8(%ebp),%eax
  801178:	89 08                	mov    %ecx,(%eax)
			return 0;
  80117a:	b8 00 00 00 00       	mov    $0x0,%eax
  80117f:	eb 1a                	jmp    80119b <fd_alloc+0x72>
  801181:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801186:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80118b:	75 b6                	jne    801143 <fd_alloc+0x1a>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80118d:	8b 45 08             	mov    0x8(%ebp),%eax
  801190:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  801196:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80119b:	5d                   	pop    %ebp
  80119c:	c3                   	ret    

0080119d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80119d:	55                   	push   %ebp
  80119e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011a0:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  8011a4:	77 39                	ja     8011df <fd_lookup+0x42>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8011a9:	c1 e0 0c             	shl    $0xc,%eax
  8011ac:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011b1:	89 c2                	mov    %eax,%edx
  8011b3:	c1 ea 16             	shr    $0x16,%edx
  8011b6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011bd:	f6 c2 01             	test   $0x1,%dl
  8011c0:	74 24                	je     8011e6 <fd_lookup+0x49>
  8011c2:	89 c2                	mov    %eax,%edx
  8011c4:	c1 ea 0c             	shr    $0xc,%edx
  8011c7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011ce:	f6 c2 01             	test   $0x1,%dl
  8011d1:	74 1a                	je     8011ed <fd_lookup+0x50>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011d3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011d6:	89 02                	mov    %eax,(%edx)
	return 0;
  8011d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8011dd:	eb 13                	jmp    8011f2 <fd_lookup+0x55>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011df:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011e4:	eb 0c                	jmp    8011f2 <fd_lookup+0x55>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011e6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011eb:	eb 05                	jmp    8011f2 <fd_lookup+0x55>
  8011ed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8011f2:	5d                   	pop    %ebp
  8011f3:	c3                   	ret    

008011f4 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011f4:	55                   	push   %ebp
  8011f5:	89 e5                	mov    %esp,%ebp
  8011f7:	53                   	push   %ebx
  8011f8:	83 ec 04             	sub    $0x4,%esp
  8011fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8011fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801201:	3b 05 20 30 80 00    	cmp    0x803020,%eax
  801207:	75 1e                	jne    801227 <dev_lookup+0x33>
  801209:	eb 0e                	jmp    801219 <dev_lookup+0x25>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80120b:	b8 3c 30 80 00       	mov    $0x80303c,%eax
  801210:	eb 0c                	jmp    80121e <dev_lookup+0x2a>
  801212:	b8 00 30 80 00       	mov    $0x803000,%eax
  801217:	eb 05                	jmp    80121e <dev_lookup+0x2a>
  801219:	b8 20 30 80 00       	mov    $0x803020,%eax
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  80121e:	89 03                	mov    %eax,(%ebx)
			return 0;
  801220:	b8 00 00 00 00       	mov    $0x0,%eax
  801225:	eb 36                	jmp    80125d <dev_lookup+0x69>
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801227:	3b 05 3c 30 80 00    	cmp    0x80303c,%eax
  80122d:	74 dc                	je     80120b <dev_lookup+0x17>
  80122f:	3b 05 00 30 80 00    	cmp    0x803000,%eax
  801235:	74 db                	je     801212 <dev_lookup+0x1e>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801237:	8b 15 04 44 80 00    	mov    0x804404,%edx
  80123d:	8b 52 48             	mov    0x48(%edx),%edx
  801240:	83 ec 04             	sub    $0x4,%esp
  801243:	50                   	push   %eax
  801244:	52                   	push   %edx
  801245:	68 dc 24 80 00       	push   $0x8024dc
  80124a:	e8 67 f1 ff ff       	call   8003b6 <cprintf>
	*dev = 0;
  80124f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801255:	83 c4 10             	add    $0x10,%esp
  801258:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80125d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801260:	c9                   	leave  
  801261:	c3                   	ret    

00801262 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801262:	55                   	push   %ebp
  801263:	89 e5                	mov    %esp,%ebp
  801265:	56                   	push   %esi
  801266:	53                   	push   %ebx
  801267:	83 ec 10             	sub    $0x10,%esp
  80126a:	8b 75 08             	mov    0x8(%ebp),%esi
  80126d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801270:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801273:	50                   	push   %eax
  801274:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80127a:	c1 e8 0c             	shr    $0xc,%eax
  80127d:	50                   	push   %eax
  80127e:	e8 1a ff ff ff       	call   80119d <fd_lookup>
  801283:	83 c4 08             	add    $0x8,%esp
  801286:	85 c0                	test   %eax,%eax
  801288:	78 05                	js     80128f <fd_close+0x2d>
	    || fd != fd2)
  80128a:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80128d:	74 06                	je     801295 <fd_close+0x33>
		return (must_exist ? r : 0);
  80128f:	84 db                	test   %bl,%bl
  801291:	74 47                	je     8012da <fd_close+0x78>
  801293:	eb 4a                	jmp    8012df <fd_close+0x7d>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801295:	83 ec 08             	sub    $0x8,%esp
  801298:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80129b:	50                   	push   %eax
  80129c:	ff 36                	pushl  (%esi)
  80129e:	e8 51 ff ff ff       	call   8011f4 <dev_lookup>
  8012a3:	89 c3                	mov    %eax,%ebx
  8012a5:	83 c4 10             	add    $0x10,%esp
  8012a8:	85 c0                	test   %eax,%eax
  8012aa:	78 1c                	js     8012c8 <fd_close+0x66>
		if (dev->dev_close)
  8012ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012af:	8b 40 10             	mov    0x10(%eax),%eax
  8012b2:	85 c0                	test   %eax,%eax
  8012b4:	74 0d                	je     8012c3 <fd_close+0x61>
			r = (*dev->dev_close)(fd);
  8012b6:	83 ec 0c             	sub    $0xc,%esp
  8012b9:	56                   	push   %esi
  8012ba:	ff d0                	call   *%eax
  8012bc:	89 c3                	mov    %eax,%ebx
  8012be:	83 c4 10             	add    $0x10,%esp
  8012c1:	eb 05                	jmp    8012c8 <fd_close+0x66>
		else
			r = 0;
  8012c3:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012c8:	83 ec 08             	sub    $0x8,%esp
  8012cb:	56                   	push   %esi
  8012cc:	6a 00                	push   $0x0
  8012ce:	e8 c3 fc ff ff       	call   800f96 <sys_page_unmap>
	return r;
  8012d3:	83 c4 10             	add    $0x10,%esp
  8012d6:	89 d8                	mov    %ebx,%eax
  8012d8:	eb 05                	jmp    8012df <fd_close+0x7d>
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
  8012da:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
	return r;
}
  8012df:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012e2:	5b                   	pop    %ebx
  8012e3:	5e                   	pop    %esi
  8012e4:	5d                   	pop    %ebp
  8012e5:	c3                   	ret    

008012e6 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012e6:	55                   	push   %ebp
  8012e7:	89 e5                	mov    %esp,%ebp
  8012e9:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012ef:	50                   	push   %eax
  8012f0:	ff 75 08             	pushl  0x8(%ebp)
  8012f3:	e8 a5 fe ff ff       	call   80119d <fd_lookup>
  8012f8:	83 c4 08             	add    $0x8,%esp
  8012fb:	85 c0                	test   %eax,%eax
  8012fd:	78 10                	js     80130f <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012ff:	83 ec 08             	sub    $0x8,%esp
  801302:	6a 01                	push   $0x1
  801304:	ff 75 f4             	pushl  -0xc(%ebp)
  801307:	e8 56 ff ff ff       	call   801262 <fd_close>
  80130c:	83 c4 10             	add    $0x10,%esp
}
  80130f:	c9                   	leave  
  801310:	c3                   	ret    

00801311 <close_all>:

void
close_all(void)
{
  801311:	55                   	push   %ebp
  801312:	89 e5                	mov    %esp,%ebp
  801314:	53                   	push   %ebx
  801315:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801318:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80131d:	83 ec 0c             	sub    $0xc,%esp
  801320:	53                   	push   %ebx
  801321:	e8 c0 ff ff ff       	call   8012e6 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801326:	43                   	inc    %ebx
  801327:	83 c4 10             	add    $0x10,%esp
  80132a:	83 fb 20             	cmp    $0x20,%ebx
  80132d:	75 ee                	jne    80131d <close_all+0xc>
		close(i);
}
  80132f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801332:	c9                   	leave  
  801333:	c3                   	ret    

00801334 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801334:	55                   	push   %ebp
  801335:	89 e5                	mov    %esp,%ebp
  801337:	57                   	push   %edi
  801338:	56                   	push   %esi
  801339:	53                   	push   %ebx
  80133a:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80133d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801340:	50                   	push   %eax
  801341:	ff 75 08             	pushl  0x8(%ebp)
  801344:	e8 54 fe ff ff       	call   80119d <fd_lookup>
  801349:	83 c4 08             	add    $0x8,%esp
  80134c:	85 c0                	test   %eax,%eax
  80134e:	0f 88 c2 00 00 00    	js     801416 <dup+0xe2>
		return r;
	close(newfdnum);
  801354:	83 ec 0c             	sub    $0xc,%esp
  801357:	ff 75 0c             	pushl  0xc(%ebp)
  80135a:	e8 87 ff ff ff       	call   8012e6 <close>

	newfd = INDEX2FD(newfdnum);
  80135f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801362:	c1 e3 0c             	shl    $0xc,%ebx
  801365:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80136b:	83 c4 04             	add    $0x4,%esp
  80136e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801371:	e8 9c fd ff ff       	call   801112 <fd2data>
  801376:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801378:	89 1c 24             	mov    %ebx,(%esp)
  80137b:	e8 92 fd ff ff       	call   801112 <fd2data>
  801380:	83 c4 10             	add    $0x10,%esp
  801383:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801385:	89 f0                	mov    %esi,%eax
  801387:	c1 e8 16             	shr    $0x16,%eax
  80138a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801391:	a8 01                	test   $0x1,%al
  801393:	74 35                	je     8013ca <dup+0x96>
  801395:	89 f0                	mov    %esi,%eax
  801397:	c1 e8 0c             	shr    $0xc,%eax
  80139a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013a1:	f6 c2 01             	test   $0x1,%dl
  8013a4:	74 24                	je     8013ca <dup+0x96>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013a6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013ad:	83 ec 0c             	sub    $0xc,%esp
  8013b0:	25 07 0e 00 00       	and    $0xe07,%eax
  8013b5:	50                   	push   %eax
  8013b6:	57                   	push   %edi
  8013b7:	6a 00                	push   $0x0
  8013b9:	56                   	push   %esi
  8013ba:	6a 00                	push   $0x0
  8013bc:	e8 93 fb ff ff       	call   800f54 <sys_page_map>
  8013c1:	89 c6                	mov    %eax,%esi
  8013c3:	83 c4 20             	add    $0x20,%esp
  8013c6:	85 c0                	test   %eax,%eax
  8013c8:	78 2c                	js     8013f6 <dup+0xc2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013ca:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013cd:	89 d0                	mov    %edx,%eax
  8013cf:	c1 e8 0c             	shr    $0xc,%eax
  8013d2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013d9:	83 ec 0c             	sub    $0xc,%esp
  8013dc:	25 07 0e 00 00       	and    $0xe07,%eax
  8013e1:	50                   	push   %eax
  8013e2:	53                   	push   %ebx
  8013e3:	6a 00                	push   $0x0
  8013e5:	52                   	push   %edx
  8013e6:	6a 00                	push   $0x0
  8013e8:	e8 67 fb ff ff       	call   800f54 <sys_page_map>
  8013ed:	89 c6                	mov    %eax,%esi
  8013ef:	83 c4 20             	add    $0x20,%esp
  8013f2:	85 c0                	test   %eax,%eax
  8013f4:	79 1d                	jns    801413 <dup+0xdf>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013f6:	83 ec 08             	sub    $0x8,%esp
  8013f9:	53                   	push   %ebx
  8013fa:	6a 00                	push   $0x0
  8013fc:	e8 95 fb ff ff       	call   800f96 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801401:	83 c4 08             	add    $0x8,%esp
  801404:	57                   	push   %edi
  801405:	6a 00                	push   $0x0
  801407:	e8 8a fb ff ff       	call   800f96 <sys_page_unmap>
	return r;
  80140c:	83 c4 10             	add    $0x10,%esp
  80140f:	89 f0                	mov    %esi,%eax
  801411:	eb 03                	jmp    801416 <dup+0xe2>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801413:	8b 45 0c             	mov    0xc(%ebp),%eax

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801416:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801419:	5b                   	pop    %ebx
  80141a:	5e                   	pop    %esi
  80141b:	5f                   	pop    %edi
  80141c:	5d                   	pop    %ebp
  80141d:	c3                   	ret    

0080141e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
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
  80142d:	e8 6b fd ff ff       	call   80119d <fd_lookup>
  801432:	83 c4 08             	add    $0x8,%esp
  801435:	85 c0                	test   %eax,%eax
  801437:	78 67                	js     8014a0 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801439:	83 ec 08             	sub    $0x8,%esp
  80143c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80143f:	50                   	push   %eax
  801440:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801443:	ff 30                	pushl  (%eax)
  801445:	e8 aa fd ff ff       	call   8011f4 <dev_lookup>
  80144a:	83 c4 10             	add    $0x10,%esp
  80144d:	85 c0                	test   %eax,%eax
  80144f:	78 4f                	js     8014a0 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801451:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801454:	8b 42 08             	mov    0x8(%edx),%eax
  801457:	83 e0 03             	and    $0x3,%eax
  80145a:	83 f8 01             	cmp    $0x1,%eax
  80145d:	75 21                	jne    801480 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80145f:	a1 04 44 80 00       	mov    0x804404,%eax
  801464:	8b 40 48             	mov    0x48(%eax),%eax
  801467:	83 ec 04             	sub    $0x4,%esp
  80146a:	53                   	push   %ebx
  80146b:	50                   	push   %eax
  80146c:	68 20 25 80 00       	push   $0x802520
  801471:	e8 40 ef ff ff       	call   8003b6 <cprintf>
		return -E_INVAL;
  801476:	83 c4 10             	add    $0x10,%esp
  801479:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80147e:	eb 20                	jmp    8014a0 <read+0x82>
	}
	if (!dev->dev_read)
  801480:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801483:	8b 40 08             	mov    0x8(%eax),%eax
  801486:	85 c0                	test   %eax,%eax
  801488:	74 11                	je     80149b <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80148a:	83 ec 04             	sub    $0x4,%esp
  80148d:	ff 75 10             	pushl  0x10(%ebp)
  801490:	ff 75 0c             	pushl  0xc(%ebp)
  801493:	52                   	push   %edx
  801494:	ff d0                	call   *%eax
  801496:	83 c4 10             	add    $0x10,%esp
  801499:	eb 05                	jmp    8014a0 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80149b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8014a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014a3:	c9                   	leave  
  8014a4:	c3                   	ret    

008014a5 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014a5:	55                   	push   %ebp
  8014a6:	89 e5                	mov    %esp,%ebp
  8014a8:	57                   	push   %edi
  8014a9:	56                   	push   %esi
  8014aa:	53                   	push   %ebx
  8014ab:	83 ec 0c             	sub    $0xc,%esp
  8014ae:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014b1:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014b4:	85 f6                	test   %esi,%esi
  8014b6:	74 31                	je     8014e9 <readn+0x44>
  8014b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8014bd:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014c2:	83 ec 04             	sub    $0x4,%esp
  8014c5:	89 f2                	mov    %esi,%edx
  8014c7:	29 c2                	sub    %eax,%edx
  8014c9:	52                   	push   %edx
  8014ca:	03 45 0c             	add    0xc(%ebp),%eax
  8014cd:	50                   	push   %eax
  8014ce:	57                   	push   %edi
  8014cf:	e8 4a ff ff ff       	call   80141e <read>
		if (m < 0)
  8014d4:	83 c4 10             	add    $0x10,%esp
  8014d7:	85 c0                	test   %eax,%eax
  8014d9:	78 17                	js     8014f2 <readn+0x4d>
			return m;
		if (m == 0)
  8014db:	85 c0                	test   %eax,%eax
  8014dd:	74 11                	je     8014f0 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014df:	01 c3                	add    %eax,%ebx
  8014e1:	89 d8                	mov    %ebx,%eax
  8014e3:	39 f3                	cmp    %esi,%ebx
  8014e5:	72 db                	jb     8014c2 <readn+0x1d>
  8014e7:	eb 09                	jmp    8014f2 <readn+0x4d>
  8014e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8014ee:	eb 02                	jmp    8014f2 <readn+0x4d>
  8014f0:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014f5:	5b                   	pop    %ebx
  8014f6:	5e                   	pop    %esi
  8014f7:	5f                   	pop    %edi
  8014f8:	5d                   	pop    %ebp
  8014f9:	c3                   	ret    

008014fa <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014fa:	55                   	push   %ebp
  8014fb:	89 e5                	mov    %esp,%ebp
  8014fd:	53                   	push   %ebx
  8014fe:	83 ec 14             	sub    $0x14,%esp
  801501:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801504:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801507:	50                   	push   %eax
  801508:	53                   	push   %ebx
  801509:	e8 8f fc ff ff       	call   80119d <fd_lookup>
  80150e:	83 c4 08             	add    $0x8,%esp
  801511:	85 c0                	test   %eax,%eax
  801513:	78 62                	js     801577 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801515:	83 ec 08             	sub    $0x8,%esp
  801518:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80151b:	50                   	push   %eax
  80151c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80151f:	ff 30                	pushl  (%eax)
  801521:	e8 ce fc ff ff       	call   8011f4 <dev_lookup>
  801526:	83 c4 10             	add    $0x10,%esp
  801529:	85 c0                	test   %eax,%eax
  80152b:	78 4a                	js     801577 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80152d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801530:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801534:	75 21                	jne    801557 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801536:	a1 04 44 80 00       	mov    0x804404,%eax
  80153b:	8b 40 48             	mov    0x48(%eax),%eax
  80153e:	83 ec 04             	sub    $0x4,%esp
  801541:	53                   	push   %ebx
  801542:	50                   	push   %eax
  801543:	68 3c 25 80 00       	push   $0x80253c
  801548:	e8 69 ee ff ff       	call   8003b6 <cprintf>
		return -E_INVAL;
  80154d:	83 c4 10             	add    $0x10,%esp
  801550:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801555:	eb 20                	jmp    801577 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801557:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80155a:	8b 52 0c             	mov    0xc(%edx),%edx
  80155d:	85 d2                	test   %edx,%edx
  80155f:	74 11                	je     801572 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801561:	83 ec 04             	sub    $0x4,%esp
  801564:	ff 75 10             	pushl  0x10(%ebp)
  801567:	ff 75 0c             	pushl  0xc(%ebp)
  80156a:	50                   	push   %eax
  80156b:	ff d2                	call   *%edx
  80156d:	83 c4 10             	add    $0x10,%esp
  801570:	eb 05                	jmp    801577 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801572:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801577:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80157a:	c9                   	leave  
  80157b:	c3                   	ret    

0080157c <seek>:

int
seek(int fdnum, off_t offset)
{
  80157c:	55                   	push   %ebp
  80157d:	89 e5                	mov    %esp,%ebp
  80157f:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801582:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801585:	50                   	push   %eax
  801586:	ff 75 08             	pushl  0x8(%ebp)
  801589:	e8 0f fc ff ff       	call   80119d <fd_lookup>
  80158e:	83 c4 08             	add    $0x8,%esp
  801591:	85 c0                	test   %eax,%eax
  801593:	78 0e                	js     8015a3 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801595:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801598:	8b 55 0c             	mov    0xc(%ebp),%edx
  80159b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80159e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015a3:	c9                   	leave  
  8015a4:	c3                   	ret    

008015a5 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015a5:	55                   	push   %ebp
  8015a6:	89 e5                	mov    %esp,%ebp
  8015a8:	53                   	push   %ebx
  8015a9:	83 ec 14             	sub    $0x14,%esp
  8015ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015af:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015b2:	50                   	push   %eax
  8015b3:	53                   	push   %ebx
  8015b4:	e8 e4 fb ff ff       	call   80119d <fd_lookup>
  8015b9:	83 c4 08             	add    $0x8,%esp
  8015bc:	85 c0                	test   %eax,%eax
  8015be:	78 5f                	js     80161f <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015c0:	83 ec 08             	sub    $0x8,%esp
  8015c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015c6:	50                   	push   %eax
  8015c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ca:	ff 30                	pushl  (%eax)
  8015cc:	e8 23 fc ff ff       	call   8011f4 <dev_lookup>
  8015d1:	83 c4 10             	add    $0x10,%esp
  8015d4:	85 c0                	test   %eax,%eax
  8015d6:	78 47                	js     80161f <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015db:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015df:	75 21                	jne    801602 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015e1:	a1 04 44 80 00       	mov    0x804404,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015e6:	8b 40 48             	mov    0x48(%eax),%eax
  8015e9:	83 ec 04             	sub    $0x4,%esp
  8015ec:	53                   	push   %ebx
  8015ed:	50                   	push   %eax
  8015ee:	68 fc 24 80 00       	push   $0x8024fc
  8015f3:	e8 be ed ff ff       	call   8003b6 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015f8:	83 c4 10             	add    $0x10,%esp
  8015fb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801600:	eb 1d                	jmp    80161f <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  801602:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801605:	8b 52 18             	mov    0x18(%edx),%edx
  801608:	85 d2                	test   %edx,%edx
  80160a:	74 0e                	je     80161a <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80160c:	83 ec 08             	sub    $0x8,%esp
  80160f:	ff 75 0c             	pushl  0xc(%ebp)
  801612:	50                   	push   %eax
  801613:	ff d2                	call   *%edx
  801615:	83 c4 10             	add    $0x10,%esp
  801618:	eb 05                	jmp    80161f <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80161a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80161f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801622:	c9                   	leave  
  801623:	c3                   	ret    

00801624 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801624:	55                   	push   %ebp
  801625:	89 e5                	mov    %esp,%ebp
  801627:	53                   	push   %ebx
  801628:	83 ec 14             	sub    $0x14,%esp
  80162b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80162e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801631:	50                   	push   %eax
  801632:	ff 75 08             	pushl  0x8(%ebp)
  801635:	e8 63 fb ff ff       	call   80119d <fd_lookup>
  80163a:	83 c4 08             	add    $0x8,%esp
  80163d:	85 c0                	test   %eax,%eax
  80163f:	78 52                	js     801693 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801641:	83 ec 08             	sub    $0x8,%esp
  801644:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801647:	50                   	push   %eax
  801648:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80164b:	ff 30                	pushl  (%eax)
  80164d:	e8 a2 fb ff ff       	call   8011f4 <dev_lookup>
  801652:	83 c4 10             	add    $0x10,%esp
  801655:	85 c0                	test   %eax,%eax
  801657:	78 3a                	js     801693 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  801659:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80165c:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801660:	74 2c                	je     80168e <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801662:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801665:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80166c:	00 00 00 
	stat->st_isdir = 0;
  80166f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801676:	00 00 00 
	stat->st_dev = dev;
  801679:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80167f:	83 ec 08             	sub    $0x8,%esp
  801682:	53                   	push   %ebx
  801683:	ff 75 f0             	pushl  -0x10(%ebp)
  801686:	ff 50 14             	call   *0x14(%eax)
  801689:	83 c4 10             	add    $0x10,%esp
  80168c:	eb 05                	jmp    801693 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80168e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801693:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801696:	c9                   	leave  
  801697:	c3                   	ret    

00801698 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801698:	55                   	push   %ebp
  801699:	89 e5                	mov    %esp,%ebp
  80169b:	56                   	push   %esi
  80169c:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80169d:	83 ec 08             	sub    $0x8,%esp
  8016a0:	6a 00                	push   $0x0
  8016a2:	ff 75 08             	pushl  0x8(%ebp)
  8016a5:	e8 75 01 00 00       	call   80181f <open>
  8016aa:	89 c3                	mov    %eax,%ebx
  8016ac:	83 c4 10             	add    $0x10,%esp
  8016af:	85 c0                	test   %eax,%eax
  8016b1:	78 1d                	js     8016d0 <stat+0x38>
		return fd;
	r = fstat(fd, stat);
  8016b3:	83 ec 08             	sub    $0x8,%esp
  8016b6:	ff 75 0c             	pushl  0xc(%ebp)
  8016b9:	50                   	push   %eax
  8016ba:	e8 65 ff ff ff       	call   801624 <fstat>
  8016bf:	89 c6                	mov    %eax,%esi
	close(fd);
  8016c1:	89 1c 24             	mov    %ebx,(%esp)
  8016c4:	e8 1d fc ff ff       	call   8012e6 <close>
	return r;
  8016c9:	83 c4 10             	add    $0x10,%esp
  8016cc:	89 f0                	mov    %esi,%eax
  8016ce:	eb 00                	jmp    8016d0 <stat+0x38>
}
  8016d0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016d3:	5b                   	pop    %ebx
  8016d4:	5e                   	pop    %esi
  8016d5:	5d                   	pop    %ebp
  8016d6:	c3                   	ret    

008016d7 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016d7:	55                   	push   %ebp
  8016d8:	89 e5                	mov    %esp,%ebp
  8016da:	56                   	push   %esi
  8016db:	53                   	push   %ebx
  8016dc:	89 c6                	mov    %eax,%esi
  8016de:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016e0:	83 3d 00 44 80 00 00 	cmpl   $0x0,0x804400
  8016e7:	75 12                	jne    8016fb <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016e9:	83 ec 0c             	sub    $0xc,%esp
  8016ec:	6a 01                	push   $0x1
  8016ee:	e8 fe 06 00 00       	call   801df1 <ipc_find_env>
  8016f3:	a3 00 44 80 00       	mov    %eax,0x804400
  8016f8:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016fb:	6a 07                	push   $0x7
  8016fd:	68 00 50 80 00       	push   $0x805000
  801702:	56                   	push   %esi
  801703:	ff 35 00 44 80 00    	pushl  0x804400
  801709:	e8 84 06 00 00       	call   801d92 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80170e:	83 c4 0c             	add    $0xc,%esp
  801711:	6a 00                	push   $0x0
  801713:	53                   	push   %ebx
  801714:	6a 00                	push   $0x0
  801716:	e8 02 06 00 00       	call   801d1d <ipc_recv>
}
  80171b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80171e:	5b                   	pop    %ebx
  80171f:	5e                   	pop    %esi
  801720:	5d                   	pop    %ebp
  801721:	c3                   	ret    

00801722 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801722:	55                   	push   %ebp
  801723:	89 e5                	mov    %esp,%ebp
  801725:	53                   	push   %ebx
  801726:	83 ec 04             	sub    $0x4,%esp
  801729:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80172c:	8b 45 08             	mov    0x8(%ebp),%eax
  80172f:	8b 40 0c             	mov    0xc(%eax),%eax
  801732:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801737:	ba 00 00 00 00       	mov    $0x0,%edx
  80173c:	b8 05 00 00 00       	mov    $0x5,%eax
  801741:	e8 91 ff ff ff       	call   8016d7 <fsipc>
  801746:	85 c0                	test   %eax,%eax
  801748:	78 2c                	js     801776 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80174a:	83 ec 08             	sub    $0x8,%esp
  80174d:	68 00 50 80 00       	push   $0x805000
  801752:	53                   	push   %ebx
  801753:	e8 49 f3 ff ff       	call   800aa1 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801758:	a1 80 50 80 00       	mov    0x805080,%eax
  80175d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801763:	a1 84 50 80 00       	mov    0x805084,%eax
  801768:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80176e:	83 c4 10             	add    $0x10,%esp
  801771:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801776:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801779:	c9                   	leave  
  80177a:	c3                   	ret    

0080177b <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80177b:	55                   	push   %ebp
  80177c:	89 e5                	mov    %esp,%ebp
  80177e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801781:	8b 45 08             	mov    0x8(%ebp),%eax
  801784:	8b 40 0c             	mov    0xc(%eax),%eax
  801787:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80178c:	ba 00 00 00 00       	mov    $0x0,%edx
  801791:	b8 06 00 00 00       	mov    $0x6,%eax
  801796:	e8 3c ff ff ff       	call   8016d7 <fsipc>
}
  80179b:	c9                   	leave  
  80179c:	c3                   	ret    

0080179d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80179d:	55                   	push   %ebp
  80179e:	89 e5                	mov    %esp,%ebp
  8017a0:	56                   	push   %esi
  8017a1:	53                   	push   %ebx
  8017a2:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a8:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ab:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8017b0:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8017bb:	b8 03 00 00 00       	mov    $0x3,%eax
  8017c0:	e8 12 ff ff ff       	call   8016d7 <fsipc>
  8017c5:	89 c3                	mov    %eax,%ebx
  8017c7:	85 c0                	test   %eax,%eax
  8017c9:	78 4b                	js     801816 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8017cb:	39 c6                	cmp    %eax,%esi
  8017cd:	73 16                	jae    8017e5 <devfile_read+0x48>
  8017cf:	68 59 25 80 00       	push   $0x802559
  8017d4:	68 60 25 80 00       	push   $0x802560
  8017d9:	6a 7a                	push   $0x7a
  8017db:	68 75 25 80 00       	push   $0x802575
  8017e0:	e8 f9 ea ff ff       	call   8002de <_panic>
	assert(r <= PGSIZE);
  8017e5:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017ea:	7e 16                	jle    801802 <devfile_read+0x65>
  8017ec:	68 80 25 80 00       	push   $0x802580
  8017f1:	68 60 25 80 00       	push   $0x802560
  8017f6:	6a 7b                	push   $0x7b
  8017f8:	68 75 25 80 00       	push   $0x802575
  8017fd:	e8 dc ea ff ff       	call   8002de <_panic>
	memmove(buf, &fsipcbuf, r);
  801802:	83 ec 04             	sub    $0x4,%esp
  801805:	50                   	push   %eax
  801806:	68 00 50 80 00       	push   $0x805000
  80180b:	ff 75 0c             	pushl  0xc(%ebp)
  80180e:	e8 5b f4 ff ff       	call   800c6e <memmove>
	return r;
  801813:	83 c4 10             	add    $0x10,%esp
}
  801816:	89 d8                	mov    %ebx,%eax
  801818:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80181b:	5b                   	pop    %ebx
  80181c:	5e                   	pop    %esi
  80181d:	5d                   	pop    %ebp
  80181e:	c3                   	ret    

0080181f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80181f:	55                   	push   %ebp
  801820:	89 e5                	mov    %esp,%ebp
  801822:	53                   	push   %ebx
  801823:	83 ec 20             	sub    $0x20,%esp
  801826:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801829:	53                   	push   %ebx
  80182a:	e8 1b f2 ff ff       	call   800a4a <strlen>
  80182f:	83 c4 10             	add    $0x10,%esp
  801832:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801837:	7f 63                	jg     80189c <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801839:	83 ec 0c             	sub    $0xc,%esp
  80183c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80183f:	50                   	push   %eax
  801840:	e8 e4 f8 ff ff       	call   801129 <fd_alloc>
  801845:	83 c4 10             	add    $0x10,%esp
  801848:	85 c0                	test   %eax,%eax
  80184a:	78 55                	js     8018a1 <open+0x82>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80184c:	83 ec 08             	sub    $0x8,%esp
  80184f:	53                   	push   %ebx
  801850:	68 00 50 80 00       	push   $0x805000
  801855:	e8 47 f2 ff ff       	call   800aa1 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80185a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80185d:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801862:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801865:	b8 01 00 00 00       	mov    $0x1,%eax
  80186a:	e8 68 fe ff ff       	call   8016d7 <fsipc>
  80186f:	89 c3                	mov    %eax,%ebx
  801871:	83 c4 10             	add    $0x10,%esp
  801874:	85 c0                	test   %eax,%eax
  801876:	79 14                	jns    80188c <open+0x6d>
		fd_close(fd, 0);
  801878:	83 ec 08             	sub    $0x8,%esp
  80187b:	6a 00                	push   $0x0
  80187d:	ff 75 f4             	pushl  -0xc(%ebp)
  801880:	e8 dd f9 ff ff       	call   801262 <fd_close>
		return r;
  801885:	83 c4 10             	add    $0x10,%esp
  801888:	89 d8                	mov    %ebx,%eax
  80188a:	eb 15                	jmp    8018a1 <open+0x82>
	}

	return fd2num(fd);
  80188c:	83 ec 0c             	sub    $0xc,%esp
  80188f:	ff 75 f4             	pushl  -0xc(%ebp)
  801892:	e8 6b f8 ff ff       	call   801102 <fd2num>
  801897:	83 c4 10             	add    $0x10,%esp
  80189a:	eb 05                	jmp    8018a1 <open+0x82>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80189c:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8018a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018a4:	c9                   	leave  
  8018a5:	c3                   	ret    

008018a6 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  8018a6:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8018aa:	7e 38                	jle    8018e4 <writebuf+0x3e>
};


static void
writebuf(struct printbuf *b)
{
  8018ac:	55                   	push   %ebp
  8018ad:	89 e5                	mov    %esp,%ebp
  8018af:	53                   	push   %ebx
  8018b0:	83 ec 08             	sub    $0x8,%esp
  8018b3:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  8018b5:	ff 70 04             	pushl  0x4(%eax)
  8018b8:	8d 40 10             	lea    0x10(%eax),%eax
  8018bb:	50                   	push   %eax
  8018bc:	ff 33                	pushl  (%ebx)
  8018be:	e8 37 fc ff ff       	call   8014fa <write>
		if (result > 0)
  8018c3:	83 c4 10             	add    $0x10,%esp
  8018c6:	85 c0                	test   %eax,%eax
  8018c8:	7e 03                	jle    8018cd <writebuf+0x27>
			b->result += result;
  8018ca:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8018cd:	3b 43 04             	cmp    0x4(%ebx),%eax
  8018d0:	74 0e                	je     8018e0 <writebuf+0x3a>
			b->error = (result < 0 ? result : 0);
  8018d2:	89 c2                	mov    %eax,%edx
  8018d4:	85 c0                	test   %eax,%eax
  8018d6:	7e 05                	jle    8018dd <writebuf+0x37>
  8018d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8018dd:	89 53 0c             	mov    %edx,0xc(%ebx)
	}
}
  8018e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018e3:	c9                   	leave  
  8018e4:	c3                   	ret    

008018e5 <putch>:

static void
putch(int ch, void *thunk)
{
  8018e5:	55                   	push   %ebp
  8018e6:	89 e5                	mov    %esp,%ebp
  8018e8:	53                   	push   %ebx
  8018e9:	83 ec 04             	sub    $0x4,%esp
  8018ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8018ef:	8b 53 04             	mov    0x4(%ebx),%edx
  8018f2:	8d 42 01             	lea    0x1(%edx),%eax
  8018f5:	89 43 04             	mov    %eax,0x4(%ebx)
  8018f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018fb:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8018ff:	3d 00 01 00 00       	cmp    $0x100,%eax
  801904:	75 0e                	jne    801914 <putch+0x2f>
		writebuf(b);
  801906:	89 d8                	mov    %ebx,%eax
  801908:	e8 99 ff ff ff       	call   8018a6 <writebuf>
		b->idx = 0;
  80190d:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801914:	83 c4 04             	add    $0x4,%esp
  801917:	5b                   	pop    %ebx
  801918:	5d                   	pop    %ebp
  801919:	c3                   	ret    

0080191a <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  80191a:	55                   	push   %ebp
  80191b:	89 e5                	mov    %esp,%ebp
  80191d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  801923:	8b 45 08             	mov    0x8(%ebp),%eax
  801926:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  80192c:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801933:	00 00 00 
	b.result = 0;
  801936:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80193d:	00 00 00 
	b.error = 1;
  801940:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801947:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  80194a:	ff 75 10             	pushl  0x10(%ebp)
  80194d:	ff 75 0c             	pushl  0xc(%ebp)
  801950:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801956:	50                   	push   %eax
  801957:	68 e5 18 80 00       	push   $0x8018e5
  80195c:	e8 8c eb ff ff       	call   8004ed <vprintfmt>
	if (b.idx > 0)
  801961:	83 c4 10             	add    $0x10,%esp
  801964:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  80196b:	7e 0b                	jle    801978 <vfprintf+0x5e>
		writebuf(&b);
  80196d:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801973:	e8 2e ff ff ff       	call   8018a6 <writebuf>

	return (b.result ? b.result : b.error);
  801978:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80197e:	85 c0                	test   %eax,%eax
  801980:	75 06                	jne    801988 <vfprintf+0x6e>
  801982:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  801988:	c9                   	leave  
  801989:	c3                   	ret    

0080198a <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  80198a:	55                   	push   %ebp
  80198b:	89 e5                	mov    %esp,%ebp
  80198d:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801990:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801993:	50                   	push   %eax
  801994:	ff 75 0c             	pushl  0xc(%ebp)
  801997:	ff 75 08             	pushl  0x8(%ebp)
  80199a:	e8 7b ff ff ff       	call   80191a <vfprintf>
	va_end(ap);

	return cnt;
}
  80199f:	c9                   	leave  
  8019a0:	c3                   	ret    

008019a1 <printf>:

int
printf(const char *fmt, ...)
{
  8019a1:	55                   	push   %ebp
  8019a2:	89 e5                	mov    %esp,%ebp
  8019a4:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8019a7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  8019aa:	50                   	push   %eax
  8019ab:	ff 75 08             	pushl  0x8(%ebp)
  8019ae:	6a 01                	push   $0x1
  8019b0:	e8 65 ff ff ff       	call   80191a <vfprintf>
	va_end(ap);

	return cnt;
}
  8019b5:	c9                   	leave  
  8019b6:	c3                   	ret    

008019b7 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019b7:	55                   	push   %ebp
  8019b8:	89 e5                	mov    %esp,%ebp
  8019ba:	56                   	push   %esi
  8019bb:	53                   	push   %ebx
  8019bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019bf:	83 ec 0c             	sub    $0xc,%esp
  8019c2:	ff 75 08             	pushl  0x8(%ebp)
  8019c5:	e8 48 f7 ff ff       	call   801112 <fd2data>
  8019ca:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019cc:	83 c4 08             	add    $0x8,%esp
  8019cf:	68 8c 25 80 00       	push   $0x80258c
  8019d4:	53                   	push   %ebx
  8019d5:	e8 c7 f0 ff ff       	call   800aa1 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019da:	8b 46 04             	mov    0x4(%esi),%eax
  8019dd:	2b 06                	sub    (%esi),%eax
  8019df:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019e5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019ec:	00 00 00 
	stat->st_dev = &devpipe;
  8019ef:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  8019f6:	30 80 00 
	return 0;
}
  8019f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8019fe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a01:	5b                   	pop    %ebx
  801a02:	5e                   	pop    %esi
  801a03:	5d                   	pop    %ebp
  801a04:	c3                   	ret    

00801a05 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a05:	55                   	push   %ebp
  801a06:	89 e5                	mov    %esp,%ebp
  801a08:	53                   	push   %ebx
  801a09:	83 ec 0c             	sub    $0xc,%esp
  801a0c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a0f:	53                   	push   %ebx
  801a10:	6a 00                	push   $0x0
  801a12:	e8 7f f5 ff ff       	call   800f96 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a17:	89 1c 24             	mov    %ebx,(%esp)
  801a1a:	e8 f3 f6 ff ff       	call   801112 <fd2data>
  801a1f:	83 c4 08             	add    $0x8,%esp
  801a22:	50                   	push   %eax
  801a23:	6a 00                	push   $0x0
  801a25:	e8 6c f5 ff ff       	call   800f96 <sys_page_unmap>
}
  801a2a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a2d:	c9                   	leave  
  801a2e:	c3                   	ret    

00801a2f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a2f:	55                   	push   %ebp
  801a30:	89 e5                	mov    %esp,%ebp
  801a32:	57                   	push   %edi
  801a33:	56                   	push   %esi
  801a34:	53                   	push   %ebx
  801a35:	83 ec 1c             	sub    $0x1c,%esp
  801a38:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a3b:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a3d:	a1 04 44 80 00       	mov    0x804404,%eax
  801a42:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a45:	83 ec 0c             	sub    $0xc,%esp
  801a48:	ff 75 e0             	pushl  -0x20(%ebp)
  801a4b:	e8 fc 03 00 00       	call   801e4c <pageref>
  801a50:	89 c3                	mov    %eax,%ebx
  801a52:	89 3c 24             	mov    %edi,(%esp)
  801a55:	e8 f2 03 00 00       	call   801e4c <pageref>
  801a5a:	83 c4 10             	add    $0x10,%esp
  801a5d:	39 c3                	cmp    %eax,%ebx
  801a5f:	0f 94 c1             	sete   %cl
  801a62:	0f b6 c9             	movzbl %cl,%ecx
  801a65:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a68:	8b 15 04 44 80 00    	mov    0x804404,%edx
  801a6e:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a71:	39 ce                	cmp    %ecx,%esi
  801a73:	74 1b                	je     801a90 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a75:	39 c3                	cmp    %eax,%ebx
  801a77:	75 c4                	jne    801a3d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a79:	8b 42 58             	mov    0x58(%edx),%eax
  801a7c:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a7f:	50                   	push   %eax
  801a80:	56                   	push   %esi
  801a81:	68 93 25 80 00       	push   $0x802593
  801a86:	e8 2b e9 ff ff       	call   8003b6 <cprintf>
  801a8b:	83 c4 10             	add    $0x10,%esp
  801a8e:	eb ad                	jmp    801a3d <_pipeisclosed+0xe>
	}
}
  801a90:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a93:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a96:	5b                   	pop    %ebx
  801a97:	5e                   	pop    %esi
  801a98:	5f                   	pop    %edi
  801a99:	5d                   	pop    %ebp
  801a9a:	c3                   	ret    

00801a9b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a9b:	55                   	push   %ebp
  801a9c:	89 e5                	mov    %esp,%ebp
  801a9e:	57                   	push   %edi
  801a9f:	56                   	push   %esi
  801aa0:	53                   	push   %ebx
  801aa1:	83 ec 18             	sub    $0x18,%esp
  801aa4:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801aa7:	56                   	push   %esi
  801aa8:	e8 65 f6 ff ff       	call   801112 <fd2data>
  801aad:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801aaf:	83 c4 10             	add    $0x10,%esp
  801ab2:	bf 00 00 00 00       	mov    $0x0,%edi
  801ab7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801abb:	75 42                	jne    801aff <devpipe_write+0x64>
  801abd:	eb 4e                	jmp    801b0d <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801abf:	89 da                	mov    %ebx,%edx
  801ac1:	89 f0                	mov    %esi,%eax
  801ac3:	e8 67 ff ff ff       	call   801a2f <_pipeisclosed>
  801ac8:	85 c0                	test   %eax,%eax
  801aca:	75 46                	jne    801b12 <devpipe_write+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801acc:	e8 21 f4 ff ff       	call   800ef2 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ad1:	8b 53 04             	mov    0x4(%ebx),%edx
  801ad4:	8b 03                	mov    (%ebx),%eax
  801ad6:	83 c0 20             	add    $0x20,%eax
  801ad9:	39 c2                	cmp    %eax,%edx
  801adb:	73 e2                	jae    801abf <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801add:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ae0:	8a 0c 38             	mov    (%eax,%edi,1),%cl
  801ae3:	89 d0                	mov    %edx,%eax
  801ae5:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801aea:	79 05                	jns    801af1 <devpipe_write+0x56>
  801aec:	48                   	dec    %eax
  801aed:	83 c8 e0             	or     $0xffffffe0,%eax
  801af0:	40                   	inc    %eax
  801af1:	88 4c 03 08          	mov    %cl,0x8(%ebx,%eax,1)
		p->p_wpos++;
  801af5:	42                   	inc    %edx
  801af6:	89 53 04             	mov    %edx,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801af9:	47                   	inc    %edi
  801afa:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801afd:	74 0e                	je     801b0d <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801aff:	8b 53 04             	mov    0x4(%ebx),%edx
  801b02:	8b 03                	mov    (%ebx),%eax
  801b04:	83 c0 20             	add    $0x20,%eax
  801b07:	39 c2                	cmp    %eax,%edx
  801b09:	73 b4                	jae    801abf <devpipe_write+0x24>
  801b0b:	eb d0                	jmp    801add <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b0d:	8b 45 10             	mov    0x10(%ebp),%eax
  801b10:	eb 05                	jmp    801b17 <devpipe_write+0x7c>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b12:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b17:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b1a:	5b                   	pop    %ebx
  801b1b:	5e                   	pop    %esi
  801b1c:	5f                   	pop    %edi
  801b1d:	5d                   	pop    %ebp
  801b1e:	c3                   	ret    

00801b1f <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b1f:	55                   	push   %ebp
  801b20:	89 e5                	mov    %esp,%ebp
  801b22:	57                   	push   %edi
  801b23:	56                   	push   %esi
  801b24:	53                   	push   %ebx
  801b25:	83 ec 18             	sub    $0x18,%esp
  801b28:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b2b:	57                   	push   %edi
  801b2c:	e8 e1 f5 ff ff       	call   801112 <fd2data>
  801b31:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b33:	83 c4 10             	add    $0x10,%esp
  801b36:	be 00 00 00 00       	mov    $0x0,%esi
  801b3b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b3f:	75 3d                	jne    801b7e <devpipe_read+0x5f>
  801b41:	eb 48                	jmp    801b8b <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801b43:	89 f0                	mov    %esi,%eax
  801b45:	eb 4e                	jmp    801b95 <devpipe_read+0x76>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b47:	89 da                	mov    %ebx,%edx
  801b49:	89 f8                	mov    %edi,%eax
  801b4b:	e8 df fe ff ff       	call   801a2f <_pipeisclosed>
  801b50:	85 c0                	test   %eax,%eax
  801b52:	75 3c                	jne    801b90 <devpipe_read+0x71>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b54:	e8 99 f3 ff ff       	call   800ef2 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b59:	8b 03                	mov    (%ebx),%eax
  801b5b:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b5e:	74 e7                	je     801b47 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b60:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801b65:	79 05                	jns    801b6c <devpipe_read+0x4d>
  801b67:	48                   	dec    %eax
  801b68:	83 c8 e0             	or     $0xffffffe0,%eax
  801b6b:	40                   	inc    %eax
  801b6c:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801b70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b73:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801b76:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b78:	46                   	inc    %esi
  801b79:	39 75 10             	cmp    %esi,0x10(%ebp)
  801b7c:	74 0d                	je     801b8b <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
  801b7e:	8b 03                	mov    (%ebx),%eax
  801b80:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b83:	75 db                	jne    801b60 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b85:	85 f6                	test   %esi,%esi
  801b87:	75 ba                	jne    801b43 <devpipe_read+0x24>
  801b89:	eb bc                	jmp    801b47 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b8b:	8b 45 10             	mov    0x10(%ebp),%eax
  801b8e:	eb 05                	jmp    801b95 <devpipe_read+0x76>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b90:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b95:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b98:	5b                   	pop    %ebx
  801b99:	5e                   	pop    %esi
  801b9a:	5f                   	pop    %edi
  801b9b:	5d                   	pop    %ebp
  801b9c:	c3                   	ret    

00801b9d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b9d:	55                   	push   %ebp
  801b9e:	89 e5                	mov    %esp,%ebp
  801ba0:	56                   	push   %esi
  801ba1:	53                   	push   %ebx
  801ba2:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ba5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ba8:	50                   	push   %eax
  801ba9:	e8 7b f5 ff ff       	call   801129 <fd_alloc>
  801bae:	83 c4 10             	add    $0x10,%esp
  801bb1:	85 c0                	test   %eax,%eax
  801bb3:	0f 88 2a 01 00 00    	js     801ce3 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bb9:	83 ec 04             	sub    $0x4,%esp
  801bbc:	68 07 04 00 00       	push   $0x407
  801bc1:	ff 75 f4             	pushl  -0xc(%ebp)
  801bc4:	6a 00                	push   $0x0
  801bc6:	e8 46 f3 ff ff       	call   800f11 <sys_page_alloc>
  801bcb:	83 c4 10             	add    $0x10,%esp
  801bce:	85 c0                	test   %eax,%eax
  801bd0:	0f 88 0d 01 00 00    	js     801ce3 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801bd6:	83 ec 0c             	sub    $0xc,%esp
  801bd9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bdc:	50                   	push   %eax
  801bdd:	e8 47 f5 ff ff       	call   801129 <fd_alloc>
  801be2:	89 c3                	mov    %eax,%ebx
  801be4:	83 c4 10             	add    $0x10,%esp
  801be7:	85 c0                	test   %eax,%eax
  801be9:	0f 88 e2 00 00 00    	js     801cd1 <pipe+0x134>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bef:	83 ec 04             	sub    $0x4,%esp
  801bf2:	68 07 04 00 00       	push   $0x407
  801bf7:	ff 75 f0             	pushl  -0x10(%ebp)
  801bfa:	6a 00                	push   $0x0
  801bfc:	e8 10 f3 ff ff       	call   800f11 <sys_page_alloc>
  801c01:	89 c3                	mov    %eax,%ebx
  801c03:	83 c4 10             	add    $0x10,%esp
  801c06:	85 c0                	test   %eax,%eax
  801c08:	0f 88 c3 00 00 00    	js     801cd1 <pipe+0x134>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c0e:	83 ec 0c             	sub    $0xc,%esp
  801c11:	ff 75 f4             	pushl  -0xc(%ebp)
  801c14:	e8 f9 f4 ff ff       	call   801112 <fd2data>
  801c19:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c1b:	83 c4 0c             	add    $0xc,%esp
  801c1e:	68 07 04 00 00       	push   $0x407
  801c23:	50                   	push   %eax
  801c24:	6a 00                	push   $0x0
  801c26:	e8 e6 f2 ff ff       	call   800f11 <sys_page_alloc>
  801c2b:	89 c3                	mov    %eax,%ebx
  801c2d:	83 c4 10             	add    $0x10,%esp
  801c30:	85 c0                	test   %eax,%eax
  801c32:	0f 88 89 00 00 00    	js     801cc1 <pipe+0x124>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c38:	83 ec 0c             	sub    $0xc,%esp
  801c3b:	ff 75 f0             	pushl  -0x10(%ebp)
  801c3e:	e8 cf f4 ff ff       	call   801112 <fd2data>
  801c43:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c4a:	50                   	push   %eax
  801c4b:	6a 00                	push   $0x0
  801c4d:	56                   	push   %esi
  801c4e:	6a 00                	push   $0x0
  801c50:	e8 ff f2 ff ff       	call   800f54 <sys_page_map>
  801c55:	89 c3                	mov    %eax,%ebx
  801c57:	83 c4 20             	add    $0x20,%esp
  801c5a:	85 c0                	test   %eax,%eax
  801c5c:	78 55                	js     801cb3 <pipe+0x116>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c5e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c64:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c67:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c69:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c6c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c73:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c79:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c7c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c81:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c88:	83 ec 0c             	sub    $0xc,%esp
  801c8b:	ff 75 f4             	pushl  -0xc(%ebp)
  801c8e:	e8 6f f4 ff ff       	call   801102 <fd2num>
  801c93:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c96:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c98:	83 c4 04             	add    $0x4,%esp
  801c9b:	ff 75 f0             	pushl  -0x10(%ebp)
  801c9e:	e8 5f f4 ff ff       	call   801102 <fd2num>
  801ca3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ca6:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ca9:	83 c4 10             	add    $0x10,%esp
  801cac:	b8 00 00 00 00       	mov    $0x0,%eax
  801cb1:	eb 30                	jmp    801ce3 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801cb3:	83 ec 08             	sub    $0x8,%esp
  801cb6:	56                   	push   %esi
  801cb7:	6a 00                	push   $0x0
  801cb9:	e8 d8 f2 ff ff       	call   800f96 <sys_page_unmap>
  801cbe:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801cc1:	83 ec 08             	sub    $0x8,%esp
  801cc4:	ff 75 f0             	pushl  -0x10(%ebp)
  801cc7:	6a 00                	push   $0x0
  801cc9:	e8 c8 f2 ff ff       	call   800f96 <sys_page_unmap>
  801cce:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801cd1:	83 ec 08             	sub    $0x8,%esp
  801cd4:	ff 75 f4             	pushl  -0xc(%ebp)
  801cd7:	6a 00                	push   $0x0
  801cd9:	e8 b8 f2 ff ff       	call   800f96 <sys_page_unmap>
  801cde:	83 c4 10             	add    $0x10,%esp
  801ce1:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  801ce3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ce6:	5b                   	pop    %ebx
  801ce7:	5e                   	pop    %esi
  801ce8:	5d                   	pop    %ebp
  801ce9:	c3                   	ret    

00801cea <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801cea:	55                   	push   %ebp
  801ceb:	89 e5                	mov    %esp,%ebp
  801ced:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cf0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cf3:	50                   	push   %eax
  801cf4:	ff 75 08             	pushl  0x8(%ebp)
  801cf7:	e8 a1 f4 ff ff       	call   80119d <fd_lookup>
  801cfc:	83 c4 10             	add    $0x10,%esp
  801cff:	85 c0                	test   %eax,%eax
  801d01:	78 18                	js     801d1b <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d03:	83 ec 0c             	sub    $0xc,%esp
  801d06:	ff 75 f4             	pushl  -0xc(%ebp)
  801d09:	e8 04 f4 ff ff       	call   801112 <fd2data>
	return _pipeisclosed(fd, p);
  801d0e:	89 c2                	mov    %eax,%edx
  801d10:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d13:	e8 17 fd ff ff       	call   801a2f <_pipeisclosed>
  801d18:	83 c4 10             	add    $0x10,%esp
}
  801d1b:	c9                   	leave  
  801d1c:	c3                   	ret    

00801d1d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801d1d:	55                   	push   %ebp
  801d1e:	89 e5                	mov    %esp,%ebp
  801d20:	56                   	push   %esi
  801d21:	53                   	push   %ebx
  801d22:	8b 75 08             	mov    0x8(%ebp),%esi
  801d25:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d28:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");
	int r;
    if (pg != NULL) {
  801d2b:	85 c0                	test   %eax,%eax
  801d2d:	74 0e                	je     801d3d <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  801d2f:	83 ec 0c             	sub    $0xc,%esp
  801d32:	50                   	push   %eax
  801d33:	e8 89 f3 ff ff       	call   8010c1 <sys_ipc_recv>
  801d38:	83 c4 10             	add    $0x10,%esp
  801d3b:	eb 10                	jmp    801d4d <ipc_recv+0x30>
    } else {
        r = sys_ipc_recv((void *) UTOP);
  801d3d:	83 ec 0c             	sub    $0xc,%esp
  801d40:	68 00 00 c0 ee       	push   $0xeec00000
  801d45:	e8 77 f3 ff ff       	call   8010c1 <sys_ipc_recv>
  801d4a:	83 c4 10             	add    $0x10,%esp
    }
    if (r < 0) {
  801d4d:	85 c0                	test   %eax,%eax
  801d4f:	79 16                	jns    801d67 <ipc_recv+0x4a>
        // failed
        if (from_env_store != NULL) *from_env_store = 0;
  801d51:	85 f6                	test   %esi,%esi
  801d53:	74 06                	je     801d5b <ipc_recv+0x3e>
  801d55:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL) *perm_store = 0;
  801d5b:	85 db                	test   %ebx,%ebx
  801d5d:	74 2c                	je     801d8b <ipc_recv+0x6e>
  801d5f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801d65:	eb 24                	jmp    801d8b <ipc_recv+0x6e>
        return r;
    } else {
        if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801d67:	85 f6                	test   %esi,%esi
  801d69:	74 0a                	je     801d75 <ipc_recv+0x58>
  801d6b:	a1 04 44 80 00       	mov    0x804404,%eax
  801d70:	8b 40 74             	mov    0x74(%eax),%eax
  801d73:	89 06                	mov    %eax,(%esi)
        if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801d75:	85 db                	test   %ebx,%ebx
  801d77:	74 0a                	je     801d83 <ipc_recv+0x66>
  801d79:	a1 04 44 80 00       	mov    0x804404,%eax
  801d7e:	8b 40 78             	mov    0x78(%eax),%eax
  801d81:	89 03                	mov    %eax,(%ebx)
        return thisenv->env_ipc_value;
  801d83:	a1 04 44 80 00       	mov    0x804404,%eax
  801d88:	8b 40 70             	mov    0x70(%eax),%eax
    }
 
	return 0;
}
  801d8b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d8e:	5b                   	pop    %ebx
  801d8f:	5e                   	pop    %esi
  801d90:	5d                   	pop    %ebp
  801d91:	c3                   	ret    

00801d92 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801d92:	55                   	push   %ebp
  801d93:	89 e5                	mov    %esp,%ebp
  801d95:	57                   	push   %edi
  801d96:	56                   	push   %esi
  801d97:	53                   	push   %ebx
  801d98:	83 ec 0c             	sub    $0xc,%esp
  801d9b:	8b 75 10             	mov    0x10(%ebp),%esi
  801d9e:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;
    if (pg == NULL) pg = (void *)UTOP;
  801da1:	85 f6                	test   %esi,%esi
  801da3:	75 05                	jne    801daa <ipc_send+0x18>
  801da5:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
  801daa:	57                   	push   %edi
  801dab:	56                   	push   %esi
  801dac:	ff 75 0c             	pushl  0xc(%ebp)
  801daf:	ff 75 08             	pushl  0x8(%ebp)
  801db2:	e8 e7 f2 ff ff       	call   80109e <sys_ipc_try_send>
  801db7:	89 c3                	mov    %eax,%ebx
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
  801db9:	83 c4 10             	add    $0x10,%esp
  801dbc:	85 c0                	test   %eax,%eax
  801dbe:	79 17                	jns    801dd7 <ipc_send+0x45>
  801dc0:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801dc3:	74 1d                	je     801de2 <ipc_send+0x50>
  801dc5:	50                   	push   %eax
  801dc6:	68 ab 25 80 00       	push   $0x8025ab
  801dcb:	6a 40                	push   $0x40
  801dcd:	68 bf 25 80 00       	push   $0x8025bf
  801dd2:	e8 07 e5 ff ff       	call   8002de <_panic>
        sys_yield();
  801dd7:	e8 16 f1 ff ff       	call   800ef2 <sys_yield>
    } while (r != 0);
  801ddc:	85 db                	test   %ebx,%ebx
  801dde:	75 ca                	jne    801daa <ipc_send+0x18>
  801de0:	eb 07                	jmp    801de9 <ipc_send+0x57>
	int r;
    if (pg == NULL) pg = (void *)UTOP;
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
        sys_yield();
  801de2:	e8 0b f1 ff ff       	call   800ef2 <sys_yield>
  801de7:	eb c1                	jmp    801daa <ipc_send+0x18>
    } while (r != 0);
}
  801de9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dec:	5b                   	pop    %ebx
  801ded:	5e                   	pop    %esi
  801dee:	5f                   	pop    %edi
  801def:	5d                   	pop    %ebp
  801df0:	c3                   	ret    

00801df1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801df1:	55                   	push   %ebp
  801df2:	89 e5                	mov    %esp,%ebp
  801df4:	53                   	push   %ebx
  801df5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801df8:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801dfd:	39 c1                	cmp    %eax,%ecx
  801dff:	74 21                	je     801e22 <ipc_find_env+0x31>
  801e01:	ba 01 00 00 00       	mov    $0x1,%edx
  801e06:	8d 1c 95 00 00 00 00 	lea    0x0(,%edx,4),%ebx
  801e0d:	89 d0                	mov    %edx,%eax
  801e0f:	c1 e0 07             	shl    $0x7,%eax
  801e12:	29 d8                	sub    %ebx,%eax
  801e14:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801e19:	8b 40 50             	mov    0x50(%eax),%eax
  801e1c:	39 c8                	cmp    %ecx,%eax
  801e1e:	75 1b                	jne    801e3b <ipc_find_env+0x4a>
  801e20:	eb 05                	jmp    801e27 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801e22:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801e27:	8d 04 95 00 00 00 00 	lea    0x0(,%edx,4),%eax
  801e2e:	c1 e2 07             	shl    $0x7,%edx
  801e31:	29 c2                	sub    %eax,%edx
  801e33:	8b 82 48 00 c0 ee    	mov    -0x113fffb8(%edx),%eax
  801e39:	eb 0e                	jmp    801e49 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801e3b:	42                   	inc    %edx
  801e3c:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  801e42:	75 c2                	jne    801e06 <ipc_find_env+0x15>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801e44:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e49:	5b                   	pop    %ebx
  801e4a:	5d                   	pop    %ebp
  801e4b:	c3                   	ret    

00801e4c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801e4c:	55                   	push   %ebp
  801e4d:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e4f:	8b 45 08             	mov    0x8(%ebp),%eax
  801e52:	c1 e8 16             	shr    $0x16,%eax
  801e55:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801e5c:	a8 01                	test   $0x1,%al
  801e5e:	74 21                	je     801e81 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801e60:	8b 45 08             	mov    0x8(%ebp),%eax
  801e63:	c1 e8 0c             	shr    $0xc,%eax
  801e66:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801e6d:	a8 01                	test   $0x1,%al
  801e6f:	74 17                	je     801e88 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801e71:	c1 e8 0c             	shr    $0xc,%eax
  801e74:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801e7b:	ef 
  801e7c:	0f b7 c0             	movzwl %ax,%eax
  801e7f:	eb 0c                	jmp    801e8d <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801e81:	b8 00 00 00 00       	mov    $0x0,%eax
  801e86:	eb 05                	jmp    801e8d <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801e88:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801e8d:	5d                   	pop    %ebp
  801e8e:	c3                   	ret    
  801e8f:	90                   	nop

00801e90 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801e90:	55                   	push   %ebp
  801e91:	57                   	push   %edi
  801e92:	56                   	push   %esi
  801e93:	53                   	push   %ebx
  801e94:	83 ec 1c             	sub    $0x1c,%esp
  801e97:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801e9b:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801e9f:	8b 7c 24 38          	mov    0x38(%esp),%edi
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801ea3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ea7:	89 ca                	mov    %ecx,%edx
  const DWunion dd = {.ll = d};
  801ea9:	89 f8                	mov    %edi,%eax
  801eab:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801eaf:	85 f6                	test   %esi,%esi
  801eb1:	75 2d                	jne    801ee0 <__udivdi3+0x50>
    {
      if (d0 > n1)
  801eb3:	39 cf                	cmp    %ecx,%edi
  801eb5:	77 65                	ja     801f1c <__udivdi3+0x8c>
  801eb7:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801eb9:	85 ff                	test   %edi,%edi
  801ebb:	75 0b                	jne    801ec8 <__udivdi3+0x38>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801ebd:	b8 01 00 00 00       	mov    $0x1,%eax
  801ec2:	31 d2                	xor    %edx,%edx
  801ec4:	f7 f7                	div    %edi
  801ec6:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801ec8:	31 d2                	xor    %edx,%edx
  801eca:	89 c8                	mov    %ecx,%eax
  801ecc:	f7 f5                	div    %ebp
  801ece:	89 c1                	mov    %eax,%ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801ed0:	89 d8                	mov    %ebx,%eax
  801ed2:	f7 f5                	div    %ebp
  801ed4:	89 cf                	mov    %ecx,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801ed6:	89 fa                	mov    %edi,%edx
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
  801ee0:	39 ce                	cmp    %ecx,%esi
  801ee2:	77 28                	ja     801f0c <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801ee4:	0f bd fe             	bsr    %esi,%edi
	  if (bm == 0)
  801ee7:	83 f7 1f             	xor    $0x1f,%edi
  801eea:	75 40                	jne    801f2c <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801eec:	39 ce                	cmp    %ecx,%esi
  801eee:	72 0a                	jb     801efa <__udivdi3+0x6a>
  801ef0:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801ef4:	0f 87 9e 00 00 00    	ja     801f98 <__udivdi3+0x108>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801efa:	b8 01 00 00 00       	mov    $0x1,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801eff:	89 fa                	mov    %edi,%edx
  801f01:	83 c4 1c             	add    $0x1c,%esp
  801f04:	5b                   	pop    %ebx
  801f05:	5e                   	pop    %esi
  801f06:	5f                   	pop    %edi
  801f07:	5d                   	pop    %ebp
  801f08:	c3                   	ret    
  801f09:	8d 76 00             	lea    0x0(%esi),%esi
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801f0c:	31 ff                	xor    %edi,%edi
  801f0e:	31 c0                	xor    %eax,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801f10:	89 fa                	mov    %edi,%edx
  801f12:	83 c4 1c             	add    $0x1c,%esp
  801f15:	5b                   	pop    %ebx
  801f16:	5e                   	pop    %esi
  801f17:	5f                   	pop    %edi
  801f18:	5d                   	pop    %ebp
  801f19:	c3                   	ret    
  801f1a:	66 90                	xchg   %ax,%ax
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801f1c:	89 d8                	mov    %ebx,%eax
  801f1e:	f7 f7                	div    %edi
  801f20:	31 ff                	xor    %edi,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801f22:	89 fa                	mov    %edi,%edx
  801f24:	83 c4 1c             	add    $0x1c,%esp
  801f27:	5b                   	pop    %ebx
  801f28:	5e                   	pop    %esi
  801f29:	5f                   	pop    %edi
  801f2a:	5d                   	pop    %ebp
  801f2b:	c3                   	ret    
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801f2c:	bd 20 00 00 00       	mov    $0x20,%ebp
  801f31:	89 eb                	mov    %ebp,%ebx
  801f33:	29 fb                	sub    %edi,%ebx

	      d1 = (d1 << bm) | (d0 >> b);
  801f35:	89 f9                	mov    %edi,%ecx
  801f37:	d3 e6                	shl    %cl,%esi
  801f39:	89 c5                	mov    %eax,%ebp
  801f3b:	88 d9                	mov    %bl,%cl
  801f3d:	d3 ed                	shr    %cl,%ebp
  801f3f:	89 e9                	mov    %ebp,%ecx
  801f41:	09 f1                	or     %esi,%ecx
  801f43:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
	      d0 = d0 << bm;
  801f47:	89 f9                	mov    %edi,%ecx
  801f49:	d3 e0                	shl    %cl,%eax
  801f4b:	89 c5                	mov    %eax,%ebp
	      n2 = n1 >> b;
  801f4d:	89 d6                	mov    %edx,%esi
  801f4f:	88 d9                	mov    %bl,%cl
  801f51:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
  801f53:	89 f9                	mov    %edi,%ecx
  801f55:	d3 e2                	shl    %cl,%edx
  801f57:	8b 44 24 08          	mov    0x8(%esp),%eax
  801f5b:	88 d9                	mov    %bl,%cl
  801f5d:	d3 e8                	shr    %cl,%eax
  801f5f:	09 c2                	or     %eax,%edx
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801f61:	89 d0                	mov    %edx,%eax
  801f63:	89 f2                	mov    %esi,%edx
  801f65:	f7 74 24 0c          	divl   0xc(%esp)
  801f69:	89 d6                	mov    %edx,%esi
  801f6b:	89 c3                	mov    %eax,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  801f6d:	f7 e5                	mul    %ebp

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801f6f:	39 d6                	cmp    %edx,%esi
  801f71:	72 19                	jb     801f8c <__udivdi3+0xfc>
  801f73:	74 0b                	je     801f80 <__udivdi3+0xf0>
  801f75:	89 d8                	mov    %ebx,%eax
  801f77:	31 ff                	xor    %edi,%edi
  801f79:	e9 58 ff ff ff       	jmp    801ed6 <__udivdi3+0x46>
  801f7e:	66 90                	xchg   %ax,%ax
  801f80:	8b 54 24 08          	mov    0x8(%esp),%edx
  801f84:	89 f9                	mov    %edi,%ecx
  801f86:	d3 e2                	shl    %cl,%edx
  801f88:	39 c2                	cmp    %eax,%edx
  801f8a:	73 e9                	jae    801f75 <__udivdi3+0xe5>
  801f8c:	8d 43 ff             	lea    -0x1(%ebx),%eax
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801f8f:	31 ff                	xor    %edi,%edi
  801f91:	e9 40 ff ff ff       	jmp    801ed6 <__udivdi3+0x46>
  801f96:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801f98:	31 c0                	xor    %eax,%eax
  801f9a:	e9 37 ff ff ff       	jmp    801ed6 <__udivdi3+0x46>
  801f9f:	90                   	nop

00801fa0 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801fa0:	55                   	push   %ebp
  801fa1:	57                   	push   %edi
  801fa2:	56                   	push   %esi
  801fa3:	53                   	push   %ebx
  801fa4:	83 ec 1c             	sub    $0x1c,%esp
  801fa7:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801fab:	8b 74 24 34          	mov    0x34(%esp),%esi
  801faf:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fb3:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801fb7:	89 44 24 0c          	mov    %eax,0xc(%esp)
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801fbb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801fbf:	89 f3                	mov    %esi,%ebx
  const DWunion dd = {.ll = d};
  801fc1:	89 fa                	mov    %edi,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801fc3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  n1 = nn.s.high;
  801fc7:	89 34 24             	mov    %esi,(%esp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801fca:	85 c0                	test   %eax,%eax
  801fcc:	75 1a                	jne    801fe8 <__umoddi3+0x48>
    {
      if (d0 > n1)
  801fce:	39 f7                	cmp    %esi,%edi
  801fd0:	0f 86 a2 00 00 00    	jbe    802078 <__umoddi3+0xd8>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801fd6:	89 c8                	mov    %ecx,%eax
  801fd8:	89 f2                	mov    %esi,%edx
  801fda:	f7 f7                	div    %edi
  801fdc:	89 d0                	mov    %edx,%eax

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801fde:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801fe0:	83 c4 1c             	add    $0x1c,%esp
  801fe3:	5b                   	pop    %ebx
  801fe4:	5e                   	pop    %esi
  801fe5:	5f                   	pop    %edi
  801fe6:	5d                   	pop    %ebp
  801fe7:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801fe8:	39 f0                	cmp    %esi,%eax
  801fea:	0f 87 ac 00 00 00    	ja     80209c <__umoddi3+0xfc>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801ff0:	0f bd e8             	bsr    %eax,%ebp
	  if (bm == 0)
  801ff3:	83 f5 1f             	xor    $0x1f,%ebp
  801ff6:	0f 84 ac 00 00 00    	je     8020a8 <__umoddi3+0x108>
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801ffc:	bf 20 00 00 00       	mov    $0x20,%edi
  802001:	29 ef                	sub    %ebp,%edi
  802003:	89 fe                	mov    %edi,%esi
  802005:	89 7c 24 0c          	mov    %edi,0xc(%esp)

	      d1 = (d1 << bm) | (d0 >> b);
  802009:	89 e9                	mov    %ebp,%ecx
  80200b:	d3 e0                	shl    %cl,%eax
  80200d:	89 d7                	mov    %edx,%edi
  80200f:	89 f1                	mov    %esi,%ecx
  802011:	d3 ef                	shr    %cl,%edi
  802013:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  802015:	89 e9                	mov    %ebp,%ecx
  802017:	d3 e2                	shl    %cl,%edx
  802019:	89 14 24             	mov    %edx,(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80201c:	89 d8                	mov    %ebx,%eax
  80201e:	d3 e0                	shl    %cl,%eax
  802020:	89 c2                	mov    %eax,%edx
	      n0 = n0 << bm;
  802022:	8b 44 24 08          	mov    0x8(%esp),%eax
  802026:	d3 e0                	shl    %cl,%eax
  802028:	89 44 24 04          	mov    %eax,0x4(%esp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80202c:	8b 44 24 08          	mov    0x8(%esp),%eax
  802030:	89 f1                	mov    %esi,%ecx
  802032:	d3 e8                	shr    %cl,%eax
  802034:	09 d0                	or     %edx,%eax
  802036:	d3 eb                	shr    %cl,%ebx
  802038:	89 da                	mov    %ebx,%edx
  80203a:	f7 f7                	div    %edi
  80203c:	89 d3                	mov    %edx,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  80203e:	f7 24 24             	mull   (%esp)
  802041:	89 c6                	mov    %eax,%esi
  802043:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802045:	39 d3                	cmp    %edx,%ebx
  802047:	0f 82 87 00 00 00    	jb     8020d4 <__umoddi3+0x134>
  80204d:	0f 84 91 00 00 00    	je     8020e4 <__umoddi3+0x144>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802053:	8b 54 24 04          	mov    0x4(%esp),%edx
  802057:	29 f2                	sub    %esi,%edx
  802059:	19 cb                	sbb    %ecx,%ebx
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80205b:	89 d8                	mov    %ebx,%eax
  80205d:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  802061:	d3 e0                	shl    %cl,%eax
  802063:	89 e9                	mov    %ebp,%ecx
  802065:	d3 ea                	shr    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802067:	09 d0                	or     %edx,%eax
  802069:	89 e9                	mov    %ebp,%ecx
  80206b:	d3 eb                	shr    %cl,%ebx
  80206d:	89 da                	mov    %ebx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80206f:	83 c4 1c             	add    $0x1c,%esp
  802072:	5b                   	pop    %ebx
  802073:	5e                   	pop    %esi
  802074:	5f                   	pop    %edi
  802075:	5d                   	pop    %ebp
  802076:	c3                   	ret    
  802077:	90                   	nop
  802078:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80207a:	85 ff                	test   %edi,%edi
  80207c:	75 0b                	jne    802089 <__umoddi3+0xe9>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80207e:	b8 01 00 00 00       	mov    $0x1,%eax
  802083:	31 d2                	xor    %edx,%edx
  802085:	f7 f7                	div    %edi
  802087:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802089:	89 f0                	mov    %esi,%eax
  80208b:	31 d2                	xor    %edx,%edx
  80208d:	f7 f5                	div    %ebp
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80208f:	89 c8                	mov    %ecx,%eax
  802091:	f7 f5                	div    %ebp
  802093:	89 d0                	mov    %edx,%eax
  802095:	e9 44 ff ff ff       	jmp    801fde <__umoddi3+0x3e>
  80209a:	66 90                	xchg   %ax,%ax
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  80209c:	89 c8                	mov    %ecx,%eax
  80209e:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8020a0:	83 c4 1c             	add    $0x1c,%esp
  8020a3:	5b                   	pop    %ebx
  8020a4:	5e                   	pop    %esi
  8020a5:	5f                   	pop    %edi
  8020a6:	5d                   	pop    %ebp
  8020a7:	c3                   	ret    

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8020a8:	3b 04 24             	cmp    (%esp),%eax
  8020ab:	72 06                	jb     8020b3 <__umoddi3+0x113>
  8020ad:	3b 7c 24 04          	cmp    0x4(%esp),%edi
  8020b1:	77 0f                	ja     8020c2 <__umoddi3+0x122>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8020b3:	89 f2                	mov    %esi,%edx
  8020b5:	29 f9                	sub    %edi,%ecx
  8020b7:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  8020bb:	89 14 24             	mov    %edx,(%esp)
  8020be:	89 4c 24 04          	mov    %ecx,0x4(%esp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8020c2:	8b 44 24 04          	mov    0x4(%esp),%eax
  8020c6:	8b 14 24             	mov    (%esp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8020c9:	83 c4 1c             	add    $0x1c,%esp
  8020cc:	5b                   	pop    %ebx
  8020cd:	5e                   	pop    %esi
  8020ce:	5f                   	pop    %edi
  8020cf:	5d                   	pop    %ebp
  8020d0:	c3                   	ret    
  8020d1:	8d 76 00             	lea    0x0(%esi),%esi
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8020d4:	2b 04 24             	sub    (%esp),%eax
  8020d7:	19 fa                	sbb    %edi,%edx
  8020d9:	89 d1                	mov    %edx,%ecx
  8020db:	89 c6                	mov    %eax,%esi
  8020dd:	e9 71 ff ff ff       	jmp    802053 <__umoddi3+0xb3>
  8020e2:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8020e4:	39 44 24 04          	cmp    %eax,0x4(%esp)
  8020e8:	72 ea                	jb     8020d4 <__umoddi3+0x134>
  8020ea:	89 d9                	mov    %ebx,%ecx
  8020ec:	e9 62 ff ff ff       	jmp    802053 <__umoddi3+0xb3>
