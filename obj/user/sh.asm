
obj/user/sh.debug:     file format elf32-i386


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
  80002c:	e8 9e 09 00 00       	call   8009cf <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <_gettoken>:
#define WHITESPACE " \t\r\n"
#define SYMBOLS "<|>&;()"

int
_gettoken(char *s, char **p1, char **p2)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 0c             	sub    $0xc,%esp
  80003c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80003f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int t;

	if (s == 0) {
  800042:	85 db                	test   %ebx,%ebx
  800044:	75 27                	jne    80006d <_gettoken+0x3a>
		if (debug > 1)
  800046:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  80004d:	0f 8e 36 01 00 00    	jle    800189 <_gettoken+0x156>
			cprintf("GETTOKEN NULL\n");
  800053:	83 ec 0c             	sub    $0xc,%esp
  800056:	68 40 33 80 00       	push   $0x803340
  80005b:	e8 b0 0a 00 00       	call   800b10 <cprintf>
  800060:	83 c4 10             	add    $0x10,%esp
		return 0;
  800063:	b8 00 00 00 00       	mov    $0x0,%eax
  800068:	e9 33 01 00 00       	jmp    8001a0 <_gettoken+0x16d>
	}

	if (debug > 1)
  80006d:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800074:	7e 11                	jle    800087 <_gettoken+0x54>
		cprintf("GETTOKEN: %s\n", s);
  800076:	83 ec 08             	sub    $0x8,%esp
  800079:	53                   	push   %ebx
  80007a:	68 4f 33 80 00       	push   $0x80334f
  80007f:	e8 8c 0a 00 00       	call   800b10 <cprintf>
  800084:	83 c4 10             	add    $0x10,%esp

	*p1 = 0;
  800087:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
	*p2 = 0;
  80008d:	8b 45 10             	mov    0x10(%ebp),%eax
  800090:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	while (strchr(WHITESPACE, *s))
  800096:	eb 05                	jmp    80009d <_gettoken+0x6a>
		*s++ = 0;
  800098:	43                   	inc    %ebx
  800099:	c6 43 ff 00          	movb   $0x0,-0x1(%ebx)
		cprintf("GETTOKEN: %s\n", s);

	*p1 = 0;
	*p2 = 0;

	while (strchr(WHITESPACE, *s))
  80009d:	83 ec 08             	sub    $0x8,%esp
  8000a0:	0f be 03             	movsbl (%ebx),%eax
  8000a3:	50                   	push   %eax
  8000a4:	68 5d 33 80 00       	push   $0x80335d
  8000a9:	e8 75 12 00 00       	call   801323 <strchr>
  8000ae:	83 c4 10             	add    $0x10,%esp
  8000b1:	85 c0                	test   %eax,%eax
  8000b3:	75 e3                	jne    800098 <_gettoken+0x65>
		*s++ = 0;
	if (*s == 0) {
  8000b5:	8a 03                	mov    (%ebx),%al
  8000b7:	84 c0                	test   %al,%al
  8000b9:	75 27                	jne    8000e2 <_gettoken+0xaf>
		if (debug > 1)
  8000bb:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  8000c2:	0f 8e c8 00 00 00    	jle    800190 <_gettoken+0x15d>
			cprintf("EOL\n");
  8000c8:	83 ec 0c             	sub    $0xc,%esp
  8000cb:	68 62 33 80 00       	push   $0x803362
  8000d0:	e8 3b 0a 00 00       	call   800b10 <cprintf>
  8000d5:	83 c4 10             	add    $0x10,%esp
		return 0;
  8000d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8000dd:	e9 be 00 00 00       	jmp    8001a0 <_gettoken+0x16d>
	}
	if (strchr(SYMBOLS, *s)) {
  8000e2:	83 ec 08             	sub    $0x8,%esp
  8000e5:	0f be c0             	movsbl %al,%eax
  8000e8:	50                   	push   %eax
  8000e9:	68 73 33 80 00       	push   $0x803373
  8000ee:	e8 30 12 00 00       	call   801323 <strchr>
  8000f3:	83 c4 10             	add    $0x10,%esp
  8000f6:	85 c0                	test   %eax,%eax
  8000f8:	74 30                	je     80012a <_gettoken+0xf7>
		t = *s;
  8000fa:	0f be 33             	movsbl (%ebx),%esi
		*p1 = s;
  8000fd:	89 1f                	mov    %ebx,(%edi)
		*s++ = 0;
  8000ff:	c6 03 00             	movb   $0x0,(%ebx)
		*p2 = s;
  800102:	43                   	inc    %ebx
  800103:	8b 45 10             	mov    0x10(%ebp),%eax
  800106:	89 18                	mov    %ebx,(%eax)
		if (debug > 1)
  800108:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  80010f:	0f 8e 82 00 00 00    	jle    800197 <_gettoken+0x164>
			cprintf("TOK %c\n", t);
  800115:	83 ec 08             	sub    $0x8,%esp
  800118:	56                   	push   %esi
  800119:	68 67 33 80 00       	push   $0x803367
  80011e:	e8 ed 09 00 00       	call   800b10 <cprintf>
  800123:	83 c4 10             	add    $0x10,%esp
		return t;
  800126:	89 f0                	mov    %esi,%eax
  800128:	eb 76                	jmp    8001a0 <_gettoken+0x16d>
	}
	*p1 = s;
  80012a:	89 1f                	mov    %ebx,(%edi)
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  80012c:	8a 03                	mov    (%ebx),%al
  80012e:	84 c0                	test   %al,%al
  800130:	75 09                	jne    80013b <_gettoken+0x108>
  800132:	eb 1f                	jmp    800153 <_gettoken+0x120>
		s++;
  800134:	43                   	inc    %ebx
		if (debug > 1)
			cprintf("TOK %c\n", t);
		return t;
	}
	*p1 = s;
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  800135:	8a 03                	mov    (%ebx),%al
  800137:	84 c0                	test   %al,%al
  800139:	74 18                	je     800153 <_gettoken+0x120>
  80013b:	83 ec 08             	sub    $0x8,%esp
  80013e:	0f be c0             	movsbl %al,%eax
  800141:	50                   	push   %eax
  800142:	68 6f 33 80 00       	push   $0x80336f
  800147:	e8 d7 11 00 00       	call   801323 <strchr>
  80014c:	83 c4 10             	add    $0x10,%esp
  80014f:	85 c0                	test   %eax,%eax
  800151:	74 e1                	je     800134 <_gettoken+0x101>
		s++;
	*p2 = s;
  800153:	8b 45 10             	mov    0x10(%ebp),%eax
  800156:	89 18                	mov    %ebx,(%eax)
	if (debug > 1) {
  800158:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  80015f:	7e 3a                	jle    80019b <_gettoken+0x168>
		t = **p2;
  800161:	0f b6 33             	movzbl (%ebx),%esi
		**p2 = 0;
  800164:	c6 03 00             	movb   $0x0,(%ebx)
		cprintf("WORD: %s\n", *p1);
  800167:	83 ec 08             	sub    $0x8,%esp
  80016a:	ff 37                	pushl  (%edi)
  80016c:	68 7b 33 80 00       	push   $0x80337b
  800171:	e8 9a 09 00 00       	call   800b10 <cprintf>
		**p2 = t;
  800176:	8b 45 10             	mov    0x10(%ebp),%eax
  800179:	8b 00                	mov    (%eax),%eax
  80017b:	89 f2                	mov    %esi,%edx
  80017d:	88 10                	mov    %dl,(%eax)
  80017f:	83 c4 10             	add    $0x10,%esp
	}
	return 'w';
  800182:	b8 77 00 00 00       	mov    $0x77,%eax
  800187:	eb 17                	jmp    8001a0 <_gettoken+0x16d>
	int t;

	if (s == 0) {
		if (debug > 1)
			cprintf("GETTOKEN NULL\n");
		return 0;
  800189:	b8 00 00 00 00       	mov    $0x0,%eax
  80018e:	eb 10                	jmp    8001a0 <_gettoken+0x16d>
	while (strchr(WHITESPACE, *s))
		*s++ = 0;
	if (*s == 0) {
		if (debug > 1)
			cprintf("EOL\n");
		return 0;
  800190:	b8 00 00 00 00       	mov    $0x0,%eax
  800195:	eb 09                	jmp    8001a0 <_gettoken+0x16d>
		*p1 = s;
		*s++ = 0;
		*p2 = s;
		if (debug > 1)
			cprintf("TOK %c\n", t);
		return t;
  800197:	89 f0                	mov    %esi,%eax
  800199:	eb 05                	jmp    8001a0 <_gettoken+0x16d>
		t = **p2;
		**p2 = 0;
		cprintf("WORD: %s\n", *p1);
		**p2 = t;
	}
	return 'w';
  80019b:	b8 77 00 00 00       	mov    $0x77,%eax
}
  8001a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a3:	5b                   	pop    %ebx
  8001a4:	5e                   	pop    %esi
  8001a5:	5f                   	pop    %edi
  8001a6:	5d                   	pop    %ebp
  8001a7:	c3                   	ret    

008001a8 <gettoken>:

int
gettoken(char *s, char **p1)
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	83 ec 08             	sub    $0x8,%esp
  8001ae:	8b 45 08             	mov    0x8(%ebp),%eax
	static int c, nc;
	static char* np1, *np2;

	if (s) {
  8001b1:	85 c0                	test   %eax,%eax
  8001b3:	74 22                	je     8001d7 <gettoken+0x2f>
		nc = _gettoken(s, &np1, &np2);
  8001b5:	83 ec 04             	sub    $0x4,%esp
  8001b8:	68 0c 50 80 00       	push   $0x80500c
  8001bd:	68 10 50 80 00       	push   $0x805010
  8001c2:	50                   	push   %eax
  8001c3:	e8 6b fe ff ff       	call   800033 <_gettoken>
  8001c8:	a3 08 50 80 00       	mov    %eax,0x805008
		return 0;
  8001cd:	83 c4 10             	add    $0x10,%esp
  8001d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8001d5:	eb 3a                	jmp    800211 <gettoken+0x69>
	}
	c = nc;
  8001d7:	a1 08 50 80 00       	mov    0x805008,%eax
  8001dc:	a3 04 50 80 00       	mov    %eax,0x805004
	*p1 = np1;
  8001e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001e4:	8b 15 10 50 80 00    	mov    0x805010,%edx
  8001ea:	89 10                	mov    %edx,(%eax)
	nc = _gettoken(np2, &np1, &np2);
  8001ec:	83 ec 04             	sub    $0x4,%esp
  8001ef:	68 0c 50 80 00       	push   $0x80500c
  8001f4:	68 10 50 80 00       	push   $0x805010
  8001f9:	ff 35 0c 50 80 00    	pushl  0x80500c
  8001ff:	e8 2f fe ff ff       	call   800033 <_gettoken>
  800204:	a3 08 50 80 00       	mov    %eax,0x805008
	return c;
  800209:	a1 04 50 80 00       	mov    0x805004,%eax
  80020e:	83 c4 10             	add    $0x10,%esp
}
  800211:	c9                   	leave  
  800212:	c3                   	ret    

