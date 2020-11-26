
obj/user/echo.debug:     file format elf32-i386


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
  80002c:	e8 a9 00 00 00       	call   8000da <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
  80003c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80003f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int i, nflag;

	nflag = 0;
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
  800042:	83 ff 01             	cmp    $0x1,%edi
  800045:	7e 77                	jle    8000be <umain+0x8b>
  800047:	83 ec 08             	sub    $0x8,%esp
  80004a:	68 e0 1e 80 00       	push   $0x801ee0
  80004f:	ff 76 04             	pushl  0x4(%esi)
  800052:	e8 f3 01 00 00       	call   80024a <strcmp>
  800057:	83 c4 10             	add    $0x10,%esp
  80005a:	85 c0                	test   %eax,%eax
  80005c:	75 12                	jne    800070 <umain+0x3d>
		nflag = 1;
		argc--;
  80005e:	4f                   	dec    %edi
		argv++;
  80005f:	83 c6 04             	add    $0x4,%esi
	}
	for (i = 1; i < argc; i++) {
  800062:	83 ff 01             	cmp    $0x1,%edi
  800065:	7e 6b                	jle    8000d2 <umain+0x9f>
{
	int i, nflag;

	nflag = 0;
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
		nflag = 1;
  800067:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
  80006e:	eb 07                	jmp    800077 <umain+0x44>
void
umain(int argc, char **argv)
{
	int i, nflag;

	nflag = 0;
  800070:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800077:	bb 01 00 00 00       	mov    $0x1,%ebx
  80007c:	eb 19                	jmp    800097 <umain+0x64>
		nflag = 1;
		argc--;
		argv++;
	}
	for (i = 1; i < argc; i++) {
		if (i > 1)
  80007e:	83 fb 01             	cmp    $0x1,%ebx
  800081:	7e 14                	jle    800097 <umain+0x64>
			write(1, " ", 1);
  800083:	83 ec 04             	sub    $0x4,%esp
  800086:	6a 01                	push   $0x1
  800088:	68 e3 1e 80 00       	push   $0x801ee3
  80008d:	6a 01                	push   $0x1
  80008f:	e8 5f 0b 00 00       	call   800bf3 <write>
  800094:	83 c4 10             	add    $0x10,%esp
		write(1, argv[i], strlen(argv[i]));
  800097:	83 ec 0c             	sub    $0xc,%esp
  80009a:	ff 34 9e             	pushl  (%esi,%ebx,4)
  80009d:	e8 a1 00 00 00       	call   800143 <strlen>
  8000a2:	83 c4 0c             	add    $0xc,%esp
  8000a5:	50                   	push   %eax
  8000a6:	ff 34 9e             	pushl  (%esi,%ebx,4)
  8000a9:	6a 01                	push   $0x1
  8000ab:	e8 43 0b 00 00       	call   800bf3 <write>
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
		nflag = 1;
		argc--;
		argv++;
	}
	for (i = 1; i < argc; i++) {
  8000b0:	43                   	inc    %ebx
  8000b1:	83 c4 10             	add    $0x10,%esp
  8000b4:	39 fb                	cmp    %edi,%ebx
  8000b6:	7c c6                	jl     80007e <umain+0x4b>
		if (i > 1)
			write(1, " ", 1);
		write(1, argv[i], strlen(argv[i]));
	}
	if (!nflag)
  8000b8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000bc:	75 14                	jne    8000d2 <umain+0x9f>
		write(1, "\n", 1);
  8000be:	83 ec 04             	sub    $0x4,%esp
  8000c1:	6a 01                	push   $0x1
  8000c3:	68 e1 1f 80 00       	push   $0x801fe1
  8000c8:	6a 01                	push   $0x1
  8000ca:	e8 24 0b 00 00       	call   800bf3 <write>
  8000cf:	83 c4 10             	add    $0x10,%esp
}
  8000d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000d5:	5b                   	pop    %ebx
  8000d6:	5e                   	pop    %esi
  8000d7:	5f                   	pop    %edi
  8000d8:	5d                   	pop    %ebp
  8000d9:	c3                   	ret    

008000da <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000da:	55                   	push   %ebp
  8000db:	89 e5                	mov    %esp,%ebp
  8000dd:	56                   	push   %esi
  8000de:	53                   	push   %ebx
  8000df:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000e2:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000e5:	e8 e2 04 00 00       	call   8005cc <sys_getenvid>
  8000ea:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ef:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000f6:	c1 e0 07             	shl    $0x7,%eax
  8000f9:	29 d0                	sub    %edx,%eax
  8000fb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800100:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800105:	85 db                	test   %ebx,%ebx
  800107:	7e 07                	jle    800110 <libmain+0x36>
		binaryname = argv[0];
  800109:	8b 06                	mov    (%esi),%eax
  80010b:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800110:	83 ec 08             	sub    $0x8,%esp
  800113:	56                   	push   %esi
  800114:	53                   	push   %ebx
  800115:	e8 19 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80011a:	e8 0a 00 00 00       	call   800129 <exit>
}
  80011f:	83 c4 10             	add    $0x10,%esp
  800122:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800125:	5b                   	pop    %ebx
  800126:	5e                   	pop    %esi
  800127:	5d                   	pop    %ebp
  800128:	c3                   	ret    

00800129 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800129:	55                   	push   %ebp
  80012a:	89 e5                	mov    %esp,%ebp
  80012c:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80012f:	e8 d6 08 00 00       	call   800a0a <close_all>
	sys_env_destroy(0);
  800134:	83 ec 0c             	sub    $0xc,%esp
  800137:	6a 00                	push   $0x0
  800139:	e8 4d 04 00 00       	call   80058b <sys_env_destroy>
}
  80013e:	83 c4 10             	add    $0x10,%esp
  800141:	c9                   	leave  
  800142:	c3                   	ret    

00800143 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800149:	80 3a 00             	cmpb   $0x0,(%edx)
  80014c:	74 0e                	je     80015c <strlen+0x19>
  80014e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800153:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800154:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800158:	75 f9                	jne    800153 <strlen+0x10>
  80015a:	eb 05                	jmp    800161 <strlen+0x1e>
  80015c:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800161:	5d                   	pop    %ebp
  800162:	c3                   	ret    

00800163 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	53                   	push   %ebx
  800167:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80016a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80016d:	85 c9                	test   %ecx,%ecx
  80016f:	74 1a                	je     80018b <strnlen+0x28>
  800171:	80 3b 00             	cmpb   $0x0,(%ebx)
  800174:	74 1c                	je     800192 <strnlen+0x2f>
  800176:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  80017b:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80017d:	39 ca                	cmp    %ecx,%edx
  80017f:	74 16                	je     800197 <strnlen+0x34>
  800181:	42                   	inc    %edx
  800182:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800187:	75 f2                	jne    80017b <strnlen+0x18>
  800189:	eb 0c                	jmp    800197 <strnlen+0x34>
  80018b:	b8 00 00 00 00       	mov    $0x0,%eax
  800190:	eb 05                	jmp    800197 <strnlen+0x34>
  800192:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800197:	5b                   	pop    %ebx
  800198:	5d                   	pop    %ebp
  800199:	c3                   	ret    

0080019a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80019a:	55                   	push   %ebp
  80019b:	89 e5                	mov    %esp,%ebp
  80019d:	53                   	push   %ebx
  80019e:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8001a4:	89 c2                	mov    %eax,%edx
  8001a6:	42                   	inc    %edx
  8001a7:	41                   	inc    %ecx
  8001a8:	8a 59 ff             	mov    -0x1(%ecx),%bl
  8001ab:	88 5a ff             	mov    %bl,-0x1(%edx)
  8001ae:	84 db                	test   %bl,%bl
  8001b0:	75 f4                	jne    8001a6 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8001b2:	5b                   	pop    %ebx
  8001b3:	5d                   	pop    %ebp
  8001b4:	c3                   	ret    

008001b5 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8001b5:	55                   	push   %ebp
  8001b6:	89 e5                	mov    %esp,%ebp
  8001b8:	53                   	push   %ebx
  8001b9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8001bc:	53                   	push   %ebx
  8001bd:	e8 81 ff ff ff       	call   800143 <strlen>
  8001c2:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8001c5:	ff 75 0c             	pushl  0xc(%ebp)
  8001c8:	01 d8                	add    %ebx,%eax
  8001ca:	50                   	push   %eax
  8001cb:	e8 ca ff ff ff       	call   80019a <strcpy>
	return dst;
}
  8001d0:	89 d8                	mov    %ebx,%eax
  8001d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001d5:	c9                   	leave  
  8001d6:	c3                   	ret    

008001d7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8001d7:	55                   	push   %ebp
  8001d8:	89 e5                	mov    %esp,%ebp
  8001da:	56                   	push   %esi
  8001db:	53                   	push   %ebx
  8001dc:	8b 75 08             	mov    0x8(%ebp),%esi
  8001df:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001e2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8001e5:	85 db                	test   %ebx,%ebx
  8001e7:	74 14                	je     8001fd <strncpy+0x26>
  8001e9:	01 f3                	add    %esi,%ebx
  8001eb:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  8001ed:	41                   	inc    %ecx
  8001ee:	8a 02                	mov    (%edx),%al
  8001f0:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8001f3:	80 3a 01             	cmpb   $0x1,(%edx)
  8001f6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8001f9:	39 cb                	cmp    %ecx,%ebx
  8001fb:	75 f0                	jne    8001ed <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8001fd:	89 f0                	mov    %esi,%eax
  8001ff:	5b                   	pop    %ebx
  800200:	5e                   	pop    %esi
  800201:	5d                   	pop    %ebp
  800202:	c3                   	ret    

00800203 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800203:	55                   	push   %ebp
  800204:	89 e5                	mov    %esp,%ebp
  800206:	53                   	push   %ebx
  800207:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80020a:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80020d:	85 c0                	test   %eax,%eax
  80020f:	74 30                	je     800241 <strlcpy+0x3e>
		while (--size > 0 && *src != '\0')
  800211:	48                   	dec    %eax
  800212:	74 20                	je     800234 <strlcpy+0x31>
  800214:	8a 0b                	mov    (%ebx),%cl
  800216:	84 c9                	test   %cl,%cl
  800218:	74 1f                	je     800239 <strlcpy+0x36>
  80021a:	8d 53 01             	lea    0x1(%ebx),%edx
  80021d:	01 c3                	add    %eax,%ebx
  80021f:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
  800222:	40                   	inc    %eax
  800223:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800226:	39 da                	cmp    %ebx,%edx
  800228:	74 12                	je     80023c <strlcpy+0x39>
  80022a:	42                   	inc    %edx
  80022b:	8a 4a ff             	mov    -0x1(%edx),%cl
  80022e:	84 c9                	test   %cl,%cl
  800230:	75 f0                	jne    800222 <strlcpy+0x1f>
  800232:	eb 08                	jmp    80023c <strlcpy+0x39>
  800234:	8b 45 08             	mov    0x8(%ebp),%eax
  800237:	eb 03                	jmp    80023c <strlcpy+0x39>
  800239:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
		*dst = '\0';
  80023c:	c6 00 00             	movb   $0x0,(%eax)
  80023f:	eb 03                	jmp    800244 <strlcpy+0x41>
  800241:	8b 45 08             	mov    0x8(%ebp),%eax
	}
	return dst - dst_in;
  800244:	2b 45 08             	sub    0x8(%ebp),%eax
}
  800247:	5b                   	pop    %ebx
  800248:	5d                   	pop    %ebp
  800249:	c3                   	ret    

0080024a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80024a:	55                   	push   %ebp
  80024b:	89 e5                	mov    %esp,%ebp
  80024d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800250:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800253:	8a 01                	mov    (%ecx),%al
  800255:	84 c0                	test   %al,%al
  800257:	74 10                	je     800269 <strcmp+0x1f>
  800259:	3a 02                	cmp    (%edx),%al
  80025b:	75 0c                	jne    800269 <strcmp+0x1f>
		p++, q++;
  80025d:	41                   	inc    %ecx
  80025e:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80025f:	8a 01                	mov    (%ecx),%al
  800261:	84 c0                	test   %al,%al
  800263:	74 04                	je     800269 <strcmp+0x1f>
  800265:	3a 02                	cmp    (%edx),%al
  800267:	74 f4                	je     80025d <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800269:	0f b6 c0             	movzbl %al,%eax
  80026c:	0f b6 12             	movzbl (%edx),%edx
  80026f:	29 d0                	sub    %edx,%eax
}
  800271:	5d                   	pop    %ebp
  800272:	c3                   	ret    

00800273 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800273:	55                   	push   %ebp
  800274:	89 e5                	mov    %esp,%ebp
  800276:	56                   	push   %esi
  800277:	53                   	push   %ebx
  800278:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80027b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80027e:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800281:	85 f6                	test   %esi,%esi
  800283:	74 23                	je     8002a8 <strncmp+0x35>
  800285:	8a 03                	mov    (%ebx),%al
  800287:	84 c0                	test   %al,%al
  800289:	74 2b                	je     8002b6 <strncmp+0x43>
  80028b:	3a 02                	cmp    (%edx),%al
  80028d:	75 27                	jne    8002b6 <strncmp+0x43>
  80028f:	8d 43 01             	lea    0x1(%ebx),%eax
  800292:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800294:	89 c3                	mov    %eax,%ebx
  800296:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800297:	39 c6                	cmp    %eax,%esi
  800299:	74 14                	je     8002af <strncmp+0x3c>
  80029b:	8a 08                	mov    (%eax),%cl
  80029d:	84 c9                	test   %cl,%cl
  80029f:	74 15                	je     8002b6 <strncmp+0x43>
  8002a1:	40                   	inc    %eax
  8002a2:	3a 0a                	cmp    (%edx),%cl
  8002a4:	74 ee                	je     800294 <strncmp+0x21>
  8002a6:	eb 0e                	jmp    8002b6 <strncmp+0x43>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8002a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8002ad:	eb 0f                	jmp    8002be <strncmp+0x4b>
  8002af:	b8 00 00 00 00       	mov    $0x0,%eax
  8002b4:	eb 08                	jmp    8002be <strncmp+0x4b>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8002b6:	0f b6 03             	movzbl (%ebx),%eax
  8002b9:	0f b6 12             	movzbl (%edx),%edx
  8002bc:	29 d0                	sub    %edx,%eax
}
  8002be:	5b                   	pop    %ebx
  8002bf:	5e                   	pop    %esi
  8002c0:	5d                   	pop    %ebp
  8002c1:	c3                   	ret    

008002c2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8002c2:	55                   	push   %ebp
  8002c3:	89 e5                	mov    %esp,%ebp
  8002c5:	53                   	push   %ebx
  8002c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  8002cc:	8a 10                	mov    (%eax),%dl
  8002ce:	84 d2                	test   %dl,%dl
  8002d0:	74 1a                	je     8002ec <strchr+0x2a>
  8002d2:	88 d9                	mov    %bl,%cl
		if (*s == c)
  8002d4:	38 d3                	cmp    %dl,%bl
  8002d6:	75 06                	jne    8002de <strchr+0x1c>
  8002d8:	eb 17                	jmp    8002f1 <strchr+0x2f>
  8002da:	38 ca                	cmp    %cl,%dl
  8002dc:	74 13                	je     8002f1 <strchr+0x2f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8002de:	40                   	inc    %eax
  8002df:	8a 10                	mov    (%eax),%dl
  8002e1:	84 d2                	test   %dl,%dl
  8002e3:	75 f5                	jne    8002da <strchr+0x18>
		if (*s == c)
			return (char *) s;
	return 0;
  8002e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8002ea:	eb 05                	jmp    8002f1 <strchr+0x2f>
  8002ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8002f1:	5b                   	pop    %ebx
  8002f2:	5d                   	pop    %ebp
  8002f3:	c3                   	ret    

008002f4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8002f4:	55                   	push   %ebp
  8002f5:	89 e5                	mov    %esp,%ebp
  8002f7:	53                   	push   %ebx
  8002f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8002fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  8002fe:	8a 10                	mov    (%eax),%dl
  800300:	84 d2                	test   %dl,%dl
  800302:	74 13                	je     800317 <strfind+0x23>
  800304:	88 d9                	mov    %bl,%cl
		if (*s == c)
  800306:	38 d3                	cmp    %dl,%bl
  800308:	75 06                	jne    800310 <strfind+0x1c>
  80030a:	eb 0b                	jmp    800317 <strfind+0x23>
  80030c:	38 ca                	cmp    %cl,%dl
  80030e:	74 07                	je     800317 <strfind+0x23>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800310:	40                   	inc    %eax
  800311:	8a 10                	mov    (%eax),%dl
  800313:	84 d2                	test   %dl,%dl
  800315:	75 f5                	jne    80030c <strfind+0x18>
		if (*s == c)
			break;
	return (char *) s;
}
  800317:	5b                   	pop    %ebx
  800318:	5d                   	pop    %ebp
  800319:	c3                   	ret    

0080031a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80031a:	55                   	push   %ebp
  80031b:	89 e5                	mov    %esp,%ebp
  80031d:	57                   	push   %edi
  80031e:	56                   	push   %esi
  80031f:	53                   	push   %ebx
  800320:	8b 7d 08             	mov    0x8(%ebp),%edi
  800323:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800326:	85 c9                	test   %ecx,%ecx
  800328:	74 36                	je     800360 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80032a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800330:	75 28                	jne    80035a <memset+0x40>
  800332:	f6 c1 03             	test   $0x3,%cl
  800335:	75 23                	jne    80035a <memset+0x40>
		c &= 0xFF;
  800337:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80033b:	89 d3                	mov    %edx,%ebx
  80033d:	c1 e3 08             	shl    $0x8,%ebx
  800340:	89 d6                	mov    %edx,%esi
  800342:	c1 e6 18             	shl    $0x18,%esi
  800345:	89 d0                	mov    %edx,%eax
  800347:	c1 e0 10             	shl    $0x10,%eax
  80034a:	09 f0                	or     %esi,%eax
  80034c:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80034e:	89 d8                	mov    %ebx,%eax
  800350:	09 d0                	or     %edx,%eax
  800352:	c1 e9 02             	shr    $0x2,%ecx
  800355:	fc                   	cld    
  800356:	f3 ab                	rep stos %eax,%es:(%edi)
  800358:	eb 06                	jmp    800360 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80035a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80035d:	fc                   	cld    
  80035e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800360:	89 f8                	mov    %edi,%eax
  800362:	5b                   	pop    %ebx
  800363:	5e                   	pop    %esi
  800364:	5f                   	pop    %edi
  800365:	5d                   	pop    %ebp
  800366:	c3                   	ret    

