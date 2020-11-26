
obj/user/ls.debug:     file format elf32-i386


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
  80002c:	e8 9c 02 00 00       	call   8002cd <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <ls1>:
		panic("error reading directory %s: %e", path, n);
}

void
ls1(const char *prefix, bool isdir, off_t size, const char *name)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80003b:	8b 75 0c             	mov    0xc(%ebp),%esi
	const char *sep;

	if(flag['l'])
  80003e:	83 3d d0 41 80 00 00 	cmpl   $0x0,0x8041d0
  800045:	74 20                	je     800067 <ls1+0x34>
		printf("%11d %c ", size, isdir ? 'd' : '-');
  800047:	89 f0                	mov    %esi,%eax
  800049:	3c 01                	cmp    $0x1,%al
  80004b:	19 c0                	sbb    %eax,%eax
  80004d:	83 e0 c9             	and    $0xffffffc9,%eax
  800050:	83 c0 64             	add    $0x64,%eax
  800053:	83 ec 04             	sub    $0x4,%esp
  800056:	50                   	push   %eax
  800057:	ff 75 10             	pushl  0x10(%ebp)
  80005a:	68 42 23 80 00       	push   $0x802342
  80005f:	e8 e6 19 00 00       	call   801a4a <printf>
  800064:	83 c4 10             	add    $0x10,%esp
	if(prefix) {
  800067:	85 db                	test   %ebx,%ebx
  800069:	74 3d                	je     8000a8 <ls1+0x75>
		if (prefix[0] && prefix[strlen(prefix)-1] != '/')
  80006b:	80 3b 00             	cmpb   $0x0,(%ebx)
  80006e:	74 1a                	je     80008a <ls1+0x57>
  800070:	83 ec 0c             	sub    $0xc,%esp
  800073:	53                   	push   %ebx
  800074:	e8 23 09 00 00       	call   80099c <strlen>
  800079:	83 c4 10             	add    $0x10,%esp
  80007c:	80 7c 03 ff 2f       	cmpb   $0x2f,-0x1(%ebx,%eax,1)
  800081:	75 0e                	jne    800091 <ls1+0x5e>
			sep = "/";
		else
			sep = "";
  800083:	b8 a8 23 80 00       	mov    $0x8023a8,%eax
  800088:	eb 0c                	jmp    800096 <ls1+0x63>
  80008a:	b8 a8 23 80 00       	mov    $0x8023a8,%eax
  80008f:	eb 05                	jmp    800096 <ls1+0x63>

	if(flag['l'])
		printf("%11d %c ", size, isdir ? 'd' : '-');
	if(prefix) {
		if (prefix[0] && prefix[strlen(prefix)-1] != '/')
			sep = "/";
  800091:	b8 40 23 80 00       	mov    $0x802340,%eax
		else
			sep = "";
		printf("%s%s", prefix, sep);
  800096:	83 ec 04             	sub    $0x4,%esp
  800099:	50                   	push   %eax
  80009a:	53                   	push   %ebx
  80009b:	68 4b 23 80 00       	push   $0x80234b
  8000a0:	e8 a5 19 00 00       	call   801a4a <printf>
  8000a5:	83 c4 10             	add    $0x10,%esp
	}
	printf("%s", name);
  8000a8:	83 ec 08             	sub    $0x8,%esp
  8000ab:	ff 75 14             	pushl  0x14(%ebp)
  8000ae:	68 c2 27 80 00       	push   $0x8027c2
  8000b3:	e8 92 19 00 00       	call   801a4a <printf>
	if(flag['F'] && isdir)
  8000b8:	83 c4 10             	add    $0x10,%esp
  8000bb:	83 3d 38 41 80 00 00 	cmpl   $0x0,0x804138
  8000c2:	74 16                	je     8000da <ls1+0xa7>
  8000c4:	89 f0                	mov    %esi,%eax
  8000c6:	84 c0                	test   %al,%al
  8000c8:	74 10                	je     8000da <ls1+0xa7>
		printf("/");
  8000ca:	83 ec 0c             	sub    $0xc,%esp
  8000cd:	68 40 23 80 00       	push   $0x802340
  8000d2:	e8 73 19 00 00       	call   801a4a <printf>
  8000d7:	83 c4 10             	add    $0x10,%esp
	printf("\n");
  8000da:	83 ec 0c             	sub    $0xc,%esp
  8000dd:	68 a7 23 80 00       	push   $0x8023a7
  8000e2:	e8 63 19 00 00       	call   801a4a <printf>
}
  8000e7:	83 c4 10             	add    $0x10,%esp
  8000ea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000ed:	5b                   	pop    %ebx
  8000ee:	5e                   	pop    %esi
  8000ef:	5d                   	pop    %ebp
  8000f0:	c3                   	ret    

008000f1 <lsdir>:
		ls1(0, st.st_isdir, st.st_size, path);
}

void
lsdir(const char *path, const char *prefix)
{
  8000f1:	55                   	push   %ebp
  8000f2:	89 e5                	mov    %esp,%ebp
  8000f4:	57                   	push   %edi
  8000f5:	56                   	push   %esi
  8000f6:	53                   	push   %ebx
  8000f7:	81 ec 14 01 00 00    	sub    $0x114,%esp
  8000fd:	8b 7d 08             	mov    0x8(%ebp),%edi
	int fd, n;
	struct File f;

	if ((fd = open(path, O_RDONLY)) < 0)
  800100:	6a 00                	push   $0x0
  800102:	57                   	push   %edi
  800103:	e8 c0 17 00 00       	call   8018c8 <open>
  800108:	89 c3                	mov    %eax,%ebx
  80010a:	83 c4 10             	add    $0x10,%esp
  80010d:	85 c0                	test   %eax,%eax
  80010f:	79 41                	jns    800152 <lsdir+0x61>
		panic("open %s: %e", path, fd);
  800111:	83 ec 0c             	sub    $0xc,%esp
  800114:	50                   	push   %eax
  800115:	57                   	push   %edi
  800116:	68 50 23 80 00       	push   $0x802350
  80011b:	6a 1d                	push   $0x1d
  80011d:	68 5c 23 80 00       	push   $0x80235c
  800122:	e8 0f 02 00 00       	call   800336 <_panic>
	while ((n = readn(fd, &f, sizeof f)) == sizeof f)
		if (f.f_name[0])
  800127:	80 bd e8 fe ff ff 00 	cmpb   $0x0,-0x118(%ebp)
  80012e:	74 28                	je     800158 <lsdir+0x67>
			ls1(prefix, f.f_type==FTYPE_DIR, f.f_size, f.f_name);
  800130:	56                   	push   %esi
  800131:	ff b5 68 ff ff ff    	pushl  -0x98(%ebp)
  800137:	83 bd 6c ff ff ff 01 	cmpl   $0x1,-0x94(%ebp)
  80013e:	0f 94 c0             	sete   %al
  800141:	0f b6 c0             	movzbl %al,%eax
  800144:	50                   	push   %eax
  800145:	ff 75 0c             	pushl  0xc(%ebp)
  800148:	e8 e6 fe ff ff       	call   800033 <ls1>
  80014d:	83 c4 10             	add    $0x10,%esp
  800150:	eb 06                	jmp    800158 <lsdir+0x67>
	int fd, n;
	struct File f;

	if ((fd = open(path, O_RDONLY)) < 0)
		panic("open %s: %e", path, fd);
	while ((n = readn(fd, &f, sizeof f)) == sizeof f)
  800152:	8d b5 e8 fe ff ff    	lea    -0x118(%ebp),%esi
  800158:	83 ec 04             	sub    $0x4,%esp
  80015b:	68 00 01 00 00       	push   $0x100
  800160:	56                   	push   %esi
  800161:	53                   	push   %ebx
  800162:	e8 e7 13 00 00       	call   80154e <readn>
  800167:	83 c4 10             	add    $0x10,%esp
  80016a:	3d 00 01 00 00       	cmp    $0x100,%eax
  80016f:	74 b6                	je     800127 <lsdir+0x36>
		if (f.f_name[0])
			ls1(prefix, f.f_type==FTYPE_DIR, f.f_size, f.f_name);
	if (n > 0)
  800171:	85 c0                	test   %eax,%eax
  800173:	7e 12                	jle    800187 <lsdir+0x96>
		panic("short read in directory %s", path);
  800175:	57                   	push   %edi
  800176:	68 66 23 80 00       	push   $0x802366
  80017b:	6a 22                	push   $0x22
  80017d:	68 5c 23 80 00       	push   $0x80235c
  800182:	e8 af 01 00 00       	call   800336 <_panic>
	if (n < 0)
  800187:	85 c0                	test   %eax,%eax
  800189:	79 16                	jns    8001a1 <lsdir+0xb0>
		panic("error reading directory %s: %e", path, n);
  80018b:	83 ec 0c             	sub    $0xc,%esp
  80018e:	50                   	push   %eax
  80018f:	57                   	push   %edi
  800190:	68 ac 23 80 00       	push   $0x8023ac
  800195:	6a 24                	push   $0x24
  800197:	68 5c 23 80 00       	push   $0x80235c
  80019c:	e8 95 01 00 00       	call   800336 <_panic>
}
  8001a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a4:	5b                   	pop    %ebx
  8001a5:	5e                   	pop    %esi
  8001a6:	5f                   	pop    %edi
  8001a7:	5d                   	pop    %ebp
  8001a8:	c3                   	ret    

008001a9 <ls>:
void lsdir(const char*, const char*);
void ls1(const char*, bool, off_t, const char*);

void
ls(const char *path, const char *prefix)
{
  8001a9:	55                   	push   %ebp
  8001aa:	89 e5                	mov    %esp,%ebp
  8001ac:	53                   	push   %ebx
  8001ad:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  8001b3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Stat st;

	if ((r = stat(path, &st)) < 0)
  8001b6:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
  8001bc:	50                   	push   %eax
  8001bd:	53                   	push   %ebx
  8001be:	e8 7e 15 00 00       	call   801741 <stat>
  8001c3:	83 c4 10             	add    $0x10,%esp
  8001c6:	85 c0                	test   %eax,%eax
  8001c8:	79 16                	jns    8001e0 <ls+0x37>
		panic("stat %s: %e", path, r);
  8001ca:	83 ec 0c             	sub    $0xc,%esp
  8001cd:	50                   	push   %eax
  8001ce:	53                   	push   %ebx
  8001cf:	68 81 23 80 00       	push   $0x802381
  8001d4:	6a 0f                	push   $0xf
  8001d6:	68 5c 23 80 00       	push   $0x80235c
  8001db:	e8 56 01 00 00       	call   800336 <_panic>
	if (st.st_isdir && !flag['d'])
  8001e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8001e3:	85 c0                	test   %eax,%eax
  8001e5:	74 1a                	je     800201 <ls+0x58>
  8001e7:	83 3d b0 41 80 00 00 	cmpl   $0x0,0x8041b0
  8001ee:	75 11                	jne    800201 <ls+0x58>
		lsdir(path, prefix);
  8001f0:	83 ec 08             	sub    $0x8,%esp
  8001f3:	ff 75 0c             	pushl  0xc(%ebp)
  8001f6:	53                   	push   %ebx
  8001f7:	e8 f5 fe ff ff       	call   8000f1 <lsdir>
  8001fc:	83 c4 10             	add    $0x10,%esp
  8001ff:	eb 17                	jmp    800218 <ls+0x6f>
	else
		ls1(0, st.st_isdir, st.st_size, path);
  800201:	53                   	push   %ebx
  800202:	ff 75 ec             	pushl  -0x14(%ebp)
  800205:	85 c0                	test   %eax,%eax
  800207:	0f 95 c0             	setne  %al
  80020a:	0f b6 c0             	movzbl %al,%eax
  80020d:	50                   	push   %eax
  80020e:	6a 00                	push   $0x0
  800210:	e8 1e fe ff ff       	call   800033 <ls1>
  800215:	83 c4 10             	add    $0x10,%esp
}
  800218:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80021b:	c9                   	leave  
  80021c:	c3                   	ret    

0080021d <usage>:
	printf("\n");
}

void
usage(void)
{
  80021d:	55                   	push   %ebp
  80021e:	89 e5                	mov    %esp,%ebp
  800220:	83 ec 14             	sub    $0x14,%esp
	printf("usage: ls [-dFl] [file...]\n");
  800223:	68 8d 23 80 00       	push   $0x80238d
  800228:	e8 1d 18 00 00       	call   801a4a <printf>
	exit();
  80022d:	e8 ea 00 00 00       	call   80031c <exit>
}
  800232:	83 c4 10             	add    $0x10,%esp
  800235:	c9                   	leave  
  800236:	c3                   	ret    

00800237 <umain>:

void
umain(int argc, char **argv)
{
  800237:	55                   	push   %ebp
  800238:	89 e5                	mov    %esp,%ebp
  80023a:	56                   	push   %esi
  80023b:	53                   	push   %ebx
  80023c:	83 ec 14             	sub    $0x14,%esp
  80023f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int i;
	struct Argstate args;

	argstart(&argc, argv, &args);
  800242:	8d 45 e8             	lea    -0x18(%ebp),%eax
  800245:	50                   	push   %eax
  800246:	56                   	push   %esi
  800247:	8d 45 08             	lea    0x8(%ebp),%eax
  80024a:	50                   	push   %eax
  80024b:	e8 04 0e 00 00       	call   801054 <argstart>
	while ((i = argnext(&args)) >= 0)
  800250:	83 c4 10             	add    $0x10,%esp
  800253:	8d 5d e8             	lea    -0x18(%ebp),%ebx
  800256:	eb 1d                	jmp    800275 <umain+0x3e>
		switch (i) {
  800258:	83 f8 64             	cmp    $0x64,%eax
  80025b:	74 0a                	je     800267 <umain+0x30>
  80025d:	83 f8 6c             	cmp    $0x6c,%eax
  800260:	74 05                	je     800267 <umain+0x30>
  800262:	83 f8 46             	cmp    $0x46,%eax
  800265:	75 09                	jne    800270 <umain+0x39>
		case 'd':
		case 'F':
		case 'l':
			flag[i]++;
  800267:	ff 04 85 20 40 80 00 	incl   0x804020(,%eax,4)
			break;
  80026e:	eb 05                	jmp    800275 <umain+0x3e>
		default:
			usage();
  800270:	e8 a8 ff ff ff       	call   80021d <usage>
{
	int i;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  800275:	83 ec 0c             	sub    $0xc,%esp
  800278:	53                   	push   %ebx
  800279:	e8 0f 0e 00 00       	call   80108d <argnext>
  80027e:	83 c4 10             	add    $0x10,%esp
  800281:	85 c0                	test   %eax,%eax
  800283:	79 d3                	jns    800258 <umain+0x21>
			break;
		default:
			usage();
		}

	if (argc == 1)
  800285:	8b 45 08             	mov    0x8(%ebp),%eax
  800288:	83 f8 01             	cmp    $0x1,%eax
  80028b:	74 0c                	je     800299 <umain+0x62>
		ls("/", "");
	else {
		for (i = 1; i < argc; i++)
  80028d:	bb 01 00 00 00       	mov    $0x1,%ebx
  800292:	83 f8 01             	cmp    $0x1,%eax
  800295:	7f 19                	jg     8002b0 <umain+0x79>
  800297:	eb 2d                	jmp    8002c6 <umain+0x8f>
		default:
			usage();
		}

	if (argc == 1)
		ls("/", "");
  800299:	83 ec 08             	sub    $0x8,%esp
  80029c:	68 a8 23 80 00       	push   $0x8023a8
  8002a1:	68 40 23 80 00       	push   $0x802340
  8002a6:	e8 fe fe ff ff       	call   8001a9 <ls>
  8002ab:	83 c4 10             	add    $0x10,%esp
  8002ae:	eb 16                	jmp    8002c6 <umain+0x8f>
	else {
		for (i = 1; i < argc; i++)
			ls(argv[i], argv[i]);
  8002b0:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  8002b3:	83 ec 08             	sub    $0x8,%esp
  8002b6:	50                   	push   %eax
  8002b7:	50                   	push   %eax
  8002b8:	e8 ec fe ff ff       	call   8001a9 <ls>
		}

	if (argc == 1)
		ls("/", "");
	else {
		for (i = 1; i < argc; i++)
  8002bd:	43                   	inc    %ebx
  8002be:	83 c4 10             	add    $0x10,%esp
  8002c1:	39 5d 08             	cmp    %ebx,0x8(%ebp)
  8002c4:	7f ea                	jg     8002b0 <umain+0x79>
			ls(argv[i], argv[i]);
	}
}
  8002c6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002c9:	5b                   	pop    %ebx
  8002ca:	5e                   	pop    %esi
  8002cb:	5d                   	pop    %ebp
  8002cc:	c3                   	ret    

008002cd <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8002cd:	55                   	push   %ebp
  8002ce:	89 e5                	mov    %esp,%ebp
  8002d0:	56                   	push   %esi
  8002d1:	53                   	push   %ebx
  8002d2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002d5:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8002d8:	e8 48 0b 00 00       	call   800e25 <sys_getenvid>
  8002dd:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002e2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8002e9:	c1 e0 07             	shl    $0x7,%eax
  8002ec:	29 d0                	sub    %edx,%eax
  8002ee:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002f3:	a3 20 44 80 00       	mov    %eax,0x804420

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002f8:	85 db                	test   %ebx,%ebx
  8002fa:	7e 07                	jle    800303 <libmain+0x36>
		binaryname = argv[0];
  8002fc:	8b 06                	mov    (%esi),%eax
  8002fe:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800303:	83 ec 08             	sub    $0x8,%esp
  800306:	56                   	push   %esi
  800307:	53                   	push   %ebx
  800308:	e8 2a ff ff ff       	call   800237 <umain>

	// exit gracefully
	exit();
  80030d:	e8 0a 00 00 00       	call   80031c <exit>
}
  800312:	83 c4 10             	add    $0x10,%esp
  800315:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800318:	5b                   	pop    %ebx
  800319:	5e                   	pop    %esi
  80031a:	5d                   	pop    %ebp
  80031b:	c3                   	ret    

0080031c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80031c:	55                   	push   %ebp
  80031d:	89 e5                	mov    %esp,%ebp
  80031f:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800322:	e8 93 10 00 00       	call   8013ba <close_all>
	sys_env_destroy(0);
  800327:	83 ec 0c             	sub    $0xc,%esp
  80032a:	6a 00                	push   $0x0
  80032c:	e8 b3 0a 00 00       	call   800de4 <sys_env_destroy>
}
  800331:	83 c4 10             	add    $0x10,%esp
  800334:	c9                   	leave  
  800335:	c3                   	ret    

00800336 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800336:	55                   	push   %ebp
  800337:	89 e5                	mov    %esp,%ebp
  800339:	56                   	push   %esi
  80033a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80033b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80033e:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800344:	e8 dc 0a 00 00       	call   800e25 <sys_getenvid>
  800349:	83 ec 0c             	sub    $0xc,%esp
  80034c:	ff 75 0c             	pushl  0xc(%ebp)
  80034f:	ff 75 08             	pushl  0x8(%ebp)
  800352:	56                   	push   %esi
  800353:	50                   	push   %eax
  800354:	68 d8 23 80 00       	push   $0x8023d8
  800359:	e8 b0 00 00 00       	call   80040e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80035e:	83 c4 18             	add    $0x18,%esp
  800361:	53                   	push   %ebx
  800362:	ff 75 10             	pushl  0x10(%ebp)
  800365:	e8 53 00 00 00       	call   8003bd <vcprintf>
	cprintf("\n");
  80036a:	c7 04 24 a7 23 80 00 	movl   $0x8023a7,(%esp)
  800371:	e8 98 00 00 00       	call   80040e <cprintf>
  800376:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800379:	cc                   	int3   
  80037a:	eb fd                	jmp    800379 <_panic+0x43>

0080037c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80037c:	55                   	push   %ebp
  80037d:	89 e5                	mov    %esp,%ebp
  80037f:	53                   	push   %ebx
  800380:	83 ec 04             	sub    $0x4,%esp
  800383:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800386:	8b 13                	mov    (%ebx),%edx
  800388:	8d 42 01             	lea    0x1(%edx),%eax
  80038b:	89 03                	mov    %eax,(%ebx)
  80038d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800390:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800394:	3d ff 00 00 00       	cmp    $0xff,%eax
  800399:	75 1a                	jne    8003b5 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80039b:	83 ec 08             	sub    $0x8,%esp
  80039e:	68 ff 00 00 00       	push   $0xff
  8003a3:	8d 43 08             	lea    0x8(%ebx),%eax
  8003a6:	50                   	push   %eax
  8003a7:	e8 fb 09 00 00       	call   800da7 <sys_cputs>
		b->idx = 0;
  8003ac:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003b2:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8003b5:	ff 43 04             	incl   0x4(%ebx)
}
  8003b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003bb:	c9                   	leave  
  8003bc:	c3                   	ret    

008003bd <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003bd:	55                   	push   %ebp
  8003be:	89 e5                	mov    %esp,%ebp
  8003c0:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003c6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003cd:	00 00 00 
	b.cnt = 0;
  8003d0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003d7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003da:	ff 75 0c             	pushl  0xc(%ebp)
  8003dd:	ff 75 08             	pushl  0x8(%ebp)
  8003e0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003e6:	50                   	push   %eax
  8003e7:	68 7c 03 80 00       	push   $0x80037c
  8003ec:	e8 54 01 00 00       	call   800545 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003f1:	83 c4 08             	add    $0x8,%esp
  8003f4:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003fa:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800400:	50                   	push   %eax
  800401:	e8 a1 09 00 00       	call   800da7 <sys_cputs>

	return b.cnt;
}
  800406:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80040c:	c9                   	leave  
  80040d:	c3                   	ret    

0080040e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80040e:	55                   	push   %ebp
  80040f:	89 e5                	mov    %esp,%ebp
  800411:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800414:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800417:	50                   	push   %eax
  800418:	ff 75 08             	pushl  0x8(%ebp)
  80041b:	e8 9d ff ff ff       	call   8003bd <vcprintf>
	va_end(ap);

	return cnt;
}
  800420:	c9                   	leave  
  800421:	c3                   	ret    