00800213 <runcmd>:
// runcmd() is called in a forked child,
// so it's OK to manipulate file descriptor state.
#define MAXARGS 16
void
runcmd(char* s)
{
  800213:	55                   	push   %ebp
  800214:	89 e5                	mov    %esp,%ebp
  800216:	57                   	push   %edi
  800217:	56                   	push   %esi
  800218:	53                   	push   %ebx
  800219:	81 ec 64 04 00 00    	sub    $0x464,%esp
	char *argv[MAXARGS], *t, argv0buf[BUFSIZ];
	int argc, c, i, r, p[2], fd, pipe_child;

	pipe_child = 0;
	gettoken(s, 0);
  80021f:	6a 00                	push   $0x0
  800221:	ff 75 08             	pushl  0x8(%ebp)
  800224:	e8 7f ff ff ff       	call   8001a8 <gettoken>
  800229:	83 c4 10             	add    $0x10,%esp

again:
	argc = 0;
	while (1) {
		switch ((c = gettoken(0, &t))) {
  80022c:	8d 5d a4             	lea    -0x5c(%ebp),%ebx

	pipe_child = 0;
	gettoken(s, 0);

again:
	argc = 0;
  80022f:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		switch ((c = gettoken(0, &t))) {
  800234:	83 ec 08             	sub    $0x8,%esp
  800237:	53                   	push   %ebx
  800238:	6a 00                	push   $0x0
  80023a:	e8 69 ff ff ff       	call   8001a8 <gettoken>
  80023f:	83 c4 10             	add    $0x10,%esp
  800242:	83 f8 3e             	cmp    $0x3e,%eax
  800245:	0f 84 cc 00 00 00    	je     800317 <runcmd+0x104>
  80024b:	83 f8 3e             	cmp    $0x3e,%eax
  80024e:	7f 12                	jg     800262 <runcmd+0x4f>
  800250:	85 c0                	test   %eax,%eax
  800252:	0f 84 3b 02 00 00    	je     800493 <runcmd+0x280>
  800258:	83 f8 3c             	cmp    $0x3c,%eax
  80025b:	74 3e                	je     80029b <runcmd+0x88>
  80025d:	e9 1f 02 00 00       	jmp    800481 <runcmd+0x26e>
  800262:	83 f8 77             	cmp    $0x77,%eax
  800265:	74 0e                	je     800275 <runcmd+0x62>
  800267:	83 f8 7c             	cmp    $0x7c,%eax
  80026a:	0f 84 25 01 00 00    	je     800395 <runcmd+0x182>
  800270:	e9 0c 02 00 00       	jmp    800481 <runcmd+0x26e>

		case 'w':	// Add an argument
			if (argc == MAXARGS) {
  800275:	83 fe 10             	cmp    $0x10,%esi
  800278:	75 15                	jne    80028f <runcmd+0x7c>
				cprintf("too many arguments\n");
  80027a:	83 ec 0c             	sub    $0xc,%esp
  80027d:	68 85 33 80 00       	push   $0x803385
  800282:	e8 89 08 00 00       	call   800b10 <cprintf>
				exit();
  800287:	e8 92 07 00 00       	call   800a1e <exit>
  80028c:	83 c4 10             	add    $0x10,%esp
			}
			argv[argc++] = t;
  80028f:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  800292:	89 44 b5 a8          	mov    %eax,-0x58(%ebp,%esi,4)
  800296:	8d 76 01             	lea    0x1(%esi),%esi
			break;
  800299:	eb 99                	jmp    800234 <runcmd+0x21>

		case '<':	// Input redirection
			// Grab the filename from the argument list
			if (gettoken(0, &t) != 'w') {
  80029b:	83 ec 08             	sub    $0x8,%esp
  80029e:	53                   	push   %ebx
  80029f:	6a 00                	push   $0x0
  8002a1:	e8 02 ff ff ff       	call   8001a8 <gettoken>
  8002a6:	83 c4 10             	add    $0x10,%esp
  8002a9:	83 f8 77             	cmp    $0x77,%eax
  8002ac:	74 15                	je     8002c3 <runcmd+0xb0>
				cprintf("syntax error: < not followed by word\n");
  8002ae:	83 ec 0c             	sub    $0xc,%esp
  8002b1:	68 d8 34 80 00       	push   $0x8034d8
  8002b6:	e8 55 08 00 00       	call   800b10 <cprintf>
				exit();
  8002bb:	e8 5e 07 00 00       	call   800a1e <exit>
  8002c0:	83 c4 10             	add    $0x10,%esp
			}
			if ((fd = open(t, O_RDONLY)) < 0) {
  8002c3:	83 ec 08             	sub    $0x8,%esp
  8002c6:	6a 00                	push   $0x0
  8002c8:	ff 75 a4             	pushl  -0x5c(%ebp)
  8002cb:	e8 db 20 00 00       	call   8023ab <open>
  8002d0:	89 c7                	mov    %eax,%edi
  8002d2:	83 c4 10             	add    $0x10,%esp
  8002d5:	85 c0                	test   %eax,%eax
  8002d7:	79 1b                	jns    8002f4 <runcmd+0xe1>
				cprintf("open %s for read: %e", t, fd);
  8002d9:	83 ec 04             	sub    $0x4,%esp
  8002dc:	50                   	push   %eax
  8002dd:	ff 75 a4             	pushl  -0x5c(%ebp)
  8002e0:	68 99 33 80 00       	push   $0x803399
  8002e5:	e8 26 08 00 00       	call   800b10 <cprintf>
				exit();
  8002ea:	e8 2f 07 00 00       	call   800a1e <exit>
  8002ef:	83 c4 10             	add    $0x10,%esp
  8002f2:	eb 08                	jmp    8002fc <runcmd+0xe9>
			}
			if (fd != 0) {
  8002f4:	85 c0                	test   %eax,%eax
  8002f6:	0f 84 38 ff ff ff    	je     800234 <runcmd+0x21>
				dup(fd, 0);
  8002fc:	83 ec 08             	sub    $0x8,%esp
  8002ff:	6a 00                	push   $0x0
  800301:	57                   	push   %edi
  800302:	e8 b9 1b 00 00       	call   801ec0 <dup>
				close(fd);
  800307:	89 3c 24             	mov    %edi,(%esp)
  80030a:	e8 63 1b 00 00       	call   801e72 <close>
  80030f:	83 c4 10             	add    $0x10,%esp
  800312:	e9 1d ff ff ff       	jmp    800234 <runcmd+0x21>
			}
			break;

		case '>':	// Output redirection
			// Grab the filename from the argument list
			if (gettoken(0, &t) != 'w') {
  800317:	83 ec 08             	sub    $0x8,%esp
  80031a:	53                   	push   %ebx
  80031b:	6a 00                	push   $0x0
  80031d:	e8 86 fe ff ff       	call   8001a8 <gettoken>
  800322:	83 c4 10             	add    $0x10,%esp
  800325:	83 f8 77             	cmp    $0x77,%eax
  800328:	74 15                	je     80033f <runcmd+0x12c>
				cprintf("syntax error: > not followed by word\n");
  80032a:	83 ec 0c             	sub    $0xc,%esp
  80032d:	68 00 35 80 00       	push   $0x803500
  800332:	e8 d9 07 00 00       	call   800b10 <cprintf>
				exit();
  800337:	e8 e2 06 00 00       	call   800a1e <exit>
  80033c:	83 c4 10             	add    $0x10,%esp
			}
			if ((fd = open(t, O_WRONLY|O_CREAT|O_TRUNC)) < 0) {
  80033f:	83 ec 08             	sub    $0x8,%esp
  800342:	68 01 03 00 00       	push   $0x301
  800347:	ff 75 a4             	pushl  -0x5c(%ebp)
  80034a:	e8 5c 20 00 00       	call   8023ab <open>
  80034f:	89 c7                	mov    %eax,%edi
  800351:	83 c4 10             	add    $0x10,%esp
  800354:	85 c0                	test   %eax,%eax
  800356:	79 19                	jns    800371 <runcmd+0x15e>
				cprintf("open %s for write: %e", t, fd);
  800358:	83 ec 04             	sub    $0x4,%esp
  80035b:	50                   	push   %eax
  80035c:	ff 75 a4             	pushl  -0x5c(%ebp)
  80035f:	68 ae 33 80 00       	push   $0x8033ae
  800364:	e8 a7 07 00 00       	call   800b10 <cprintf>
				exit();
  800369:	e8 b0 06 00 00       	call   800a1e <exit>
  80036e:	83 c4 10             	add    $0x10,%esp
			}
			if (fd != 1) {
  800371:	83 ff 01             	cmp    $0x1,%edi
  800374:	0f 84 ba fe ff ff    	je     800234 <runcmd+0x21>
				dup(fd, 1);
  80037a:	83 ec 08             	sub    $0x8,%esp
  80037d:	6a 01                	push   $0x1
  80037f:	57                   	push   %edi
  800380:	e8 3b 1b 00 00       	call   801ec0 <dup>
				close(fd);
  800385:	89 3c 24             	mov    %edi,(%esp)
  800388:	e8 e5 1a 00 00       	call   801e72 <close>
  80038d:	83 c4 10             	add    $0x10,%esp
  800390:	e9 9f fe ff ff       	jmp    800234 <runcmd+0x21>
			}
			break;

		case '|':	// Pipe
			if ((r = pipe(p)) < 0) {
  800395:	83 ec 0c             	sub    $0xc,%esp
  800398:	8d 85 9c fb ff ff    	lea    -0x464(%ebp),%eax
  80039e:	50                   	push   %eax
  80039f:	e8 19 29 00 00       	call   802cbd <pipe>
  8003a4:	83 c4 10             	add    $0x10,%esp
  8003a7:	85 c0                	test   %eax,%eax
  8003a9:	79 16                	jns    8003c1 <runcmd+0x1ae>
				cprintf("pipe: %e", r);
  8003ab:	83 ec 08             	sub    $0x8,%esp
  8003ae:	50                   	push   %eax
  8003af:	68 c4 33 80 00       	push   $0x8033c4
  8003b4:	e8 57 07 00 00       	call   800b10 <cprintf>
				exit();
  8003b9:	e8 60 06 00 00       	call   800a1e <exit>
  8003be:	83 c4 10             	add    $0x10,%esp
			}
			if (debug)
  8003c1:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8003c8:	74 1c                	je     8003e6 <runcmd+0x1d3>
				cprintf("PIPE: %d %d\n", p[0], p[1]);
  8003ca:	83 ec 04             	sub    $0x4,%esp
  8003cd:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  8003d3:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  8003d9:	68 cd 33 80 00       	push   $0x8033cd
  8003de:	e8 2d 07 00 00       	call   800b10 <cprintf>
  8003e3:	83 c4 10             	add    $0x10,%esp
			if ((r = fork()) < 0) {
  8003e6:	e8 60 15 00 00       	call   80194b <fork>
  8003eb:	89 c7                	mov    %eax,%edi
  8003ed:	85 c0                	test   %eax,%eax
  8003ef:	79 16                	jns    800407 <runcmd+0x1f4>
				cprintf("fork: %e", r);
  8003f1:	83 ec 08             	sub    $0x8,%esp
  8003f4:	50                   	push   %eax
  8003f5:	68 da 33 80 00       	push   $0x8033da
  8003fa:	e8 11 07 00 00       	call   800b10 <cprintf>
				exit();
  8003ff:	e8 1a 06 00 00       	call   800a1e <exit>
  800404:	83 c4 10             	add    $0x10,%esp
			}
			if (r == 0) {
  800407:	85 ff                	test   %edi,%edi
  800409:	75 3c                	jne    800447 <runcmd+0x234>
				if (p[0] != 0) {
  80040b:	8b 85 9c fb ff ff    	mov    -0x464(%ebp),%eax
  800411:	85 c0                	test   %eax,%eax
  800413:	74 1c                	je     800431 <runcmd+0x21e>
					dup(p[0], 0);
  800415:	83 ec 08             	sub    $0x8,%esp
  800418:	6a 00                	push   $0x0
  80041a:	50                   	push   %eax
  80041b:	e8 a0 1a 00 00       	call   801ec0 <dup>
					close(p[0]);
  800420:	83 c4 04             	add    $0x4,%esp
  800423:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  800429:	e8 44 1a 00 00       	call   801e72 <close>
  80042e:	83 c4 10             	add    $0x10,%esp
				}
				close(p[1]);
  800431:	83 ec 0c             	sub    $0xc,%esp
  800434:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  80043a:	e8 33 1a 00 00       	call   801e72 <close>
				goto again;
  80043f:	83 c4 10             	add    $0x10,%esp
  800442:	e9 e8 fd ff ff       	jmp    80022f <runcmd+0x1c>
			} else {
				pipe_child = r;
				if (p[1] != 1) {
  800447:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  80044d:	83 f8 01             	cmp    $0x1,%eax
  800450:	74 1c                	je     80046e <runcmd+0x25b>
					dup(p[1], 1);
  800452:	83 ec 08             	sub    $0x8,%esp
  800455:	6a 01                	push   $0x1
  800457:	50                   	push   %eax
  800458:	e8 63 1a 00 00       	call   801ec0 <dup>
					close(p[1]);
  80045d:	83 c4 04             	add    $0x4,%esp
  800460:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  800466:	e8 07 1a 00 00       	call   801e72 <close>
  80046b:	83 c4 10             	add    $0x10,%esp
				}
				close(p[0]);
  80046e:	83 ec 0c             	sub    $0xc,%esp
  800471:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  800477:	e8 f6 19 00 00       	call   801e72 <close>
				goto runit;
  80047c:	83 c4 10             	add    $0x10,%esp
  80047f:	eb 17                	jmp    800498 <runcmd+0x285>
		case 0:		// String is complete
			// Run the current command!
			goto runit;

		default:
			panic("bad return %d from gettoken", c);
  800481:	50                   	push   %eax
  800482:	68 e3 33 80 00       	push   $0x8033e3
  800487:	6a 6e                	push   $0x6e
  800489:	68 ff 33 80 00       	push   $0x8033ff
  80048e:	e8 a5 05 00 00       	call   800a38 <_panic>
runcmd(char* s)
{
	char *argv[MAXARGS], *t, argv0buf[BUFSIZ];
	int argc, c, i, r, p[2], fd, pipe_child;

	pipe_child = 0;
  800493:	bf 00 00 00 00       	mov    $0x0,%edi
		}
	}

runit:
	// Return immediately if command line was empty.
	if(argc == 0) {
  800498:	85 f6                	test   %esi,%esi
  80049a:	75 22                	jne    8004be <runcmd+0x2ab>
		if (debug)
  80049c:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8004a3:	0f 84 9b 01 00 00    	je     800644 <runcmd+0x431>
			cprintf("EMPTY COMMAND\n");
  8004a9:	83 ec 0c             	sub    $0xc,%esp
  8004ac:	68 09 34 80 00       	push   $0x803409
  8004b1:	e8 5a 06 00 00       	call   800b10 <cprintf>
  8004b6:	83 c4 10             	add    $0x10,%esp
  8004b9:	e9 86 01 00 00       	jmp    800644 <runcmd+0x431>

	// Clean up command line.
	// Read all commands from the filesystem: add an initial '/' to
	// the command name.
	// This essentially acts like 'PATH=/'.
	if (argv[0][0] != '/') {
  8004be:	8b 45 a8             	mov    -0x58(%ebp),%eax
  8004c1:	80 38 2f             	cmpb   $0x2f,(%eax)
  8004c4:	74 23                	je     8004e9 <runcmd+0x2d6>
		argv0buf[0] = '/';
  8004c6:	c6 85 a4 fb ff ff 2f 	movb   $0x2f,-0x45c(%ebp)
		strcpy(argv0buf + 1, argv[0]);
  8004cd:	83 ec 08             	sub    $0x8,%esp
  8004d0:	50                   	push   %eax
  8004d1:	8d 9d a4 fb ff ff    	lea    -0x45c(%ebp),%ebx
  8004d7:	8d 85 a5 fb ff ff    	lea    -0x45b(%ebp),%eax
  8004dd:	50                   	push   %eax
  8004de:	e8 18 0d 00 00       	call   8011fb <strcpy>
		argv[0] = argv0buf;
  8004e3:	89 5d a8             	mov    %ebx,-0x58(%ebp)
  8004e6:	83 c4 10             	add    $0x10,%esp
	}
	argv[argc] = 0;
  8004e9:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
  8004f0:	00 

	// Print the command.
	if (debug) {
  8004f1:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8004f8:	74 4e                	je     800548 <runcmd+0x335>
		cprintf("[%08x] SPAWN:", thisenv->env_id);
  8004fa:	a1 24 54 80 00       	mov    0x805424,%eax
  8004ff:	8b 40 48             	mov    0x48(%eax),%eax
  800502:	83 ec 08             	sub    $0x8,%esp
  800505:	50                   	push   %eax
  800506:	68 18 34 80 00       	push   $0x803418
  80050b:	e8 00 06 00 00       	call   800b10 <cprintf>
		for (i = 0; argv[i]; i++)
  800510:	8b 45 a8             	mov    -0x58(%ebp),%eax
  800513:	83 c4 10             	add    $0x10,%esp
  800516:	85 c0                	test   %eax,%eax
  800518:	74 1e                	je     800538 <runcmd+0x325>
  80051a:	8d 5d ac             	lea    -0x54(%ebp),%ebx
			cprintf(" %s", argv[i]);
  80051d:	83 ec 08             	sub    $0x8,%esp
  800520:	50                   	push   %eax
  800521:	68 a0 34 80 00       	push   $0x8034a0
  800526:	e8 e5 05 00 00       	call   800b10 <cprintf>
  80052b:	83 c3 04             	add    $0x4,%ebx
	argv[argc] = 0;

	// Print the command.
	if (debug) {
		cprintf("[%08x] SPAWN:", thisenv->env_id);
		for (i = 0; argv[i]; i++)
  80052e:	8b 43 fc             	mov    -0x4(%ebx),%eax
  800531:	83 c4 10             	add    $0x10,%esp
  800534:	85 c0                	test   %eax,%eax
  800536:	75 e5                	jne    80051d <runcmd+0x30a>
			cprintf(" %s", argv[i]);
		cprintf("\n");
  800538:	83 ec 0c             	sub    $0xc,%esp
  80053b:	68 60 33 80 00       	push   $0x803360
  800540:	e8 cb 05 00 00       	call   800b10 <cprintf>
  800545:	83 c4 10             	add    $0x10,%esp
	}

	// Spawn the command!
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
  800548:	83 ec 08             	sub    $0x8,%esp
  80054b:	8d 45 a8             	lea    -0x58(%ebp),%eax
  80054e:	50                   	push   %eax
  80054f:	ff 75 a8             	pushl  -0x58(%ebp)
  800552:	e8 ec 1f 00 00       	call   802543 <spawn>
  800557:	89 c3                	mov    %eax,%ebx
  800559:	83 c4 10             	add    $0x10,%esp
  80055c:	85 c0                	test   %eax,%eax
  80055e:	0f 89 c3 00 00 00    	jns    800627 <runcmd+0x414>
		cprintf("spawn %s: %e\n", argv[0], r);
  800564:	83 ec 04             	sub    $0x4,%esp
  800567:	50                   	push   %eax
  800568:	ff 75 a8             	pushl  -0x58(%ebp)
  80056b:	68 26 34 80 00       	push   $0x803426
  800570:	e8 9b 05 00 00       	call   800b10 <cprintf>

	// In the parent, close all file descriptors and wait for the
	// spawned command to exit.
	close_all();
  800575:	e8 23 19 00 00       	call   801e9d <close_all>
  80057a:	83 c4 10             	add    $0x10,%esp
  80057d:	eb 4c                	jmp    8005cb <runcmd+0x3b8>
	if (r >= 0) {
		if (debug)
			cprintf("[%08x] WAIT %s %08x\n", thisenv->env_id, argv[0], r);
  80057f:	a1 24 54 80 00       	mov    0x805424,%eax
  800584:	8b 40 48             	mov    0x48(%eax),%eax
  800587:	53                   	push   %ebx
  800588:	ff 75 a8             	pushl  -0x58(%ebp)
  80058b:	50                   	push   %eax
  80058c:	68 34 34 80 00       	push   $0x803434
  800591:	e8 7a 05 00 00       	call   800b10 <cprintf>
  800596:	83 c4 10             	add    $0x10,%esp
		wait(r);
  800599:	83 ec 0c             	sub    $0xc,%esp
  80059c:	53                   	push   %ebx
  80059d:	e8 9b 28 00 00       	call   802e3d <wait>
		if (debug)
  8005a2:	83 c4 10             	add    $0x10,%esp
  8005a5:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8005ac:	0f 84 8c 00 00 00    	je     80063e <runcmd+0x42b>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  8005b2:	a1 24 54 80 00       	mov    0x805424,%eax
  8005b7:	8b 40 48             	mov    0x48(%eax),%eax
  8005ba:	83 ec 08             	sub    $0x8,%esp
  8005bd:	50                   	push   %eax
  8005be:	68 49 34 80 00       	push   $0x803449
  8005c3:	e8 48 05 00 00       	call   800b10 <cprintf>
  8005c8:	83 c4 10             	add    $0x10,%esp
	}

	// If we were the left-hand part of a pipe,
	// wait for the right-hand part to finish.
	if (pipe_child) {
  8005cb:	85 ff                	test   %edi,%edi
  8005cd:	74 51                	je     800620 <runcmd+0x40d>
		if (debug)
  8005cf:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8005d6:	74 1a                	je     8005f2 <runcmd+0x3df>
			cprintf("[%08x] WAIT pipe_child %08x\n", thisenv->env_id, pipe_child);
  8005d8:	a1 24 54 80 00       	mov    0x805424,%eax
  8005dd:	8b 40 48             	mov    0x48(%eax),%eax
  8005e0:	83 ec 04             	sub    $0x4,%esp
  8005e3:	57                   	push   %edi
  8005e4:	50                   	push   %eax
  8005e5:	68 5f 34 80 00       	push   $0x80345f
  8005ea:	e8 21 05 00 00       	call   800b10 <cprintf>
  8005ef:	83 c4 10             	add    $0x10,%esp
		wait(pipe_child);
  8005f2:	83 ec 0c             	sub    $0xc,%esp
  8005f5:	57                   	push   %edi
  8005f6:	e8 42 28 00 00       	call   802e3d <wait>
		if (debug)
  8005fb:	83 c4 10             	add    $0x10,%esp
  8005fe:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800605:	74 19                	je     800620 <runcmd+0x40d>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  800607:	a1 24 54 80 00       	mov    0x805424,%eax
  80060c:	8b 40 48             	mov    0x48(%eax),%eax
  80060f:	83 ec 08             	sub    $0x8,%esp
  800612:	50                   	push   %eax
  800613:	68 49 34 80 00       	push   $0x803449
  800618:	e8 f3 04 00 00       	call   800b10 <cprintf>
  80061d:	83 c4 10             	add    $0x10,%esp
	}

	// Done!
	exit();
  800620:	e8 f9 03 00 00       	call   800a1e <exit>
  800625:	eb 1d                	jmp    800644 <runcmd+0x431>
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
		cprintf("spawn %s: %e\n", argv[0], r);

	// In the parent, close all file descriptors and wait for the
	// spawned command to exit.
	close_all();
  800627:	e8 71 18 00 00       	call   801e9d <close_all>
	if (r >= 0) {
		if (debug)
  80062c:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800633:	0f 84 60 ff ff ff    	je     800599 <runcmd+0x386>
  800639:	e9 41 ff ff ff       	jmp    80057f <runcmd+0x36c>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
	}

	// If we were the left-hand part of a pipe,
	// wait for the right-hand part to finish.
	if (pipe_child) {
  80063e:	85 ff                	test   %edi,%edi
  800640:	75 b0                	jne    8005f2 <runcmd+0x3df>
  800642:	eb dc                	jmp    800620 <runcmd+0x40d>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
	}

	// Done!
	exit();
}
  800644:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800647:	5b                   	pop    %ebx
  800648:	5e                   	pop    %esi
  800649:	5f                   	pop    %edi
  80064a:	5d                   	pop    %ebp
  80064b:	c3                   	ret    

0080064c <usage>:
}


void
usage(void)
{
  80064c:	55                   	push   %ebp
  80064d:	89 e5                	mov    %esp,%ebp
  80064f:	83 ec 14             	sub    $0x14,%esp
	cprintf("usage: sh [-dix] [command-file]\n");
  800652:	68 28 35 80 00       	push   $0x803528
  800657:	e8 b4 04 00 00       	call   800b10 <cprintf>
	exit();
  80065c:	e8 bd 03 00 00       	call   800a1e <exit>
}
  800661:	83 c4 10             	add    $0x10,%esp
  800664:	c9                   	leave  
  800665:	c3                   	ret    

00800666 <umain>:

void
umain(int argc, char **argv)
{
  800666:	55                   	push   %ebp
  800667:	89 e5                	mov    %esp,%ebp
  800669:	57                   	push   %edi
  80066a:	56                   	push   %esi
  80066b:	53                   	push   %ebx
  80066c:	83 ec 30             	sub    $0x30,%esp
  80066f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
  800672:	8d 45 d8             	lea    -0x28(%ebp),%eax
  800675:	50                   	push   %eax
  800676:	57                   	push   %edi
  800677:	8d 45 08             	lea    0x8(%ebp),%eax
  80067a:	50                   	push   %eax
  80067b:	e8 b7 14 00 00       	call   801b37 <argstart>
	while ((r = argnext(&args)) >= 0)
  800680:	83 c4 10             	add    $0x10,%esp
{
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
  800683:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
umain(int argc, char **argv)
{
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
  80068a:	be 3f 00 00 00       	mov    $0x3f,%esi
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
  80068f:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  800692:	eb 2e                	jmp    8006c2 <umain+0x5c>
		switch (r) {
  800694:	83 f8 69             	cmp    $0x69,%eax
  800697:	74 24                	je     8006bd <umain+0x57>
  800699:	83 f8 78             	cmp    $0x78,%eax
  80069c:	74 07                	je     8006a5 <umain+0x3f>
  80069e:	83 f8 64             	cmp    $0x64,%eax
  8006a1:	75 13                	jne    8006b6 <umain+0x50>
  8006a3:	eb 09                	jmp    8006ae <umain+0x48>
			break;
		case 'i':
			interactive = 1;
			break;
		case 'x':
			echocmds = 1;
  8006a5:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  8006ac:	eb 14                	jmp    8006c2 <umain+0x5c>
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
		switch (r) {
		case 'd':
			debug++;
  8006ae:	ff 05 00 50 80 00    	incl   0x805000
			break;
  8006b4:	eb 0c                	jmp    8006c2 <umain+0x5c>
			break;
		case 'x':
			echocmds = 1;
			break;
		default:
			usage();
  8006b6:	e8 91 ff ff ff       	call   80064c <usage>
  8006bb:	eb 05                	jmp    8006c2 <umain+0x5c>
		switch (r) {
		case 'd':
			debug++;
			break;
		case 'i':
			interactive = 1;
  8006bd:	be 01 00 00 00       	mov    $0x1,%esi
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
  8006c2:	83 ec 0c             	sub    $0xc,%esp
  8006c5:	53                   	push   %ebx
  8006c6:	e8 a5 14 00 00       	call   801b70 <argnext>
  8006cb:	83 c4 10             	add    $0x10,%esp
  8006ce:	85 c0                	test   %eax,%eax
  8006d0:	79 c2                	jns    800694 <umain+0x2e>
			break;
		default:
			usage();
		}

	if (argc > 2)
  8006d2:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  8006d6:	7e 05                	jle    8006dd <umain+0x77>
		usage();
  8006d8:	e8 6f ff ff ff       	call   80064c <usage>
	if (argc == 2) {
  8006dd:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  8006e1:	75 56                	jne    800739 <umain+0xd3>
		close(0);
  8006e3:	83 ec 0c             	sub    $0xc,%esp
  8006e6:	6a 00                	push   $0x0
  8006e8:	e8 85 17 00 00       	call   801e72 <close>
		if ((r = open(argv[1], O_RDONLY)) < 0)
  8006ed:	83 c4 08             	add    $0x8,%esp
  8006f0:	6a 00                	push   $0x0
  8006f2:	ff 77 04             	pushl  0x4(%edi)
  8006f5:	e8 b1 1c 00 00       	call   8023ab <open>
  8006fa:	83 c4 10             	add    $0x10,%esp
  8006fd:	85 c0                	test   %eax,%eax
  8006ff:	79 1b                	jns    80071c <umain+0xb6>
			panic("open %s: %e", argv[1], r);
  800701:	83 ec 0c             	sub    $0xc,%esp
  800704:	50                   	push   %eax
  800705:	ff 77 04             	pushl  0x4(%edi)
  800708:	68 7c 34 80 00       	push   $0x80347c
  80070d:	68 1e 01 00 00       	push   $0x11e
  800712:	68 ff 33 80 00       	push   $0x8033ff
  800717:	e8 1c 03 00 00       	call   800a38 <_panic>
		assert(r == 0);
  80071c:	85 c0                	test   %eax,%eax
  80071e:	74 19                	je     800739 <umain+0xd3>
  800720:	68 88 34 80 00       	push   $0x803488
  800725:	68 8f 34 80 00       	push   $0x80348f
  80072a:	68 1f 01 00 00       	push   $0x11f
  80072f:	68 ff 33 80 00       	push   $0x8033ff
  800734:	e8 ff 02 00 00       	call   800a38 <_panic>
	}
	if (interactive == '?')
  800739:	83 fe 3f             	cmp    $0x3f,%esi
  80073c:	75 0f                	jne    80074d <umain+0xe7>
		interactive = iscons(0);
  80073e:	83 ec 0c             	sub    $0xc,%esp
  800741:	6a 00                	push   $0x0
  800743:	e8 09 02 00 00       	call   800951 <iscons>
  800748:	89 c6                	mov    %eax,%esi
  80074a:	83 c4 10             	add    $0x10,%esp
  80074d:	85 f6                	test   %esi,%esi
  80074f:	74 07                	je     800758 <umain+0xf2>
  800751:	bf a4 34 80 00       	mov    $0x8034a4,%edi
  800756:	eb 05                	jmp    80075d <umain+0xf7>
  800758:	bf 00 00 00 00       	mov    $0x0,%edi

	while (1) {
		char *buf;

		buf = readline(interactive ? "$ " : NULL);
  80075d:	83 ec 0c             	sub    $0xc,%esp
  800760:	57                   	push   %edi
  800761:	e8 38 09 00 00       	call   80109e <readline>
  800766:	89 c3                	mov    %eax,%ebx
		if (buf == NULL) {
  800768:	83 c4 10             	add    $0x10,%esp
  80076b:	85 c0                	test   %eax,%eax
  80076d:	75 1e                	jne    80078d <umain+0x127>
			if (debug)
  80076f:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800776:	74 10                	je     800788 <umain+0x122>
				cprintf("EXITING\n");
  800778:	83 ec 0c             	sub    $0xc,%esp
  80077b:	68 a7 34 80 00       	push   $0x8034a7
  800780:	e8 8b 03 00 00       	call   800b10 <cprintf>
  800785:	83 c4 10             	add    $0x10,%esp
			exit();	// end of file
  800788:	e8 91 02 00 00       	call   800a1e <exit>
		}
		if (debug)
  80078d:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800794:	74 11                	je     8007a7 <umain+0x141>
			cprintf("LINE: %s\n", buf);
  800796:	83 ec 08             	sub    $0x8,%esp
  800799:	53                   	push   %ebx
  80079a:	68 b0 34 80 00       	push   $0x8034b0
  80079f:	e8 6c 03 00 00       	call   800b10 <cprintf>
  8007a4:	83 c4 10             	add    $0x10,%esp
		if (buf[0] == '#')
  8007a7:	80 3b 23             	cmpb   $0x23,(%ebx)
  8007aa:	74 b1                	je     80075d <umain+0xf7>
			continue;
		if (echocmds)
  8007ac:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8007b0:	74 11                	je     8007c3 <umain+0x15d>
			printf("# %s\n", buf);
  8007b2:	83 ec 08             	sub    $0x8,%esp
  8007b5:	53                   	push   %ebx
  8007b6:	68 ba 34 80 00       	push   $0x8034ba
  8007bb:	e8 6d 1d 00 00       	call   80252d <printf>
  8007c0:	83 c4 10             	add    $0x10,%esp
		if (debug)
  8007c3:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8007ca:	74 10                	je     8007dc <umain+0x176>
			cprintf("BEFORE FORK\n");
  8007cc:	83 ec 0c             	sub    $0xc,%esp
  8007cf:	68 c0 34 80 00       	push   $0x8034c0
  8007d4:	e8 37 03 00 00       	call   800b10 <cprintf>
  8007d9:	83 c4 10             	add    $0x10,%esp
		if ((r = fork()) < 0)
  8007dc:	e8 6a 11 00 00       	call   80194b <fork>
  8007e1:	89 c6                	mov    %eax,%esi
  8007e3:	85 c0                	test   %eax,%eax
  8007e5:	79 15                	jns    8007fc <umain+0x196>
			panic("fork: %e", r);
  8007e7:	50                   	push   %eax
  8007e8:	68 da 33 80 00       	push   $0x8033da
  8007ed:	68 36 01 00 00       	push   $0x136
  8007f2:	68 ff 33 80 00       	push   $0x8033ff
  8007f7:	e8 3c 02 00 00       	call   800a38 <_panic>
		if (debug)
  8007fc:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800803:	74 11                	je     800816 <umain+0x1b0>
			cprintf("FORK: %d\n", r);
  800805:	83 ec 08             	sub    $0x8,%esp
  800808:	50                   	push   %eax
  800809:	68 cd 34 80 00       	push   $0x8034cd
  80080e:	e8 fd 02 00 00       	call   800b10 <cprintf>
  800813:	83 c4 10             	add    $0x10,%esp
		if (r == 0) {
  800816:	85 f6                	test   %esi,%esi
  800818:	75 16                	jne    800830 <umain+0x1ca>
			runcmd(buf);
  80081a:	83 ec 0c             	sub    $0xc,%esp
  80081d:	53                   	push   %ebx
  80081e:	e8 f0 f9 ff ff       	call   800213 <runcmd>
			exit();
  800823:	e8 f6 01 00 00       	call   800a1e <exit>
  800828:	83 c4 10             	add    $0x10,%esp
  80082b:	e9 2d ff ff ff       	jmp    80075d <umain+0xf7>
		} else
			wait(r);
  800830:	83 ec 0c             	sub    $0xc,%esp
  800833:	56                   	push   %esi
  800834:	e8 04 26 00 00       	call   802e3d <wait>
  800839:	83 c4 10             	add    $0x10,%esp
  80083c:	e9 1c ff ff ff       	jmp    80075d <umain+0xf7>

00800841 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800841:	55                   	push   %ebp
  800842:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800844:	b8 00 00 00 00       	mov    $0x0,%eax
  800849:	5d                   	pop    %ebp
  80084a:	c3                   	ret    

0080084b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80084b:	55                   	push   %ebp
  80084c:	89 e5                	mov    %esp,%ebp
  80084e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800851:	68 49 35 80 00       	push   $0x803549
  800856:	ff 75 0c             	pushl  0xc(%ebp)
  800859:	e8 9d 09 00 00       	call   8011fb <strcpy>
	return 0;
}
  80085e:	b8 00 00 00 00       	mov    $0x0,%eax
  800863:	c9                   	leave  
  800864:	c3                   	ret    

00800865 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800865:	55                   	push   %ebp
  800866:	89 e5                	mov    %esp,%ebp
  800868:	57                   	push   %edi
  800869:	56                   	push   %esi
  80086a:	53                   	push   %ebx
  80086b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800871:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800875:	74 45                	je     8008bc <devcons_write+0x57>
  800877:	b8 00 00 00 00       	mov    $0x0,%eax
  80087c:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800881:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800887:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80088a:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  80088c:	83 fb 7f             	cmp    $0x7f,%ebx
  80088f:	76 05                	jbe    800896 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  800891:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800896:	83 ec 04             	sub    $0x4,%esp
  800899:	53                   	push   %ebx
  80089a:	03 45 0c             	add    0xc(%ebp),%eax
  80089d:	50                   	push   %eax
  80089e:	57                   	push   %edi
  80089f:	e8 24 0b 00 00       	call   8013c8 <memmove>
		sys_cputs(buf, m);
  8008a4:	83 c4 08             	add    $0x8,%esp
  8008a7:	53                   	push   %ebx
  8008a8:	57                   	push   %edi
  8008a9:	e8 01 0d 00 00       	call   8015af <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8008ae:	01 de                	add    %ebx,%esi
  8008b0:	89 f0                	mov    %esi,%eax
  8008b2:	83 c4 10             	add    $0x10,%esp
  8008b5:	3b 75 10             	cmp    0x10(%ebp),%esi
  8008b8:	72 cd                	jb     800887 <devcons_write+0x22>
  8008ba:	eb 05                	jmp    8008c1 <devcons_write+0x5c>
  8008bc:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8008c1:	89 f0                	mov    %esi,%eax
  8008c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008c6:	5b                   	pop    %ebx
  8008c7:	5e                   	pop    %esi
  8008c8:	5f                   	pop    %edi
  8008c9:	5d                   	pop    %ebp
  8008ca:	c3                   	ret    

008008cb <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8008cb:	55                   	push   %ebp
  8008cc:	89 e5                	mov    %esp,%ebp
  8008ce:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8008d1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8008d5:	75 07                	jne    8008de <devcons_read+0x13>
  8008d7:	eb 23                	jmp    8008fc <devcons_read+0x31>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8008d9:	e8 6e 0d 00 00       	call   80164c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8008de:	e8 ea 0c 00 00       	call   8015cd <sys_cgetc>
  8008e3:	85 c0                	test   %eax,%eax
  8008e5:	74 f2                	je     8008d9 <devcons_read+0xe>
		sys_yield();
	if (c < 0)
  8008e7:	85 c0                	test   %eax,%eax
  8008e9:	78 1d                	js     800908 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8008eb:	83 f8 04             	cmp    $0x4,%eax
  8008ee:	74 13                	je     800903 <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  8008f0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008f3:	88 02                	mov    %al,(%edx)
	return 1;
  8008f5:	b8 01 00 00 00       	mov    $0x1,%eax
  8008fa:	eb 0c                	jmp    800908 <devcons_read+0x3d>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8008fc:	b8 00 00 00 00       	mov    $0x0,%eax
  800901:	eb 05                	jmp    800908 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800903:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800908:	c9                   	leave  
  800909:	c3                   	ret    

0080090a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80090a:	55                   	push   %ebp
  80090b:	89 e5                	mov    %esp,%ebp
  80090d:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800910:	8b 45 08             	mov    0x8(%ebp),%eax
  800913:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800916:	6a 01                	push   $0x1
  800918:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80091b:	50                   	push   %eax
  80091c:	e8 8e 0c 00 00       	call   8015af <sys_cputs>
}
  800921:	83 c4 10             	add    $0x10,%esp
  800924:	c9                   	leave  
  800925:	c3                   	ret    

00800926 <getchar>:

int
getchar(void)
{
  800926:	55                   	push   %ebp
  800927:	89 e5                	mov    %esp,%ebp
  800929:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80092c:	6a 01                	push   $0x1
  80092e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800931:	50                   	push   %eax
  800932:	6a 00                	push   $0x0
  800934:	e8 71 16 00 00       	call   801faa <read>
	if (r < 0)
  800939:	83 c4 10             	add    $0x10,%esp
  80093c:	85 c0                	test   %eax,%eax
  80093e:	78 0f                	js     80094f <getchar+0x29>
		return r;
	if (r < 1)
  800940:	85 c0                	test   %eax,%eax
  800942:	7e 06                	jle    80094a <getchar+0x24>
		return -E_EOF;
	return c;
  800944:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800948:	eb 05                	jmp    80094f <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80094a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80094f:	c9                   	leave  
  800950:	c3                   	ret    

00800951 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800951:	55                   	push   %ebp
  800952:	89 e5                	mov    %esp,%ebp
  800954:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800957:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80095a:	50                   	push   %eax
  80095b:	ff 75 08             	pushl  0x8(%ebp)
  80095e:	e8 c6 13 00 00       	call   801d29 <fd_lookup>
  800963:	83 c4 10             	add    $0x10,%esp
  800966:	85 c0                	test   %eax,%eax
  800968:	78 11                	js     80097b <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80096a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80096d:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800973:	39 10                	cmp    %edx,(%eax)
  800975:	0f 94 c0             	sete   %al
  800978:	0f b6 c0             	movzbl %al,%eax
}
  80097b:	c9                   	leave  
  80097c:	c3                   	ret    

0080097d <opencons>:

int
opencons(void)
{
  80097d:	55                   	push   %ebp
  80097e:	89 e5                	mov    %esp,%ebp
  800980:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800983:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800986:	50                   	push   %eax
  800987:	e8 29 13 00 00       	call   801cb5 <fd_alloc>
  80098c:	83 c4 10             	add    $0x10,%esp
  80098f:	85 c0                	test   %eax,%eax
  800991:	78 3a                	js     8009cd <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800993:	83 ec 04             	sub    $0x4,%esp
  800996:	68 07 04 00 00       	push   $0x407
  80099b:	ff 75 f4             	pushl  -0xc(%ebp)
  80099e:	6a 00                	push   $0x0
  8009a0:	e8 c6 0c 00 00       	call   80166b <sys_page_alloc>
  8009a5:	83 c4 10             	add    $0x10,%esp
  8009a8:	85 c0                	test   %eax,%eax
  8009aa:	78 21                	js     8009cd <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8009ac:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8009b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009b5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8009b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009ba:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8009c1:	83 ec 0c             	sub    $0xc,%esp
  8009c4:	50                   	push   %eax
  8009c5:	e8 c4 12 00 00       	call   801c8e <fd2num>
  8009ca:	83 c4 10             	add    $0x10,%esp
}
  8009cd:	c9                   	leave  
  8009ce:	c3                   	ret    

008009cf <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8009cf:	55                   	push   %ebp
  8009d0:	89 e5                	mov    %esp,%ebp
  8009d2:	56                   	push   %esi
  8009d3:	53                   	push   %ebx
  8009d4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009d7:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8009da:	e8 4e 0c 00 00       	call   80162d <sys_getenvid>
  8009df:	25 ff 03 00 00       	and    $0x3ff,%eax
  8009e4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8009eb:	c1 e0 07             	shl    $0x7,%eax
  8009ee:	29 d0                	sub    %edx,%eax
  8009f0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8009f5:	a3 24 54 80 00       	mov    %eax,0x805424

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8009fa:	85 db                	test   %ebx,%ebx
  8009fc:	7e 07                	jle    800a05 <libmain+0x36>
		binaryname = argv[0];
  8009fe:	8b 06                	mov    (%esi),%eax
  800a00:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  800a05:	83 ec 08             	sub    $0x8,%esp
  800a08:	56                   	push   %esi
  800a09:	53                   	push   %ebx
  800a0a:	e8 57 fc ff ff       	call   800666 <umain>

	// exit gracefully
	exit();
  800a0f:	e8 0a 00 00 00       	call   800a1e <exit>
}
  800a14:	83 c4 10             	add    $0x10,%esp
  800a17:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a1a:	5b                   	pop    %ebx
  800a1b:	5e                   	pop    %esi
  800a1c:	5d                   	pop    %ebp
  800a1d:	c3                   	ret    

00800a1e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800a1e:	55                   	push   %ebp
  800a1f:	89 e5                	mov    %esp,%ebp
  800a21:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800a24:	e8 74 14 00 00       	call   801e9d <close_all>
	sys_env_destroy(0);
  800a29:	83 ec 0c             	sub    $0xc,%esp
  800a2c:	6a 00                	push   $0x0
  800a2e:	e8 b9 0b 00 00       	call   8015ec <sys_env_destroy>
}
  800a33:	83 c4 10             	add    $0x10,%esp
  800a36:	c9                   	leave  
  800a37:	c3                   	ret    

00800a38 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800a38:	55                   	push   %ebp
  800a39:	89 e5                	mov    %esp,%ebp
  800a3b:	56                   	push   %esi
  800a3c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800a3d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800a40:	8b 35 1c 40 80 00    	mov    0x80401c,%esi
  800a46:	e8 e2 0b 00 00       	call   80162d <sys_getenvid>
  800a4b:	83 ec 0c             	sub    $0xc,%esp
  800a4e:	ff 75 0c             	pushl  0xc(%ebp)
  800a51:	ff 75 08             	pushl  0x8(%ebp)
  800a54:	56                   	push   %esi
  800a55:	50                   	push   %eax
  800a56:	68 60 35 80 00       	push   $0x803560
  800a5b:	e8 b0 00 00 00       	call   800b10 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800a60:	83 c4 18             	add    $0x18,%esp
  800a63:	53                   	push   %ebx
  800a64:	ff 75 10             	pushl  0x10(%ebp)
  800a67:	e8 53 00 00 00       	call   800abf <vcprintf>
	cprintf("\n");
  800a6c:	c7 04 24 60 33 80 00 	movl   $0x803360,(%esp)
  800a73:	e8 98 00 00 00       	call   800b10 <cprintf>
  800a78:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800a7b:	cc                   	int3   
  800a7c:	eb fd                	jmp    800a7b <_panic+0x43>

00800a7e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800a7e:	55                   	push   %ebp
  800a7f:	89 e5                	mov    %esp,%ebp
  800a81:	53                   	push   %ebx
  800a82:	83 ec 04             	sub    $0x4,%esp
  800a85:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800a88:	8b 13                	mov    (%ebx),%edx
  800a8a:	8d 42 01             	lea    0x1(%edx),%eax
  800a8d:	89 03                	mov    %eax,(%ebx)
  800a8f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a92:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800a96:	3d ff 00 00 00       	cmp    $0xff,%eax
  800a9b:	75 1a                	jne    800ab7 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800a9d:	83 ec 08             	sub    $0x8,%esp
  800aa0:	68 ff 00 00 00       	push   $0xff
  800aa5:	8d 43 08             	lea    0x8(%ebx),%eax
  800aa8:	50                   	push   %eax
  800aa9:	e8 01 0b 00 00       	call   8015af <sys_cputs>
		b->idx = 0;
  800aae:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800ab4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800ab7:	ff 43 04             	incl   0x4(%ebx)
}
  800aba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800abd:	c9                   	leave  
  800abe:	c3                   	ret    

00800abf <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800abf:	55                   	push   %ebp
  800ac0:	89 e5                	mov    %esp,%ebp
  800ac2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800ac8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800acf:	00 00 00 
	b.cnt = 0;
  800ad2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800ad9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800adc:	ff 75 0c             	pushl  0xc(%ebp)
  800adf:	ff 75 08             	pushl  0x8(%ebp)
  800ae2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800ae8:	50                   	push   %eax
  800ae9:	68 7e 0a 80 00       	push   $0x800a7e
  800aee:	e8 54 01 00 00       	call   800c47 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800af3:	83 c4 08             	add    $0x8,%esp
  800af6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800afc:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800b02:	50                   	push   %eax
  800b03:	e8 a7 0a 00 00       	call   8015af <sys_cputs>

	return b.cnt;
}
  800b08:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800b0e:	c9                   	leave  
  800b0f:	c3                   	ret    

00800b10 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800b10:	55                   	push   %ebp
  800b11:	89 e5                	mov    %esp,%ebp
  800b13:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800b16:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800b19:	50                   	push   %eax
  800b1a:	ff 75 08             	pushl  0x8(%ebp)
  800b1d:	e8 9d ff ff ff       	call   800abf <vcprintf>
	va_end(ap);

	return cnt;
}
  800b22:	c9                   	leave  
  800b23:	c3                   	ret    

00800b24 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800b24:	55                   	push   %ebp
  800b25:	89 e5                	mov    %esp,%ebp
  800b27:	57                   	push   %edi
  800b28:	56                   	push   %esi
  800b29:	53                   	push   %ebx
  800b2a:	83 ec 1c             	sub    $0x1c,%esp
  800b2d:	89 c6                	mov    %eax,%esi
  800b2f:	89 d7                	mov    %edx,%edi
  800b31:	8b 45 08             	mov    0x8(%ebp),%eax
  800b34:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b37:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b3a:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800b3d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b40:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b45:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800b48:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800b4b:	39 d3                	cmp    %edx,%ebx
  800b4d:	72 11                	jb     800b60 <printnum+0x3c>
  800b4f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800b52:	76 0c                	jbe    800b60 <printnum+0x3c>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800b54:	8b 45 14             	mov    0x14(%ebp),%eax
  800b57:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800b5a:	85 db                	test   %ebx,%ebx
  800b5c:	7f 37                	jg     800b95 <printnum+0x71>
  800b5e:	eb 44                	jmp    800ba4 <printnum+0x80>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800b60:	83 ec 0c             	sub    $0xc,%esp
  800b63:	ff 75 18             	pushl  0x18(%ebp)
  800b66:	8b 45 14             	mov    0x14(%ebp),%eax
  800b69:	48                   	dec    %eax
  800b6a:	50                   	push   %eax
  800b6b:	ff 75 10             	pushl  0x10(%ebp)
  800b6e:	83 ec 08             	sub    $0x8,%esp
  800b71:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b74:	ff 75 e0             	pushl  -0x20(%ebp)
  800b77:	ff 75 dc             	pushl  -0x24(%ebp)
  800b7a:	ff 75 d8             	pushl  -0x28(%ebp)
  800b7d:	e8 4a 25 00 00       	call   8030cc <__udivdi3>
  800b82:	83 c4 18             	add    $0x18,%esp
  800b85:	52                   	push   %edx
  800b86:	50                   	push   %eax
  800b87:	89 fa                	mov    %edi,%edx
  800b89:	89 f0                	mov    %esi,%eax
  800b8b:	e8 94 ff ff ff       	call   800b24 <printnum>
  800b90:	83 c4 20             	add    $0x20,%esp
  800b93:	eb 0f                	jmp    800ba4 <printnum+0x80>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800b95:	83 ec 08             	sub    $0x8,%esp
  800b98:	57                   	push   %edi
  800b99:	ff 75 18             	pushl  0x18(%ebp)
  800b9c:	ff d6                	call   *%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800b9e:	83 c4 10             	add    $0x10,%esp
  800ba1:	4b                   	dec    %ebx
  800ba2:	75 f1                	jne    800b95 <printnum+0x71>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800ba4:	83 ec 08             	sub    $0x8,%esp
  800ba7:	57                   	push   %edi
  800ba8:	83 ec 04             	sub    $0x4,%esp
  800bab:	ff 75 e4             	pushl  -0x1c(%ebp)
  800bae:	ff 75 e0             	pushl  -0x20(%ebp)
  800bb1:	ff 75 dc             	pushl  -0x24(%ebp)
  800bb4:	ff 75 d8             	pushl  -0x28(%ebp)
  800bb7:	e8 20 26 00 00       	call   8031dc <__umoddi3>
  800bbc:	83 c4 14             	add    $0x14,%esp
  800bbf:	0f be 80 83 35 80 00 	movsbl 0x803583(%eax),%eax
  800bc6:	50                   	push   %eax
  800bc7:	ff d6                	call   *%esi
}
  800bc9:	83 c4 10             	add    $0x10,%esp
  800bcc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bcf:	5b                   	pop    %ebx
  800bd0:	5e                   	pop    %esi
  800bd1:	5f                   	pop    %edi
  800bd2:	5d                   	pop    %ebp
  800bd3:	c3                   	ret    

00800bd4 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800bd4:	55                   	push   %ebp
  800bd5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800bd7:	83 fa 01             	cmp    $0x1,%edx
  800bda:	7e 0e                	jle    800bea <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800bdc:	8b 10                	mov    (%eax),%edx
  800bde:	8d 4a 08             	lea    0x8(%edx),%ecx
  800be1:	89 08                	mov    %ecx,(%eax)
  800be3:	8b 02                	mov    (%edx),%eax
  800be5:	8b 52 04             	mov    0x4(%edx),%edx
  800be8:	eb 22                	jmp    800c0c <getuint+0x38>
	else if (lflag)
  800bea:	85 d2                	test   %edx,%edx
  800bec:	74 10                	je     800bfe <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800bee:	8b 10                	mov    (%eax),%edx
  800bf0:	8d 4a 04             	lea    0x4(%edx),%ecx
  800bf3:	89 08                	mov    %ecx,(%eax)
  800bf5:	8b 02                	mov    (%edx),%eax
  800bf7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bfc:	eb 0e                	jmp    800c0c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800bfe:	8b 10                	mov    (%eax),%edx
  800c00:	8d 4a 04             	lea    0x4(%edx),%ecx
  800c03:	89 08                	mov    %ecx,(%eax)
  800c05:	8b 02                	mov    (%edx),%eax
  800c07:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800c0c:	5d                   	pop    %ebp
  800c0d:	c3                   	ret    

00800c0e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800c0e:	55                   	push   %ebp
  800c0f:	89 e5                	mov    %esp,%ebp
  800c11:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800c14:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800c17:	8b 10                	mov    (%eax),%edx
  800c19:	3b 50 04             	cmp    0x4(%eax),%edx
  800c1c:	73 0a                	jae    800c28 <sprintputch+0x1a>
		*b->buf++ = ch;
  800c1e:	8d 4a 01             	lea    0x1(%edx),%ecx
  800c21:	89 08                	mov    %ecx,(%eax)
  800c23:	8b 45 08             	mov    0x8(%ebp),%eax
  800c26:	88 02                	mov    %al,(%edx)
}
  800c28:	5d                   	pop    %ebp
  800c29:	c3                   	ret    

00800c2a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800c2a:	55                   	push   %ebp
  800c2b:	89 e5                	mov    %esp,%ebp
  800c2d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800c30:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800c33:	50                   	push   %eax
  800c34:	ff 75 10             	pushl  0x10(%ebp)
  800c37:	ff 75 0c             	pushl  0xc(%ebp)
  800c3a:	ff 75 08             	pushl  0x8(%ebp)
  800c3d:	e8 05 00 00 00       	call   800c47 <vprintfmt>
	va_end(ap);
}
  800c42:	83 c4 10             	add    $0x10,%esp
  800c45:	c9                   	leave  
  800c46:	c3                   	ret    