00800367 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800367:	55                   	push   %ebp
  800368:	89 e5                	mov    %esp,%ebp
  80036a:	57                   	push   %edi
  80036b:	56                   	push   %esi
  80036c:	8b 45 08             	mov    0x8(%ebp),%eax
  80036f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800372:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800375:	39 c6                	cmp    %eax,%esi
  800377:	73 33                	jae    8003ac <memmove+0x45>
  800379:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80037c:	39 d0                	cmp    %edx,%eax
  80037e:	73 2c                	jae    8003ac <memmove+0x45>
		s += n;
		d += n;
  800380:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800383:	89 d6                	mov    %edx,%esi
  800385:	09 fe                	or     %edi,%esi
  800387:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80038d:	75 13                	jne    8003a2 <memmove+0x3b>
  80038f:	f6 c1 03             	test   $0x3,%cl
  800392:	75 0e                	jne    8003a2 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800394:	83 ef 04             	sub    $0x4,%edi
  800397:	8d 72 fc             	lea    -0x4(%edx),%esi
  80039a:	c1 e9 02             	shr    $0x2,%ecx
  80039d:	fd                   	std    
  80039e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8003a0:	eb 07                	jmp    8003a9 <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8003a2:	4f                   	dec    %edi
  8003a3:	8d 72 ff             	lea    -0x1(%edx),%esi
  8003a6:	fd                   	std    
  8003a7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8003a9:	fc                   	cld    
  8003aa:	eb 1d                	jmp    8003c9 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8003ac:	89 f2                	mov    %esi,%edx
  8003ae:	09 c2                	or     %eax,%edx
  8003b0:	f6 c2 03             	test   $0x3,%dl
  8003b3:	75 0f                	jne    8003c4 <memmove+0x5d>
  8003b5:	f6 c1 03             	test   $0x3,%cl
  8003b8:	75 0a                	jne    8003c4 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
  8003ba:	c1 e9 02             	shr    $0x2,%ecx
  8003bd:	89 c7                	mov    %eax,%edi
  8003bf:	fc                   	cld    
  8003c0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8003c2:	eb 05                	jmp    8003c9 <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8003c4:	89 c7                	mov    %eax,%edi
  8003c6:	fc                   	cld    
  8003c7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8003c9:	5e                   	pop    %esi
  8003ca:	5f                   	pop    %edi
  8003cb:	5d                   	pop    %ebp
  8003cc:	c3                   	ret    

008003cd <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8003cd:	55                   	push   %ebp
  8003ce:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8003d0:	ff 75 10             	pushl  0x10(%ebp)
  8003d3:	ff 75 0c             	pushl  0xc(%ebp)
  8003d6:	ff 75 08             	pushl  0x8(%ebp)
  8003d9:	e8 89 ff ff ff       	call   800367 <memmove>
}
  8003de:	c9                   	leave  
  8003df:	c3                   	ret    

008003e0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8003e0:	55                   	push   %ebp
  8003e1:	89 e5                	mov    %esp,%ebp
  8003e3:	57                   	push   %edi
  8003e4:	56                   	push   %esi
  8003e5:	53                   	push   %ebx
  8003e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8003e9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8003ec:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8003ef:	85 c0                	test   %eax,%eax
  8003f1:	74 33                	je     800426 <memcmp+0x46>
  8003f3:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  8003f6:	8a 13                	mov    (%ebx),%dl
  8003f8:	8a 0e                	mov    (%esi),%cl
  8003fa:	38 ca                	cmp    %cl,%dl
  8003fc:	75 13                	jne    800411 <memcmp+0x31>
  8003fe:	b8 00 00 00 00       	mov    $0x0,%eax
  800403:	eb 16                	jmp    80041b <memcmp+0x3b>
  800405:	8a 54 03 01          	mov    0x1(%ebx,%eax,1),%dl
  800409:	40                   	inc    %eax
  80040a:	8a 0c 06             	mov    (%esi,%eax,1),%cl
  80040d:	38 ca                	cmp    %cl,%dl
  80040f:	74 0a                	je     80041b <memcmp+0x3b>
			return (int) *s1 - (int) *s2;
  800411:	0f b6 c2             	movzbl %dl,%eax
  800414:	0f b6 c9             	movzbl %cl,%ecx
  800417:	29 c8                	sub    %ecx,%eax
  800419:	eb 10                	jmp    80042b <memcmp+0x4b>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80041b:	39 f8                	cmp    %edi,%eax
  80041d:	75 e6                	jne    800405 <memcmp+0x25>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80041f:	b8 00 00 00 00       	mov    $0x0,%eax
  800424:	eb 05                	jmp    80042b <memcmp+0x4b>
  800426:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80042b:	5b                   	pop    %ebx
  80042c:	5e                   	pop    %esi
  80042d:	5f                   	pop    %edi
  80042e:	5d                   	pop    %ebp
  80042f:	c3                   	ret    

00800430 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800430:	55                   	push   %ebp
  800431:	89 e5                	mov    %esp,%ebp
  800433:	53                   	push   %ebx
  800434:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800437:	89 d0                	mov    %edx,%eax
  800439:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  80043c:	39 c2                	cmp    %eax,%edx
  80043e:	73 1b                	jae    80045b <memfind+0x2b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800440:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800444:	0f b6 0a             	movzbl (%edx),%ecx
  800447:	39 d9                	cmp    %ebx,%ecx
  800449:	75 09                	jne    800454 <memfind+0x24>
  80044b:	eb 12                	jmp    80045f <memfind+0x2f>
  80044d:	0f b6 0a             	movzbl (%edx),%ecx
  800450:	39 d9                	cmp    %ebx,%ecx
  800452:	74 0f                	je     800463 <memfind+0x33>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800454:	42                   	inc    %edx
  800455:	39 d0                	cmp    %edx,%eax
  800457:	75 f4                	jne    80044d <memfind+0x1d>
  800459:	eb 0a                	jmp    800465 <memfind+0x35>
  80045b:	89 d0                	mov    %edx,%eax
  80045d:	eb 06                	jmp    800465 <memfind+0x35>
		if (*(const unsigned char *) s == (unsigned char) c)
  80045f:	89 d0                	mov    %edx,%eax
  800461:	eb 02                	jmp    800465 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800463:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800465:	5b                   	pop    %ebx
  800466:	5d                   	pop    %ebp
  800467:	c3                   	ret    

00800468 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800468:	55                   	push   %ebp
  800469:	89 e5                	mov    %esp,%ebp
  80046b:	57                   	push   %edi
  80046c:	56                   	push   %esi
  80046d:	53                   	push   %ebx
  80046e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800471:	eb 01                	jmp    800474 <strtol+0xc>
		s++;
  800473:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800474:	8a 01                	mov    (%ecx),%al
  800476:	3c 20                	cmp    $0x20,%al
  800478:	74 f9                	je     800473 <strtol+0xb>
  80047a:	3c 09                	cmp    $0x9,%al
  80047c:	74 f5                	je     800473 <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  80047e:	3c 2b                	cmp    $0x2b,%al
  800480:	75 08                	jne    80048a <strtol+0x22>
		s++;
  800482:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800483:	bf 00 00 00 00       	mov    $0x0,%edi
  800488:	eb 11                	jmp    80049b <strtol+0x33>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80048a:	3c 2d                	cmp    $0x2d,%al
  80048c:	75 08                	jne    800496 <strtol+0x2e>
		s++, neg = 1;
  80048e:	41                   	inc    %ecx
  80048f:	bf 01 00 00 00       	mov    $0x1,%edi
  800494:	eb 05                	jmp    80049b <strtol+0x33>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800496:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80049b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80049f:	0f 84 87 00 00 00    	je     80052c <strtol+0xc4>
  8004a5:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  8004a9:	75 27                	jne    8004d2 <strtol+0x6a>
  8004ab:	80 39 30             	cmpb   $0x30,(%ecx)
  8004ae:	75 22                	jne    8004d2 <strtol+0x6a>
  8004b0:	e9 88 00 00 00       	jmp    80053d <strtol+0xd5>
		s += 2, base = 16;
  8004b5:	83 c1 02             	add    $0x2,%ecx
  8004b8:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  8004bf:	eb 11                	jmp    8004d2 <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
  8004c1:	41                   	inc    %ecx
  8004c2:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  8004c9:	eb 07                	jmp    8004d2 <strtol+0x6a>
	else if (base == 0)
		base = 10;
  8004cb:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  8004d2:	b8 00 00 00 00       	mov    $0x0,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8004d7:	8a 11                	mov    (%ecx),%dl
  8004d9:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8004dc:	80 fb 09             	cmp    $0x9,%bl
  8004df:	77 08                	ja     8004e9 <strtol+0x81>
			dig = *s - '0';
  8004e1:	0f be d2             	movsbl %dl,%edx
  8004e4:	83 ea 30             	sub    $0x30,%edx
  8004e7:	eb 22                	jmp    80050b <strtol+0xa3>
		else if (*s >= 'a' && *s <= 'z')
  8004e9:	8d 72 9f             	lea    -0x61(%edx),%esi
  8004ec:	89 f3                	mov    %esi,%ebx
  8004ee:	80 fb 19             	cmp    $0x19,%bl
  8004f1:	77 08                	ja     8004fb <strtol+0x93>
			dig = *s - 'a' + 10;
  8004f3:	0f be d2             	movsbl %dl,%edx
  8004f6:	83 ea 57             	sub    $0x57,%edx
  8004f9:	eb 10                	jmp    80050b <strtol+0xa3>
		else if (*s >= 'A' && *s <= 'Z')
  8004fb:	8d 72 bf             	lea    -0x41(%edx),%esi
  8004fe:	89 f3                	mov    %esi,%ebx
  800500:	80 fb 19             	cmp    $0x19,%bl
  800503:	77 14                	ja     800519 <strtol+0xb1>
			dig = *s - 'A' + 10;
  800505:	0f be d2             	movsbl %dl,%edx
  800508:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  80050b:	3b 55 10             	cmp    0x10(%ebp),%edx
  80050e:	7d 09                	jge    800519 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800510:	41                   	inc    %ecx
  800511:	0f af 45 10          	imul   0x10(%ebp),%eax
  800515:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800517:	eb be                	jmp    8004d7 <strtol+0x6f>

	if (endptr)
  800519:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80051d:	74 05                	je     800524 <strtol+0xbc>
		*endptr = (char *) s;
  80051f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800522:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800524:	85 ff                	test   %edi,%edi
  800526:	74 21                	je     800549 <strtol+0xe1>
  800528:	f7 d8                	neg    %eax
  80052a:	eb 1d                	jmp    800549 <strtol+0xe1>
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80052c:	80 39 30             	cmpb   $0x30,(%ecx)
  80052f:	75 9a                	jne    8004cb <strtol+0x63>
  800531:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800535:	0f 84 7a ff ff ff    	je     8004b5 <strtol+0x4d>
  80053b:	eb 84                	jmp    8004c1 <strtol+0x59>
  80053d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800541:	0f 84 6e ff ff ff    	je     8004b5 <strtol+0x4d>
  800547:	eb 89                	jmp    8004d2 <strtol+0x6a>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  800549:	5b                   	pop    %ebx
  80054a:	5e                   	pop    %esi
  80054b:	5f                   	pop    %edi
  80054c:	5d                   	pop    %ebp
  80054d:	c3                   	ret    

0080054e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80054e:	55                   	push   %ebp
  80054f:	89 e5                	mov    %esp,%ebp
  800551:	57                   	push   %edi
  800552:	56                   	push   %esi
  800553:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800554:	b8 00 00 00 00       	mov    $0x0,%eax
  800559:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80055c:	8b 55 08             	mov    0x8(%ebp),%edx
  80055f:	89 c3                	mov    %eax,%ebx
  800561:	89 c7                	mov    %eax,%edi
  800563:	89 c6                	mov    %eax,%esi
  800565:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800567:	5b                   	pop    %ebx
  800568:	5e                   	pop    %esi
  800569:	5f                   	pop    %edi
  80056a:	5d                   	pop    %ebp
  80056b:	c3                   	ret    

0080056c <sys_cgetc>:

int
sys_cgetc(void)
{
  80056c:	55                   	push   %ebp
  80056d:	89 e5                	mov    %esp,%ebp
  80056f:	57                   	push   %edi
  800570:	56                   	push   %esi
  800571:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800572:	ba 00 00 00 00       	mov    $0x0,%edx
  800577:	b8 01 00 00 00       	mov    $0x1,%eax
  80057c:	89 d1                	mov    %edx,%ecx
  80057e:	89 d3                	mov    %edx,%ebx
  800580:	89 d7                	mov    %edx,%edi
  800582:	89 d6                	mov    %edx,%esi
  800584:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800586:	5b                   	pop    %ebx
  800587:	5e                   	pop    %esi
  800588:	5f                   	pop    %edi
  800589:	5d                   	pop    %ebp
  80058a:	c3                   	ret    

0080058b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80058b:	55                   	push   %ebp
  80058c:	89 e5                	mov    %esp,%ebp
  80058e:	57                   	push   %edi
  80058f:	56                   	push   %esi
  800590:	53                   	push   %ebx
  800591:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800594:	b9 00 00 00 00       	mov    $0x0,%ecx
  800599:	b8 03 00 00 00       	mov    $0x3,%eax
  80059e:	8b 55 08             	mov    0x8(%ebp),%edx
  8005a1:	89 cb                	mov    %ecx,%ebx
  8005a3:	89 cf                	mov    %ecx,%edi
  8005a5:	89 ce                	mov    %ecx,%esi
  8005a7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8005a9:	85 c0                	test   %eax,%eax
  8005ab:	7e 17                	jle    8005c4 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8005ad:	83 ec 0c             	sub    $0xc,%esp
  8005b0:	50                   	push   %eax
  8005b1:	6a 03                	push   $0x3
  8005b3:	68 ef 1e 80 00       	push   $0x801eef
  8005b8:	6a 23                	push   $0x23
  8005ba:	68 0c 1f 80 00       	push   $0x801f0c
  8005bf:	e8 cf 0e 00 00       	call   801493 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8005c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005c7:	5b                   	pop    %ebx
  8005c8:	5e                   	pop    %esi
  8005c9:	5f                   	pop    %edi
  8005ca:	5d                   	pop    %ebp
  8005cb:	c3                   	ret    

008005cc <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8005cc:	55                   	push   %ebp
  8005cd:	89 e5                	mov    %esp,%ebp
  8005cf:	57                   	push   %edi
  8005d0:	56                   	push   %esi
  8005d1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8005d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8005d7:	b8 02 00 00 00       	mov    $0x2,%eax
  8005dc:	89 d1                	mov    %edx,%ecx
  8005de:	89 d3                	mov    %edx,%ebx
  8005e0:	89 d7                	mov    %edx,%edi
  8005e2:	89 d6                	mov    %edx,%esi
  8005e4:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8005e6:	5b                   	pop    %ebx
  8005e7:	5e                   	pop    %esi
  8005e8:	5f                   	pop    %edi
  8005e9:	5d                   	pop    %ebp
  8005ea:	c3                   	ret    

008005eb <sys_yield>:

void
sys_yield(void)
{
  8005eb:	55                   	push   %ebp
  8005ec:	89 e5                	mov    %esp,%ebp
  8005ee:	57                   	push   %edi
  8005ef:	56                   	push   %esi
  8005f0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8005f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8005f6:	b8 0b 00 00 00       	mov    $0xb,%eax
  8005fb:	89 d1                	mov    %edx,%ecx
  8005fd:	89 d3                	mov    %edx,%ebx
  8005ff:	89 d7                	mov    %edx,%edi
  800601:	89 d6                	mov    %edx,%esi
  800603:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800605:	5b                   	pop    %ebx
  800606:	5e                   	pop    %esi
  800607:	5f                   	pop    %edi
  800608:	5d                   	pop    %ebp
  800609:	c3                   	ret    

0080060a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80060a:	55                   	push   %ebp
  80060b:	89 e5                	mov    %esp,%ebp
  80060d:	57                   	push   %edi
  80060e:	56                   	push   %esi
  80060f:	53                   	push   %ebx
  800610:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800613:	be 00 00 00 00       	mov    $0x0,%esi
  800618:	b8 04 00 00 00       	mov    $0x4,%eax
  80061d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800620:	8b 55 08             	mov    0x8(%ebp),%edx
  800623:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800626:	89 f7                	mov    %esi,%edi
  800628:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80062a:	85 c0                	test   %eax,%eax
  80062c:	7e 17                	jle    800645 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80062e:	83 ec 0c             	sub    $0xc,%esp
  800631:	50                   	push   %eax
  800632:	6a 04                	push   $0x4
  800634:	68 ef 1e 80 00       	push   $0x801eef
  800639:	6a 23                	push   $0x23
  80063b:	68 0c 1f 80 00       	push   $0x801f0c
  800640:	e8 4e 0e 00 00       	call   801493 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800645:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800648:	5b                   	pop    %ebx
  800649:	5e                   	pop    %esi
  80064a:	5f                   	pop    %edi
  80064b:	5d                   	pop    %ebp
  80064c:	c3                   	ret    

0080064d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80064d:	55                   	push   %ebp
  80064e:	89 e5                	mov    %esp,%ebp
  800650:	57                   	push   %edi
  800651:	56                   	push   %esi
  800652:	53                   	push   %ebx
  800653:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800656:	b8 05 00 00 00       	mov    $0x5,%eax
  80065b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80065e:	8b 55 08             	mov    0x8(%ebp),%edx
  800661:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800664:	8b 7d 14             	mov    0x14(%ebp),%edi
  800667:	8b 75 18             	mov    0x18(%ebp),%esi
  80066a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80066c:	85 c0                	test   %eax,%eax
  80066e:	7e 17                	jle    800687 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800670:	83 ec 0c             	sub    $0xc,%esp
  800673:	50                   	push   %eax
  800674:	6a 05                	push   $0x5
  800676:	68 ef 1e 80 00       	push   $0x801eef
  80067b:	6a 23                	push   $0x23
  80067d:	68 0c 1f 80 00       	push   $0x801f0c
  800682:	e8 0c 0e 00 00       	call   801493 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800687:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80068a:	5b                   	pop    %ebx
  80068b:	5e                   	pop    %esi
  80068c:	5f                   	pop    %edi
  80068d:	5d                   	pop    %ebp
  80068e:	c3                   	ret    

0080068f <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80068f:	55                   	push   %ebp
  800690:	89 e5                	mov    %esp,%ebp
  800692:	57                   	push   %edi
  800693:	56                   	push   %esi
  800694:	53                   	push   %ebx
  800695:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800698:	bb 00 00 00 00       	mov    $0x0,%ebx
  80069d:	b8 06 00 00 00       	mov    $0x6,%eax
  8006a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8006a8:	89 df                	mov    %ebx,%edi
  8006aa:	89 de                	mov    %ebx,%esi
  8006ac:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8006ae:	85 c0                	test   %eax,%eax
  8006b0:	7e 17                	jle    8006c9 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8006b2:	83 ec 0c             	sub    $0xc,%esp
  8006b5:	50                   	push   %eax
  8006b6:	6a 06                	push   $0x6
  8006b8:	68 ef 1e 80 00       	push   $0x801eef
  8006bd:	6a 23                	push   $0x23
  8006bf:	68 0c 1f 80 00       	push   $0x801f0c
  8006c4:	e8 ca 0d 00 00       	call   801493 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8006c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006cc:	5b                   	pop    %ebx
  8006cd:	5e                   	pop    %esi
  8006ce:	5f                   	pop    %edi
  8006cf:	5d                   	pop    %ebp
  8006d0:	c3                   	ret    

008006d1 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8006d1:	55                   	push   %ebp
  8006d2:	89 e5                	mov    %esp,%ebp
  8006d4:	57                   	push   %edi
  8006d5:	56                   	push   %esi
  8006d6:	53                   	push   %ebx
  8006d7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8006da:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006df:	b8 08 00 00 00       	mov    $0x8,%eax
  8006e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006e7:	8b 55 08             	mov    0x8(%ebp),%edx
  8006ea:	89 df                	mov    %ebx,%edi
  8006ec:	89 de                	mov    %ebx,%esi
  8006ee:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8006f0:	85 c0                	test   %eax,%eax
  8006f2:	7e 17                	jle    80070b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8006f4:	83 ec 0c             	sub    $0xc,%esp
  8006f7:	50                   	push   %eax
  8006f8:	6a 08                	push   $0x8
  8006fa:	68 ef 1e 80 00       	push   $0x801eef
  8006ff:	6a 23                	push   $0x23
  800701:	68 0c 1f 80 00       	push   $0x801f0c
  800706:	e8 88 0d 00 00       	call   801493 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80070b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80070e:	5b                   	pop    %ebx
  80070f:	5e                   	pop    %esi
  800710:	5f                   	pop    %edi
  800711:	5d                   	pop    %ebp
  800712:	c3                   	ret    

00800713 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800713:	55                   	push   %ebp
  800714:	89 e5                	mov    %esp,%ebp
  800716:	57                   	push   %edi
  800717:	56                   	push   %esi
  800718:	53                   	push   %ebx
  800719:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80071c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800721:	b8 09 00 00 00       	mov    $0x9,%eax
  800726:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800729:	8b 55 08             	mov    0x8(%ebp),%edx
  80072c:	89 df                	mov    %ebx,%edi
  80072e:	89 de                	mov    %ebx,%esi
  800730:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800732:	85 c0                	test   %eax,%eax
  800734:	7e 17                	jle    80074d <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800736:	83 ec 0c             	sub    $0xc,%esp
  800739:	50                   	push   %eax
  80073a:	6a 09                	push   $0x9
  80073c:	68 ef 1e 80 00       	push   $0x801eef
  800741:	6a 23                	push   $0x23
  800743:	68 0c 1f 80 00       	push   $0x801f0c
  800748:	e8 46 0d 00 00       	call   801493 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80074d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800750:	5b                   	pop    %ebx
  800751:	5e                   	pop    %esi
  800752:	5f                   	pop    %edi
  800753:	5d                   	pop    %ebp
  800754:	c3                   	ret    

00800755 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800755:	55                   	push   %ebp
  800756:	89 e5                	mov    %esp,%ebp
  800758:	57                   	push   %edi
  800759:	56                   	push   %esi
  80075a:	53                   	push   %ebx
  80075b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80075e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800763:	b8 0a 00 00 00       	mov    $0xa,%eax
  800768:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80076b:	8b 55 08             	mov    0x8(%ebp),%edx
  80076e:	89 df                	mov    %ebx,%edi
  800770:	89 de                	mov    %ebx,%esi
  800772:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800774:	85 c0                	test   %eax,%eax
  800776:	7e 17                	jle    80078f <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800778:	83 ec 0c             	sub    $0xc,%esp
  80077b:	50                   	push   %eax
  80077c:	6a 0a                	push   $0xa
  80077e:	68 ef 1e 80 00       	push   $0x801eef
  800783:	6a 23                	push   $0x23
  800785:	68 0c 1f 80 00       	push   $0x801f0c
  80078a:	e8 04 0d 00 00       	call   801493 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80078f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800792:	5b                   	pop    %ebx
  800793:	5e                   	pop    %esi
  800794:	5f                   	pop    %edi
  800795:	5d                   	pop    %ebp
  800796:	c3                   	ret    

00800797 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800797:	55                   	push   %ebp
  800798:	89 e5                	mov    %esp,%ebp
  80079a:	57                   	push   %edi
  80079b:	56                   	push   %esi
  80079c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80079d:	be 00 00 00 00       	mov    $0x0,%esi
  8007a2:	b8 0c 00 00 00       	mov    $0xc,%eax
  8007a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8007ad:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8007b0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8007b3:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8007b5:	5b                   	pop    %ebx
  8007b6:	5e                   	pop    %esi
  8007b7:	5f                   	pop    %edi
  8007b8:	5d                   	pop    %ebp
  8007b9:	c3                   	ret    

008007ba <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8007ba:	55                   	push   %ebp
  8007bb:	89 e5                	mov    %esp,%ebp
  8007bd:	57                   	push   %edi
  8007be:	56                   	push   %esi
  8007bf:	53                   	push   %ebx
  8007c0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8007c3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007c8:	b8 0d 00 00 00       	mov    $0xd,%eax
  8007cd:	8b 55 08             	mov    0x8(%ebp),%edx
  8007d0:	89 cb                	mov    %ecx,%ebx
  8007d2:	89 cf                	mov    %ecx,%edi
  8007d4:	89 ce                	mov    %ecx,%esi
  8007d6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8007d8:	85 c0                	test   %eax,%eax
  8007da:	7e 17                	jle    8007f3 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8007dc:	83 ec 0c             	sub    $0xc,%esp
  8007df:	50                   	push   %eax
  8007e0:	6a 0d                	push   $0xd
  8007e2:	68 ef 1e 80 00       	push   $0x801eef
  8007e7:	6a 23                	push   $0x23
  8007e9:	68 0c 1f 80 00       	push   $0x801f0c
  8007ee:	e8 a0 0c 00 00       	call   801493 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8007f3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007f6:	5b                   	pop    %ebx
  8007f7:	5e                   	pop    %esi
  8007f8:	5f                   	pop    %edi
  8007f9:	5d                   	pop    %ebp
  8007fa:	c3                   	ret    

008007fb <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8007fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800801:	05 00 00 00 30       	add    $0x30000000,%eax
  800806:	c1 e8 0c             	shr    $0xc,%eax
}
  800809:	5d                   	pop    %ebp
  80080a:	c3                   	ret    

0080080b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80080b:	55                   	push   %ebp
  80080c:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80080e:	8b 45 08             	mov    0x8(%ebp),%eax
  800811:	05 00 00 00 30       	add    $0x30000000,%eax
  800816:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80081b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800820:	5d                   	pop    %ebp
  800821:	c3                   	ret    

00800822 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800822:	55                   	push   %ebp
  800823:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800825:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  80082a:	a8 01                	test   $0x1,%al
  80082c:	74 34                	je     800862 <fd_alloc+0x40>
  80082e:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800833:	a8 01                	test   $0x1,%al
  800835:	74 32                	je     800869 <fd_alloc+0x47>
  800837:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80083c:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80083e:	89 c2                	mov    %eax,%edx
  800840:	c1 ea 16             	shr    $0x16,%edx
  800843:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80084a:	f6 c2 01             	test   $0x1,%dl
  80084d:	74 1f                	je     80086e <fd_alloc+0x4c>
  80084f:	89 c2                	mov    %eax,%edx
  800851:	c1 ea 0c             	shr    $0xc,%edx
  800854:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80085b:	f6 c2 01             	test   $0x1,%dl
  80085e:	75 1a                	jne    80087a <fd_alloc+0x58>
  800860:	eb 0c                	jmp    80086e <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800862:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800867:	eb 05                	jmp    80086e <fd_alloc+0x4c>
  800869:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  80086e:	8b 45 08             	mov    0x8(%ebp),%eax
  800871:	89 08                	mov    %ecx,(%eax)
			return 0;
  800873:	b8 00 00 00 00       	mov    $0x0,%eax
  800878:	eb 1a                	jmp    800894 <fd_alloc+0x72>
  80087a:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80087f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800884:	75 b6                	jne    80083c <fd_alloc+0x1a>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800886:	8b 45 08             	mov    0x8(%ebp),%eax
  800889:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  80088f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800894:	5d                   	pop    %ebp
  800895:	c3                   	ret    

00800896 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800896:	55                   	push   %ebp
  800897:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800899:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  80089d:	77 39                	ja     8008d8 <fd_lookup+0x42>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80089f:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a2:	c1 e0 0c             	shl    $0xc,%eax
  8008a5:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8008aa:	89 c2                	mov    %eax,%edx
  8008ac:	c1 ea 16             	shr    $0x16,%edx
  8008af:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8008b6:	f6 c2 01             	test   $0x1,%dl
  8008b9:	74 24                	je     8008df <fd_lookup+0x49>
  8008bb:	89 c2                	mov    %eax,%edx
  8008bd:	c1 ea 0c             	shr    $0xc,%edx
  8008c0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8008c7:	f6 c2 01             	test   $0x1,%dl
  8008ca:	74 1a                	je     8008e6 <fd_lookup+0x50>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8008cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008cf:	89 02                	mov    %eax,(%edx)
	return 0;
  8008d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d6:	eb 13                	jmp    8008eb <fd_lookup+0x55>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8008d8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008dd:	eb 0c                	jmp    8008eb <fd_lookup+0x55>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8008df:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008e4:	eb 05                	jmp    8008eb <fd_lookup+0x55>
  8008e6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8008eb:	5d                   	pop    %ebp
  8008ec:	c3                   	ret    

008008ed <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8008ed:	55                   	push   %ebp
  8008ee:	89 e5                	mov    %esp,%ebp
  8008f0:	53                   	push   %ebx
  8008f1:	83 ec 04             	sub    $0x4,%esp
  8008f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8008fa:	3b 05 04 30 80 00    	cmp    0x803004,%eax
  800900:	75 1e                	jne    800920 <dev_lookup+0x33>
  800902:	eb 0e                	jmp    800912 <dev_lookup+0x25>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800904:	b8 20 30 80 00       	mov    $0x803020,%eax
  800909:	eb 0c                	jmp    800917 <dev_lookup+0x2a>
  80090b:	b8 3c 30 80 00       	mov    $0x80303c,%eax
  800910:	eb 05                	jmp    800917 <dev_lookup+0x2a>
  800912:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800917:	89 03                	mov    %eax,(%ebx)
			return 0;
  800919:	b8 00 00 00 00       	mov    $0x0,%eax
  80091e:	eb 36                	jmp    800956 <dev_lookup+0x69>
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800920:	3b 05 20 30 80 00    	cmp    0x803020,%eax
  800926:	74 dc                	je     800904 <dev_lookup+0x17>
  800928:	3b 05 3c 30 80 00    	cmp    0x80303c,%eax
  80092e:	74 db                	je     80090b <dev_lookup+0x1e>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800930:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800936:	8b 52 48             	mov    0x48(%edx),%edx
  800939:	83 ec 04             	sub    $0x4,%esp
  80093c:	50                   	push   %eax
  80093d:	52                   	push   %edx
  80093e:	68 1c 1f 80 00       	push   $0x801f1c
  800943:	e8 23 0c 00 00       	call   80156b <cprintf>
	*dev = 0;
  800948:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80094e:	83 c4 10             	add    $0x10,%esp
  800951:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800956:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800959:	c9                   	leave  
  80095a:	c3                   	ret    

0080095b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	56                   	push   %esi
  80095f:	53                   	push   %ebx
  800960:	83 ec 10             	sub    $0x10,%esp
  800963:	8b 75 08             	mov    0x8(%ebp),%esi
  800966:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800969:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80096c:	50                   	push   %eax
  80096d:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800973:	c1 e8 0c             	shr    $0xc,%eax
  800976:	50                   	push   %eax
  800977:	e8 1a ff ff ff       	call   800896 <fd_lookup>
  80097c:	83 c4 08             	add    $0x8,%esp
  80097f:	85 c0                	test   %eax,%eax
  800981:	78 05                	js     800988 <fd_close+0x2d>
	    || fd != fd2)
  800983:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800986:	74 06                	je     80098e <fd_close+0x33>
		return (must_exist ? r : 0);
  800988:	84 db                	test   %bl,%bl
  80098a:	74 47                	je     8009d3 <fd_close+0x78>
  80098c:	eb 4a                	jmp    8009d8 <fd_close+0x7d>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80098e:	83 ec 08             	sub    $0x8,%esp
  800991:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800994:	50                   	push   %eax
  800995:	ff 36                	pushl  (%esi)
  800997:	e8 51 ff ff ff       	call   8008ed <dev_lookup>
  80099c:	89 c3                	mov    %eax,%ebx
  80099e:	83 c4 10             	add    $0x10,%esp
  8009a1:	85 c0                	test   %eax,%eax
  8009a3:	78 1c                	js     8009c1 <fd_close+0x66>
		if (dev->dev_close)
  8009a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009a8:	8b 40 10             	mov    0x10(%eax),%eax
  8009ab:	85 c0                	test   %eax,%eax
  8009ad:	74 0d                	je     8009bc <fd_close+0x61>
			r = (*dev->dev_close)(fd);
  8009af:	83 ec 0c             	sub    $0xc,%esp
  8009b2:	56                   	push   %esi
  8009b3:	ff d0                	call   *%eax
  8009b5:	89 c3                	mov    %eax,%ebx
  8009b7:	83 c4 10             	add    $0x10,%esp
  8009ba:	eb 05                	jmp    8009c1 <fd_close+0x66>
		else
			r = 0;
  8009bc:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8009c1:	83 ec 08             	sub    $0x8,%esp
  8009c4:	56                   	push   %esi
  8009c5:	6a 00                	push   $0x0
  8009c7:	e8 c3 fc ff ff       	call   80068f <sys_page_unmap>
	return r;
  8009cc:	83 c4 10             	add    $0x10,%esp
  8009cf:	89 d8                	mov    %ebx,%eax
  8009d1:	eb 05                	jmp    8009d8 <fd_close+0x7d>
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
  8009d3:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
	return r;
}
  8009d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009db:	5b                   	pop    %ebx
  8009dc:	5e                   	pop    %esi
  8009dd:	5d                   	pop    %ebp
  8009de:	c3                   	ret    

008009df <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8009df:	55                   	push   %ebp
  8009e0:	89 e5                	mov    %esp,%ebp
  8009e2:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8009e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009e8:	50                   	push   %eax
  8009e9:	ff 75 08             	pushl  0x8(%ebp)
  8009ec:	e8 a5 fe ff ff       	call   800896 <fd_lookup>
  8009f1:	83 c4 08             	add    $0x8,%esp
  8009f4:	85 c0                	test   %eax,%eax
  8009f6:	78 10                	js     800a08 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8009f8:	83 ec 08             	sub    $0x8,%esp
  8009fb:	6a 01                	push   $0x1
  8009fd:	ff 75 f4             	pushl  -0xc(%ebp)
  800a00:	e8 56 ff ff ff       	call   80095b <fd_close>
  800a05:	83 c4 10             	add    $0x10,%esp
}
  800a08:	c9                   	leave  
  800a09:	c3                   	ret    

00800a0a <close_all>:

void
close_all(void)
{
  800a0a:	55                   	push   %ebp
  800a0b:	89 e5                	mov    %esp,%ebp
  800a0d:	53                   	push   %ebx
  800a0e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800a11:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800a16:	83 ec 0c             	sub    $0xc,%esp
  800a19:	53                   	push   %ebx
  800a1a:	e8 c0 ff ff ff       	call   8009df <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800a1f:	43                   	inc    %ebx
  800a20:	83 c4 10             	add    $0x10,%esp
  800a23:	83 fb 20             	cmp    $0x20,%ebx
  800a26:	75 ee                	jne    800a16 <close_all+0xc>
		close(i);
}
  800a28:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a2b:	c9                   	leave  
  800a2c:	c3                   	ret    

00800a2d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800a2d:	55                   	push   %ebp
  800a2e:	89 e5                	mov    %esp,%ebp
  800a30:	57                   	push   %edi
  800a31:	56                   	push   %esi
  800a32:	53                   	push   %ebx
  800a33:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800a36:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800a39:	50                   	push   %eax
  800a3a:	ff 75 08             	pushl  0x8(%ebp)
  800a3d:	e8 54 fe ff ff       	call   800896 <fd_lookup>
  800a42:	83 c4 08             	add    $0x8,%esp
  800a45:	85 c0                	test   %eax,%eax
  800a47:	0f 88 c2 00 00 00    	js     800b0f <dup+0xe2>
		return r;
	close(newfdnum);
  800a4d:	83 ec 0c             	sub    $0xc,%esp
  800a50:	ff 75 0c             	pushl  0xc(%ebp)
  800a53:	e8 87 ff ff ff       	call   8009df <close>

	newfd = INDEX2FD(newfdnum);
  800a58:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a5b:	c1 e3 0c             	shl    $0xc,%ebx
  800a5e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800a64:	83 c4 04             	add    $0x4,%esp
  800a67:	ff 75 e4             	pushl  -0x1c(%ebp)
  800a6a:	e8 9c fd ff ff       	call   80080b <fd2data>
  800a6f:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  800a71:	89 1c 24             	mov    %ebx,(%esp)
  800a74:	e8 92 fd ff ff       	call   80080b <fd2data>
  800a79:	83 c4 10             	add    $0x10,%esp
  800a7c:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800a7e:	89 f0                	mov    %esi,%eax
  800a80:	c1 e8 16             	shr    $0x16,%eax
  800a83:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800a8a:	a8 01                	test   $0x1,%al
  800a8c:	74 35                	je     800ac3 <dup+0x96>
  800a8e:	89 f0                	mov    %esi,%eax
  800a90:	c1 e8 0c             	shr    $0xc,%eax
  800a93:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800a9a:	f6 c2 01             	test   $0x1,%dl
  800a9d:	74 24                	je     800ac3 <dup+0x96>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800a9f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800aa6:	83 ec 0c             	sub    $0xc,%esp
  800aa9:	25 07 0e 00 00       	and    $0xe07,%eax
  800aae:	50                   	push   %eax
  800aaf:	57                   	push   %edi
  800ab0:	6a 00                	push   $0x0
  800ab2:	56                   	push   %esi
  800ab3:	6a 00                	push   $0x0
  800ab5:	e8 93 fb ff ff       	call   80064d <sys_page_map>
  800aba:	89 c6                	mov    %eax,%esi
  800abc:	83 c4 20             	add    $0x20,%esp
  800abf:	85 c0                	test   %eax,%eax
  800ac1:	78 2c                	js     800aef <dup+0xc2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800ac3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800ac6:	89 d0                	mov    %edx,%eax
  800ac8:	c1 e8 0c             	shr    $0xc,%eax
  800acb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ad2:	83 ec 0c             	sub    $0xc,%esp
  800ad5:	25 07 0e 00 00       	and    $0xe07,%eax
  800ada:	50                   	push   %eax
  800adb:	53                   	push   %ebx
  800adc:	6a 00                	push   $0x0
  800ade:	52                   	push   %edx
  800adf:	6a 00                	push   $0x0
  800ae1:	e8 67 fb ff ff       	call   80064d <sys_page_map>
  800ae6:	89 c6                	mov    %eax,%esi
  800ae8:	83 c4 20             	add    $0x20,%esp
  800aeb:	85 c0                	test   %eax,%eax
  800aed:	79 1d                	jns    800b0c <dup+0xdf>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800aef:	83 ec 08             	sub    $0x8,%esp
  800af2:	53                   	push   %ebx
  800af3:	6a 00                	push   $0x0
  800af5:	e8 95 fb ff ff       	call   80068f <sys_page_unmap>
	sys_page_unmap(0, nva);
  800afa:	83 c4 08             	add    $0x8,%esp
  800afd:	57                   	push   %edi
  800afe:	6a 00                	push   $0x0
  800b00:	e8 8a fb ff ff       	call   80068f <sys_page_unmap>
	return r;
  800b05:	83 c4 10             	add    $0x10,%esp
  800b08:	89 f0                	mov    %esi,%eax
  800b0a:	eb 03                	jmp    800b0f <dup+0xe2>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  800b0c:	8b 45 0c             	mov    0xc(%ebp),%eax

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800b0f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b12:	5b                   	pop    %ebx
  800b13:	5e                   	pop    %esi
  800b14:	5f                   	pop    %edi
  800b15:	5d                   	pop    %ebp
  800b16:	c3                   	ret    