00800422 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800422:	55                   	push   %ebp
  800423:	89 e5                	mov    %esp,%ebp
  800425:	57                   	push   %edi
  800426:	56                   	push   %esi
  800427:	53                   	push   %ebx
  800428:	83 ec 1c             	sub    $0x1c,%esp
  80042b:	89 c6                	mov    %eax,%esi
  80042d:	89 d7                	mov    %edx,%edi
  80042f:	8b 45 08             	mov    0x8(%ebp),%eax
  800432:	8b 55 0c             	mov    0xc(%ebp),%edx
  800435:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800438:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80043b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80043e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800443:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800446:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800449:	39 d3                	cmp    %edx,%ebx
  80044b:	72 11                	jb     80045e <printnum+0x3c>
  80044d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800450:	76 0c                	jbe    80045e <printnum+0x3c>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800452:	8b 45 14             	mov    0x14(%ebp),%eax
  800455:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800458:	85 db                	test   %ebx,%ebx
  80045a:	7f 37                	jg     800493 <printnum+0x71>
  80045c:	eb 44                	jmp    8004a2 <printnum+0x80>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80045e:	83 ec 0c             	sub    $0xc,%esp
  800461:	ff 75 18             	pushl  0x18(%ebp)
  800464:	8b 45 14             	mov    0x14(%ebp),%eax
  800467:	48                   	dec    %eax
  800468:	50                   	push   %eax
  800469:	ff 75 10             	pushl  0x10(%ebp)
  80046c:	83 ec 08             	sub    $0x8,%esp
  80046f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800472:	ff 75 e0             	pushl  -0x20(%ebp)
  800475:	ff 75 dc             	pushl  -0x24(%ebp)
  800478:	ff 75 d8             	pushl  -0x28(%ebp)
  80047b:	e8 48 1c 00 00       	call   8020c8 <__udivdi3>
  800480:	83 c4 18             	add    $0x18,%esp
  800483:	52                   	push   %edx
  800484:	50                   	push   %eax
  800485:	89 fa                	mov    %edi,%edx
  800487:	89 f0                	mov    %esi,%eax
  800489:	e8 94 ff ff ff       	call   800422 <printnum>
  80048e:	83 c4 20             	add    $0x20,%esp
  800491:	eb 0f                	jmp    8004a2 <printnum+0x80>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800493:	83 ec 08             	sub    $0x8,%esp
  800496:	57                   	push   %edi
  800497:	ff 75 18             	pushl  0x18(%ebp)
  80049a:	ff d6                	call   *%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80049c:	83 c4 10             	add    $0x10,%esp
  80049f:	4b                   	dec    %ebx
  8004a0:	75 f1                	jne    800493 <printnum+0x71>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004a2:	83 ec 08             	sub    $0x8,%esp
  8004a5:	57                   	push   %edi
  8004a6:	83 ec 04             	sub    $0x4,%esp
  8004a9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004ac:	ff 75 e0             	pushl  -0x20(%ebp)
  8004af:	ff 75 dc             	pushl  -0x24(%ebp)
  8004b2:	ff 75 d8             	pushl  -0x28(%ebp)
  8004b5:	e8 1e 1d 00 00       	call   8021d8 <__umoddi3>
  8004ba:	83 c4 14             	add    $0x14,%esp
  8004bd:	0f be 80 fb 23 80 00 	movsbl 0x8023fb(%eax),%eax
  8004c4:	50                   	push   %eax
  8004c5:	ff d6                	call   *%esi
}
  8004c7:	83 c4 10             	add    $0x10,%esp
  8004ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004cd:	5b                   	pop    %ebx
  8004ce:	5e                   	pop    %esi
  8004cf:	5f                   	pop    %edi
  8004d0:	5d                   	pop    %ebp
  8004d1:	c3                   	ret    

008004d2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004d2:	55                   	push   %ebp
  8004d3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004d5:	83 fa 01             	cmp    $0x1,%edx
  8004d8:	7e 0e                	jle    8004e8 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004da:	8b 10                	mov    (%eax),%edx
  8004dc:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004df:	89 08                	mov    %ecx,(%eax)
  8004e1:	8b 02                	mov    (%edx),%eax
  8004e3:	8b 52 04             	mov    0x4(%edx),%edx
  8004e6:	eb 22                	jmp    80050a <getuint+0x38>
	else if (lflag)
  8004e8:	85 d2                	test   %edx,%edx
  8004ea:	74 10                	je     8004fc <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004ec:	8b 10                	mov    (%eax),%edx
  8004ee:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004f1:	89 08                	mov    %ecx,(%eax)
  8004f3:	8b 02                	mov    (%edx),%eax
  8004f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8004fa:	eb 0e                	jmp    80050a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004fc:	8b 10                	mov    (%eax),%edx
  8004fe:	8d 4a 04             	lea    0x4(%edx),%ecx
  800501:	89 08                	mov    %ecx,(%eax)
  800503:	8b 02                	mov    (%edx),%eax
  800505:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80050a:	5d                   	pop    %ebp
  80050b:	c3                   	ret    

0080050c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80050c:	55                   	push   %ebp
  80050d:	89 e5                	mov    %esp,%ebp
  80050f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800512:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800515:	8b 10                	mov    (%eax),%edx
  800517:	3b 50 04             	cmp    0x4(%eax),%edx
  80051a:	73 0a                	jae    800526 <sprintputch+0x1a>
		*b->buf++ = ch;
  80051c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80051f:	89 08                	mov    %ecx,(%eax)
  800521:	8b 45 08             	mov    0x8(%ebp),%eax
  800524:	88 02                	mov    %al,(%edx)
}
  800526:	5d                   	pop    %ebp
  800527:	c3                   	ret    

00800528 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800528:	55                   	push   %ebp
  800529:	89 e5                	mov    %esp,%ebp
  80052b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80052e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800531:	50                   	push   %eax
  800532:	ff 75 10             	pushl  0x10(%ebp)
  800535:	ff 75 0c             	pushl  0xc(%ebp)
  800538:	ff 75 08             	pushl  0x8(%ebp)
  80053b:	e8 05 00 00 00       	call   800545 <vprintfmt>
	va_end(ap);
}
  800540:	83 c4 10             	add    $0x10,%esp
  800543:	c9                   	leave  
  800544:	c3                   	ret    

00800545 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800545:	55                   	push   %ebp
  800546:	89 e5                	mov    %esp,%ebp
  800548:	57                   	push   %edi
  800549:	56                   	push   %esi
  80054a:	53                   	push   %ebx
  80054b:	83 ec 2c             	sub    $0x2c,%esp
  80054e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800551:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800554:	eb 03                	jmp    800559 <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  800556:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  800559:	8b 45 10             	mov    0x10(%ebp),%eax
  80055c:	8d 70 01             	lea    0x1(%eax),%esi
  80055f:	0f b6 00             	movzbl (%eax),%eax
  800562:	83 f8 25             	cmp    $0x25,%eax
  800565:	74 25                	je     80058c <vprintfmt+0x47>
			if (ch == '\0')									//当然中间如果遇到'\0'，代表这个字符串的访问结束
  800567:	85 c0                	test   %eax,%eax
  800569:	75 0d                	jne    800578 <vprintfmt+0x33>
  80056b:	e9 b5 03 00 00       	jmp    800925 <vprintfmt+0x3e0>
  800570:	85 c0                	test   %eax,%eax
  800572:	0f 84 ad 03 00 00    	je     800925 <vprintfmt+0x3e0>
				return;
			putch(ch, putdat);								//调用putch函数，把一个字符ch输出到putdat指针所指向的地址中所存放的值对应的地址处
  800578:	83 ec 08             	sub    $0x8,%esp
  80057b:	53                   	push   %ebx
  80057c:	50                   	push   %eax
  80057d:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  80057f:	46                   	inc    %esi
  800580:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800584:	83 c4 10             	add    $0x10,%esp
  800587:	83 f8 25             	cmp    $0x25,%eax
  80058a:	75 e4                	jne    800570 <vprintfmt+0x2b>
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  80058c:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  800590:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800597:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80059e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8005a5:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8005ac:	eb 07                	jmp    8005b5 <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8005ae:	8b 75 10             	mov    0x10(%ebp),%esi

		// flag to pad on the right
		case '-':											//%后面的'-'代表要进行左对齐输出，右边填空格，如果省略代表右对齐
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
  8005b1:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8005b5:	8d 46 01             	lea    0x1(%esi),%eax
  8005b8:	89 45 10             	mov    %eax,0x10(%ebp)
  8005bb:	0f b6 16             	movzbl (%esi),%edx
  8005be:	8a 06                	mov    (%esi),%al
  8005c0:	83 e8 23             	sub    $0x23,%eax
  8005c3:	3c 55                	cmp    $0x55,%al
  8005c5:	0f 87 03 03 00 00    	ja     8008ce <vprintfmt+0x389>
  8005cb:	0f b6 c0             	movzbl %al,%eax
  8005ce:	ff 24 85 40 25 80 00 	jmp    *0x802540(,%eax,4)
  8005d5:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
			goto reswitch;									//处理下一个字符

		// flag to pad with 0's instead of spaces
		case '0':											//0--有0表示进行对齐输出时填0,如省略表示填入空格，并且如果为0，则一定是右对齐
			padc = '0';										//对其方式标志位变为0
  8005d8:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  8005dc:	eb d7                	jmp    8005b5 <vprintfmt+0x70>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
				precision = precision * 10 + ch - '0';
  8005de:	8d 42 d0             	lea    -0x30(%edx),%eax
  8005e1:	89 c1                	mov    %eax,%ecx
  8005e3:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  8005e6:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8005ea:	8d 50 d0             	lea    -0x30(%eax),%edx
  8005ed:	83 fa 09             	cmp    $0x9,%edx
  8005f0:	77 51                	ja     800643 <vprintfmt+0xfe>
  8005f2:	8b 75 10             	mov    0x10(%ebp),%esi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
  8005f5:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8005f6:	8d 14 89             	lea    (%ecx,%ecx,4),%edx
  8005f9:	01 d2                	add    %edx,%edx
  8005fb:	8d 4c 10 d0          	lea    -0x30(%eax,%edx,1),%ecx
				ch = *fmt;
  8005ff:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800602:	8d 50 d0             	lea    -0x30(%eax),%edx
  800605:	83 fa 09             	cmp    $0x9,%edx
  800608:	76 eb                	jbe    8005f5 <vprintfmt+0xb0>
  80060a:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80060d:	eb 37                	jmp    800646 <vprintfmt+0x101>
					break;
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
  80060f:	8b 45 14             	mov    0x14(%ebp),%eax
  800612:	8d 50 04             	lea    0x4(%eax),%edx
  800615:	89 55 14             	mov    %edx,0x14(%ebp)
  800618:	8b 00                	mov    (%eax),%eax
  80061a:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80061d:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
			goto process_precision;
  800620:	eb 24                	jmp    800646 <vprintfmt+0x101>
  800622:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800626:	79 07                	jns    80062f <vprintfmt+0xea>
  800628:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80062f:	8b 75 10             	mov    0x10(%ebp),%esi
  800632:	eb 81                	jmp    8005b5 <vprintfmt+0x70>
  800634:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  800637:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80063e:	e9 72 ff ff ff       	jmp    8005b5 <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800643:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:									//处理输出精度，把width字段赋值为刚刚计算出来的precision值，所以width应该是整数部分的有效数字位数
			if (width < 0)
  800646:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80064a:	0f 89 65 ff ff ff    	jns    8005b5 <vprintfmt+0x70>
				width = precision, precision = -1;
  800650:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800653:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800656:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80065d:	e9 53 ff ff ff       	jmp    8005b5 <vprintfmt+0x70>
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
  800662:	ff 45 d4             	incl   -0x2c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800665:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
			goto reswitch;
  800668:	e9 48 ff ff ff       	jmp    8005b5 <vprintfmt+0x70>

		// character
		case 'c':											//如果是'c'代表显示一个字符
			putch(va_arg(ap, int), putdat);					//调用输出一个字符到内存的函数putch
  80066d:	8b 45 14             	mov    0x14(%ebp),%eax
  800670:	8d 50 04             	lea    0x4(%eax),%edx
  800673:	89 55 14             	mov    %edx,0x14(%ebp)
  800676:	83 ec 08             	sub    $0x8,%esp
  800679:	53                   	push   %ebx
  80067a:	ff 30                	pushl  (%eax)
  80067c:	ff d7                	call   *%edi
			break;
  80067e:	83 c4 10             	add    $0x10,%esp
  800681:	e9 d3 fe ff ff       	jmp    800559 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800686:	8b 45 14             	mov    0x14(%ebp),%eax
  800689:	8d 50 04             	lea    0x4(%eax),%edx
  80068c:	89 55 14             	mov    %edx,0x14(%ebp)
  80068f:	8b 00                	mov    (%eax),%eax
  800691:	85 c0                	test   %eax,%eax
  800693:	79 02                	jns    800697 <vprintfmt+0x152>
  800695:	f7 d8                	neg    %eax
  800697:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800699:	83 f8 0f             	cmp    $0xf,%eax
  80069c:	7f 0b                	jg     8006a9 <vprintfmt+0x164>
  80069e:	8b 04 85 a0 26 80 00 	mov    0x8026a0(,%eax,4),%eax
  8006a5:	85 c0                	test   %eax,%eax
  8006a7:	75 15                	jne    8006be <vprintfmt+0x179>
				printfmt(putch, putdat, "error %d", err);
  8006a9:	52                   	push   %edx
  8006aa:	68 13 24 80 00       	push   $0x802413
  8006af:	53                   	push   %ebx
  8006b0:	57                   	push   %edi
  8006b1:	e8 72 fe ff ff       	call   800528 <printfmt>
  8006b6:	83 c4 10             	add    $0x10,%esp
  8006b9:	e9 9b fe ff ff       	jmp    800559 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  8006be:	50                   	push   %eax
  8006bf:	68 c2 27 80 00       	push   $0x8027c2
  8006c4:	53                   	push   %ebx
  8006c5:	57                   	push   %edi
  8006c6:	e8 5d fe ff ff       	call   800528 <printfmt>
  8006cb:	83 c4 10             	add    $0x10,%esp
  8006ce:	e9 86 fe ff ff       	jmp    800559 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d6:	8d 50 04             	lea    0x4(%eax),%edx
  8006d9:	89 55 14             	mov    %edx,0x14(%ebp)
  8006dc:	8b 00                	mov    (%eax),%eax
  8006de:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8006e1:	85 c0                	test   %eax,%eax
  8006e3:	75 07                	jne    8006ec <vprintfmt+0x1a7>
				p = "(null)";
  8006e5:	c7 45 d4 0c 24 80 00 	movl   $0x80240c,-0x2c(%ebp)
			if (width > 0 && padc != '-')
  8006ec:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8006ef:	85 f6                	test   %esi,%esi
  8006f1:	0f 8e fb 01 00 00    	jle    8008f2 <vprintfmt+0x3ad>
  8006f7:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  8006fb:	0f 84 09 02 00 00    	je     80090a <vprintfmt+0x3c5>
				for (width -= strnlen(p, precision); width > 0; width--)
  800701:	83 ec 08             	sub    $0x8,%esp
  800704:	ff 75 d0             	pushl  -0x30(%ebp)
  800707:	ff 75 d4             	pushl  -0x2c(%ebp)
  80070a:	e8 ad 02 00 00       	call   8009bc <strnlen>
  80070f:	89 f1                	mov    %esi,%ecx
  800711:	29 c1                	sub    %eax,%ecx
  800713:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800716:	83 c4 10             	add    $0x10,%esp
  800719:	85 c9                	test   %ecx,%ecx
  80071b:	0f 8e d1 01 00 00    	jle    8008f2 <vprintfmt+0x3ad>
					putch(padc, putdat);
  800721:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800725:	83 ec 08             	sub    $0x8,%esp
  800728:	53                   	push   %ebx
  800729:	56                   	push   %esi
  80072a:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80072c:	83 c4 10             	add    $0x10,%esp
  80072f:	ff 4d e4             	decl   -0x1c(%ebp)
  800732:	75 f1                	jne    800725 <vprintfmt+0x1e0>
  800734:	e9 b9 01 00 00       	jmp    8008f2 <vprintfmt+0x3ad>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800739:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80073d:	74 19                	je     800758 <vprintfmt+0x213>
  80073f:	0f be c0             	movsbl %al,%eax
  800742:	83 e8 20             	sub    $0x20,%eax
  800745:	83 f8 5e             	cmp    $0x5e,%eax
  800748:	76 0e                	jbe    800758 <vprintfmt+0x213>
					putch('?', putdat);
  80074a:	83 ec 08             	sub    $0x8,%esp
  80074d:	53                   	push   %ebx
  80074e:	6a 3f                	push   $0x3f
  800750:	ff 55 08             	call   *0x8(%ebp)
  800753:	83 c4 10             	add    $0x10,%esp
  800756:	eb 0b                	jmp    800763 <vprintfmt+0x21e>
				else
					putch(ch, putdat);
  800758:	83 ec 08             	sub    $0x8,%esp
  80075b:	53                   	push   %ebx
  80075c:	52                   	push   %edx
  80075d:	ff 55 08             	call   *0x8(%ebp)
  800760:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800763:	ff 4d e4             	decl   -0x1c(%ebp)
  800766:	46                   	inc    %esi
  800767:	8a 46 ff             	mov    -0x1(%esi),%al
  80076a:	0f be d0             	movsbl %al,%edx
  80076d:	85 d2                	test   %edx,%edx
  80076f:	75 1c                	jne    80078d <vprintfmt+0x248>
  800771:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800774:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800778:	7f 1f                	jg     800799 <vprintfmt+0x254>
  80077a:	e9 da fd ff ff       	jmp    800559 <vprintfmt+0x14>
  80077f:	89 7d 08             	mov    %edi,0x8(%ebp)
  800782:	8b 7d d0             	mov    -0x30(%ebp),%edi
  800785:	eb 06                	jmp    80078d <vprintfmt+0x248>
  800787:	89 7d 08             	mov    %edi,0x8(%ebp)
  80078a:	8b 7d d0             	mov    -0x30(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80078d:	85 ff                	test   %edi,%edi
  80078f:	78 a8                	js     800739 <vprintfmt+0x1f4>
  800791:	4f                   	dec    %edi
  800792:	79 a5                	jns    800739 <vprintfmt+0x1f4>
  800794:	8b 7d 08             	mov    0x8(%ebp),%edi
  800797:	eb db                	jmp    800774 <vprintfmt+0x22f>
  800799:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80079c:	83 ec 08             	sub    $0x8,%esp
  80079f:	53                   	push   %ebx
  8007a0:	6a 20                	push   $0x20
  8007a2:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007a4:	4e                   	dec    %esi
  8007a5:	83 c4 10             	add    $0x10,%esp
  8007a8:	85 f6                	test   %esi,%esi
  8007aa:	7f f0                	jg     80079c <vprintfmt+0x257>
  8007ac:	e9 a8 fd ff ff       	jmp    800559 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007b1:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  8007b5:	7e 16                	jle    8007cd <vprintfmt+0x288>
		return va_arg(*ap, long long);
  8007b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ba:	8d 50 08             	lea    0x8(%eax),%edx
  8007bd:	89 55 14             	mov    %edx,0x14(%ebp)
  8007c0:	8b 50 04             	mov    0x4(%eax),%edx
  8007c3:	8b 00                	mov    (%eax),%eax
  8007c5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007c8:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007cb:	eb 34                	jmp    800801 <vprintfmt+0x2bc>
	else if (lflag)
  8007cd:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8007d1:	74 18                	je     8007eb <vprintfmt+0x2a6>
		return va_arg(*ap, long);
  8007d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d6:	8d 50 04             	lea    0x4(%eax),%edx
  8007d9:	89 55 14             	mov    %edx,0x14(%ebp)
  8007dc:	8b 30                	mov    (%eax),%esi
  8007de:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8007e1:	89 f0                	mov    %esi,%eax
  8007e3:	c1 f8 1f             	sar    $0x1f,%eax
  8007e6:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8007e9:	eb 16                	jmp    800801 <vprintfmt+0x2bc>
	else
		return va_arg(*ap, int);
  8007eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ee:	8d 50 04             	lea    0x4(%eax),%edx
  8007f1:	89 55 14             	mov    %edx,0x14(%ebp)
  8007f4:	8b 30                	mov    (%eax),%esi
  8007f6:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8007f9:	89 f0                	mov    %esi,%eax
  8007fb:	c1 f8 1f             	sar    $0x1f,%eax
  8007fe:	89 45 dc             	mov    %eax,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800801:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800804:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
  800807:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80080b:	0f 89 8a 00 00 00    	jns    80089b <vprintfmt+0x356>
				putch('-', putdat);
  800811:	83 ec 08             	sub    $0x8,%esp
  800814:	53                   	push   %ebx
  800815:	6a 2d                	push   $0x2d
  800817:	ff d7                	call   *%edi
				num = -(long long) num;
  800819:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80081c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80081f:	f7 d8                	neg    %eax
  800821:	83 d2 00             	adc    $0x0,%edx
  800824:	f7 da                	neg    %edx
  800826:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800829:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80082e:	eb 70                	jmp    8008a0 <vprintfmt+0x35b>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800830:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800833:	8d 45 14             	lea    0x14(%ebp),%eax
  800836:	e8 97 fc ff ff       	call   8004d2 <getuint>
			base = 10;
  80083b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800840:	eb 5e                	jmp    8008a0 <vprintfmt+0x35b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  800842:	83 ec 08             	sub    $0x8,%esp
  800845:	53                   	push   %ebx
  800846:	6a 30                	push   $0x30
  800848:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  80084a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80084d:	8d 45 14             	lea    0x14(%ebp),%eax
  800850:	e8 7d fc ff ff       	call   8004d2 <getuint>
			base = 8;
			goto number;
  800855:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800858:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80085d:	eb 41                	jmp    8008a0 <vprintfmt+0x35b>
		// pointer
		case 'p':
			putch('0', putdat);
  80085f:	83 ec 08             	sub    $0x8,%esp
  800862:	53                   	push   %ebx
  800863:	6a 30                	push   $0x30
  800865:	ff d7                	call   *%edi
			putch('x', putdat);
  800867:	83 c4 08             	add    $0x8,%esp
  80086a:	53                   	push   %ebx
  80086b:	6a 78                	push   $0x78
  80086d:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80086f:	8b 45 14             	mov    0x14(%ebp),%eax
  800872:	8d 50 04             	lea    0x4(%eax),%edx
  800875:	89 55 14             	mov    %edx,0x14(%ebp)
			goto number;
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800878:	8b 00                	mov    (%eax),%eax
  80087a:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80087f:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800882:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800887:	eb 17                	jmp    8008a0 <vprintfmt+0x35b>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800889:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80088c:	8d 45 14             	lea    0x14(%ebp),%eax
  80088f:	e8 3e fc ff ff       	call   8004d2 <getuint>
			base = 16;
  800894:	b9 10 00 00 00       	mov    $0x10,%ecx
  800899:	eb 05                	jmp    8008a0 <vprintfmt+0x35b>
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80089b:	b9 0a 00 00 00       	mov    $0xa,%ecx
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008a0:	83 ec 0c             	sub    $0xc,%esp
  8008a3:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8008a7:	56                   	push   %esi
  8008a8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8008ab:	51                   	push   %ecx
  8008ac:	52                   	push   %edx
  8008ad:	50                   	push   %eax
  8008ae:	89 da                	mov    %ebx,%edx
  8008b0:	89 f8                	mov    %edi,%eax
  8008b2:	e8 6b fb ff ff       	call   800422 <printnum>
			break;
  8008b7:	83 c4 20             	add    $0x20,%esp
  8008ba:	e9 9a fc ff ff       	jmp    800559 <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008bf:	83 ec 08             	sub    $0x8,%esp
  8008c2:	53                   	push   %ebx
  8008c3:	52                   	push   %edx
  8008c4:	ff d7                	call   *%edi
			break;
  8008c6:	83 c4 10             	add    $0x10,%esp
  8008c9:	e9 8b fc ff ff       	jmp    800559 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008ce:	83 ec 08             	sub    $0x8,%esp
  8008d1:	53                   	push   %ebx
  8008d2:	6a 25                	push   $0x25
  8008d4:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008d6:	83 c4 10             	add    $0x10,%esp
  8008d9:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8008dd:	0f 84 73 fc ff ff    	je     800556 <vprintfmt+0x11>
  8008e3:	4e                   	dec    %esi
  8008e4:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8008e8:	75 f9                	jne    8008e3 <vprintfmt+0x39e>
  8008ea:	89 75 10             	mov    %esi,0x10(%ebp)
  8008ed:	e9 67 fc ff ff       	jmp    800559 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008f2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8008f5:	8d 70 01             	lea    0x1(%eax),%esi
  8008f8:	8a 00                	mov    (%eax),%al
  8008fa:	0f be d0             	movsbl %al,%edx
  8008fd:	85 d2                	test   %edx,%edx
  8008ff:	0f 85 7a fe ff ff    	jne    80077f <vprintfmt+0x23a>
  800905:	e9 4f fc ff ff       	jmp    800559 <vprintfmt+0x14>
  80090a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80090d:	8d 70 01             	lea    0x1(%eax),%esi
  800910:	8a 00                	mov    (%eax),%al
  800912:	0f be d0             	movsbl %al,%edx
  800915:	85 d2                	test   %edx,%edx
  800917:	0f 85 6a fe ff ff    	jne    800787 <vprintfmt+0x242>
  80091d:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800920:	e9 77 fe ff ff       	jmp    80079c <vprintfmt+0x257>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800925:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800928:	5b                   	pop    %ebx
  800929:	5e                   	pop    %esi
  80092a:	5f                   	pop    %edi
  80092b:	5d                   	pop    %ebp
  80092c:	c3                   	ret    

0080092d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80092d:	55                   	push   %ebp
  80092e:	89 e5                	mov    %esp,%ebp
  800930:	83 ec 18             	sub    $0x18,%esp
  800933:	8b 45 08             	mov    0x8(%ebp),%eax
  800936:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800939:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80093c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800940:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800943:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80094a:	85 c0                	test   %eax,%eax
  80094c:	74 26                	je     800974 <vsnprintf+0x47>
  80094e:	85 d2                	test   %edx,%edx
  800950:	7e 29                	jle    80097b <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800952:	ff 75 14             	pushl  0x14(%ebp)
  800955:	ff 75 10             	pushl  0x10(%ebp)
  800958:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80095b:	50                   	push   %eax
  80095c:	68 0c 05 80 00       	push   $0x80050c
  800961:	e8 df fb ff ff       	call   800545 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800966:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800969:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80096c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80096f:	83 c4 10             	add    $0x10,%esp
  800972:	eb 0c                	jmp    800980 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800974:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800979:	eb 05                	jmp    800980 <vsnprintf+0x53>
  80097b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800980:	c9                   	leave  
  800981:	c3                   	ret    

00800982 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800988:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80098b:	50                   	push   %eax
  80098c:	ff 75 10             	pushl  0x10(%ebp)
  80098f:	ff 75 0c             	pushl  0xc(%ebp)
  800992:	ff 75 08             	pushl  0x8(%ebp)
  800995:	e8 93 ff ff ff       	call   80092d <vsnprintf>
	va_end(ap);

	return rc;
}
  80099a:	c9                   	leave  
  80099b:	c3                   	ret    