00800c47 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800c47:	55                   	push   %ebp
  800c48:	89 e5                	mov    %esp,%ebp
  800c4a:	57                   	push   %edi
  800c4b:	56                   	push   %esi
  800c4c:	53                   	push   %ebx
  800c4d:	83 ec 2c             	sub    $0x2c,%esp
  800c50:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c53:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c56:	eb 03                	jmp    800c5b <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c58:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  800c5b:	8b 45 10             	mov    0x10(%ebp),%eax
  800c5e:	8d 70 01             	lea    0x1(%eax),%esi
  800c61:	0f b6 00             	movzbl (%eax),%eax
  800c64:	83 f8 25             	cmp    $0x25,%eax
  800c67:	74 25                	je     800c8e <vprintfmt+0x47>
			if (ch == '\0')									//当然中间如果遇到'\0'，代表这个字符串的访问结束
  800c69:	85 c0                	test   %eax,%eax
  800c6b:	75 0d                	jne    800c7a <vprintfmt+0x33>
  800c6d:	e9 b5 03 00 00       	jmp    801027 <vprintfmt+0x3e0>
  800c72:	85 c0                	test   %eax,%eax
  800c74:	0f 84 ad 03 00 00    	je     801027 <vprintfmt+0x3e0>
				return;
			putch(ch, putdat);								//调用putch函数，把一个字符ch输出到putdat指针所指向的地址中所存放的值对应的地址处
  800c7a:	83 ec 08             	sub    $0x8,%esp
  800c7d:	53                   	push   %ebx
  800c7e:	50                   	push   %eax
  800c7f:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  800c81:	46                   	inc    %esi
  800c82:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800c86:	83 c4 10             	add    $0x10,%esp
  800c89:	83 f8 25             	cmp    $0x25,%eax
  800c8c:	75 e4                	jne    800c72 <vprintfmt+0x2b>
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  800c8e:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  800c92:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800c99:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800ca0:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800ca7:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800cae:	eb 07                	jmp    800cb7 <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800cb0:	8b 75 10             	mov    0x10(%ebp),%esi

		// flag to pad on the right
		case '-':											//%后面的'-'代表要进行左对齐输出，右边填空格，如果省略代表右对齐
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
  800cb3:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800cb7:	8d 46 01             	lea    0x1(%esi),%eax
  800cba:	89 45 10             	mov    %eax,0x10(%ebp)
  800cbd:	0f b6 16             	movzbl (%esi),%edx
  800cc0:	8a 06                	mov    (%esi),%al
  800cc2:	83 e8 23             	sub    $0x23,%eax
  800cc5:	3c 55                	cmp    $0x55,%al
  800cc7:	0f 87 03 03 00 00    	ja     800fd0 <vprintfmt+0x389>
  800ccd:	0f b6 c0             	movzbl %al,%eax
  800cd0:	ff 24 85 c0 36 80 00 	jmp    *0x8036c0(,%eax,4)
  800cd7:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
			goto reswitch;									//处理下一个字符

		// flag to pad with 0's instead of spaces
		case '0':											//0--有0表示进行对齐输出时填0,如省略表示填入空格，并且如果为0，则一定是右对齐
			padc = '0';										//对其方式标志位变为0
  800cda:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  800cde:	eb d7                	jmp    800cb7 <vprintfmt+0x70>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
				precision = precision * 10 + ch - '0';
  800ce0:	8d 42 d0             	lea    -0x30(%edx),%eax
  800ce3:	89 c1                	mov    %eax,%ecx
  800ce5:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  800ce8:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800cec:	8d 50 d0             	lea    -0x30(%eax),%edx
  800cef:	83 fa 09             	cmp    $0x9,%edx
  800cf2:	77 51                	ja     800d45 <vprintfmt+0xfe>
  800cf4:	8b 75 10             	mov    0x10(%ebp),%esi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
  800cf7:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800cf8:	8d 14 89             	lea    (%ecx,%ecx,4),%edx
  800cfb:	01 d2                	add    %edx,%edx
  800cfd:	8d 4c 10 d0          	lea    -0x30(%eax,%edx,1),%ecx
				ch = *fmt;
  800d01:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800d04:	8d 50 d0             	lea    -0x30(%eax),%edx
  800d07:	83 fa 09             	cmp    $0x9,%edx
  800d0a:	76 eb                	jbe    800cf7 <vprintfmt+0xb0>
  800d0c:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800d0f:	eb 37                	jmp    800d48 <vprintfmt+0x101>
					break;
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
  800d11:	8b 45 14             	mov    0x14(%ebp),%eax
  800d14:	8d 50 04             	lea    0x4(%eax),%edx
  800d17:	89 55 14             	mov    %edx,0x14(%ebp)
  800d1a:	8b 00                	mov    (%eax),%eax
  800d1c:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800d1f:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
			goto process_precision;
  800d22:	eb 24                	jmp    800d48 <vprintfmt+0x101>
  800d24:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800d28:	79 07                	jns    800d31 <vprintfmt+0xea>
  800d2a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800d31:	8b 75 10             	mov    0x10(%ebp),%esi
  800d34:	eb 81                	jmp    800cb7 <vprintfmt+0x70>
  800d36:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  800d39:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800d40:	e9 72 ff ff ff       	jmp    800cb7 <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800d45:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:									//处理输出精度，把width字段赋值为刚刚计算出来的precision值，所以width应该是整数部分的有效数字位数
			if (width < 0)
  800d48:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800d4c:	0f 89 65 ff ff ff    	jns    800cb7 <vprintfmt+0x70>
				width = precision, precision = -1;
  800d52:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800d55:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800d58:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800d5f:	e9 53 ff ff ff       	jmp    800cb7 <vprintfmt+0x70>
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
  800d64:	ff 45 d4             	incl   -0x2c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800d67:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
			goto reswitch;
  800d6a:	e9 48 ff ff ff       	jmp    800cb7 <vprintfmt+0x70>

		// character
		case 'c':											//如果是'c'代表显示一个字符
			putch(va_arg(ap, int), putdat);					//调用输出一个字符到内存的函数putch
  800d6f:	8b 45 14             	mov    0x14(%ebp),%eax
  800d72:	8d 50 04             	lea    0x4(%eax),%edx
  800d75:	89 55 14             	mov    %edx,0x14(%ebp)
  800d78:	83 ec 08             	sub    $0x8,%esp
  800d7b:	53                   	push   %ebx
  800d7c:	ff 30                	pushl  (%eax)
  800d7e:	ff d7                	call   *%edi
			break;
  800d80:	83 c4 10             	add    $0x10,%esp
  800d83:	e9 d3 fe ff ff       	jmp    800c5b <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800d88:	8b 45 14             	mov    0x14(%ebp),%eax
  800d8b:	8d 50 04             	lea    0x4(%eax),%edx
  800d8e:	89 55 14             	mov    %edx,0x14(%ebp)
  800d91:	8b 00                	mov    (%eax),%eax
  800d93:	85 c0                	test   %eax,%eax
  800d95:	79 02                	jns    800d99 <vprintfmt+0x152>
  800d97:	f7 d8                	neg    %eax
  800d99:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800d9b:	83 f8 0f             	cmp    $0xf,%eax
  800d9e:	7f 0b                	jg     800dab <vprintfmt+0x164>
  800da0:	8b 04 85 20 38 80 00 	mov    0x803820(,%eax,4),%eax
  800da7:	85 c0                	test   %eax,%eax
  800da9:	75 15                	jne    800dc0 <vprintfmt+0x179>
				printfmt(putch, putdat, "error %d", err);
  800dab:	52                   	push   %edx
  800dac:	68 9b 35 80 00       	push   $0x80359b
  800db1:	53                   	push   %ebx
  800db2:	57                   	push   %edi
  800db3:	e8 72 fe ff ff       	call   800c2a <printfmt>
  800db8:	83 c4 10             	add    $0x10,%esp
  800dbb:	e9 9b fe ff ff       	jmp    800c5b <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  800dc0:	50                   	push   %eax
  800dc1:	68 a1 34 80 00       	push   $0x8034a1
  800dc6:	53                   	push   %ebx
  800dc7:	57                   	push   %edi
  800dc8:	e8 5d fe ff ff       	call   800c2a <printfmt>
  800dcd:	83 c4 10             	add    $0x10,%esp
  800dd0:	e9 86 fe ff ff       	jmp    800c5b <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800dd5:	8b 45 14             	mov    0x14(%ebp),%eax
  800dd8:	8d 50 04             	lea    0x4(%eax),%edx
  800ddb:	89 55 14             	mov    %edx,0x14(%ebp)
  800dde:	8b 00                	mov    (%eax),%eax
  800de0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800de3:	85 c0                	test   %eax,%eax
  800de5:	75 07                	jne    800dee <vprintfmt+0x1a7>
				p = "(null)";
  800de7:	c7 45 d4 94 35 80 00 	movl   $0x803594,-0x2c(%ebp)
			if (width > 0 && padc != '-')
  800dee:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800df1:	85 f6                	test   %esi,%esi
  800df3:	0f 8e fb 01 00 00    	jle    800ff4 <vprintfmt+0x3ad>
  800df9:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  800dfd:	0f 84 09 02 00 00    	je     80100c <vprintfmt+0x3c5>
				for (width -= strnlen(p, precision); width > 0; width--)
  800e03:	83 ec 08             	sub    $0x8,%esp
  800e06:	ff 75 d0             	pushl  -0x30(%ebp)
  800e09:	ff 75 d4             	pushl  -0x2c(%ebp)
  800e0c:	e8 b3 03 00 00       	call   8011c4 <strnlen>
  800e11:	89 f1                	mov    %esi,%ecx
  800e13:	29 c1                	sub    %eax,%ecx
  800e15:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800e18:	83 c4 10             	add    $0x10,%esp
  800e1b:	85 c9                	test   %ecx,%ecx
  800e1d:	0f 8e d1 01 00 00    	jle    800ff4 <vprintfmt+0x3ad>
					putch(padc, putdat);
  800e23:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800e27:	83 ec 08             	sub    $0x8,%esp
  800e2a:	53                   	push   %ebx
  800e2b:	56                   	push   %esi
  800e2c:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800e2e:	83 c4 10             	add    $0x10,%esp
  800e31:	ff 4d e4             	decl   -0x1c(%ebp)
  800e34:	75 f1                	jne    800e27 <vprintfmt+0x1e0>
  800e36:	e9 b9 01 00 00       	jmp    800ff4 <vprintfmt+0x3ad>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800e3b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800e3f:	74 19                	je     800e5a <vprintfmt+0x213>
  800e41:	0f be c0             	movsbl %al,%eax
  800e44:	83 e8 20             	sub    $0x20,%eax
  800e47:	83 f8 5e             	cmp    $0x5e,%eax
  800e4a:	76 0e                	jbe    800e5a <vprintfmt+0x213>
					putch('?', putdat);
  800e4c:	83 ec 08             	sub    $0x8,%esp
  800e4f:	53                   	push   %ebx
  800e50:	6a 3f                	push   $0x3f
  800e52:	ff 55 08             	call   *0x8(%ebp)
  800e55:	83 c4 10             	add    $0x10,%esp
  800e58:	eb 0b                	jmp    800e65 <vprintfmt+0x21e>
				else
					putch(ch, putdat);
  800e5a:	83 ec 08             	sub    $0x8,%esp
  800e5d:	53                   	push   %ebx
  800e5e:	52                   	push   %edx
  800e5f:	ff 55 08             	call   *0x8(%ebp)
  800e62:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800e65:	ff 4d e4             	decl   -0x1c(%ebp)
  800e68:	46                   	inc    %esi
  800e69:	8a 46 ff             	mov    -0x1(%esi),%al
  800e6c:	0f be d0             	movsbl %al,%edx
  800e6f:	85 d2                	test   %edx,%edx
  800e71:	75 1c                	jne    800e8f <vprintfmt+0x248>
  800e73:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800e76:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e7a:	7f 1f                	jg     800e9b <vprintfmt+0x254>
  800e7c:	e9 da fd ff ff       	jmp    800c5b <vprintfmt+0x14>
  800e81:	89 7d 08             	mov    %edi,0x8(%ebp)
  800e84:	8b 7d d0             	mov    -0x30(%ebp),%edi
  800e87:	eb 06                	jmp    800e8f <vprintfmt+0x248>
  800e89:	89 7d 08             	mov    %edi,0x8(%ebp)
  800e8c:	8b 7d d0             	mov    -0x30(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800e8f:	85 ff                	test   %edi,%edi
  800e91:	78 a8                	js     800e3b <vprintfmt+0x1f4>
  800e93:	4f                   	dec    %edi
  800e94:	79 a5                	jns    800e3b <vprintfmt+0x1f4>
  800e96:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e99:	eb db                	jmp    800e76 <vprintfmt+0x22f>
  800e9b:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800e9e:	83 ec 08             	sub    $0x8,%esp
  800ea1:	53                   	push   %ebx
  800ea2:	6a 20                	push   $0x20
  800ea4:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800ea6:	4e                   	dec    %esi
  800ea7:	83 c4 10             	add    $0x10,%esp
  800eaa:	85 f6                	test   %esi,%esi
  800eac:	7f f0                	jg     800e9e <vprintfmt+0x257>
  800eae:	e9 a8 fd ff ff       	jmp    800c5b <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800eb3:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  800eb7:	7e 16                	jle    800ecf <vprintfmt+0x288>
		return va_arg(*ap, long long);
  800eb9:	8b 45 14             	mov    0x14(%ebp),%eax
  800ebc:	8d 50 08             	lea    0x8(%eax),%edx
  800ebf:	89 55 14             	mov    %edx,0x14(%ebp)
  800ec2:	8b 50 04             	mov    0x4(%eax),%edx
  800ec5:	8b 00                	mov    (%eax),%eax
  800ec7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800eca:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800ecd:	eb 34                	jmp    800f03 <vprintfmt+0x2bc>
	else if (lflag)
  800ecf:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800ed3:	74 18                	je     800eed <vprintfmt+0x2a6>
		return va_arg(*ap, long);
  800ed5:	8b 45 14             	mov    0x14(%ebp),%eax
  800ed8:	8d 50 04             	lea    0x4(%eax),%edx
  800edb:	89 55 14             	mov    %edx,0x14(%ebp)
  800ede:	8b 30                	mov    (%eax),%esi
  800ee0:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800ee3:	89 f0                	mov    %esi,%eax
  800ee5:	c1 f8 1f             	sar    $0x1f,%eax
  800ee8:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800eeb:	eb 16                	jmp    800f03 <vprintfmt+0x2bc>
	else
		return va_arg(*ap, int);
  800eed:	8b 45 14             	mov    0x14(%ebp),%eax
  800ef0:	8d 50 04             	lea    0x4(%eax),%edx
  800ef3:	89 55 14             	mov    %edx,0x14(%ebp)
  800ef6:	8b 30                	mov    (%eax),%esi
  800ef8:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800efb:	89 f0                	mov    %esi,%eax
  800efd:	c1 f8 1f             	sar    $0x1f,%eax
  800f00:	89 45 dc             	mov    %eax,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800f03:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800f06:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
  800f09:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800f0d:	0f 89 8a 00 00 00    	jns    800f9d <vprintfmt+0x356>
				putch('-', putdat);
  800f13:	83 ec 08             	sub    $0x8,%esp
  800f16:	53                   	push   %ebx
  800f17:	6a 2d                	push   $0x2d
  800f19:	ff d7                	call   *%edi
				num = -(long long) num;
  800f1b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800f1e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800f21:	f7 d8                	neg    %eax
  800f23:	83 d2 00             	adc    $0x0,%edx
  800f26:	f7 da                	neg    %edx
  800f28:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800f2b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800f30:	eb 70                	jmp    800fa2 <vprintfmt+0x35b>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800f32:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800f35:	8d 45 14             	lea    0x14(%ebp),%eax
  800f38:	e8 97 fc ff ff       	call   800bd4 <getuint>
			base = 10;
  800f3d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800f42:	eb 5e                	jmp    800fa2 <vprintfmt+0x35b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  800f44:	83 ec 08             	sub    $0x8,%esp
  800f47:	53                   	push   %ebx
  800f48:	6a 30                	push   $0x30
  800f4a:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  800f4c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800f4f:	8d 45 14             	lea    0x14(%ebp),%eax
  800f52:	e8 7d fc ff ff       	call   800bd4 <getuint>
			base = 8;
			goto number;
  800f57:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800f5a:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800f5f:	eb 41                	jmp    800fa2 <vprintfmt+0x35b>
		// pointer
		case 'p':
			putch('0', putdat);
  800f61:	83 ec 08             	sub    $0x8,%esp
  800f64:	53                   	push   %ebx
  800f65:	6a 30                	push   $0x30
  800f67:	ff d7                	call   *%edi
			putch('x', putdat);
  800f69:	83 c4 08             	add    $0x8,%esp
  800f6c:	53                   	push   %ebx
  800f6d:	6a 78                	push   $0x78
  800f6f:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800f71:	8b 45 14             	mov    0x14(%ebp),%eax
  800f74:	8d 50 04             	lea    0x4(%eax),%edx
  800f77:	89 55 14             	mov    %edx,0x14(%ebp)
			goto number;
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800f7a:	8b 00                	mov    (%eax),%eax
  800f7c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800f81:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800f84:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800f89:	eb 17                	jmp    800fa2 <vprintfmt+0x35b>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800f8b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800f8e:	8d 45 14             	lea    0x14(%ebp),%eax
  800f91:	e8 3e fc ff ff       	call   800bd4 <getuint>
			base = 16;
  800f96:	b9 10 00 00 00       	mov    $0x10,%ecx
  800f9b:	eb 05                	jmp    800fa2 <vprintfmt+0x35b>
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800f9d:	b9 0a 00 00 00       	mov    $0xa,%ecx
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800fa2:	83 ec 0c             	sub    $0xc,%esp
  800fa5:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800fa9:	56                   	push   %esi
  800faa:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fad:	51                   	push   %ecx
  800fae:	52                   	push   %edx
  800faf:	50                   	push   %eax
  800fb0:	89 da                	mov    %ebx,%edx
  800fb2:	89 f8                	mov    %edi,%eax
  800fb4:	e8 6b fb ff ff       	call   800b24 <printnum>
			break;
  800fb9:	83 c4 20             	add    $0x20,%esp
  800fbc:	e9 9a fc ff ff       	jmp    800c5b <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800fc1:	83 ec 08             	sub    $0x8,%esp
  800fc4:	53                   	push   %ebx
  800fc5:	52                   	push   %edx
  800fc6:	ff d7                	call   *%edi
			break;
  800fc8:	83 c4 10             	add    $0x10,%esp
  800fcb:	e9 8b fc ff ff       	jmp    800c5b <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800fd0:	83 ec 08             	sub    $0x8,%esp
  800fd3:	53                   	push   %ebx
  800fd4:	6a 25                	push   $0x25
  800fd6:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800fd8:	83 c4 10             	add    $0x10,%esp
  800fdb:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800fdf:	0f 84 73 fc ff ff    	je     800c58 <vprintfmt+0x11>
  800fe5:	4e                   	dec    %esi
  800fe6:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800fea:	75 f9                	jne    800fe5 <vprintfmt+0x39e>
  800fec:	89 75 10             	mov    %esi,0x10(%ebp)
  800fef:	e9 67 fc ff ff       	jmp    800c5b <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800ff4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800ff7:	8d 70 01             	lea    0x1(%eax),%esi
  800ffa:	8a 00                	mov    (%eax),%al
  800ffc:	0f be d0             	movsbl %al,%edx
  800fff:	85 d2                	test   %edx,%edx
  801001:	0f 85 7a fe ff ff    	jne    800e81 <vprintfmt+0x23a>
  801007:	e9 4f fc ff ff       	jmp    800c5b <vprintfmt+0x14>
  80100c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80100f:	8d 70 01             	lea    0x1(%eax),%esi
  801012:	8a 00                	mov    (%eax),%al
  801014:	0f be d0             	movsbl %al,%edx
  801017:	85 d2                	test   %edx,%edx
  801019:	0f 85 6a fe ff ff    	jne    800e89 <vprintfmt+0x242>
  80101f:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801022:	e9 77 fe ff ff       	jmp    800e9e <vprintfmt+0x257>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  801027:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80102a:	5b                   	pop    %ebx
  80102b:	5e                   	pop    %esi
  80102c:	5f                   	pop    %edi
  80102d:	5d                   	pop    %ebp
  80102e:	c3                   	ret    

0080102f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80102f:	55                   	push   %ebp
  801030:	89 e5                	mov    %esp,%ebp
  801032:	83 ec 18             	sub    $0x18,%esp
  801035:	8b 45 08             	mov    0x8(%ebp),%eax
  801038:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80103b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80103e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801042:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801045:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80104c:	85 c0                	test   %eax,%eax
  80104e:	74 26                	je     801076 <vsnprintf+0x47>
  801050:	85 d2                	test   %edx,%edx
  801052:	7e 29                	jle    80107d <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801054:	ff 75 14             	pushl  0x14(%ebp)
  801057:	ff 75 10             	pushl  0x10(%ebp)
  80105a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80105d:	50                   	push   %eax
  80105e:	68 0e 0c 80 00       	push   $0x800c0e
  801063:	e8 df fb ff ff       	call   800c47 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801068:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80106b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80106e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801071:	83 c4 10             	add    $0x10,%esp
  801074:	eb 0c                	jmp    801082 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801076:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80107b:	eb 05                	jmp    801082 <vsnprintf+0x53>
  80107d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801082:	c9                   	leave  
  801083:	c3                   	ret    

00801084 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801084:	55                   	push   %ebp
  801085:	89 e5                	mov    %esp,%ebp
  801087:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80108a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80108d:	50                   	push   %eax
  80108e:	ff 75 10             	pushl  0x10(%ebp)
  801091:	ff 75 0c             	pushl  0xc(%ebp)
  801094:	ff 75 08             	pushl  0x8(%ebp)
  801097:	e8 93 ff ff ff       	call   80102f <vsnprintf>
	va_end(ap);

	return rc;
}
  80109c:	c9                   	leave  
  80109d:	c3                   	ret    

0080109e <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  80109e:	55                   	push   %ebp
  80109f:	89 e5                	mov    %esp,%ebp
  8010a1:	57                   	push   %edi
  8010a2:	56                   	push   %esi
  8010a3:	53                   	push   %ebx
  8010a4:	83 ec 0c             	sub    $0xc,%esp
  8010a7:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  8010aa:	85 c0                	test   %eax,%eax
  8010ac:	74 13                	je     8010c1 <readline+0x23>
		fprintf(1, "%s", prompt);
  8010ae:	83 ec 04             	sub    $0x4,%esp
  8010b1:	50                   	push   %eax
  8010b2:	68 a1 34 80 00       	push   $0x8034a1
  8010b7:	6a 01                	push   $0x1
  8010b9:	e8 58 14 00 00       	call   802516 <fprintf>
  8010be:	83 c4 10             	add    $0x10,%esp
#endif

	i = 0;
	echoing = iscons(0);
  8010c1:	83 ec 0c             	sub    $0xc,%esp
  8010c4:	6a 00                	push   $0x0
  8010c6:	e8 86 f8 ff ff       	call   800951 <iscons>
  8010cb:	89 c7                	mov    %eax,%edi
  8010cd:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
  8010d0:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
  8010d5:	e8 4c f8 ff ff       	call   800926 <getchar>
  8010da:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  8010dc:	85 c0                	test   %eax,%eax
  8010de:	79 24                	jns    801104 <readline+0x66>
			if (c != -E_EOF)
  8010e0:	83 f8 f8             	cmp    $0xfffffff8,%eax
  8010e3:	0f 84 90 00 00 00    	je     801179 <readline+0xdb>
				cprintf("read error: %e\n", c);
  8010e9:	83 ec 08             	sub    $0x8,%esp
  8010ec:	50                   	push   %eax
  8010ed:	68 7f 38 80 00       	push   $0x80387f
  8010f2:	e8 19 fa ff ff       	call   800b10 <cprintf>
  8010f7:	83 c4 10             	add    $0x10,%esp
			return NULL;
  8010fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8010ff:	e9 98 00 00 00       	jmp    80119c <readline+0xfe>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  801104:	83 f8 08             	cmp    $0x8,%eax
  801107:	74 7d                	je     801186 <readline+0xe8>
  801109:	83 f8 7f             	cmp    $0x7f,%eax
  80110c:	75 16                	jne    801124 <readline+0x86>
  80110e:	eb 70                	jmp    801180 <readline+0xe2>
			if (echoing)
  801110:	85 ff                	test   %edi,%edi
  801112:	74 0d                	je     801121 <readline+0x83>
				cputchar('\b');
  801114:	83 ec 0c             	sub    $0xc,%esp
  801117:	6a 08                	push   $0x8
  801119:	e8 ec f7 ff ff       	call   80090a <cputchar>
  80111e:	83 c4 10             	add    $0x10,%esp
			i--;
  801121:	4e                   	dec    %esi
  801122:	eb b1                	jmp    8010d5 <readline+0x37>
		} else if (c >= ' ' && i < BUFLEN-1) {
  801124:	83 f8 1f             	cmp    $0x1f,%eax
  801127:	7e 23                	jle    80114c <readline+0xae>
  801129:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  80112f:	7f 1b                	jg     80114c <readline+0xae>
			if (echoing)
  801131:	85 ff                	test   %edi,%edi
  801133:	74 0c                	je     801141 <readline+0xa3>
				cputchar(c);
  801135:	83 ec 0c             	sub    $0xc,%esp
  801138:	53                   	push   %ebx
  801139:	e8 cc f7 ff ff       	call   80090a <cputchar>
  80113e:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
  801141:	88 9e 20 50 80 00    	mov    %bl,0x805020(%esi)
  801147:	8d 76 01             	lea    0x1(%esi),%esi
  80114a:	eb 89                	jmp    8010d5 <readline+0x37>
		} else if (c == '\n' || c == '\r') {
  80114c:	83 fb 0a             	cmp    $0xa,%ebx
  80114f:	74 09                	je     80115a <readline+0xbc>
  801151:	83 fb 0d             	cmp    $0xd,%ebx
  801154:	0f 85 7b ff ff ff    	jne    8010d5 <readline+0x37>
			if (echoing)
  80115a:	85 ff                	test   %edi,%edi
  80115c:	74 0d                	je     80116b <readline+0xcd>
				cputchar('\n');
  80115e:	83 ec 0c             	sub    $0xc,%esp
  801161:	6a 0a                	push   $0xa
  801163:	e8 a2 f7 ff ff       	call   80090a <cputchar>
  801168:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
  80116b:	c6 86 20 50 80 00 00 	movb   $0x0,0x805020(%esi)
			return buf;
  801172:	b8 20 50 80 00       	mov    $0x805020,%eax
  801177:	eb 23                	jmp    80119c <readline+0xfe>
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  801179:	b8 00 00 00 00       	mov    $0x0,%eax
  80117e:	eb 1c                	jmp    80119c <readline+0xfe>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  801180:	85 f6                	test   %esi,%esi
  801182:	7f 8c                	jg     801110 <readline+0x72>
  801184:	eb 09                	jmp    80118f <readline+0xf1>
  801186:	85 f6                	test   %esi,%esi
  801188:	7f 86                	jg     801110 <readline+0x72>
  80118a:	e9 46 ff ff ff       	jmp    8010d5 <readline+0x37>
			if (echoing)
				cputchar('\b');
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
  80118f:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  801195:	7e 9a                	jle    801131 <readline+0x93>
  801197:	e9 39 ff ff ff       	jmp    8010d5 <readline+0x37>
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
  80119c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80119f:	5b                   	pop    %ebx
  8011a0:	5e                   	pop    %esi
  8011a1:	5f                   	pop    %edi
  8011a2:	5d                   	pop    %ebp
  8011a3:	c3                   	ret    

008011a4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8011a4:	55                   	push   %ebp
  8011a5:	89 e5                	mov    %esp,%ebp
  8011a7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8011aa:	80 3a 00             	cmpb   $0x0,(%edx)
  8011ad:	74 0e                	je     8011bd <strlen+0x19>
  8011af:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8011b4:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8011b5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8011b9:	75 f9                	jne    8011b4 <strlen+0x10>
  8011bb:	eb 05                	jmp    8011c2 <strlen+0x1e>
  8011bd:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8011c2:	5d                   	pop    %ebp
  8011c3:	c3                   	ret    

008011c4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8011c4:	55                   	push   %ebp
  8011c5:	89 e5                	mov    %esp,%ebp
  8011c7:	53                   	push   %ebx
  8011c8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8011cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8011ce:	85 c9                	test   %ecx,%ecx
  8011d0:	74 1a                	je     8011ec <strnlen+0x28>
  8011d2:	80 3b 00             	cmpb   $0x0,(%ebx)
  8011d5:	74 1c                	je     8011f3 <strnlen+0x2f>
  8011d7:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8011dc:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8011de:	39 ca                	cmp    %ecx,%edx
  8011e0:	74 16                	je     8011f8 <strnlen+0x34>
  8011e2:	42                   	inc    %edx
  8011e3:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8011e8:	75 f2                	jne    8011dc <strnlen+0x18>
  8011ea:	eb 0c                	jmp    8011f8 <strnlen+0x34>
  8011ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8011f1:	eb 05                	jmp    8011f8 <strnlen+0x34>
  8011f3:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8011f8:	5b                   	pop    %ebx
  8011f9:	5d                   	pop    %ebp
  8011fa:	c3                   	ret    

008011fb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8011fb:	55                   	push   %ebp
  8011fc:	89 e5                	mov    %esp,%ebp
  8011fe:	53                   	push   %ebx
  8011ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801202:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801205:	89 c2                	mov    %eax,%edx
  801207:	42                   	inc    %edx
  801208:	41                   	inc    %ecx
  801209:	8a 59 ff             	mov    -0x1(%ecx),%bl
  80120c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80120f:	84 db                	test   %bl,%bl
  801211:	75 f4                	jne    801207 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801213:	5b                   	pop    %ebx
  801214:	5d                   	pop    %ebp
  801215:	c3                   	ret    

00801216 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801216:	55                   	push   %ebp
  801217:	89 e5                	mov    %esp,%ebp
  801219:	53                   	push   %ebx
  80121a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80121d:	53                   	push   %ebx
  80121e:	e8 81 ff ff ff       	call   8011a4 <strlen>
  801223:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801226:	ff 75 0c             	pushl  0xc(%ebp)
  801229:	01 d8                	add    %ebx,%eax
  80122b:	50                   	push   %eax
  80122c:	e8 ca ff ff ff       	call   8011fb <strcpy>
	return dst;
}
  801231:	89 d8                	mov    %ebx,%eax
  801233:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801236:	c9                   	leave  
  801237:	c3                   	ret    

00801238 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801238:	55                   	push   %ebp
  801239:	89 e5                	mov    %esp,%ebp
  80123b:	56                   	push   %esi
  80123c:	53                   	push   %ebx
  80123d:	8b 75 08             	mov    0x8(%ebp),%esi
  801240:	8b 55 0c             	mov    0xc(%ebp),%edx
  801243:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801246:	85 db                	test   %ebx,%ebx
  801248:	74 14                	je     80125e <strncpy+0x26>
  80124a:	01 f3                	add    %esi,%ebx
  80124c:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  80124e:	41                   	inc    %ecx
  80124f:	8a 02                	mov    (%edx),%al
  801251:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801254:	80 3a 01             	cmpb   $0x1,(%edx)
  801257:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80125a:	39 cb                	cmp    %ecx,%ebx
  80125c:	75 f0                	jne    80124e <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80125e:	89 f0                	mov    %esi,%eax
  801260:	5b                   	pop    %ebx
  801261:	5e                   	pop    %esi
  801262:	5d                   	pop    %ebp
  801263:	c3                   	ret    

00801264 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801264:	55                   	push   %ebp
  801265:	89 e5                	mov    %esp,%ebp
  801267:	53                   	push   %ebx
  801268:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80126b:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80126e:	85 c0                	test   %eax,%eax
  801270:	74 30                	je     8012a2 <strlcpy+0x3e>
		while (--size > 0 && *src != '\0')
  801272:	48                   	dec    %eax
  801273:	74 20                	je     801295 <strlcpy+0x31>
  801275:	8a 0b                	mov    (%ebx),%cl
  801277:	84 c9                	test   %cl,%cl
  801279:	74 1f                	je     80129a <strlcpy+0x36>
  80127b:	8d 53 01             	lea    0x1(%ebx),%edx
  80127e:	01 c3                	add    %eax,%ebx
  801280:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
  801283:	40                   	inc    %eax
  801284:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801287:	39 da                	cmp    %ebx,%edx
  801289:	74 12                	je     80129d <strlcpy+0x39>
  80128b:	42                   	inc    %edx
  80128c:	8a 4a ff             	mov    -0x1(%edx),%cl
  80128f:	84 c9                	test   %cl,%cl
  801291:	75 f0                	jne    801283 <strlcpy+0x1f>
  801293:	eb 08                	jmp    80129d <strlcpy+0x39>
  801295:	8b 45 08             	mov    0x8(%ebp),%eax
  801298:	eb 03                	jmp    80129d <strlcpy+0x39>
  80129a:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
		*dst = '\0';
  80129d:	c6 00 00             	movb   $0x0,(%eax)
  8012a0:	eb 03                	jmp    8012a5 <strlcpy+0x41>
  8012a2:	8b 45 08             	mov    0x8(%ebp),%eax
	}
	return dst - dst_in;
  8012a5:	2b 45 08             	sub    0x8(%ebp),%eax
}
  8012a8:	5b                   	pop    %ebx
  8012a9:	5d                   	pop    %ebp
  8012aa:	c3                   	ret    