00800b17 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800b17:	55                   	push   %ebp
  800b18:	89 e5                	mov    %esp,%ebp
  800b1a:	53                   	push   %ebx
  800b1b:	83 ec 14             	sub    $0x14,%esp
  800b1e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800b21:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800b24:	50                   	push   %eax
  800b25:	53                   	push   %ebx
  800b26:	e8 6b fd ff ff       	call   800896 <fd_lookup>
  800b2b:	83 c4 08             	add    $0x8,%esp
  800b2e:	85 c0                	test   %eax,%eax
  800b30:	78 67                	js     800b99 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b32:	83 ec 08             	sub    $0x8,%esp
  800b35:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b38:	50                   	push   %eax
  800b39:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b3c:	ff 30                	pushl  (%eax)
  800b3e:	e8 aa fd ff ff       	call   8008ed <dev_lookup>
  800b43:	83 c4 10             	add    $0x10,%esp
  800b46:	85 c0                	test   %eax,%eax
  800b48:	78 4f                	js     800b99 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800b4a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b4d:	8b 42 08             	mov    0x8(%edx),%eax
  800b50:	83 e0 03             	and    $0x3,%eax
  800b53:	83 f8 01             	cmp    $0x1,%eax
  800b56:	75 21                	jne    800b79 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800b58:	a1 04 40 80 00       	mov    0x804004,%eax
  800b5d:	8b 40 48             	mov    0x48(%eax),%eax
  800b60:	83 ec 04             	sub    $0x4,%esp
  800b63:	53                   	push   %ebx
  800b64:	50                   	push   %eax
  800b65:	68 5d 1f 80 00       	push   $0x801f5d
  800b6a:	e8 fc 09 00 00       	call   80156b <cprintf>
		return -E_INVAL;
  800b6f:	83 c4 10             	add    $0x10,%esp
  800b72:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b77:	eb 20                	jmp    800b99 <read+0x82>
	}
	if (!dev->dev_read)
  800b79:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b7c:	8b 40 08             	mov    0x8(%eax),%eax
  800b7f:	85 c0                	test   %eax,%eax
  800b81:	74 11                	je     800b94 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800b83:	83 ec 04             	sub    $0x4,%esp
  800b86:	ff 75 10             	pushl  0x10(%ebp)
  800b89:	ff 75 0c             	pushl  0xc(%ebp)
  800b8c:	52                   	push   %edx
  800b8d:	ff d0                	call   *%eax
  800b8f:	83 c4 10             	add    $0x10,%esp
  800b92:	eb 05                	jmp    800b99 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800b94:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  800b99:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b9c:	c9                   	leave  
  800b9d:	c3                   	ret    

00800b9e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800b9e:	55                   	push   %ebp
  800b9f:	89 e5                	mov    %esp,%ebp
  800ba1:	57                   	push   %edi
  800ba2:	56                   	push   %esi
  800ba3:	53                   	push   %ebx
  800ba4:	83 ec 0c             	sub    $0xc,%esp
  800ba7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800baa:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800bad:	85 f6                	test   %esi,%esi
  800baf:	74 31                	je     800be2 <readn+0x44>
  800bb1:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb6:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  800bbb:	83 ec 04             	sub    $0x4,%esp
  800bbe:	89 f2                	mov    %esi,%edx
  800bc0:	29 c2                	sub    %eax,%edx
  800bc2:	52                   	push   %edx
  800bc3:	03 45 0c             	add    0xc(%ebp),%eax
  800bc6:	50                   	push   %eax
  800bc7:	57                   	push   %edi
  800bc8:	e8 4a ff ff ff       	call   800b17 <read>
		if (m < 0)
  800bcd:	83 c4 10             	add    $0x10,%esp
  800bd0:	85 c0                	test   %eax,%eax
  800bd2:	78 17                	js     800beb <readn+0x4d>
			return m;
		if (m == 0)
  800bd4:	85 c0                	test   %eax,%eax
  800bd6:	74 11                	je     800be9 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800bd8:	01 c3                	add    %eax,%ebx
  800bda:	89 d8                	mov    %ebx,%eax
  800bdc:	39 f3                	cmp    %esi,%ebx
  800bde:	72 db                	jb     800bbb <readn+0x1d>
  800be0:	eb 09                	jmp    800beb <readn+0x4d>
  800be2:	b8 00 00 00 00       	mov    $0x0,%eax
  800be7:	eb 02                	jmp    800beb <readn+0x4d>
  800be9:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800beb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bee:	5b                   	pop    %ebx
  800bef:	5e                   	pop    %esi
  800bf0:	5f                   	pop    %edi
  800bf1:	5d                   	pop    %ebp
  800bf2:	c3                   	ret    

00800bf3 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800bf3:	55                   	push   %ebp
  800bf4:	89 e5                	mov    %esp,%ebp
  800bf6:	53                   	push   %ebx
  800bf7:	83 ec 14             	sub    $0x14,%esp
  800bfa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800bfd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800c00:	50                   	push   %eax
  800c01:	53                   	push   %ebx
  800c02:	e8 8f fc ff ff       	call   800896 <fd_lookup>
  800c07:	83 c4 08             	add    $0x8,%esp
  800c0a:	85 c0                	test   %eax,%eax
  800c0c:	78 62                	js     800c70 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c0e:	83 ec 08             	sub    $0x8,%esp
  800c11:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c14:	50                   	push   %eax
  800c15:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c18:	ff 30                	pushl  (%eax)
  800c1a:	e8 ce fc ff ff       	call   8008ed <dev_lookup>
  800c1f:	83 c4 10             	add    $0x10,%esp
  800c22:	85 c0                	test   %eax,%eax
  800c24:	78 4a                	js     800c70 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800c26:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c29:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800c2d:	75 21                	jne    800c50 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800c2f:	a1 04 40 80 00       	mov    0x804004,%eax
  800c34:	8b 40 48             	mov    0x48(%eax),%eax
  800c37:	83 ec 04             	sub    $0x4,%esp
  800c3a:	53                   	push   %ebx
  800c3b:	50                   	push   %eax
  800c3c:	68 79 1f 80 00       	push   $0x801f79
  800c41:	e8 25 09 00 00       	call   80156b <cprintf>
		return -E_INVAL;
  800c46:	83 c4 10             	add    $0x10,%esp
  800c49:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c4e:	eb 20                	jmp    800c70 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800c50:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c53:	8b 52 0c             	mov    0xc(%edx),%edx
  800c56:	85 d2                	test   %edx,%edx
  800c58:	74 11                	je     800c6b <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800c5a:	83 ec 04             	sub    $0x4,%esp
  800c5d:	ff 75 10             	pushl  0x10(%ebp)
  800c60:	ff 75 0c             	pushl  0xc(%ebp)
  800c63:	50                   	push   %eax
  800c64:	ff d2                	call   *%edx
  800c66:	83 c4 10             	add    $0x10,%esp
  800c69:	eb 05                	jmp    800c70 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800c6b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  800c70:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c73:	c9                   	leave  
  800c74:	c3                   	ret    

00800c75 <seek>:

int
seek(int fdnum, off_t offset)
{
  800c75:	55                   	push   %ebp
  800c76:	89 e5                	mov    %esp,%ebp
  800c78:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800c7b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800c7e:	50                   	push   %eax
  800c7f:	ff 75 08             	pushl  0x8(%ebp)
  800c82:	e8 0f fc ff ff       	call   800896 <fd_lookup>
  800c87:	83 c4 08             	add    $0x8,%esp
  800c8a:	85 c0                	test   %eax,%eax
  800c8c:	78 0e                	js     800c9c <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800c8e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800c91:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c94:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800c97:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c9c:	c9                   	leave  
  800c9d:	c3                   	ret    

00800c9e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800c9e:	55                   	push   %ebp
  800c9f:	89 e5                	mov    %esp,%ebp
  800ca1:	53                   	push   %ebx
  800ca2:	83 ec 14             	sub    $0x14,%esp
  800ca5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800ca8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800cab:	50                   	push   %eax
  800cac:	53                   	push   %ebx
  800cad:	e8 e4 fb ff ff       	call   800896 <fd_lookup>
  800cb2:	83 c4 08             	add    $0x8,%esp
  800cb5:	85 c0                	test   %eax,%eax
  800cb7:	78 5f                	js     800d18 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800cb9:	83 ec 08             	sub    $0x8,%esp
  800cbc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800cbf:	50                   	push   %eax
  800cc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800cc3:	ff 30                	pushl  (%eax)
  800cc5:	e8 23 fc ff ff       	call   8008ed <dev_lookup>
  800cca:	83 c4 10             	add    $0x10,%esp
  800ccd:	85 c0                	test   %eax,%eax
  800ccf:	78 47                	js     800d18 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800cd1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800cd4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800cd8:	75 21                	jne    800cfb <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800cda:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800cdf:	8b 40 48             	mov    0x48(%eax),%eax
  800ce2:	83 ec 04             	sub    $0x4,%esp
  800ce5:	53                   	push   %ebx
  800ce6:	50                   	push   %eax
  800ce7:	68 3c 1f 80 00       	push   $0x801f3c
  800cec:	e8 7a 08 00 00       	call   80156b <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800cf1:	83 c4 10             	add    $0x10,%esp
  800cf4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800cf9:	eb 1d                	jmp    800d18 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  800cfb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800cfe:	8b 52 18             	mov    0x18(%edx),%edx
  800d01:	85 d2                	test   %edx,%edx
  800d03:	74 0e                	je     800d13 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800d05:	83 ec 08             	sub    $0x8,%esp
  800d08:	ff 75 0c             	pushl  0xc(%ebp)
  800d0b:	50                   	push   %eax
  800d0c:	ff d2                	call   *%edx
  800d0e:	83 c4 10             	add    $0x10,%esp
  800d11:	eb 05                	jmp    800d18 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800d13:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  800d18:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d1b:	c9                   	leave  
  800d1c:	c3                   	ret    

00800d1d <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800d1d:	55                   	push   %ebp
  800d1e:	89 e5                	mov    %esp,%ebp
  800d20:	53                   	push   %ebx
  800d21:	83 ec 14             	sub    $0x14,%esp
  800d24:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800d27:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d2a:	50                   	push   %eax
  800d2b:	ff 75 08             	pushl  0x8(%ebp)
  800d2e:	e8 63 fb ff ff       	call   800896 <fd_lookup>
  800d33:	83 c4 08             	add    $0x8,%esp
  800d36:	85 c0                	test   %eax,%eax
  800d38:	78 52                	js     800d8c <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800d3a:	83 ec 08             	sub    $0x8,%esp
  800d3d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d40:	50                   	push   %eax
  800d41:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d44:	ff 30                	pushl  (%eax)
  800d46:	e8 a2 fb ff ff       	call   8008ed <dev_lookup>
  800d4b:	83 c4 10             	add    $0x10,%esp
  800d4e:	85 c0                	test   %eax,%eax
  800d50:	78 3a                	js     800d8c <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  800d52:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d55:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800d59:	74 2c                	je     800d87 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800d5b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800d5e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800d65:	00 00 00 
	stat->st_isdir = 0;
  800d68:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800d6f:	00 00 00 
	stat->st_dev = dev;
  800d72:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800d78:	83 ec 08             	sub    $0x8,%esp
  800d7b:	53                   	push   %ebx
  800d7c:	ff 75 f0             	pushl  -0x10(%ebp)
  800d7f:	ff 50 14             	call   *0x14(%eax)
  800d82:	83 c4 10             	add    $0x10,%esp
  800d85:	eb 05                	jmp    800d8c <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800d87:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800d8c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d8f:	c9                   	leave  
  800d90:	c3                   	ret    

00800d91 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800d91:	55                   	push   %ebp
  800d92:	89 e5                	mov    %esp,%ebp
  800d94:	56                   	push   %esi
  800d95:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800d96:	83 ec 08             	sub    $0x8,%esp
  800d99:	6a 00                	push   $0x0
  800d9b:	ff 75 08             	pushl  0x8(%ebp)
  800d9e:	e8 75 01 00 00       	call   800f18 <open>
  800da3:	89 c3                	mov    %eax,%ebx
  800da5:	83 c4 10             	add    $0x10,%esp
  800da8:	85 c0                	test   %eax,%eax
  800daa:	78 1d                	js     800dc9 <stat+0x38>
		return fd;
	r = fstat(fd, stat);
  800dac:	83 ec 08             	sub    $0x8,%esp
  800daf:	ff 75 0c             	pushl  0xc(%ebp)
  800db2:	50                   	push   %eax
  800db3:	e8 65 ff ff ff       	call   800d1d <fstat>
  800db8:	89 c6                	mov    %eax,%esi
	close(fd);
  800dba:	89 1c 24             	mov    %ebx,(%esp)
  800dbd:	e8 1d fc ff ff       	call   8009df <close>
	return r;
  800dc2:	83 c4 10             	add    $0x10,%esp
  800dc5:	89 f0                	mov    %esi,%eax
  800dc7:	eb 00                	jmp    800dc9 <stat+0x38>
}
  800dc9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800dcc:	5b                   	pop    %ebx
  800dcd:	5e                   	pop    %esi
  800dce:	5d                   	pop    %ebp
  800dcf:	c3                   	ret    

00800dd0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800dd0:	55                   	push   %ebp
  800dd1:	89 e5                	mov    %esp,%ebp
  800dd3:	56                   	push   %esi
  800dd4:	53                   	push   %ebx
  800dd5:	89 c6                	mov    %eax,%esi
  800dd7:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800dd9:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800de0:	75 12                	jne    800df4 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800de2:	83 ec 0c             	sub    $0xc,%esp
  800de5:	6a 01                	push   $0x1
  800de7:	e8 e1 0d 00 00       	call   801bcd <ipc_find_env>
  800dec:	a3 00 40 80 00       	mov    %eax,0x804000
  800df1:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800df4:	6a 07                	push   $0x7
  800df6:	68 00 50 80 00       	push   $0x805000
  800dfb:	56                   	push   %esi
  800dfc:	ff 35 00 40 80 00    	pushl  0x804000
  800e02:	e8 67 0d 00 00       	call   801b6e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800e07:	83 c4 0c             	add    $0xc,%esp
  800e0a:	6a 00                	push   $0x0
  800e0c:	53                   	push   %ebx
  800e0d:	6a 00                	push   $0x0
  800e0f:	e8 e5 0c 00 00       	call   801af9 <ipc_recv>
}
  800e14:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e17:	5b                   	pop    %ebx
  800e18:	5e                   	pop    %esi
  800e19:	5d                   	pop    %ebp
  800e1a:	c3                   	ret    

00800e1b <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800e1b:	55                   	push   %ebp
  800e1c:	89 e5                	mov    %esp,%ebp
  800e1e:	53                   	push   %ebx
  800e1f:	83 ec 04             	sub    $0x4,%esp
  800e22:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800e25:	8b 45 08             	mov    0x8(%ebp),%eax
  800e28:	8b 40 0c             	mov    0xc(%eax),%eax
  800e2b:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800e30:	ba 00 00 00 00       	mov    $0x0,%edx
  800e35:	b8 05 00 00 00       	mov    $0x5,%eax
  800e3a:	e8 91 ff ff ff       	call   800dd0 <fsipc>
  800e3f:	85 c0                	test   %eax,%eax
  800e41:	78 2c                	js     800e6f <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800e43:	83 ec 08             	sub    $0x8,%esp
  800e46:	68 00 50 80 00       	push   $0x805000
  800e4b:	53                   	push   %ebx
  800e4c:	e8 49 f3 ff ff       	call   80019a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800e51:	a1 80 50 80 00       	mov    0x805080,%eax
  800e56:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800e5c:	a1 84 50 80 00       	mov    0x805084,%eax
  800e61:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800e67:	83 c4 10             	add    $0x10,%esp
  800e6a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e6f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e72:	c9                   	leave  
  800e73:	c3                   	ret    

00800e74 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800e74:	55                   	push   %ebp
  800e75:	89 e5                	mov    %esp,%ebp
  800e77:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800e7a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e7d:	8b 40 0c             	mov    0xc(%eax),%eax
  800e80:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800e85:	ba 00 00 00 00       	mov    $0x0,%edx
  800e8a:	b8 06 00 00 00       	mov    $0x6,%eax
  800e8f:	e8 3c ff ff ff       	call   800dd0 <fsipc>
}
  800e94:	c9                   	leave  
  800e95:	c3                   	ret    

00800e96 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800e96:	55                   	push   %ebp
  800e97:	89 e5                	mov    %esp,%ebp
  800e99:	56                   	push   %esi
  800e9a:	53                   	push   %ebx
  800e9b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800e9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea1:	8b 40 0c             	mov    0xc(%eax),%eax
  800ea4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800ea9:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800eaf:	ba 00 00 00 00       	mov    $0x0,%edx
  800eb4:	b8 03 00 00 00       	mov    $0x3,%eax
  800eb9:	e8 12 ff ff ff       	call   800dd0 <fsipc>
  800ebe:	89 c3                	mov    %eax,%ebx
  800ec0:	85 c0                	test   %eax,%eax
  800ec2:	78 4b                	js     800f0f <devfile_read+0x79>
		return r;
	assert(r <= n);
  800ec4:	39 c6                	cmp    %eax,%esi
  800ec6:	73 16                	jae    800ede <devfile_read+0x48>
  800ec8:	68 96 1f 80 00       	push   $0x801f96
  800ecd:	68 9d 1f 80 00       	push   $0x801f9d
  800ed2:	6a 7a                	push   $0x7a
  800ed4:	68 b2 1f 80 00       	push   $0x801fb2
  800ed9:	e8 b5 05 00 00       	call   801493 <_panic>
	assert(r <= PGSIZE);
  800ede:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ee3:	7e 16                	jle    800efb <devfile_read+0x65>
  800ee5:	68 bd 1f 80 00       	push   $0x801fbd
  800eea:	68 9d 1f 80 00       	push   $0x801f9d
  800eef:	6a 7b                	push   $0x7b
  800ef1:	68 b2 1f 80 00       	push   $0x801fb2
  800ef6:	e8 98 05 00 00       	call   801493 <_panic>
	memmove(buf, &fsipcbuf, r);
  800efb:	83 ec 04             	sub    $0x4,%esp
  800efe:	50                   	push   %eax
  800eff:	68 00 50 80 00       	push   $0x805000
  800f04:	ff 75 0c             	pushl  0xc(%ebp)
  800f07:	e8 5b f4 ff ff       	call   800367 <memmove>
	return r;
  800f0c:	83 c4 10             	add    $0x10,%esp
}
  800f0f:	89 d8                	mov    %ebx,%eax
  800f11:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f14:	5b                   	pop    %ebx
  800f15:	5e                   	pop    %esi
  800f16:	5d                   	pop    %ebp
  800f17:	c3                   	ret    

00800f18 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800f18:	55                   	push   %ebp
  800f19:	89 e5                	mov    %esp,%ebp
  800f1b:	53                   	push   %ebx
  800f1c:	83 ec 20             	sub    $0x20,%esp
  800f1f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800f22:	53                   	push   %ebx
  800f23:	e8 1b f2 ff ff       	call   800143 <strlen>
  800f28:	83 c4 10             	add    $0x10,%esp
  800f2b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800f30:	7f 63                	jg     800f95 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800f32:	83 ec 0c             	sub    $0xc,%esp
  800f35:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f38:	50                   	push   %eax
  800f39:	e8 e4 f8 ff ff       	call   800822 <fd_alloc>
  800f3e:	83 c4 10             	add    $0x10,%esp
  800f41:	85 c0                	test   %eax,%eax
  800f43:	78 55                	js     800f9a <open+0x82>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800f45:	83 ec 08             	sub    $0x8,%esp
  800f48:	53                   	push   %ebx
  800f49:	68 00 50 80 00       	push   $0x805000
  800f4e:	e8 47 f2 ff ff       	call   80019a <strcpy>
	fsipcbuf.open.req_omode = mode;
  800f53:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f56:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800f5b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800f5e:	b8 01 00 00 00       	mov    $0x1,%eax
  800f63:	e8 68 fe ff ff       	call   800dd0 <fsipc>
  800f68:	89 c3                	mov    %eax,%ebx
  800f6a:	83 c4 10             	add    $0x10,%esp
  800f6d:	85 c0                	test   %eax,%eax
  800f6f:	79 14                	jns    800f85 <open+0x6d>
		fd_close(fd, 0);
  800f71:	83 ec 08             	sub    $0x8,%esp
  800f74:	6a 00                	push   $0x0
  800f76:	ff 75 f4             	pushl  -0xc(%ebp)
  800f79:	e8 dd f9 ff ff       	call   80095b <fd_close>
		return r;
  800f7e:	83 c4 10             	add    $0x10,%esp
  800f81:	89 d8                	mov    %ebx,%eax
  800f83:	eb 15                	jmp    800f9a <open+0x82>
	}

	return fd2num(fd);
  800f85:	83 ec 0c             	sub    $0xc,%esp
  800f88:	ff 75 f4             	pushl  -0xc(%ebp)
  800f8b:	e8 6b f8 ff ff       	call   8007fb <fd2num>
  800f90:	83 c4 10             	add    $0x10,%esp
  800f93:	eb 05                	jmp    800f9a <open+0x82>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800f95:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800f9a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f9d:	c9                   	leave  
  800f9e:	c3                   	ret    