0080099c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
  80099f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009a2:	80 3a 00             	cmpb   $0x0,(%edx)
  8009a5:	74 0e                	je     8009b5 <strlen+0x19>
  8009a7:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8009ac:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009ad:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009b1:	75 f9                	jne    8009ac <strlen+0x10>
  8009b3:	eb 05                	jmp    8009ba <strlen+0x1e>
  8009b5:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8009ba:	5d                   	pop    %ebp
  8009bb:	c3                   	ret    

008009bc <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009bc:	55                   	push   %ebp
  8009bd:	89 e5                	mov    %esp,%ebp
  8009bf:	53                   	push   %ebx
  8009c0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009c6:	85 c9                	test   %ecx,%ecx
  8009c8:	74 1a                	je     8009e4 <strnlen+0x28>
  8009ca:	80 3b 00             	cmpb   $0x0,(%ebx)
  8009cd:	74 1c                	je     8009eb <strnlen+0x2f>
  8009cf:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8009d4:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009d6:	39 ca                	cmp    %ecx,%edx
  8009d8:	74 16                	je     8009f0 <strnlen+0x34>
  8009da:	42                   	inc    %edx
  8009db:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8009e0:	75 f2                	jne    8009d4 <strnlen+0x18>
  8009e2:	eb 0c                	jmp    8009f0 <strnlen+0x34>
  8009e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8009e9:	eb 05                	jmp    8009f0 <strnlen+0x34>
  8009eb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8009f0:	5b                   	pop    %ebx
  8009f1:	5d                   	pop    %ebp
  8009f2:	c3                   	ret    

008009f3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009f3:	55                   	push   %ebp
  8009f4:	89 e5                	mov    %esp,%ebp
  8009f6:	53                   	push   %ebx
  8009f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009fd:	89 c2                	mov    %eax,%edx
  8009ff:	42                   	inc    %edx
  800a00:	41                   	inc    %ecx
  800a01:	8a 59 ff             	mov    -0x1(%ecx),%bl
  800a04:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a07:	84 db                	test   %bl,%bl
  800a09:	75 f4                	jne    8009ff <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a0b:	5b                   	pop    %ebx
  800a0c:	5d                   	pop    %ebp
  800a0d:	c3                   	ret    

00800a0e <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a0e:	55                   	push   %ebp
  800a0f:	89 e5                	mov    %esp,%ebp
  800a11:	53                   	push   %ebx
  800a12:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a15:	53                   	push   %ebx
  800a16:	e8 81 ff ff ff       	call   80099c <strlen>
  800a1b:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a1e:	ff 75 0c             	pushl  0xc(%ebp)
  800a21:	01 d8                	add    %ebx,%eax
  800a23:	50                   	push   %eax
  800a24:	e8 ca ff ff ff       	call   8009f3 <strcpy>
	return dst;
}
  800a29:	89 d8                	mov    %ebx,%eax
  800a2b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a2e:	c9                   	leave  
  800a2f:	c3                   	ret    

00800a30 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a30:	55                   	push   %ebp
  800a31:	89 e5                	mov    %esp,%ebp
  800a33:	56                   	push   %esi
  800a34:	53                   	push   %ebx
  800a35:	8b 75 08             	mov    0x8(%ebp),%esi
  800a38:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a3b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a3e:	85 db                	test   %ebx,%ebx
  800a40:	74 14                	je     800a56 <strncpy+0x26>
  800a42:	01 f3                	add    %esi,%ebx
  800a44:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800a46:	41                   	inc    %ecx
  800a47:	8a 02                	mov    (%edx),%al
  800a49:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a4c:	80 3a 01             	cmpb   $0x1,(%edx)
  800a4f:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a52:	39 cb                	cmp    %ecx,%ebx
  800a54:	75 f0                	jne    800a46 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a56:	89 f0                	mov    %esi,%eax
  800a58:	5b                   	pop    %ebx
  800a59:	5e                   	pop    %esi
  800a5a:	5d                   	pop    %ebp
  800a5b:	c3                   	ret    

00800a5c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a5c:	55                   	push   %ebp
  800a5d:	89 e5                	mov    %esp,%ebp
  800a5f:	53                   	push   %ebx
  800a60:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a63:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a66:	85 c0                	test   %eax,%eax
  800a68:	74 30                	je     800a9a <strlcpy+0x3e>
		while (--size > 0 && *src != '\0')
  800a6a:	48                   	dec    %eax
  800a6b:	74 20                	je     800a8d <strlcpy+0x31>
  800a6d:	8a 0b                	mov    (%ebx),%cl
  800a6f:	84 c9                	test   %cl,%cl
  800a71:	74 1f                	je     800a92 <strlcpy+0x36>
  800a73:	8d 53 01             	lea    0x1(%ebx),%edx
  800a76:	01 c3                	add    %eax,%ebx
  800a78:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
  800a7b:	40                   	inc    %eax
  800a7c:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a7f:	39 da                	cmp    %ebx,%edx
  800a81:	74 12                	je     800a95 <strlcpy+0x39>
  800a83:	42                   	inc    %edx
  800a84:	8a 4a ff             	mov    -0x1(%edx),%cl
  800a87:	84 c9                	test   %cl,%cl
  800a89:	75 f0                	jne    800a7b <strlcpy+0x1f>
  800a8b:	eb 08                	jmp    800a95 <strlcpy+0x39>
  800a8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a90:	eb 03                	jmp    800a95 <strlcpy+0x39>
  800a92:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
		*dst = '\0';
  800a95:	c6 00 00             	movb   $0x0,(%eax)
  800a98:	eb 03                	jmp    800a9d <strlcpy+0x41>
  800a9a:	8b 45 08             	mov    0x8(%ebp),%eax
	}
	return dst - dst_in;
  800a9d:	2b 45 08             	sub    0x8(%ebp),%eax
}
  800aa0:	5b                   	pop    %ebx
  800aa1:	5d                   	pop    %ebp
  800aa2:	c3                   	ret    

00800aa3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800aa3:	55                   	push   %ebp
  800aa4:	89 e5                	mov    %esp,%ebp
  800aa6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aa9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800aac:	8a 01                	mov    (%ecx),%al
  800aae:	84 c0                	test   %al,%al
  800ab0:	74 10                	je     800ac2 <strcmp+0x1f>
  800ab2:	3a 02                	cmp    (%edx),%al
  800ab4:	75 0c                	jne    800ac2 <strcmp+0x1f>
		p++, q++;
  800ab6:	41                   	inc    %ecx
  800ab7:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800ab8:	8a 01                	mov    (%ecx),%al
  800aba:	84 c0                	test   %al,%al
  800abc:	74 04                	je     800ac2 <strcmp+0x1f>
  800abe:	3a 02                	cmp    (%edx),%al
  800ac0:	74 f4                	je     800ab6 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ac2:	0f b6 c0             	movzbl %al,%eax
  800ac5:	0f b6 12             	movzbl (%edx),%edx
  800ac8:	29 d0                	sub    %edx,%eax
}
  800aca:	5d                   	pop    %ebp
  800acb:	c3                   	ret    

00800acc <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800acc:	55                   	push   %ebp
  800acd:	89 e5                	mov    %esp,%ebp
  800acf:	56                   	push   %esi
  800ad0:	53                   	push   %ebx
  800ad1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ad4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ad7:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800ada:	85 f6                	test   %esi,%esi
  800adc:	74 23                	je     800b01 <strncmp+0x35>
  800ade:	8a 03                	mov    (%ebx),%al
  800ae0:	84 c0                	test   %al,%al
  800ae2:	74 2b                	je     800b0f <strncmp+0x43>
  800ae4:	3a 02                	cmp    (%edx),%al
  800ae6:	75 27                	jne    800b0f <strncmp+0x43>
  800ae8:	8d 43 01             	lea    0x1(%ebx),%eax
  800aeb:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800aed:	89 c3                	mov    %eax,%ebx
  800aef:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800af0:	39 c6                	cmp    %eax,%esi
  800af2:	74 14                	je     800b08 <strncmp+0x3c>
  800af4:	8a 08                	mov    (%eax),%cl
  800af6:	84 c9                	test   %cl,%cl
  800af8:	74 15                	je     800b0f <strncmp+0x43>
  800afa:	40                   	inc    %eax
  800afb:	3a 0a                	cmp    (%edx),%cl
  800afd:	74 ee                	je     800aed <strncmp+0x21>
  800aff:	eb 0e                	jmp    800b0f <strncmp+0x43>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b01:	b8 00 00 00 00       	mov    $0x0,%eax
  800b06:	eb 0f                	jmp    800b17 <strncmp+0x4b>
  800b08:	b8 00 00 00 00       	mov    $0x0,%eax
  800b0d:	eb 08                	jmp    800b17 <strncmp+0x4b>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b0f:	0f b6 03             	movzbl (%ebx),%eax
  800b12:	0f b6 12             	movzbl (%edx),%edx
  800b15:	29 d0                	sub    %edx,%eax
}
  800b17:	5b                   	pop    %ebx
  800b18:	5e                   	pop    %esi
  800b19:	5d                   	pop    %ebp
  800b1a:	c3                   	ret    

00800b1b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b1b:	55                   	push   %ebp
  800b1c:	89 e5                	mov    %esp,%ebp
  800b1e:	53                   	push   %ebx
  800b1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b22:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800b25:	8a 10                	mov    (%eax),%dl
  800b27:	84 d2                	test   %dl,%dl
  800b29:	74 1a                	je     800b45 <strchr+0x2a>
  800b2b:	88 d9                	mov    %bl,%cl
		if (*s == c)
  800b2d:	38 d3                	cmp    %dl,%bl
  800b2f:	75 06                	jne    800b37 <strchr+0x1c>
  800b31:	eb 17                	jmp    800b4a <strchr+0x2f>
  800b33:	38 ca                	cmp    %cl,%dl
  800b35:	74 13                	je     800b4a <strchr+0x2f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b37:	40                   	inc    %eax
  800b38:	8a 10                	mov    (%eax),%dl
  800b3a:	84 d2                	test   %dl,%dl
  800b3c:	75 f5                	jne    800b33 <strchr+0x18>
		if (*s == c)
			return (char *) s;
	return 0;
  800b3e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b43:	eb 05                	jmp    800b4a <strchr+0x2f>
  800b45:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b4a:	5b                   	pop    %ebx
  800b4b:	5d                   	pop    %ebp
  800b4c:	c3                   	ret    

00800b4d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b4d:	55                   	push   %ebp
  800b4e:	89 e5                	mov    %esp,%ebp
  800b50:	53                   	push   %ebx
  800b51:	8b 45 08             	mov    0x8(%ebp),%eax
  800b54:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800b57:	8a 10                	mov    (%eax),%dl
  800b59:	84 d2                	test   %dl,%dl
  800b5b:	74 13                	je     800b70 <strfind+0x23>
  800b5d:	88 d9                	mov    %bl,%cl
		if (*s == c)
  800b5f:	38 d3                	cmp    %dl,%bl
  800b61:	75 06                	jne    800b69 <strfind+0x1c>
  800b63:	eb 0b                	jmp    800b70 <strfind+0x23>
  800b65:	38 ca                	cmp    %cl,%dl
  800b67:	74 07                	je     800b70 <strfind+0x23>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b69:	40                   	inc    %eax
  800b6a:	8a 10                	mov    (%eax),%dl
  800b6c:	84 d2                	test   %dl,%dl
  800b6e:	75 f5                	jne    800b65 <strfind+0x18>
		if (*s == c)
			break;
	return (char *) s;
}
  800b70:	5b                   	pop    %ebx
  800b71:	5d                   	pop    %ebp
  800b72:	c3                   	ret    

00800b73 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b73:	55                   	push   %ebp
  800b74:	89 e5                	mov    %esp,%ebp
  800b76:	57                   	push   %edi
  800b77:	56                   	push   %esi
  800b78:	53                   	push   %ebx
  800b79:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b7c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b7f:	85 c9                	test   %ecx,%ecx
  800b81:	74 36                	je     800bb9 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b83:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b89:	75 28                	jne    800bb3 <memset+0x40>
  800b8b:	f6 c1 03             	test   $0x3,%cl
  800b8e:	75 23                	jne    800bb3 <memset+0x40>
		c &= 0xFF;
  800b90:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b94:	89 d3                	mov    %edx,%ebx
  800b96:	c1 e3 08             	shl    $0x8,%ebx
  800b99:	89 d6                	mov    %edx,%esi
  800b9b:	c1 e6 18             	shl    $0x18,%esi
  800b9e:	89 d0                	mov    %edx,%eax
  800ba0:	c1 e0 10             	shl    $0x10,%eax
  800ba3:	09 f0                	or     %esi,%eax
  800ba5:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800ba7:	89 d8                	mov    %ebx,%eax
  800ba9:	09 d0                	or     %edx,%eax
  800bab:	c1 e9 02             	shr    $0x2,%ecx
  800bae:	fc                   	cld    
  800baf:	f3 ab                	rep stos %eax,%es:(%edi)
  800bb1:	eb 06                	jmp    800bb9 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bb3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bb6:	fc                   	cld    
  800bb7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bb9:	89 f8                	mov    %edi,%eax
  800bbb:	5b                   	pop    %ebx
  800bbc:	5e                   	pop    %esi
  800bbd:	5f                   	pop    %edi
  800bbe:	5d                   	pop    %ebp
  800bbf:	c3                   	ret    

00800bc0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bc0:	55                   	push   %ebp
  800bc1:	89 e5                	mov    %esp,%ebp
  800bc3:	57                   	push   %edi
  800bc4:	56                   	push   %esi
  800bc5:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bcb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bce:	39 c6                	cmp    %eax,%esi
  800bd0:	73 33                	jae    800c05 <memmove+0x45>
  800bd2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bd5:	39 d0                	cmp    %edx,%eax
  800bd7:	73 2c                	jae    800c05 <memmove+0x45>
		s += n;
		d += n;
  800bd9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bdc:	89 d6                	mov    %edx,%esi
  800bde:	09 fe                	or     %edi,%esi
  800be0:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800be6:	75 13                	jne    800bfb <memmove+0x3b>
  800be8:	f6 c1 03             	test   $0x3,%cl
  800beb:	75 0e                	jne    800bfb <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800bed:	83 ef 04             	sub    $0x4,%edi
  800bf0:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bf3:	c1 e9 02             	shr    $0x2,%ecx
  800bf6:	fd                   	std    
  800bf7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bf9:	eb 07                	jmp    800c02 <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bfb:	4f                   	dec    %edi
  800bfc:	8d 72 ff             	lea    -0x1(%edx),%esi
  800bff:	fd                   	std    
  800c00:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c02:	fc                   	cld    
  800c03:	eb 1d                	jmp    800c22 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c05:	89 f2                	mov    %esi,%edx
  800c07:	09 c2                	or     %eax,%edx
  800c09:	f6 c2 03             	test   $0x3,%dl
  800c0c:	75 0f                	jne    800c1d <memmove+0x5d>
  800c0e:	f6 c1 03             	test   $0x3,%cl
  800c11:	75 0a                	jne    800c1d <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
  800c13:	c1 e9 02             	shr    $0x2,%ecx
  800c16:	89 c7                	mov    %eax,%edi
  800c18:	fc                   	cld    
  800c19:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c1b:	eb 05                	jmp    800c22 <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c1d:	89 c7                	mov    %eax,%edi
  800c1f:	fc                   	cld    
  800c20:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c22:	5e                   	pop    %esi
  800c23:	5f                   	pop    %edi
  800c24:	5d                   	pop    %ebp
  800c25:	c3                   	ret    

00800c26 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c26:	55                   	push   %ebp
  800c27:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c29:	ff 75 10             	pushl  0x10(%ebp)
  800c2c:	ff 75 0c             	pushl  0xc(%ebp)
  800c2f:	ff 75 08             	pushl  0x8(%ebp)
  800c32:	e8 89 ff ff ff       	call   800bc0 <memmove>
}
  800c37:	c9                   	leave  
  800c38:	c3                   	ret    

00800c39 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c39:	55                   	push   %ebp
  800c3a:	89 e5                	mov    %esp,%ebp
  800c3c:	57                   	push   %edi
  800c3d:	56                   	push   %esi
  800c3e:	53                   	push   %ebx
  800c3f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800c42:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c45:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c48:	85 c0                	test   %eax,%eax
  800c4a:	74 33                	je     800c7f <memcmp+0x46>
  800c4c:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800c4f:	8a 13                	mov    (%ebx),%dl
  800c51:	8a 0e                	mov    (%esi),%cl
  800c53:	38 ca                	cmp    %cl,%dl
  800c55:	75 13                	jne    800c6a <memcmp+0x31>
  800c57:	b8 00 00 00 00       	mov    $0x0,%eax
  800c5c:	eb 16                	jmp    800c74 <memcmp+0x3b>
  800c5e:	8a 54 03 01          	mov    0x1(%ebx,%eax,1),%dl
  800c62:	40                   	inc    %eax
  800c63:	8a 0c 06             	mov    (%esi,%eax,1),%cl
  800c66:	38 ca                	cmp    %cl,%dl
  800c68:	74 0a                	je     800c74 <memcmp+0x3b>
			return (int) *s1 - (int) *s2;
  800c6a:	0f b6 c2             	movzbl %dl,%eax
  800c6d:	0f b6 c9             	movzbl %cl,%ecx
  800c70:	29 c8                	sub    %ecx,%eax
  800c72:	eb 10                	jmp    800c84 <memcmp+0x4b>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c74:	39 f8                	cmp    %edi,%eax
  800c76:	75 e6                	jne    800c5e <memcmp+0x25>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c78:	b8 00 00 00 00       	mov    $0x0,%eax
  800c7d:	eb 05                	jmp    800c84 <memcmp+0x4b>
  800c7f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c84:	5b                   	pop    %ebx
  800c85:	5e                   	pop    %esi
  800c86:	5f                   	pop    %edi
  800c87:	5d                   	pop    %ebp
  800c88:	c3                   	ret    