008012ab <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8012ab:	55                   	push   %ebp
  8012ac:	89 e5                	mov    %esp,%ebp
  8012ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012b1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8012b4:	8a 01                	mov    (%ecx),%al
  8012b6:	84 c0                	test   %al,%al
  8012b8:	74 10                	je     8012ca <strcmp+0x1f>
  8012ba:	3a 02                	cmp    (%edx),%al
  8012bc:	75 0c                	jne    8012ca <strcmp+0x1f>
		p++, q++;
  8012be:	41                   	inc    %ecx
  8012bf:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8012c0:	8a 01                	mov    (%ecx),%al
  8012c2:	84 c0                	test   %al,%al
  8012c4:	74 04                	je     8012ca <strcmp+0x1f>
  8012c6:	3a 02                	cmp    (%edx),%al
  8012c8:	74 f4                	je     8012be <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8012ca:	0f b6 c0             	movzbl %al,%eax
  8012cd:	0f b6 12             	movzbl (%edx),%edx
  8012d0:	29 d0                	sub    %edx,%eax
}
  8012d2:	5d                   	pop    %ebp
  8012d3:	c3                   	ret    

008012d4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8012d4:	55                   	push   %ebp
  8012d5:	89 e5                	mov    %esp,%ebp
  8012d7:	56                   	push   %esi
  8012d8:	53                   	push   %ebx
  8012d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8012dc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012df:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  8012e2:	85 f6                	test   %esi,%esi
  8012e4:	74 23                	je     801309 <strncmp+0x35>
  8012e6:	8a 03                	mov    (%ebx),%al
  8012e8:	84 c0                	test   %al,%al
  8012ea:	74 2b                	je     801317 <strncmp+0x43>
  8012ec:	3a 02                	cmp    (%edx),%al
  8012ee:	75 27                	jne    801317 <strncmp+0x43>
  8012f0:	8d 43 01             	lea    0x1(%ebx),%eax
  8012f3:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  8012f5:	89 c3                	mov    %eax,%ebx
  8012f7:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8012f8:	39 c6                	cmp    %eax,%esi
  8012fa:	74 14                	je     801310 <strncmp+0x3c>
  8012fc:	8a 08                	mov    (%eax),%cl
  8012fe:	84 c9                	test   %cl,%cl
  801300:	74 15                	je     801317 <strncmp+0x43>
  801302:	40                   	inc    %eax
  801303:	3a 0a                	cmp    (%edx),%cl
  801305:	74 ee                	je     8012f5 <strncmp+0x21>
  801307:	eb 0e                	jmp    801317 <strncmp+0x43>
		n--, p++, q++;
	if (n == 0)
		return 0;
  801309:	b8 00 00 00 00       	mov    $0x0,%eax
  80130e:	eb 0f                	jmp    80131f <strncmp+0x4b>
  801310:	b8 00 00 00 00       	mov    $0x0,%eax
  801315:	eb 08                	jmp    80131f <strncmp+0x4b>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801317:	0f b6 03             	movzbl (%ebx),%eax
  80131a:	0f b6 12             	movzbl (%edx),%edx
  80131d:	29 d0                	sub    %edx,%eax
}
  80131f:	5b                   	pop    %ebx
  801320:	5e                   	pop    %esi
  801321:	5d                   	pop    %ebp
  801322:	c3                   	ret    

00801323 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801323:	55                   	push   %ebp
  801324:	89 e5                	mov    %esp,%ebp
  801326:	53                   	push   %ebx
  801327:	8b 45 08             	mov    0x8(%ebp),%eax
  80132a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  80132d:	8a 10                	mov    (%eax),%dl
  80132f:	84 d2                	test   %dl,%dl
  801331:	74 1a                	je     80134d <strchr+0x2a>
  801333:	88 d9                	mov    %bl,%cl
		if (*s == c)
  801335:	38 d3                	cmp    %dl,%bl
  801337:	75 06                	jne    80133f <strchr+0x1c>
  801339:	eb 17                	jmp    801352 <strchr+0x2f>
  80133b:	38 ca                	cmp    %cl,%dl
  80133d:	74 13                	je     801352 <strchr+0x2f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80133f:	40                   	inc    %eax
  801340:	8a 10                	mov    (%eax),%dl
  801342:	84 d2                	test   %dl,%dl
  801344:	75 f5                	jne    80133b <strchr+0x18>
		if (*s == c)
			return (char *) s;
	return 0;
  801346:	b8 00 00 00 00       	mov    $0x0,%eax
  80134b:	eb 05                	jmp    801352 <strchr+0x2f>
  80134d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801352:	5b                   	pop    %ebx
  801353:	5d                   	pop    %ebp
  801354:	c3                   	ret    

00801355 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801355:	55                   	push   %ebp
  801356:	89 e5                	mov    %esp,%ebp
  801358:	53                   	push   %ebx
  801359:	8b 45 08             	mov    0x8(%ebp),%eax
  80135c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  80135f:	8a 10                	mov    (%eax),%dl
  801361:	84 d2                	test   %dl,%dl
  801363:	74 13                	je     801378 <strfind+0x23>
  801365:	88 d9                	mov    %bl,%cl
		if (*s == c)
  801367:	38 d3                	cmp    %dl,%bl
  801369:	75 06                	jne    801371 <strfind+0x1c>
  80136b:	eb 0b                	jmp    801378 <strfind+0x23>
  80136d:	38 ca                	cmp    %cl,%dl
  80136f:	74 07                	je     801378 <strfind+0x23>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801371:	40                   	inc    %eax
  801372:	8a 10                	mov    (%eax),%dl
  801374:	84 d2                	test   %dl,%dl
  801376:	75 f5                	jne    80136d <strfind+0x18>
		if (*s == c)
			break;
	return (char *) s;
}
  801378:	5b                   	pop    %ebx
  801379:	5d                   	pop    %ebp
  80137a:	c3                   	ret    

0080137b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80137b:	55                   	push   %ebp
  80137c:	89 e5                	mov    %esp,%ebp
  80137e:	57                   	push   %edi
  80137f:	56                   	push   %esi
  801380:	53                   	push   %ebx
  801381:	8b 7d 08             	mov    0x8(%ebp),%edi
  801384:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801387:	85 c9                	test   %ecx,%ecx
  801389:	74 36                	je     8013c1 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80138b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801391:	75 28                	jne    8013bb <memset+0x40>
  801393:	f6 c1 03             	test   $0x3,%cl
  801396:	75 23                	jne    8013bb <memset+0x40>
		c &= 0xFF;
  801398:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80139c:	89 d3                	mov    %edx,%ebx
  80139e:	c1 e3 08             	shl    $0x8,%ebx
  8013a1:	89 d6                	mov    %edx,%esi
  8013a3:	c1 e6 18             	shl    $0x18,%esi
  8013a6:	89 d0                	mov    %edx,%eax
  8013a8:	c1 e0 10             	shl    $0x10,%eax
  8013ab:	09 f0                	or     %esi,%eax
  8013ad:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8013af:	89 d8                	mov    %ebx,%eax
  8013b1:	09 d0                	or     %edx,%eax
  8013b3:	c1 e9 02             	shr    $0x2,%ecx
  8013b6:	fc                   	cld    
  8013b7:	f3 ab                	rep stos %eax,%es:(%edi)
  8013b9:	eb 06                	jmp    8013c1 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8013bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013be:	fc                   	cld    
  8013bf:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8013c1:	89 f8                	mov    %edi,%eax
  8013c3:	5b                   	pop    %ebx
  8013c4:	5e                   	pop    %esi
  8013c5:	5f                   	pop    %edi
  8013c6:	5d                   	pop    %ebp
  8013c7:	c3                   	ret    

008013c8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8013c8:	55                   	push   %ebp
  8013c9:	89 e5                	mov    %esp,%ebp
  8013cb:	57                   	push   %edi
  8013cc:	56                   	push   %esi
  8013cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8013d3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8013d6:	39 c6                	cmp    %eax,%esi
  8013d8:	73 33                	jae    80140d <memmove+0x45>
  8013da:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8013dd:	39 d0                	cmp    %edx,%eax
  8013df:	73 2c                	jae    80140d <memmove+0x45>
		s += n;
		d += n;
  8013e1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8013e4:	89 d6                	mov    %edx,%esi
  8013e6:	09 fe                	or     %edi,%esi
  8013e8:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8013ee:	75 13                	jne    801403 <memmove+0x3b>
  8013f0:	f6 c1 03             	test   $0x3,%cl
  8013f3:	75 0e                	jne    801403 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8013f5:	83 ef 04             	sub    $0x4,%edi
  8013f8:	8d 72 fc             	lea    -0x4(%edx),%esi
  8013fb:	c1 e9 02             	shr    $0x2,%ecx
  8013fe:	fd                   	std    
  8013ff:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801401:	eb 07                	jmp    80140a <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801403:	4f                   	dec    %edi
  801404:	8d 72 ff             	lea    -0x1(%edx),%esi
  801407:	fd                   	std    
  801408:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80140a:	fc                   	cld    
  80140b:	eb 1d                	jmp    80142a <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80140d:	89 f2                	mov    %esi,%edx
  80140f:	09 c2                	or     %eax,%edx
  801411:	f6 c2 03             	test   $0x3,%dl
  801414:	75 0f                	jne    801425 <memmove+0x5d>
  801416:	f6 c1 03             	test   $0x3,%cl
  801419:	75 0a                	jne    801425 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
  80141b:	c1 e9 02             	shr    $0x2,%ecx
  80141e:	89 c7                	mov    %eax,%edi
  801420:	fc                   	cld    
  801421:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801423:	eb 05                	jmp    80142a <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801425:	89 c7                	mov    %eax,%edi
  801427:	fc                   	cld    
  801428:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80142a:	5e                   	pop    %esi
  80142b:	5f                   	pop    %edi
  80142c:	5d                   	pop    %ebp
  80142d:	c3                   	ret    

0080142e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80142e:	55                   	push   %ebp
  80142f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801431:	ff 75 10             	pushl  0x10(%ebp)
  801434:	ff 75 0c             	pushl  0xc(%ebp)
  801437:	ff 75 08             	pushl  0x8(%ebp)
  80143a:	e8 89 ff ff ff       	call   8013c8 <memmove>
}
  80143f:	c9                   	leave  
  801440:	c3                   	ret    

00801441 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801441:	55                   	push   %ebp
  801442:	89 e5                	mov    %esp,%ebp
  801444:	57                   	push   %edi
  801445:	56                   	push   %esi
  801446:	53                   	push   %ebx
  801447:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80144a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80144d:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801450:	85 c0                	test   %eax,%eax
  801452:	74 33                	je     801487 <memcmp+0x46>
  801454:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  801457:	8a 13                	mov    (%ebx),%dl
  801459:	8a 0e                	mov    (%esi),%cl
  80145b:	38 ca                	cmp    %cl,%dl
  80145d:	75 13                	jne    801472 <memcmp+0x31>
  80145f:	b8 00 00 00 00       	mov    $0x0,%eax
  801464:	eb 16                	jmp    80147c <memcmp+0x3b>
  801466:	8a 54 03 01          	mov    0x1(%ebx,%eax,1),%dl
  80146a:	40                   	inc    %eax
  80146b:	8a 0c 06             	mov    (%esi,%eax,1),%cl
  80146e:	38 ca                	cmp    %cl,%dl
  801470:	74 0a                	je     80147c <memcmp+0x3b>
			return (int) *s1 - (int) *s2;
  801472:	0f b6 c2             	movzbl %dl,%eax
  801475:	0f b6 c9             	movzbl %cl,%ecx
  801478:	29 c8                	sub    %ecx,%eax
  80147a:	eb 10                	jmp    80148c <memcmp+0x4b>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80147c:	39 f8                	cmp    %edi,%eax
  80147e:	75 e6                	jne    801466 <memcmp+0x25>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801480:	b8 00 00 00 00       	mov    $0x0,%eax
  801485:	eb 05                	jmp    80148c <memcmp+0x4b>
  801487:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80148c:	5b                   	pop    %ebx
  80148d:	5e                   	pop    %esi
  80148e:	5f                   	pop    %edi
  80148f:	5d                   	pop    %ebp
  801490:	c3                   	ret    

00801491 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801491:	55                   	push   %ebp
  801492:	89 e5                	mov    %esp,%ebp
  801494:	53                   	push   %ebx
  801495:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  801498:	89 d0                	mov    %edx,%eax
  80149a:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  80149d:	39 c2                	cmp    %eax,%edx
  80149f:	73 1b                	jae    8014bc <memfind+0x2b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8014a1:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  8014a5:	0f b6 0a             	movzbl (%edx),%ecx
  8014a8:	39 d9                	cmp    %ebx,%ecx
  8014aa:	75 09                	jne    8014b5 <memfind+0x24>
  8014ac:	eb 12                	jmp    8014c0 <memfind+0x2f>
  8014ae:	0f b6 0a             	movzbl (%edx),%ecx
  8014b1:	39 d9                	cmp    %ebx,%ecx
  8014b3:	74 0f                	je     8014c4 <memfind+0x33>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8014b5:	42                   	inc    %edx
  8014b6:	39 d0                	cmp    %edx,%eax
  8014b8:	75 f4                	jne    8014ae <memfind+0x1d>
  8014ba:	eb 0a                	jmp    8014c6 <memfind+0x35>
  8014bc:	89 d0                	mov    %edx,%eax
  8014be:	eb 06                	jmp    8014c6 <memfind+0x35>
		if (*(const unsigned char *) s == (unsigned char) c)
  8014c0:	89 d0                	mov    %edx,%eax
  8014c2:	eb 02                	jmp    8014c6 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8014c4:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8014c6:	5b                   	pop    %ebx
  8014c7:	5d                   	pop    %ebp
  8014c8:	c3                   	ret    

008014c9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8014c9:	55                   	push   %ebp
  8014ca:	89 e5                	mov    %esp,%ebp
  8014cc:	57                   	push   %edi
  8014cd:	56                   	push   %esi
  8014ce:	53                   	push   %ebx
  8014cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8014d2:	eb 01                	jmp    8014d5 <strtol+0xc>
		s++;
  8014d4:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8014d5:	8a 01                	mov    (%ecx),%al
  8014d7:	3c 20                	cmp    $0x20,%al
  8014d9:	74 f9                	je     8014d4 <strtol+0xb>
  8014db:	3c 09                	cmp    $0x9,%al
  8014dd:	74 f5                	je     8014d4 <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  8014df:	3c 2b                	cmp    $0x2b,%al
  8014e1:	75 08                	jne    8014eb <strtol+0x22>
		s++;
  8014e3:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8014e4:	bf 00 00 00 00       	mov    $0x0,%edi
  8014e9:	eb 11                	jmp    8014fc <strtol+0x33>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8014eb:	3c 2d                	cmp    $0x2d,%al
  8014ed:	75 08                	jne    8014f7 <strtol+0x2e>
		s++, neg = 1;
  8014ef:	41                   	inc    %ecx
  8014f0:	bf 01 00 00 00       	mov    $0x1,%edi
  8014f5:	eb 05                	jmp    8014fc <strtol+0x33>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8014f7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8014fc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801500:	0f 84 87 00 00 00    	je     80158d <strtol+0xc4>
  801506:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  80150a:	75 27                	jne    801533 <strtol+0x6a>
  80150c:	80 39 30             	cmpb   $0x30,(%ecx)
  80150f:	75 22                	jne    801533 <strtol+0x6a>
  801511:	e9 88 00 00 00       	jmp    80159e <strtol+0xd5>
		s += 2, base = 16;
  801516:	83 c1 02             	add    $0x2,%ecx
  801519:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  801520:	eb 11                	jmp    801533 <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
  801522:	41                   	inc    %ecx
  801523:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  80152a:	eb 07                	jmp    801533 <strtol+0x6a>
	else if (base == 0)
		base = 10;
  80152c:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  801533:	b8 00 00 00 00       	mov    $0x0,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801538:	8a 11                	mov    (%ecx),%dl
  80153a:	8d 5a d0             	lea    -0x30(%edx),%ebx
  80153d:	80 fb 09             	cmp    $0x9,%bl
  801540:	77 08                	ja     80154a <strtol+0x81>
			dig = *s - '0';
  801542:	0f be d2             	movsbl %dl,%edx
  801545:	83 ea 30             	sub    $0x30,%edx
  801548:	eb 22                	jmp    80156c <strtol+0xa3>
		else if (*s >= 'a' && *s <= 'z')
  80154a:	8d 72 9f             	lea    -0x61(%edx),%esi
  80154d:	89 f3                	mov    %esi,%ebx
  80154f:	80 fb 19             	cmp    $0x19,%bl
  801552:	77 08                	ja     80155c <strtol+0x93>
			dig = *s - 'a' + 10;
  801554:	0f be d2             	movsbl %dl,%edx
  801557:	83 ea 57             	sub    $0x57,%edx
  80155a:	eb 10                	jmp    80156c <strtol+0xa3>
		else if (*s >= 'A' && *s <= 'Z')
  80155c:	8d 72 bf             	lea    -0x41(%edx),%esi
  80155f:	89 f3                	mov    %esi,%ebx
  801561:	80 fb 19             	cmp    $0x19,%bl
  801564:	77 14                	ja     80157a <strtol+0xb1>
			dig = *s - 'A' + 10;
  801566:	0f be d2             	movsbl %dl,%edx
  801569:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  80156c:	3b 55 10             	cmp    0x10(%ebp),%edx
  80156f:	7d 09                	jge    80157a <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  801571:	41                   	inc    %ecx
  801572:	0f af 45 10          	imul   0x10(%ebp),%eax
  801576:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801578:	eb be                	jmp    801538 <strtol+0x6f>

	if (endptr)
  80157a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80157e:	74 05                	je     801585 <strtol+0xbc>
		*endptr = (char *) s;
  801580:	8b 75 0c             	mov    0xc(%ebp),%esi
  801583:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801585:	85 ff                	test   %edi,%edi
  801587:	74 21                	je     8015aa <strtol+0xe1>
  801589:	f7 d8                	neg    %eax
  80158b:	eb 1d                	jmp    8015aa <strtol+0xe1>
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80158d:	80 39 30             	cmpb   $0x30,(%ecx)
  801590:	75 9a                	jne    80152c <strtol+0x63>
  801592:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801596:	0f 84 7a ff ff ff    	je     801516 <strtol+0x4d>
  80159c:	eb 84                	jmp    801522 <strtol+0x59>
  80159e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8015a2:	0f 84 6e ff ff ff    	je     801516 <strtol+0x4d>
  8015a8:	eb 89                	jmp    801533 <strtol+0x6a>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  8015aa:	5b                   	pop    %ebx
  8015ab:	5e                   	pop    %esi
  8015ac:	5f                   	pop    %edi
  8015ad:	5d                   	pop    %ebp
  8015ae:	c3                   	ret    

008015af <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8015af:	55                   	push   %ebp
  8015b0:	89 e5                	mov    %esp,%ebp
  8015b2:	57                   	push   %edi
  8015b3:	56                   	push   %esi
  8015b4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8015ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015bd:	8b 55 08             	mov    0x8(%ebp),%edx
  8015c0:	89 c3                	mov    %eax,%ebx
  8015c2:	89 c7                	mov    %eax,%edi
  8015c4:	89 c6                	mov    %eax,%esi
  8015c6:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8015c8:	5b                   	pop    %ebx
  8015c9:	5e                   	pop    %esi
  8015ca:	5f                   	pop    %edi
  8015cb:	5d                   	pop    %ebp
  8015cc:	c3                   	ret    

008015cd <sys_cgetc>:

int
sys_cgetc(void)
{
  8015cd:	55                   	push   %ebp
  8015ce:	89 e5                	mov    %esp,%ebp
  8015d0:	57                   	push   %edi
  8015d1:	56                   	push   %esi
  8015d2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8015d8:	b8 01 00 00 00       	mov    $0x1,%eax
  8015dd:	89 d1                	mov    %edx,%ecx
  8015df:	89 d3                	mov    %edx,%ebx
  8015e1:	89 d7                	mov    %edx,%edi
  8015e3:	89 d6                	mov    %edx,%esi
  8015e5:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8015e7:	5b                   	pop    %ebx
  8015e8:	5e                   	pop    %esi
  8015e9:	5f                   	pop    %edi
  8015ea:	5d                   	pop    %ebp
  8015eb:	c3                   	ret    

008015ec <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8015ec:	55                   	push   %ebp
  8015ed:	89 e5                	mov    %esp,%ebp
  8015ef:	57                   	push   %edi
  8015f0:	56                   	push   %esi
  8015f1:	53                   	push   %ebx
  8015f2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015f5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015fa:	b8 03 00 00 00       	mov    $0x3,%eax
  8015ff:	8b 55 08             	mov    0x8(%ebp),%edx
  801602:	89 cb                	mov    %ecx,%ebx
  801604:	89 cf                	mov    %ecx,%edi
  801606:	89 ce                	mov    %ecx,%esi
  801608:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80160a:	85 c0                	test   %eax,%eax
  80160c:	7e 17                	jle    801625 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80160e:	83 ec 0c             	sub    $0xc,%esp
  801611:	50                   	push   %eax
  801612:	6a 03                	push   $0x3
  801614:	68 8f 38 80 00       	push   $0x80388f
  801619:	6a 23                	push   $0x23
  80161b:	68 ac 38 80 00       	push   $0x8038ac
  801620:	e8 13 f4 ff ff       	call   800a38 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801625:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801628:	5b                   	pop    %ebx
  801629:	5e                   	pop    %esi
  80162a:	5f                   	pop    %edi
  80162b:	5d                   	pop    %ebp
  80162c:	c3                   	ret    

0080162d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80162d:	55                   	push   %ebp
  80162e:	89 e5                	mov    %esp,%ebp
  801630:	57                   	push   %edi
  801631:	56                   	push   %esi
  801632:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801633:	ba 00 00 00 00       	mov    $0x0,%edx
  801638:	b8 02 00 00 00       	mov    $0x2,%eax
  80163d:	89 d1                	mov    %edx,%ecx
  80163f:	89 d3                	mov    %edx,%ebx
  801641:	89 d7                	mov    %edx,%edi
  801643:	89 d6                	mov    %edx,%esi
  801645:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801647:	5b                   	pop    %ebx
  801648:	5e                   	pop    %esi
  801649:	5f                   	pop    %edi
  80164a:	5d                   	pop    %ebp
  80164b:	c3                   	ret    

0080164c <sys_yield>:

void
sys_yield(void)
{
  80164c:	55                   	push   %ebp
  80164d:	89 e5                	mov    %esp,%ebp
  80164f:	57                   	push   %edi
  801650:	56                   	push   %esi
  801651:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801652:	ba 00 00 00 00       	mov    $0x0,%edx
  801657:	b8 0b 00 00 00       	mov    $0xb,%eax
  80165c:	89 d1                	mov    %edx,%ecx
  80165e:	89 d3                	mov    %edx,%ebx
  801660:	89 d7                	mov    %edx,%edi
  801662:	89 d6                	mov    %edx,%esi
  801664:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801666:	5b                   	pop    %ebx
  801667:	5e                   	pop    %esi
  801668:	5f                   	pop    %edi
  801669:	5d                   	pop    %ebp
  80166a:	c3                   	ret    

0080166b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80166b:	55                   	push   %ebp
  80166c:	89 e5                	mov    %esp,%ebp
  80166e:	57                   	push   %edi
  80166f:	56                   	push   %esi
  801670:	53                   	push   %ebx
  801671:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801674:	be 00 00 00 00       	mov    $0x0,%esi
  801679:	b8 04 00 00 00       	mov    $0x4,%eax
  80167e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801681:	8b 55 08             	mov    0x8(%ebp),%edx
  801684:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801687:	89 f7                	mov    %esi,%edi
  801689:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80168b:	85 c0                	test   %eax,%eax
  80168d:	7e 17                	jle    8016a6 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80168f:	83 ec 0c             	sub    $0xc,%esp
  801692:	50                   	push   %eax
  801693:	6a 04                	push   $0x4
  801695:	68 8f 38 80 00       	push   $0x80388f
  80169a:	6a 23                	push   $0x23
  80169c:	68 ac 38 80 00       	push   $0x8038ac
  8016a1:	e8 92 f3 ff ff       	call   800a38 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8016a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016a9:	5b                   	pop    %ebx
  8016aa:	5e                   	pop    %esi
  8016ab:	5f                   	pop    %edi
  8016ac:	5d                   	pop    %ebp
  8016ad:	c3                   	ret    

008016ae <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8016ae:	55                   	push   %ebp
  8016af:	89 e5                	mov    %esp,%ebp
  8016b1:	57                   	push   %edi
  8016b2:	56                   	push   %esi
  8016b3:	53                   	push   %ebx
  8016b4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8016b7:	b8 05 00 00 00       	mov    $0x5,%eax
  8016bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8016c2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8016c5:	8b 7d 14             	mov    0x14(%ebp),%edi
  8016c8:	8b 75 18             	mov    0x18(%ebp),%esi
  8016cb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8016cd:	85 c0                	test   %eax,%eax
  8016cf:	7e 17                	jle    8016e8 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8016d1:	83 ec 0c             	sub    $0xc,%esp
  8016d4:	50                   	push   %eax
  8016d5:	6a 05                	push   $0x5
  8016d7:	68 8f 38 80 00       	push   $0x80388f
  8016dc:	6a 23                	push   $0x23
  8016de:	68 ac 38 80 00       	push   $0x8038ac
  8016e3:	e8 50 f3 ff ff       	call   800a38 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8016e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016eb:	5b                   	pop    %ebx
  8016ec:	5e                   	pop    %esi
  8016ed:	5f                   	pop    %edi
  8016ee:	5d                   	pop    %ebp
  8016ef:	c3                   	ret    

008016f0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8016f0:	55                   	push   %ebp
  8016f1:	89 e5                	mov    %esp,%ebp
  8016f3:	57                   	push   %edi
  8016f4:	56                   	push   %esi
  8016f5:	53                   	push   %ebx
  8016f6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8016f9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016fe:	b8 06 00 00 00       	mov    $0x6,%eax
  801703:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801706:	8b 55 08             	mov    0x8(%ebp),%edx
  801709:	89 df                	mov    %ebx,%edi
  80170b:	89 de                	mov    %ebx,%esi
  80170d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80170f:	85 c0                	test   %eax,%eax
  801711:	7e 17                	jle    80172a <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801713:	83 ec 0c             	sub    $0xc,%esp
  801716:	50                   	push   %eax
  801717:	6a 06                	push   $0x6
  801719:	68 8f 38 80 00       	push   $0x80388f
  80171e:	6a 23                	push   $0x23
  801720:	68 ac 38 80 00       	push   $0x8038ac
  801725:	e8 0e f3 ff ff       	call   800a38 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80172a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80172d:	5b                   	pop    %ebx
  80172e:	5e                   	pop    %esi
  80172f:	5f                   	pop    %edi
  801730:	5d                   	pop    %ebp
  801731:	c3                   	ret    

00801732 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801732:	55                   	push   %ebp
  801733:	89 e5                	mov    %esp,%ebp
  801735:	57                   	push   %edi
  801736:	56                   	push   %esi
  801737:	53                   	push   %ebx
  801738:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80173b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801740:	b8 08 00 00 00       	mov    $0x8,%eax
  801745:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801748:	8b 55 08             	mov    0x8(%ebp),%edx
  80174b:	89 df                	mov    %ebx,%edi
  80174d:	89 de                	mov    %ebx,%esi
  80174f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801751:	85 c0                	test   %eax,%eax
  801753:	7e 17                	jle    80176c <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801755:	83 ec 0c             	sub    $0xc,%esp
  801758:	50                   	push   %eax
  801759:	6a 08                	push   $0x8
  80175b:	68 8f 38 80 00       	push   $0x80388f
  801760:	6a 23                	push   $0x23
  801762:	68 ac 38 80 00       	push   $0x8038ac
  801767:	e8 cc f2 ff ff       	call   800a38 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80176c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80176f:	5b                   	pop    %ebx
  801770:	5e                   	pop    %esi
  801771:	5f                   	pop    %edi
  801772:	5d                   	pop    %ebp
  801773:	c3                   	ret    

00801774 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801774:	55                   	push   %ebp
  801775:	89 e5                	mov    %esp,%ebp
  801777:	57                   	push   %edi
  801778:	56                   	push   %esi
  801779:	53                   	push   %ebx
  80177a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80177d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801782:	b8 09 00 00 00       	mov    $0x9,%eax
  801787:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80178a:	8b 55 08             	mov    0x8(%ebp),%edx
  80178d:	89 df                	mov    %ebx,%edi
  80178f:	89 de                	mov    %ebx,%esi
  801791:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801793:	85 c0                	test   %eax,%eax
  801795:	7e 17                	jle    8017ae <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801797:	83 ec 0c             	sub    $0xc,%esp
  80179a:	50                   	push   %eax
  80179b:	6a 09                	push   $0x9
  80179d:	68 8f 38 80 00       	push   $0x80388f
  8017a2:	6a 23                	push   $0x23
  8017a4:	68 ac 38 80 00       	push   $0x8038ac
  8017a9:	e8 8a f2 ff ff       	call   800a38 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8017ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017b1:	5b                   	pop    %ebx
  8017b2:	5e                   	pop    %esi
  8017b3:	5f                   	pop    %edi
  8017b4:	5d                   	pop    %ebp
  8017b5:	c3                   	ret    

008017b6 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8017b6:	55                   	push   %ebp
  8017b7:	89 e5                	mov    %esp,%ebp
  8017b9:	57                   	push   %edi
  8017ba:	56                   	push   %esi
  8017bb:	53                   	push   %ebx
  8017bc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8017bf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017c4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8017c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8017cf:	89 df                	mov    %ebx,%edi
  8017d1:	89 de                	mov    %ebx,%esi
  8017d3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8017d5:	85 c0                	test   %eax,%eax
  8017d7:	7e 17                	jle    8017f0 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8017d9:	83 ec 0c             	sub    $0xc,%esp
  8017dc:	50                   	push   %eax
  8017dd:	6a 0a                	push   $0xa
  8017df:	68 8f 38 80 00       	push   $0x80388f
  8017e4:	6a 23                	push   $0x23
  8017e6:	68 ac 38 80 00       	push   $0x8038ac
  8017eb:	e8 48 f2 ff ff       	call   800a38 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8017f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017f3:	5b                   	pop    %ebx
  8017f4:	5e                   	pop    %esi
  8017f5:	5f                   	pop    %edi
  8017f6:	5d                   	pop    %ebp
  8017f7:	c3                   	ret    

008017f8 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8017f8:	55                   	push   %ebp
  8017f9:	89 e5                	mov    %esp,%ebp
  8017fb:	57                   	push   %edi
  8017fc:	56                   	push   %esi
  8017fd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8017fe:	be 00 00 00 00       	mov    $0x0,%esi
  801803:	b8 0c 00 00 00       	mov    $0xc,%eax
  801808:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80180b:	8b 55 08             	mov    0x8(%ebp),%edx
  80180e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801811:	8b 7d 14             	mov    0x14(%ebp),%edi
  801814:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801816:	5b                   	pop    %ebx
  801817:	5e                   	pop    %esi
  801818:	5f                   	pop    %edi
  801819:	5d                   	pop    %ebp
  80181a:	c3                   	ret    

0080181b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80181b:	55                   	push   %ebp
  80181c:	89 e5                	mov    %esp,%ebp
  80181e:	57                   	push   %edi
  80181f:	56                   	push   %esi
  801820:	53                   	push   %ebx
  801821:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801824:	b9 00 00 00 00       	mov    $0x0,%ecx
  801829:	b8 0d 00 00 00       	mov    $0xd,%eax
  80182e:	8b 55 08             	mov    0x8(%ebp),%edx
  801831:	89 cb                	mov    %ecx,%ebx
  801833:	89 cf                	mov    %ecx,%edi
  801835:	89 ce                	mov    %ecx,%esi
  801837:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801839:	85 c0                	test   %eax,%eax
  80183b:	7e 17                	jle    801854 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80183d:	83 ec 0c             	sub    $0xc,%esp
  801840:	50                   	push   %eax
  801841:	6a 0d                	push   $0xd
  801843:	68 8f 38 80 00       	push   $0x80388f
  801848:	6a 23                	push   $0x23
  80184a:	68 ac 38 80 00       	push   $0x8038ac
  80184f:	e8 e4 f1 ff ff       	call   800a38 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801854:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801857:	5b                   	pop    %ebx
  801858:	5e                   	pop    %esi
  801859:	5f                   	pop    %edi
  80185a:	5d                   	pop    %ebp
  80185b:	c3                   	ret    

0080185c <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  80185c:	55                   	push   %ebp
  80185d:	89 e5                	mov    %esp,%ebp
  80185f:	56                   	push   %esi
  801860:	53                   	push   %ebx
  801861:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801864:	8b 18                	mov    (%eax),%ebx
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).
	
	if((err & FEC_WR) == 0){
  801866:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  80186a:	75 14                	jne    801880 <pgfault+0x24>
		panic("pgfault not cause by write \n");
  80186c:	83 ec 04             	sub    $0x4,%esp
  80186f:	68 ba 38 80 00       	push   $0x8038ba
  801874:	6a 1c                	push   $0x1c
  801876:	68 d7 38 80 00       	push   $0x8038d7
  80187b:	e8 b8 f1 ff ff       	call   800a38 <_panic>
	}
 
	if ((uvpt[PGNUM(addr)] & PTE_COW) == 0) 
  801880:	89 d8                	mov    %ebx,%eax
  801882:	c1 e8 0c             	shr    $0xc,%eax
  801885:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80188c:	f6 c4 08             	test   $0x8,%ah
  80188f:	75 14                	jne    8018a5 <pgfault+0x49>
    {
        panic("pgfault not cause by COW \n");
  801891:	83 ec 04             	sub    $0x4,%esp
  801894:	68 e2 38 80 00       	push   $0x8038e2
  801899:	6a 21                	push   $0x21
  80189b:	68 d7 38 80 00       	push   $0x8038d7
  8018a0:	e8 93 f1 ff ff       	call   800a38 <_panic>
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.
	envid_t eid = sys_getenvid();
  8018a5:	e8 83 fd ff ff       	call   80162d <sys_getenvid>
  8018aa:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(eid,(void*)PFTEMP,PTE_P|PTE_W|PTE_U)) < 0)
  8018ac:	83 ec 04             	sub    $0x4,%esp
  8018af:	6a 07                	push   $0x7
  8018b1:	68 00 f0 7f 00       	push   $0x7ff000
  8018b6:	50                   	push   %eax
  8018b7:	e8 af fd ff ff       	call   80166b <sys_page_alloc>
  8018bc:	83 c4 10             	add    $0x10,%esp
  8018bf:	85 c0                	test   %eax,%eax
  8018c1:	79 14                	jns    8018d7 <pgfault+0x7b>
		panic("page alloction failed.\n");
  8018c3:	83 ec 04             	sub    $0x4,%esp
  8018c6:	68 fd 38 80 00       	push   $0x8038fd
  8018cb:	6a 2d                	push   $0x2d
  8018cd:	68 d7 38 80 00       	push   $0x8038d7
  8018d2:	e8 61 f1 ff ff       	call   800a38 <_panic>
	addr = ROUNDDOWN(addr,PGSIZE);
  8018d7:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP,addr,PGSIZE);
  8018dd:	83 ec 04             	sub    $0x4,%esp
  8018e0:	68 00 10 00 00       	push   $0x1000
  8018e5:	53                   	push   %ebx
  8018e6:	68 00 f0 7f 00       	push   $0x7ff000
  8018eb:	e8 d8 fa ff ff       	call   8013c8 <memmove>
	if ((r = sys_page_map(eid, PFTEMP, eid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  8018f0:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  8018f7:	53                   	push   %ebx
  8018f8:	56                   	push   %esi
  8018f9:	68 00 f0 7f 00       	push   $0x7ff000
  8018fe:	56                   	push   %esi
  8018ff:	e8 aa fd ff ff       	call   8016ae <sys_page_map>
  801904:	83 c4 20             	add    $0x20,%esp
  801907:	85 c0                	test   %eax,%eax
  801909:	79 12                	jns    80191d <pgfault+0xc1>
        panic("pgfault: page map failed %e\n", r);
  80190b:	50                   	push   %eax
  80190c:	68 15 39 80 00       	push   $0x803915
  801911:	6a 31                	push   $0x31
  801913:	68 d7 38 80 00       	push   $0x8038d7
  801918:	e8 1b f1 ff ff       	call   800a38 <_panic>
	if ((r = sys_page_unmap(eid, PFTEMP)) < 0)
  80191d:	83 ec 08             	sub    $0x8,%esp
  801920:	68 00 f0 7f 00       	push   $0x7ff000
  801925:	56                   	push   %esi
  801926:	e8 c5 fd ff ff       	call   8016f0 <sys_page_unmap>
  80192b:	83 c4 10             	add    $0x10,%esp
  80192e:	85 c0                	test   %eax,%eax
  801930:	79 12                	jns    801944 <pgfault+0xe8>
        panic("pgfault: page unmap failed %e\n", r);
  801932:	50                   	push   %eax
  801933:	68 84 39 80 00       	push   $0x803984
  801938:	6a 33                	push   $0x33
  80193a:	68 d7 38 80 00       	push   $0x8038d7
  80193f:	e8 f4 f0 ff ff       	call   800a38 <_panic>
	// LAB 4: Your code here.

	// panic("pgfault not implemented");
}
  801944:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801947:	5b                   	pop    %ebx
  801948:	5e                   	pop    %esi
  801949:	5d                   	pop    %ebp
  80194a:	c3                   	ret    

0080194b <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80194b:	55                   	push   %ebp
  80194c:	89 e5                	mov    %esp,%ebp
  80194e:	57                   	push   %edi
  80194f:	56                   	push   %esi
  801950:	53                   	push   %ebx
  801951:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	struct PageInfo* pg = NULL;
	set_pgfault_handler(pgfault);
  801954:	68 5c 18 80 00       	push   $0x80185c
  801959:	e8 5b 15 00 00       	call   802eb9 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80195e:	b8 07 00 00 00       	mov    $0x7,%eax
  801963:	cd 30                	int    $0x30
  801965:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801968:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t eid = sys_exofork();
	if (eid < 0) panic("fork fault.\n");
  80196b:	83 c4 10             	add    $0x10,%esp
  80196e:	85 c0                	test   %eax,%eax
  801970:	79 14                	jns    801986 <fork+0x3b>
  801972:	83 ec 04             	sub    $0x4,%esp
  801975:	68 32 39 80 00       	push   $0x803932
  80197a:	6a 71                	push   $0x71
  80197c:	68 d7 38 80 00       	push   $0x8038d7
  801981:	e8 b2 f0 ff ff       	call   800a38 <_panic>
	if (eid == 0){
  801986:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80198a:	75 25                	jne    8019b1 <fork+0x66>
		thisenv = &envs[ENVX(sys_getenvid())];
  80198c:	e8 9c fc ff ff       	call   80162d <sys_getenvid>
  801991:	25 ff 03 00 00       	and    $0x3ff,%eax
  801996:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80199d:	c1 e0 07             	shl    $0x7,%eax
  8019a0:	29 d0                	sub    %edx,%eax
  8019a2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8019a7:	a3 24 54 80 00       	mov    %eax,0x805424
		return eid;
  8019ac:	e9 61 01 00 00       	jmp    801b12 <fork+0x1c7>
  8019b1:	bb 00 00 80 00       	mov    $0x800000,%ebx
	}
	// copy something to the child page.
	for (uintptr_t i = UTEXT;i <= USTACKTOP;i += PGSIZE){
		if (uvpd[PDX(i)] & PTE_P && (uvpt[PGNUM(i)] & PTE_P)){
  8019b6:	89 d8                	mov    %ebx,%eax
  8019b8:	c1 e8 16             	shr    $0x16,%eax
  8019bb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8019c2:	a8 01                	test   $0x1,%al
  8019c4:	74 52                	je     801a18 <fork+0xcd>
  8019c6:	89 de                	mov    %ebx,%esi
  8019c8:	c1 ee 0c             	shr    $0xc,%esi
  8019cb:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8019d2:	a8 01                	test   $0x1,%al
  8019d4:	74 42                	je     801a18 <fork+0xcd>
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.
	envid_t myenvid = sys_getenvid();
  8019d6:	e8 52 fc ff ff       	call   80162d <sys_getenvid>
  8019db:	89 c7                	mov    %eax,%edi
	pte_t pte = uvpt[pn];
  8019dd:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	int perm = PTE_U | PTE_P;
	if(pte & PTE_W || pte & PTE_COW)
  8019e4:	a9 02 08 00 00       	test   $0x802,%eax
  8019e9:	0f 85 de 00 00 00    	jne    801acd <fork+0x182>
  8019ef:	e9 fb 00 00 00       	jmp    801aef <fork+0x1a4>
		perm |= PTE_COW;
	if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),envid,(void*)(pn*PGSIZE),perm))<0){
		panic("duppage fault :%e\n",r);
  8019f4:	50                   	push   %eax
  8019f5:	68 3f 39 80 00       	push   $0x80393f
  8019fa:	6a 50                	push   $0x50
  8019fc:	68 d7 38 80 00       	push   $0x8038d7
  801a01:	e8 32 f0 ff ff       	call   800a38 <_panic>
	}
	if(perm & PTE_COW){
		if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),myenvid,(void*)(pn*PGSIZE),perm))<0)
			panic("duppage fault :%e\n",r);
  801a06:	50                   	push   %eax
  801a07:	68 3f 39 80 00       	push   $0x80393f
  801a0c:	6a 54                	push   $0x54
  801a0e:	68 d7 38 80 00       	push   $0x8038d7
  801a13:	e8 20 f0 ff ff       	call   800a38 <_panic>
	if (eid == 0){
		thisenv = &envs[ENVX(sys_getenvid())];
		return eid;
	}
	// copy something to the child page.
	for (uintptr_t i = UTEXT;i <= USTACKTOP;i += PGSIZE){
  801a18:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801a1e:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801a24:	75 90                	jne    8019b6 <fork+0x6b>
		if (uvpd[PDX(i)] & PTE_P && (uvpt[PGNUM(i)] & PTE_P)){
			duppage(eid,PGNUM(i));
		}
	}
	int r = sys_page_alloc(eid,(void*)(UXSTACKTOP-PGSIZE),PTE_U|PTE_P|PTE_W);
  801a26:	83 ec 04             	sub    $0x4,%esp
  801a29:	6a 07                	push   $0x7
  801a2b:	68 00 f0 bf ee       	push   $0xeebff000
  801a30:	ff 75 e0             	pushl  -0x20(%ebp)
  801a33:	e8 33 fc ff ff       	call   80166b <sys_page_alloc>
	if (r < 0) panic("fork fault.\n");
  801a38:	83 c4 10             	add    $0x10,%esp
  801a3b:	85 c0                	test   %eax,%eax
  801a3d:	79 14                	jns    801a53 <fork+0x108>
  801a3f:	83 ec 04             	sub    $0x4,%esp
  801a42:	68 32 39 80 00       	push   $0x803932
  801a47:	6a 7d                	push   $0x7d
  801a49:	68 d7 38 80 00       	push   $0x8038d7
  801a4e:	e8 e5 ef ff ff       	call   800a38 <_panic>

	extern void _pgfault_upcall();
    r = sys_env_set_pgfault_upcall(eid, _pgfault_upcall);
  801a53:	83 ec 08             	sub    $0x8,%esp
  801a56:	68 31 2f 80 00       	push   $0x802f31
  801a5b:	ff 75 e0             	pushl  -0x20(%ebp)
  801a5e:	e8 53 fd ff ff       	call   8017b6 <sys_env_set_pgfault_upcall>
    if (r < 0) panic("fork fault 3\n");
  801a63:	83 c4 10             	add    $0x10,%esp
  801a66:	85 c0                	test   %eax,%eax
  801a68:	79 17                	jns    801a81 <fork+0x136>
  801a6a:	83 ec 04             	sub    $0x4,%esp
  801a6d:	68 52 39 80 00       	push   $0x803952
  801a72:	68 81 00 00 00       	push   $0x81
  801a77:	68 d7 38 80 00       	push   $0x8038d7
  801a7c:	e8 b7 ef ff ff       	call   800a38 <_panic>

	if ((r = sys_env_set_status(eid, ENV_RUNNABLE)) < 0)
  801a81:	83 ec 08             	sub    $0x8,%esp
  801a84:	6a 02                	push   $0x2
  801a86:	ff 75 e0             	pushl  -0x20(%ebp)
  801a89:	e8 a4 fc ff ff       	call   801732 <sys_env_set_status>
  801a8e:	83 c4 10             	add    $0x10,%esp
  801a91:	85 c0                	test   %eax,%eax
  801a93:	79 7d                	jns    801b12 <fork+0x1c7>
        panic("fork fault 4\n");
  801a95:	83 ec 04             	sub    $0x4,%esp
  801a98:	68 60 39 80 00       	push   $0x803960
  801a9d:	68 84 00 00 00       	push   $0x84
  801aa2:	68 d7 38 80 00       	push   $0x8038d7
  801aa7:	e8 8c ef ff ff       	call   800a38 <_panic>
		perm |= PTE_COW;
	if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),envid,(void*)(pn*PGSIZE),perm))<0){
		panic("duppage fault :%e\n",r);
	}
	if(perm & PTE_COW){
		if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),myenvid,(void*)(pn*PGSIZE),perm))<0)
  801aac:	83 ec 0c             	sub    $0xc,%esp
  801aaf:	68 05 08 00 00       	push   $0x805
  801ab4:	56                   	push   %esi
  801ab5:	57                   	push   %edi
  801ab6:	56                   	push   %esi
  801ab7:	57                   	push   %edi
  801ab8:	e8 f1 fb ff ff       	call   8016ae <sys_page_map>
  801abd:	83 c4 20             	add    $0x20,%esp
  801ac0:	85 c0                	test   %eax,%eax
  801ac2:	0f 89 50 ff ff ff    	jns    801a18 <fork+0xcd>
  801ac8:	e9 39 ff ff ff       	jmp    801a06 <fork+0xbb>
	envid_t myenvid = sys_getenvid();
	pte_t pte = uvpt[pn];
	int perm = PTE_U | PTE_P;
	if(pte & PTE_W || pte & PTE_COW)
		perm |= PTE_COW;
	if((r = sys_page_map(myenvid,(void*)(pn*PGSIZE),envid,(void*)(pn*PGSIZE),perm))<0){
  801acd:	c1 e6 0c             	shl    $0xc,%esi
  801ad0:	83 ec 0c             	sub    $0xc,%esp
  801ad3:	68 05 08 00 00       	push   $0x805
  801ad8:	56                   	push   %esi
  801ad9:	ff 75 e4             	pushl  -0x1c(%ebp)
  801adc:	56                   	push   %esi
  801add:	57                   	push   %edi
  801ade:	e8 cb fb ff ff       	call   8016ae <sys_page_map>
  801ae3:	83 c4 20             	add    $0x20,%esp
  801ae6:	85 c0                	test   %eax,%eax
  801ae8:	79 c2                	jns    801aac <fork+0x161>
  801aea:	e9 05 ff ff ff       	jmp    8019f4 <fork+0xa9>
  801aef:	c1 e6 0c             	shl    $0xc,%esi
  801af2:	83 ec 0c             	sub    $0xc,%esp
  801af5:	6a 05                	push   $0x5
  801af7:	56                   	push   %esi
  801af8:	ff 75 e4             	pushl  -0x1c(%ebp)
  801afb:	56                   	push   %esi
  801afc:	57                   	push   %edi
  801afd:	e8 ac fb ff ff       	call   8016ae <sys_page_map>
  801b02:	83 c4 20             	add    $0x20,%esp
  801b05:	85 c0                	test   %eax,%eax
  801b07:	0f 89 0b ff ff ff    	jns    801a18 <fork+0xcd>
  801b0d:	e9 e2 fe ff ff       	jmp    8019f4 <fork+0xa9>
    if (r < 0) panic("fork fault 3\n");

	if ((r = sys_env_set_status(eid, ENV_RUNNABLE)) < 0)
        panic("fork fault 4\n");
    return eid;
}
  801b12:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801b15:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b18:	5b                   	pop    %ebx
  801b19:	5e                   	pop    %esi
  801b1a:	5f                   	pop    %edi
  801b1b:	5d                   	pop    %ebp
  801b1c:	c3                   	ret    

00801b1d <sfork>:

// Challenge!
int
sfork(void)
{
  801b1d:	55                   	push   %ebp
  801b1e:	89 e5                	mov    %esp,%ebp
  801b20:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801b23:	68 6e 39 80 00       	push   $0x80396e
  801b28:	68 8c 00 00 00       	push   $0x8c
  801b2d:	68 d7 38 80 00       	push   $0x8038d7
  801b32:	e8 01 ef ff ff       	call   800a38 <_panic>

00801b37 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  801b37:	55                   	push   %ebp
  801b38:	89 e5                	mov    %esp,%ebp
  801b3a:	8b 55 08             	mov    0x8(%ebp),%edx
  801b3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b40:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801b43:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  801b45:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  801b48:	83 3a 01             	cmpl   $0x1,(%edx)
  801b4b:	7e 0b                	jle    801b58 <argstart+0x21>
  801b4d:	85 c9                	test   %ecx,%ecx
  801b4f:	74 0e                	je     801b5f <argstart+0x28>
  801b51:	ba 61 33 80 00       	mov    $0x803361,%edx
  801b56:	eb 0c                	jmp    801b64 <argstart+0x2d>
  801b58:	ba 00 00 00 00       	mov    $0x0,%edx
  801b5d:	eb 05                	jmp    801b64 <argstart+0x2d>
  801b5f:	ba 00 00 00 00       	mov    $0x0,%edx
  801b64:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  801b67:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  801b6e:	5d                   	pop    %ebp
  801b6f:	c3                   	ret    

00801b70 <argnext>:

int
argnext(struct Argstate *args)
{
  801b70:	55                   	push   %ebp
  801b71:	89 e5                	mov    %esp,%ebp
  801b73:	53                   	push   %ebx
  801b74:	83 ec 04             	sub    $0x4,%esp
  801b77:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801b7a:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  801b81:	8b 43 08             	mov    0x8(%ebx),%eax
  801b84:	85 c0                	test   %eax,%eax
  801b86:	74 6a                	je     801bf2 <argnext+0x82>
		return -1;

	if (!*args->curarg) {
  801b88:	80 38 00             	cmpb   $0x0,(%eax)
  801b8b:	75 4b                	jne    801bd8 <argnext+0x68>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  801b8d:	8b 0b                	mov    (%ebx),%ecx
  801b8f:	83 39 01             	cmpl   $0x1,(%ecx)
  801b92:	74 50                	je     801be4 <argnext+0x74>
		    || args->argv[1][0] != '-'
  801b94:	8b 53 04             	mov    0x4(%ebx),%edx
  801b97:	8b 42 04             	mov    0x4(%edx),%eax
  801b9a:	80 38 2d             	cmpb   $0x2d,(%eax)
  801b9d:	75 45                	jne    801be4 <argnext+0x74>
		    || args->argv[1][1] == '\0')
  801b9f:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801ba3:	74 3f                	je     801be4 <argnext+0x74>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801ba5:	40                   	inc    %eax
  801ba6:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801ba9:	83 ec 04             	sub    $0x4,%esp
  801bac:	8b 01                	mov    (%ecx),%eax
  801bae:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801bb5:	50                   	push   %eax
  801bb6:	8d 42 08             	lea    0x8(%edx),%eax
  801bb9:	50                   	push   %eax
  801bba:	83 c2 04             	add    $0x4,%edx
  801bbd:	52                   	push   %edx
  801bbe:	e8 05 f8 ff ff       	call   8013c8 <memmove>
		(*args->argc)--;
  801bc3:	8b 03                	mov    (%ebx),%eax
  801bc5:	ff 08                	decl   (%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801bc7:	8b 43 08             	mov    0x8(%ebx),%eax
  801bca:	83 c4 10             	add    $0x10,%esp
  801bcd:	80 38 2d             	cmpb   $0x2d,(%eax)
  801bd0:	75 06                	jne    801bd8 <argnext+0x68>
  801bd2:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801bd6:	74 0c                	je     801be4 <argnext+0x74>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801bd8:	8b 53 08             	mov    0x8(%ebx),%edx
  801bdb:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  801bde:	42                   	inc    %edx
  801bdf:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  801be2:	eb 13                	jmp    801bf7 <argnext+0x87>

    endofargs:
	args->curarg = 0;
  801be4:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  801beb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801bf0:	eb 05                	jmp    801bf7 <argnext+0x87>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  801bf2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801bf7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bfa:	c9                   	leave  
  801bfb:	c3                   	ret    

00801bfc <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801bfc:	55                   	push   %ebp
  801bfd:	89 e5                	mov    %esp,%ebp
  801bff:	53                   	push   %ebx
  801c00:	83 ec 04             	sub    $0x4,%esp
  801c03:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801c06:	8b 43 08             	mov    0x8(%ebx),%eax
  801c09:	85 c0                	test   %eax,%eax
  801c0b:	74 57                	je     801c64 <argnextvalue+0x68>
		return 0;
	if (*args->curarg) {
  801c0d:	80 38 00             	cmpb   $0x0,(%eax)
  801c10:	74 0c                	je     801c1e <argnextvalue+0x22>
		args->argvalue = args->curarg;
  801c12:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801c15:	c7 43 08 61 33 80 00 	movl   $0x803361,0x8(%ebx)
  801c1c:	eb 41                	jmp    801c5f <argnextvalue+0x63>
	} else if (*args->argc > 1) {
  801c1e:	8b 13                	mov    (%ebx),%edx
  801c20:	83 3a 01             	cmpl   $0x1,(%edx)
  801c23:	7e 2c                	jle    801c51 <argnextvalue+0x55>
		args->argvalue = args->argv[1];
  801c25:	8b 43 04             	mov    0x4(%ebx),%eax
  801c28:	8b 48 04             	mov    0x4(%eax),%ecx
  801c2b:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801c2e:	83 ec 04             	sub    $0x4,%esp
  801c31:	8b 12                	mov    (%edx),%edx
  801c33:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  801c3a:	52                   	push   %edx
  801c3b:	8d 50 08             	lea    0x8(%eax),%edx
  801c3e:	52                   	push   %edx
  801c3f:	83 c0 04             	add    $0x4,%eax
  801c42:	50                   	push   %eax
  801c43:	e8 80 f7 ff ff       	call   8013c8 <memmove>
		(*args->argc)--;
  801c48:	8b 03                	mov    (%ebx),%eax
  801c4a:	ff 08                	decl   (%eax)
  801c4c:	83 c4 10             	add    $0x10,%esp
  801c4f:	eb 0e                	jmp    801c5f <argnextvalue+0x63>
	} else {
		args->argvalue = 0;
  801c51:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801c58:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  801c5f:	8b 43 0c             	mov    0xc(%ebx),%eax
  801c62:	eb 05                	jmp    801c69 <argnextvalue+0x6d>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  801c64:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  801c69:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c6c:	c9                   	leave  
  801c6d:	c3                   	ret    

00801c6e <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  801c6e:	55                   	push   %ebp
  801c6f:	89 e5                	mov    %esp,%ebp
  801c71:	83 ec 08             	sub    $0x8,%esp
  801c74:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801c77:	8b 51 0c             	mov    0xc(%ecx),%edx
  801c7a:	89 d0                	mov    %edx,%eax
  801c7c:	85 d2                	test   %edx,%edx
  801c7e:	75 0c                	jne    801c8c <argvalue+0x1e>
  801c80:	83 ec 0c             	sub    $0xc,%esp
  801c83:	51                   	push   %ecx
  801c84:	e8 73 ff ff ff       	call   801bfc <argnextvalue>
  801c89:	83 c4 10             	add    $0x10,%esp
}
  801c8c:	c9                   	leave  
  801c8d:	c3                   	ret    

00801c8e <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801c8e:	55                   	push   %ebp
  801c8f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801c91:	8b 45 08             	mov    0x8(%ebp),%eax
  801c94:	05 00 00 00 30       	add    $0x30000000,%eax
  801c99:	c1 e8 0c             	shr    $0xc,%eax
}
  801c9c:	5d                   	pop    %ebp
  801c9d:	c3                   	ret    

00801c9e <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801c9e:	55                   	push   %ebp
  801c9f:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801ca1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca4:	05 00 00 00 30       	add    $0x30000000,%eax
  801ca9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801cae:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801cb3:	5d                   	pop    %ebp
  801cb4:	c3                   	ret    

00801cb5 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801cb5:	55                   	push   %ebp
  801cb6:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801cb8:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801cbd:	a8 01                	test   $0x1,%al
  801cbf:	74 34                	je     801cf5 <fd_alloc+0x40>
  801cc1:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801cc6:	a8 01                	test   $0x1,%al
  801cc8:	74 32                	je     801cfc <fd_alloc+0x47>
  801cca:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801ccf:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801cd1:	89 c2                	mov    %eax,%edx
  801cd3:	c1 ea 16             	shr    $0x16,%edx
  801cd6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801cdd:	f6 c2 01             	test   $0x1,%dl
  801ce0:	74 1f                	je     801d01 <fd_alloc+0x4c>
  801ce2:	89 c2                	mov    %eax,%edx
  801ce4:	c1 ea 0c             	shr    $0xc,%edx
  801ce7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801cee:	f6 c2 01             	test   $0x1,%dl
  801cf1:	75 1a                	jne    801d0d <fd_alloc+0x58>
  801cf3:	eb 0c                	jmp    801d01 <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801cf5:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801cfa:	eb 05                	jmp    801d01 <fd_alloc+0x4c>
  801cfc:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  801d01:	8b 45 08             	mov    0x8(%ebp),%eax
  801d04:	89 08                	mov    %ecx,(%eax)
			return 0;
  801d06:	b8 00 00 00 00       	mov    $0x0,%eax
  801d0b:	eb 1a                	jmp    801d27 <fd_alloc+0x72>
  801d0d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801d12:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801d17:	75 b6                	jne    801ccf <fd_alloc+0x1a>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801d19:	8b 45 08             	mov    0x8(%ebp),%eax
  801d1c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  801d22:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801d27:	5d                   	pop    %ebp
  801d28:	c3                   	ret    

00801d29 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801d29:	55                   	push   %ebp
  801d2a:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801d2c:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  801d30:	77 39                	ja     801d6b <fd_lookup+0x42>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801d32:	8b 45 08             	mov    0x8(%ebp),%eax
  801d35:	c1 e0 0c             	shl    $0xc,%eax
  801d38:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801d3d:	89 c2                	mov    %eax,%edx
  801d3f:	c1 ea 16             	shr    $0x16,%edx
  801d42:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801d49:	f6 c2 01             	test   $0x1,%dl
  801d4c:	74 24                	je     801d72 <fd_lookup+0x49>
  801d4e:	89 c2                	mov    %eax,%edx
  801d50:	c1 ea 0c             	shr    $0xc,%edx
  801d53:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801d5a:	f6 c2 01             	test   $0x1,%dl
  801d5d:	74 1a                	je     801d79 <fd_lookup+0x50>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801d5f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d62:	89 02                	mov    %eax,(%edx)
	return 0;
  801d64:	b8 00 00 00 00       	mov    $0x0,%eax
  801d69:	eb 13                	jmp    801d7e <fd_lookup+0x55>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801d6b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801d70:	eb 0c                	jmp    801d7e <fd_lookup+0x55>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801d72:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801d77:	eb 05                	jmp    801d7e <fd_lookup+0x55>
  801d79:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801d7e:	5d                   	pop    %ebp
  801d7f:	c3                   	ret    

00801d80 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801d80:	55                   	push   %ebp
  801d81:	89 e5                	mov    %esp,%ebp
  801d83:	53                   	push   %ebx
  801d84:	83 ec 04             	sub    $0x4,%esp
  801d87:	8b 45 08             	mov    0x8(%ebp),%eax
  801d8a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801d8d:	3b 05 20 40 80 00    	cmp    0x804020,%eax
  801d93:	75 1e                	jne    801db3 <dev_lookup+0x33>
  801d95:	eb 0e                	jmp    801da5 <dev_lookup+0x25>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801d97:	b8 3c 40 80 00       	mov    $0x80403c,%eax
  801d9c:	eb 0c                	jmp    801daa <dev_lookup+0x2a>
  801d9e:	b8 00 40 80 00       	mov    $0x804000,%eax
  801da3:	eb 05                	jmp    801daa <dev_lookup+0x2a>
  801da5:	b8 20 40 80 00       	mov    $0x804020,%eax
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801daa:	89 03                	mov    %eax,(%ebx)
			return 0;
  801dac:	b8 00 00 00 00       	mov    $0x0,%eax
  801db1:	eb 36                	jmp    801de9 <dev_lookup+0x69>
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801db3:	3b 05 3c 40 80 00    	cmp    0x80403c,%eax
  801db9:	74 dc                	je     801d97 <dev_lookup+0x17>
  801dbb:	3b 05 00 40 80 00    	cmp    0x804000,%eax
  801dc1:	74 db                	je     801d9e <dev_lookup+0x1e>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801dc3:	8b 15 24 54 80 00    	mov    0x805424,%edx
  801dc9:	8b 52 48             	mov    0x48(%edx),%edx
  801dcc:	83 ec 04             	sub    $0x4,%esp
  801dcf:	50                   	push   %eax
  801dd0:	52                   	push   %edx
  801dd1:	68 a4 39 80 00       	push   $0x8039a4
  801dd6:	e8 35 ed ff ff       	call   800b10 <cprintf>
	*dev = 0;
  801ddb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801de1:	83 c4 10             	add    $0x10,%esp
  801de4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801de9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dec:	c9                   	leave  
  801ded:	c3                   	ret    

00801dee <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801dee:	55                   	push   %ebp
  801def:	89 e5                	mov    %esp,%ebp
  801df1:	56                   	push   %esi
  801df2:	53                   	push   %ebx
  801df3:	83 ec 10             	sub    $0x10,%esp
  801df6:	8b 75 08             	mov    0x8(%ebp),%esi
  801df9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801dfc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dff:	50                   	push   %eax
  801e00:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801e06:	c1 e8 0c             	shr    $0xc,%eax
  801e09:	50                   	push   %eax
  801e0a:	e8 1a ff ff ff       	call   801d29 <fd_lookup>
  801e0f:	83 c4 08             	add    $0x8,%esp
  801e12:	85 c0                	test   %eax,%eax
  801e14:	78 05                	js     801e1b <fd_close+0x2d>
	    || fd != fd2)
  801e16:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801e19:	74 06                	je     801e21 <fd_close+0x33>
		return (must_exist ? r : 0);
  801e1b:	84 db                	test   %bl,%bl
  801e1d:	74 47                	je     801e66 <fd_close+0x78>
  801e1f:	eb 4a                	jmp    801e6b <fd_close+0x7d>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801e21:	83 ec 08             	sub    $0x8,%esp
  801e24:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e27:	50                   	push   %eax
  801e28:	ff 36                	pushl  (%esi)
  801e2a:	e8 51 ff ff ff       	call   801d80 <dev_lookup>
  801e2f:	89 c3                	mov    %eax,%ebx
  801e31:	83 c4 10             	add    $0x10,%esp
  801e34:	85 c0                	test   %eax,%eax
  801e36:	78 1c                	js     801e54 <fd_close+0x66>
		if (dev->dev_close)
  801e38:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e3b:	8b 40 10             	mov    0x10(%eax),%eax
  801e3e:	85 c0                	test   %eax,%eax
  801e40:	74 0d                	je     801e4f <fd_close+0x61>
			r = (*dev->dev_close)(fd);
  801e42:	83 ec 0c             	sub    $0xc,%esp
  801e45:	56                   	push   %esi
  801e46:	ff d0                	call   *%eax
  801e48:	89 c3                	mov    %eax,%ebx
  801e4a:	83 c4 10             	add    $0x10,%esp
  801e4d:	eb 05                	jmp    801e54 <fd_close+0x66>
		else
			r = 0;
  801e4f:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801e54:	83 ec 08             	sub    $0x8,%esp
  801e57:	56                   	push   %esi
  801e58:	6a 00                	push   $0x0
  801e5a:	e8 91 f8 ff ff       	call   8016f0 <sys_page_unmap>
	return r;
  801e5f:	83 c4 10             	add    $0x10,%esp
  801e62:	89 d8                	mov    %ebx,%eax
  801e64:	eb 05                	jmp    801e6b <fd_close+0x7d>
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
  801e66:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
	return r;
}
  801e6b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e6e:	5b                   	pop    %ebx
  801e6f:	5e                   	pop    %esi
  801e70:	5d                   	pop    %ebp
  801e71:	c3                   	ret    

00801e72 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801e72:	55                   	push   %ebp
  801e73:	89 e5                	mov    %esp,%ebp
  801e75:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e78:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e7b:	50                   	push   %eax
  801e7c:	ff 75 08             	pushl  0x8(%ebp)
  801e7f:	e8 a5 fe ff ff       	call   801d29 <fd_lookup>
  801e84:	83 c4 08             	add    $0x8,%esp
  801e87:	85 c0                	test   %eax,%eax
  801e89:	78 10                	js     801e9b <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801e8b:	83 ec 08             	sub    $0x8,%esp
  801e8e:	6a 01                	push   $0x1
  801e90:	ff 75 f4             	pushl  -0xc(%ebp)
  801e93:	e8 56 ff ff ff       	call   801dee <fd_close>
  801e98:	83 c4 10             	add    $0x10,%esp
}
  801e9b:	c9                   	leave  
  801e9c:	c3                   	ret    