00800f9f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800f9f:	55                   	push   %ebp
  800fa0:	89 e5                	mov    %esp,%ebp
  800fa2:	56                   	push   %esi
  800fa3:	53                   	push   %ebx
  800fa4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800fa7:	83 ec 0c             	sub    $0xc,%esp
  800faa:	ff 75 08             	pushl  0x8(%ebp)
  800fad:	e8 59 f8 ff ff       	call   80080b <fd2data>
  800fb2:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800fb4:	83 c4 08             	add    $0x8,%esp
  800fb7:	68 c9 1f 80 00       	push   $0x801fc9
  800fbc:	53                   	push   %ebx
  800fbd:	e8 d8 f1 ff ff       	call   80019a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800fc2:	8b 46 04             	mov    0x4(%esi),%eax
  800fc5:	2b 06                	sub    (%esi),%eax
  800fc7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800fcd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800fd4:	00 00 00 
	stat->st_dev = &devpipe;
  800fd7:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800fde:	30 80 00 
	return 0;
}
  800fe1:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fe9:	5b                   	pop    %ebx
  800fea:	5e                   	pop    %esi
  800feb:	5d                   	pop    %ebp
  800fec:	c3                   	ret    

00800fed <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800fed:	55                   	push   %ebp
  800fee:	89 e5                	mov    %esp,%ebp
  800ff0:	53                   	push   %ebx
  800ff1:	83 ec 0c             	sub    $0xc,%esp
  800ff4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800ff7:	53                   	push   %ebx
  800ff8:	6a 00                	push   $0x0
  800ffa:	e8 90 f6 ff ff       	call   80068f <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800fff:	89 1c 24             	mov    %ebx,(%esp)
  801002:	e8 04 f8 ff ff       	call   80080b <fd2data>
  801007:	83 c4 08             	add    $0x8,%esp
  80100a:	50                   	push   %eax
  80100b:	6a 00                	push   $0x0
  80100d:	e8 7d f6 ff ff       	call   80068f <sys_page_unmap>
}
  801012:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801015:	c9                   	leave  
  801016:	c3                   	ret    

00801017 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801017:	55                   	push   %ebp
  801018:	89 e5                	mov    %esp,%ebp
  80101a:	57                   	push   %edi
  80101b:	56                   	push   %esi
  80101c:	53                   	push   %ebx
  80101d:	83 ec 1c             	sub    $0x1c,%esp
  801020:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801023:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801025:	a1 04 40 80 00       	mov    0x804004,%eax
  80102a:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80102d:	83 ec 0c             	sub    $0xc,%esp
  801030:	ff 75 e0             	pushl  -0x20(%ebp)
  801033:	e8 f0 0b 00 00       	call   801c28 <pageref>
  801038:	89 c3                	mov    %eax,%ebx
  80103a:	89 3c 24             	mov    %edi,(%esp)
  80103d:	e8 e6 0b 00 00       	call   801c28 <pageref>
  801042:	83 c4 10             	add    $0x10,%esp
  801045:	39 c3                	cmp    %eax,%ebx
  801047:	0f 94 c1             	sete   %cl
  80104a:	0f b6 c9             	movzbl %cl,%ecx
  80104d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801050:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801056:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801059:	39 ce                	cmp    %ecx,%esi
  80105b:	74 1b                	je     801078 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80105d:	39 c3                	cmp    %eax,%ebx
  80105f:	75 c4                	jne    801025 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801061:	8b 42 58             	mov    0x58(%edx),%eax
  801064:	ff 75 e4             	pushl  -0x1c(%ebp)
  801067:	50                   	push   %eax
  801068:	56                   	push   %esi
  801069:	68 d0 1f 80 00       	push   $0x801fd0
  80106e:	e8 f8 04 00 00       	call   80156b <cprintf>
  801073:	83 c4 10             	add    $0x10,%esp
  801076:	eb ad                	jmp    801025 <_pipeisclosed+0xe>
	}
}
  801078:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80107b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80107e:	5b                   	pop    %ebx
  80107f:	5e                   	pop    %esi
  801080:	5f                   	pop    %edi
  801081:	5d                   	pop    %ebp
  801082:	c3                   	ret    

00801083 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801083:	55                   	push   %ebp
  801084:	89 e5                	mov    %esp,%ebp
  801086:	57                   	push   %edi
  801087:	56                   	push   %esi
  801088:	53                   	push   %ebx
  801089:	83 ec 18             	sub    $0x18,%esp
  80108c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80108f:	56                   	push   %esi
  801090:	e8 76 f7 ff ff       	call   80080b <fd2data>
  801095:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801097:	83 c4 10             	add    $0x10,%esp
  80109a:	bf 00 00 00 00       	mov    $0x0,%edi
  80109f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010a3:	75 42                	jne    8010e7 <devpipe_write+0x64>
  8010a5:	eb 4e                	jmp    8010f5 <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8010a7:	89 da                	mov    %ebx,%edx
  8010a9:	89 f0                	mov    %esi,%eax
  8010ab:	e8 67 ff ff ff       	call   801017 <_pipeisclosed>
  8010b0:	85 c0                	test   %eax,%eax
  8010b2:	75 46                	jne    8010fa <devpipe_write+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8010b4:	e8 32 f5 ff ff       	call   8005eb <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8010b9:	8b 53 04             	mov    0x4(%ebx),%edx
  8010bc:	8b 03                	mov    (%ebx),%eax
  8010be:	83 c0 20             	add    $0x20,%eax
  8010c1:	39 c2                	cmp    %eax,%edx
  8010c3:	73 e2                	jae    8010a7 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8010c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010c8:	8a 0c 38             	mov    (%eax,%edi,1),%cl
  8010cb:	89 d0                	mov    %edx,%eax
  8010cd:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8010d2:	79 05                	jns    8010d9 <devpipe_write+0x56>
  8010d4:	48                   	dec    %eax
  8010d5:	83 c8 e0             	or     $0xffffffe0,%eax
  8010d8:	40                   	inc    %eax
  8010d9:	88 4c 03 08          	mov    %cl,0x8(%ebx,%eax,1)
		p->p_wpos++;
  8010dd:	42                   	inc    %edx
  8010de:	89 53 04             	mov    %edx,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8010e1:	47                   	inc    %edi
  8010e2:	39 7d 10             	cmp    %edi,0x10(%ebp)
  8010e5:	74 0e                	je     8010f5 <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8010e7:	8b 53 04             	mov    0x4(%ebx),%edx
  8010ea:	8b 03                	mov    (%ebx),%eax
  8010ec:	83 c0 20             	add    $0x20,%eax
  8010ef:	39 c2                	cmp    %eax,%edx
  8010f1:	73 b4                	jae    8010a7 <devpipe_write+0x24>
  8010f3:	eb d0                	jmp    8010c5 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8010f5:	8b 45 10             	mov    0x10(%ebp),%eax
  8010f8:	eb 05                	jmp    8010ff <devpipe_write+0x7c>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8010fa:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8010ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801102:	5b                   	pop    %ebx
  801103:	5e                   	pop    %esi
  801104:	5f                   	pop    %edi
  801105:	5d                   	pop    %ebp
  801106:	c3                   	ret    

00801107 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801107:	55                   	push   %ebp
  801108:	89 e5                	mov    %esp,%ebp
  80110a:	57                   	push   %edi
  80110b:	56                   	push   %esi
  80110c:	53                   	push   %ebx
  80110d:	83 ec 18             	sub    $0x18,%esp
  801110:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801113:	57                   	push   %edi
  801114:	e8 f2 f6 ff ff       	call   80080b <fd2data>
  801119:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80111b:	83 c4 10             	add    $0x10,%esp
  80111e:	be 00 00 00 00       	mov    $0x0,%esi
  801123:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801127:	75 3d                	jne    801166 <devpipe_read+0x5f>
  801129:	eb 48                	jmp    801173 <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  80112b:	89 f0                	mov    %esi,%eax
  80112d:	eb 4e                	jmp    80117d <devpipe_read+0x76>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80112f:	89 da                	mov    %ebx,%edx
  801131:	89 f8                	mov    %edi,%eax
  801133:	e8 df fe ff ff       	call   801017 <_pipeisclosed>
  801138:	85 c0                	test   %eax,%eax
  80113a:	75 3c                	jne    801178 <devpipe_read+0x71>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80113c:	e8 aa f4 ff ff       	call   8005eb <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801141:	8b 03                	mov    (%ebx),%eax
  801143:	3b 43 04             	cmp    0x4(%ebx),%eax
  801146:	74 e7                	je     80112f <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801148:	25 1f 00 00 80       	and    $0x8000001f,%eax
  80114d:	79 05                	jns    801154 <devpipe_read+0x4d>
  80114f:	48                   	dec    %eax
  801150:	83 c8 e0             	or     $0xffffffe0,%eax
  801153:	40                   	inc    %eax
  801154:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801158:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80115b:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  80115e:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801160:	46                   	inc    %esi
  801161:	39 75 10             	cmp    %esi,0x10(%ebp)
  801164:	74 0d                	je     801173 <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
  801166:	8b 03                	mov    (%ebx),%eax
  801168:	3b 43 04             	cmp    0x4(%ebx),%eax
  80116b:	75 db                	jne    801148 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80116d:	85 f6                	test   %esi,%esi
  80116f:	75 ba                	jne    80112b <devpipe_read+0x24>
  801171:	eb bc                	jmp    80112f <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801173:	8b 45 10             	mov    0x10(%ebp),%eax
  801176:	eb 05                	jmp    80117d <devpipe_read+0x76>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801178:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80117d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801180:	5b                   	pop    %ebx
  801181:	5e                   	pop    %esi
  801182:	5f                   	pop    %edi
  801183:	5d                   	pop    %ebp
  801184:	c3                   	ret    

00801185 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801185:	55                   	push   %ebp
  801186:	89 e5                	mov    %esp,%ebp
  801188:	56                   	push   %esi
  801189:	53                   	push   %ebx
  80118a:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80118d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801190:	50                   	push   %eax
  801191:	e8 8c f6 ff ff       	call   800822 <fd_alloc>
  801196:	83 c4 10             	add    $0x10,%esp
  801199:	85 c0                	test   %eax,%eax
  80119b:	0f 88 2a 01 00 00    	js     8012cb <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011a1:	83 ec 04             	sub    $0x4,%esp
  8011a4:	68 07 04 00 00       	push   $0x407
  8011a9:	ff 75 f4             	pushl  -0xc(%ebp)
  8011ac:	6a 00                	push   $0x0
  8011ae:	e8 57 f4 ff ff       	call   80060a <sys_page_alloc>
  8011b3:	83 c4 10             	add    $0x10,%esp
  8011b6:	85 c0                	test   %eax,%eax
  8011b8:	0f 88 0d 01 00 00    	js     8012cb <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8011be:	83 ec 0c             	sub    $0xc,%esp
  8011c1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011c4:	50                   	push   %eax
  8011c5:	e8 58 f6 ff ff       	call   800822 <fd_alloc>
  8011ca:	89 c3                	mov    %eax,%ebx
  8011cc:	83 c4 10             	add    $0x10,%esp
  8011cf:	85 c0                	test   %eax,%eax
  8011d1:	0f 88 e2 00 00 00    	js     8012b9 <pipe+0x134>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011d7:	83 ec 04             	sub    $0x4,%esp
  8011da:	68 07 04 00 00       	push   $0x407
  8011df:	ff 75 f0             	pushl  -0x10(%ebp)
  8011e2:	6a 00                	push   $0x0
  8011e4:	e8 21 f4 ff ff       	call   80060a <sys_page_alloc>
  8011e9:	89 c3                	mov    %eax,%ebx
  8011eb:	83 c4 10             	add    $0x10,%esp
  8011ee:	85 c0                	test   %eax,%eax
  8011f0:	0f 88 c3 00 00 00    	js     8012b9 <pipe+0x134>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8011f6:	83 ec 0c             	sub    $0xc,%esp
  8011f9:	ff 75 f4             	pushl  -0xc(%ebp)
  8011fc:	e8 0a f6 ff ff       	call   80080b <fd2data>
  801201:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801203:	83 c4 0c             	add    $0xc,%esp
  801206:	68 07 04 00 00       	push   $0x407
  80120b:	50                   	push   %eax
  80120c:	6a 00                	push   $0x0
  80120e:	e8 f7 f3 ff ff       	call   80060a <sys_page_alloc>
  801213:	89 c3                	mov    %eax,%ebx
  801215:	83 c4 10             	add    $0x10,%esp
  801218:	85 c0                	test   %eax,%eax
  80121a:	0f 88 89 00 00 00    	js     8012a9 <pipe+0x124>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801220:	83 ec 0c             	sub    $0xc,%esp
  801223:	ff 75 f0             	pushl  -0x10(%ebp)
  801226:	e8 e0 f5 ff ff       	call   80080b <fd2data>
  80122b:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801232:	50                   	push   %eax
  801233:	6a 00                	push   $0x0
  801235:	56                   	push   %esi
  801236:	6a 00                	push   $0x0
  801238:	e8 10 f4 ff ff       	call   80064d <sys_page_map>
  80123d:	89 c3                	mov    %eax,%ebx
  80123f:	83 c4 20             	add    $0x20,%esp
  801242:	85 c0                	test   %eax,%eax
  801244:	78 55                	js     80129b <pipe+0x116>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801246:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80124c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80124f:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801251:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801254:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80125b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801261:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801264:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801266:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801269:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801270:	83 ec 0c             	sub    $0xc,%esp
  801273:	ff 75 f4             	pushl  -0xc(%ebp)
  801276:	e8 80 f5 ff ff       	call   8007fb <fd2num>
  80127b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80127e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801280:	83 c4 04             	add    $0x4,%esp
  801283:	ff 75 f0             	pushl  -0x10(%ebp)
  801286:	e8 70 f5 ff ff       	call   8007fb <fd2num>
  80128b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80128e:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801291:	83 c4 10             	add    $0x10,%esp
  801294:	b8 00 00 00 00       	mov    $0x0,%eax
  801299:	eb 30                	jmp    8012cb <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  80129b:	83 ec 08             	sub    $0x8,%esp
  80129e:	56                   	push   %esi
  80129f:	6a 00                	push   $0x0
  8012a1:	e8 e9 f3 ff ff       	call   80068f <sys_page_unmap>
  8012a6:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8012a9:	83 ec 08             	sub    $0x8,%esp
  8012ac:	ff 75 f0             	pushl  -0x10(%ebp)
  8012af:	6a 00                	push   $0x0
  8012b1:	e8 d9 f3 ff ff       	call   80068f <sys_page_unmap>
  8012b6:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8012b9:	83 ec 08             	sub    $0x8,%esp
  8012bc:	ff 75 f4             	pushl  -0xc(%ebp)
  8012bf:	6a 00                	push   $0x0
  8012c1:	e8 c9 f3 ff ff       	call   80068f <sys_page_unmap>
  8012c6:	83 c4 10             	add    $0x10,%esp
  8012c9:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  8012cb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012ce:	5b                   	pop    %ebx
  8012cf:	5e                   	pop    %esi
  8012d0:	5d                   	pop    %ebp
  8012d1:	c3                   	ret    

008012d2 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8012d2:	55                   	push   %ebp
  8012d3:	89 e5                	mov    %esp,%ebp
  8012d5:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012d8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012db:	50                   	push   %eax
  8012dc:	ff 75 08             	pushl  0x8(%ebp)
  8012df:	e8 b2 f5 ff ff       	call   800896 <fd_lookup>
  8012e4:	83 c4 10             	add    $0x10,%esp
  8012e7:	85 c0                	test   %eax,%eax
  8012e9:	78 18                	js     801303 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8012eb:	83 ec 0c             	sub    $0xc,%esp
  8012ee:	ff 75 f4             	pushl  -0xc(%ebp)
  8012f1:	e8 15 f5 ff ff       	call   80080b <fd2data>
	return _pipeisclosed(fd, p);
  8012f6:	89 c2                	mov    %eax,%edx
  8012f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012fb:	e8 17 fd ff ff       	call   801017 <_pipeisclosed>
  801300:	83 c4 10             	add    $0x10,%esp
}
  801303:	c9                   	leave  
  801304:	c3                   	ret    

00801305 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801305:	55                   	push   %ebp
  801306:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801308:	b8 00 00 00 00       	mov    $0x0,%eax
  80130d:	5d                   	pop    %ebp
  80130e:	c3                   	ret    

0080130f <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80130f:	55                   	push   %ebp
  801310:	89 e5                	mov    %esp,%ebp
  801312:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801315:	68 e8 1f 80 00       	push   $0x801fe8
  80131a:	ff 75 0c             	pushl  0xc(%ebp)
  80131d:	e8 78 ee ff ff       	call   80019a <strcpy>
	return 0;
}
  801322:	b8 00 00 00 00       	mov    $0x0,%eax
  801327:	c9                   	leave  
  801328:	c3                   	ret    

00801329 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801329:	55                   	push   %ebp
  80132a:	89 e5                	mov    %esp,%ebp
  80132c:	57                   	push   %edi
  80132d:	56                   	push   %esi
  80132e:	53                   	push   %ebx
  80132f:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801335:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801339:	74 45                	je     801380 <devcons_write+0x57>
  80133b:	b8 00 00 00 00       	mov    $0x0,%eax
  801340:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801345:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80134b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80134e:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801350:	83 fb 7f             	cmp    $0x7f,%ebx
  801353:	76 05                	jbe    80135a <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801355:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  80135a:	83 ec 04             	sub    $0x4,%esp
  80135d:	53                   	push   %ebx
  80135e:	03 45 0c             	add    0xc(%ebp),%eax
  801361:	50                   	push   %eax
  801362:	57                   	push   %edi
  801363:	e8 ff ef ff ff       	call   800367 <memmove>
		sys_cputs(buf, m);
  801368:	83 c4 08             	add    $0x8,%esp
  80136b:	53                   	push   %ebx
  80136c:	57                   	push   %edi
  80136d:	e8 dc f1 ff ff       	call   80054e <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801372:	01 de                	add    %ebx,%esi
  801374:	89 f0                	mov    %esi,%eax
  801376:	83 c4 10             	add    $0x10,%esp
  801379:	3b 75 10             	cmp    0x10(%ebp),%esi
  80137c:	72 cd                	jb     80134b <devcons_write+0x22>
  80137e:	eb 05                	jmp    801385 <devcons_write+0x5c>
  801380:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801385:	89 f0                	mov    %esi,%eax
  801387:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80138a:	5b                   	pop    %ebx
  80138b:	5e                   	pop    %esi
  80138c:	5f                   	pop    %edi
  80138d:	5d                   	pop    %ebp
  80138e:	c3                   	ret    