00800c89 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c89:	55                   	push   %ebp
  800c8a:	89 e5                	mov    %esp,%ebp
  800c8c:	53                   	push   %ebx
  800c8d:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800c90:	89 d0                	mov    %edx,%eax
  800c92:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800c95:	39 c2                	cmp    %eax,%edx
  800c97:	73 1b                	jae    800cb4 <memfind+0x2b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c99:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800c9d:	0f b6 0a             	movzbl (%edx),%ecx
  800ca0:	39 d9                	cmp    %ebx,%ecx
  800ca2:	75 09                	jne    800cad <memfind+0x24>
  800ca4:	eb 12                	jmp    800cb8 <memfind+0x2f>
  800ca6:	0f b6 0a             	movzbl (%edx),%ecx
  800ca9:	39 d9                	cmp    %ebx,%ecx
  800cab:	74 0f                	je     800cbc <memfind+0x33>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cad:	42                   	inc    %edx
  800cae:	39 d0                	cmp    %edx,%eax
  800cb0:	75 f4                	jne    800ca6 <memfind+0x1d>
  800cb2:	eb 0a                	jmp    800cbe <memfind+0x35>
  800cb4:	89 d0                	mov    %edx,%eax
  800cb6:	eb 06                	jmp    800cbe <memfind+0x35>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cb8:	89 d0                	mov    %edx,%eax
  800cba:	eb 02                	jmp    800cbe <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cbc:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800cbe:	5b                   	pop    %ebx
  800cbf:	5d                   	pop    %ebp
  800cc0:	c3                   	ret    

00800cc1 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cc1:	55                   	push   %ebp
  800cc2:	89 e5                	mov    %esp,%ebp
  800cc4:	57                   	push   %edi
  800cc5:	56                   	push   %esi
  800cc6:	53                   	push   %ebx
  800cc7:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cca:	eb 01                	jmp    800ccd <strtol+0xc>
		s++;
  800ccc:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ccd:	8a 01                	mov    (%ecx),%al
  800ccf:	3c 20                	cmp    $0x20,%al
  800cd1:	74 f9                	je     800ccc <strtol+0xb>
  800cd3:	3c 09                	cmp    $0x9,%al
  800cd5:	74 f5                	je     800ccc <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  800cd7:	3c 2b                	cmp    $0x2b,%al
  800cd9:	75 08                	jne    800ce3 <strtol+0x22>
		s++;
  800cdb:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cdc:	bf 00 00 00 00       	mov    $0x0,%edi
  800ce1:	eb 11                	jmp    800cf4 <strtol+0x33>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ce3:	3c 2d                	cmp    $0x2d,%al
  800ce5:	75 08                	jne    800cef <strtol+0x2e>
		s++, neg = 1;
  800ce7:	41                   	inc    %ecx
  800ce8:	bf 01 00 00 00       	mov    $0x1,%edi
  800ced:	eb 05                	jmp    800cf4 <strtol+0x33>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cef:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cf4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800cf8:	0f 84 87 00 00 00    	je     800d85 <strtol+0xc4>
  800cfe:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800d02:	75 27                	jne    800d2b <strtol+0x6a>
  800d04:	80 39 30             	cmpb   $0x30,(%ecx)
  800d07:	75 22                	jne    800d2b <strtol+0x6a>
  800d09:	e9 88 00 00 00       	jmp    800d96 <strtol+0xd5>
		s += 2, base = 16;
  800d0e:	83 c1 02             	add    $0x2,%ecx
  800d11:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800d18:	eb 11                	jmp    800d2b <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
  800d1a:	41                   	inc    %ecx
  800d1b:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800d22:	eb 07                	jmp    800d2b <strtol+0x6a>
	else if (base == 0)
		base = 10;
  800d24:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  800d2b:	b8 00 00 00 00       	mov    $0x0,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d30:	8a 11                	mov    (%ecx),%dl
  800d32:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800d35:	80 fb 09             	cmp    $0x9,%bl
  800d38:	77 08                	ja     800d42 <strtol+0x81>
			dig = *s - '0';
  800d3a:	0f be d2             	movsbl %dl,%edx
  800d3d:	83 ea 30             	sub    $0x30,%edx
  800d40:	eb 22                	jmp    800d64 <strtol+0xa3>
		else if (*s >= 'a' && *s <= 'z')
  800d42:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d45:	89 f3                	mov    %esi,%ebx
  800d47:	80 fb 19             	cmp    $0x19,%bl
  800d4a:	77 08                	ja     800d54 <strtol+0x93>
			dig = *s - 'a' + 10;
  800d4c:	0f be d2             	movsbl %dl,%edx
  800d4f:	83 ea 57             	sub    $0x57,%edx
  800d52:	eb 10                	jmp    800d64 <strtol+0xa3>
		else if (*s >= 'A' && *s <= 'Z')
  800d54:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d57:	89 f3                	mov    %esi,%ebx
  800d59:	80 fb 19             	cmp    $0x19,%bl
  800d5c:	77 14                	ja     800d72 <strtol+0xb1>
			dig = *s - 'A' + 10;
  800d5e:	0f be d2             	movsbl %dl,%edx
  800d61:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800d64:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d67:	7d 09                	jge    800d72 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800d69:	41                   	inc    %ecx
  800d6a:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d6e:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800d70:	eb be                	jmp    800d30 <strtol+0x6f>

	if (endptr)
  800d72:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d76:	74 05                	je     800d7d <strtol+0xbc>
		*endptr = (char *) s;
  800d78:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d7b:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800d7d:	85 ff                	test   %edi,%edi
  800d7f:	74 21                	je     800da2 <strtol+0xe1>
  800d81:	f7 d8                	neg    %eax
  800d83:	eb 1d                	jmp    800da2 <strtol+0xe1>
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d85:	80 39 30             	cmpb   $0x30,(%ecx)
  800d88:	75 9a                	jne    800d24 <strtol+0x63>
  800d8a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d8e:	0f 84 7a ff ff ff    	je     800d0e <strtol+0x4d>
  800d94:	eb 84                	jmp    800d1a <strtol+0x59>
  800d96:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d9a:	0f 84 6e ff ff ff    	je     800d0e <strtol+0x4d>
  800da0:	eb 89                	jmp    800d2b <strtol+0x6a>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  800da2:	5b                   	pop    %ebx
  800da3:	5e                   	pop    %esi
  800da4:	5f                   	pop    %edi
  800da5:	5d                   	pop    %ebp
  800da6:	c3                   	ret    

00800da7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800da7:	55                   	push   %ebp
  800da8:	89 e5                	mov    %esp,%ebp
  800daa:	57                   	push   %edi
  800dab:	56                   	push   %esi
  800dac:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dad:	b8 00 00 00 00       	mov    $0x0,%eax
  800db2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db5:	8b 55 08             	mov    0x8(%ebp),%edx
  800db8:	89 c3                	mov    %eax,%ebx
  800dba:	89 c7                	mov    %eax,%edi
  800dbc:	89 c6                	mov    %eax,%esi
  800dbe:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800dc0:	5b                   	pop    %ebx
  800dc1:	5e                   	pop    %esi
  800dc2:	5f                   	pop    %edi
  800dc3:	5d                   	pop    %ebp
  800dc4:	c3                   	ret    

00800dc5 <sys_cgetc>:

int
sys_cgetc(void)
{
  800dc5:	55                   	push   %ebp
  800dc6:	89 e5                	mov    %esp,%ebp
  800dc8:	57                   	push   %edi
  800dc9:	56                   	push   %esi
  800dca:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcb:	ba 00 00 00 00       	mov    $0x0,%edx
  800dd0:	b8 01 00 00 00       	mov    $0x1,%eax
  800dd5:	89 d1                	mov    %edx,%ecx
  800dd7:	89 d3                	mov    %edx,%ebx
  800dd9:	89 d7                	mov    %edx,%edi
  800ddb:	89 d6                	mov    %edx,%esi
  800ddd:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ddf:	5b                   	pop    %ebx
  800de0:	5e                   	pop    %esi
  800de1:	5f                   	pop    %edi
  800de2:	5d                   	pop    %ebp
  800de3:	c3                   	ret    

00800de4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800de4:	55                   	push   %ebp
  800de5:	89 e5                	mov    %esp,%ebp
  800de7:	57                   	push   %edi
  800de8:	56                   	push   %esi
  800de9:	53                   	push   %ebx
  800dea:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ded:	b9 00 00 00 00       	mov    $0x0,%ecx
  800df2:	b8 03 00 00 00       	mov    $0x3,%eax
  800df7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfa:	89 cb                	mov    %ecx,%ebx
  800dfc:	89 cf                	mov    %ecx,%edi
  800dfe:	89 ce                	mov    %ecx,%esi
  800e00:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e02:	85 c0                	test   %eax,%eax
  800e04:	7e 17                	jle    800e1d <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e06:	83 ec 0c             	sub    $0xc,%esp
  800e09:	50                   	push   %eax
  800e0a:	6a 03                	push   $0x3
  800e0c:	68 ff 26 80 00       	push   $0x8026ff
  800e11:	6a 23                	push   $0x23
  800e13:	68 1c 27 80 00       	push   $0x80271c
  800e18:	e8 19 f5 ff ff       	call   800336 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e20:	5b                   	pop    %ebx
  800e21:	5e                   	pop    %esi
  800e22:	5f                   	pop    %edi
  800e23:	5d                   	pop    %ebp
  800e24:	c3                   	ret    

00800e25 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e25:	55                   	push   %ebp
  800e26:	89 e5                	mov    %esp,%ebp
  800e28:	57                   	push   %edi
  800e29:	56                   	push   %esi
  800e2a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2b:	ba 00 00 00 00       	mov    $0x0,%edx
  800e30:	b8 02 00 00 00       	mov    $0x2,%eax
  800e35:	89 d1                	mov    %edx,%ecx
  800e37:	89 d3                	mov    %edx,%ebx
  800e39:	89 d7                	mov    %edx,%edi
  800e3b:	89 d6                	mov    %edx,%esi
  800e3d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e3f:	5b                   	pop    %ebx
  800e40:	5e                   	pop    %esi
  800e41:	5f                   	pop    %edi
  800e42:	5d                   	pop    %ebp
  800e43:	c3                   	ret    

00800e44 <sys_yield>:

void
sys_yield(void)
{
  800e44:	55                   	push   %ebp
  800e45:	89 e5                	mov    %esp,%ebp
  800e47:	57                   	push   %edi
  800e48:	56                   	push   %esi
  800e49:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4a:	ba 00 00 00 00       	mov    $0x0,%edx
  800e4f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e54:	89 d1                	mov    %edx,%ecx
  800e56:	89 d3                	mov    %edx,%ebx
  800e58:	89 d7                	mov    %edx,%edi
  800e5a:	89 d6                	mov    %edx,%esi
  800e5c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e5e:	5b                   	pop    %ebx
  800e5f:	5e                   	pop    %esi
  800e60:	5f                   	pop    %edi
  800e61:	5d                   	pop    %ebp
  800e62:	c3                   	ret    

00800e63 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e63:	55                   	push   %ebp
  800e64:	89 e5                	mov    %esp,%ebp
  800e66:	57                   	push   %edi
  800e67:	56                   	push   %esi
  800e68:	53                   	push   %ebx
  800e69:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e6c:	be 00 00 00 00       	mov    $0x0,%esi
  800e71:	b8 04 00 00 00       	mov    $0x4,%eax
  800e76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e79:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e7f:	89 f7                	mov    %esi,%edi
  800e81:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e83:	85 c0                	test   %eax,%eax
  800e85:	7e 17                	jle    800e9e <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e87:	83 ec 0c             	sub    $0xc,%esp
  800e8a:	50                   	push   %eax
  800e8b:	6a 04                	push   $0x4
  800e8d:	68 ff 26 80 00       	push   $0x8026ff
  800e92:	6a 23                	push   $0x23
  800e94:	68 1c 27 80 00       	push   $0x80271c
  800e99:	e8 98 f4 ff ff       	call   800336 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ea1:	5b                   	pop    %ebx
  800ea2:	5e                   	pop    %esi
  800ea3:	5f                   	pop    %edi
  800ea4:	5d                   	pop    %ebp
  800ea5:	c3                   	ret    

00800ea6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ea6:	55                   	push   %ebp
  800ea7:	89 e5                	mov    %esp,%ebp
  800ea9:	57                   	push   %edi
  800eaa:	56                   	push   %esi
  800eab:	53                   	push   %ebx
  800eac:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eaf:	b8 05 00 00 00       	mov    $0x5,%eax
  800eb4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb7:	8b 55 08             	mov    0x8(%ebp),%edx
  800eba:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ebd:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ec0:	8b 75 18             	mov    0x18(%ebp),%esi
  800ec3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ec5:	85 c0                	test   %eax,%eax
  800ec7:	7e 17                	jle    800ee0 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec9:	83 ec 0c             	sub    $0xc,%esp
  800ecc:	50                   	push   %eax
  800ecd:	6a 05                	push   $0x5
  800ecf:	68 ff 26 80 00       	push   $0x8026ff
  800ed4:	6a 23                	push   $0x23
  800ed6:	68 1c 27 80 00       	push   $0x80271c
  800edb:	e8 56 f4 ff ff       	call   800336 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ee0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ee3:	5b                   	pop    %ebx
  800ee4:	5e                   	pop    %esi
  800ee5:	5f                   	pop    %edi
  800ee6:	5d                   	pop    %ebp
  800ee7:	c3                   	ret    

00800ee8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ee8:	55                   	push   %ebp
  800ee9:	89 e5                	mov    %esp,%ebp
  800eeb:	57                   	push   %edi
  800eec:	56                   	push   %esi
  800eed:	53                   	push   %ebx
  800eee:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ef1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ef6:	b8 06 00 00 00       	mov    $0x6,%eax
  800efb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800efe:	8b 55 08             	mov    0x8(%ebp),%edx
  800f01:	89 df                	mov    %ebx,%edi
  800f03:	89 de                	mov    %ebx,%esi
  800f05:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f07:	85 c0                	test   %eax,%eax
  800f09:	7e 17                	jle    800f22 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f0b:	83 ec 0c             	sub    $0xc,%esp
  800f0e:	50                   	push   %eax
  800f0f:	6a 06                	push   $0x6
  800f11:	68 ff 26 80 00       	push   $0x8026ff
  800f16:	6a 23                	push   $0x23
  800f18:	68 1c 27 80 00       	push   $0x80271c
  800f1d:	e8 14 f4 ff ff       	call   800336 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f25:	5b                   	pop    %ebx
  800f26:	5e                   	pop    %esi
  800f27:	5f                   	pop    %edi
  800f28:	5d                   	pop    %ebp
  800f29:	c3                   	ret    

00800f2a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f2a:	55                   	push   %ebp
  800f2b:	89 e5                	mov    %esp,%ebp
  800f2d:	57                   	push   %edi
  800f2e:	56                   	push   %esi
  800f2f:	53                   	push   %ebx
  800f30:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f33:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f38:	b8 08 00 00 00       	mov    $0x8,%eax
  800f3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f40:	8b 55 08             	mov    0x8(%ebp),%edx
  800f43:	89 df                	mov    %ebx,%edi
  800f45:	89 de                	mov    %ebx,%esi
  800f47:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f49:	85 c0                	test   %eax,%eax
  800f4b:	7e 17                	jle    800f64 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f4d:	83 ec 0c             	sub    $0xc,%esp
  800f50:	50                   	push   %eax
  800f51:	6a 08                	push   $0x8
  800f53:	68 ff 26 80 00       	push   $0x8026ff
  800f58:	6a 23                	push   $0x23
  800f5a:	68 1c 27 80 00       	push   $0x80271c
  800f5f:	e8 d2 f3 ff ff       	call   800336 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f64:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f67:	5b                   	pop    %ebx
  800f68:	5e                   	pop    %esi
  800f69:	5f                   	pop    %edi
  800f6a:	5d                   	pop    %ebp
  800f6b:	c3                   	ret    

00800f6c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f6c:	55                   	push   %ebp
  800f6d:	89 e5                	mov    %esp,%ebp
  800f6f:	57                   	push   %edi
  800f70:	56                   	push   %esi
  800f71:	53                   	push   %ebx
  800f72:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f75:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f7a:	b8 09 00 00 00       	mov    $0x9,%eax
  800f7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f82:	8b 55 08             	mov    0x8(%ebp),%edx
  800f85:	89 df                	mov    %ebx,%edi
  800f87:	89 de                	mov    %ebx,%esi
  800f89:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f8b:	85 c0                	test   %eax,%eax
  800f8d:	7e 17                	jle    800fa6 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f8f:	83 ec 0c             	sub    $0xc,%esp
  800f92:	50                   	push   %eax
  800f93:	6a 09                	push   $0x9
  800f95:	68 ff 26 80 00       	push   $0x8026ff
  800f9a:	6a 23                	push   $0x23
  800f9c:	68 1c 27 80 00       	push   $0x80271c
  800fa1:	e8 90 f3 ff ff       	call   800336 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800fa6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fa9:	5b                   	pop    %ebx
  800faa:	5e                   	pop    %esi
  800fab:	5f                   	pop    %edi
  800fac:	5d                   	pop    %ebp
  800fad:	c3                   	ret    

00800fae <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800fae:	55                   	push   %ebp
  800faf:	89 e5                	mov    %esp,%ebp
  800fb1:	57                   	push   %edi
  800fb2:	56                   	push   %esi
  800fb3:	53                   	push   %ebx
  800fb4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fb7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fbc:	b8 0a 00 00 00       	mov    $0xa,%eax
  800fc1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc7:	89 df                	mov    %ebx,%edi
  800fc9:	89 de                	mov    %ebx,%esi
  800fcb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fcd:	85 c0                	test   %eax,%eax
  800fcf:	7e 17                	jle    800fe8 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fd1:	83 ec 0c             	sub    $0xc,%esp
  800fd4:	50                   	push   %eax
  800fd5:	6a 0a                	push   $0xa
  800fd7:	68 ff 26 80 00       	push   $0x8026ff
  800fdc:	6a 23                	push   $0x23
  800fde:	68 1c 27 80 00       	push   $0x80271c
  800fe3:	e8 4e f3 ff ff       	call   800336 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800fe8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800feb:	5b                   	pop    %ebx
  800fec:	5e                   	pop    %esi
  800fed:	5f                   	pop    %edi
  800fee:	5d                   	pop    %ebp
  800fef:	c3                   	ret    

00800ff0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ff0:	55                   	push   %ebp
  800ff1:	89 e5                	mov    %esp,%ebp
  800ff3:	57                   	push   %edi
  800ff4:	56                   	push   %esi
  800ff5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ff6:	be 00 00 00 00       	mov    $0x0,%esi
  800ffb:	b8 0c 00 00 00       	mov    $0xc,%eax
  801000:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801003:	8b 55 08             	mov    0x8(%ebp),%edx
  801006:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801009:	8b 7d 14             	mov    0x14(%ebp),%edi
  80100c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80100e:	5b                   	pop    %ebx
  80100f:	5e                   	pop    %esi
  801010:	5f                   	pop    %edi
  801011:	5d                   	pop    %ebp
  801012:	c3                   	ret    

00801013 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801013:	55                   	push   %ebp
  801014:	89 e5                	mov    %esp,%ebp
  801016:	57                   	push   %edi
  801017:	56                   	push   %esi
  801018:	53                   	push   %ebx
  801019:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80101c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801021:	b8 0d 00 00 00       	mov    $0xd,%eax
  801026:	8b 55 08             	mov    0x8(%ebp),%edx
  801029:	89 cb                	mov    %ecx,%ebx
  80102b:	89 cf                	mov    %ecx,%edi
  80102d:	89 ce                	mov    %ecx,%esi
  80102f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801031:	85 c0                	test   %eax,%eax
  801033:	7e 17                	jle    80104c <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801035:	83 ec 0c             	sub    $0xc,%esp
  801038:	50                   	push   %eax
  801039:	6a 0d                	push   $0xd
  80103b:	68 ff 26 80 00       	push   $0x8026ff
  801040:	6a 23                	push   $0x23
  801042:	68 1c 27 80 00       	push   $0x80271c
  801047:	e8 ea f2 ff ff       	call   800336 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80104c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80104f:	5b                   	pop    %ebx
  801050:	5e                   	pop    %esi
  801051:	5f                   	pop    %edi
  801052:	5d                   	pop    %ebp
  801053:	c3                   	ret    

00801054 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  801054:	55                   	push   %ebp
  801055:	89 e5                	mov    %esp,%ebp
  801057:	8b 55 08             	mov    0x8(%ebp),%edx
  80105a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80105d:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801060:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  801062:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  801065:	83 3a 01             	cmpl   $0x1,(%edx)
  801068:	7e 0b                	jle    801075 <argstart+0x21>
  80106a:	85 c9                	test   %ecx,%ecx
  80106c:	74 0e                	je     80107c <argstart+0x28>
  80106e:	ba a8 23 80 00       	mov    $0x8023a8,%edx
  801073:	eb 0c                	jmp    801081 <argstart+0x2d>
  801075:	ba 00 00 00 00       	mov    $0x0,%edx
  80107a:	eb 05                	jmp    801081 <argstart+0x2d>
  80107c:	ba 00 00 00 00       	mov    $0x0,%edx
  801081:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  801084:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  80108b:	5d                   	pop    %ebp
  80108c:	c3                   	ret    

0080108d <argnext>:

int
argnext(struct Argstate *args)
{
  80108d:	55                   	push   %ebp
  80108e:	89 e5                	mov    %esp,%ebp
  801090:	53                   	push   %ebx
  801091:	83 ec 04             	sub    $0x4,%esp
  801094:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801097:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  80109e:	8b 43 08             	mov    0x8(%ebx),%eax
  8010a1:	85 c0                	test   %eax,%eax
  8010a3:	74 6a                	je     80110f <argnext+0x82>
		return -1;

	if (!*args->curarg) {
  8010a5:	80 38 00             	cmpb   $0x0,(%eax)
  8010a8:	75 4b                	jne    8010f5 <argnext+0x68>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  8010aa:	8b 0b                	mov    (%ebx),%ecx
  8010ac:	83 39 01             	cmpl   $0x1,(%ecx)
  8010af:	74 50                	je     801101 <argnext+0x74>
		    || args->argv[1][0] != '-'
  8010b1:	8b 53 04             	mov    0x4(%ebx),%edx
  8010b4:	8b 42 04             	mov    0x4(%edx),%eax
  8010b7:	80 38 2d             	cmpb   $0x2d,(%eax)
  8010ba:	75 45                	jne    801101 <argnext+0x74>
		    || args->argv[1][1] == '\0')
  8010bc:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  8010c0:	74 3f                	je     801101 <argnext+0x74>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  8010c2:	40                   	inc    %eax
  8010c3:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  8010c6:	83 ec 04             	sub    $0x4,%esp
  8010c9:	8b 01                	mov    (%ecx),%eax
  8010cb:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  8010d2:	50                   	push   %eax
  8010d3:	8d 42 08             	lea    0x8(%edx),%eax
  8010d6:	50                   	push   %eax
  8010d7:	83 c2 04             	add    $0x4,%edx
  8010da:	52                   	push   %edx
  8010db:	e8 e0 fa ff ff       	call   800bc0 <memmove>
		(*args->argc)--;
  8010e0:	8b 03                	mov    (%ebx),%eax
  8010e2:	ff 08                	decl   (%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  8010e4:	8b 43 08             	mov    0x8(%ebx),%eax
  8010e7:	83 c4 10             	add    $0x10,%esp
  8010ea:	80 38 2d             	cmpb   $0x2d,(%eax)
  8010ed:	75 06                	jne    8010f5 <argnext+0x68>
  8010ef:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  8010f3:	74 0c                	je     801101 <argnext+0x74>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  8010f5:	8b 53 08             	mov    0x8(%ebx),%edx
  8010f8:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  8010fb:	42                   	inc    %edx
  8010fc:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  8010ff:	eb 13                	jmp    801114 <argnext+0x87>

    endofargs:
	args->curarg = 0;
  801101:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  801108:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80110d:	eb 05                	jmp    801114 <argnext+0x87>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  80110f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801114:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801117:	c9                   	leave  
  801118:	c3                   	ret    

00801119 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801119:	55                   	push   %ebp
  80111a:	89 e5                	mov    %esp,%ebp
  80111c:	53                   	push   %ebx
  80111d:	83 ec 04             	sub    $0x4,%esp
  801120:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801123:	8b 43 08             	mov    0x8(%ebx),%eax
  801126:	85 c0                	test   %eax,%eax
  801128:	74 57                	je     801181 <argnextvalue+0x68>
		return 0;
	if (*args->curarg) {
  80112a:	80 38 00             	cmpb   $0x0,(%eax)
  80112d:	74 0c                	je     80113b <argnextvalue+0x22>
		args->argvalue = args->curarg;
  80112f:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801132:	c7 43 08 a8 23 80 00 	movl   $0x8023a8,0x8(%ebx)
  801139:	eb 41                	jmp    80117c <argnextvalue+0x63>
	} else if (*args->argc > 1) {
  80113b:	8b 13                	mov    (%ebx),%edx
  80113d:	83 3a 01             	cmpl   $0x1,(%edx)
  801140:	7e 2c                	jle    80116e <argnextvalue+0x55>
		args->argvalue = args->argv[1];
  801142:	8b 43 04             	mov    0x4(%ebx),%eax
  801145:	8b 48 04             	mov    0x4(%eax),%ecx
  801148:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  80114b:	83 ec 04             	sub    $0x4,%esp
  80114e:	8b 12                	mov    (%edx),%edx
  801150:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  801157:	52                   	push   %edx
  801158:	8d 50 08             	lea    0x8(%eax),%edx
  80115b:	52                   	push   %edx
  80115c:	83 c0 04             	add    $0x4,%eax
  80115f:	50                   	push   %eax
  801160:	e8 5b fa ff ff       	call   800bc0 <memmove>
		(*args->argc)--;
  801165:	8b 03                	mov    (%ebx),%eax
  801167:	ff 08                	decl   (%eax)
  801169:	83 c4 10             	add    $0x10,%esp
  80116c:	eb 0e                	jmp    80117c <argnextvalue+0x63>
	} else {
		args->argvalue = 0;
  80116e:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801175:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  80117c:	8b 43 0c             	mov    0xc(%ebx),%eax
  80117f:	eb 05                	jmp    801186 <argnextvalue+0x6d>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  801181:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  801186:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801189:	c9                   	leave  
  80118a:	c3                   	ret    

0080118b <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  80118b:	55                   	push   %ebp
  80118c:	89 e5                	mov    %esp,%ebp
  80118e:	83 ec 08             	sub    $0x8,%esp
  801191:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801194:	8b 51 0c             	mov    0xc(%ecx),%edx
  801197:	89 d0                	mov    %edx,%eax
  801199:	85 d2                	test   %edx,%edx
  80119b:	75 0c                	jne    8011a9 <argvalue+0x1e>
  80119d:	83 ec 0c             	sub    $0xc,%esp
  8011a0:	51                   	push   %ecx
  8011a1:	e8 73 ff ff ff       	call   801119 <argnextvalue>
  8011a6:	83 c4 10             	add    $0x10,%esp
}
  8011a9:	c9                   	leave  
  8011aa:	c3                   	ret    

008011ab <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011ab:	55                   	push   %ebp
  8011ac:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b1:	05 00 00 00 30       	add    $0x30000000,%eax
  8011b6:	c1 e8 0c             	shr    $0xc,%eax
}
  8011b9:	5d                   	pop    %ebp
  8011ba:	c3                   	ret    

008011bb <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011bb:	55                   	push   %ebp
  8011bc:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011be:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c1:	05 00 00 00 30       	add    $0x30000000,%eax
  8011c6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011cb:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011d0:	5d                   	pop    %ebp
  8011d1:	c3                   	ret    

008011d2 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011d2:	55                   	push   %ebp
  8011d3:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011d5:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8011da:	a8 01                	test   $0x1,%al
  8011dc:	74 34                	je     801212 <fd_alloc+0x40>
  8011de:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8011e3:	a8 01                	test   $0x1,%al
  8011e5:	74 32                	je     801219 <fd_alloc+0x47>
  8011e7:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8011ec:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011ee:	89 c2                	mov    %eax,%edx
  8011f0:	c1 ea 16             	shr    $0x16,%edx
  8011f3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011fa:	f6 c2 01             	test   $0x1,%dl
  8011fd:	74 1f                	je     80121e <fd_alloc+0x4c>
  8011ff:	89 c2                	mov    %eax,%edx
  801201:	c1 ea 0c             	shr    $0xc,%edx
  801204:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80120b:	f6 c2 01             	test   $0x1,%dl
  80120e:	75 1a                	jne    80122a <fd_alloc+0x58>
  801210:	eb 0c                	jmp    80121e <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801212:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801217:	eb 05                	jmp    80121e <fd_alloc+0x4c>
  801219:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  80121e:	8b 45 08             	mov    0x8(%ebp),%eax
  801221:	89 08                	mov    %ecx,(%eax)
			return 0;
  801223:	b8 00 00 00 00       	mov    $0x0,%eax
  801228:	eb 1a                	jmp    801244 <fd_alloc+0x72>
  80122a:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80122f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801234:	75 b6                	jne    8011ec <fd_alloc+0x1a>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801236:	8b 45 08             	mov    0x8(%ebp),%eax
  801239:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  80123f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801244:	5d                   	pop    %ebp
  801245:	c3                   	ret    

00801246 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801246:	55                   	push   %ebp
  801247:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801249:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  80124d:	77 39                	ja     801288 <fd_lookup+0x42>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80124f:	8b 45 08             	mov    0x8(%ebp),%eax
  801252:	c1 e0 0c             	shl    $0xc,%eax
  801255:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80125a:	89 c2                	mov    %eax,%edx
  80125c:	c1 ea 16             	shr    $0x16,%edx
  80125f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801266:	f6 c2 01             	test   $0x1,%dl
  801269:	74 24                	je     80128f <fd_lookup+0x49>
  80126b:	89 c2                	mov    %eax,%edx
  80126d:	c1 ea 0c             	shr    $0xc,%edx
  801270:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801277:	f6 c2 01             	test   $0x1,%dl
  80127a:	74 1a                	je     801296 <fd_lookup+0x50>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80127c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80127f:	89 02                	mov    %eax,(%edx)
	return 0;
  801281:	b8 00 00 00 00       	mov    $0x0,%eax
  801286:	eb 13                	jmp    80129b <fd_lookup+0x55>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801288:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80128d:	eb 0c                	jmp    80129b <fd_lookup+0x55>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80128f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801294:	eb 05                	jmp    80129b <fd_lookup+0x55>
  801296:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80129b:	5d                   	pop    %ebp
  80129c:	c3                   	ret    

0080129d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80129d:	55                   	push   %ebp
  80129e:	89 e5                	mov    %esp,%ebp
  8012a0:	53                   	push   %ebx
  8012a1:	83 ec 04             	sub    $0x4,%esp
  8012a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8012a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8012aa:	3b 05 04 30 80 00    	cmp    0x803004,%eax
  8012b0:	75 1e                	jne    8012d0 <dev_lookup+0x33>
  8012b2:	eb 0e                	jmp    8012c2 <dev_lookup+0x25>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012b4:	b8 20 30 80 00       	mov    $0x803020,%eax
  8012b9:	eb 0c                	jmp    8012c7 <dev_lookup+0x2a>
  8012bb:	b8 3c 30 80 00       	mov    $0x80303c,%eax
  8012c0:	eb 05                	jmp    8012c7 <dev_lookup+0x2a>
  8012c2:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  8012c7:	89 03                	mov    %eax,(%ebx)
			return 0;
  8012c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8012ce:	eb 36                	jmp    801306 <dev_lookup+0x69>
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8012d0:	3b 05 20 30 80 00    	cmp    0x803020,%eax
  8012d6:	74 dc                	je     8012b4 <dev_lookup+0x17>
  8012d8:	3b 05 3c 30 80 00    	cmp    0x80303c,%eax
  8012de:	74 db                	je     8012bb <dev_lookup+0x1e>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012e0:	8b 15 20 44 80 00    	mov    0x804420,%edx
  8012e6:	8b 52 48             	mov    0x48(%edx),%edx
  8012e9:	83 ec 04             	sub    $0x4,%esp
  8012ec:	50                   	push   %eax
  8012ed:	52                   	push   %edx
  8012ee:	68 2c 27 80 00       	push   $0x80272c
  8012f3:	e8 16 f1 ff ff       	call   80040e <cprintf>
	*dev = 0;
  8012f8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8012fe:	83 c4 10             	add    $0x10,%esp
  801301:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801306:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801309:	c9                   	leave  
  80130a:	c3                   	ret    

0080130b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80130b:	55                   	push   %ebp
  80130c:	89 e5                	mov    %esp,%ebp
  80130e:	56                   	push   %esi
  80130f:	53                   	push   %ebx
  801310:	83 ec 10             	sub    $0x10,%esp
  801313:	8b 75 08             	mov    0x8(%ebp),%esi
  801316:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801319:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80131c:	50                   	push   %eax
  80131d:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801323:	c1 e8 0c             	shr    $0xc,%eax
  801326:	50                   	push   %eax
  801327:	e8 1a ff ff ff       	call   801246 <fd_lookup>
  80132c:	83 c4 08             	add    $0x8,%esp
  80132f:	85 c0                	test   %eax,%eax
  801331:	78 05                	js     801338 <fd_close+0x2d>
	    || fd != fd2)
  801333:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801336:	74 06                	je     80133e <fd_close+0x33>
		return (must_exist ? r : 0);
  801338:	84 db                	test   %bl,%bl
  80133a:	74 47                	je     801383 <fd_close+0x78>
  80133c:	eb 4a                	jmp    801388 <fd_close+0x7d>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80133e:	83 ec 08             	sub    $0x8,%esp
  801341:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801344:	50                   	push   %eax
  801345:	ff 36                	pushl  (%esi)
  801347:	e8 51 ff ff ff       	call   80129d <dev_lookup>
  80134c:	89 c3                	mov    %eax,%ebx
  80134e:	83 c4 10             	add    $0x10,%esp
  801351:	85 c0                	test   %eax,%eax
  801353:	78 1c                	js     801371 <fd_close+0x66>
		if (dev->dev_close)
  801355:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801358:	8b 40 10             	mov    0x10(%eax),%eax
  80135b:	85 c0                	test   %eax,%eax
  80135d:	74 0d                	je     80136c <fd_close+0x61>
			r = (*dev->dev_close)(fd);
  80135f:	83 ec 0c             	sub    $0xc,%esp
  801362:	56                   	push   %esi
  801363:	ff d0                	call   *%eax
  801365:	89 c3                	mov    %eax,%ebx
  801367:	83 c4 10             	add    $0x10,%esp
  80136a:	eb 05                	jmp    801371 <fd_close+0x66>
		else
			r = 0;
  80136c:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801371:	83 ec 08             	sub    $0x8,%esp
  801374:	56                   	push   %esi
  801375:	6a 00                	push   $0x0
  801377:	e8 6c fb ff ff       	call   800ee8 <sys_page_unmap>
	return r;
  80137c:	83 c4 10             	add    $0x10,%esp
  80137f:	89 d8                	mov    %ebx,%eax
  801381:	eb 05                	jmp    801388 <fd_close+0x7d>
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
  801383:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
	return r;
}
  801388:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80138b:	5b                   	pop    %ebx
  80138c:	5e                   	pop    %esi
  80138d:	5d                   	pop    %ebp
  80138e:	c3                   	ret    

0080138f <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80138f:	55                   	push   %ebp
  801390:	89 e5                	mov    %esp,%ebp
  801392:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801395:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801398:	50                   	push   %eax
  801399:	ff 75 08             	pushl  0x8(%ebp)
  80139c:	e8 a5 fe ff ff       	call   801246 <fd_lookup>
  8013a1:	83 c4 08             	add    $0x8,%esp
  8013a4:	85 c0                	test   %eax,%eax
  8013a6:	78 10                	js     8013b8 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8013a8:	83 ec 08             	sub    $0x8,%esp
  8013ab:	6a 01                	push   $0x1
  8013ad:	ff 75 f4             	pushl  -0xc(%ebp)
  8013b0:	e8 56 ff ff ff       	call   80130b <fd_close>
  8013b5:	83 c4 10             	add    $0x10,%esp
}
  8013b8:	c9                   	leave  
  8013b9:	c3                   	ret    