00801e9d <close_all>:

void
close_all(void)
{
  801e9d:	55                   	push   %ebp
  801e9e:	89 e5                	mov    %esp,%ebp
  801ea0:	53                   	push   %ebx
  801ea1:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801ea4:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801ea9:	83 ec 0c             	sub    $0xc,%esp
  801eac:	53                   	push   %ebx
  801ead:	e8 c0 ff ff ff       	call   801e72 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801eb2:	43                   	inc    %ebx
  801eb3:	83 c4 10             	add    $0x10,%esp
  801eb6:	83 fb 20             	cmp    $0x20,%ebx
  801eb9:	75 ee                	jne    801ea9 <close_all+0xc>
		close(i);
}
  801ebb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ebe:	c9                   	leave  
  801ebf:	c3                   	ret    

00801ec0 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801ec0:	55                   	push   %ebp
  801ec1:	89 e5                	mov    %esp,%ebp
  801ec3:	57                   	push   %edi
  801ec4:	56                   	push   %esi
  801ec5:	53                   	push   %ebx
  801ec6:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801ec9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801ecc:	50                   	push   %eax
  801ecd:	ff 75 08             	pushl  0x8(%ebp)
  801ed0:	e8 54 fe ff ff       	call   801d29 <fd_lookup>
  801ed5:	83 c4 08             	add    $0x8,%esp
  801ed8:	85 c0                	test   %eax,%eax
  801eda:	0f 88 c2 00 00 00    	js     801fa2 <dup+0xe2>
		return r;
	close(newfdnum);
  801ee0:	83 ec 0c             	sub    $0xc,%esp
  801ee3:	ff 75 0c             	pushl  0xc(%ebp)
  801ee6:	e8 87 ff ff ff       	call   801e72 <close>

	newfd = INDEX2FD(newfdnum);
  801eeb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801eee:	c1 e3 0c             	shl    $0xc,%ebx
  801ef1:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801ef7:	83 c4 04             	add    $0x4,%esp
  801efa:	ff 75 e4             	pushl  -0x1c(%ebp)
  801efd:	e8 9c fd ff ff       	call   801c9e <fd2data>
  801f02:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801f04:	89 1c 24             	mov    %ebx,(%esp)
  801f07:	e8 92 fd ff ff       	call   801c9e <fd2data>
  801f0c:	83 c4 10             	add    $0x10,%esp
  801f0f:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801f11:	89 f0                	mov    %esi,%eax
  801f13:	c1 e8 16             	shr    $0x16,%eax
  801f16:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801f1d:	a8 01                	test   $0x1,%al
  801f1f:	74 35                	je     801f56 <dup+0x96>
  801f21:	89 f0                	mov    %esi,%eax
  801f23:	c1 e8 0c             	shr    $0xc,%eax
  801f26:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801f2d:	f6 c2 01             	test   $0x1,%dl
  801f30:	74 24                	je     801f56 <dup+0x96>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801f32:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801f39:	83 ec 0c             	sub    $0xc,%esp
  801f3c:	25 07 0e 00 00       	and    $0xe07,%eax
  801f41:	50                   	push   %eax
  801f42:	57                   	push   %edi
  801f43:	6a 00                	push   $0x0
  801f45:	56                   	push   %esi
  801f46:	6a 00                	push   $0x0
  801f48:	e8 61 f7 ff ff       	call   8016ae <sys_page_map>
  801f4d:	89 c6                	mov    %eax,%esi
  801f4f:	83 c4 20             	add    $0x20,%esp
  801f52:	85 c0                	test   %eax,%eax
  801f54:	78 2c                	js     801f82 <dup+0xc2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801f56:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801f59:	89 d0                	mov    %edx,%eax
  801f5b:	c1 e8 0c             	shr    $0xc,%eax
  801f5e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801f65:	83 ec 0c             	sub    $0xc,%esp
  801f68:	25 07 0e 00 00       	and    $0xe07,%eax
  801f6d:	50                   	push   %eax
  801f6e:	53                   	push   %ebx
  801f6f:	6a 00                	push   $0x0
  801f71:	52                   	push   %edx
  801f72:	6a 00                	push   $0x0
  801f74:	e8 35 f7 ff ff       	call   8016ae <sys_page_map>
  801f79:	89 c6                	mov    %eax,%esi
  801f7b:	83 c4 20             	add    $0x20,%esp
  801f7e:	85 c0                	test   %eax,%eax
  801f80:	79 1d                	jns    801f9f <dup+0xdf>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801f82:	83 ec 08             	sub    $0x8,%esp
  801f85:	53                   	push   %ebx
  801f86:	6a 00                	push   $0x0
  801f88:	e8 63 f7 ff ff       	call   8016f0 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801f8d:	83 c4 08             	add    $0x8,%esp
  801f90:	57                   	push   %edi
  801f91:	6a 00                	push   $0x0
  801f93:	e8 58 f7 ff ff       	call   8016f0 <sys_page_unmap>
	return r;
  801f98:	83 c4 10             	add    $0x10,%esp
  801f9b:	89 f0                	mov    %esi,%eax
  801f9d:	eb 03                	jmp    801fa2 <dup+0xe2>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801f9f:	8b 45 0c             	mov    0xc(%ebp),%eax

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801fa2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fa5:	5b                   	pop    %ebx
  801fa6:	5e                   	pop    %esi
  801fa7:	5f                   	pop    %edi
  801fa8:	5d                   	pop    %ebp
  801fa9:	c3                   	ret    

00801faa <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801faa:	55                   	push   %ebp
  801fab:	89 e5                	mov    %esp,%ebp
  801fad:	53                   	push   %ebx
  801fae:	83 ec 14             	sub    $0x14,%esp
  801fb1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801fb4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801fb7:	50                   	push   %eax
  801fb8:	53                   	push   %ebx
  801fb9:	e8 6b fd ff ff       	call   801d29 <fd_lookup>
  801fbe:	83 c4 08             	add    $0x8,%esp
  801fc1:	85 c0                	test   %eax,%eax
  801fc3:	78 67                	js     80202c <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801fc5:	83 ec 08             	sub    $0x8,%esp
  801fc8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fcb:	50                   	push   %eax
  801fcc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fcf:	ff 30                	pushl  (%eax)
  801fd1:	e8 aa fd ff ff       	call   801d80 <dev_lookup>
  801fd6:	83 c4 10             	add    $0x10,%esp
  801fd9:	85 c0                	test   %eax,%eax
  801fdb:	78 4f                	js     80202c <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801fdd:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801fe0:	8b 42 08             	mov    0x8(%edx),%eax
  801fe3:	83 e0 03             	and    $0x3,%eax
  801fe6:	83 f8 01             	cmp    $0x1,%eax
  801fe9:	75 21                	jne    80200c <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801feb:	a1 24 54 80 00       	mov    0x805424,%eax
  801ff0:	8b 40 48             	mov    0x48(%eax),%eax
  801ff3:	83 ec 04             	sub    $0x4,%esp
  801ff6:	53                   	push   %ebx
  801ff7:	50                   	push   %eax
  801ff8:	68 e5 39 80 00       	push   $0x8039e5
  801ffd:	e8 0e eb ff ff       	call   800b10 <cprintf>
		return -E_INVAL;
  802002:	83 c4 10             	add    $0x10,%esp
  802005:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80200a:	eb 20                	jmp    80202c <read+0x82>
	}
	if (!dev->dev_read)
  80200c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80200f:	8b 40 08             	mov    0x8(%eax),%eax
  802012:	85 c0                	test   %eax,%eax
  802014:	74 11                	je     802027 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  802016:	83 ec 04             	sub    $0x4,%esp
  802019:	ff 75 10             	pushl  0x10(%ebp)
  80201c:	ff 75 0c             	pushl  0xc(%ebp)
  80201f:	52                   	push   %edx
  802020:	ff d0                	call   *%eax
  802022:	83 c4 10             	add    $0x10,%esp
  802025:	eb 05                	jmp    80202c <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  802027:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80202c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80202f:	c9                   	leave  
  802030:	c3                   	ret    

00802031 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  802031:	55                   	push   %ebp
  802032:	89 e5                	mov    %esp,%ebp
  802034:	57                   	push   %edi
  802035:	56                   	push   %esi
  802036:	53                   	push   %ebx
  802037:	83 ec 0c             	sub    $0xc,%esp
  80203a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80203d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802040:	85 f6                	test   %esi,%esi
  802042:	74 31                	je     802075 <readn+0x44>
  802044:	b8 00 00 00 00       	mov    $0x0,%eax
  802049:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  80204e:	83 ec 04             	sub    $0x4,%esp
  802051:	89 f2                	mov    %esi,%edx
  802053:	29 c2                	sub    %eax,%edx
  802055:	52                   	push   %edx
  802056:	03 45 0c             	add    0xc(%ebp),%eax
  802059:	50                   	push   %eax
  80205a:	57                   	push   %edi
  80205b:	e8 4a ff ff ff       	call   801faa <read>
		if (m < 0)
  802060:	83 c4 10             	add    $0x10,%esp
  802063:	85 c0                	test   %eax,%eax
  802065:	78 17                	js     80207e <readn+0x4d>
			return m;
		if (m == 0)
  802067:	85 c0                	test   %eax,%eax
  802069:	74 11                	je     80207c <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80206b:	01 c3                	add    %eax,%ebx
  80206d:	89 d8                	mov    %ebx,%eax
  80206f:	39 f3                	cmp    %esi,%ebx
  802071:	72 db                	jb     80204e <readn+0x1d>
  802073:	eb 09                	jmp    80207e <readn+0x4d>
  802075:	b8 00 00 00 00       	mov    $0x0,%eax
  80207a:	eb 02                	jmp    80207e <readn+0x4d>
  80207c:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80207e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802081:	5b                   	pop    %ebx
  802082:	5e                   	pop    %esi
  802083:	5f                   	pop    %edi
  802084:	5d                   	pop    %ebp
  802085:	c3                   	ret    

00802086 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  802086:	55                   	push   %ebp
  802087:	89 e5                	mov    %esp,%ebp
  802089:	53                   	push   %ebx
  80208a:	83 ec 14             	sub    $0x14,%esp
  80208d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802090:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802093:	50                   	push   %eax
  802094:	53                   	push   %ebx
  802095:	e8 8f fc ff ff       	call   801d29 <fd_lookup>
  80209a:	83 c4 08             	add    $0x8,%esp
  80209d:	85 c0                	test   %eax,%eax
  80209f:	78 62                	js     802103 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8020a1:	83 ec 08             	sub    $0x8,%esp
  8020a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020a7:	50                   	push   %eax
  8020a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020ab:	ff 30                	pushl  (%eax)
  8020ad:	e8 ce fc ff ff       	call   801d80 <dev_lookup>
  8020b2:	83 c4 10             	add    $0x10,%esp
  8020b5:	85 c0                	test   %eax,%eax
  8020b7:	78 4a                	js     802103 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8020b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020bc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8020c0:	75 21                	jne    8020e3 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8020c2:	a1 24 54 80 00       	mov    0x805424,%eax
  8020c7:	8b 40 48             	mov    0x48(%eax),%eax
  8020ca:	83 ec 04             	sub    $0x4,%esp
  8020cd:	53                   	push   %ebx
  8020ce:	50                   	push   %eax
  8020cf:	68 01 3a 80 00       	push   $0x803a01
  8020d4:	e8 37 ea ff ff       	call   800b10 <cprintf>
		return -E_INVAL;
  8020d9:	83 c4 10             	add    $0x10,%esp
  8020dc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8020e1:	eb 20                	jmp    802103 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8020e3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8020e6:	8b 52 0c             	mov    0xc(%edx),%edx
  8020e9:	85 d2                	test   %edx,%edx
  8020eb:	74 11                	je     8020fe <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8020ed:	83 ec 04             	sub    $0x4,%esp
  8020f0:	ff 75 10             	pushl  0x10(%ebp)
  8020f3:	ff 75 0c             	pushl  0xc(%ebp)
  8020f6:	50                   	push   %eax
  8020f7:	ff d2                	call   *%edx
  8020f9:	83 c4 10             	add    $0x10,%esp
  8020fc:	eb 05                	jmp    802103 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8020fe:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  802103:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802106:	c9                   	leave  
  802107:	c3                   	ret    

00802108 <seek>:

int
seek(int fdnum, off_t offset)
{
  802108:	55                   	push   %ebp
  802109:	89 e5                	mov    %esp,%ebp
  80210b:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80210e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802111:	50                   	push   %eax
  802112:	ff 75 08             	pushl  0x8(%ebp)
  802115:	e8 0f fc ff ff       	call   801d29 <fd_lookup>
  80211a:	83 c4 08             	add    $0x8,%esp
  80211d:	85 c0                	test   %eax,%eax
  80211f:	78 0e                	js     80212f <seek+0x27>
		return r;
	fd->fd_offset = offset;
  802121:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802124:	8b 55 0c             	mov    0xc(%ebp),%edx
  802127:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80212a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80212f:	c9                   	leave  
  802130:	c3                   	ret    

00802131 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802131:	55                   	push   %ebp
  802132:	89 e5                	mov    %esp,%ebp
  802134:	53                   	push   %ebx
  802135:	83 ec 14             	sub    $0x14,%esp
  802138:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80213b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80213e:	50                   	push   %eax
  80213f:	53                   	push   %ebx
  802140:	e8 e4 fb ff ff       	call   801d29 <fd_lookup>
  802145:	83 c4 08             	add    $0x8,%esp
  802148:	85 c0                	test   %eax,%eax
  80214a:	78 5f                	js     8021ab <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80214c:	83 ec 08             	sub    $0x8,%esp
  80214f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802152:	50                   	push   %eax
  802153:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802156:	ff 30                	pushl  (%eax)
  802158:	e8 23 fc ff ff       	call   801d80 <dev_lookup>
  80215d:	83 c4 10             	add    $0x10,%esp
  802160:	85 c0                	test   %eax,%eax
  802162:	78 47                	js     8021ab <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802164:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802167:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80216b:	75 21                	jne    80218e <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80216d:	a1 24 54 80 00       	mov    0x805424,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802172:	8b 40 48             	mov    0x48(%eax),%eax
  802175:	83 ec 04             	sub    $0x4,%esp
  802178:	53                   	push   %ebx
  802179:	50                   	push   %eax
  80217a:	68 c4 39 80 00       	push   $0x8039c4
  80217f:	e8 8c e9 ff ff       	call   800b10 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  802184:	83 c4 10             	add    $0x10,%esp
  802187:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80218c:	eb 1d                	jmp    8021ab <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  80218e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802191:	8b 52 18             	mov    0x18(%edx),%edx
  802194:	85 d2                	test   %edx,%edx
  802196:	74 0e                	je     8021a6 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  802198:	83 ec 08             	sub    $0x8,%esp
  80219b:	ff 75 0c             	pushl  0xc(%ebp)
  80219e:	50                   	push   %eax
  80219f:	ff d2                	call   *%edx
  8021a1:	83 c4 10             	add    $0x10,%esp
  8021a4:	eb 05                	jmp    8021ab <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8021a6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8021ab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021ae:	c9                   	leave  
  8021af:	c3                   	ret    

008021b0 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8021b0:	55                   	push   %ebp
  8021b1:	89 e5                	mov    %esp,%ebp
  8021b3:	53                   	push   %ebx
  8021b4:	83 ec 14             	sub    $0x14,%esp
  8021b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8021ba:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8021bd:	50                   	push   %eax
  8021be:	ff 75 08             	pushl  0x8(%ebp)
  8021c1:	e8 63 fb ff ff       	call   801d29 <fd_lookup>
  8021c6:	83 c4 08             	add    $0x8,%esp
  8021c9:	85 c0                	test   %eax,%eax
  8021cb:	78 52                	js     80221f <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8021cd:	83 ec 08             	sub    $0x8,%esp
  8021d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021d3:	50                   	push   %eax
  8021d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021d7:	ff 30                	pushl  (%eax)
  8021d9:	e8 a2 fb ff ff       	call   801d80 <dev_lookup>
  8021de:	83 c4 10             	add    $0x10,%esp
  8021e1:	85 c0                	test   %eax,%eax
  8021e3:	78 3a                	js     80221f <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  8021e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021e8:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8021ec:	74 2c                	je     80221a <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8021ee:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8021f1:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8021f8:	00 00 00 
	stat->st_isdir = 0;
  8021fb:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802202:	00 00 00 
	stat->st_dev = dev;
  802205:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80220b:	83 ec 08             	sub    $0x8,%esp
  80220e:	53                   	push   %ebx
  80220f:	ff 75 f0             	pushl  -0x10(%ebp)
  802212:	ff 50 14             	call   *0x14(%eax)
  802215:	83 c4 10             	add    $0x10,%esp
  802218:	eb 05                	jmp    80221f <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80221a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80221f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802222:	c9                   	leave  
  802223:	c3                   	ret    

00802224 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  802224:	55                   	push   %ebp
  802225:	89 e5                	mov    %esp,%ebp
  802227:	56                   	push   %esi
  802228:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  802229:	83 ec 08             	sub    $0x8,%esp
  80222c:	6a 00                	push   $0x0
  80222e:	ff 75 08             	pushl  0x8(%ebp)
  802231:	e8 75 01 00 00       	call   8023ab <open>
  802236:	89 c3                	mov    %eax,%ebx
  802238:	83 c4 10             	add    $0x10,%esp
  80223b:	85 c0                	test   %eax,%eax
  80223d:	78 1d                	js     80225c <stat+0x38>
		return fd;
	r = fstat(fd, stat);
  80223f:	83 ec 08             	sub    $0x8,%esp
  802242:	ff 75 0c             	pushl  0xc(%ebp)
  802245:	50                   	push   %eax
  802246:	e8 65 ff ff ff       	call   8021b0 <fstat>
  80224b:	89 c6                	mov    %eax,%esi
	close(fd);
  80224d:	89 1c 24             	mov    %ebx,(%esp)
  802250:	e8 1d fc ff ff       	call   801e72 <close>
	return r;
  802255:	83 c4 10             	add    $0x10,%esp
  802258:	89 f0                	mov    %esi,%eax
  80225a:	eb 00                	jmp    80225c <stat+0x38>
}
  80225c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80225f:	5b                   	pop    %ebx
  802260:	5e                   	pop    %esi
  802261:	5d                   	pop    %ebp
  802262:	c3                   	ret    

00802263 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  802263:	55                   	push   %ebp
  802264:	89 e5                	mov    %esp,%ebp
  802266:	56                   	push   %esi
  802267:	53                   	push   %ebx
  802268:	89 c6                	mov    %eax,%esi
  80226a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80226c:	83 3d 20 54 80 00 00 	cmpl   $0x0,0x805420
  802273:	75 12                	jne    802287 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802275:	83 ec 0c             	sub    $0xc,%esp
  802278:	6a 01                	push   $0x1
  80227a:	e8 ac 0d 00 00       	call   80302b <ipc_find_env>
  80227f:	a3 20 54 80 00       	mov    %eax,0x805420
  802284:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802287:	6a 07                	push   $0x7
  802289:	68 00 60 80 00       	push   $0x806000
  80228e:	56                   	push   %esi
  80228f:	ff 35 20 54 80 00    	pushl  0x805420
  802295:	e8 32 0d 00 00       	call   802fcc <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80229a:	83 c4 0c             	add    $0xc,%esp
  80229d:	6a 00                	push   $0x0
  80229f:	53                   	push   %ebx
  8022a0:	6a 00                	push   $0x0
  8022a2:	e8 b0 0c 00 00       	call   802f57 <ipc_recv>
}
  8022a7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022aa:	5b                   	pop    %ebx
  8022ab:	5e                   	pop    %esi
  8022ac:	5d                   	pop    %ebp
  8022ad:	c3                   	ret    

008022ae <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8022ae:	55                   	push   %ebp
  8022af:	89 e5                	mov    %esp,%ebp
  8022b1:	53                   	push   %ebx
  8022b2:	83 ec 04             	sub    $0x4,%esp
  8022b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8022b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8022bb:	8b 40 0c             	mov    0xc(%eax),%eax
  8022be:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8022c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8022c8:	b8 05 00 00 00       	mov    $0x5,%eax
  8022cd:	e8 91 ff ff ff       	call   802263 <fsipc>
  8022d2:	85 c0                	test   %eax,%eax
  8022d4:	78 2c                	js     802302 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8022d6:	83 ec 08             	sub    $0x8,%esp
  8022d9:	68 00 60 80 00       	push   $0x806000
  8022de:	53                   	push   %ebx
  8022df:	e8 17 ef ff ff       	call   8011fb <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8022e4:	a1 80 60 80 00       	mov    0x806080,%eax
  8022e9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8022ef:	a1 84 60 80 00       	mov    0x806084,%eax
  8022f4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8022fa:	83 c4 10             	add    $0x10,%esp
  8022fd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802302:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802305:	c9                   	leave  
  802306:	c3                   	ret    

00802307 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  802307:	55                   	push   %ebp
  802308:	89 e5                	mov    %esp,%ebp
  80230a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80230d:	8b 45 08             	mov    0x8(%ebp),%eax
  802310:	8b 40 0c             	mov    0xc(%eax),%eax
  802313:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  802318:	ba 00 00 00 00       	mov    $0x0,%edx
  80231d:	b8 06 00 00 00       	mov    $0x6,%eax
  802322:	e8 3c ff ff ff       	call   802263 <fsipc>
}
  802327:	c9                   	leave  
  802328:	c3                   	ret    

00802329 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  802329:	55                   	push   %ebp
  80232a:	89 e5                	mov    %esp,%ebp
  80232c:	56                   	push   %esi
  80232d:	53                   	push   %ebx
  80232e:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  802331:	8b 45 08             	mov    0x8(%ebp),%eax
  802334:	8b 40 0c             	mov    0xc(%eax),%eax
  802337:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  80233c:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  802342:	ba 00 00 00 00       	mov    $0x0,%edx
  802347:	b8 03 00 00 00       	mov    $0x3,%eax
  80234c:	e8 12 ff ff ff       	call   802263 <fsipc>
  802351:	89 c3                	mov    %eax,%ebx
  802353:	85 c0                	test   %eax,%eax
  802355:	78 4b                	js     8023a2 <devfile_read+0x79>
		return r;
	assert(r <= n);
  802357:	39 c6                	cmp    %eax,%esi
  802359:	73 16                	jae    802371 <devfile_read+0x48>
  80235b:	68 1e 3a 80 00       	push   $0x803a1e
  802360:	68 8f 34 80 00       	push   $0x80348f
  802365:	6a 7a                	push   $0x7a
  802367:	68 25 3a 80 00       	push   $0x803a25
  80236c:	e8 c7 e6 ff ff       	call   800a38 <_panic>
	assert(r <= PGSIZE);
  802371:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802376:	7e 16                	jle    80238e <devfile_read+0x65>
  802378:	68 30 3a 80 00       	push   $0x803a30
  80237d:	68 8f 34 80 00       	push   $0x80348f
  802382:	6a 7b                	push   $0x7b
  802384:	68 25 3a 80 00       	push   $0x803a25
  802389:	e8 aa e6 ff ff       	call   800a38 <_panic>
	memmove(buf, &fsipcbuf, r);
  80238e:	83 ec 04             	sub    $0x4,%esp
  802391:	50                   	push   %eax
  802392:	68 00 60 80 00       	push   $0x806000
  802397:	ff 75 0c             	pushl  0xc(%ebp)
  80239a:	e8 29 f0 ff ff       	call   8013c8 <memmove>
	return r;
  80239f:	83 c4 10             	add    $0x10,%esp
}
  8023a2:	89 d8                	mov    %ebx,%eax
  8023a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023a7:	5b                   	pop    %ebx
  8023a8:	5e                   	pop    %esi
  8023a9:	5d                   	pop    %ebp
  8023aa:	c3                   	ret    

008023ab <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8023ab:	55                   	push   %ebp
  8023ac:	89 e5                	mov    %esp,%ebp
  8023ae:	53                   	push   %ebx
  8023af:	83 ec 20             	sub    $0x20,%esp
  8023b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8023b5:	53                   	push   %ebx
  8023b6:	e8 e9 ed ff ff       	call   8011a4 <strlen>
  8023bb:	83 c4 10             	add    $0x10,%esp
  8023be:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8023c3:	7f 63                	jg     802428 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8023c5:	83 ec 0c             	sub    $0xc,%esp
  8023c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023cb:	50                   	push   %eax
  8023cc:	e8 e4 f8 ff ff       	call   801cb5 <fd_alloc>
  8023d1:	83 c4 10             	add    $0x10,%esp
  8023d4:	85 c0                	test   %eax,%eax
  8023d6:	78 55                	js     80242d <open+0x82>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8023d8:	83 ec 08             	sub    $0x8,%esp
  8023db:	53                   	push   %ebx
  8023dc:	68 00 60 80 00       	push   $0x806000
  8023e1:	e8 15 ee ff ff       	call   8011fb <strcpy>
	fsipcbuf.open.req_omode = mode;
  8023e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023e9:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8023ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8023f1:	b8 01 00 00 00       	mov    $0x1,%eax
  8023f6:	e8 68 fe ff ff       	call   802263 <fsipc>
  8023fb:	89 c3                	mov    %eax,%ebx
  8023fd:	83 c4 10             	add    $0x10,%esp
  802400:	85 c0                	test   %eax,%eax
  802402:	79 14                	jns    802418 <open+0x6d>
		fd_close(fd, 0);
  802404:	83 ec 08             	sub    $0x8,%esp
  802407:	6a 00                	push   $0x0
  802409:	ff 75 f4             	pushl  -0xc(%ebp)
  80240c:	e8 dd f9 ff ff       	call   801dee <fd_close>
		return r;
  802411:	83 c4 10             	add    $0x10,%esp
  802414:	89 d8                	mov    %ebx,%eax
  802416:	eb 15                	jmp    80242d <open+0x82>
	}

	return fd2num(fd);
  802418:	83 ec 0c             	sub    $0xc,%esp
  80241b:	ff 75 f4             	pushl  -0xc(%ebp)
  80241e:	e8 6b f8 ff ff       	call   801c8e <fd2num>
  802423:	83 c4 10             	add    $0x10,%esp
  802426:	eb 05                	jmp    80242d <open+0x82>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  802428:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80242d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802430:	c9                   	leave  
  802431:	c3                   	ret    

00802432 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  802432:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  802436:	7e 38                	jle    802470 <writebuf+0x3e>
};


static void
writebuf(struct printbuf *b)
{
  802438:	55                   	push   %ebp
  802439:	89 e5                	mov    %esp,%ebp
  80243b:	53                   	push   %ebx
  80243c:	83 ec 08             	sub    $0x8,%esp
  80243f:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  802441:	ff 70 04             	pushl  0x4(%eax)
  802444:	8d 40 10             	lea    0x10(%eax),%eax
  802447:	50                   	push   %eax
  802448:	ff 33                	pushl  (%ebx)
  80244a:	e8 37 fc ff ff       	call   802086 <write>
		if (result > 0)
  80244f:	83 c4 10             	add    $0x10,%esp
  802452:	85 c0                	test   %eax,%eax
  802454:	7e 03                	jle    802459 <writebuf+0x27>
			b->result += result;
  802456:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  802459:	3b 43 04             	cmp    0x4(%ebx),%eax
  80245c:	74 0e                	je     80246c <writebuf+0x3a>
			b->error = (result < 0 ? result : 0);
  80245e:	89 c2                	mov    %eax,%edx
  802460:	85 c0                	test   %eax,%eax
  802462:	7e 05                	jle    802469 <writebuf+0x37>
  802464:	ba 00 00 00 00       	mov    $0x0,%edx
  802469:	89 53 0c             	mov    %edx,0xc(%ebx)
	}
}
  80246c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80246f:	c9                   	leave  
  802470:	c3                   	ret    

00802471 <putch>:

static void
putch(int ch, void *thunk)
{
  802471:	55                   	push   %ebp
  802472:	89 e5                	mov    %esp,%ebp
  802474:	53                   	push   %ebx
  802475:	83 ec 04             	sub    $0x4,%esp
  802478:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  80247b:	8b 53 04             	mov    0x4(%ebx),%edx
  80247e:	8d 42 01             	lea    0x1(%edx),%eax
  802481:	89 43 04             	mov    %eax,0x4(%ebx)
  802484:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802487:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  80248b:	3d 00 01 00 00       	cmp    $0x100,%eax
  802490:	75 0e                	jne    8024a0 <putch+0x2f>
		writebuf(b);
  802492:	89 d8                	mov    %ebx,%eax
  802494:	e8 99 ff ff ff       	call   802432 <writebuf>
		b->idx = 0;
  802499:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8024a0:	83 c4 04             	add    $0x4,%esp
  8024a3:	5b                   	pop    %ebx
  8024a4:	5d                   	pop    %ebp
  8024a5:	c3                   	ret    

008024a6 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8024a6:	55                   	push   %ebp
  8024a7:	89 e5                	mov    %esp,%ebp
  8024a9:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8024af:	8b 45 08             	mov    0x8(%ebp),%eax
  8024b2:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8024b8:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8024bf:	00 00 00 
	b.result = 0;
  8024c2:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8024c9:	00 00 00 
	b.error = 1;
  8024cc:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8024d3:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8024d6:	ff 75 10             	pushl  0x10(%ebp)
  8024d9:	ff 75 0c             	pushl  0xc(%ebp)
  8024dc:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8024e2:	50                   	push   %eax
  8024e3:	68 71 24 80 00       	push   $0x802471
  8024e8:	e8 5a e7 ff ff       	call   800c47 <vprintfmt>
	if (b.idx > 0)
  8024ed:	83 c4 10             	add    $0x10,%esp
  8024f0:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8024f7:	7e 0b                	jle    802504 <vfprintf+0x5e>
		writebuf(&b);
  8024f9:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8024ff:	e8 2e ff ff ff       	call   802432 <writebuf>

	return (b.result ? b.result : b.error);
  802504:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80250a:	85 c0                	test   %eax,%eax
  80250c:	75 06                	jne    802514 <vfprintf+0x6e>
  80250e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  802514:	c9                   	leave  
  802515:	c3                   	ret    

00802516 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  802516:	55                   	push   %ebp
  802517:	89 e5                	mov    %esp,%ebp
  802519:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80251c:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  80251f:	50                   	push   %eax
  802520:	ff 75 0c             	pushl  0xc(%ebp)
  802523:	ff 75 08             	pushl  0x8(%ebp)
  802526:	e8 7b ff ff ff       	call   8024a6 <vfprintf>
	va_end(ap);

	return cnt;
}
  80252b:	c9                   	leave  
  80252c:	c3                   	ret    

0080252d <printf>:

int
printf(const char *fmt, ...)
{
  80252d:	55                   	push   %ebp
  80252e:	89 e5                	mov    %esp,%ebp
  802530:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  802533:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  802536:	50                   	push   %eax
  802537:	ff 75 08             	pushl  0x8(%ebp)
  80253a:	6a 01                	push   $0x1
  80253c:	e8 65 ff ff ff       	call   8024a6 <vfprintf>
	va_end(ap);

	return cnt;
}
  802541:	c9                   	leave  
  802542:	c3                   	ret    