0080138f <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80138f:	55                   	push   %ebp
  801390:	89 e5                	mov    %esp,%ebp
  801392:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801395:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801399:	75 07                	jne    8013a2 <devcons_read+0x13>
  80139b:	eb 23                	jmp    8013c0 <devcons_read+0x31>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80139d:	e8 49 f2 ff ff       	call   8005eb <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8013a2:	e8 c5 f1 ff ff       	call   80056c <sys_cgetc>
  8013a7:	85 c0                	test   %eax,%eax
  8013a9:	74 f2                	je     80139d <devcons_read+0xe>
		sys_yield();
	if (c < 0)
  8013ab:	85 c0                	test   %eax,%eax
  8013ad:	78 1d                	js     8013cc <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8013af:	83 f8 04             	cmp    $0x4,%eax
  8013b2:	74 13                	je     8013c7 <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  8013b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013b7:	88 02                	mov    %al,(%edx)
	return 1;
  8013b9:	b8 01 00 00 00       	mov    $0x1,%eax
  8013be:	eb 0c                	jmp    8013cc <devcons_read+0x3d>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8013c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8013c5:	eb 05                	jmp    8013cc <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8013c7:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8013cc:	c9                   	leave  
  8013cd:	c3                   	ret    

008013ce <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8013ce:	55                   	push   %ebp
  8013cf:	89 e5                	mov    %esp,%ebp
  8013d1:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8013d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d7:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8013da:	6a 01                	push   $0x1
  8013dc:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8013df:	50                   	push   %eax
  8013e0:	e8 69 f1 ff ff       	call   80054e <sys_cputs>
}
  8013e5:	83 c4 10             	add    $0x10,%esp
  8013e8:	c9                   	leave  
  8013e9:	c3                   	ret    

008013ea <getchar>:

int
getchar(void)
{
  8013ea:	55                   	push   %ebp
  8013eb:	89 e5                	mov    %esp,%ebp
  8013ed:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8013f0:	6a 01                	push   $0x1
  8013f2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8013f5:	50                   	push   %eax
  8013f6:	6a 00                	push   $0x0
  8013f8:	e8 1a f7 ff ff       	call   800b17 <read>
	if (r < 0)
  8013fd:	83 c4 10             	add    $0x10,%esp
  801400:	85 c0                	test   %eax,%eax
  801402:	78 0f                	js     801413 <getchar+0x29>
		return r;
	if (r < 1)
  801404:	85 c0                	test   %eax,%eax
  801406:	7e 06                	jle    80140e <getchar+0x24>
		return -E_EOF;
	return c;
  801408:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80140c:	eb 05                	jmp    801413 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80140e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801413:	c9                   	leave  
  801414:	c3                   	ret    

00801415 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801415:	55                   	push   %ebp
  801416:	89 e5                	mov    %esp,%ebp
  801418:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80141b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80141e:	50                   	push   %eax
  80141f:	ff 75 08             	pushl  0x8(%ebp)
  801422:	e8 6f f4 ff ff       	call   800896 <fd_lookup>
  801427:	83 c4 10             	add    $0x10,%esp
  80142a:	85 c0                	test   %eax,%eax
  80142c:	78 11                	js     80143f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80142e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801431:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801437:	39 10                	cmp    %edx,(%eax)
  801439:	0f 94 c0             	sete   %al
  80143c:	0f b6 c0             	movzbl %al,%eax
}
  80143f:	c9                   	leave  
  801440:	c3                   	ret    

00801441 <opencons>:

int
opencons(void)
{
  801441:	55                   	push   %ebp
  801442:	89 e5                	mov    %esp,%ebp
  801444:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801447:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80144a:	50                   	push   %eax
  80144b:	e8 d2 f3 ff ff       	call   800822 <fd_alloc>
  801450:	83 c4 10             	add    $0x10,%esp
  801453:	85 c0                	test   %eax,%eax
  801455:	78 3a                	js     801491 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801457:	83 ec 04             	sub    $0x4,%esp
  80145a:	68 07 04 00 00       	push   $0x407
  80145f:	ff 75 f4             	pushl  -0xc(%ebp)
  801462:	6a 00                	push   $0x0
  801464:	e8 a1 f1 ff ff       	call   80060a <sys_page_alloc>
  801469:	83 c4 10             	add    $0x10,%esp
  80146c:	85 c0                	test   %eax,%eax
  80146e:	78 21                	js     801491 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801470:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801476:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801479:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80147b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80147e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801485:	83 ec 0c             	sub    $0xc,%esp
  801488:	50                   	push   %eax
  801489:	e8 6d f3 ff ff       	call   8007fb <fd2num>
  80148e:	83 c4 10             	add    $0x10,%esp
}
  801491:	c9                   	leave  
  801492:	c3                   	ret    

00801493 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801493:	55                   	push   %ebp
  801494:	89 e5                	mov    %esp,%ebp
  801496:	56                   	push   %esi
  801497:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801498:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80149b:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8014a1:	e8 26 f1 ff ff       	call   8005cc <sys_getenvid>
  8014a6:	83 ec 0c             	sub    $0xc,%esp
  8014a9:	ff 75 0c             	pushl  0xc(%ebp)
  8014ac:	ff 75 08             	pushl  0x8(%ebp)
  8014af:	56                   	push   %esi
  8014b0:	50                   	push   %eax
  8014b1:	68 f4 1f 80 00       	push   $0x801ff4
  8014b6:	e8 b0 00 00 00       	call   80156b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8014bb:	83 c4 18             	add    $0x18,%esp
  8014be:	53                   	push   %ebx
  8014bf:	ff 75 10             	pushl  0x10(%ebp)
  8014c2:	e8 53 00 00 00       	call   80151a <vcprintf>
	cprintf("\n");
  8014c7:	c7 04 24 e1 1f 80 00 	movl   $0x801fe1,(%esp)
  8014ce:	e8 98 00 00 00       	call   80156b <cprintf>
  8014d3:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8014d6:	cc                   	int3   
  8014d7:	eb fd                	jmp    8014d6 <_panic+0x43>

008014d9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8014d9:	55                   	push   %ebp
  8014da:	89 e5                	mov    %esp,%ebp
  8014dc:	53                   	push   %ebx
  8014dd:	83 ec 04             	sub    $0x4,%esp
  8014e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8014e3:	8b 13                	mov    (%ebx),%edx
  8014e5:	8d 42 01             	lea    0x1(%edx),%eax
  8014e8:	89 03                	mov    %eax,(%ebx)
  8014ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014ed:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8014f1:	3d ff 00 00 00       	cmp    $0xff,%eax
  8014f6:	75 1a                	jne    801512 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8014f8:	83 ec 08             	sub    $0x8,%esp
  8014fb:	68 ff 00 00 00       	push   $0xff
  801500:	8d 43 08             	lea    0x8(%ebx),%eax
  801503:	50                   	push   %eax
  801504:	e8 45 f0 ff ff       	call   80054e <sys_cputs>
		b->idx = 0;
  801509:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80150f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801512:	ff 43 04             	incl   0x4(%ebx)
}
  801515:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801518:	c9                   	leave  
  801519:	c3                   	ret    

0080151a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80151a:	55                   	push   %ebp
  80151b:	89 e5                	mov    %esp,%ebp
  80151d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801523:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80152a:	00 00 00 
	b.cnt = 0;
  80152d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801534:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801537:	ff 75 0c             	pushl  0xc(%ebp)
  80153a:	ff 75 08             	pushl  0x8(%ebp)
  80153d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801543:	50                   	push   %eax
  801544:	68 d9 14 80 00       	push   $0x8014d9
  801549:	e8 54 01 00 00       	call   8016a2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80154e:	83 c4 08             	add    $0x8,%esp
  801551:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801557:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80155d:	50                   	push   %eax
  80155e:	e8 eb ef ff ff       	call   80054e <sys_cputs>

	return b.cnt;
}
  801563:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801569:	c9                   	leave  
  80156a:	c3                   	ret    

0080156b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80156b:	55                   	push   %ebp
  80156c:	89 e5                	mov    %esp,%ebp
  80156e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801571:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801574:	50                   	push   %eax
  801575:	ff 75 08             	pushl  0x8(%ebp)
  801578:	e8 9d ff ff ff       	call   80151a <vcprintf>
	va_end(ap);

	return cnt;
}
  80157d:	c9                   	leave  
  80157e:	c3                   	ret    

0080157f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80157f:	55                   	push   %ebp
  801580:	89 e5                	mov    %esp,%ebp
  801582:	57                   	push   %edi
  801583:	56                   	push   %esi
  801584:	53                   	push   %ebx
  801585:	83 ec 1c             	sub    $0x1c,%esp
  801588:	89 c6                	mov    %eax,%esi
  80158a:	89 d7                	mov    %edx,%edi
  80158c:	8b 45 08             	mov    0x8(%ebp),%eax
  80158f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801592:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801595:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801598:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80159b:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015a0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8015a3:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8015a6:	39 d3                	cmp    %edx,%ebx
  8015a8:	72 11                	jb     8015bb <printnum+0x3c>
  8015aa:	39 45 10             	cmp    %eax,0x10(%ebp)
  8015ad:	76 0c                	jbe    8015bb <printnum+0x3c>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8015af:	8b 45 14             	mov    0x14(%ebp),%eax
  8015b2:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8015b5:	85 db                	test   %ebx,%ebx
  8015b7:	7f 37                	jg     8015f0 <printnum+0x71>
  8015b9:	eb 44                	jmp    8015ff <printnum+0x80>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8015bb:	83 ec 0c             	sub    $0xc,%esp
  8015be:	ff 75 18             	pushl  0x18(%ebp)
  8015c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8015c4:	48                   	dec    %eax
  8015c5:	50                   	push   %eax
  8015c6:	ff 75 10             	pushl  0x10(%ebp)
  8015c9:	83 ec 08             	sub    $0x8,%esp
  8015cc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015cf:	ff 75 e0             	pushl  -0x20(%ebp)
  8015d2:	ff 75 dc             	pushl  -0x24(%ebp)
  8015d5:	ff 75 d8             	pushl  -0x28(%ebp)
  8015d8:	e8 8f 06 00 00       	call   801c6c <__udivdi3>
  8015dd:	83 c4 18             	add    $0x18,%esp
  8015e0:	52                   	push   %edx
  8015e1:	50                   	push   %eax
  8015e2:	89 fa                	mov    %edi,%edx
  8015e4:	89 f0                	mov    %esi,%eax
  8015e6:	e8 94 ff ff ff       	call   80157f <printnum>
  8015eb:	83 c4 20             	add    $0x20,%esp
  8015ee:	eb 0f                	jmp    8015ff <printnum+0x80>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8015f0:	83 ec 08             	sub    $0x8,%esp
  8015f3:	57                   	push   %edi
  8015f4:	ff 75 18             	pushl  0x18(%ebp)
  8015f7:	ff d6                	call   *%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8015f9:	83 c4 10             	add    $0x10,%esp
  8015fc:	4b                   	dec    %ebx
  8015fd:	75 f1                	jne    8015f0 <printnum+0x71>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8015ff:	83 ec 08             	sub    $0x8,%esp
  801602:	57                   	push   %edi
  801603:	83 ec 04             	sub    $0x4,%esp
  801606:	ff 75 e4             	pushl  -0x1c(%ebp)
  801609:	ff 75 e0             	pushl  -0x20(%ebp)
  80160c:	ff 75 dc             	pushl  -0x24(%ebp)
  80160f:	ff 75 d8             	pushl  -0x28(%ebp)
  801612:	e8 65 07 00 00       	call   801d7c <__umoddi3>
  801617:	83 c4 14             	add    $0x14,%esp
  80161a:	0f be 80 17 20 80 00 	movsbl 0x802017(%eax),%eax
  801621:	50                   	push   %eax
  801622:	ff d6                	call   *%esi
}
  801624:	83 c4 10             	add    $0x10,%esp
  801627:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80162a:	5b                   	pop    %ebx
  80162b:	5e                   	pop    %esi
  80162c:	5f                   	pop    %edi
  80162d:	5d                   	pop    %ebp
  80162e:	c3                   	ret    

0080162f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80162f:	55                   	push   %ebp
  801630:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801632:	83 fa 01             	cmp    $0x1,%edx
  801635:	7e 0e                	jle    801645 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801637:	8b 10                	mov    (%eax),%edx
  801639:	8d 4a 08             	lea    0x8(%edx),%ecx
  80163c:	89 08                	mov    %ecx,(%eax)
  80163e:	8b 02                	mov    (%edx),%eax
  801640:	8b 52 04             	mov    0x4(%edx),%edx
  801643:	eb 22                	jmp    801667 <getuint+0x38>
	else if (lflag)
  801645:	85 d2                	test   %edx,%edx
  801647:	74 10                	je     801659 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801649:	8b 10                	mov    (%eax),%edx
  80164b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80164e:	89 08                	mov    %ecx,(%eax)
  801650:	8b 02                	mov    (%edx),%eax
  801652:	ba 00 00 00 00       	mov    $0x0,%edx
  801657:	eb 0e                	jmp    801667 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801659:	8b 10                	mov    (%eax),%edx
  80165b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80165e:	89 08                	mov    %ecx,(%eax)
  801660:	8b 02                	mov    (%edx),%eax
  801662:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801667:	5d                   	pop    %ebp
  801668:	c3                   	ret    

00801669 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801669:	55                   	push   %ebp
  80166a:	89 e5                	mov    %esp,%ebp
  80166c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80166f:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  801672:	8b 10                	mov    (%eax),%edx
  801674:	3b 50 04             	cmp    0x4(%eax),%edx
  801677:	73 0a                	jae    801683 <sprintputch+0x1a>
		*b->buf++ = ch;
  801679:	8d 4a 01             	lea    0x1(%edx),%ecx
  80167c:	89 08                	mov    %ecx,(%eax)
  80167e:	8b 45 08             	mov    0x8(%ebp),%eax
  801681:	88 02                	mov    %al,(%edx)
}
  801683:	5d                   	pop    %ebp
  801684:	c3                   	ret    

00801685 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801685:	55                   	push   %ebp
  801686:	89 e5                	mov    %esp,%ebp
  801688:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80168b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80168e:	50                   	push   %eax
  80168f:	ff 75 10             	pushl  0x10(%ebp)
  801692:	ff 75 0c             	pushl  0xc(%ebp)
  801695:	ff 75 08             	pushl  0x8(%ebp)
  801698:	e8 05 00 00 00       	call   8016a2 <vprintfmt>
	va_end(ap);
}
  80169d:	83 c4 10             	add    $0x10,%esp
  8016a0:	c9                   	leave  
  8016a1:	c3                   	ret    