008013ba <close_all>:

void
close_all(void)
{
  8013ba:	55                   	push   %ebp
  8013bb:	89 e5                	mov    %esp,%ebp
  8013bd:	53                   	push   %ebx
  8013be:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013c1:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013c6:	83 ec 0c             	sub    $0xc,%esp
  8013c9:	53                   	push   %ebx
  8013ca:	e8 c0 ff ff ff       	call   80138f <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013cf:	43                   	inc    %ebx
  8013d0:	83 c4 10             	add    $0x10,%esp
  8013d3:	83 fb 20             	cmp    $0x20,%ebx
  8013d6:	75 ee                	jne    8013c6 <close_all+0xc>
		close(i);
}
  8013d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013db:	c9                   	leave  
  8013dc:	c3                   	ret    

008013dd <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013dd:	55                   	push   %ebp
  8013de:	89 e5                	mov    %esp,%ebp
  8013e0:	57                   	push   %edi
  8013e1:	56                   	push   %esi
  8013e2:	53                   	push   %ebx
  8013e3:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013e6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013e9:	50                   	push   %eax
  8013ea:	ff 75 08             	pushl  0x8(%ebp)
  8013ed:	e8 54 fe ff ff       	call   801246 <fd_lookup>
  8013f2:	83 c4 08             	add    $0x8,%esp
  8013f5:	85 c0                	test   %eax,%eax
  8013f7:	0f 88 c2 00 00 00    	js     8014bf <dup+0xe2>
		return r;
	close(newfdnum);
  8013fd:	83 ec 0c             	sub    $0xc,%esp
  801400:	ff 75 0c             	pushl  0xc(%ebp)
  801403:	e8 87 ff ff ff       	call   80138f <close>

	newfd = INDEX2FD(newfdnum);
  801408:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80140b:	c1 e3 0c             	shl    $0xc,%ebx
  80140e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801414:	83 c4 04             	add    $0x4,%esp
  801417:	ff 75 e4             	pushl  -0x1c(%ebp)
  80141a:	e8 9c fd ff ff       	call   8011bb <fd2data>
  80141f:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801421:	89 1c 24             	mov    %ebx,(%esp)
  801424:	e8 92 fd ff ff       	call   8011bb <fd2data>
  801429:	83 c4 10             	add    $0x10,%esp
  80142c:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80142e:	89 f0                	mov    %esi,%eax
  801430:	c1 e8 16             	shr    $0x16,%eax
  801433:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80143a:	a8 01                	test   $0x1,%al
  80143c:	74 35                	je     801473 <dup+0x96>
  80143e:	89 f0                	mov    %esi,%eax
  801440:	c1 e8 0c             	shr    $0xc,%eax
  801443:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80144a:	f6 c2 01             	test   $0x1,%dl
  80144d:	74 24                	je     801473 <dup+0x96>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80144f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801456:	83 ec 0c             	sub    $0xc,%esp
  801459:	25 07 0e 00 00       	and    $0xe07,%eax
  80145e:	50                   	push   %eax
  80145f:	57                   	push   %edi
  801460:	6a 00                	push   $0x0
  801462:	56                   	push   %esi
  801463:	6a 00                	push   $0x0
  801465:	e8 3c fa ff ff       	call   800ea6 <sys_page_map>
  80146a:	89 c6                	mov    %eax,%esi
  80146c:	83 c4 20             	add    $0x20,%esp
  80146f:	85 c0                	test   %eax,%eax
  801471:	78 2c                	js     80149f <dup+0xc2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801473:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801476:	89 d0                	mov    %edx,%eax
  801478:	c1 e8 0c             	shr    $0xc,%eax
  80147b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801482:	83 ec 0c             	sub    $0xc,%esp
  801485:	25 07 0e 00 00       	and    $0xe07,%eax
  80148a:	50                   	push   %eax
  80148b:	53                   	push   %ebx
  80148c:	6a 00                	push   $0x0
  80148e:	52                   	push   %edx
  80148f:	6a 00                	push   $0x0
  801491:	e8 10 fa ff ff       	call   800ea6 <sys_page_map>
  801496:	89 c6                	mov    %eax,%esi
  801498:	83 c4 20             	add    $0x20,%esp
  80149b:	85 c0                	test   %eax,%eax
  80149d:	79 1d                	jns    8014bc <dup+0xdf>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80149f:	83 ec 08             	sub    $0x8,%esp
  8014a2:	53                   	push   %ebx
  8014a3:	6a 00                	push   $0x0
  8014a5:	e8 3e fa ff ff       	call   800ee8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014aa:	83 c4 08             	add    $0x8,%esp
  8014ad:	57                   	push   %edi
  8014ae:	6a 00                	push   $0x0
  8014b0:	e8 33 fa ff ff       	call   800ee8 <sys_page_unmap>
	return r;
  8014b5:	83 c4 10             	add    $0x10,%esp
  8014b8:	89 f0                	mov    %esi,%eax
  8014ba:	eb 03                	jmp    8014bf <dup+0xe2>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8014bc:	8b 45 0c             	mov    0xc(%ebp),%eax

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8014bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014c2:	5b                   	pop    %ebx
  8014c3:	5e                   	pop    %esi
  8014c4:	5f                   	pop    %edi
  8014c5:	5d                   	pop    %ebp
  8014c6:	c3                   	ret    

008014c7 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014c7:	55                   	push   %ebp
  8014c8:	89 e5                	mov    %esp,%ebp
  8014ca:	53                   	push   %ebx
  8014cb:	83 ec 14             	sub    $0x14,%esp
  8014ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014d1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014d4:	50                   	push   %eax
  8014d5:	53                   	push   %ebx
  8014d6:	e8 6b fd ff ff       	call   801246 <fd_lookup>
  8014db:	83 c4 08             	add    $0x8,%esp
  8014de:	85 c0                	test   %eax,%eax
  8014e0:	78 67                	js     801549 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014e2:	83 ec 08             	sub    $0x8,%esp
  8014e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014e8:	50                   	push   %eax
  8014e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ec:	ff 30                	pushl  (%eax)
  8014ee:	e8 aa fd ff ff       	call   80129d <dev_lookup>
  8014f3:	83 c4 10             	add    $0x10,%esp
  8014f6:	85 c0                	test   %eax,%eax
  8014f8:	78 4f                	js     801549 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014fa:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014fd:	8b 42 08             	mov    0x8(%edx),%eax
  801500:	83 e0 03             	and    $0x3,%eax
  801503:	83 f8 01             	cmp    $0x1,%eax
  801506:	75 21                	jne    801529 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801508:	a1 20 44 80 00       	mov    0x804420,%eax
  80150d:	8b 40 48             	mov    0x48(%eax),%eax
  801510:	83 ec 04             	sub    $0x4,%esp
  801513:	53                   	push   %ebx
  801514:	50                   	push   %eax
  801515:	68 70 27 80 00       	push   $0x802770
  80151a:	e8 ef ee ff ff       	call   80040e <cprintf>
		return -E_INVAL;
  80151f:	83 c4 10             	add    $0x10,%esp
  801522:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801527:	eb 20                	jmp    801549 <read+0x82>
	}
	if (!dev->dev_read)
  801529:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80152c:	8b 40 08             	mov    0x8(%eax),%eax
  80152f:	85 c0                	test   %eax,%eax
  801531:	74 11                	je     801544 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801533:	83 ec 04             	sub    $0x4,%esp
  801536:	ff 75 10             	pushl  0x10(%ebp)
  801539:	ff 75 0c             	pushl  0xc(%ebp)
  80153c:	52                   	push   %edx
  80153d:	ff d0                	call   *%eax
  80153f:	83 c4 10             	add    $0x10,%esp
  801542:	eb 05                	jmp    801549 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801544:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801549:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80154c:	c9                   	leave  
  80154d:	c3                   	ret    

0080154e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80154e:	55                   	push   %ebp
  80154f:	89 e5                	mov    %esp,%ebp
  801551:	57                   	push   %edi
  801552:	56                   	push   %esi
  801553:	53                   	push   %ebx
  801554:	83 ec 0c             	sub    $0xc,%esp
  801557:	8b 7d 08             	mov    0x8(%ebp),%edi
  80155a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80155d:	85 f6                	test   %esi,%esi
  80155f:	74 31                	je     801592 <readn+0x44>
  801561:	b8 00 00 00 00       	mov    $0x0,%eax
  801566:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  80156b:	83 ec 04             	sub    $0x4,%esp
  80156e:	89 f2                	mov    %esi,%edx
  801570:	29 c2                	sub    %eax,%edx
  801572:	52                   	push   %edx
  801573:	03 45 0c             	add    0xc(%ebp),%eax
  801576:	50                   	push   %eax
  801577:	57                   	push   %edi
  801578:	e8 4a ff ff ff       	call   8014c7 <read>
		if (m < 0)
  80157d:	83 c4 10             	add    $0x10,%esp
  801580:	85 c0                	test   %eax,%eax
  801582:	78 17                	js     80159b <readn+0x4d>
			return m;
		if (m == 0)
  801584:	85 c0                	test   %eax,%eax
  801586:	74 11                	je     801599 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801588:	01 c3                	add    %eax,%ebx
  80158a:	89 d8                	mov    %ebx,%eax
  80158c:	39 f3                	cmp    %esi,%ebx
  80158e:	72 db                	jb     80156b <readn+0x1d>
  801590:	eb 09                	jmp    80159b <readn+0x4d>
  801592:	b8 00 00 00 00       	mov    $0x0,%eax
  801597:	eb 02                	jmp    80159b <readn+0x4d>
  801599:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80159b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80159e:	5b                   	pop    %ebx
  80159f:	5e                   	pop    %esi
  8015a0:	5f                   	pop    %edi
  8015a1:	5d                   	pop    %ebp
  8015a2:	c3                   	ret    