00802543 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  802543:	55                   	push   %ebp
  802544:	89 e5                	mov    %esp,%ebp
  802546:	57                   	push   %edi
  802547:	56                   	push   %esi
  802548:	53                   	push   %ebx
  802549:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  80254f:	6a 00                	push   $0x0
  802551:	ff 75 08             	pushl  0x8(%ebp)
  802554:	e8 52 fe ff ff       	call   8023ab <open>
  802559:	89 c1                	mov    %eax,%ecx
  80255b:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  802561:	83 c4 10             	add    $0x10,%esp
  802564:	85 c0                	test   %eax,%eax
  802566:	0f 88 6f 04 00 00    	js     8029db <spawn+0x498>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  80256c:	83 ec 04             	sub    $0x4,%esp
  80256f:	68 00 02 00 00       	push   $0x200
  802574:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  80257a:	50                   	push   %eax
  80257b:	51                   	push   %ecx
  80257c:	e8 b0 fa ff ff       	call   802031 <readn>
  802581:	83 c4 10             	add    $0x10,%esp
  802584:	3d 00 02 00 00       	cmp    $0x200,%eax
  802589:	75 0c                	jne    802597 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  80258b:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  802592:	45 4c 46 
  802595:	74 33                	je     8025ca <spawn+0x87>
		close(fd);
  802597:	83 ec 0c             	sub    $0xc,%esp
  80259a:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8025a0:	e8 cd f8 ff ff       	call   801e72 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8025a5:	83 c4 0c             	add    $0xc,%esp
  8025a8:	68 7f 45 4c 46       	push   $0x464c457f
  8025ad:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  8025b3:	68 3c 3a 80 00       	push   $0x803a3c
  8025b8:	e8 53 e5 ff ff       	call   800b10 <cprintf>
		return -E_NOT_EXEC;
  8025bd:	83 c4 10             	add    $0x10,%esp
  8025c0:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  8025c5:	e9 71 04 00 00       	jmp    802a3b <spawn+0x4f8>
  8025ca:	b8 07 00 00 00       	mov    $0x7,%eax
  8025cf:	cd 30                	int    $0x30
  8025d1:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  8025d7:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  8025dd:	85 c0                	test   %eax,%eax
  8025df:	0f 88 fe 03 00 00    	js     8029e3 <spawn+0x4a0>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  8025e5:	89 c6                	mov    %eax,%esi
  8025e7:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  8025ed:	8d 04 b5 00 00 00 00 	lea    0x0(,%esi,4),%eax
  8025f4:	c1 e6 07             	shl    $0x7,%esi
  8025f7:	29 c6                	sub    %eax,%esi
  8025f9:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  8025ff:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  802605:	b9 11 00 00 00       	mov    $0x11,%ecx
  80260a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  80260c:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  802612:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  802618:	8b 45 0c             	mov    0xc(%ebp),%eax
  80261b:	8b 00                	mov    (%eax),%eax
  80261d:	85 c0                	test   %eax,%eax
  80261f:	74 3a                	je     80265b <spawn+0x118>
  802621:	bb 00 00 00 00       	mov    $0x0,%ebx
  802626:	be 00 00 00 00       	mov    $0x0,%esi
  80262b:	8b 7d 0c             	mov    0xc(%ebp),%edi
		string_size += strlen(argv[argc]) + 1;
  80262e:	83 ec 0c             	sub    $0xc,%esp
  802631:	50                   	push   %eax
  802632:	e8 6d eb ff ff       	call   8011a4 <strlen>
  802637:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80263b:	43                   	inc    %ebx
  80263c:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  802643:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  802646:	83 c4 10             	add    $0x10,%esp
  802649:	85 c0                	test   %eax,%eax
  80264b:	75 e1                	jne    80262e <spawn+0xeb>
  80264d:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  802653:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
  802659:	eb 1e                	jmp    802679 <spawn+0x136>
  80265b:	c7 85 80 fd ff ff 00 	movl   $0x0,-0x280(%ebp)
  802662:	00 00 00 
  802665:	c7 85 88 fd ff ff 00 	movl   $0x0,-0x278(%ebp)
  80266c:	00 00 00 
  80266f:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  802674:	be 00 00 00 00       	mov    $0x0,%esi
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  802679:	bf 00 10 40 00       	mov    $0x401000,%edi
  80267e:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  802680:	89 fa                	mov    %edi,%edx
  802682:	83 e2 fc             	and    $0xfffffffc,%edx
  802685:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  80268c:	29 c2                	sub    %eax,%edx
  80268e:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  802694:	8d 42 f8             	lea    -0x8(%edx),%eax
  802697:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  80269c:	0f 86 51 03 00 00    	jbe    8029f3 <spawn+0x4b0>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8026a2:	83 ec 04             	sub    $0x4,%esp
  8026a5:	6a 07                	push   $0x7
  8026a7:	68 00 00 40 00       	push   $0x400000
  8026ac:	6a 00                	push   $0x0
  8026ae:	e8 b8 ef ff ff       	call   80166b <sys_page_alloc>
  8026b3:	83 c4 10             	add    $0x10,%esp
  8026b6:	85 c0                	test   %eax,%eax
  8026b8:	0f 88 3c 03 00 00    	js     8029fa <spawn+0x4b7>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8026be:	85 db                	test   %ebx,%ebx
  8026c0:	7e 44                	jle    802706 <spawn+0x1c3>
  8026c2:	be 00 00 00 00       	mov    $0x0,%esi
  8026c7:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  8026cd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
		argv_store[i] = UTEMP2USTACK(string_store);
  8026d0:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  8026d6:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  8026dc:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  8026df:	83 ec 08             	sub    $0x8,%esp
  8026e2:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8026e5:	57                   	push   %edi
  8026e6:	e8 10 eb ff ff       	call   8011fb <strcpy>
		string_store += strlen(argv[i]) + 1;
  8026eb:	83 c4 04             	add    $0x4,%esp
  8026ee:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8026f1:	e8 ae ea ff ff       	call   8011a4 <strlen>
  8026f6:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8026fa:	46                   	inc    %esi
  8026fb:	83 c4 10             	add    $0x10,%esp
  8026fe:	3b b5 90 fd ff ff    	cmp    -0x270(%ebp),%esi
  802704:	75 ca                	jne    8026d0 <spawn+0x18d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  802706:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  80270c:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  802712:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  802719:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  80271f:	74 19                	je     80273a <spawn+0x1f7>
  802721:	68 b0 3a 80 00       	push   $0x803ab0
  802726:	68 8f 34 80 00       	push   $0x80348f
  80272b:	68 f1 00 00 00       	push   $0xf1
  802730:	68 56 3a 80 00       	push   $0x803a56
  802735:	e8 fe e2 ff ff       	call   800a38 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  80273a:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  802740:	89 c8                	mov    %ecx,%eax
  802742:	2d 00 30 80 11       	sub    $0x11803000,%eax
  802747:	89 41 fc             	mov    %eax,-0x4(%ecx)
	argv_store[-2] = argc;
  80274a:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802750:	89 41 f8             	mov    %eax,-0x8(%ecx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  802753:	8d 81 f8 cf 7f ee    	lea    -0x11803008(%ecx),%eax
  802759:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  80275f:	83 ec 0c             	sub    $0xc,%esp
  802762:	6a 07                	push   $0x7
  802764:	68 00 d0 bf ee       	push   $0xeebfd000
  802769:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80276f:	68 00 00 40 00       	push   $0x400000
  802774:	6a 00                	push   $0x0
  802776:	e8 33 ef ff ff       	call   8016ae <sys_page_map>
  80277b:	89 c3                	mov    %eax,%ebx
  80277d:	83 c4 20             	add    $0x20,%esp
  802780:	85 c0                	test   %eax,%eax
  802782:	0f 88 a1 02 00 00    	js     802a29 <spawn+0x4e6>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  802788:	83 ec 08             	sub    $0x8,%esp
  80278b:	68 00 00 40 00       	push   $0x400000
  802790:	6a 00                	push   $0x0
  802792:	e8 59 ef ff ff       	call   8016f0 <sys_page_unmap>
  802797:	89 c3                	mov    %eax,%ebx
  802799:	83 c4 10             	add    $0x10,%esp
  80279c:	85 c0                	test   %eax,%eax
  80279e:	0f 88 85 02 00 00    	js     802a29 <spawn+0x4e6>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  8027a4:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  8027aa:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  8027b1:	89 85 78 fd ff ff    	mov    %eax,-0x288(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8027b7:	66 83 bd 14 fe ff ff 	cmpw   $0x0,-0x1ec(%ebp)
  8027be:	00 
  8027bf:	0f 84 ab 01 00 00    	je     802970 <spawn+0x42d>
  8027c5:	c7 85 80 fd ff ff 00 	movl   $0x0,-0x280(%ebp)
  8027cc:	00 00 00 
		if (ph->p_type != ELF_PROG_LOAD)
  8027cf:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  8027d5:	83 38 01             	cmpl   $0x1,(%eax)
  8027d8:	0f 85 70 01 00 00    	jne    80294e <spawn+0x40b>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  8027de:	89 c1                	mov    %eax,%ecx
  8027e0:	8b 40 18             	mov    0x18(%eax),%eax
  8027e3:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  8027e6:	83 f8 01             	cmp    $0x1,%eax
  8027e9:	19 c0                	sbb    %eax,%eax
  8027eb:	83 e0 fe             	and    $0xfffffffe,%eax
  8027ee:	83 c0 07             	add    $0x7,%eax
  8027f1:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  8027f7:	89 c8                	mov    %ecx,%eax
  8027f9:	8b 49 04             	mov    0x4(%ecx),%ecx
  8027fc:	89 8d 7c fd ff ff    	mov    %ecx,-0x284(%ebp)
  802802:	8b 50 10             	mov    0x10(%eax),%edx
  802805:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)
  80280b:	8b 78 14             	mov    0x14(%eax),%edi
  80280e:	89 bd 90 fd ff ff    	mov    %edi,-0x270(%ebp)
  802814:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  802817:	89 f0                	mov    %esi,%eax
  802819:	25 ff 0f 00 00       	and    $0xfff,%eax
  80281e:	74 1a                	je     80283a <spawn+0x2f7>
		va -= i;
  802820:	29 c6                	sub    %eax,%esi
		memsz += i;
  802822:	01 c7                	add    %eax,%edi
  802824:	89 bd 90 fd ff ff    	mov    %edi,-0x270(%ebp)
		filesz += i;
  80282a:	01 c2                	add    %eax,%edx
  80282c:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)
		fileoffset -= i;
  802832:	29 c1                	sub    %eax,%ecx
  802834:	89 8d 7c fd ff ff    	mov    %ecx,-0x284(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  80283a:	83 bd 90 fd ff ff 00 	cmpl   $0x0,-0x270(%ebp)
  802841:	0f 84 07 01 00 00    	je     80294e <spawn+0x40b>
  802847:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (i >= filesz) {
  80284c:	39 9d 94 fd ff ff    	cmp    %ebx,-0x26c(%ebp)
  802852:	77 27                	ja     80287b <spawn+0x338>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  802854:	83 ec 04             	sub    $0x4,%esp
  802857:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  80285d:	56                   	push   %esi
  80285e:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  802864:	e8 02 ee ff ff       	call   80166b <sys_page_alloc>
  802869:	83 c4 10             	add    $0x10,%esp
  80286c:	85 c0                	test   %eax,%eax
  80286e:	0f 89 c2 00 00 00    	jns    802936 <spawn+0x3f3>
  802874:	89 c3                	mov    %eax,%ebx
  802876:	e9 8d 01 00 00       	jmp    802a08 <spawn+0x4c5>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80287b:	83 ec 04             	sub    $0x4,%esp
  80287e:	6a 07                	push   $0x7
  802880:	68 00 00 40 00       	push   $0x400000
  802885:	6a 00                	push   $0x0
  802887:	e8 df ed ff ff       	call   80166b <sys_page_alloc>
  80288c:	83 c4 10             	add    $0x10,%esp
  80288f:	85 c0                	test   %eax,%eax
  802891:	0f 88 67 01 00 00    	js     8029fe <spawn+0x4bb>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802897:	83 ec 08             	sub    $0x8,%esp
  80289a:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  8028a0:	01 d8                	add    %ebx,%eax
  8028a2:	50                   	push   %eax
  8028a3:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8028a9:	e8 5a f8 ff ff       	call   802108 <seek>
  8028ae:	83 c4 10             	add    $0x10,%esp
  8028b1:	85 c0                	test   %eax,%eax
  8028b3:	0f 88 49 01 00 00    	js     802a02 <spawn+0x4bf>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8028b9:	83 ec 04             	sub    $0x4,%esp
  8028bc:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  8028c2:	29 d8                	sub    %ebx,%eax
  8028c4:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8028c9:	76 05                	jbe    8028d0 <spawn+0x38d>
  8028cb:	b8 00 10 00 00       	mov    $0x1000,%eax
  8028d0:	50                   	push   %eax
  8028d1:	68 00 00 40 00       	push   $0x400000
  8028d6:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8028dc:	e8 50 f7 ff ff       	call   802031 <readn>
  8028e1:	83 c4 10             	add    $0x10,%esp
  8028e4:	85 c0                	test   %eax,%eax
  8028e6:	0f 88 1a 01 00 00    	js     802a06 <spawn+0x4c3>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  8028ec:	83 ec 0c             	sub    $0xc,%esp
  8028ef:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8028f5:	56                   	push   %esi
  8028f6:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  8028fc:	68 00 00 40 00       	push   $0x400000
  802901:	6a 00                	push   $0x0
  802903:	e8 a6 ed ff ff       	call   8016ae <sys_page_map>
  802908:	83 c4 20             	add    $0x20,%esp
  80290b:	85 c0                	test   %eax,%eax
  80290d:	79 15                	jns    802924 <spawn+0x3e1>
				panic("spawn: sys_page_map data: %e", r);
  80290f:	50                   	push   %eax
  802910:	68 62 3a 80 00       	push   $0x803a62
  802915:	68 24 01 00 00       	push   $0x124
  80291a:	68 56 3a 80 00       	push   $0x803a56
  80291f:	e8 14 e1 ff ff       	call   800a38 <_panic>
			sys_page_unmap(0, UTEMP);
  802924:	83 ec 08             	sub    $0x8,%esp
  802927:	68 00 00 40 00       	push   $0x400000
  80292c:	6a 00                	push   $0x0
  80292e:	e8 bd ed ff ff       	call   8016f0 <sys_page_unmap>
  802933:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  802936:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80293c:	81 c6 00 10 00 00    	add    $0x1000,%esi
  802942:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  802948:	0f 82 fe fe ff ff    	jb     80284c <spawn+0x309>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80294e:	ff 85 80 fd ff ff    	incl   -0x280(%ebp)
  802954:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  80295a:	83 85 78 fd ff ff 20 	addl   $0x20,-0x288(%ebp)
  802961:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  802968:	39 d0                	cmp    %edx,%eax
  80296a:	0f 8f 5f fe ff ff    	jg     8027cf <spawn+0x28c>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  802970:	83 ec 0c             	sub    $0xc,%esp
  802973:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802979:	e8 f4 f4 ff ff       	call   801e72 <close>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  80297e:	83 c4 08             	add    $0x8,%esp
  802981:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  802987:	50                   	push   %eax
  802988:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80298e:	e8 e1 ed ff ff       	call   801774 <sys_env_set_trapframe>
  802993:	83 c4 10             	add    $0x10,%esp
  802996:	85 c0                	test   %eax,%eax
  802998:	79 15                	jns    8029af <spawn+0x46c>
		panic("sys_env_set_trapframe: %e", r);
  80299a:	50                   	push   %eax
  80299b:	68 7f 3a 80 00       	push   $0x803a7f
  8029a0:	68 85 00 00 00       	push   $0x85
  8029a5:	68 56 3a 80 00       	push   $0x803a56
  8029aa:	e8 89 e0 ff ff       	call   800a38 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  8029af:	83 ec 08             	sub    $0x8,%esp
  8029b2:	6a 02                	push   $0x2
  8029b4:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8029ba:	e8 73 ed ff ff       	call   801732 <sys_env_set_status>
  8029bf:	83 c4 10             	add    $0x10,%esp
  8029c2:	85 c0                	test   %eax,%eax
  8029c4:	79 25                	jns    8029eb <spawn+0x4a8>
		panic("sys_env_set_status: %e", r);
  8029c6:	50                   	push   %eax
  8029c7:	68 99 3a 80 00       	push   $0x803a99
  8029cc:	68 88 00 00 00       	push   $0x88
  8029d1:	68 56 3a 80 00       	push   $0x803a56
  8029d6:	e8 5d e0 ff ff       	call   800a38 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  8029db:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  8029e1:	eb 58                	jmp    802a3b <spawn+0x4f8>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  8029e3:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  8029e9:	eb 50                	jmp    802a3b <spawn+0x4f8>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  8029eb:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  8029f1:	eb 48                	jmp    802a3b <spawn+0x4f8>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  8029f3:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  8029f8:	eb 41                	jmp    802a3b <spawn+0x4f8>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  8029fa:	89 c3                	mov    %eax,%ebx
  8029fc:	eb 3d                	jmp    802a3b <spawn+0x4f8>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8029fe:	89 c3                	mov    %eax,%ebx
  802a00:	eb 06                	jmp    802a08 <spawn+0x4c5>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802a02:	89 c3                	mov    %eax,%ebx
  802a04:	eb 02                	jmp    802a08 <spawn+0x4c5>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802a06:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  802a08:	83 ec 0c             	sub    $0xc,%esp
  802a0b:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802a11:	e8 d6 eb ff ff       	call   8015ec <sys_env_destroy>
	close(fd);
  802a16:	83 c4 04             	add    $0x4,%esp
  802a19:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802a1f:	e8 4e f4 ff ff       	call   801e72 <close>
	return r;
  802a24:	83 c4 10             	add    $0x10,%esp
  802a27:	eb 12                	jmp    802a3b <spawn+0x4f8>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  802a29:	83 ec 08             	sub    $0x8,%esp
  802a2c:	68 00 00 40 00       	push   $0x400000
  802a31:	6a 00                	push   $0x0
  802a33:	e8 b8 ec ff ff       	call   8016f0 <sys_page_unmap>
  802a38:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  802a3b:	89 d8                	mov    %ebx,%eax
  802a3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802a40:	5b                   	pop    %ebx
  802a41:	5e                   	pop    %esi
  802a42:	5f                   	pop    %edi
  802a43:	5d                   	pop    %ebp
  802a44:	c3                   	ret    

00802a45 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  802a45:	55                   	push   %ebp
  802a46:	89 e5                	mov    %esp,%ebp
  802a48:	57                   	push   %edi
  802a49:	56                   	push   %esi
  802a4a:	53                   	push   %ebx
  802a4b:	83 ec 1c             	sub    $0x1c,%esp
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802a4e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802a52:	74 5f                	je     802ab3 <spawnl+0x6e>
  802a54:	8d 45 14             	lea    0x14(%ebp),%eax
  802a57:	ba 00 00 00 00       	mov    $0x0,%edx
  802a5c:	eb 02                	jmp    802a60 <spawnl+0x1b>
		argc++;
  802a5e:	89 ca                	mov    %ecx,%edx
  802a60:	8d 4a 01             	lea    0x1(%edx),%ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802a63:	83 c0 04             	add    $0x4,%eax
  802a66:	83 78 fc 00          	cmpl   $0x0,-0x4(%eax)
  802a6a:	75 f2                	jne    802a5e <spawnl+0x19>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802a6c:	8d 04 95 1e 00 00 00 	lea    0x1e(,%edx,4),%eax
  802a73:	83 e0 f0             	and    $0xfffffff0,%eax
  802a76:	29 c4                	sub    %eax,%esp
  802a78:	8d 44 24 03          	lea    0x3(%esp),%eax
  802a7c:	c1 e8 02             	shr    $0x2,%eax
  802a7f:	8d 34 85 00 00 00 00 	lea    0x0(,%eax,4),%esi
  802a86:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  802a88:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802a8b:	89 3c 85 00 00 00 00 	mov    %edi,0x0(,%eax,4)
	argv[argc+1] = NULL;
  802a92:	c7 44 96 08 00 00 00 	movl   $0x0,0x8(%esi,%edx,4)
  802a99:	00 

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802a9a:	89 ce                	mov    %ecx,%esi
  802a9c:	85 c9                	test   %ecx,%ecx
  802a9e:	74 23                	je     802ac3 <spawnl+0x7e>
  802aa0:	b8 00 00 00 00       	mov    $0x0,%eax
		argv[i+1] = va_arg(vl, const char *);
  802aa5:	40                   	inc    %eax
  802aa6:	8b 54 85 0c          	mov    0xc(%ebp,%eax,4),%edx
  802aaa:	89 14 83             	mov    %edx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802aad:	39 f0                	cmp    %esi,%eax
  802aaf:	75 f4                	jne    802aa5 <spawnl+0x60>
  802ab1:	eb 10                	jmp    802ac3 <spawnl+0x7e>
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
	argv[0] = arg0;
  802ab3:	8b 45 0c             	mov    0xc(%ebp),%eax
  802ab6:	89 45 e0             	mov    %eax,-0x20(%ebp)
	argv[argc+1] = NULL;
  802ab9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802ac0:	8d 5d e0             	lea    -0x20(%ebp),%ebx
	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802ac3:	83 ec 08             	sub    $0x8,%esp
  802ac6:	53                   	push   %ebx
  802ac7:	ff 75 08             	pushl  0x8(%ebp)
  802aca:	e8 74 fa ff ff       	call   802543 <spawn>
}
  802acf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802ad2:	5b                   	pop    %ebx
  802ad3:	5e                   	pop    %esi
  802ad4:	5f                   	pop    %edi
  802ad5:	5d                   	pop    %ebp
  802ad6:	c3                   	ret    

00802ad7 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802ad7:	55                   	push   %ebp
  802ad8:	89 e5                	mov    %esp,%ebp
  802ada:	56                   	push   %esi
  802adb:	53                   	push   %ebx
  802adc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802adf:	83 ec 0c             	sub    $0xc,%esp
  802ae2:	ff 75 08             	pushl  0x8(%ebp)
  802ae5:	e8 b4 f1 ff ff       	call   801c9e <fd2data>
  802aea:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802aec:	83 c4 08             	add    $0x8,%esp
  802aef:	68 d8 3a 80 00       	push   $0x803ad8
  802af4:	53                   	push   %ebx
  802af5:	e8 01 e7 ff ff       	call   8011fb <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802afa:	8b 46 04             	mov    0x4(%esi),%eax
  802afd:	2b 06                	sub    (%esi),%eax
  802aff:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802b05:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802b0c:	00 00 00 
	stat->st_dev = &devpipe;
  802b0f:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  802b16:	40 80 00 
	return 0;
}
  802b19:	b8 00 00 00 00       	mov    $0x0,%eax
  802b1e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802b21:	5b                   	pop    %ebx
  802b22:	5e                   	pop    %esi
  802b23:	5d                   	pop    %ebp
  802b24:	c3                   	ret    

00802b25 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802b25:	55                   	push   %ebp
  802b26:	89 e5                	mov    %esp,%ebp
  802b28:	53                   	push   %ebx
  802b29:	83 ec 0c             	sub    $0xc,%esp
  802b2c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802b2f:	53                   	push   %ebx
  802b30:	6a 00                	push   $0x0
  802b32:	e8 b9 eb ff ff       	call   8016f0 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802b37:	89 1c 24             	mov    %ebx,(%esp)
  802b3a:	e8 5f f1 ff ff       	call   801c9e <fd2data>
  802b3f:	83 c4 08             	add    $0x8,%esp
  802b42:	50                   	push   %eax
  802b43:	6a 00                	push   $0x0
  802b45:	e8 a6 eb ff ff       	call   8016f0 <sys_page_unmap>
}
  802b4a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802b4d:	c9                   	leave  
  802b4e:	c3                   	ret    

00802b4f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802b4f:	55                   	push   %ebp
  802b50:	89 e5                	mov    %esp,%ebp
  802b52:	57                   	push   %edi
  802b53:	56                   	push   %esi
  802b54:	53                   	push   %ebx
  802b55:	83 ec 1c             	sub    $0x1c,%esp
  802b58:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802b5b:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802b5d:	a1 24 54 80 00       	mov    0x805424,%eax
  802b62:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  802b65:	83 ec 0c             	sub    $0xc,%esp
  802b68:	ff 75 e0             	pushl  -0x20(%ebp)
  802b6b:	e8 16 05 00 00       	call   803086 <pageref>
  802b70:	89 c3                	mov    %eax,%ebx
  802b72:	89 3c 24             	mov    %edi,(%esp)
  802b75:	e8 0c 05 00 00       	call   803086 <pageref>
  802b7a:	83 c4 10             	add    $0x10,%esp
  802b7d:	39 c3                	cmp    %eax,%ebx
  802b7f:	0f 94 c1             	sete   %cl
  802b82:	0f b6 c9             	movzbl %cl,%ecx
  802b85:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802b88:	8b 15 24 54 80 00    	mov    0x805424,%edx
  802b8e:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802b91:	39 ce                	cmp    %ecx,%esi
  802b93:	74 1b                	je     802bb0 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802b95:	39 c3                	cmp    %eax,%ebx
  802b97:	75 c4                	jne    802b5d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802b99:	8b 42 58             	mov    0x58(%edx),%eax
  802b9c:	ff 75 e4             	pushl  -0x1c(%ebp)
  802b9f:	50                   	push   %eax
  802ba0:	56                   	push   %esi
  802ba1:	68 df 3a 80 00       	push   $0x803adf
  802ba6:	e8 65 df ff ff       	call   800b10 <cprintf>
  802bab:	83 c4 10             	add    $0x10,%esp
  802bae:	eb ad                	jmp    802b5d <_pipeisclosed+0xe>
	}
}
  802bb0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802bb3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802bb6:	5b                   	pop    %ebx
  802bb7:	5e                   	pop    %esi
  802bb8:	5f                   	pop    %edi
  802bb9:	5d                   	pop    %ebp
  802bba:	c3                   	ret    

00802bbb <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802bbb:	55                   	push   %ebp
  802bbc:	89 e5                	mov    %esp,%ebp
  802bbe:	57                   	push   %edi
  802bbf:	56                   	push   %esi
  802bc0:	53                   	push   %ebx
  802bc1:	83 ec 18             	sub    $0x18,%esp
  802bc4:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802bc7:	56                   	push   %esi
  802bc8:	e8 d1 f0 ff ff       	call   801c9e <fd2data>
  802bcd:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802bcf:	83 c4 10             	add    $0x10,%esp
  802bd2:	bf 00 00 00 00       	mov    $0x0,%edi
  802bd7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802bdb:	75 42                	jne    802c1f <devpipe_write+0x64>
  802bdd:	eb 4e                	jmp    802c2d <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802bdf:	89 da                	mov    %ebx,%edx
  802be1:	89 f0                	mov    %esi,%eax
  802be3:	e8 67 ff ff ff       	call   802b4f <_pipeisclosed>
  802be8:	85 c0                	test   %eax,%eax
  802bea:	75 46                	jne    802c32 <devpipe_write+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802bec:	e8 5b ea ff ff       	call   80164c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802bf1:	8b 53 04             	mov    0x4(%ebx),%edx
  802bf4:	8b 03                	mov    (%ebx),%eax
  802bf6:	83 c0 20             	add    $0x20,%eax
  802bf9:	39 c2                	cmp    %eax,%edx
  802bfb:	73 e2                	jae    802bdf <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802bfd:	8b 45 0c             	mov    0xc(%ebp),%eax
  802c00:	8a 0c 38             	mov    (%eax,%edi,1),%cl
  802c03:	89 d0                	mov    %edx,%eax
  802c05:	25 1f 00 00 80       	and    $0x8000001f,%eax
  802c0a:	79 05                	jns    802c11 <devpipe_write+0x56>
  802c0c:	48                   	dec    %eax
  802c0d:	83 c8 e0             	or     $0xffffffe0,%eax
  802c10:	40                   	inc    %eax
  802c11:	88 4c 03 08          	mov    %cl,0x8(%ebx,%eax,1)
		p->p_wpos++;
  802c15:	42                   	inc    %edx
  802c16:	89 53 04             	mov    %edx,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802c19:	47                   	inc    %edi
  802c1a:	39 7d 10             	cmp    %edi,0x10(%ebp)
  802c1d:	74 0e                	je     802c2d <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802c1f:	8b 53 04             	mov    0x4(%ebx),%edx
  802c22:	8b 03                	mov    (%ebx),%eax
  802c24:	83 c0 20             	add    $0x20,%eax
  802c27:	39 c2                	cmp    %eax,%edx
  802c29:	73 b4                	jae    802bdf <devpipe_write+0x24>
  802c2b:	eb d0                	jmp    802bfd <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802c2d:	8b 45 10             	mov    0x10(%ebp),%eax
  802c30:	eb 05                	jmp    802c37 <devpipe_write+0x7c>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802c32:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802c37:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802c3a:	5b                   	pop    %ebx
  802c3b:	5e                   	pop    %esi
  802c3c:	5f                   	pop    %edi
  802c3d:	5d                   	pop    %ebp
  802c3e:	c3                   	ret    

00802c3f <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802c3f:	55                   	push   %ebp
  802c40:	89 e5                	mov    %esp,%ebp
  802c42:	57                   	push   %edi
  802c43:	56                   	push   %esi
  802c44:	53                   	push   %ebx
  802c45:	83 ec 18             	sub    $0x18,%esp
  802c48:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802c4b:	57                   	push   %edi
  802c4c:	e8 4d f0 ff ff       	call   801c9e <fd2data>
  802c51:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802c53:	83 c4 10             	add    $0x10,%esp
  802c56:	be 00 00 00 00       	mov    $0x0,%esi
  802c5b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802c5f:	75 3d                	jne    802c9e <devpipe_read+0x5f>
  802c61:	eb 48                	jmp    802cab <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  802c63:	89 f0                	mov    %esi,%eax
  802c65:	eb 4e                	jmp    802cb5 <devpipe_read+0x76>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802c67:	89 da                	mov    %ebx,%edx
  802c69:	89 f8                	mov    %edi,%eax
  802c6b:	e8 df fe ff ff       	call   802b4f <_pipeisclosed>
  802c70:	85 c0                	test   %eax,%eax
  802c72:	75 3c                	jne    802cb0 <devpipe_read+0x71>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802c74:	e8 d3 e9 ff ff       	call   80164c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802c79:	8b 03                	mov    (%ebx),%eax
  802c7b:	3b 43 04             	cmp    0x4(%ebx),%eax
  802c7e:	74 e7                	je     802c67 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802c80:	25 1f 00 00 80       	and    $0x8000001f,%eax
  802c85:	79 05                	jns    802c8c <devpipe_read+0x4d>
  802c87:	48                   	dec    %eax
  802c88:	83 c8 e0             	or     $0xffffffe0,%eax
  802c8b:	40                   	inc    %eax
  802c8c:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  802c90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802c93:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  802c96:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802c98:	46                   	inc    %esi
  802c99:	39 75 10             	cmp    %esi,0x10(%ebp)
  802c9c:	74 0d                	je     802cab <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
  802c9e:	8b 03                	mov    (%ebx),%eax
  802ca0:	3b 43 04             	cmp    0x4(%ebx),%eax
  802ca3:	75 db                	jne    802c80 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802ca5:	85 f6                	test   %esi,%esi
  802ca7:	75 ba                	jne    802c63 <devpipe_read+0x24>
  802ca9:	eb bc                	jmp    802c67 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802cab:	8b 45 10             	mov    0x10(%ebp),%eax
  802cae:	eb 05                	jmp    802cb5 <devpipe_read+0x76>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802cb0:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802cb5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802cb8:	5b                   	pop    %ebx
  802cb9:	5e                   	pop    %esi
  802cba:	5f                   	pop    %edi
  802cbb:	5d                   	pop    %ebp
  802cbc:	c3                   	ret    