008016a2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8016a2:	55                   	push   %ebp
  8016a3:	89 e5                	mov    %esp,%ebp
  8016a5:	57                   	push   %edi
  8016a6:	56                   	push   %esi
  8016a7:	53                   	push   %ebx
  8016a8:	83 ec 2c             	sub    $0x2c,%esp
  8016ab:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016b1:	eb 03                	jmp    8016b6 <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  8016b3:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  8016b6:	8b 45 10             	mov    0x10(%ebp),%eax
  8016b9:	8d 70 01             	lea    0x1(%eax),%esi
  8016bc:	0f b6 00             	movzbl (%eax),%eax
  8016bf:	83 f8 25             	cmp    $0x25,%eax
  8016c2:	74 25                	je     8016e9 <vprintfmt+0x47>
			if (ch == '\0')									//当然中间如果遇到'\0'，代表这个字符串的访问结束
  8016c4:	85 c0                	test   %eax,%eax
  8016c6:	75 0d                	jne    8016d5 <vprintfmt+0x33>
  8016c8:	e9 b5 03 00 00       	jmp    801a82 <vprintfmt+0x3e0>
  8016cd:	85 c0                	test   %eax,%eax
  8016cf:	0f 84 ad 03 00 00    	je     801a82 <vprintfmt+0x3e0>
				return;
			putch(ch, putdat);								//调用putch函数，把一个字符ch输出到putdat指针所指向的地址中所存放的值对应的地址处
  8016d5:	83 ec 08             	sub    $0x8,%esp
  8016d8:	53                   	push   %ebx
  8016d9:	50                   	push   %eax
  8016da:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  8016dc:	46                   	inc    %esi
  8016dd:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  8016e1:	83 c4 10             	add    $0x10,%esp
  8016e4:	83 f8 25             	cmp    $0x25,%eax
  8016e7:	75 e4                	jne    8016cd <vprintfmt+0x2b>
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  8016e9:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  8016ed:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8016f4:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8016fb:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  801702:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  801709:	eb 07                	jmp    801712 <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80170b:	8b 75 10             	mov    0x10(%ebp),%esi

		// flag to pad on the right
		case '-':											//%后面的'-'代表要进行左对齐输出，右边填空格，如果省略代表右对齐
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
  80170e:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  801712:	8d 46 01             	lea    0x1(%esi),%eax
  801715:	89 45 10             	mov    %eax,0x10(%ebp)
  801718:	0f b6 16             	movzbl (%esi),%edx
  80171b:	8a 06                	mov    (%esi),%al
  80171d:	83 e8 23             	sub    $0x23,%eax
  801720:	3c 55                	cmp    $0x55,%al
  801722:	0f 87 03 03 00 00    	ja     801a2b <vprintfmt+0x389>
  801728:	0f b6 c0             	movzbl %al,%eax
  80172b:	ff 24 85 60 21 80 00 	jmp    *0x802160(,%eax,4)
  801732:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
			goto reswitch;									//处理下一个字符

		// flag to pad with 0's instead of spaces
		case '0':											//0--有0表示进行对齐输出时填0,如省略表示填入空格，并且如果为0，则一定是右对齐
			padc = '0';										//对其方式标志位变为0
  801735:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  801739:	eb d7                	jmp    801712 <vprintfmt+0x70>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
				precision = precision * 10 + ch - '0';
  80173b:	8d 42 d0             	lea    -0x30(%edx),%eax
  80173e:	89 c1                	mov    %eax,%ecx
  801740:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  801743:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  801747:	8d 50 d0             	lea    -0x30(%eax),%edx
  80174a:	83 fa 09             	cmp    $0x9,%edx
  80174d:	77 51                	ja     8017a0 <vprintfmt+0xfe>
  80174f:	8b 75 10             	mov    0x10(%ebp),%esi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
  801752:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  801753:	8d 14 89             	lea    (%ecx,%ecx,4),%edx
  801756:	01 d2                	add    %edx,%edx
  801758:	8d 4c 10 d0          	lea    -0x30(%eax,%edx,1),%ecx
				ch = *fmt;
  80175c:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80175f:	8d 50 d0             	lea    -0x30(%eax),%edx
  801762:	83 fa 09             	cmp    $0x9,%edx
  801765:	76 eb                	jbe    801752 <vprintfmt+0xb0>
  801767:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80176a:	eb 37                	jmp    8017a3 <vprintfmt+0x101>
					break;
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
  80176c:	8b 45 14             	mov    0x14(%ebp),%eax
  80176f:	8d 50 04             	lea    0x4(%eax),%edx
  801772:	89 55 14             	mov    %edx,0x14(%ebp)
  801775:	8b 00                	mov    (%eax),%eax
  801777:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80177a:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
			goto process_precision;
  80177d:	eb 24                	jmp    8017a3 <vprintfmt+0x101>
  80177f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801783:	79 07                	jns    80178c <vprintfmt+0xea>
  801785:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80178c:	8b 75 10             	mov    0x10(%ebp),%esi
  80178f:	eb 81                	jmp    801712 <vprintfmt+0x70>
  801791:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  801794:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80179b:	e9 72 ff ff ff       	jmp    801712 <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8017a0:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:									//处理输出精度，把width字段赋值为刚刚计算出来的precision值，所以width应该是整数部分的有效数字位数
			if (width < 0)
  8017a3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8017a7:	0f 89 65 ff ff ff    	jns    801712 <vprintfmt+0x70>
				width = precision, precision = -1;
  8017ad:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8017b0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8017b3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8017ba:	e9 53 ff ff ff       	jmp    801712 <vprintfmt+0x70>
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
  8017bf:	ff 45 d4             	incl   -0x2c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8017c2:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
			goto reswitch;
  8017c5:	e9 48 ff ff ff       	jmp    801712 <vprintfmt+0x70>

		// character
		case 'c':											//如果是'c'代表显示一个字符
			putch(va_arg(ap, int), putdat);					//调用输出一个字符到内存的函数putch
  8017ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8017cd:	8d 50 04             	lea    0x4(%eax),%edx
  8017d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8017d3:	83 ec 08             	sub    $0x8,%esp
  8017d6:	53                   	push   %ebx
  8017d7:	ff 30                	pushl  (%eax)
  8017d9:	ff d7                	call   *%edi
			break;
  8017db:	83 c4 10             	add    $0x10,%esp
  8017de:	e9 d3 fe ff ff       	jmp    8016b6 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8017e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8017e6:	8d 50 04             	lea    0x4(%eax),%edx
  8017e9:	89 55 14             	mov    %edx,0x14(%ebp)
  8017ec:	8b 00                	mov    (%eax),%eax
  8017ee:	85 c0                	test   %eax,%eax
  8017f0:	79 02                	jns    8017f4 <vprintfmt+0x152>
  8017f2:	f7 d8                	neg    %eax
  8017f4:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8017f6:	83 f8 0f             	cmp    $0xf,%eax
  8017f9:	7f 0b                	jg     801806 <vprintfmt+0x164>
  8017fb:	8b 04 85 c0 22 80 00 	mov    0x8022c0(,%eax,4),%eax
  801802:	85 c0                	test   %eax,%eax
  801804:	75 15                	jne    80181b <vprintfmt+0x179>
				printfmt(putch, putdat, "error %d", err);
  801806:	52                   	push   %edx
  801807:	68 2f 20 80 00       	push   $0x80202f
  80180c:	53                   	push   %ebx
  80180d:	57                   	push   %edi
  80180e:	e8 72 fe ff ff       	call   801685 <printfmt>
  801813:	83 c4 10             	add    $0x10,%esp
  801816:	e9 9b fe ff ff       	jmp    8016b6 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  80181b:	50                   	push   %eax
  80181c:	68 af 1f 80 00       	push   $0x801faf
  801821:	53                   	push   %ebx
  801822:	57                   	push   %edi
  801823:	e8 5d fe ff ff       	call   801685 <printfmt>
  801828:	83 c4 10             	add    $0x10,%esp
  80182b:	e9 86 fe ff ff       	jmp    8016b6 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801830:	8b 45 14             	mov    0x14(%ebp),%eax
  801833:	8d 50 04             	lea    0x4(%eax),%edx
  801836:	89 55 14             	mov    %edx,0x14(%ebp)
  801839:	8b 00                	mov    (%eax),%eax
  80183b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80183e:	85 c0                	test   %eax,%eax
  801840:	75 07                	jne    801849 <vprintfmt+0x1a7>
				p = "(null)";
  801842:	c7 45 d4 28 20 80 00 	movl   $0x802028,-0x2c(%ebp)
			if (width > 0 && padc != '-')
  801849:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80184c:	85 f6                	test   %esi,%esi
  80184e:	0f 8e fb 01 00 00    	jle    801a4f <vprintfmt+0x3ad>
  801854:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  801858:	0f 84 09 02 00 00    	je     801a67 <vprintfmt+0x3c5>
				for (width -= strnlen(p, precision); width > 0; width--)
  80185e:	83 ec 08             	sub    $0x8,%esp
  801861:	ff 75 d0             	pushl  -0x30(%ebp)
  801864:	ff 75 d4             	pushl  -0x2c(%ebp)
  801867:	e8 f7 e8 ff ff       	call   800163 <strnlen>
  80186c:	89 f1                	mov    %esi,%ecx
  80186e:	29 c1                	sub    %eax,%ecx
  801870:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  801873:	83 c4 10             	add    $0x10,%esp
  801876:	85 c9                	test   %ecx,%ecx
  801878:	0f 8e d1 01 00 00    	jle    801a4f <vprintfmt+0x3ad>
					putch(padc, putdat);
  80187e:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  801882:	83 ec 08             	sub    $0x8,%esp
  801885:	53                   	push   %ebx
  801886:	56                   	push   %esi
  801887:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801889:	83 c4 10             	add    $0x10,%esp
  80188c:	ff 4d e4             	decl   -0x1c(%ebp)
  80188f:	75 f1                	jne    801882 <vprintfmt+0x1e0>
  801891:	e9 b9 01 00 00       	jmp    801a4f <vprintfmt+0x3ad>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801896:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80189a:	74 19                	je     8018b5 <vprintfmt+0x213>
  80189c:	0f be c0             	movsbl %al,%eax
  80189f:	83 e8 20             	sub    $0x20,%eax
  8018a2:	83 f8 5e             	cmp    $0x5e,%eax
  8018a5:	76 0e                	jbe    8018b5 <vprintfmt+0x213>
					putch('?', putdat);
  8018a7:	83 ec 08             	sub    $0x8,%esp
  8018aa:	53                   	push   %ebx
  8018ab:	6a 3f                	push   $0x3f
  8018ad:	ff 55 08             	call   *0x8(%ebp)
  8018b0:	83 c4 10             	add    $0x10,%esp
  8018b3:	eb 0b                	jmp    8018c0 <vprintfmt+0x21e>
				else
					putch(ch, putdat);
  8018b5:	83 ec 08             	sub    $0x8,%esp
  8018b8:	53                   	push   %ebx
  8018b9:	52                   	push   %edx
  8018ba:	ff 55 08             	call   *0x8(%ebp)
  8018bd:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8018c0:	ff 4d e4             	decl   -0x1c(%ebp)
  8018c3:	46                   	inc    %esi
  8018c4:	8a 46 ff             	mov    -0x1(%esi),%al
  8018c7:	0f be d0             	movsbl %al,%edx
  8018ca:	85 d2                	test   %edx,%edx
  8018cc:	75 1c                	jne    8018ea <vprintfmt+0x248>
  8018ce:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8018d1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8018d5:	7f 1f                	jg     8018f6 <vprintfmt+0x254>
  8018d7:	e9 da fd ff ff       	jmp    8016b6 <vprintfmt+0x14>
  8018dc:	89 7d 08             	mov    %edi,0x8(%ebp)
  8018df:	8b 7d d0             	mov    -0x30(%ebp),%edi
  8018e2:	eb 06                	jmp    8018ea <vprintfmt+0x248>
  8018e4:	89 7d 08             	mov    %edi,0x8(%ebp)
  8018e7:	8b 7d d0             	mov    -0x30(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8018ea:	85 ff                	test   %edi,%edi
  8018ec:	78 a8                	js     801896 <vprintfmt+0x1f4>
  8018ee:	4f                   	dec    %edi
  8018ef:	79 a5                	jns    801896 <vprintfmt+0x1f4>
  8018f1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8018f4:	eb db                	jmp    8018d1 <vprintfmt+0x22f>
  8018f6:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8018f9:	83 ec 08             	sub    $0x8,%esp
  8018fc:	53                   	push   %ebx
  8018fd:	6a 20                	push   $0x20
  8018ff:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801901:	4e                   	dec    %esi
  801902:	83 c4 10             	add    $0x10,%esp
  801905:	85 f6                	test   %esi,%esi
  801907:	7f f0                	jg     8018f9 <vprintfmt+0x257>
  801909:	e9 a8 fd ff ff       	jmp    8016b6 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80190e:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  801912:	7e 16                	jle    80192a <vprintfmt+0x288>
		return va_arg(*ap, long long);
  801914:	8b 45 14             	mov    0x14(%ebp),%eax
  801917:	8d 50 08             	lea    0x8(%eax),%edx
  80191a:	89 55 14             	mov    %edx,0x14(%ebp)
  80191d:	8b 50 04             	mov    0x4(%eax),%edx
  801920:	8b 00                	mov    (%eax),%eax
  801922:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801925:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801928:	eb 34                	jmp    80195e <vprintfmt+0x2bc>
	else if (lflag)
  80192a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80192e:	74 18                	je     801948 <vprintfmt+0x2a6>
		return va_arg(*ap, long);
  801930:	8b 45 14             	mov    0x14(%ebp),%eax
  801933:	8d 50 04             	lea    0x4(%eax),%edx
  801936:	89 55 14             	mov    %edx,0x14(%ebp)
  801939:	8b 30                	mov    (%eax),%esi
  80193b:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80193e:	89 f0                	mov    %esi,%eax
  801940:	c1 f8 1f             	sar    $0x1f,%eax
  801943:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801946:	eb 16                	jmp    80195e <vprintfmt+0x2bc>
	else
		return va_arg(*ap, int);
  801948:	8b 45 14             	mov    0x14(%ebp),%eax
  80194b:	8d 50 04             	lea    0x4(%eax),%edx
  80194e:	89 55 14             	mov    %edx,0x14(%ebp)
  801951:	8b 30                	mov    (%eax),%esi
  801953:	89 75 d8             	mov    %esi,-0x28(%ebp)
  801956:	89 f0                	mov    %esi,%eax
  801958:	c1 f8 1f             	sar    $0x1f,%eax
  80195b:	89 45 dc             	mov    %eax,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80195e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801961:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
  801964:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801968:	0f 89 8a 00 00 00    	jns    8019f8 <vprintfmt+0x356>
				putch('-', putdat);
  80196e:	83 ec 08             	sub    $0x8,%esp
  801971:	53                   	push   %ebx
  801972:	6a 2d                	push   $0x2d
  801974:	ff d7                	call   *%edi
				num = -(long long) num;
  801976:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801979:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80197c:	f7 d8                	neg    %eax
  80197e:	83 d2 00             	adc    $0x0,%edx
  801981:	f7 da                	neg    %edx
  801983:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801986:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80198b:	eb 70                	jmp    8019fd <vprintfmt+0x35b>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80198d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  801990:	8d 45 14             	lea    0x14(%ebp),%eax
  801993:	e8 97 fc ff ff       	call   80162f <getuint>
			base = 10;
  801998:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80199d:	eb 5e                	jmp    8019fd <vprintfmt+0x35b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  80199f:	83 ec 08             	sub    $0x8,%esp
  8019a2:	53                   	push   %ebx
  8019a3:	6a 30                	push   $0x30
  8019a5:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  8019a7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8019aa:	8d 45 14             	lea    0x14(%ebp),%eax
  8019ad:	e8 7d fc ff ff       	call   80162f <getuint>
			base = 8;
			goto number;
  8019b2:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  8019b5:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8019ba:	eb 41                	jmp    8019fd <vprintfmt+0x35b>
		// pointer
		case 'p':
			putch('0', putdat);
  8019bc:	83 ec 08             	sub    $0x8,%esp
  8019bf:	53                   	push   %ebx
  8019c0:	6a 30                	push   $0x30
  8019c2:	ff d7                	call   *%edi
			putch('x', putdat);
  8019c4:	83 c4 08             	add    $0x8,%esp
  8019c7:	53                   	push   %ebx
  8019c8:	6a 78                	push   $0x78
  8019ca:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8019cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8019cf:	8d 50 04             	lea    0x4(%eax),%edx
  8019d2:	89 55 14             	mov    %edx,0x14(%ebp)
			goto number;
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8019d5:	8b 00                	mov    (%eax),%eax
  8019d7:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8019dc:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8019df:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8019e4:	eb 17                	jmp    8019fd <vprintfmt+0x35b>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8019e6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8019e9:	8d 45 14             	lea    0x14(%ebp),%eax
  8019ec:	e8 3e fc ff ff       	call   80162f <getuint>
			base = 16;
  8019f1:	b9 10 00 00 00       	mov    $0x10,%ecx
  8019f6:	eb 05                	jmp    8019fd <vprintfmt+0x35b>
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8019f8:	b9 0a 00 00 00       	mov    $0xa,%ecx
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8019fd:	83 ec 0c             	sub    $0xc,%esp
  801a00:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  801a04:	56                   	push   %esi
  801a05:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a08:	51                   	push   %ecx
  801a09:	52                   	push   %edx
  801a0a:	50                   	push   %eax
  801a0b:	89 da                	mov    %ebx,%edx
  801a0d:	89 f8                	mov    %edi,%eax
  801a0f:	e8 6b fb ff ff       	call   80157f <printnum>
			break;
  801a14:	83 c4 20             	add    $0x20,%esp
  801a17:	e9 9a fc ff ff       	jmp    8016b6 <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801a1c:	83 ec 08             	sub    $0x8,%esp
  801a1f:	53                   	push   %ebx
  801a20:	52                   	push   %edx
  801a21:	ff d7                	call   *%edi
			break;
  801a23:	83 c4 10             	add    $0x10,%esp
  801a26:	e9 8b fc ff ff       	jmp    8016b6 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801a2b:	83 ec 08             	sub    $0x8,%esp
  801a2e:	53                   	push   %ebx
  801a2f:	6a 25                	push   $0x25
  801a31:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801a33:	83 c4 10             	add    $0x10,%esp
  801a36:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  801a3a:	0f 84 73 fc ff ff    	je     8016b3 <vprintfmt+0x11>
  801a40:	4e                   	dec    %esi
  801a41:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  801a45:	75 f9                	jne    801a40 <vprintfmt+0x39e>
  801a47:	89 75 10             	mov    %esi,0x10(%ebp)
  801a4a:	e9 67 fc ff ff       	jmp    8016b6 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801a4f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801a52:	8d 70 01             	lea    0x1(%eax),%esi
  801a55:	8a 00                	mov    (%eax),%al
  801a57:	0f be d0             	movsbl %al,%edx
  801a5a:	85 d2                	test   %edx,%edx
  801a5c:	0f 85 7a fe ff ff    	jne    8018dc <vprintfmt+0x23a>
  801a62:	e9 4f fc ff ff       	jmp    8016b6 <vprintfmt+0x14>
  801a67:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801a6a:	8d 70 01             	lea    0x1(%eax),%esi
  801a6d:	8a 00                	mov    (%eax),%al
  801a6f:	0f be d0             	movsbl %al,%edx
  801a72:	85 d2                	test   %edx,%edx
  801a74:	0f 85 6a fe ff ff    	jne    8018e4 <vprintfmt+0x242>
  801a7a:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801a7d:	e9 77 fe ff ff       	jmp    8018f9 <vprintfmt+0x257>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  801a82:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a85:	5b                   	pop    %ebx
  801a86:	5e                   	pop    %esi
  801a87:	5f                   	pop    %edi
  801a88:	5d                   	pop    %ebp
  801a89:	c3                   	ret    

00801a8a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801a8a:	55                   	push   %ebp
  801a8b:	89 e5                	mov    %esp,%ebp
  801a8d:	83 ec 18             	sub    $0x18,%esp
  801a90:	8b 45 08             	mov    0x8(%ebp),%eax
  801a93:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801a96:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801a99:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801a9d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801aa0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801aa7:	85 c0                	test   %eax,%eax
  801aa9:	74 26                	je     801ad1 <vsnprintf+0x47>
  801aab:	85 d2                	test   %edx,%edx
  801aad:	7e 29                	jle    801ad8 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801aaf:	ff 75 14             	pushl  0x14(%ebp)
  801ab2:	ff 75 10             	pushl  0x10(%ebp)
  801ab5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801ab8:	50                   	push   %eax
  801ab9:	68 69 16 80 00       	push   $0x801669
  801abe:	e8 df fb ff ff       	call   8016a2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801ac3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801ac6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801ac9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801acc:	83 c4 10             	add    $0x10,%esp
  801acf:	eb 0c                	jmp    801add <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801ad1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801ad6:	eb 05                	jmp    801add <vsnprintf+0x53>
  801ad8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801add:	c9                   	leave  
  801ade:	c3                   	ret    

00801adf <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801adf:	55                   	push   %ebp
  801ae0:	89 e5                	mov    %esp,%ebp
  801ae2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801ae5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801ae8:	50                   	push   %eax
  801ae9:	ff 75 10             	pushl  0x10(%ebp)
  801aec:	ff 75 0c             	pushl  0xc(%ebp)
  801aef:	ff 75 08             	pushl  0x8(%ebp)
  801af2:	e8 93 ff ff ff       	call   801a8a <vsnprintf>
	va_end(ap);

	return rc;
}
  801af7:	c9                   	leave  
  801af8:	c3                   	ret    

00801af9 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801af9:	55                   	push   %ebp
  801afa:	89 e5                	mov    %esp,%ebp
  801afc:	56                   	push   %esi
  801afd:	53                   	push   %ebx
  801afe:	8b 75 08             	mov    0x8(%ebp),%esi
  801b01:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b04:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");
	int r;
    if (pg != NULL) {
  801b07:	85 c0                	test   %eax,%eax
  801b09:	74 0e                	je     801b19 <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  801b0b:	83 ec 0c             	sub    $0xc,%esp
  801b0e:	50                   	push   %eax
  801b0f:	e8 a6 ec ff ff       	call   8007ba <sys_ipc_recv>
  801b14:	83 c4 10             	add    $0x10,%esp
  801b17:	eb 10                	jmp    801b29 <ipc_recv+0x30>
    } else {
        r = sys_ipc_recv((void *) UTOP);
  801b19:	83 ec 0c             	sub    $0xc,%esp
  801b1c:	68 00 00 c0 ee       	push   $0xeec00000
  801b21:	e8 94 ec ff ff       	call   8007ba <sys_ipc_recv>
  801b26:	83 c4 10             	add    $0x10,%esp
    }
    if (r < 0) {
  801b29:	85 c0                	test   %eax,%eax
  801b2b:	79 16                	jns    801b43 <ipc_recv+0x4a>
        // failed
        if (from_env_store != NULL) *from_env_store = 0;
  801b2d:	85 f6                	test   %esi,%esi
  801b2f:	74 06                	je     801b37 <ipc_recv+0x3e>
  801b31:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL) *perm_store = 0;
  801b37:	85 db                	test   %ebx,%ebx
  801b39:	74 2c                	je     801b67 <ipc_recv+0x6e>
  801b3b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801b41:	eb 24                	jmp    801b67 <ipc_recv+0x6e>
        return r;
    } else {
        if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801b43:	85 f6                	test   %esi,%esi
  801b45:	74 0a                	je     801b51 <ipc_recv+0x58>
  801b47:	a1 04 40 80 00       	mov    0x804004,%eax
  801b4c:	8b 40 74             	mov    0x74(%eax),%eax
  801b4f:	89 06                	mov    %eax,(%esi)
        if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801b51:	85 db                	test   %ebx,%ebx
  801b53:	74 0a                	je     801b5f <ipc_recv+0x66>
  801b55:	a1 04 40 80 00       	mov    0x804004,%eax
  801b5a:	8b 40 78             	mov    0x78(%eax),%eax
  801b5d:	89 03                	mov    %eax,(%ebx)
        return thisenv->env_ipc_value;
  801b5f:	a1 04 40 80 00       	mov    0x804004,%eax
  801b64:	8b 40 70             	mov    0x70(%eax),%eax
    }
 
	return 0;
}
  801b67:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b6a:	5b                   	pop    %ebx
  801b6b:	5e                   	pop    %esi
  801b6c:	5d                   	pop    %ebp
  801b6d:	c3                   	ret    