008015a3 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015a3:	55                   	push   %ebp
  8015a4:	89 e5                	mov    %esp,%ebp
  8015a6:	53                   	push   %ebx
  8015a7:	83 ec 14             	sub    $0x14,%esp
  8015aa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015ad:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015b0:	50                   	push   %eax
  8015b1:	53                   	push   %ebx
  8015b2:	e8 8f fc ff ff       	call   801246 <fd_lookup>
  8015b7:	83 c4 08             	add    $0x8,%esp
  8015ba:	85 c0                	test   %eax,%eax
  8015bc:	78 62                	js     801620 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015be:	83 ec 08             	sub    $0x8,%esp
  8015c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015c4:	50                   	push   %eax
  8015c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c8:	ff 30                	pushl  (%eax)
  8015ca:	e8 ce fc ff ff       	call   80129d <dev_lookup>
  8015cf:	83 c4 10             	add    $0x10,%esp
  8015d2:	85 c0                	test   %eax,%eax
  8015d4:	78 4a                	js     801620 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015d9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015dd:	75 21                	jne    801600 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015df:	a1 20 44 80 00       	mov    0x804420,%eax
  8015e4:	8b 40 48             	mov    0x48(%eax),%eax
  8015e7:	83 ec 04             	sub    $0x4,%esp
  8015ea:	53                   	push   %ebx
  8015eb:	50                   	push   %eax
  8015ec:	68 8c 27 80 00       	push   $0x80278c
  8015f1:	e8 18 ee ff ff       	call   80040e <cprintf>
		return -E_INVAL;
  8015f6:	83 c4 10             	add    $0x10,%esp
  8015f9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015fe:	eb 20                	jmp    801620 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801600:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801603:	8b 52 0c             	mov    0xc(%edx),%edx
  801606:	85 d2                	test   %edx,%edx
  801608:	74 11                	je     80161b <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80160a:	83 ec 04             	sub    $0x4,%esp
  80160d:	ff 75 10             	pushl  0x10(%ebp)
  801610:	ff 75 0c             	pushl  0xc(%ebp)
  801613:	50                   	push   %eax
  801614:	ff d2                	call   *%edx
  801616:	83 c4 10             	add    $0x10,%esp
  801619:	eb 05                	jmp    801620 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80161b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801620:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801623:	c9                   	leave  
  801624:	c3                   	ret    

00801625 <seek>:

int
seek(int fdnum, off_t offset)
{
  801625:	55                   	push   %ebp
  801626:	89 e5                	mov    %esp,%ebp
  801628:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80162b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80162e:	50                   	push   %eax
  80162f:	ff 75 08             	pushl  0x8(%ebp)
  801632:	e8 0f fc ff ff       	call   801246 <fd_lookup>
  801637:	83 c4 08             	add    $0x8,%esp
  80163a:	85 c0                	test   %eax,%eax
  80163c:	78 0e                	js     80164c <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80163e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801641:	8b 55 0c             	mov    0xc(%ebp),%edx
  801644:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801647:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80164c:	c9                   	leave  
  80164d:	c3                   	ret    

0080164e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80164e:	55                   	push   %ebp
  80164f:	89 e5                	mov    %esp,%ebp
  801651:	53                   	push   %ebx
  801652:	83 ec 14             	sub    $0x14,%esp
  801655:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801658:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80165b:	50                   	push   %eax
  80165c:	53                   	push   %ebx
  80165d:	e8 e4 fb ff ff       	call   801246 <fd_lookup>
  801662:	83 c4 08             	add    $0x8,%esp
  801665:	85 c0                	test   %eax,%eax
  801667:	78 5f                	js     8016c8 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801669:	83 ec 08             	sub    $0x8,%esp
  80166c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80166f:	50                   	push   %eax
  801670:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801673:	ff 30                	pushl  (%eax)
  801675:	e8 23 fc ff ff       	call   80129d <dev_lookup>
  80167a:	83 c4 10             	add    $0x10,%esp
  80167d:	85 c0                	test   %eax,%eax
  80167f:	78 47                	js     8016c8 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801681:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801684:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801688:	75 21                	jne    8016ab <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80168a:	a1 20 44 80 00       	mov    0x804420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80168f:	8b 40 48             	mov    0x48(%eax),%eax
  801692:	83 ec 04             	sub    $0x4,%esp
  801695:	53                   	push   %ebx
  801696:	50                   	push   %eax
  801697:	68 4c 27 80 00       	push   $0x80274c
  80169c:	e8 6d ed ff ff       	call   80040e <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016a1:	83 c4 10             	add    $0x10,%esp
  8016a4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016a9:	eb 1d                	jmp    8016c8 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  8016ab:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016ae:	8b 52 18             	mov    0x18(%edx),%edx
  8016b1:	85 d2                	test   %edx,%edx
  8016b3:	74 0e                	je     8016c3 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016b5:	83 ec 08             	sub    $0x8,%esp
  8016b8:	ff 75 0c             	pushl  0xc(%ebp)
  8016bb:	50                   	push   %eax
  8016bc:	ff d2                	call   *%edx
  8016be:	83 c4 10             	add    $0x10,%esp
  8016c1:	eb 05                	jmp    8016c8 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016c3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8016c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016cb:	c9                   	leave  
  8016cc:	c3                   	ret    

008016cd <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016cd:	55                   	push   %ebp
  8016ce:	89 e5                	mov    %esp,%ebp
  8016d0:	53                   	push   %ebx
  8016d1:	83 ec 14             	sub    $0x14,%esp
  8016d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016d7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016da:	50                   	push   %eax
  8016db:	ff 75 08             	pushl  0x8(%ebp)
  8016de:	e8 63 fb ff ff       	call   801246 <fd_lookup>
  8016e3:	83 c4 08             	add    $0x8,%esp
  8016e6:	85 c0                	test   %eax,%eax
  8016e8:	78 52                	js     80173c <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ea:	83 ec 08             	sub    $0x8,%esp
  8016ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016f0:	50                   	push   %eax
  8016f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f4:	ff 30                	pushl  (%eax)
  8016f6:	e8 a2 fb ff ff       	call   80129d <dev_lookup>
  8016fb:	83 c4 10             	add    $0x10,%esp
  8016fe:	85 c0                	test   %eax,%eax
  801700:	78 3a                	js     80173c <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  801702:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801705:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801709:	74 2c                	je     801737 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80170b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80170e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801715:	00 00 00 
	stat->st_isdir = 0;
  801718:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80171f:	00 00 00 
	stat->st_dev = dev;
  801722:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801728:	83 ec 08             	sub    $0x8,%esp
  80172b:	53                   	push   %ebx
  80172c:	ff 75 f0             	pushl  -0x10(%ebp)
  80172f:	ff 50 14             	call   *0x14(%eax)
  801732:	83 c4 10             	add    $0x10,%esp
  801735:	eb 05                	jmp    80173c <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801737:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80173c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80173f:	c9                   	leave  
  801740:	c3                   	ret    

00801741 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801741:	55                   	push   %ebp
  801742:	89 e5                	mov    %esp,%ebp
  801744:	56                   	push   %esi
  801745:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801746:	83 ec 08             	sub    $0x8,%esp
  801749:	6a 00                	push   $0x0
  80174b:	ff 75 08             	pushl  0x8(%ebp)
  80174e:	e8 75 01 00 00       	call   8018c8 <open>
  801753:	89 c3                	mov    %eax,%ebx
  801755:	83 c4 10             	add    $0x10,%esp
  801758:	85 c0                	test   %eax,%eax
  80175a:	78 1d                	js     801779 <stat+0x38>
		return fd;
	r = fstat(fd, stat);
  80175c:	83 ec 08             	sub    $0x8,%esp
  80175f:	ff 75 0c             	pushl  0xc(%ebp)
  801762:	50                   	push   %eax
  801763:	e8 65 ff ff ff       	call   8016cd <fstat>
  801768:	89 c6                	mov    %eax,%esi
	close(fd);
  80176a:	89 1c 24             	mov    %ebx,(%esp)
  80176d:	e8 1d fc ff ff       	call   80138f <close>
	return r;
  801772:	83 c4 10             	add    $0x10,%esp
  801775:	89 f0                	mov    %esi,%eax
  801777:	eb 00                	jmp    801779 <stat+0x38>
}
  801779:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80177c:	5b                   	pop    %ebx
  80177d:	5e                   	pop    %esi
  80177e:	5d                   	pop    %ebp
  80177f:	c3                   	ret    

00801780 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801780:	55                   	push   %ebp
  801781:	89 e5                	mov    %esp,%ebp
  801783:	56                   	push   %esi
  801784:	53                   	push   %ebx
  801785:	89 c6                	mov    %eax,%esi
  801787:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801789:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801790:	75 12                	jne    8017a4 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801792:	83 ec 0c             	sub    $0xc,%esp
  801795:	6a 01                	push   $0x1
  801797:	e8 8c 08 00 00       	call   802028 <ipc_find_env>
  80179c:	a3 00 40 80 00       	mov    %eax,0x804000
  8017a1:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017a4:	6a 07                	push   $0x7
  8017a6:	68 00 50 80 00       	push   $0x805000
  8017ab:	56                   	push   %esi
  8017ac:	ff 35 00 40 80 00    	pushl  0x804000
  8017b2:	e8 12 08 00 00       	call   801fc9 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017b7:	83 c4 0c             	add    $0xc,%esp
  8017ba:	6a 00                	push   $0x0
  8017bc:	53                   	push   %ebx
  8017bd:	6a 00                	push   $0x0
  8017bf:	e8 90 07 00 00       	call   801f54 <ipc_recv>
}
  8017c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017c7:	5b                   	pop    %ebx
  8017c8:	5e                   	pop    %esi
  8017c9:	5d                   	pop    %ebp
  8017ca:	c3                   	ret    

008017cb <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017cb:	55                   	push   %ebp
  8017cc:	89 e5                	mov    %esp,%ebp
  8017ce:	53                   	push   %ebx
  8017cf:	83 ec 04             	sub    $0x4,%esp
  8017d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d8:	8b 40 0c             	mov    0xc(%eax),%eax
  8017db:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8017e5:	b8 05 00 00 00       	mov    $0x5,%eax
  8017ea:	e8 91 ff ff ff       	call   801780 <fsipc>
  8017ef:	85 c0                	test   %eax,%eax
  8017f1:	78 2c                	js     80181f <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017f3:	83 ec 08             	sub    $0x8,%esp
  8017f6:	68 00 50 80 00       	push   $0x805000
  8017fb:	53                   	push   %ebx
  8017fc:	e8 f2 f1 ff ff       	call   8009f3 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801801:	a1 80 50 80 00       	mov    0x805080,%eax
  801806:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80180c:	a1 84 50 80 00       	mov    0x805084,%eax
  801811:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801817:	83 c4 10             	add    $0x10,%esp
  80181a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80181f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801822:	c9                   	leave  
  801823:	c3                   	ret    

00801824 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801824:	55                   	push   %ebp
  801825:	89 e5                	mov    %esp,%ebp
  801827:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80182a:	8b 45 08             	mov    0x8(%ebp),%eax
  80182d:	8b 40 0c             	mov    0xc(%eax),%eax
  801830:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801835:	ba 00 00 00 00       	mov    $0x0,%edx
  80183a:	b8 06 00 00 00       	mov    $0x6,%eax
  80183f:	e8 3c ff ff ff       	call   801780 <fsipc>
}
  801844:	c9                   	leave  
  801845:	c3                   	ret    

00801846 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801846:	55                   	push   %ebp
  801847:	89 e5                	mov    %esp,%ebp
  801849:	56                   	push   %esi
  80184a:	53                   	push   %ebx
  80184b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80184e:	8b 45 08             	mov    0x8(%ebp),%eax
  801851:	8b 40 0c             	mov    0xc(%eax),%eax
  801854:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801859:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80185f:	ba 00 00 00 00       	mov    $0x0,%edx
  801864:	b8 03 00 00 00       	mov    $0x3,%eax
  801869:	e8 12 ff ff ff       	call   801780 <fsipc>
  80186e:	89 c3                	mov    %eax,%ebx
  801870:	85 c0                	test   %eax,%eax
  801872:	78 4b                	js     8018bf <devfile_read+0x79>
		return r;
	assert(r <= n);
  801874:	39 c6                	cmp    %eax,%esi
  801876:	73 16                	jae    80188e <devfile_read+0x48>
  801878:	68 a9 27 80 00       	push   $0x8027a9
  80187d:	68 b0 27 80 00       	push   $0x8027b0
  801882:	6a 7a                	push   $0x7a
  801884:	68 c5 27 80 00       	push   $0x8027c5
  801889:	e8 a8 ea ff ff       	call   800336 <_panic>
	assert(r <= PGSIZE);
  80188e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801893:	7e 16                	jle    8018ab <devfile_read+0x65>
  801895:	68 d0 27 80 00       	push   $0x8027d0
  80189a:	68 b0 27 80 00       	push   $0x8027b0
  80189f:	6a 7b                	push   $0x7b
  8018a1:	68 c5 27 80 00       	push   $0x8027c5
  8018a6:	e8 8b ea ff ff       	call   800336 <_panic>
	memmove(buf, &fsipcbuf, r);
  8018ab:	83 ec 04             	sub    $0x4,%esp
  8018ae:	50                   	push   %eax
  8018af:	68 00 50 80 00       	push   $0x805000
  8018b4:	ff 75 0c             	pushl  0xc(%ebp)
  8018b7:	e8 04 f3 ff ff       	call   800bc0 <memmove>
	return r;
  8018bc:	83 c4 10             	add    $0x10,%esp
}
  8018bf:	89 d8                	mov    %ebx,%eax
  8018c1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018c4:	5b                   	pop    %ebx
  8018c5:	5e                   	pop    %esi
  8018c6:	5d                   	pop    %ebp
  8018c7:	c3                   	ret    

008018c8 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018c8:	55                   	push   %ebp
  8018c9:	89 e5                	mov    %esp,%ebp
  8018cb:	53                   	push   %ebx
  8018cc:	83 ec 20             	sub    $0x20,%esp
  8018cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018d2:	53                   	push   %ebx
  8018d3:	e8 c4 f0 ff ff       	call   80099c <strlen>
  8018d8:	83 c4 10             	add    $0x10,%esp
  8018db:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018e0:	7f 63                	jg     801945 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018e2:	83 ec 0c             	sub    $0xc,%esp
  8018e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018e8:	50                   	push   %eax
  8018e9:	e8 e4 f8 ff ff       	call   8011d2 <fd_alloc>
  8018ee:	83 c4 10             	add    $0x10,%esp
  8018f1:	85 c0                	test   %eax,%eax
  8018f3:	78 55                	js     80194a <open+0x82>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018f5:	83 ec 08             	sub    $0x8,%esp
  8018f8:	53                   	push   %ebx
  8018f9:	68 00 50 80 00       	push   $0x805000
  8018fe:	e8 f0 f0 ff ff       	call   8009f3 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801903:	8b 45 0c             	mov    0xc(%ebp),%eax
  801906:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80190b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80190e:	b8 01 00 00 00       	mov    $0x1,%eax
  801913:	e8 68 fe ff ff       	call   801780 <fsipc>
  801918:	89 c3                	mov    %eax,%ebx
  80191a:	83 c4 10             	add    $0x10,%esp
  80191d:	85 c0                	test   %eax,%eax
  80191f:	79 14                	jns    801935 <open+0x6d>
		fd_close(fd, 0);
  801921:	83 ec 08             	sub    $0x8,%esp
  801924:	6a 00                	push   $0x0
  801926:	ff 75 f4             	pushl  -0xc(%ebp)
  801929:	e8 dd f9 ff ff       	call   80130b <fd_close>
		return r;
  80192e:	83 c4 10             	add    $0x10,%esp
  801931:	89 d8                	mov    %ebx,%eax
  801933:	eb 15                	jmp    80194a <open+0x82>
	}

	return fd2num(fd);
  801935:	83 ec 0c             	sub    $0xc,%esp
  801938:	ff 75 f4             	pushl  -0xc(%ebp)
  80193b:	e8 6b f8 ff ff       	call   8011ab <fd2num>
  801940:	83 c4 10             	add    $0x10,%esp
  801943:	eb 05                	jmp    80194a <open+0x82>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801945:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80194a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80194d:	c9                   	leave  
  80194e:	c3                   	ret    

0080194f <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  80194f:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801953:	7e 38                	jle    80198d <writebuf+0x3e>
};


static void
writebuf(struct printbuf *b)
{
  801955:	55                   	push   %ebp
  801956:	89 e5                	mov    %esp,%ebp
  801958:	53                   	push   %ebx
  801959:	83 ec 08             	sub    $0x8,%esp
  80195c:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  80195e:	ff 70 04             	pushl  0x4(%eax)
  801961:	8d 40 10             	lea    0x10(%eax),%eax
  801964:	50                   	push   %eax
  801965:	ff 33                	pushl  (%ebx)
  801967:	e8 37 fc ff ff       	call   8015a3 <write>
		if (result > 0)
  80196c:	83 c4 10             	add    $0x10,%esp
  80196f:	85 c0                	test   %eax,%eax
  801971:	7e 03                	jle    801976 <writebuf+0x27>
			b->result += result;
  801973:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801976:	3b 43 04             	cmp    0x4(%ebx),%eax
  801979:	74 0e                	je     801989 <writebuf+0x3a>
			b->error = (result < 0 ? result : 0);
  80197b:	89 c2                	mov    %eax,%edx
  80197d:	85 c0                	test   %eax,%eax
  80197f:	7e 05                	jle    801986 <writebuf+0x37>
  801981:	ba 00 00 00 00       	mov    $0x0,%edx
  801986:	89 53 0c             	mov    %edx,0xc(%ebx)
	}
}
  801989:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80198c:	c9                   	leave  
  80198d:	c3                   	ret    

0080198e <putch>:

static void
putch(int ch, void *thunk)
{
  80198e:	55                   	push   %ebp
  80198f:	89 e5                	mov    %esp,%ebp
  801991:	53                   	push   %ebx
  801992:	83 ec 04             	sub    $0x4,%esp
  801995:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801998:	8b 53 04             	mov    0x4(%ebx),%edx
  80199b:	8d 42 01             	lea    0x1(%edx),%eax
  80199e:	89 43 04             	mov    %eax,0x4(%ebx)
  8019a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019a4:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8019a8:	3d 00 01 00 00       	cmp    $0x100,%eax
  8019ad:	75 0e                	jne    8019bd <putch+0x2f>
		writebuf(b);
  8019af:	89 d8                	mov    %ebx,%eax
  8019b1:	e8 99 ff ff ff       	call   80194f <writebuf>
		b->idx = 0;
  8019b6:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8019bd:	83 c4 04             	add    $0x4,%esp
  8019c0:	5b                   	pop    %ebx
  8019c1:	5d                   	pop    %ebp
  8019c2:	c3                   	ret    

008019c3 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8019c3:	55                   	push   %ebp
  8019c4:	89 e5                	mov    %esp,%ebp
  8019c6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8019cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8019cf:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8019d5:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8019dc:	00 00 00 
	b.result = 0;
  8019df:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8019e6:	00 00 00 
	b.error = 1;
  8019e9:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8019f0:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8019f3:	ff 75 10             	pushl  0x10(%ebp)
  8019f6:	ff 75 0c             	pushl  0xc(%ebp)
  8019f9:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8019ff:	50                   	push   %eax
  801a00:	68 8e 19 80 00       	push   $0x80198e
  801a05:	e8 3b eb ff ff       	call   800545 <vprintfmt>
	if (b.idx > 0)
  801a0a:	83 c4 10             	add    $0x10,%esp
  801a0d:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801a14:	7e 0b                	jle    801a21 <vfprintf+0x5e>
		writebuf(&b);
  801a16:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801a1c:	e8 2e ff ff ff       	call   80194f <writebuf>

	return (b.result ? b.result : b.error);
  801a21:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801a27:	85 c0                	test   %eax,%eax
  801a29:	75 06                	jne    801a31 <vfprintf+0x6e>
  801a2b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  801a31:	c9                   	leave  
  801a32:	c3                   	ret    

00801a33 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801a33:	55                   	push   %ebp
  801a34:	89 e5                	mov    %esp,%ebp
  801a36:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801a39:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801a3c:	50                   	push   %eax
  801a3d:	ff 75 0c             	pushl  0xc(%ebp)
  801a40:	ff 75 08             	pushl  0x8(%ebp)
  801a43:	e8 7b ff ff ff       	call   8019c3 <vfprintf>
	va_end(ap);

	return cnt;
}
  801a48:	c9                   	leave  
  801a49:	c3                   	ret    

00801a4a <printf>:

int
printf(const char *fmt, ...)
{
  801a4a:	55                   	push   %ebp
  801a4b:	89 e5                	mov    %esp,%ebp
  801a4d:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801a50:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801a53:	50                   	push   %eax
  801a54:	ff 75 08             	pushl  0x8(%ebp)
  801a57:	6a 01                	push   $0x1
  801a59:	e8 65 ff ff ff       	call   8019c3 <vfprintf>
	va_end(ap);

	return cnt;
}
  801a5e:	c9                   	leave  
  801a5f:	c3                   	ret    

00801a60 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a60:	55                   	push   %ebp
  801a61:	89 e5                	mov    %esp,%ebp
  801a63:	56                   	push   %esi
  801a64:	53                   	push   %ebx
  801a65:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a68:	83 ec 0c             	sub    $0xc,%esp
  801a6b:	ff 75 08             	pushl  0x8(%ebp)
  801a6e:	e8 48 f7 ff ff       	call   8011bb <fd2data>
  801a73:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a75:	83 c4 08             	add    $0x8,%esp
  801a78:	68 dc 27 80 00       	push   $0x8027dc
  801a7d:	53                   	push   %ebx
  801a7e:	e8 70 ef ff ff       	call   8009f3 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a83:	8b 46 04             	mov    0x4(%esi),%eax
  801a86:	2b 06                	sub    (%esi),%eax
  801a88:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a8e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a95:	00 00 00 
	stat->st_dev = &devpipe;
  801a98:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a9f:	30 80 00 
	return 0;
}
  801aa2:	b8 00 00 00 00       	mov    $0x0,%eax
  801aa7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aaa:	5b                   	pop    %ebx
  801aab:	5e                   	pop    %esi
  801aac:	5d                   	pop    %ebp
  801aad:	c3                   	ret    