00802cbd <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802cbd:	55                   	push   %ebp
  802cbe:	89 e5                	mov    %esp,%ebp
  802cc0:	56                   	push   %esi
  802cc1:	53                   	push   %ebx
  802cc2:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802cc5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802cc8:	50                   	push   %eax
  802cc9:	e8 e7 ef ff ff       	call   801cb5 <fd_alloc>
  802cce:	83 c4 10             	add    $0x10,%esp
  802cd1:	85 c0                	test   %eax,%eax
  802cd3:	0f 88 2a 01 00 00    	js     802e03 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802cd9:	83 ec 04             	sub    $0x4,%esp
  802cdc:	68 07 04 00 00       	push   $0x407
  802ce1:	ff 75 f4             	pushl  -0xc(%ebp)
  802ce4:	6a 00                	push   $0x0
  802ce6:	e8 80 e9 ff ff       	call   80166b <sys_page_alloc>
  802ceb:	83 c4 10             	add    $0x10,%esp
  802cee:	85 c0                	test   %eax,%eax
  802cf0:	0f 88 0d 01 00 00    	js     802e03 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802cf6:	83 ec 0c             	sub    $0xc,%esp
  802cf9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802cfc:	50                   	push   %eax
  802cfd:	e8 b3 ef ff ff       	call   801cb5 <fd_alloc>
  802d02:	89 c3                	mov    %eax,%ebx
  802d04:	83 c4 10             	add    $0x10,%esp
  802d07:	85 c0                	test   %eax,%eax
  802d09:	0f 88 e2 00 00 00    	js     802df1 <pipe+0x134>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802d0f:	83 ec 04             	sub    $0x4,%esp
  802d12:	68 07 04 00 00       	push   $0x407
  802d17:	ff 75 f0             	pushl  -0x10(%ebp)
  802d1a:	6a 00                	push   $0x0
  802d1c:	e8 4a e9 ff ff       	call   80166b <sys_page_alloc>
  802d21:	89 c3                	mov    %eax,%ebx
  802d23:	83 c4 10             	add    $0x10,%esp
  802d26:	85 c0                	test   %eax,%eax
  802d28:	0f 88 c3 00 00 00    	js     802df1 <pipe+0x134>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802d2e:	83 ec 0c             	sub    $0xc,%esp
  802d31:	ff 75 f4             	pushl  -0xc(%ebp)
  802d34:	e8 65 ef ff ff       	call   801c9e <fd2data>
  802d39:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802d3b:	83 c4 0c             	add    $0xc,%esp
  802d3e:	68 07 04 00 00       	push   $0x407
  802d43:	50                   	push   %eax
  802d44:	6a 00                	push   $0x0
  802d46:	e8 20 e9 ff ff       	call   80166b <sys_page_alloc>
  802d4b:	89 c3                	mov    %eax,%ebx
  802d4d:	83 c4 10             	add    $0x10,%esp
  802d50:	85 c0                	test   %eax,%eax
  802d52:	0f 88 89 00 00 00    	js     802de1 <pipe+0x124>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802d58:	83 ec 0c             	sub    $0xc,%esp
  802d5b:	ff 75 f0             	pushl  -0x10(%ebp)
  802d5e:	e8 3b ef ff ff       	call   801c9e <fd2data>
  802d63:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802d6a:	50                   	push   %eax
  802d6b:	6a 00                	push   $0x0
  802d6d:	56                   	push   %esi
  802d6e:	6a 00                	push   $0x0
  802d70:	e8 39 e9 ff ff       	call   8016ae <sys_page_map>
  802d75:	89 c3                	mov    %eax,%ebx
  802d77:	83 c4 20             	add    $0x20,%esp
  802d7a:	85 c0                	test   %eax,%eax
  802d7c:	78 55                	js     802dd3 <pipe+0x116>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802d7e:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802d84:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802d87:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802d89:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802d8c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802d93:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802d99:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d9c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802d9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802da1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802da8:	83 ec 0c             	sub    $0xc,%esp
  802dab:	ff 75 f4             	pushl  -0xc(%ebp)
  802dae:	e8 db ee ff ff       	call   801c8e <fd2num>
  802db3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802db6:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802db8:	83 c4 04             	add    $0x4,%esp
  802dbb:	ff 75 f0             	pushl  -0x10(%ebp)
  802dbe:	e8 cb ee ff ff       	call   801c8e <fd2num>
  802dc3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802dc6:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802dc9:	83 c4 10             	add    $0x10,%esp
  802dcc:	b8 00 00 00 00       	mov    $0x0,%eax
  802dd1:	eb 30                	jmp    802e03 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  802dd3:	83 ec 08             	sub    $0x8,%esp
  802dd6:	56                   	push   %esi
  802dd7:	6a 00                	push   $0x0
  802dd9:	e8 12 e9 ff ff       	call   8016f0 <sys_page_unmap>
  802dde:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802de1:	83 ec 08             	sub    $0x8,%esp
  802de4:	ff 75 f0             	pushl  -0x10(%ebp)
  802de7:	6a 00                	push   $0x0
  802de9:	e8 02 e9 ff ff       	call   8016f0 <sys_page_unmap>
  802dee:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802df1:	83 ec 08             	sub    $0x8,%esp
  802df4:	ff 75 f4             	pushl  -0xc(%ebp)
  802df7:	6a 00                	push   $0x0
  802df9:	e8 f2 e8 ff ff       	call   8016f0 <sys_page_unmap>
  802dfe:	83 c4 10             	add    $0x10,%esp
  802e01:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  802e03:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802e06:	5b                   	pop    %ebx
  802e07:	5e                   	pop    %esi
  802e08:	5d                   	pop    %ebp
  802e09:	c3                   	ret    

00802e0a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802e0a:	55                   	push   %ebp
  802e0b:	89 e5                	mov    %esp,%ebp
  802e0d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802e10:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802e13:	50                   	push   %eax
  802e14:	ff 75 08             	pushl  0x8(%ebp)
  802e17:	e8 0d ef ff ff       	call   801d29 <fd_lookup>
  802e1c:	83 c4 10             	add    $0x10,%esp
  802e1f:	85 c0                	test   %eax,%eax
  802e21:	78 18                	js     802e3b <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802e23:	83 ec 0c             	sub    $0xc,%esp
  802e26:	ff 75 f4             	pushl  -0xc(%ebp)
  802e29:	e8 70 ee ff ff       	call   801c9e <fd2data>
	return _pipeisclosed(fd, p);
  802e2e:	89 c2                	mov    %eax,%edx
  802e30:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802e33:	e8 17 fd ff ff       	call   802b4f <_pipeisclosed>
  802e38:	83 c4 10             	add    $0x10,%esp
}
  802e3b:	c9                   	leave  
  802e3c:	c3                   	ret    

00802e3d <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802e3d:	55                   	push   %ebp
  802e3e:	89 e5                	mov    %esp,%ebp
  802e40:	56                   	push   %esi
  802e41:	53                   	push   %ebx
  802e42:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802e45:	85 f6                	test   %esi,%esi
  802e47:	75 16                	jne    802e5f <wait+0x22>
  802e49:	68 f7 3a 80 00       	push   $0x803af7
  802e4e:	68 8f 34 80 00       	push   $0x80348f
  802e53:	6a 09                	push   $0x9
  802e55:	68 02 3b 80 00       	push   $0x803b02
  802e5a:	e8 d9 db ff ff       	call   800a38 <_panic>
	e = &envs[ENVX(envid)];
  802e5f:	89 f3                	mov    %esi,%ebx
  802e61:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802e67:	8d 14 9d 00 00 00 00 	lea    0x0(,%ebx,4),%edx
  802e6e:	89 d8                	mov    %ebx,%eax
  802e70:	c1 e0 07             	shl    $0x7,%eax
  802e73:	29 d0                	sub    %edx,%eax
  802e75:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802e7a:	8b 40 48             	mov    0x48(%eax),%eax
  802e7d:	39 c6                	cmp    %eax,%esi
  802e7f:	75 31                	jne    802eb2 <wait+0x75>
  802e81:	89 d8                	mov    %ebx,%eax
  802e83:	c1 e0 07             	shl    $0x7,%eax
  802e86:	29 d0                	sub    %edx,%eax
  802e88:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802e8d:	8b 40 54             	mov    0x54(%eax),%eax
  802e90:	85 c0                	test   %eax,%eax
  802e92:	74 1e                	je     802eb2 <wait+0x75>
  802e94:	c1 e3 07             	shl    $0x7,%ebx
  802e97:	29 d3                	sub    %edx,%ebx
  802e99:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
		sys_yield();
  802e9f:	e8 a8 e7 ff ff       	call   80164c <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802ea4:	8b 43 48             	mov    0x48(%ebx),%eax
  802ea7:	39 c6                	cmp    %eax,%esi
  802ea9:	75 07                	jne    802eb2 <wait+0x75>
  802eab:	8b 43 54             	mov    0x54(%ebx),%eax
  802eae:	85 c0                	test   %eax,%eax
  802eb0:	75 ed                	jne    802e9f <wait+0x62>
		sys_yield();
}
  802eb2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802eb5:	5b                   	pop    %ebx
  802eb6:	5e                   	pop    %esi
  802eb7:	5d                   	pop    %ebp
  802eb8:	c3                   	ret    

00802eb9 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802eb9:	55                   	push   %ebp
  802eba:	89 e5                	mov    %esp,%ebp
  802ebc:	53                   	push   %ebx
  802ebd:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  802ec0:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802ec7:	75 5b                	jne    802f24 <set_pgfault_handler+0x6b>
		// First time through!
		// LAB 4: Your code here.
		void *va = (void *)(UXSTACKTOP - PGSIZE);
		envid_t eid = sys_getenvid();
  802ec9:	e8 5f e7 ff ff       	call   80162d <sys_getenvid>
  802ece:	89 c3                	mov    %eax,%ebx
		r = sys_page_alloc(eid,va,PTE_P | PTE_U | PTE_W);
  802ed0:	83 ec 04             	sub    $0x4,%esp
  802ed3:	6a 07                	push   $0x7
  802ed5:	68 00 f0 bf ee       	push   $0xeebff000
  802eda:	50                   	push   %eax
  802edb:	e8 8b e7 ff ff       	call   80166b <sys_page_alloc>
		if(r<0) panic("set_pgfault_handler\n");
  802ee0:	83 c4 10             	add    $0x10,%esp
  802ee3:	85 c0                	test   %eax,%eax
  802ee5:	79 14                	jns    802efb <set_pgfault_handler+0x42>
  802ee7:	83 ec 04             	sub    $0x4,%esp
  802eea:	68 0d 3b 80 00       	push   $0x803b0d
  802eef:	6a 23                	push   $0x23
  802ef1:	68 22 3b 80 00       	push   $0x803b22
  802ef6:	e8 3d db ff ff       	call   800a38 <_panic>
		r = sys_env_set_pgfault_upcall(eid,_pgfault_upcall);
  802efb:	83 ec 08             	sub    $0x8,%esp
  802efe:	68 31 2f 80 00       	push   $0x802f31
  802f03:	53                   	push   %ebx
  802f04:	e8 ad e8 ff ff       	call   8017b6 <sys_env_set_pgfault_upcall>
		if(r<0) panic("set_pgfault_handler\n");
  802f09:	83 c4 10             	add    $0x10,%esp
  802f0c:	85 c0                	test   %eax,%eax
  802f0e:	79 14                	jns    802f24 <set_pgfault_handler+0x6b>
  802f10:	83 ec 04             	sub    $0x4,%esp
  802f13:	68 0d 3b 80 00       	push   $0x803b0d
  802f18:	6a 25                	push   $0x25
  802f1a:	68 22 3b 80 00       	push   $0x803b22
  802f1f:	e8 14 db ff ff       	call   800a38 <_panic>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802f24:	8b 45 08             	mov    0x8(%ebp),%eax
  802f27:	a3 00 70 80 00       	mov    %eax,0x807000
}
  802f2c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802f2f:	c9                   	leave  
  802f30:	c3                   	ret    

00802f31 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802f31:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802f32:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802f37:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802f39:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp,%ebx
  802f3c:	89 e3                	mov    %esp,%ebx
	movl 40(%esp),%eax 	// esp from utf_fault_va to utf_regs(end)
  802f3e:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp),%esp 	// 
  802f42:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax
  802f46:	50                   	push   %eax
 
 
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx,%esp
  802f47:	89 dc                	mov    %ebx,%esp
	subl $4,48(%esp)
  802f49:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	popl %eax
  802f4e:	58                   	pop    %eax
	popl %eax
  802f4f:	58                   	pop    %eax
	popal
  802f50:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4,%esp
  802f51:	83 c4 04             	add    $0x4,%esp
	popfl
  802f54:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  802f55:	5c                   	pop    %esp
 
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802f56:	c3                   	ret    

00802f57 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802f57:	55                   	push   %ebp
  802f58:	89 e5                	mov    %esp,%ebp
  802f5a:	56                   	push   %esi
  802f5b:	53                   	push   %ebx
  802f5c:	8b 75 08             	mov    0x8(%ebp),%esi
  802f5f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802f62:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");
	int r;
    if (pg != NULL) {
  802f65:	85 c0                	test   %eax,%eax
  802f67:	74 0e                	je     802f77 <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  802f69:	83 ec 0c             	sub    $0xc,%esp
  802f6c:	50                   	push   %eax
  802f6d:	e8 a9 e8 ff ff       	call   80181b <sys_ipc_recv>
  802f72:	83 c4 10             	add    $0x10,%esp
  802f75:	eb 10                	jmp    802f87 <ipc_recv+0x30>
    } else {
        r = sys_ipc_recv((void *) UTOP);
  802f77:	83 ec 0c             	sub    $0xc,%esp
  802f7a:	68 00 00 c0 ee       	push   $0xeec00000
  802f7f:	e8 97 e8 ff ff       	call   80181b <sys_ipc_recv>
  802f84:	83 c4 10             	add    $0x10,%esp
    }
    if (r < 0) {
  802f87:	85 c0                	test   %eax,%eax
  802f89:	79 16                	jns    802fa1 <ipc_recv+0x4a>
        // failed
        if (from_env_store != NULL) *from_env_store = 0;
  802f8b:	85 f6                	test   %esi,%esi
  802f8d:	74 06                	je     802f95 <ipc_recv+0x3e>
  802f8f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL) *perm_store = 0;
  802f95:	85 db                	test   %ebx,%ebx
  802f97:	74 2c                	je     802fc5 <ipc_recv+0x6e>
  802f99:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802f9f:	eb 24                	jmp    802fc5 <ipc_recv+0x6e>
        return r;
    } else {
        if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  802fa1:	85 f6                	test   %esi,%esi
  802fa3:	74 0a                	je     802faf <ipc_recv+0x58>
  802fa5:	a1 24 54 80 00       	mov    0x805424,%eax
  802faa:	8b 40 74             	mov    0x74(%eax),%eax
  802fad:	89 06                	mov    %eax,(%esi)
        if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  802faf:	85 db                	test   %ebx,%ebx
  802fb1:	74 0a                	je     802fbd <ipc_recv+0x66>
  802fb3:	a1 24 54 80 00       	mov    0x805424,%eax
  802fb8:	8b 40 78             	mov    0x78(%eax),%eax
  802fbb:	89 03                	mov    %eax,(%ebx)
        return thisenv->env_ipc_value;
  802fbd:	a1 24 54 80 00       	mov    0x805424,%eax
  802fc2:	8b 40 70             	mov    0x70(%eax),%eax
    }
 
	return 0;
}
  802fc5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802fc8:	5b                   	pop    %ebx
  802fc9:	5e                   	pop    %esi
  802fca:	5d                   	pop    %ebp
  802fcb:	c3                   	ret    

00802fcc <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802fcc:	55                   	push   %ebp
  802fcd:	89 e5                	mov    %esp,%ebp
  802fcf:	57                   	push   %edi
  802fd0:	56                   	push   %esi
  802fd1:	53                   	push   %ebx
  802fd2:	83 ec 0c             	sub    $0xc,%esp
  802fd5:	8b 75 10             	mov    0x10(%ebp),%esi
  802fd8:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;
    if (pg == NULL) pg = (void *)UTOP;
  802fdb:	85 f6                	test   %esi,%esi
  802fdd:	75 05                	jne    802fe4 <ipc_send+0x18>
  802fdf:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
  802fe4:	57                   	push   %edi
  802fe5:	56                   	push   %esi
  802fe6:	ff 75 0c             	pushl  0xc(%ebp)
  802fe9:	ff 75 08             	pushl  0x8(%ebp)
  802fec:	e8 07 e8 ff ff       	call   8017f8 <sys_ipc_try_send>
  802ff1:	89 c3                	mov    %eax,%ebx
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
  802ff3:	83 c4 10             	add    $0x10,%esp
  802ff6:	85 c0                	test   %eax,%eax
  802ff8:	79 17                	jns    803011 <ipc_send+0x45>
  802ffa:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802ffd:	74 1d                	je     80301c <ipc_send+0x50>
  802fff:	50                   	push   %eax
  803000:	68 30 3b 80 00       	push   $0x803b30
  803005:	6a 40                	push   $0x40
  803007:	68 44 3b 80 00       	push   $0x803b44
  80300c:	e8 27 da ff ff       	call   800a38 <_panic>
        sys_yield();
  803011:	e8 36 e6 ff ff       	call   80164c <sys_yield>
    } while (r != 0);
  803016:	85 db                	test   %ebx,%ebx
  803018:	75 ca                	jne    802fe4 <ipc_send+0x18>
  80301a:	eb 07                	jmp    803023 <ipc_send+0x57>
	int r;
    if (pg == NULL) pg = (void *)UTOP;
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
        sys_yield();
  80301c:	e8 2b e6 ff ff       	call   80164c <sys_yield>
  803021:	eb c1                	jmp    802fe4 <ipc_send+0x18>
    } while (r != 0);
}
  803023:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803026:	5b                   	pop    %ebx
  803027:	5e                   	pop    %esi
  803028:	5f                   	pop    %edi
  803029:	5d                   	pop    %ebp
  80302a:	c3                   	ret    

0080302b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80302b:	55                   	push   %ebp
  80302c:	89 e5                	mov    %esp,%ebp
  80302e:	53                   	push   %ebx
  80302f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  803032:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  803037:	39 c1                	cmp    %eax,%ecx
  803039:	74 21                	je     80305c <ipc_find_env+0x31>
  80303b:	ba 01 00 00 00       	mov    $0x1,%edx
  803040:	8d 1c 95 00 00 00 00 	lea    0x0(,%edx,4),%ebx
  803047:	89 d0                	mov    %edx,%eax
  803049:	c1 e0 07             	shl    $0x7,%eax
  80304c:	29 d8                	sub    %ebx,%eax
  80304e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  803053:	8b 40 50             	mov    0x50(%eax),%eax
  803056:	39 c8                	cmp    %ecx,%eax
  803058:	75 1b                	jne    803075 <ipc_find_env+0x4a>
  80305a:	eb 05                	jmp    803061 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80305c:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_type == type)
			return envs[i].env_id;
  803061:	8d 04 95 00 00 00 00 	lea    0x0(,%edx,4),%eax
  803068:	c1 e2 07             	shl    $0x7,%edx
  80306b:	29 c2                	sub    %eax,%edx
  80306d:	8b 82 48 00 c0 ee    	mov    -0x113fffb8(%edx),%eax
  803073:	eb 0e                	jmp    803083 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  803075:	42                   	inc    %edx
  803076:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  80307c:	75 c2                	jne    803040 <ipc_find_env+0x15>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80307e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  803083:	5b                   	pop    %ebx
  803084:	5d                   	pop    %ebp
  803085:	c3                   	ret    

00803086 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  803086:	55                   	push   %ebp
  803087:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  803089:	8b 45 08             	mov    0x8(%ebp),%eax
  80308c:	c1 e8 16             	shr    $0x16,%eax
  80308f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  803096:	a8 01                	test   $0x1,%al
  803098:	74 21                	je     8030bb <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  80309a:	8b 45 08             	mov    0x8(%ebp),%eax
  80309d:	c1 e8 0c             	shr    $0xc,%eax
  8030a0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8030a7:	a8 01                	test   $0x1,%al
  8030a9:	74 17                	je     8030c2 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8030ab:	c1 e8 0c             	shr    $0xc,%eax
  8030ae:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8030b5:	ef 
  8030b6:	0f b7 c0             	movzwl %ax,%eax
  8030b9:	eb 0c                	jmp    8030c7 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8030bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8030c0:	eb 05                	jmp    8030c7 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8030c2:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8030c7:	5d                   	pop    %ebp
  8030c8:	c3                   	ret    
  8030c9:	66 90                	xchg   %ax,%ax
  8030cb:	90                   	nop

008030cc <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8030cc:	55                   	push   %ebp
  8030cd:	57                   	push   %edi
  8030ce:	56                   	push   %esi
  8030cf:	53                   	push   %ebx
  8030d0:	83 ec 1c             	sub    $0x1c,%esp
  8030d3:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8030d7:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8030db:	8b 7c 24 38          	mov    0x38(%esp),%edi
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8030df:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8030e3:	89 ca                	mov    %ecx,%edx
  const DWunion dd = {.ll = d};
  8030e5:	89 f8                	mov    %edi,%eax
  8030e7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8030eb:	85 f6                	test   %esi,%esi
  8030ed:	75 2d                	jne    80311c <__udivdi3+0x50>
    {
      if (d0 > n1)
  8030ef:	39 cf                	cmp    %ecx,%edi
  8030f1:	77 65                	ja     803158 <__udivdi3+0x8c>
  8030f3:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8030f5:	85 ff                	test   %edi,%edi
  8030f7:	75 0b                	jne    803104 <__udivdi3+0x38>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8030f9:	b8 01 00 00 00       	mov    $0x1,%eax
  8030fe:	31 d2                	xor    %edx,%edx
  803100:	f7 f7                	div    %edi
  803102:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  803104:	31 d2                	xor    %edx,%edx
  803106:	89 c8                	mov    %ecx,%eax
  803108:	f7 f5                	div    %ebp
  80310a:	89 c1                	mov    %eax,%ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80310c:	89 d8                	mov    %ebx,%eax
  80310e:	f7 f5                	div    %ebp
  803110:	89 cf                	mov    %ecx,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  803112:	89 fa                	mov    %edi,%edx
  803114:	83 c4 1c             	add    $0x1c,%esp
  803117:	5b                   	pop    %ebx
  803118:	5e                   	pop    %esi
  803119:	5f                   	pop    %edi
  80311a:	5d                   	pop    %ebp
  80311b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80311c:	39 ce                	cmp    %ecx,%esi
  80311e:	77 28                	ja     803148 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  803120:	0f bd fe             	bsr    %esi,%edi
	  if (bm == 0)
  803123:	83 f7 1f             	xor    $0x1f,%edi
  803126:	75 40                	jne    803168 <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  803128:	39 ce                	cmp    %ecx,%esi
  80312a:	72 0a                	jb     803136 <__udivdi3+0x6a>
  80312c:	3b 44 24 08          	cmp    0x8(%esp),%eax
  803130:	0f 87 9e 00 00 00    	ja     8031d4 <__udivdi3+0x108>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  803136:	b8 01 00 00 00       	mov    $0x1,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80313b:	89 fa                	mov    %edi,%edx
  80313d:	83 c4 1c             	add    $0x1c,%esp
  803140:	5b                   	pop    %ebx
  803141:	5e                   	pop    %esi
  803142:	5f                   	pop    %edi
  803143:	5d                   	pop    %ebp
  803144:	c3                   	ret    
  803145:	8d 76 00             	lea    0x0(%esi),%esi
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  803148:	31 ff                	xor    %edi,%edi
  80314a:	31 c0                	xor    %eax,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80314c:	89 fa                	mov    %edi,%edx
  80314e:	83 c4 1c             	add    $0x1c,%esp
  803151:	5b                   	pop    %ebx
  803152:	5e                   	pop    %esi
  803153:	5f                   	pop    %edi
  803154:	5d                   	pop    %ebp
  803155:	c3                   	ret    
  803156:	66 90                	xchg   %ax,%ax
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  803158:	89 d8                	mov    %ebx,%eax
  80315a:	f7 f7                	div    %edi
  80315c:	31 ff                	xor    %edi,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80315e:	89 fa                	mov    %edi,%edx
  803160:	83 c4 1c             	add    $0x1c,%esp
  803163:	5b                   	pop    %ebx
  803164:	5e                   	pop    %esi
  803165:	5f                   	pop    %edi
  803166:	5d                   	pop    %ebp
  803167:	c3                   	ret    
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  803168:	bd 20 00 00 00       	mov    $0x20,%ebp
  80316d:	89 eb                	mov    %ebp,%ebx
  80316f:	29 fb                	sub    %edi,%ebx

	      d1 = (d1 << bm) | (d0 >> b);
  803171:	89 f9                	mov    %edi,%ecx
  803173:	d3 e6                	shl    %cl,%esi
  803175:	89 c5                	mov    %eax,%ebp
  803177:	88 d9                	mov    %bl,%cl
  803179:	d3 ed                	shr    %cl,%ebp
  80317b:	89 e9                	mov    %ebp,%ecx
  80317d:	09 f1                	or     %esi,%ecx
  80317f:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
	      d0 = d0 << bm;
  803183:	89 f9                	mov    %edi,%ecx
  803185:	d3 e0                	shl    %cl,%eax
  803187:	89 c5                	mov    %eax,%ebp
	      n2 = n1 >> b;
  803189:	89 d6                	mov    %edx,%esi
  80318b:	88 d9                	mov    %bl,%cl
  80318d:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
  80318f:	89 f9                	mov    %edi,%ecx
  803191:	d3 e2                	shl    %cl,%edx
  803193:	8b 44 24 08          	mov    0x8(%esp),%eax
  803197:	88 d9                	mov    %bl,%cl
  803199:	d3 e8                	shr    %cl,%eax
  80319b:	09 c2                	or     %eax,%edx
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80319d:	89 d0                	mov    %edx,%eax
  80319f:	89 f2                	mov    %esi,%edx
  8031a1:	f7 74 24 0c          	divl   0xc(%esp)
  8031a5:	89 d6                	mov    %edx,%esi
  8031a7:	89 c3                	mov    %eax,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  8031a9:	f7 e5                	mul    %ebp

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8031ab:	39 d6                	cmp    %edx,%esi
  8031ad:	72 19                	jb     8031c8 <__udivdi3+0xfc>
  8031af:	74 0b                	je     8031bc <__udivdi3+0xf0>
  8031b1:	89 d8                	mov    %ebx,%eax
  8031b3:	31 ff                	xor    %edi,%edi
  8031b5:	e9 58 ff ff ff       	jmp    803112 <__udivdi3+0x46>
  8031ba:	66 90                	xchg   %ax,%ax
  8031bc:	8b 54 24 08          	mov    0x8(%esp),%edx
  8031c0:	89 f9                	mov    %edi,%ecx
  8031c2:	d3 e2                	shl    %cl,%edx
  8031c4:	39 c2                	cmp    %eax,%edx
  8031c6:	73 e9                	jae    8031b1 <__udivdi3+0xe5>
  8031c8:	8d 43 ff             	lea    -0x1(%ebx),%eax
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8031cb:	31 ff                	xor    %edi,%edi
  8031cd:	e9 40 ff ff ff       	jmp    803112 <__udivdi3+0x46>
  8031d2:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8031d4:	31 c0                	xor    %eax,%eax
  8031d6:	e9 37 ff ff ff       	jmp    803112 <__udivdi3+0x46>
  8031db:	90                   	nop

008031dc <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8031dc:	55                   	push   %ebp
  8031dd:	57                   	push   %edi
  8031de:	56                   	push   %esi
  8031df:	53                   	push   %ebx
  8031e0:	83 ec 1c             	sub    $0x1c,%esp
  8031e3:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8031e7:	8b 74 24 34          	mov    0x34(%esp),%esi
  8031eb:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8031ef:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8031f3:	89 44 24 0c          	mov    %eax,0xc(%esp)
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8031f7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8031fb:	89 f3                	mov    %esi,%ebx
  const DWunion dd = {.ll = d};
  8031fd:	89 fa                	mov    %edi,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8031ff:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  n1 = nn.s.high;
  803203:	89 34 24             	mov    %esi,(%esp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  803206:	85 c0                	test   %eax,%eax
  803208:	75 1a                	jne    803224 <__umoddi3+0x48>
    {
      if (d0 > n1)
  80320a:	39 f7                	cmp    %esi,%edi
  80320c:	0f 86 a2 00 00 00    	jbe    8032b4 <__umoddi3+0xd8>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  803212:	89 c8                	mov    %ecx,%eax
  803214:	89 f2                	mov    %esi,%edx
  803216:	f7 f7                	div    %edi
  803218:	89 d0                	mov    %edx,%eax

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  80321a:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80321c:	83 c4 1c             	add    $0x1c,%esp
  80321f:	5b                   	pop    %ebx
  803220:	5e                   	pop    %esi
  803221:	5f                   	pop    %edi
  803222:	5d                   	pop    %ebp
  803223:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  803224:	39 f0                	cmp    %esi,%eax
  803226:	0f 87 ac 00 00 00    	ja     8032d8 <__umoddi3+0xfc>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80322c:	0f bd e8             	bsr    %eax,%ebp
	  if (bm == 0)
  80322f:	83 f5 1f             	xor    $0x1f,%ebp
  803232:	0f 84 ac 00 00 00    	je     8032e4 <__umoddi3+0x108>
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  803238:	bf 20 00 00 00       	mov    $0x20,%edi
  80323d:	29 ef                	sub    %ebp,%edi
  80323f:	89 fe                	mov    %edi,%esi
  803241:	89 7c 24 0c          	mov    %edi,0xc(%esp)

	      d1 = (d1 << bm) | (d0 >> b);
  803245:	89 e9                	mov    %ebp,%ecx
  803247:	d3 e0                	shl    %cl,%eax
  803249:	89 d7                	mov    %edx,%edi
  80324b:	89 f1                	mov    %esi,%ecx
  80324d:	d3 ef                	shr    %cl,%edi
  80324f:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  803251:	89 e9                	mov    %ebp,%ecx
  803253:	d3 e2                	shl    %cl,%edx
  803255:	89 14 24             	mov    %edx,(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  803258:	89 d8                	mov    %ebx,%eax
  80325a:	d3 e0                	shl    %cl,%eax
  80325c:	89 c2                	mov    %eax,%edx
	      n0 = n0 << bm;
  80325e:	8b 44 24 08          	mov    0x8(%esp),%eax
  803262:	d3 e0                	shl    %cl,%eax
  803264:	89 44 24 04          	mov    %eax,0x4(%esp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  803268:	8b 44 24 08          	mov    0x8(%esp),%eax
  80326c:	89 f1                	mov    %esi,%ecx
  80326e:	d3 e8                	shr    %cl,%eax
  803270:	09 d0                	or     %edx,%eax
  803272:	d3 eb                	shr    %cl,%ebx
  803274:	89 da                	mov    %ebx,%edx
  803276:	f7 f7                	div    %edi
  803278:	89 d3                	mov    %edx,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  80327a:	f7 24 24             	mull   (%esp)
  80327d:	89 c6                	mov    %eax,%esi
  80327f:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  803281:	39 d3                	cmp    %edx,%ebx
  803283:	0f 82 87 00 00 00    	jb     803310 <__umoddi3+0x134>
  803289:	0f 84 91 00 00 00    	je     803320 <__umoddi3+0x144>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80328f:	8b 54 24 04          	mov    0x4(%esp),%edx
  803293:	29 f2                	sub    %esi,%edx
  803295:	19 cb                	sbb    %ecx,%ebx
		  rr.s.low = (n1 << b) | (n0 >> bm);
  803297:	89 d8                	mov    %ebx,%eax
  803299:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  80329d:	d3 e0                	shl    %cl,%eax
  80329f:	89 e9                	mov    %ebp,%ecx
  8032a1:	d3 ea                	shr    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8032a3:	09 d0                	or     %edx,%eax
  8032a5:	89 e9                	mov    %ebp,%ecx
  8032a7:	d3 eb                	shr    %cl,%ebx
  8032a9:	89 da                	mov    %ebx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8032ab:	83 c4 1c             	add    $0x1c,%esp
  8032ae:	5b                   	pop    %ebx
  8032af:	5e                   	pop    %esi
  8032b0:	5f                   	pop    %edi
  8032b1:	5d                   	pop    %ebp
  8032b2:	c3                   	ret    
  8032b3:	90                   	nop
  8032b4:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8032b6:	85 ff                	test   %edi,%edi
  8032b8:	75 0b                	jne    8032c5 <__umoddi3+0xe9>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8032ba:	b8 01 00 00 00       	mov    $0x1,%eax
  8032bf:	31 d2                	xor    %edx,%edx
  8032c1:	f7 f7                	div    %edi
  8032c3:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8032c5:	89 f0                	mov    %esi,%eax
  8032c7:	31 d2                	xor    %edx,%edx
  8032c9:	f7 f5                	div    %ebp
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8032cb:	89 c8                	mov    %ecx,%eax
  8032cd:	f7 f5                	div    %ebp
  8032cf:	89 d0                	mov    %edx,%eax
  8032d1:	e9 44 ff ff ff       	jmp    80321a <__umoddi3+0x3e>
  8032d6:	66 90                	xchg   %ax,%ax
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8032d8:	89 c8                	mov    %ecx,%eax
  8032da:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8032dc:	83 c4 1c             	add    $0x1c,%esp
  8032df:	5b                   	pop    %ebx
  8032e0:	5e                   	pop    %esi
  8032e1:	5f                   	pop    %edi
  8032e2:	5d                   	pop    %ebp
  8032e3:	c3                   	ret    

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8032e4:	3b 04 24             	cmp    (%esp),%eax
  8032e7:	72 06                	jb     8032ef <__umoddi3+0x113>
  8032e9:	3b 7c 24 04          	cmp    0x4(%esp),%edi
  8032ed:	77 0f                	ja     8032fe <__umoddi3+0x122>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8032ef:	89 f2                	mov    %esi,%edx
  8032f1:	29 f9                	sub    %edi,%ecx
  8032f3:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  8032f7:	89 14 24             	mov    %edx,(%esp)
  8032fa:	89 4c 24 04          	mov    %ecx,0x4(%esp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8032fe:	8b 44 24 04          	mov    0x4(%esp),%eax
  803302:	8b 14 24             	mov    (%esp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  803305:	83 c4 1c             	add    $0x1c,%esp
  803308:	5b                   	pop    %ebx
  803309:	5e                   	pop    %esi
  80330a:	5f                   	pop    %edi
  80330b:	5d                   	pop    %ebp
  80330c:	c3                   	ret    
  80330d:	8d 76 00             	lea    0x0(%esi),%esi
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  803310:	2b 04 24             	sub    (%esp),%eax
  803313:	19 fa                	sbb    %edi,%edx
  803315:	89 d1                	mov    %edx,%ecx
  803317:	89 c6                	mov    %eax,%esi
  803319:	e9 71 ff ff ff       	jmp    80328f <__umoddi3+0xb3>
  80331e:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  803320:	39 44 24 04          	cmp    %eax,0x4(%esp)
  803324:	72 ea                	jb     803310 <__umoddi3+0x134>
  803326:	89 d9                	mov    %ebx,%ecx
  803328:	e9 62 ff ff ff       	jmp    80328f <__umoddi3+0xb3>