00801b6e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b6e:	55                   	push   %ebp
  801b6f:	89 e5                	mov    %esp,%ebp
  801b71:	57                   	push   %edi
  801b72:	56                   	push   %esi
  801b73:	53                   	push   %ebx
  801b74:	83 ec 0c             	sub    $0xc,%esp
  801b77:	8b 75 10             	mov    0x10(%ebp),%esi
  801b7a:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;
    if (pg == NULL) pg = (void *)UTOP;
  801b7d:	85 f6                	test   %esi,%esi
  801b7f:	75 05                	jne    801b86 <ipc_send+0x18>
  801b81:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
  801b86:	57                   	push   %edi
  801b87:	56                   	push   %esi
  801b88:	ff 75 0c             	pushl  0xc(%ebp)
  801b8b:	ff 75 08             	pushl  0x8(%ebp)
  801b8e:	e8 04 ec ff ff       	call   800797 <sys_ipc_try_send>
  801b93:	89 c3                	mov    %eax,%ebx
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
  801b95:	83 c4 10             	add    $0x10,%esp
  801b98:	85 c0                	test   %eax,%eax
  801b9a:	79 17                	jns    801bb3 <ipc_send+0x45>
  801b9c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b9f:	74 1d                	je     801bbe <ipc_send+0x50>
  801ba1:	50                   	push   %eax
  801ba2:	68 20 23 80 00       	push   $0x802320
  801ba7:	6a 40                	push   $0x40
  801ba9:	68 34 23 80 00       	push   $0x802334
  801bae:	e8 e0 f8 ff ff       	call   801493 <_panic>
        sys_yield();
  801bb3:	e8 33 ea ff ff       	call   8005eb <sys_yield>
    } while (r != 0);
  801bb8:	85 db                	test   %ebx,%ebx
  801bba:	75 ca                	jne    801b86 <ipc_send+0x18>
  801bbc:	eb 07                	jmp    801bc5 <ipc_send+0x57>
	int r;
    if (pg == NULL) pg = (void *)UTOP;
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
        sys_yield();
  801bbe:	e8 28 ea ff ff       	call   8005eb <sys_yield>
  801bc3:	eb c1                	jmp    801b86 <ipc_send+0x18>
    } while (r != 0);
}
  801bc5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bc8:	5b                   	pop    %ebx
  801bc9:	5e                   	pop    %esi
  801bca:	5f                   	pop    %edi
  801bcb:	5d                   	pop    %ebp
  801bcc:	c3                   	ret    

00801bcd <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801bcd:	55                   	push   %ebp
  801bce:	89 e5                	mov    %esp,%ebp
  801bd0:	53                   	push   %ebx
  801bd1:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801bd4:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801bd9:	39 c1                	cmp    %eax,%ecx
  801bdb:	74 21                	je     801bfe <ipc_find_env+0x31>
  801bdd:	ba 01 00 00 00       	mov    $0x1,%edx
  801be2:	8d 1c 95 00 00 00 00 	lea    0x0(,%edx,4),%ebx
  801be9:	89 d0                	mov    %edx,%eax
  801beb:	c1 e0 07             	shl    $0x7,%eax
  801bee:	29 d8                	sub    %ebx,%eax
  801bf0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801bf5:	8b 40 50             	mov    0x50(%eax),%eax
  801bf8:	39 c8                	cmp    %ecx,%eax
  801bfa:	75 1b                	jne    801c17 <ipc_find_env+0x4a>
  801bfc:	eb 05                	jmp    801c03 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801bfe:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801c03:	8d 04 95 00 00 00 00 	lea    0x0(,%edx,4),%eax
  801c0a:	c1 e2 07             	shl    $0x7,%edx
  801c0d:	29 c2                	sub    %eax,%edx
  801c0f:	8b 82 48 00 c0 ee    	mov    -0x113fffb8(%edx),%eax
  801c15:	eb 0e                	jmp    801c25 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c17:	42                   	inc    %edx
  801c18:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  801c1e:	75 c2                	jne    801be2 <ipc_find_env+0x15>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801c20:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c25:	5b                   	pop    %ebx
  801c26:	5d                   	pop    %ebp
  801c27:	c3                   	ret    

00801c28 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c28:	55                   	push   %ebp
  801c29:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c2b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c2e:	c1 e8 16             	shr    $0x16,%eax
  801c31:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801c38:	a8 01                	test   $0x1,%al
  801c3a:	74 21                	je     801c5d <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c3c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c3f:	c1 e8 0c             	shr    $0xc,%eax
  801c42:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801c49:	a8 01                	test   $0x1,%al
  801c4b:	74 17                	je     801c64 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c4d:	c1 e8 0c             	shr    $0xc,%eax
  801c50:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801c57:	ef 
  801c58:	0f b7 c0             	movzwl %ax,%eax
  801c5b:	eb 0c                	jmp    801c69 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801c5d:	b8 00 00 00 00       	mov    $0x0,%eax
  801c62:	eb 05                	jmp    801c69 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801c64:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801c69:	5d                   	pop    %ebp
  801c6a:	c3                   	ret    
  801c6b:	90                   	nop

00801c6c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801c6c:	55                   	push   %ebp
  801c6d:	57                   	push   %edi
  801c6e:	56                   	push   %esi
  801c6f:	53                   	push   %ebx
  801c70:	83 ec 1c             	sub    $0x1c,%esp
  801c73:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801c77:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801c7b:	8b 7c 24 38          	mov    0x38(%esp),%edi
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801c7f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c83:	89 ca                	mov    %ecx,%edx
  const DWunion dd = {.ll = d};
  801c85:	89 f8                	mov    %edi,%eax
  801c87:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801c8b:	85 f6                	test   %esi,%esi
  801c8d:	75 2d                	jne    801cbc <__udivdi3+0x50>
    {
      if (d0 > n1)
  801c8f:	39 cf                	cmp    %ecx,%edi
  801c91:	77 65                	ja     801cf8 <__udivdi3+0x8c>
  801c93:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801c95:	85 ff                	test   %edi,%edi
  801c97:	75 0b                	jne    801ca4 <__udivdi3+0x38>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801c99:	b8 01 00 00 00       	mov    $0x1,%eax
  801c9e:	31 d2                	xor    %edx,%edx
  801ca0:	f7 f7                	div    %edi
  801ca2:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801ca4:	31 d2                	xor    %edx,%edx
  801ca6:	89 c8                	mov    %ecx,%eax
  801ca8:	f7 f5                	div    %ebp
  801caa:	89 c1                	mov    %eax,%ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801cac:	89 d8                	mov    %ebx,%eax
  801cae:	f7 f5                	div    %ebp
  801cb0:	89 cf                	mov    %ecx,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801cb2:	89 fa                	mov    %edi,%edx
  801cb4:	83 c4 1c             	add    $0x1c,%esp
  801cb7:	5b                   	pop    %ebx
  801cb8:	5e                   	pop    %esi
  801cb9:	5f                   	pop    %edi
  801cba:	5d                   	pop    %ebp
  801cbb:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801cbc:	39 ce                	cmp    %ecx,%esi
  801cbe:	77 28                	ja     801ce8 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801cc0:	0f bd fe             	bsr    %esi,%edi
	  if (bm == 0)
  801cc3:	83 f7 1f             	xor    $0x1f,%edi
  801cc6:	75 40                	jne    801d08 <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801cc8:	39 ce                	cmp    %ecx,%esi
  801cca:	72 0a                	jb     801cd6 <__udivdi3+0x6a>
  801ccc:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801cd0:	0f 87 9e 00 00 00    	ja     801d74 <__udivdi3+0x108>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801cd6:	b8 01 00 00 00       	mov    $0x1,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801cdb:	89 fa                	mov    %edi,%edx
  801cdd:	83 c4 1c             	add    $0x1c,%esp
  801ce0:	5b                   	pop    %ebx
  801ce1:	5e                   	pop    %esi
  801ce2:	5f                   	pop    %edi
  801ce3:	5d                   	pop    %ebp
  801ce4:	c3                   	ret    
  801ce5:	8d 76 00             	lea    0x0(%esi),%esi
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801ce8:	31 ff                	xor    %edi,%edi
  801cea:	31 c0                	xor    %eax,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801cec:	89 fa                	mov    %edi,%edx
  801cee:	83 c4 1c             	add    $0x1c,%esp
  801cf1:	5b                   	pop    %ebx
  801cf2:	5e                   	pop    %esi
  801cf3:	5f                   	pop    %edi
  801cf4:	5d                   	pop    %ebp
  801cf5:	c3                   	ret    
  801cf6:	66 90                	xchg   %ax,%ax
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801cf8:	89 d8                	mov    %ebx,%eax
  801cfa:	f7 f7                	div    %edi
  801cfc:	31 ff                	xor    %edi,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801cfe:	89 fa                	mov    %edi,%edx
  801d00:	83 c4 1c             	add    $0x1c,%esp
  801d03:	5b                   	pop    %ebx
  801d04:	5e                   	pop    %esi
  801d05:	5f                   	pop    %edi
  801d06:	5d                   	pop    %ebp
  801d07:	c3                   	ret    
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801d08:	bd 20 00 00 00       	mov    $0x20,%ebp
  801d0d:	89 eb                	mov    %ebp,%ebx
  801d0f:	29 fb                	sub    %edi,%ebx

	      d1 = (d1 << bm) | (d0 >> b);
  801d11:	89 f9                	mov    %edi,%ecx
  801d13:	d3 e6                	shl    %cl,%esi
  801d15:	89 c5                	mov    %eax,%ebp
  801d17:	88 d9                	mov    %bl,%cl
  801d19:	d3 ed                	shr    %cl,%ebp
  801d1b:	89 e9                	mov    %ebp,%ecx
  801d1d:	09 f1                	or     %esi,%ecx
  801d1f:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
	      d0 = d0 << bm;
  801d23:	89 f9                	mov    %edi,%ecx
  801d25:	d3 e0                	shl    %cl,%eax
  801d27:	89 c5                	mov    %eax,%ebp
	      n2 = n1 >> b;
  801d29:	89 d6                	mov    %edx,%esi
  801d2b:	88 d9                	mov    %bl,%cl
  801d2d:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
  801d2f:	89 f9                	mov    %edi,%ecx
  801d31:	d3 e2                	shl    %cl,%edx
  801d33:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d37:	88 d9                	mov    %bl,%cl
  801d39:	d3 e8                	shr    %cl,%eax
  801d3b:	09 c2                	or     %eax,%edx
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801d3d:	89 d0                	mov    %edx,%eax
  801d3f:	89 f2                	mov    %esi,%edx
  801d41:	f7 74 24 0c          	divl   0xc(%esp)
  801d45:	89 d6                	mov    %edx,%esi
  801d47:	89 c3                	mov    %eax,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  801d49:	f7 e5                	mul    %ebp

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d4b:	39 d6                	cmp    %edx,%esi
  801d4d:	72 19                	jb     801d68 <__udivdi3+0xfc>
  801d4f:	74 0b                	je     801d5c <__udivdi3+0xf0>
  801d51:	89 d8                	mov    %ebx,%eax
  801d53:	31 ff                	xor    %edi,%edi
  801d55:	e9 58 ff ff ff       	jmp    801cb2 <__udivdi3+0x46>
  801d5a:	66 90                	xchg   %ax,%ax
  801d5c:	8b 54 24 08          	mov    0x8(%esp),%edx
  801d60:	89 f9                	mov    %edi,%ecx
  801d62:	d3 e2                	shl    %cl,%edx
  801d64:	39 c2                	cmp    %eax,%edx
  801d66:	73 e9                	jae    801d51 <__udivdi3+0xe5>
  801d68:	8d 43 ff             	lea    -0x1(%ebx),%eax
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801d6b:	31 ff                	xor    %edi,%edi
  801d6d:	e9 40 ff ff ff       	jmp    801cb2 <__udivdi3+0x46>
  801d72:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801d74:	31 c0                	xor    %eax,%eax
  801d76:	e9 37 ff ff ff       	jmp    801cb2 <__udivdi3+0x46>
  801d7b:	90                   	nop

00801d7c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801d7c:	55                   	push   %ebp
  801d7d:	57                   	push   %edi
  801d7e:	56                   	push   %esi
  801d7f:	53                   	push   %ebx
  801d80:	83 ec 1c             	sub    $0x1c,%esp
  801d83:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d87:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d8b:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d8f:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801d93:	89 44 24 0c          	mov    %eax,0xc(%esp)
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801d97:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d9b:	89 f3                	mov    %esi,%ebx
  const DWunion dd = {.ll = d};
  801d9d:	89 fa                	mov    %edi,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801d9f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  n1 = nn.s.high;
  801da3:	89 34 24             	mov    %esi,(%esp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801da6:	85 c0                	test   %eax,%eax
  801da8:	75 1a                	jne    801dc4 <__umoddi3+0x48>
    {
      if (d0 > n1)
  801daa:	39 f7                	cmp    %esi,%edi
  801dac:	0f 86 a2 00 00 00    	jbe    801e54 <__umoddi3+0xd8>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801db2:	89 c8                	mov    %ecx,%eax
  801db4:	89 f2                	mov    %esi,%edx
  801db6:	f7 f7                	div    %edi
  801db8:	89 d0                	mov    %edx,%eax

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801dba:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801dbc:	83 c4 1c             	add    $0x1c,%esp
  801dbf:	5b                   	pop    %ebx
  801dc0:	5e                   	pop    %esi
  801dc1:	5f                   	pop    %edi
  801dc2:	5d                   	pop    %ebp
  801dc3:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801dc4:	39 f0                	cmp    %esi,%eax
  801dc6:	0f 87 ac 00 00 00    	ja     801e78 <__umoddi3+0xfc>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801dcc:	0f bd e8             	bsr    %eax,%ebp
	  if (bm == 0)
  801dcf:	83 f5 1f             	xor    $0x1f,%ebp
  801dd2:	0f 84 ac 00 00 00    	je     801e84 <__umoddi3+0x108>
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801dd8:	bf 20 00 00 00       	mov    $0x20,%edi
  801ddd:	29 ef                	sub    %ebp,%edi
  801ddf:	89 fe                	mov    %edi,%esi
  801de1:	89 7c 24 0c          	mov    %edi,0xc(%esp)

	      d1 = (d1 << bm) | (d0 >> b);
  801de5:	89 e9                	mov    %ebp,%ecx
  801de7:	d3 e0                	shl    %cl,%eax
  801de9:	89 d7                	mov    %edx,%edi
  801deb:	89 f1                	mov    %esi,%ecx
  801ded:	d3 ef                	shr    %cl,%edi
  801def:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  801df1:	89 e9                	mov    %ebp,%ecx
  801df3:	d3 e2                	shl    %cl,%edx
  801df5:	89 14 24             	mov    %edx,(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801df8:	89 d8                	mov    %ebx,%eax
  801dfa:	d3 e0                	shl    %cl,%eax
  801dfc:	89 c2                	mov    %eax,%edx
	      n0 = n0 << bm;
  801dfe:	8b 44 24 08          	mov    0x8(%esp),%eax
  801e02:	d3 e0                	shl    %cl,%eax
  801e04:	89 44 24 04          	mov    %eax,0x4(%esp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801e08:	8b 44 24 08          	mov    0x8(%esp),%eax
  801e0c:	89 f1                	mov    %esi,%ecx
  801e0e:	d3 e8                	shr    %cl,%eax
  801e10:	09 d0                	or     %edx,%eax
  801e12:	d3 eb                	shr    %cl,%ebx
  801e14:	89 da                	mov    %ebx,%edx
  801e16:	f7 f7                	div    %edi
  801e18:	89 d3                	mov    %edx,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  801e1a:	f7 24 24             	mull   (%esp)
  801e1d:	89 c6                	mov    %eax,%esi
  801e1f:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e21:	39 d3                	cmp    %edx,%ebx
  801e23:	0f 82 87 00 00 00    	jb     801eb0 <__umoddi3+0x134>
  801e29:	0f 84 91 00 00 00    	je     801ec0 <__umoddi3+0x144>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801e2f:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e33:	29 f2                	sub    %esi,%edx
  801e35:	19 cb                	sbb    %ecx,%ebx
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801e37:	89 d8                	mov    %ebx,%eax
  801e39:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  801e3d:	d3 e0                	shl    %cl,%eax
  801e3f:	89 e9                	mov    %ebp,%ecx
  801e41:	d3 ea                	shr    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801e43:	09 d0                	or     %edx,%eax
  801e45:	89 e9                	mov    %ebp,%ecx
  801e47:	d3 eb                	shr    %cl,%ebx
  801e49:	89 da                	mov    %ebx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e4b:	83 c4 1c             	add    $0x1c,%esp
  801e4e:	5b                   	pop    %ebx
  801e4f:	5e                   	pop    %esi
  801e50:	5f                   	pop    %edi
  801e51:	5d                   	pop    %ebp
  801e52:	c3                   	ret    
  801e53:	90                   	nop
  801e54:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801e56:	85 ff                	test   %edi,%edi
  801e58:	75 0b                	jne    801e65 <__umoddi3+0xe9>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801e5a:	b8 01 00 00 00       	mov    $0x1,%eax
  801e5f:	31 d2                	xor    %edx,%edx
  801e61:	f7 f7                	div    %edi
  801e63:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801e65:	89 f0                	mov    %esi,%eax
  801e67:	31 d2                	xor    %edx,%edx
  801e69:	f7 f5                	div    %ebp
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801e6b:	89 c8                	mov    %ecx,%eax
  801e6d:	f7 f5                	div    %ebp
  801e6f:	89 d0                	mov    %edx,%eax
  801e71:	e9 44 ff ff ff       	jmp    801dba <__umoddi3+0x3e>
  801e76:	66 90                	xchg   %ax,%ax
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801e78:	89 c8                	mov    %ecx,%eax
  801e7a:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e7c:	83 c4 1c             	add    $0x1c,%esp
  801e7f:	5b                   	pop    %ebx
  801e80:	5e                   	pop    %esi
  801e81:	5f                   	pop    %edi
  801e82:	5d                   	pop    %ebp
  801e83:	c3                   	ret    

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801e84:	3b 04 24             	cmp    (%esp),%eax
  801e87:	72 06                	jb     801e8f <__umoddi3+0x113>
  801e89:	3b 7c 24 04          	cmp    0x4(%esp),%edi
  801e8d:	77 0f                	ja     801e9e <__umoddi3+0x122>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801e8f:	89 f2                	mov    %esi,%edx
  801e91:	29 f9                	sub    %edi,%ecx
  801e93:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  801e97:	89 14 24             	mov    %edx,(%esp)
  801e9a:	89 4c 24 04          	mov    %ecx,0x4(%esp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801e9e:	8b 44 24 04          	mov    0x4(%esp),%eax
  801ea2:	8b 14 24             	mov    (%esp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801ea5:	83 c4 1c             	add    $0x1c,%esp
  801ea8:	5b                   	pop    %ebx
  801ea9:	5e                   	pop    %esi
  801eaa:	5f                   	pop    %edi
  801eab:	5d                   	pop    %ebp
  801eac:	c3                   	ret    
  801ead:	8d 76 00             	lea    0x0(%esi),%esi
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801eb0:	2b 04 24             	sub    (%esp),%eax
  801eb3:	19 fa                	sbb    %edi,%edx
  801eb5:	89 d1                	mov    %edx,%ecx
  801eb7:	89 c6                	mov    %eax,%esi
  801eb9:	e9 71 ff ff ff       	jmp    801e2f <__umoddi3+0xb3>
  801ebe:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801ec0:	39 44 24 04          	cmp    %eax,0x4(%esp)
  801ec4:	72 ea                	jb     801eb0 <__umoddi3+0x134>
  801ec6:	89 d9                	mov    %ebx,%ecx
  801ec8:	e9 62 ff ff ff       	jmp    801e2f <__umoddi3+0xb3>