00801aae <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801aae:	55                   	push   %ebp
  801aaf:	89 e5                	mov    %esp,%ebp
  801ab1:	53                   	push   %ebx
  801ab2:	83 ec 0c             	sub    $0xc,%esp
  801ab5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ab8:	53                   	push   %ebx
  801ab9:	6a 00                	push   $0x0
  801abb:	e8 28 f4 ff ff       	call   800ee8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ac0:	89 1c 24             	mov    %ebx,(%esp)
  801ac3:	e8 f3 f6 ff ff       	call   8011bb <fd2data>
  801ac8:	83 c4 08             	add    $0x8,%esp
  801acb:	50                   	push   %eax
  801acc:	6a 00                	push   $0x0
  801ace:	e8 15 f4 ff ff       	call   800ee8 <sys_page_unmap>
}
  801ad3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ad6:	c9                   	leave  
  801ad7:	c3                   	ret    

00801ad8 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ad8:	55                   	push   %ebp
  801ad9:	89 e5                	mov    %esp,%ebp
  801adb:	57                   	push   %edi
  801adc:	56                   	push   %esi
  801add:	53                   	push   %ebx
  801ade:	83 ec 1c             	sub    $0x1c,%esp
  801ae1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ae4:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ae6:	a1 20 44 80 00       	mov    0x804420,%eax
  801aeb:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801aee:	83 ec 0c             	sub    $0xc,%esp
  801af1:	ff 75 e0             	pushl  -0x20(%ebp)
  801af4:	e8 8a 05 00 00       	call   802083 <pageref>
  801af9:	89 c3                	mov    %eax,%ebx
  801afb:	89 3c 24             	mov    %edi,(%esp)
  801afe:	e8 80 05 00 00       	call   802083 <pageref>
  801b03:	83 c4 10             	add    $0x10,%esp
  801b06:	39 c3                	cmp    %eax,%ebx
  801b08:	0f 94 c1             	sete   %cl
  801b0b:	0f b6 c9             	movzbl %cl,%ecx
  801b0e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b11:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801b17:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b1a:	39 ce                	cmp    %ecx,%esi
  801b1c:	74 1b                	je     801b39 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801b1e:	39 c3                	cmp    %eax,%ebx
  801b20:	75 c4                	jne    801ae6 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b22:	8b 42 58             	mov    0x58(%edx),%eax
  801b25:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b28:	50                   	push   %eax
  801b29:	56                   	push   %esi
  801b2a:	68 e3 27 80 00       	push   $0x8027e3
  801b2f:	e8 da e8 ff ff       	call   80040e <cprintf>
  801b34:	83 c4 10             	add    $0x10,%esp
  801b37:	eb ad                	jmp    801ae6 <_pipeisclosed+0xe>
	}
}
  801b39:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b3f:	5b                   	pop    %ebx
  801b40:	5e                   	pop    %esi
  801b41:	5f                   	pop    %edi
  801b42:	5d                   	pop    %ebp
  801b43:	c3                   	ret    

00801b44 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b44:	55                   	push   %ebp
  801b45:	89 e5                	mov    %esp,%ebp
  801b47:	57                   	push   %edi
  801b48:	56                   	push   %esi
  801b49:	53                   	push   %ebx
  801b4a:	83 ec 18             	sub    $0x18,%esp
  801b4d:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b50:	56                   	push   %esi
  801b51:	e8 65 f6 ff ff       	call   8011bb <fd2data>
  801b56:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b58:	83 c4 10             	add    $0x10,%esp
  801b5b:	bf 00 00 00 00       	mov    $0x0,%edi
  801b60:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b64:	75 42                	jne    801ba8 <devpipe_write+0x64>
  801b66:	eb 4e                	jmp    801bb6 <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b68:	89 da                	mov    %ebx,%edx
  801b6a:	89 f0                	mov    %esi,%eax
  801b6c:	e8 67 ff ff ff       	call   801ad8 <_pipeisclosed>
  801b71:	85 c0                	test   %eax,%eax
  801b73:	75 46                	jne    801bbb <devpipe_write+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b75:	e8 ca f2 ff ff       	call   800e44 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b7a:	8b 53 04             	mov    0x4(%ebx),%edx
  801b7d:	8b 03                	mov    (%ebx),%eax
  801b7f:	83 c0 20             	add    $0x20,%eax
  801b82:	39 c2                	cmp    %eax,%edx
  801b84:	73 e2                	jae    801b68 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b86:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b89:	8a 0c 38             	mov    (%eax,%edi,1),%cl
  801b8c:	89 d0                	mov    %edx,%eax
  801b8e:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801b93:	79 05                	jns    801b9a <devpipe_write+0x56>
  801b95:	48                   	dec    %eax
  801b96:	83 c8 e0             	or     $0xffffffe0,%eax
  801b99:	40                   	inc    %eax
  801b9a:	88 4c 03 08          	mov    %cl,0x8(%ebx,%eax,1)
		p->p_wpos++;
  801b9e:	42                   	inc    %edx
  801b9f:	89 53 04             	mov    %edx,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ba2:	47                   	inc    %edi
  801ba3:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801ba6:	74 0e                	je     801bb6 <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ba8:	8b 53 04             	mov    0x4(%ebx),%edx
  801bab:	8b 03                	mov    (%ebx),%eax
  801bad:	83 c0 20             	add    $0x20,%eax
  801bb0:	39 c2                	cmp    %eax,%edx
  801bb2:	73 b4                	jae    801b68 <devpipe_write+0x24>
  801bb4:	eb d0                	jmp    801b86 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801bb6:	8b 45 10             	mov    0x10(%ebp),%eax
  801bb9:	eb 05                	jmp    801bc0 <devpipe_write+0x7c>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bbb:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801bc0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bc3:	5b                   	pop    %ebx
  801bc4:	5e                   	pop    %esi
  801bc5:	5f                   	pop    %edi
  801bc6:	5d                   	pop    %ebp
  801bc7:	c3                   	ret    

00801bc8 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801bc8:	55                   	push   %ebp
  801bc9:	89 e5                	mov    %esp,%ebp
  801bcb:	57                   	push   %edi
  801bcc:	56                   	push   %esi
  801bcd:	53                   	push   %ebx
  801bce:	83 ec 18             	sub    $0x18,%esp
  801bd1:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801bd4:	57                   	push   %edi
  801bd5:	e8 e1 f5 ff ff       	call   8011bb <fd2data>
  801bda:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bdc:	83 c4 10             	add    $0x10,%esp
  801bdf:	be 00 00 00 00       	mov    $0x0,%esi
  801be4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801be8:	75 3d                	jne    801c27 <devpipe_read+0x5f>
  801bea:	eb 48                	jmp    801c34 <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801bec:	89 f0                	mov    %esi,%eax
  801bee:	eb 4e                	jmp    801c3e <devpipe_read+0x76>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801bf0:	89 da                	mov    %ebx,%edx
  801bf2:	89 f8                	mov    %edi,%eax
  801bf4:	e8 df fe ff ff       	call   801ad8 <_pipeisclosed>
  801bf9:	85 c0                	test   %eax,%eax
  801bfb:	75 3c                	jne    801c39 <devpipe_read+0x71>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801bfd:	e8 42 f2 ff ff       	call   800e44 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c02:	8b 03                	mov    (%ebx),%eax
  801c04:	3b 43 04             	cmp    0x4(%ebx),%eax
  801c07:	74 e7                	je     801bf0 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c09:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801c0e:	79 05                	jns    801c15 <devpipe_read+0x4d>
  801c10:	48                   	dec    %eax
  801c11:	83 c8 e0             	or     $0xffffffe0,%eax
  801c14:	40                   	inc    %eax
  801c15:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801c19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c1c:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801c1f:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c21:	46                   	inc    %esi
  801c22:	39 75 10             	cmp    %esi,0x10(%ebp)
  801c25:	74 0d                	je     801c34 <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
  801c27:	8b 03                	mov    (%ebx),%eax
  801c29:	3b 43 04             	cmp    0x4(%ebx),%eax
  801c2c:	75 db                	jne    801c09 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c2e:	85 f6                	test   %esi,%esi
  801c30:	75 ba                	jne    801bec <devpipe_read+0x24>
  801c32:	eb bc                	jmp    801bf0 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c34:	8b 45 10             	mov    0x10(%ebp),%eax
  801c37:	eb 05                	jmp    801c3e <devpipe_read+0x76>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c39:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c41:	5b                   	pop    %ebx
  801c42:	5e                   	pop    %esi
  801c43:	5f                   	pop    %edi
  801c44:	5d                   	pop    %ebp
  801c45:	c3                   	ret    

00801c46 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c46:	55                   	push   %ebp
  801c47:	89 e5                	mov    %esp,%ebp
  801c49:	56                   	push   %esi
  801c4a:	53                   	push   %ebx
  801c4b:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c4e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c51:	50                   	push   %eax
  801c52:	e8 7b f5 ff ff       	call   8011d2 <fd_alloc>
  801c57:	83 c4 10             	add    $0x10,%esp
  801c5a:	85 c0                	test   %eax,%eax
  801c5c:	0f 88 2a 01 00 00    	js     801d8c <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c62:	83 ec 04             	sub    $0x4,%esp
  801c65:	68 07 04 00 00       	push   $0x407
  801c6a:	ff 75 f4             	pushl  -0xc(%ebp)
  801c6d:	6a 00                	push   $0x0
  801c6f:	e8 ef f1 ff ff       	call   800e63 <sys_page_alloc>
  801c74:	83 c4 10             	add    $0x10,%esp
  801c77:	85 c0                	test   %eax,%eax
  801c79:	0f 88 0d 01 00 00    	js     801d8c <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c7f:	83 ec 0c             	sub    $0xc,%esp
  801c82:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c85:	50                   	push   %eax
  801c86:	e8 47 f5 ff ff       	call   8011d2 <fd_alloc>
  801c8b:	89 c3                	mov    %eax,%ebx
  801c8d:	83 c4 10             	add    $0x10,%esp
  801c90:	85 c0                	test   %eax,%eax
  801c92:	0f 88 e2 00 00 00    	js     801d7a <pipe+0x134>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c98:	83 ec 04             	sub    $0x4,%esp
  801c9b:	68 07 04 00 00       	push   $0x407
  801ca0:	ff 75 f0             	pushl  -0x10(%ebp)
  801ca3:	6a 00                	push   $0x0
  801ca5:	e8 b9 f1 ff ff       	call   800e63 <sys_page_alloc>
  801caa:	89 c3                	mov    %eax,%ebx
  801cac:	83 c4 10             	add    $0x10,%esp
  801caf:	85 c0                	test   %eax,%eax
  801cb1:	0f 88 c3 00 00 00    	js     801d7a <pipe+0x134>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801cb7:	83 ec 0c             	sub    $0xc,%esp
  801cba:	ff 75 f4             	pushl  -0xc(%ebp)
  801cbd:	e8 f9 f4 ff ff       	call   8011bb <fd2data>
  801cc2:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cc4:	83 c4 0c             	add    $0xc,%esp
  801cc7:	68 07 04 00 00       	push   $0x407
  801ccc:	50                   	push   %eax
  801ccd:	6a 00                	push   $0x0
  801ccf:	e8 8f f1 ff ff       	call   800e63 <sys_page_alloc>
  801cd4:	89 c3                	mov    %eax,%ebx
  801cd6:	83 c4 10             	add    $0x10,%esp
  801cd9:	85 c0                	test   %eax,%eax
  801cdb:	0f 88 89 00 00 00    	js     801d6a <pipe+0x124>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ce1:	83 ec 0c             	sub    $0xc,%esp
  801ce4:	ff 75 f0             	pushl  -0x10(%ebp)
  801ce7:	e8 cf f4 ff ff       	call   8011bb <fd2data>
  801cec:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801cf3:	50                   	push   %eax
  801cf4:	6a 00                	push   $0x0
  801cf6:	56                   	push   %esi
  801cf7:	6a 00                	push   $0x0
  801cf9:	e8 a8 f1 ff ff       	call   800ea6 <sys_page_map>
  801cfe:	89 c3                	mov    %eax,%ebx
  801d00:	83 c4 20             	add    $0x20,%esp
  801d03:	85 c0                	test   %eax,%eax
  801d05:	78 55                	js     801d5c <pipe+0x116>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d07:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d10:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d12:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d15:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d1c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d22:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d25:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d27:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d2a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d31:	83 ec 0c             	sub    $0xc,%esp
  801d34:	ff 75 f4             	pushl  -0xc(%ebp)
  801d37:	e8 6f f4 ff ff       	call   8011ab <fd2num>
  801d3c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d3f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d41:	83 c4 04             	add    $0x4,%esp
  801d44:	ff 75 f0             	pushl  -0x10(%ebp)
  801d47:	e8 5f f4 ff ff       	call   8011ab <fd2num>
  801d4c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d4f:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d52:	83 c4 10             	add    $0x10,%esp
  801d55:	b8 00 00 00 00       	mov    $0x0,%eax
  801d5a:	eb 30                	jmp    801d8c <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801d5c:	83 ec 08             	sub    $0x8,%esp
  801d5f:	56                   	push   %esi
  801d60:	6a 00                	push   $0x0
  801d62:	e8 81 f1 ff ff       	call   800ee8 <sys_page_unmap>
  801d67:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d6a:	83 ec 08             	sub    $0x8,%esp
  801d6d:	ff 75 f0             	pushl  -0x10(%ebp)
  801d70:	6a 00                	push   $0x0
  801d72:	e8 71 f1 ff ff       	call   800ee8 <sys_page_unmap>
  801d77:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d7a:	83 ec 08             	sub    $0x8,%esp
  801d7d:	ff 75 f4             	pushl  -0xc(%ebp)
  801d80:	6a 00                	push   $0x0
  801d82:	e8 61 f1 ff ff       	call   800ee8 <sys_page_unmap>
  801d87:	83 c4 10             	add    $0x10,%esp
  801d8a:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  801d8c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d8f:	5b                   	pop    %ebx
  801d90:	5e                   	pop    %esi
  801d91:	5d                   	pop    %ebp
  801d92:	c3                   	ret    

00801d93 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d93:	55                   	push   %ebp
  801d94:	89 e5                	mov    %esp,%ebp
  801d96:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d99:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d9c:	50                   	push   %eax
  801d9d:	ff 75 08             	pushl  0x8(%ebp)
  801da0:	e8 a1 f4 ff ff       	call   801246 <fd_lookup>
  801da5:	83 c4 10             	add    $0x10,%esp
  801da8:	85 c0                	test   %eax,%eax
  801daa:	78 18                	js     801dc4 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801dac:	83 ec 0c             	sub    $0xc,%esp
  801daf:	ff 75 f4             	pushl  -0xc(%ebp)
  801db2:	e8 04 f4 ff ff       	call   8011bb <fd2data>
	return _pipeisclosed(fd, p);
  801db7:	89 c2                	mov    %eax,%edx
  801db9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dbc:	e8 17 fd ff ff       	call   801ad8 <_pipeisclosed>
  801dc1:	83 c4 10             	add    $0x10,%esp
}
  801dc4:	c9                   	leave  
  801dc5:	c3                   	ret    

00801dc6 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801dc6:	55                   	push   %ebp
  801dc7:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801dc9:	b8 00 00 00 00       	mov    $0x0,%eax
  801dce:	5d                   	pop    %ebp
  801dcf:	c3                   	ret    

00801dd0 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801dd0:	55                   	push   %ebp
  801dd1:	89 e5                	mov    %esp,%ebp
  801dd3:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801dd6:	68 fb 27 80 00       	push   $0x8027fb
  801ddb:	ff 75 0c             	pushl  0xc(%ebp)
  801dde:	e8 10 ec ff ff       	call   8009f3 <strcpy>
	return 0;
}
  801de3:	b8 00 00 00 00       	mov    $0x0,%eax
  801de8:	c9                   	leave  
  801de9:	c3                   	ret    

00801dea <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801dea:	55                   	push   %ebp
  801deb:	89 e5                	mov    %esp,%ebp
  801ded:	57                   	push   %edi
  801dee:	56                   	push   %esi
  801def:	53                   	push   %ebx
  801df0:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801df6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801dfa:	74 45                	je     801e41 <devcons_write+0x57>
  801dfc:	b8 00 00 00 00       	mov    $0x0,%eax
  801e01:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e06:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e0c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e0f:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801e11:	83 fb 7f             	cmp    $0x7f,%ebx
  801e14:	76 05                	jbe    801e1b <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801e16:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801e1b:	83 ec 04             	sub    $0x4,%esp
  801e1e:	53                   	push   %ebx
  801e1f:	03 45 0c             	add    0xc(%ebp),%eax
  801e22:	50                   	push   %eax
  801e23:	57                   	push   %edi
  801e24:	e8 97 ed ff ff       	call   800bc0 <memmove>
		sys_cputs(buf, m);
  801e29:	83 c4 08             	add    $0x8,%esp
  801e2c:	53                   	push   %ebx
  801e2d:	57                   	push   %edi
  801e2e:	e8 74 ef ff ff       	call   800da7 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e33:	01 de                	add    %ebx,%esi
  801e35:	89 f0                	mov    %esi,%eax
  801e37:	83 c4 10             	add    $0x10,%esp
  801e3a:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e3d:	72 cd                	jb     801e0c <devcons_write+0x22>
  801e3f:	eb 05                	jmp    801e46 <devcons_write+0x5c>
  801e41:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e46:	89 f0                	mov    %esi,%eax
  801e48:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e4b:	5b                   	pop    %ebx
  801e4c:	5e                   	pop    %esi
  801e4d:	5f                   	pop    %edi
  801e4e:	5d                   	pop    %ebp
  801e4f:	c3                   	ret    

00801e50 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e50:	55                   	push   %ebp
  801e51:	89 e5                	mov    %esp,%ebp
  801e53:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801e56:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e5a:	75 07                	jne    801e63 <devcons_read+0x13>
  801e5c:	eb 23                	jmp    801e81 <devcons_read+0x31>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e5e:	e8 e1 ef ff ff       	call   800e44 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e63:	e8 5d ef ff ff       	call   800dc5 <sys_cgetc>
  801e68:	85 c0                	test   %eax,%eax
  801e6a:	74 f2                	je     801e5e <devcons_read+0xe>
		sys_yield();
	if (c < 0)
  801e6c:	85 c0                	test   %eax,%eax
  801e6e:	78 1d                	js     801e8d <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e70:	83 f8 04             	cmp    $0x4,%eax
  801e73:	74 13                	je     801e88 <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  801e75:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e78:	88 02                	mov    %al,(%edx)
	return 1;
  801e7a:	b8 01 00 00 00       	mov    $0x1,%eax
  801e7f:	eb 0c                	jmp    801e8d <devcons_read+0x3d>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801e81:	b8 00 00 00 00       	mov    $0x0,%eax
  801e86:	eb 05                	jmp    801e8d <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e88:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e8d:	c9                   	leave  
  801e8e:	c3                   	ret    

00801e8f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e8f:	55                   	push   %ebp
  801e90:	89 e5                	mov    %esp,%ebp
  801e92:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e95:	8b 45 08             	mov    0x8(%ebp),%eax
  801e98:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e9b:	6a 01                	push   $0x1
  801e9d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ea0:	50                   	push   %eax
  801ea1:	e8 01 ef ff ff       	call   800da7 <sys_cputs>
}
  801ea6:	83 c4 10             	add    $0x10,%esp
  801ea9:	c9                   	leave  
  801eaa:	c3                   	ret    

00801eab <getchar>:

int
getchar(void)
{
  801eab:	55                   	push   %ebp
  801eac:	89 e5                	mov    %esp,%ebp
  801eae:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801eb1:	6a 01                	push   $0x1
  801eb3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801eb6:	50                   	push   %eax
  801eb7:	6a 00                	push   $0x0
  801eb9:	e8 09 f6 ff ff       	call   8014c7 <read>
	if (r < 0)
  801ebe:	83 c4 10             	add    $0x10,%esp
  801ec1:	85 c0                	test   %eax,%eax
  801ec3:	78 0f                	js     801ed4 <getchar+0x29>
		return r;
	if (r < 1)
  801ec5:	85 c0                	test   %eax,%eax
  801ec7:	7e 06                	jle    801ecf <getchar+0x24>
		return -E_EOF;
	return c;
  801ec9:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801ecd:	eb 05                	jmp    801ed4 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801ecf:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801ed4:	c9                   	leave  
  801ed5:	c3                   	ret    

00801ed6 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801ed6:	55                   	push   %ebp
  801ed7:	89 e5                	mov    %esp,%ebp
  801ed9:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801edc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801edf:	50                   	push   %eax
  801ee0:	ff 75 08             	pushl  0x8(%ebp)
  801ee3:	e8 5e f3 ff ff       	call   801246 <fd_lookup>
  801ee8:	83 c4 10             	add    $0x10,%esp
  801eeb:	85 c0                	test   %eax,%eax
  801eed:	78 11                	js     801f00 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801eef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ef2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ef8:	39 10                	cmp    %edx,(%eax)
  801efa:	0f 94 c0             	sete   %al
  801efd:	0f b6 c0             	movzbl %al,%eax
}
  801f00:	c9                   	leave  
  801f01:	c3                   	ret    

00801f02 <opencons>:

int
opencons(void)
{
  801f02:	55                   	push   %ebp
  801f03:	89 e5                	mov    %esp,%ebp
  801f05:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f08:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f0b:	50                   	push   %eax
  801f0c:	e8 c1 f2 ff ff       	call   8011d2 <fd_alloc>
  801f11:	83 c4 10             	add    $0x10,%esp
  801f14:	85 c0                	test   %eax,%eax
  801f16:	78 3a                	js     801f52 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f18:	83 ec 04             	sub    $0x4,%esp
  801f1b:	68 07 04 00 00       	push   $0x407
  801f20:	ff 75 f4             	pushl  -0xc(%ebp)
  801f23:	6a 00                	push   $0x0
  801f25:	e8 39 ef ff ff       	call   800e63 <sys_page_alloc>
  801f2a:	83 c4 10             	add    $0x10,%esp
  801f2d:	85 c0                	test   %eax,%eax
  801f2f:	78 21                	js     801f52 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f31:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f37:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f3a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f3f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f46:	83 ec 0c             	sub    $0xc,%esp
  801f49:	50                   	push   %eax
  801f4a:	e8 5c f2 ff ff       	call   8011ab <fd2num>
  801f4f:	83 c4 10             	add    $0x10,%esp
}
  801f52:	c9                   	leave  
  801f53:	c3                   	ret    

00801f54 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f54:	55                   	push   %ebp
  801f55:	89 e5                	mov    %esp,%ebp
  801f57:	56                   	push   %esi
  801f58:	53                   	push   %ebx
  801f59:	8b 75 08             	mov    0x8(%ebp),%esi
  801f5c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f5f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");
	int r;
    if (pg != NULL) {
  801f62:	85 c0                	test   %eax,%eax
  801f64:	74 0e                	je     801f74 <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  801f66:	83 ec 0c             	sub    $0xc,%esp
  801f69:	50                   	push   %eax
  801f6a:	e8 a4 f0 ff ff       	call   801013 <sys_ipc_recv>
  801f6f:	83 c4 10             	add    $0x10,%esp
  801f72:	eb 10                	jmp    801f84 <ipc_recv+0x30>
    } else {
        r = sys_ipc_recv((void *) UTOP);
  801f74:	83 ec 0c             	sub    $0xc,%esp
  801f77:	68 00 00 c0 ee       	push   $0xeec00000
  801f7c:	e8 92 f0 ff ff       	call   801013 <sys_ipc_recv>
  801f81:	83 c4 10             	add    $0x10,%esp
    }
    if (r < 0) {
  801f84:	85 c0                	test   %eax,%eax
  801f86:	79 16                	jns    801f9e <ipc_recv+0x4a>
        // failed
        if (from_env_store != NULL) *from_env_store = 0;
  801f88:	85 f6                	test   %esi,%esi
  801f8a:	74 06                	je     801f92 <ipc_recv+0x3e>
  801f8c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL) *perm_store = 0;
  801f92:	85 db                	test   %ebx,%ebx
  801f94:	74 2c                	je     801fc2 <ipc_recv+0x6e>
  801f96:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801f9c:	eb 24                	jmp    801fc2 <ipc_recv+0x6e>
        return r;
    } else {
        if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801f9e:	85 f6                	test   %esi,%esi
  801fa0:	74 0a                	je     801fac <ipc_recv+0x58>
  801fa2:	a1 20 44 80 00       	mov    0x804420,%eax
  801fa7:	8b 40 74             	mov    0x74(%eax),%eax
  801faa:	89 06                	mov    %eax,(%esi)
        if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801fac:	85 db                	test   %ebx,%ebx
  801fae:	74 0a                	je     801fba <ipc_recv+0x66>
  801fb0:	a1 20 44 80 00       	mov    0x804420,%eax
  801fb5:	8b 40 78             	mov    0x78(%eax),%eax
  801fb8:	89 03                	mov    %eax,(%ebx)
        return thisenv->env_ipc_value;
  801fba:	a1 20 44 80 00       	mov    0x804420,%eax
  801fbf:	8b 40 70             	mov    0x70(%eax),%eax
    }
 
	return 0;
}
  801fc2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fc5:	5b                   	pop    %ebx
  801fc6:	5e                   	pop    %esi
  801fc7:	5d                   	pop    %ebp
  801fc8:	c3                   	ret    

00801fc9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fc9:	55                   	push   %ebp
  801fca:	89 e5                	mov    %esp,%ebp
  801fcc:	57                   	push   %edi
  801fcd:	56                   	push   %esi
  801fce:	53                   	push   %ebx
  801fcf:	83 ec 0c             	sub    $0xc,%esp
  801fd2:	8b 75 10             	mov    0x10(%ebp),%esi
  801fd5:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;
    if (pg == NULL) pg = (void *)UTOP;
  801fd8:	85 f6                	test   %esi,%esi
  801fda:	75 05                	jne    801fe1 <ipc_send+0x18>
  801fdc:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
  801fe1:	57                   	push   %edi
  801fe2:	56                   	push   %esi
  801fe3:	ff 75 0c             	pushl  0xc(%ebp)
  801fe6:	ff 75 08             	pushl  0x8(%ebp)
  801fe9:	e8 02 f0 ff ff       	call   800ff0 <sys_ipc_try_send>
  801fee:	89 c3                	mov    %eax,%ebx
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
  801ff0:	83 c4 10             	add    $0x10,%esp
  801ff3:	85 c0                	test   %eax,%eax
  801ff5:	79 17                	jns    80200e <ipc_send+0x45>
  801ff7:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ffa:	74 1d                	je     802019 <ipc_send+0x50>
  801ffc:	50                   	push   %eax
  801ffd:	68 07 28 80 00       	push   $0x802807
  802002:	6a 40                	push   $0x40
  802004:	68 1b 28 80 00       	push   $0x80281b
  802009:	e8 28 e3 ff ff       	call   800336 <_panic>
        sys_yield();
  80200e:	e8 31 ee ff ff       	call   800e44 <sys_yield>
    } while (r != 0);
  802013:	85 db                	test   %ebx,%ebx
  802015:	75 ca                	jne    801fe1 <ipc_send+0x18>
  802017:	eb 07                	jmp    802020 <ipc_send+0x57>
	int r;
    if (pg == NULL) pg = (void *)UTOP;
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
        sys_yield();
  802019:	e8 26 ee ff ff       	call   800e44 <sys_yield>
  80201e:	eb c1                	jmp    801fe1 <ipc_send+0x18>
    } while (r != 0);
}
  802020:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802023:	5b                   	pop    %ebx
  802024:	5e                   	pop    %esi
  802025:	5f                   	pop    %edi
  802026:	5d                   	pop    %ebp
  802027:	c3                   	ret    

00802028 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802028:	55                   	push   %ebp
  802029:	89 e5                	mov    %esp,%ebp
  80202b:	53                   	push   %ebx
  80202c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  80202f:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  802034:	39 c1                	cmp    %eax,%ecx
  802036:	74 21                	je     802059 <ipc_find_env+0x31>
  802038:	ba 01 00 00 00       	mov    $0x1,%edx
  80203d:	8d 1c 95 00 00 00 00 	lea    0x0(,%edx,4),%ebx
  802044:	89 d0                	mov    %edx,%eax
  802046:	c1 e0 07             	shl    $0x7,%eax
  802049:	29 d8                	sub    %ebx,%eax
  80204b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802050:	8b 40 50             	mov    0x50(%eax),%eax
  802053:	39 c8                	cmp    %ecx,%eax
  802055:	75 1b                	jne    802072 <ipc_find_env+0x4a>
  802057:	eb 05                	jmp    80205e <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802059:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_type == type)
			return envs[i].env_id;
  80205e:	8d 04 95 00 00 00 00 	lea    0x0(,%edx,4),%eax
  802065:	c1 e2 07             	shl    $0x7,%edx
  802068:	29 c2                	sub    %eax,%edx
  80206a:	8b 82 48 00 c0 ee    	mov    -0x113fffb8(%edx),%eax
  802070:	eb 0e                	jmp    802080 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802072:	42                   	inc    %edx
  802073:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  802079:	75 c2                	jne    80203d <ipc_find_env+0x15>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80207b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802080:	5b                   	pop    %ebx
  802081:	5d                   	pop    %ebp
  802082:	c3                   	ret    

00802083 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802083:	55                   	push   %ebp
  802084:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802086:	8b 45 08             	mov    0x8(%ebp),%eax
  802089:	c1 e8 16             	shr    $0x16,%eax
  80208c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802093:	a8 01                	test   $0x1,%al
  802095:	74 21                	je     8020b8 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802097:	8b 45 08             	mov    0x8(%ebp),%eax
  80209a:	c1 e8 0c             	shr    $0xc,%eax
  80209d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8020a4:	a8 01                	test   $0x1,%al
  8020a6:	74 17                	je     8020bf <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020a8:	c1 e8 0c             	shr    $0xc,%eax
  8020ab:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8020b2:	ef 
  8020b3:	0f b7 c0             	movzwl %ax,%eax
  8020b6:	eb 0c                	jmp    8020c4 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8020b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8020bd:	eb 05                	jmp    8020c4 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8020bf:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8020c4:	5d                   	pop    %ebp
  8020c5:	c3                   	ret    
  8020c6:	66 90                	xchg   %ax,%ax

008020c8 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8020c8:	55                   	push   %ebp
  8020c9:	57                   	push   %edi
  8020ca:	56                   	push   %esi
  8020cb:	53                   	push   %ebx
  8020cc:	83 ec 1c             	sub    $0x1c,%esp
  8020cf:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8020d3:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8020d7:	8b 7c 24 38          	mov    0x38(%esp),%edi
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8020db:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020df:	89 ca                	mov    %ecx,%edx
  const DWunion dd = {.ll = d};
  8020e1:	89 f8                	mov    %edi,%eax
  8020e3:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8020e7:	85 f6                	test   %esi,%esi
  8020e9:	75 2d                	jne    802118 <__udivdi3+0x50>
    {
      if (d0 > n1)
  8020eb:	39 cf                	cmp    %ecx,%edi
  8020ed:	77 65                	ja     802154 <__udivdi3+0x8c>
  8020ef:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8020f1:	85 ff                	test   %edi,%edi
  8020f3:	75 0b                	jne    802100 <__udivdi3+0x38>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8020f5:	b8 01 00 00 00       	mov    $0x1,%eax
  8020fa:	31 d2                	xor    %edx,%edx
  8020fc:	f7 f7                	div    %edi
  8020fe:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802100:	31 d2                	xor    %edx,%edx
  802102:	89 c8                	mov    %ecx,%eax
  802104:	f7 f5                	div    %ebp
  802106:	89 c1                	mov    %eax,%ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802108:	89 d8                	mov    %ebx,%eax
  80210a:	f7 f5                	div    %ebp
  80210c:	89 cf                	mov    %ecx,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80210e:	89 fa                	mov    %edi,%edx
  802110:	83 c4 1c             	add    $0x1c,%esp
  802113:	5b                   	pop    %ebx
  802114:	5e                   	pop    %esi
  802115:	5f                   	pop    %edi
  802116:	5d                   	pop    %ebp
  802117:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802118:	39 ce                	cmp    %ecx,%esi
  80211a:	77 28                	ja     802144 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80211c:	0f bd fe             	bsr    %esi,%edi
	  if (bm == 0)
  80211f:	83 f7 1f             	xor    $0x1f,%edi
  802122:	75 40                	jne    802164 <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802124:	39 ce                	cmp    %ecx,%esi
  802126:	72 0a                	jb     802132 <__udivdi3+0x6a>
  802128:	3b 44 24 08          	cmp    0x8(%esp),%eax
  80212c:	0f 87 9e 00 00 00    	ja     8021d0 <__udivdi3+0x108>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802132:	b8 01 00 00 00       	mov    $0x1,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802137:	89 fa                	mov    %edi,%edx
  802139:	83 c4 1c             	add    $0x1c,%esp
  80213c:	5b                   	pop    %ebx
  80213d:	5e                   	pop    %esi
  80213e:	5f                   	pop    %edi
  80213f:	5d                   	pop    %ebp
  802140:	c3                   	ret    
  802141:	8d 76 00             	lea    0x0(%esi),%esi
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802144:	31 ff                	xor    %edi,%edi
  802146:	31 c0                	xor    %eax,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802148:	89 fa                	mov    %edi,%edx
  80214a:	83 c4 1c             	add    $0x1c,%esp
  80214d:	5b                   	pop    %ebx
  80214e:	5e                   	pop    %esi
  80214f:	5f                   	pop    %edi
  802150:	5d                   	pop    %ebp
  802151:	c3                   	ret    
  802152:	66 90                	xchg   %ax,%ax
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802154:	89 d8                	mov    %ebx,%eax
  802156:	f7 f7                	div    %edi
  802158:	31 ff                	xor    %edi,%edi
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
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802164:	bd 20 00 00 00       	mov    $0x20,%ebp
  802169:	89 eb                	mov    %ebp,%ebx
  80216b:	29 fb                	sub    %edi,%ebx

	      d1 = (d1 << bm) | (d0 >> b);
  80216d:	89 f9                	mov    %edi,%ecx
  80216f:	d3 e6                	shl    %cl,%esi
  802171:	89 c5                	mov    %eax,%ebp
  802173:	88 d9                	mov    %bl,%cl
  802175:	d3 ed                	shr    %cl,%ebp
  802177:	89 e9                	mov    %ebp,%ecx
  802179:	09 f1                	or     %esi,%ecx
  80217b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
	      d0 = d0 << bm;
  80217f:	89 f9                	mov    %edi,%ecx
  802181:	d3 e0                	shl    %cl,%eax
  802183:	89 c5                	mov    %eax,%ebp
	      n2 = n1 >> b;
  802185:	89 d6                	mov    %edx,%esi
  802187:	88 d9                	mov    %bl,%cl
  802189:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
  80218b:	89 f9                	mov    %edi,%ecx
  80218d:	d3 e2                	shl    %cl,%edx
  80218f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802193:	88 d9                	mov    %bl,%cl
  802195:	d3 e8                	shr    %cl,%eax
  802197:	09 c2                	or     %eax,%edx
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802199:	89 d0                	mov    %edx,%eax
  80219b:	89 f2                	mov    %esi,%edx
  80219d:	f7 74 24 0c          	divl   0xc(%esp)
  8021a1:	89 d6                	mov    %edx,%esi
  8021a3:	89 c3                	mov    %eax,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  8021a5:	f7 e5                	mul    %ebp

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8021a7:	39 d6                	cmp    %edx,%esi
  8021a9:	72 19                	jb     8021c4 <__udivdi3+0xfc>
  8021ab:	74 0b                	je     8021b8 <__udivdi3+0xf0>
  8021ad:	89 d8                	mov    %ebx,%eax
  8021af:	31 ff                	xor    %edi,%edi
  8021b1:	e9 58 ff ff ff       	jmp    80210e <__udivdi3+0x46>
  8021b6:	66 90                	xchg   %ax,%ax
  8021b8:	8b 54 24 08          	mov    0x8(%esp),%edx
  8021bc:	89 f9                	mov    %edi,%ecx
  8021be:	d3 e2                	shl    %cl,%edx
  8021c0:	39 c2                	cmp    %eax,%edx
  8021c2:	73 e9                	jae    8021ad <__udivdi3+0xe5>
  8021c4:	8d 43 ff             	lea    -0x1(%ebx),%eax
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8021c7:	31 ff                	xor    %edi,%edi
  8021c9:	e9 40 ff ff ff       	jmp    80210e <__udivdi3+0x46>
  8021ce:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8021d0:	31 c0                	xor    %eax,%eax
  8021d2:	e9 37 ff ff ff       	jmp    80210e <__udivdi3+0x46>
  8021d7:	90                   	nop

008021d8 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8021d8:	55                   	push   %ebp
  8021d9:	57                   	push   %edi
  8021da:	56                   	push   %esi
  8021db:	53                   	push   %ebx
  8021dc:	83 ec 1c             	sub    $0x1c,%esp
  8021df:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8021e3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021e7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021eb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8021ef:	89 44 24 0c          	mov    %eax,0xc(%esp)
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8021f3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021f7:	89 f3                	mov    %esi,%ebx
  const DWunion dd = {.ll = d};
  8021f9:	89 fa                	mov    %edi,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8021fb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  n1 = nn.s.high;
  8021ff:	89 34 24             	mov    %esi,(%esp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802202:	85 c0                	test   %eax,%eax
  802204:	75 1a                	jne    802220 <__umoddi3+0x48>
    {
      if (d0 > n1)
  802206:	39 f7                	cmp    %esi,%edi
  802208:	0f 86 a2 00 00 00    	jbe    8022b0 <__umoddi3+0xd8>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80220e:	89 c8                	mov    %ecx,%eax
  802210:	89 f2                	mov    %esi,%edx
  802212:	f7 f7                	div    %edi
  802214:	89 d0                	mov    %edx,%eax

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802216:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802218:	83 c4 1c             	add    $0x1c,%esp
  80221b:	5b                   	pop    %ebx
  80221c:	5e                   	pop    %esi
  80221d:	5f                   	pop    %edi
  80221e:	5d                   	pop    %ebp
  80221f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802220:	39 f0                	cmp    %esi,%eax
  802222:	0f 87 ac 00 00 00    	ja     8022d4 <__umoddi3+0xfc>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802228:	0f bd e8             	bsr    %eax,%ebp
	  if (bm == 0)
  80222b:	83 f5 1f             	xor    $0x1f,%ebp
  80222e:	0f 84 ac 00 00 00    	je     8022e0 <__umoddi3+0x108>
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802234:	bf 20 00 00 00       	mov    $0x20,%edi
  802239:	29 ef                	sub    %ebp,%edi
  80223b:	89 fe                	mov    %edi,%esi
  80223d:	89 7c 24 0c          	mov    %edi,0xc(%esp)

	      d1 = (d1 << bm) | (d0 >> b);
  802241:	89 e9                	mov    %ebp,%ecx
  802243:	d3 e0                	shl    %cl,%eax
  802245:	89 d7                	mov    %edx,%edi
  802247:	89 f1                	mov    %esi,%ecx
  802249:	d3 ef                	shr    %cl,%edi
  80224b:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  80224d:	89 e9                	mov    %ebp,%ecx
  80224f:	d3 e2                	shl    %cl,%edx
  802251:	89 14 24             	mov    %edx,(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802254:	89 d8                	mov    %ebx,%eax
  802256:	d3 e0                	shl    %cl,%eax
  802258:	89 c2                	mov    %eax,%edx
	      n0 = n0 << bm;
  80225a:	8b 44 24 08          	mov    0x8(%esp),%eax
  80225e:	d3 e0                	shl    %cl,%eax
  802260:	89 44 24 04          	mov    %eax,0x4(%esp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802264:	8b 44 24 08          	mov    0x8(%esp),%eax
  802268:	89 f1                	mov    %esi,%ecx
  80226a:	d3 e8                	shr    %cl,%eax
  80226c:	09 d0                	or     %edx,%eax
  80226e:	d3 eb                	shr    %cl,%ebx
  802270:	89 da                	mov    %ebx,%edx
  802272:	f7 f7                	div    %edi
  802274:	89 d3                	mov    %edx,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  802276:	f7 24 24             	mull   (%esp)
  802279:	89 c6                	mov    %eax,%esi
  80227b:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80227d:	39 d3                	cmp    %edx,%ebx
  80227f:	0f 82 87 00 00 00    	jb     80230c <__umoddi3+0x134>
  802285:	0f 84 91 00 00 00    	je     80231c <__umoddi3+0x144>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80228b:	8b 54 24 04          	mov    0x4(%esp),%edx
  80228f:	29 f2                	sub    %esi,%edx
  802291:	19 cb                	sbb    %ecx,%ebx
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802293:	89 d8                	mov    %ebx,%eax
  802295:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  802299:	d3 e0                	shl    %cl,%eax
  80229b:	89 e9                	mov    %ebp,%ecx
  80229d:	d3 ea                	shr    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80229f:	09 d0                	or     %edx,%eax
  8022a1:	89 e9                	mov    %ebp,%ecx
  8022a3:	d3 eb                	shr    %cl,%ebx
  8022a5:	89 da                	mov    %ebx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8022a7:	83 c4 1c             	add    $0x1c,%esp
  8022aa:	5b                   	pop    %ebx
  8022ab:	5e                   	pop    %esi
  8022ac:	5f                   	pop    %edi
  8022ad:	5d                   	pop    %ebp
  8022ae:	c3                   	ret    
  8022af:	90                   	nop
  8022b0:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8022b2:	85 ff                	test   %edi,%edi
  8022b4:	75 0b                	jne    8022c1 <__umoddi3+0xe9>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8022b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8022bb:	31 d2                	xor    %edx,%edx
  8022bd:	f7 f7                	div    %edi
  8022bf:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8022c1:	89 f0                	mov    %esi,%eax
  8022c3:	31 d2                	xor    %edx,%edx
  8022c5:	f7 f5                	div    %ebp
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8022c7:	89 c8                	mov    %ecx,%eax
  8022c9:	f7 f5                	div    %ebp
  8022cb:	89 d0                	mov    %edx,%eax
  8022cd:	e9 44 ff ff ff       	jmp    802216 <__umoddi3+0x3e>
  8022d2:	66 90                	xchg   %ax,%ax
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8022d4:	89 c8                	mov    %ecx,%eax
  8022d6:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8022d8:	83 c4 1c             	add    $0x1c,%esp
  8022db:	5b                   	pop    %ebx
  8022dc:	5e                   	pop    %esi
  8022dd:	5f                   	pop    %edi
  8022de:	5d                   	pop    %ebp
  8022df:	c3                   	ret    

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8022e0:	3b 04 24             	cmp    (%esp),%eax
  8022e3:	72 06                	jb     8022eb <__umoddi3+0x113>
  8022e5:	3b 7c 24 04          	cmp    0x4(%esp),%edi
  8022e9:	77 0f                	ja     8022fa <__umoddi3+0x122>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8022eb:	89 f2                	mov    %esi,%edx
  8022ed:	29 f9                	sub    %edi,%ecx
  8022ef:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  8022f3:	89 14 24             	mov    %edx,(%esp)
  8022f6:	89 4c 24 04          	mov    %ecx,0x4(%esp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8022fa:	8b 44 24 04          	mov    0x4(%esp),%eax
  8022fe:	8b 14 24             	mov    (%esp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802301:	83 c4 1c             	add    $0x1c,%esp
  802304:	5b                   	pop    %ebx
  802305:	5e                   	pop    %esi
  802306:	5f                   	pop    %edi
  802307:	5d                   	pop    %ebp
  802308:	c3                   	ret    
  802309:	8d 76 00             	lea    0x0(%esi),%esi
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80230c:	2b 04 24             	sub    (%esp),%eax
  80230f:	19 fa                	sbb    %edi,%edx
  802311:	89 d1                	mov    %edx,%ecx
  802313:	89 c6                	mov    %eax,%esi
  802315:	e9 71 ff ff ff       	jmp    80228b <__umoddi3+0xb3>
  80231a:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80231c:	39 44 24 04          	cmp    %eax,0x4(%esp)
  802320:	72 ea                	jb     80230c <__umoddi3+0x134>
  802322:	89 d9                	mov    %ebx,%ecx
  802324:	e9 62 ff ff ff       	jmp    80228b <__umoddi3+0xb3>
