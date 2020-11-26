
obj/user/evilhello.debug:     file format elf32-i386


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
  80002c:	e8 19 00 00 00       	call   80004a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	// try to print the kernel entry point as a string!  mua ha ha!
	sys_cputs((char*)0xf010000c, 100);
  800039:	6a 64                	push   $0x64
  80003b:	68 0c 00 10 f0       	push   $0xf010000c
  800040:	e8 6e 00 00 00       	call   8000b3 <sys_cputs>
}
  800045:	83 c4 10             	add    $0x10,%esp
  800048:	c9                   	leave  
  800049:	c3                   	ret    

0080004a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004a:	55                   	push   %ebp
  80004b:	89 e5                	mov    %esp,%ebp
  80004d:	56                   	push   %esi
  80004e:	53                   	push   %ebx
  80004f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800052:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800055:	e8 d7 00 00 00       	call   800131 <sys_getenvid>
  80005a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800066:	c1 e0 07             	shl    $0x7,%eax
  800069:	29 d0                	sub    %edx,%eax
  80006b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800070:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800075:	85 db                	test   %ebx,%ebx
  800077:	7e 07                	jle    800080 <libmain+0x36>
		binaryname = argv[0];
  800079:	8b 06                	mov    (%esi),%eax
  80007b:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800080:	83 ec 08             	sub    $0x8,%esp
  800083:	56                   	push   %esi
  800084:	53                   	push   %ebx
  800085:	e8 a9 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008a:	e8 0a 00 00 00       	call   800099 <exit>
}
  80008f:	83 c4 10             	add    $0x10,%esp
  800092:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800095:	5b                   	pop    %ebx
  800096:	5e                   	pop    %esi
  800097:	5d                   	pop    %ebp
  800098:	c3                   	ret    

00800099 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800099:	55                   	push   %ebp
  80009a:	89 e5                	mov    %esp,%ebp
  80009c:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80009f:	e8 cb 04 00 00       	call   80056f <close_all>
	sys_env_destroy(0);
  8000a4:	83 ec 0c             	sub    $0xc,%esp
  8000a7:	6a 00                	push   $0x0
  8000a9:	e8 42 00 00 00       	call   8000f0 <sys_env_destroy>
}
  8000ae:	83 c4 10             	add    $0x10,%esp
  8000b1:	c9                   	leave  
  8000b2:	c3                   	ret    

008000b3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b3:	55                   	push   %ebp
  8000b4:	89 e5                	mov    %esp,%ebp
  8000b6:	57                   	push   %edi
  8000b7:	56                   	push   %esi
  8000b8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8000be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c1:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c4:	89 c3                	mov    %eax,%ebx
  8000c6:	89 c7                	mov    %eax,%edi
  8000c8:	89 c6                	mov    %eax,%esi
  8000ca:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000cc:	5b                   	pop    %ebx
  8000cd:	5e                   	pop    %esi
  8000ce:	5f                   	pop    %edi
  8000cf:	5d                   	pop    %ebp
  8000d0:	c3                   	ret    

008000d1 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d1:	55                   	push   %ebp
  8000d2:	89 e5                	mov    %esp,%ebp
  8000d4:	57                   	push   %edi
  8000d5:	56                   	push   %esi
  8000d6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8000dc:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e1:	89 d1                	mov    %edx,%ecx
  8000e3:	89 d3                	mov    %edx,%ebx
  8000e5:	89 d7                	mov    %edx,%edi
  8000e7:	89 d6                	mov    %edx,%esi
  8000e9:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000eb:	5b                   	pop    %ebx
  8000ec:	5e                   	pop    %esi
  8000ed:	5f                   	pop    %edi
  8000ee:	5d                   	pop    %ebp
  8000ef:	c3                   	ret    

008000f0 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f0:	55                   	push   %ebp
  8000f1:	89 e5                	mov    %esp,%ebp
  8000f3:	57                   	push   %edi
  8000f4:	56                   	push   %esi
  8000f5:	53                   	push   %ebx
  8000f6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000fe:	b8 03 00 00 00       	mov    $0x3,%eax
  800103:	8b 55 08             	mov    0x8(%ebp),%edx
  800106:	89 cb                	mov    %ecx,%ebx
  800108:	89 cf                	mov    %ecx,%edi
  80010a:	89 ce                	mov    %ecx,%esi
  80010c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80010e:	85 c0                	test   %eax,%eax
  800110:	7e 17                	jle    800129 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800112:	83 ec 0c             	sub    $0xc,%esp
  800115:	50                   	push   %eax
  800116:	6a 03                	push   $0x3
  800118:	68 4a 1e 80 00       	push   $0x801e4a
  80011d:	6a 23                	push   $0x23
  80011f:	68 67 1e 80 00       	push   $0x801e67
  800124:	e8 cf 0e 00 00       	call   800ff8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800129:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80012c:	5b                   	pop    %ebx
  80012d:	5e                   	pop    %esi
  80012e:	5f                   	pop    %edi
  80012f:	5d                   	pop    %ebp
  800130:	c3                   	ret    

00800131 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800131:	55                   	push   %ebp
  800132:	89 e5                	mov    %esp,%ebp
  800134:	57                   	push   %edi
  800135:	56                   	push   %esi
  800136:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800137:	ba 00 00 00 00       	mov    $0x0,%edx
  80013c:	b8 02 00 00 00       	mov    $0x2,%eax
  800141:	89 d1                	mov    %edx,%ecx
  800143:	89 d3                	mov    %edx,%ebx
  800145:	89 d7                	mov    %edx,%edi
  800147:	89 d6                	mov    %edx,%esi
  800149:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80014b:	5b                   	pop    %ebx
  80014c:	5e                   	pop    %esi
  80014d:	5f                   	pop    %edi
  80014e:	5d                   	pop    %ebp
  80014f:	c3                   	ret    

00800150 <sys_yield>:

void
sys_yield(void)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	57                   	push   %edi
  800154:	56                   	push   %esi
  800155:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800156:	ba 00 00 00 00       	mov    $0x0,%edx
  80015b:	b8 0b 00 00 00       	mov    $0xb,%eax
  800160:	89 d1                	mov    %edx,%ecx
  800162:	89 d3                	mov    %edx,%ebx
  800164:	89 d7                	mov    %edx,%edi
  800166:	89 d6                	mov    %edx,%esi
  800168:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80016a:	5b                   	pop    %ebx
  80016b:	5e                   	pop    %esi
  80016c:	5f                   	pop    %edi
  80016d:	5d                   	pop    %ebp
  80016e:	c3                   	ret    

0080016f <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80016f:	55                   	push   %ebp
  800170:	89 e5                	mov    %esp,%ebp
  800172:	57                   	push   %edi
  800173:	56                   	push   %esi
  800174:	53                   	push   %ebx
  800175:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800178:	be 00 00 00 00       	mov    $0x0,%esi
  80017d:	b8 04 00 00 00       	mov    $0x4,%eax
  800182:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800185:	8b 55 08             	mov    0x8(%ebp),%edx
  800188:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80018b:	89 f7                	mov    %esi,%edi
  80018d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80018f:	85 c0                	test   %eax,%eax
  800191:	7e 17                	jle    8001aa <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800193:	83 ec 0c             	sub    $0xc,%esp
  800196:	50                   	push   %eax
  800197:	6a 04                	push   $0x4
  800199:	68 4a 1e 80 00       	push   $0x801e4a
  80019e:	6a 23                	push   $0x23
  8001a0:	68 67 1e 80 00       	push   $0x801e67
  8001a5:	e8 4e 0e 00 00       	call   800ff8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ad:	5b                   	pop    %ebx
  8001ae:	5e                   	pop    %esi
  8001af:	5f                   	pop    %edi
  8001b0:	5d                   	pop    %ebp
  8001b1:	c3                   	ret    

008001b2 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001b2:	55                   	push   %ebp
  8001b3:	89 e5                	mov    %esp,%ebp
  8001b5:	57                   	push   %edi
  8001b6:	56                   	push   %esi
  8001b7:	53                   	push   %ebx
  8001b8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001bb:	b8 05 00 00 00       	mov    $0x5,%eax
  8001c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001c3:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c9:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001cc:	8b 75 18             	mov    0x18(%ebp),%esi
  8001cf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001d1:	85 c0                	test   %eax,%eax
  8001d3:	7e 17                	jle    8001ec <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d5:	83 ec 0c             	sub    $0xc,%esp
  8001d8:	50                   	push   %eax
  8001d9:	6a 05                	push   $0x5
  8001db:	68 4a 1e 80 00       	push   $0x801e4a
  8001e0:	6a 23                	push   $0x23
  8001e2:	68 67 1e 80 00       	push   $0x801e67
  8001e7:	e8 0c 0e 00 00       	call   800ff8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ef:	5b                   	pop    %ebx
  8001f0:	5e                   	pop    %esi
  8001f1:	5f                   	pop    %edi
  8001f2:	5d                   	pop    %ebp
  8001f3:	c3                   	ret    

008001f4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001f4:	55                   	push   %ebp
  8001f5:	89 e5                	mov    %esp,%ebp
  8001f7:	57                   	push   %edi
  8001f8:	56                   	push   %esi
  8001f9:	53                   	push   %ebx
  8001fa:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001fd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800202:	b8 06 00 00 00       	mov    $0x6,%eax
  800207:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80020a:	8b 55 08             	mov    0x8(%ebp),%edx
  80020d:	89 df                	mov    %ebx,%edi
  80020f:	89 de                	mov    %ebx,%esi
  800211:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800213:	85 c0                	test   %eax,%eax
  800215:	7e 17                	jle    80022e <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800217:	83 ec 0c             	sub    $0xc,%esp
  80021a:	50                   	push   %eax
  80021b:	6a 06                	push   $0x6
  80021d:	68 4a 1e 80 00       	push   $0x801e4a
  800222:	6a 23                	push   $0x23
  800224:	68 67 1e 80 00       	push   $0x801e67
  800229:	e8 ca 0d 00 00       	call   800ff8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80022e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800231:	5b                   	pop    %ebx
  800232:	5e                   	pop    %esi
  800233:	5f                   	pop    %edi
  800234:	5d                   	pop    %ebp
  800235:	c3                   	ret    

00800236 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800236:	55                   	push   %ebp
  800237:	89 e5                	mov    %esp,%ebp
  800239:	57                   	push   %edi
  80023a:	56                   	push   %esi
  80023b:	53                   	push   %ebx
  80023c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80023f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800244:	b8 08 00 00 00       	mov    $0x8,%eax
  800249:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80024c:	8b 55 08             	mov    0x8(%ebp),%edx
  80024f:	89 df                	mov    %ebx,%edi
  800251:	89 de                	mov    %ebx,%esi
  800253:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800255:	85 c0                	test   %eax,%eax
  800257:	7e 17                	jle    800270 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800259:	83 ec 0c             	sub    $0xc,%esp
  80025c:	50                   	push   %eax
  80025d:	6a 08                	push   $0x8
  80025f:	68 4a 1e 80 00       	push   $0x801e4a
  800264:	6a 23                	push   $0x23
  800266:	68 67 1e 80 00       	push   $0x801e67
  80026b:	e8 88 0d 00 00       	call   800ff8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800270:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800273:	5b                   	pop    %ebx
  800274:	5e                   	pop    %esi
  800275:	5f                   	pop    %edi
  800276:	5d                   	pop    %ebp
  800277:	c3                   	ret    

00800278 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800278:	55                   	push   %ebp
  800279:	89 e5                	mov    %esp,%ebp
  80027b:	57                   	push   %edi
  80027c:	56                   	push   %esi
  80027d:	53                   	push   %ebx
  80027e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800281:	bb 00 00 00 00       	mov    $0x0,%ebx
  800286:	b8 09 00 00 00       	mov    $0x9,%eax
  80028b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80028e:	8b 55 08             	mov    0x8(%ebp),%edx
  800291:	89 df                	mov    %ebx,%edi
  800293:	89 de                	mov    %ebx,%esi
  800295:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800297:	85 c0                	test   %eax,%eax
  800299:	7e 17                	jle    8002b2 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80029b:	83 ec 0c             	sub    $0xc,%esp
  80029e:	50                   	push   %eax
  80029f:	6a 09                	push   $0x9
  8002a1:	68 4a 1e 80 00       	push   $0x801e4a
  8002a6:	6a 23                	push   $0x23
  8002a8:	68 67 1e 80 00       	push   $0x801e67
  8002ad:	e8 46 0d 00 00       	call   800ff8 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b5:	5b                   	pop    %ebx
  8002b6:	5e                   	pop    %esi
  8002b7:	5f                   	pop    %edi
  8002b8:	5d                   	pop    %ebp
  8002b9:	c3                   	ret    

008002ba <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002ba:	55                   	push   %ebp
  8002bb:	89 e5                	mov    %esp,%ebp
  8002bd:	57                   	push   %edi
  8002be:	56                   	push   %esi
  8002bf:	53                   	push   %ebx
  8002c0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002c3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d3:	89 df                	mov    %ebx,%edi
  8002d5:	89 de                	mov    %ebx,%esi
  8002d7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002d9:	85 c0                	test   %eax,%eax
  8002db:	7e 17                	jle    8002f4 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002dd:	83 ec 0c             	sub    $0xc,%esp
  8002e0:	50                   	push   %eax
  8002e1:	6a 0a                	push   $0xa
  8002e3:	68 4a 1e 80 00       	push   $0x801e4a
  8002e8:	6a 23                	push   $0x23
  8002ea:	68 67 1e 80 00       	push   $0x801e67
  8002ef:	e8 04 0d 00 00       	call   800ff8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f7:	5b                   	pop    %ebx
  8002f8:	5e                   	pop    %esi
  8002f9:	5f                   	pop    %edi
  8002fa:	5d                   	pop    %ebp
  8002fb:	c3                   	ret    

008002fc <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002fc:	55                   	push   %ebp
  8002fd:	89 e5                	mov    %esp,%ebp
  8002ff:	57                   	push   %edi
  800300:	56                   	push   %esi
  800301:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800302:	be 00 00 00 00       	mov    $0x0,%esi
  800307:	b8 0c 00 00 00       	mov    $0xc,%eax
  80030c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80030f:	8b 55 08             	mov    0x8(%ebp),%edx
  800312:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800315:	8b 7d 14             	mov    0x14(%ebp),%edi
  800318:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80031a:	5b                   	pop    %ebx
  80031b:	5e                   	pop    %esi
  80031c:	5f                   	pop    %edi
  80031d:	5d                   	pop    %ebp
  80031e:	c3                   	ret    

0080031f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80031f:	55                   	push   %ebp
  800320:	89 e5                	mov    %esp,%ebp
  800322:	57                   	push   %edi
  800323:	56                   	push   %esi
  800324:	53                   	push   %ebx
  800325:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800328:	b9 00 00 00 00       	mov    $0x0,%ecx
  80032d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800332:	8b 55 08             	mov    0x8(%ebp),%edx
  800335:	89 cb                	mov    %ecx,%ebx
  800337:	89 cf                	mov    %ecx,%edi
  800339:	89 ce                	mov    %ecx,%esi
  80033b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80033d:	85 c0                	test   %eax,%eax
  80033f:	7e 17                	jle    800358 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800341:	83 ec 0c             	sub    $0xc,%esp
  800344:	50                   	push   %eax
  800345:	6a 0d                	push   $0xd
  800347:	68 4a 1e 80 00       	push   $0x801e4a
  80034c:	6a 23                	push   $0x23
  80034e:	68 67 1e 80 00       	push   $0x801e67
  800353:	e8 a0 0c 00 00       	call   800ff8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800358:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80035b:	5b                   	pop    %ebx
  80035c:	5e                   	pop    %esi
  80035d:	5f                   	pop    %edi
  80035e:	5d                   	pop    %ebp
  80035f:	c3                   	ret    

00800360 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800360:	55                   	push   %ebp
  800361:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800363:	8b 45 08             	mov    0x8(%ebp),%eax
  800366:	05 00 00 00 30       	add    $0x30000000,%eax
  80036b:	c1 e8 0c             	shr    $0xc,%eax
}
  80036e:	5d                   	pop    %ebp
  80036f:	c3                   	ret    

00800370 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800370:	55                   	push   %ebp
  800371:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800373:	8b 45 08             	mov    0x8(%ebp),%eax
  800376:	05 00 00 00 30       	add    $0x30000000,%eax
  80037b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800380:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800385:	5d                   	pop    %ebp
  800386:	c3                   	ret    

00800387 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800387:	55                   	push   %ebp
  800388:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80038a:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  80038f:	a8 01                	test   $0x1,%al
  800391:	74 34                	je     8003c7 <fd_alloc+0x40>
  800393:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800398:	a8 01                	test   $0x1,%al
  80039a:	74 32                	je     8003ce <fd_alloc+0x47>
  80039c:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8003a1:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003a3:	89 c2                	mov    %eax,%edx
  8003a5:	c1 ea 16             	shr    $0x16,%edx
  8003a8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003af:	f6 c2 01             	test   $0x1,%dl
  8003b2:	74 1f                	je     8003d3 <fd_alloc+0x4c>
  8003b4:	89 c2                	mov    %eax,%edx
  8003b6:	c1 ea 0c             	shr    $0xc,%edx
  8003b9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003c0:	f6 c2 01             	test   $0x1,%dl
  8003c3:	75 1a                	jne    8003df <fd_alloc+0x58>
  8003c5:	eb 0c                	jmp    8003d3 <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8003c7:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8003cc:	eb 05                	jmp    8003d3 <fd_alloc+0x4c>
  8003ce:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8003d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d6:	89 08                	mov    %ecx,(%eax)
			return 0;
  8003d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8003dd:	eb 1a                	jmp    8003f9 <fd_alloc+0x72>
  8003df:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003e4:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003e9:	75 b6                	jne    8003a1 <fd_alloc+0x1a>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ee:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  8003f4:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003f9:	5d                   	pop    %ebp
  8003fa:	c3                   	ret    

008003fb <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003fb:	55                   	push   %ebp
  8003fc:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003fe:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  800402:	77 39                	ja     80043d <fd_lookup+0x42>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800404:	8b 45 08             	mov    0x8(%ebp),%eax
  800407:	c1 e0 0c             	shl    $0xc,%eax
  80040a:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80040f:	89 c2                	mov    %eax,%edx
  800411:	c1 ea 16             	shr    $0x16,%edx
  800414:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80041b:	f6 c2 01             	test   $0x1,%dl
  80041e:	74 24                	je     800444 <fd_lookup+0x49>
  800420:	89 c2                	mov    %eax,%edx
  800422:	c1 ea 0c             	shr    $0xc,%edx
  800425:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80042c:	f6 c2 01             	test   $0x1,%dl
  80042f:	74 1a                	je     80044b <fd_lookup+0x50>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800431:	8b 55 0c             	mov    0xc(%ebp),%edx
  800434:	89 02                	mov    %eax,(%edx)
	return 0;
  800436:	b8 00 00 00 00       	mov    $0x0,%eax
  80043b:	eb 13                	jmp    800450 <fd_lookup+0x55>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80043d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800442:	eb 0c                	jmp    800450 <fd_lookup+0x55>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800444:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800449:	eb 05                	jmp    800450 <fd_lookup+0x55>
  80044b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800450:	5d                   	pop    %ebp
  800451:	c3                   	ret    

00800452 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800452:	55                   	push   %ebp
  800453:	89 e5                	mov    %esp,%ebp
  800455:	53                   	push   %ebx
  800456:	83 ec 04             	sub    $0x4,%esp
  800459:	8b 45 08             	mov    0x8(%ebp),%eax
  80045c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80045f:	3b 05 04 30 80 00    	cmp    0x803004,%eax
  800465:	75 1e                	jne    800485 <dev_lookup+0x33>
  800467:	eb 0e                	jmp    800477 <dev_lookup+0x25>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800469:	b8 20 30 80 00       	mov    $0x803020,%eax
  80046e:	eb 0c                	jmp    80047c <dev_lookup+0x2a>
  800470:	b8 3c 30 80 00       	mov    $0x80303c,%eax
  800475:	eb 05                	jmp    80047c <dev_lookup+0x2a>
  800477:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  80047c:	89 03                	mov    %eax,(%ebx)
			return 0;
  80047e:	b8 00 00 00 00       	mov    $0x0,%eax
  800483:	eb 36                	jmp    8004bb <dev_lookup+0x69>
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800485:	3b 05 20 30 80 00    	cmp    0x803020,%eax
  80048b:	74 dc                	je     800469 <dev_lookup+0x17>
  80048d:	3b 05 3c 30 80 00    	cmp    0x80303c,%eax
  800493:	74 db                	je     800470 <dev_lookup+0x1e>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800495:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80049b:	8b 52 48             	mov    0x48(%edx),%edx
  80049e:	83 ec 04             	sub    $0x4,%esp
  8004a1:	50                   	push   %eax
  8004a2:	52                   	push   %edx
  8004a3:	68 78 1e 80 00       	push   $0x801e78
  8004a8:	e8 23 0c 00 00       	call   8010d0 <cprintf>
	*dev = 0;
  8004ad:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8004b3:	83 c4 10             	add    $0x10,%esp
  8004b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004be:	c9                   	leave  
  8004bf:	c3                   	ret    

008004c0 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004c0:	55                   	push   %ebp
  8004c1:	89 e5                	mov    %esp,%ebp
  8004c3:	56                   	push   %esi
  8004c4:	53                   	push   %ebx
  8004c5:	83 ec 10             	sub    $0x10,%esp
  8004c8:	8b 75 08             	mov    0x8(%ebp),%esi
  8004cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004d1:	50                   	push   %eax
  8004d2:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004d8:	c1 e8 0c             	shr    $0xc,%eax
  8004db:	50                   	push   %eax
  8004dc:	e8 1a ff ff ff       	call   8003fb <fd_lookup>
  8004e1:	83 c4 08             	add    $0x8,%esp
  8004e4:	85 c0                	test   %eax,%eax
  8004e6:	78 05                	js     8004ed <fd_close+0x2d>
	    || fd != fd2)
  8004e8:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004eb:	74 06                	je     8004f3 <fd_close+0x33>
		return (must_exist ? r : 0);
  8004ed:	84 db                	test   %bl,%bl
  8004ef:	74 47                	je     800538 <fd_close+0x78>
  8004f1:	eb 4a                	jmp    80053d <fd_close+0x7d>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004f3:	83 ec 08             	sub    $0x8,%esp
  8004f6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004f9:	50                   	push   %eax
  8004fa:	ff 36                	pushl  (%esi)
  8004fc:	e8 51 ff ff ff       	call   800452 <dev_lookup>
  800501:	89 c3                	mov    %eax,%ebx
  800503:	83 c4 10             	add    $0x10,%esp
  800506:	85 c0                	test   %eax,%eax
  800508:	78 1c                	js     800526 <fd_close+0x66>
		if (dev->dev_close)
  80050a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80050d:	8b 40 10             	mov    0x10(%eax),%eax
  800510:	85 c0                	test   %eax,%eax
  800512:	74 0d                	je     800521 <fd_close+0x61>
			r = (*dev->dev_close)(fd);
  800514:	83 ec 0c             	sub    $0xc,%esp
  800517:	56                   	push   %esi
  800518:	ff d0                	call   *%eax
  80051a:	89 c3                	mov    %eax,%ebx
  80051c:	83 c4 10             	add    $0x10,%esp
  80051f:	eb 05                	jmp    800526 <fd_close+0x66>
		else
			r = 0;
  800521:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800526:	83 ec 08             	sub    $0x8,%esp
  800529:	56                   	push   %esi
  80052a:	6a 00                	push   $0x0
  80052c:	e8 c3 fc ff ff       	call   8001f4 <sys_page_unmap>
	return r;
  800531:	83 c4 10             	add    $0x10,%esp
  800534:	89 d8                	mov    %ebx,%eax
  800536:	eb 05                	jmp    80053d <fd_close+0x7d>
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
  800538:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
	return r;
}
  80053d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800540:	5b                   	pop    %ebx
  800541:	5e                   	pop    %esi
  800542:	5d                   	pop    %ebp
  800543:	c3                   	ret    

00800544 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800544:	55                   	push   %ebp
  800545:	89 e5                	mov    %esp,%ebp
  800547:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80054a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80054d:	50                   	push   %eax
  80054e:	ff 75 08             	pushl  0x8(%ebp)
  800551:	e8 a5 fe ff ff       	call   8003fb <fd_lookup>
  800556:	83 c4 08             	add    $0x8,%esp
  800559:	85 c0                	test   %eax,%eax
  80055b:	78 10                	js     80056d <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80055d:	83 ec 08             	sub    $0x8,%esp
  800560:	6a 01                	push   $0x1
  800562:	ff 75 f4             	pushl  -0xc(%ebp)
  800565:	e8 56 ff ff ff       	call   8004c0 <fd_close>
  80056a:	83 c4 10             	add    $0x10,%esp
}
  80056d:	c9                   	leave  
  80056e:	c3                   	ret    

0080056f <close_all>:

void
close_all(void)
{
  80056f:	55                   	push   %ebp
  800570:	89 e5                	mov    %esp,%ebp
  800572:	53                   	push   %ebx
  800573:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800576:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80057b:	83 ec 0c             	sub    $0xc,%esp
  80057e:	53                   	push   %ebx
  80057f:	e8 c0 ff ff ff       	call   800544 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800584:	43                   	inc    %ebx
  800585:	83 c4 10             	add    $0x10,%esp
  800588:	83 fb 20             	cmp    $0x20,%ebx
  80058b:	75 ee                	jne    80057b <close_all+0xc>
		close(i);
}
  80058d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800590:	c9                   	leave  
  800591:	c3                   	ret    

00800592 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800592:	55                   	push   %ebp
  800593:	89 e5                	mov    %esp,%ebp
  800595:	57                   	push   %edi
  800596:	56                   	push   %esi
  800597:	53                   	push   %ebx
  800598:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80059b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80059e:	50                   	push   %eax
  80059f:	ff 75 08             	pushl  0x8(%ebp)
  8005a2:	e8 54 fe ff ff       	call   8003fb <fd_lookup>
  8005a7:	83 c4 08             	add    $0x8,%esp
  8005aa:	85 c0                	test   %eax,%eax
  8005ac:	0f 88 c2 00 00 00    	js     800674 <dup+0xe2>
		return r;
	close(newfdnum);
  8005b2:	83 ec 0c             	sub    $0xc,%esp
  8005b5:	ff 75 0c             	pushl  0xc(%ebp)
  8005b8:	e8 87 ff ff ff       	call   800544 <close>

	newfd = INDEX2FD(newfdnum);
  8005bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005c0:	c1 e3 0c             	shl    $0xc,%ebx
  8005c3:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8005c9:	83 c4 04             	add    $0x4,%esp
  8005cc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005cf:	e8 9c fd ff ff       	call   800370 <fd2data>
  8005d4:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  8005d6:	89 1c 24             	mov    %ebx,(%esp)
  8005d9:	e8 92 fd ff ff       	call   800370 <fd2data>
  8005de:	83 c4 10             	add    $0x10,%esp
  8005e1:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005e3:	89 f0                	mov    %esi,%eax
  8005e5:	c1 e8 16             	shr    $0x16,%eax
  8005e8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005ef:	a8 01                	test   $0x1,%al
  8005f1:	74 35                	je     800628 <dup+0x96>
  8005f3:	89 f0                	mov    %esi,%eax
  8005f5:	c1 e8 0c             	shr    $0xc,%eax
  8005f8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005ff:	f6 c2 01             	test   $0x1,%dl
  800602:	74 24                	je     800628 <dup+0x96>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800604:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80060b:	83 ec 0c             	sub    $0xc,%esp
  80060e:	25 07 0e 00 00       	and    $0xe07,%eax
  800613:	50                   	push   %eax
  800614:	57                   	push   %edi
  800615:	6a 00                	push   $0x0
  800617:	56                   	push   %esi
  800618:	6a 00                	push   $0x0
  80061a:	e8 93 fb ff ff       	call   8001b2 <sys_page_map>
  80061f:	89 c6                	mov    %eax,%esi
  800621:	83 c4 20             	add    $0x20,%esp
  800624:	85 c0                	test   %eax,%eax
  800626:	78 2c                	js     800654 <dup+0xc2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800628:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80062b:	89 d0                	mov    %edx,%eax
  80062d:	c1 e8 0c             	shr    $0xc,%eax
  800630:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800637:	83 ec 0c             	sub    $0xc,%esp
  80063a:	25 07 0e 00 00       	and    $0xe07,%eax
  80063f:	50                   	push   %eax
  800640:	53                   	push   %ebx
  800641:	6a 00                	push   $0x0
  800643:	52                   	push   %edx
  800644:	6a 00                	push   $0x0
  800646:	e8 67 fb ff ff       	call   8001b2 <sys_page_map>
  80064b:	89 c6                	mov    %eax,%esi
  80064d:	83 c4 20             	add    $0x20,%esp
  800650:	85 c0                	test   %eax,%eax
  800652:	79 1d                	jns    800671 <dup+0xdf>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800654:	83 ec 08             	sub    $0x8,%esp
  800657:	53                   	push   %ebx
  800658:	6a 00                	push   $0x0
  80065a:	e8 95 fb ff ff       	call   8001f4 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80065f:	83 c4 08             	add    $0x8,%esp
  800662:	57                   	push   %edi
  800663:	6a 00                	push   $0x0
  800665:	e8 8a fb ff ff       	call   8001f4 <sys_page_unmap>
	return r;
  80066a:	83 c4 10             	add    $0x10,%esp
  80066d:	89 f0                	mov    %esi,%eax
  80066f:	eb 03                	jmp    800674 <dup+0xe2>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  800671:	8b 45 0c             	mov    0xc(%ebp),%eax

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800674:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800677:	5b                   	pop    %ebx
  800678:	5e                   	pop    %esi
  800679:	5f                   	pop    %edi
  80067a:	5d                   	pop    %ebp
  80067b:	c3                   	ret    

0080067c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80067c:	55                   	push   %ebp
  80067d:	89 e5                	mov    %esp,%ebp
  80067f:	53                   	push   %ebx
  800680:	83 ec 14             	sub    $0x14,%esp
  800683:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800686:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800689:	50                   	push   %eax
  80068a:	53                   	push   %ebx
  80068b:	e8 6b fd ff ff       	call   8003fb <fd_lookup>
  800690:	83 c4 08             	add    $0x8,%esp
  800693:	85 c0                	test   %eax,%eax
  800695:	78 67                	js     8006fe <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800697:	83 ec 08             	sub    $0x8,%esp
  80069a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80069d:	50                   	push   %eax
  80069e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006a1:	ff 30                	pushl  (%eax)
  8006a3:	e8 aa fd ff ff       	call   800452 <dev_lookup>
  8006a8:	83 c4 10             	add    $0x10,%esp
  8006ab:	85 c0                	test   %eax,%eax
  8006ad:	78 4f                	js     8006fe <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006af:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006b2:	8b 42 08             	mov    0x8(%edx),%eax
  8006b5:	83 e0 03             	and    $0x3,%eax
  8006b8:	83 f8 01             	cmp    $0x1,%eax
  8006bb:	75 21                	jne    8006de <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006bd:	a1 04 40 80 00       	mov    0x804004,%eax
  8006c2:	8b 40 48             	mov    0x48(%eax),%eax
  8006c5:	83 ec 04             	sub    $0x4,%esp
  8006c8:	53                   	push   %ebx
  8006c9:	50                   	push   %eax
  8006ca:	68 b9 1e 80 00       	push   $0x801eb9
  8006cf:	e8 fc 09 00 00       	call   8010d0 <cprintf>
		return -E_INVAL;
  8006d4:	83 c4 10             	add    $0x10,%esp
  8006d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006dc:	eb 20                	jmp    8006fe <read+0x82>
	}
	if (!dev->dev_read)
  8006de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006e1:	8b 40 08             	mov    0x8(%eax),%eax
  8006e4:	85 c0                	test   %eax,%eax
  8006e6:	74 11                	je     8006f9 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006e8:	83 ec 04             	sub    $0x4,%esp
  8006eb:	ff 75 10             	pushl  0x10(%ebp)
  8006ee:	ff 75 0c             	pushl  0xc(%ebp)
  8006f1:	52                   	push   %edx
  8006f2:	ff d0                	call   *%eax
  8006f4:	83 c4 10             	add    $0x10,%esp
  8006f7:	eb 05                	jmp    8006fe <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006f9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8006fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800701:	c9                   	leave  
  800702:	c3                   	ret    

00800703 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800703:	55                   	push   %ebp
  800704:	89 e5                	mov    %esp,%ebp
  800706:	57                   	push   %edi
  800707:	56                   	push   %esi
  800708:	53                   	push   %ebx
  800709:	83 ec 0c             	sub    $0xc,%esp
  80070c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80070f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800712:	85 f6                	test   %esi,%esi
  800714:	74 31                	je     800747 <readn+0x44>
  800716:	b8 00 00 00 00       	mov    $0x0,%eax
  80071b:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  800720:	83 ec 04             	sub    $0x4,%esp
  800723:	89 f2                	mov    %esi,%edx
  800725:	29 c2                	sub    %eax,%edx
  800727:	52                   	push   %edx
  800728:	03 45 0c             	add    0xc(%ebp),%eax
  80072b:	50                   	push   %eax
  80072c:	57                   	push   %edi
  80072d:	e8 4a ff ff ff       	call   80067c <read>
		if (m < 0)
  800732:	83 c4 10             	add    $0x10,%esp
  800735:	85 c0                	test   %eax,%eax
  800737:	78 17                	js     800750 <readn+0x4d>
			return m;
		if (m == 0)
  800739:	85 c0                	test   %eax,%eax
  80073b:	74 11                	je     80074e <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80073d:	01 c3                	add    %eax,%ebx
  80073f:	89 d8                	mov    %ebx,%eax
  800741:	39 f3                	cmp    %esi,%ebx
  800743:	72 db                	jb     800720 <readn+0x1d>
  800745:	eb 09                	jmp    800750 <readn+0x4d>
  800747:	b8 00 00 00 00       	mov    $0x0,%eax
  80074c:	eb 02                	jmp    800750 <readn+0x4d>
  80074e:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800750:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800753:	5b                   	pop    %ebx
  800754:	5e                   	pop    %esi
  800755:	5f                   	pop    %edi
  800756:	5d                   	pop    %ebp
  800757:	c3                   	ret    

00800758 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800758:	55                   	push   %ebp
  800759:	89 e5                	mov    %esp,%ebp
  80075b:	53                   	push   %ebx
  80075c:	83 ec 14             	sub    $0x14,%esp
  80075f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800762:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800765:	50                   	push   %eax
  800766:	53                   	push   %ebx
  800767:	e8 8f fc ff ff       	call   8003fb <fd_lookup>
  80076c:	83 c4 08             	add    $0x8,%esp
  80076f:	85 c0                	test   %eax,%eax
  800771:	78 62                	js     8007d5 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800773:	83 ec 08             	sub    $0x8,%esp
  800776:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800779:	50                   	push   %eax
  80077a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80077d:	ff 30                	pushl  (%eax)
  80077f:	e8 ce fc ff ff       	call   800452 <dev_lookup>
  800784:	83 c4 10             	add    $0x10,%esp
  800787:	85 c0                	test   %eax,%eax
  800789:	78 4a                	js     8007d5 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80078b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80078e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800792:	75 21                	jne    8007b5 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800794:	a1 04 40 80 00       	mov    0x804004,%eax
  800799:	8b 40 48             	mov    0x48(%eax),%eax
  80079c:	83 ec 04             	sub    $0x4,%esp
  80079f:	53                   	push   %ebx
  8007a0:	50                   	push   %eax
  8007a1:	68 d5 1e 80 00       	push   $0x801ed5
  8007a6:	e8 25 09 00 00       	call   8010d0 <cprintf>
		return -E_INVAL;
  8007ab:	83 c4 10             	add    $0x10,%esp
  8007ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007b3:	eb 20                	jmp    8007d5 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007b5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007b8:	8b 52 0c             	mov    0xc(%edx),%edx
  8007bb:	85 d2                	test   %edx,%edx
  8007bd:	74 11                	je     8007d0 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007bf:	83 ec 04             	sub    $0x4,%esp
  8007c2:	ff 75 10             	pushl  0x10(%ebp)
  8007c5:	ff 75 0c             	pushl  0xc(%ebp)
  8007c8:	50                   	push   %eax
  8007c9:	ff d2                	call   *%edx
  8007cb:	83 c4 10             	add    $0x10,%esp
  8007ce:	eb 05                	jmp    8007d5 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007d0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8007d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d8:	c9                   	leave  
  8007d9:	c3                   	ret    

008007da <seek>:

int
seek(int fdnum, off_t offset)
{
  8007da:	55                   	push   %ebp
  8007db:	89 e5                	mov    %esp,%ebp
  8007dd:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007e0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007e3:	50                   	push   %eax
  8007e4:	ff 75 08             	pushl  0x8(%ebp)
  8007e7:	e8 0f fc ff ff       	call   8003fb <fd_lookup>
  8007ec:	83 c4 08             	add    $0x8,%esp
  8007ef:	85 c0                	test   %eax,%eax
  8007f1:	78 0e                	js     800801 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f9:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007fc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800801:	c9                   	leave  
  800802:	c3                   	ret    

00800803 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800803:	55                   	push   %ebp
  800804:	89 e5                	mov    %esp,%ebp
  800806:	53                   	push   %ebx
  800807:	83 ec 14             	sub    $0x14,%esp
  80080a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80080d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800810:	50                   	push   %eax
  800811:	53                   	push   %ebx
  800812:	e8 e4 fb ff ff       	call   8003fb <fd_lookup>
  800817:	83 c4 08             	add    $0x8,%esp
  80081a:	85 c0                	test   %eax,%eax
  80081c:	78 5f                	js     80087d <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80081e:	83 ec 08             	sub    $0x8,%esp
  800821:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800824:	50                   	push   %eax
  800825:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800828:	ff 30                	pushl  (%eax)
  80082a:	e8 23 fc ff ff       	call   800452 <dev_lookup>
  80082f:	83 c4 10             	add    $0x10,%esp
  800832:	85 c0                	test   %eax,%eax
  800834:	78 47                	js     80087d <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800836:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800839:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80083d:	75 21                	jne    800860 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80083f:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800844:	8b 40 48             	mov    0x48(%eax),%eax
  800847:	83 ec 04             	sub    $0x4,%esp
  80084a:	53                   	push   %ebx
  80084b:	50                   	push   %eax
  80084c:	68 98 1e 80 00       	push   $0x801e98
  800851:	e8 7a 08 00 00       	call   8010d0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800856:	83 c4 10             	add    $0x10,%esp
  800859:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80085e:	eb 1d                	jmp    80087d <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  800860:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800863:	8b 52 18             	mov    0x18(%edx),%edx
  800866:	85 d2                	test   %edx,%edx
  800868:	74 0e                	je     800878 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80086a:	83 ec 08             	sub    $0x8,%esp
  80086d:	ff 75 0c             	pushl  0xc(%ebp)
  800870:	50                   	push   %eax
  800871:	ff d2                	call   *%edx
  800873:	83 c4 10             	add    $0x10,%esp
  800876:	eb 05                	jmp    80087d <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800878:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80087d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800880:	c9                   	leave  
  800881:	c3                   	ret    

00800882 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800882:	55                   	push   %ebp
  800883:	89 e5                	mov    %esp,%ebp
  800885:	53                   	push   %ebx
  800886:	83 ec 14             	sub    $0x14,%esp
  800889:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80088c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80088f:	50                   	push   %eax
  800890:	ff 75 08             	pushl  0x8(%ebp)
  800893:	e8 63 fb ff ff       	call   8003fb <fd_lookup>
  800898:	83 c4 08             	add    $0x8,%esp
  80089b:	85 c0                	test   %eax,%eax
  80089d:	78 52                	js     8008f1 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80089f:	83 ec 08             	sub    $0x8,%esp
  8008a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008a5:	50                   	push   %eax
  8008a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008a9:	ff 30                	pushl  (%eax)
  8008ab:	e8 a2 fb ff ff       	call   800452 <dev_lookup>
  8008b0:	83 c4 10             	add    $0x10,%esp
  8008b3:	85 c0                	test   %eax,%eax
  8008b5:	78 3a                	js     8008f1 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  8008b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008ba:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008be:	74 2c                	je     8008ec <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008c0:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008c3:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008ca:	00 00 00 
	stat->st_isdir = 0;
  8008cd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008d4:	00 00 00 
	stat->st_dev = dev;
  8008d7:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008dd:	83 ec 08             	sub    $0x8,%esp
  8008e0:	53                   	push   %ebx
  8008e1:	ff 75 f0             	pushl  -0x10(%ebp)
  8008e4:	ff 50 14             	call   *0x14(%eax)
  8008e7:	83 c4 10             	add    $0x10,%esp
  8008ea:	eb 05                	jmp    8008f1 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008ec:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008f4:	c9                   	leave  
  8008f5:	c3                   	ret    

008008f6 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008f6:	55                   	push   %ebp
  8008f7:	89 e5                	mov    %esp,%ebp
  8008f9:	56                   	push   %esi
  8008fa:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008fb:	83 ec 08             	sub    $0x8,%esp
  8008fe:	6a 00                	push   $0x0
  800900:	ff 75 08             	pushl  0x8(%ebp)
  800903:	e8 75 01 00 00       	call   800a7d <open>
  800908:	89 c3                	mov    %eax,%ebx
  80090a:	83 c4 10             	add    $0x10,%esp
  80090d:	85 c0                	test   %eax,%eax
  80090f:	78 1d                	js     80092e <stat+0x38>
		return fd;
	r = fstat(fd, stat);
  800911:	83 ec 08             	sub    $0x8,%esp
  800914:	ff 75 0c             	pushl  0xc(%ebp)
  800917:	50                   	push   %eax
  800918:	e8 65 ff ff ff       	call   800882 <fstat>
  80091d:	89 c6                	mov    %eax,%esi
	close(fd);
  80091f:	89 1c 24             	mov    %ebx,(%esp)
  800922:	e8 1d fc ff ff       	call   800544 <close>
	return r;
  800927:	83 c4 10             	add    $0x10,%esp
  80092a:	89 f0                	mov    %esi,%eax
  80092c:	eb 00                	jmp    80092e <stat+0x38>
}
  80092e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800931:	5b                   	pop    %ebx
  800932:	5e                   	pop    %esi
  800933:	5d                   	pop    %ebp
  800934:	c3                   	ret    

00800935 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800935:	55                   	push   %ebp
  800936:	89 e5                	mov    %esp,%ebp
  800938:	56                   	push   %esi
  800939:	53                   	push   %ebx
  80093a:	89 c6                	mov    %eax,%esi
  80093c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80093e:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800945:	75 12                	jne    800959 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800947:	83 ec 0c             	sub    $0xc,%esp
  80094a:	6a 01                	push   $0x1
  80094c:	e8 ec 11 00 00       	call   801b3d <ipc_find_env>
  800951:	a3 00 40 80 00       	mov    %eax,0x804000
  800956:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800959:	6a 07                	push   $0x7
  80095b:	68 00 50 80 00       	push   $0x805000
  800960:	56                   	push   %esi
  800961:	ff 35 00 40 80 00    	pushl  0x804000
  800967:	e8 72 11 00 00       	call   801ade <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80096c:	83 c4 0c             	add    $0xc,%esp
  80096f:	6a 00                	push   $0x0
  800971:	53                   	push   %ebx
  800972:	6a 00                	push   $0x0
  800974:	e8 f0 10 00 00       	call   801a69 <ipc_recv>
}
  800979:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80097c:	5b                   	pop    %ebx
  80097d:	5e                   	pop    %esi
  80097e:	5d                   	pop    %ebp
  80097f:	c3                   	ret    

00800980 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800980:	55                   	push   %ebp
  800981:	89 e5                	mov    %esp,%ebp
  800983:	53                   	push   %ebx
  800984:	83 ec 04             	sub    $0x4,%esp
  800987:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80098a:	8b 45 08             	mov    0x8(%ebp),%eax
  80098d:	8b 40 0c             	mov    0xc(%eax),%eax
  800990:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800995:	ba 00 00 00 00       	mov    $0x0,%edx
  80099a:	b8 05 00 00 00       	mov    $0x5,%eax
  80099f:	e8 91 ff ff ff       	call   800935 <fsipc>
  8009a4:	85 c0                	test   %eax,%eax
  8009a6:	78 2c                	js     8009d4 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009a8:	83 ec 08             	sub    $0x8,%esp
  8009ab:	68 00 50 80 00       	push   $0x805000
  8009b0:	53                   	push   %ebx
  8009b1:	e8 ff 0c 00 00       	call   8016b5 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009b6:	a1 80 50 80 00       	mov    0x805080,%eax
  8009bb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009c1:	a1 84 50 80 00       	mov    0x805084,%eax
  8009c6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009cc:	83 c4 10             	add    $0x10,%esp
  8009cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009d7:	c9                   	leave  
  8009d8:	c3                   	ret    

008009d9 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009d9:	55                   	push   %ebp
  8009da:	89 e5                	mov    %esp,%ebp
  8009dc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009df:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e2:	8b 40 0c             	mov    0xc(%eax),%eax
  8009e5:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ef:	b8 06 00 00 00       	mov    $0x6,%eax
  8009f4:	e8 3c ff ff ff       	call   800935 <fsipc>
}
  8009f9:	c9                   	leave  
  8009fa:	c3                   	ret    

008009fb <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8009fb:	55                   	push   %ebp
  8009fc:	89 e5                	mov    %esp,%ebp
  8009fe:	56                   	push   %esi
  8009ff:	53                   	push   %ebx
  800a00:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a03:	8b 45 08             	mov    0x8(%ebp),%eax
  800a06:	8b 40 0c             	mov    0xc(%eax),%eax
  800a09:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a0e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a14:	ba 00 00 00 00       	mov    $0x0,%edx
  800a19:	b8 03 00 00 00       	mov    $0x3,%eax
  800a1e:	e8 12 ff ff ff       	call   800935 <fsipc>
  800a23:	89 c3                	mov    %eax,%ebx
  800a25:	85 c0                	test   %eax,%eax
  800a27:	78 4b                	js     800a74 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a29:	39 c6                	cmp    %eax,%esi
  800a2b:	73 16                	jae    800a43 <devfile_read+0x48>
  800a2d:	68 f2 1e 80 00       	push   $0x801ef2
  800a32:	68 f9 1e 80 00       	push   $0x801ef9
  800a37:	6a 7a                	push   $0x7a
  800a39:	68 0e 1f 80 00       	push   $0x801f0e
  800a3e:	e8 b5 05 00 00       	call   800ff8 <_panic>
	assert(r <= PGSIZE);
  800a43:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a48:	7e 16                	jle    800a60 <devfile_read+0x65>
  800a4a:	68 19 1f 80 00       	push   $0x801f19
  800a4f:	68 f9 1e 80 00       	push   $0x801ef9
  800a54:	6a 7b                	push   $0x7b
  800a56:	68 0e 1f 80 00       	push   $0x801f0e
  800a5b:	e8 98 05 00 00       	call   800ff8 <_panic>
	memmove(buf, &fsipcbuf, r);
  800a60:	83 ec 04             	sub    $0x4,%esp
  800a63:	50                   	push   %eax
  800a64:	68 00 50 80 00       	push   $0x805000
  800a69:	ff 75 0c             	pushl  0xc(%ebp)
  800a6c:	e8 11 0e 00 00       	call   801882 <memmove>
	return r;
  800a71:	83 c4 10             	add    $0x10,%esp
}
  800a74:	89 d8                	mov    %ebx,%eax
  800a76:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a79:	5b                   	pop    %ebx
  800a7a:	5e                   	pop    %esi
  800a7b:	5d                   	pop    %ebp
  800a7c:	c3                   	ret    

00800a7d <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800a7d:	55                   	push   %ebp
  800a7e:	89 e5                	mov    %esp,%ebp
  800a80:	53                   	push   %ebx
  800a81:	83 ec 20             	sub    $0x20,%esp
  800a84:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800a87:	53                   	push   %ebx
  800a88:	e8 d1 0b 00 00       	call   80165e <strlen>
  800a8d:	83 c4 10             	add    $0x10,%esp
  800a90:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800a95:	7f 63                	jg     800afa <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800a97:	83 ec 0c             	sub    $0xc,%esp
  800a9a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a9d:	50                   	push   %eax
  800a9e:	e8 e4 f8 ff ff       	call   800387 <fd_alloc>
  800aa3:	83 c4 10             	add    $0x10,%esp
  800aa6:	85 c0                	test   %eax,%eax
  800aa8:	78 55                	js     800aff <open+0x82>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800aaa:	83 ec 08             	sub    $0x8,%esp
  800aad:	53                   	push   %ebx
  800aae:	68 00 50 80 00       	push   $0x805000
  800ab3:	e8 fd 0b 00 00       	call   8016b5 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800ab8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800abb:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800ac0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ac3:	b8 01 00 00 00       	mov    $0x1,%eax
  800ac8:	e8 68 fe ff ff       	call   800935 <fsipc>
  800acd:	89 c3                	mov    %eax,%ebx
  800acf:	83 c4 10             	add    $0x10,%esp
  800ad2:	85 c0                	test   %eax,%eax
  800ad4:	79 14                	jns    800aea <open+0x6d>
		fd_close(fd, 0);
  800ad6:	83 ec 08             	sub    $0x8,%esp
  800ad9:	6a 00                	push   $0x0
  800adb:	ff 75 f4             	pushl  -0xc(%ebp)
  800ade:	e8 dd f9 ff ff       	call   8004c0 <fd_close>
		return r;
  800ae3:	83 c4 10             	add    $0x10,%esp
  800ae6:	89 d8                	mov    %ebx,%eax
  800ae8:	eb 15                	jmp    800aff <open+0x82>
	}

	return fd2num(fd);
  800aea:	83 ec 0c             	sub    $0xc,%esp
  800aed:	ff 75 f4             	pushl  -0xc(%ebp)
  800af0:	e8 6b f8 ff ff       	call   800360 <fd2num>
  800af5:	83 c4 10             	add    $0x10,%esp
  800af8:	eb 05                	jmp    800aff <open+0x82>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800afa:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800aff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b02:	c9                   	leave  
  800b03:	c3                   	ret    

00800b04 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b04:	55                   	push   %ebp
  800b05:	89 e5                	mov    %esp,%ebp
  800b07:	56                   	push   %esi
  800b08:	53                   	push   %ebx
  800b09:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b0c:	83 ec 0c             	sub    $0xc,%esp
  800b0f:	ff 75 08             	pushl  0x8(%ebp)
  800b12:	e8 59 f8 ff ff       	call   800370 <fd2data>
  800b17:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b19:	83 c4 08             	add    $0x8,%esp
  800b1c:	68 25 1f 80 00       	push   $0x801f25
  800b21:	53                   	push   %ebx
  800b22:	e8 8e 0b 00 00       	call   8016b5 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b27:	8b 46 04             	mov    0x4(%esi),%eax
  800b2a:	2b 06                	sub    (%esi),%eax
  800b2c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b32:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b39:	00 00 00 
	stat->st_dev = &devpipe;
  800b3c:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800b43:	30 80 00 
	return 0;
}
  800b46:	b8 00 00 00 00       	mov    $0x0,%eax
  800b4b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b4e:	5b                   	pop    %ebx
  800b4f:	5e                   	pop    %esi
  800b50:	5d                   	pop    %ebp
  800b51:	c3                   	ret    

00800b52 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b52:	55                   	push   %ebp
  800b53:	89 e5                	mov    %esp,%ebp
  800b55:	53                   	push   %ebx
  800b56:	83 ec 0c             	sub    $0xc,%esp
  800b59:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800b5c:	53                   	push   %ebx
  800b5d:	6a 00                	push   $0x0
  800b5f:	e8 90 f6 ff ff       	call   8001f4 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800b64:	89 1c 24             	mov    %ebx,(%esp)
  800b67:	e8 04 f8 ff ff       	call   800370 <fd2data>
  800b6c:	83 c4 08             	add    $0x8,%esp
  800b6f:	50                   	push   %eax
  800b70:	6a 00                	push   $0x0
  800b72:	e8 7d f6 ff ff       	call   8001f4 <sys_page_unmap>
}
  800b77:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b7a:	c9                   	leave  
  800b7b:	c3                   	ret    

00800b7c <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
  800b7f:	57                   	push   %edi
  800b80:	56                   	push   %esi
  800b81:	53                   	push   %ebx
  800b82:	83 ec 1c             	sub    $0x1c,%esp
  800b85:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b88:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800b8a:	a1 04 40 80 00       	mov    0x804004,%eax
  800b8f:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800b92:	83 ec 0c             	sub    $0xc,%esp
  800b95:	ff 75 e0             	pushl  -0x20(%ebp)
  800b98:	e8 fb 0f 00 00       	call   801b98 <pageref>
  800b9d:	89 c3                	mov    %eax,%ebx
  800b9f:	89 3c 24             	mov    %edi,(%esp)
  800ba2:	e8 f1 0f 00 00       	call   801b98 <pageref>
  800ba7:	83 c4 10             	add    $0x10,%esp
  800baa:	39 c3                	cmp    %eax,%ebx
  800bac:	0f 94 c1             	sete   %cl
  800baf:	0f b6 c9             	movzbl %cl,%ecx
  800bb2:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800bb5:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800bbb:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800bbe:	39 ce                	cmp    %ecx,%esi
  800bc0:	74 1b                	je     800bdd <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800bc2:	39 c3                	cmp    %eax,%ebx
  800bc4:	75 c4                	jne    800b8a <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800bc6:	8b 42 58             	mov    0x58(%edx),%eax
  800bc9:	ff 75 e4             	pushl  -0x1c(%ebp)
  800bcc:	50                   	push   %eax
  800bcd:	56                   	push   %esi
  800bce:	68 2c 1f 80 00       	push   $0x801f2c
  800bd3:	e8 f8 04 00 00       	call   8010d0 <cprintf>
  800bd8:	83 c4 10             	add    $0x10,%esp
  800bdb:	eb ad                	jmp    800b8a <_pipeisclosed+0xe>
	}
}
  800bdd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800be0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be3:	5b                   	pop    %ebx
  800be4:	5e                   	pop    %esi
  800be5:	5f                   	pop    %edi
  800be6:	5d                   	pop    %ebp
  800be7:	c3                   	ret    

00800be8 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800be8:	55                   	push   %ebp
  800be9:	89 e5                	mov    %esp,%ebp
  800beb:	57                   	push   %edi
  800bec:	56                   	push   %esi
  800bed:	53                   	push   %ebx
  800bee:	83 ec 18             	sub    $0x18,%esp
  800bf1:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800bf4:	56                   	push   %esi
  800bf5:	e8 76 f7 ff ff       	call   800370 <fd2data>
  800bfa:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800bfc:	83 c4 10             	add    $0x10,%esp
  800bff:	bf 00 00 00 00       	mov    $0x0,%edi
  800c04:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c08:	75 42                	jne    800c4c <devpipe_write+0x64>
  800c0a:	eb 4e                	jmp    800c5a <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c0c:	89 da                	mov    %ebx,%edx
  800c0e:	89 f0                	mov    %esi,%eax
  800c10:	e8 67 ff ff ff       	call   800b7c <_pipeisclosed>
  800c15:	85 c0                	test   %eax,%eax
  800c17:	75 46                	jne    800c5f <devpipe_write+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c19:	e8 32 f5 ff ff       	call   800150 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c1e:	8b 53 04             	mov    0x4(%ebx),%edx
  800c21:	8b 03                	mov    (%ebx),%eax
  800c23:	83 c0 20             	add    $0x20,%eax
  800c26:	39 c2                	cmp    %eax,%edx
  800c28:	73 e2                	jae    800c0c <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c2a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c2d:	8a 0c 38             	mov    (%eax,%edi,1),%cl
  800c30:	89 d0                	mov    %edx,%eax
  800c32:	25 1f 00 00 80       	and    $0x8000001f,%eax
  800c37:	79 05                	jns    800c3e <devpipe_write+0x56>
  800c39:	48                   	dec    %eax
  800c3a:	83 c8 e0             	or     $0xffffffe0,%eax
  800c3d:	40                   	inc    %eax
  800c3e:	88 4c 03 08          	mov    %cl,0x8(%ebx,%eax,1)
		p->p_wpos++;
  800c42:	42                   	inc    %edx
  800c43:	89 53 04             	mov    %edx,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c46:	47                   	inc    %edi
  800c47:	39 7d 10             	cmp    %edi,0x10(%ebp)
  800c4a:	74 0e                	je     800c5a <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c4c:	8b 53 04             	mov    0x4(%ebx),%edx
  800c4f:	8b 03                	mov    (%ebx),%eax
  800c51:	83 c0 20             	add    $0x20,%eax
  800c54:	39 c2                	cmp    %eax,%edx
  800c56:	73 b4                	jae    800c0c <devpipe_write+0x24>
  800c58:	eb d0                	jmp    800c2a <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800c5a:	8b 45 10             	mov    0x10(%ebp),%eax
  800c5d:	eb 05                	jmp    800c64 <devpipe_write+0x7c>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800c5f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800c64:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c67:	5b                   	pop    %ebx
  800c68:	5e                   	pop    %esi
  800c69:	5f                   	pop    %edi
  800c6a:	5d                   	pop    %ebp
  800c6b:	c3                   	ret    

00800c6c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800c6c:	55                   	push   %ebp
  800c6d:	89 e5                	mov    %esp,%ebp
  800c6f:	57                   	push   %edi
  800c70:	56                   	push   %esi
  800c71:	53                   	push   %ebx
  800c72:	83 ec 18             	sub    $0x18,%esp
  800c75:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800c78:	57                   	push   %edi
  800c79:	e8 f2 f6 ff ff       	call   800370 <fd2data>
  800c7e:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c80:	83 c4 10             	add    $0x10,%esp
  800c83:	be 00 00 00 00       	mov    $0x0,%esi
  800c88:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c8c:	75 3d                	jne    800ccb <devpipe_read+0x5f>
  800c8e:	eb 48                	jmp    800cd8 <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  800c90:	89 f0                	mov    %esi,%eax
  800c92:	eb 4e                	jmp    800ce2 <devpipe_read+0x76>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800c94:	89 da                	mov    %ebx,%edx
  800c96:	89 f8                	mov    %edi,%eax
  800c98:	e8 df fe ff ff       	call   800b7c <_pipeisclosed>
  800c9d:	85 c0                	test   %eax,%eax
  800c9f:	75 3c                	jne    800cdd <devpipe_read+0x71>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800ca1:	e8 aa f4 ff ff       	call   800150 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800ca6:	8b 03                	mov    (%ebx),%eax
  800ca8:	3b 43 04             	cmp    0x4(%ebx),%eax
  800cab:	74 e7                	je     800c94 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800cad:	25 1f 00 00 80       	and    $0x8000001f,%eax
  800cb2:	79 05                	jns    800cb9 <devpipe_read+0x4d>
  800cb4:	48                   	dec    %eax
  800cb5:	83 c8 e0             	or     $0xffffffe0,%eax
  800cb8:	40                   	inc    %eax
  800cb9:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  800cbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc0:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800cc3:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cc5:	46                   	inc    %esi
  800cc6:	39 75 10             	cmp    %esi,0x10(%ebp)
  800cc9:	74 0d                	je     800cd8 <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
  800ccb:	8b 03                	mov    (%ebx),%eax
  800ccd:	3b 43 04             	cmp    0x4(%ebx),%eax
  800cd0:	75 db                	jne    800cad <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800cd2:	85 f6                	test   %esi,%esi
  800cd4:	75 ba                	jne    800c90 <devpipe_read+0x24>
  800cd6:	eb bc                	jmp    800c94 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800cd8:	8b 45 10             	mov    0x10(%ebp),%eax
  800cdb:	eb 05                	jmp    800ce2 <devpipe_read+0x76>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cdd:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800ce2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce5:	5b                   	pop    %ebx
  800ce6:	5e                   	pop    %esi
  800ce7:	5f                   	pop    %edi
  800ce8:	5d                   	pop    %ebp
  800ce9:	c3                   	ret    

00800cea <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800cea:	55                   	push   %ebp
  800ceb:	89 e5                	mov    %esp,%ebp
  800ced:	56                   	push   %esi
  800cee:	53                   	push   %ebx
  800cef:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800cf2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800cf5:	50                   	push   %eax
  800cf6:	e8 8c f6 ff ff       	call   800387 <fd_alloc>
  800cfb:	83 c4 10             	add    $0x10,%esp
  800cfe:	85 c0                	test   %eax,%eax
  800d00:	0f 88 2a 01 00 00    	js     800e30 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d06:	83 ec 04             	sub    $0x4,%esp
  800d09:	68 07 04 00 00       	push   $0x407
  800d0e:	ff 75 f4             	pushl  -0xc(%ebp)
  800d11:	6a 00                	push   $0x0
  800d13:	e8 57 f4 ff ff       	call   80016f <sys_page_alloc>
  800d18:	83 c4 10             	add    $0x10,%esp
  800d1b:	85 c0                	test   %eax,%eax
  800d1d:	0f 88 0d 01 00 00    	js     800e30 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d23:	83 ec 0c             	sub    $0xc,%esp
  800d26:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d29:	50                   	push   %eax
  800d2a:	e8 58 f6 ff ff       	call   800387 <fd_alloc>
  800d2f:	89 c3                	mov    %eax,%ebx
  800d31:	83 c4 10             	add    $0x10,%esp
  800d34:	85 c0                	test   %eax,%eax
  800d36:	0f 88 e2 00 00 00    	js     800e1e <pipe+0x134>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d3c:	83 ec 04             	sub    $0x4,%esp
  800d3f:	68 07 04 00 00       	push   $0x407
  800d44:	ff 75 f0             	pushl  -0x10(%ebp)
  800d47:	6a 00                	push   $0x0
  800d49:	e8 21 f4 ff ff       	call   80016f <sys_page_alloc>
  800d4e:	89 c3                	mov    %eax,%ebx
  800d50:	83 c4 10             	add    $0x10,%esp
  800d53:	85 c0                	test   %eax,%eax
  800d55:	0f 88 c3 00 00 00    	js     800e1e <pipe+0x134>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800d5b:	83 ec 0c             	sub    $0xc,%esp
  800d5e:	ff 75 f4             	pushl  -0xc(%ebp)
  800d61:	e8 0a f6 ff ff       	call   800370 <fd2data>
  800d66:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d68:	83 c4 0c             	add    $0xc,%esp
  800d6b:	68 07 04 00 00       	push   $0x407
  800d70:	50                   	push   %eax
  800d71:	6a 00                	push   $0x0
  800d73:	e8 f7 f3 ff ff       	call   80016f <sys_page_alloc>
  800d78:	89 c3                	mov    %eax,%ebx
  800d7a:	83 c4 10             	add    $0x10,%esp
  800d7d:	85 c0                	test   %eax,%eax
  800d7f:	0f 88 89 00 00 00    	js     800e0e <pipe+0x124>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d85:	83 ec 0c             	sub    $0xc,%esp
  800d88:	ff 75 f0             	pushl  -0x10(%ebp)
  800d8b:	e8 e0 f5 ff ff       	call   800370 <fd2data>
  800d90:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800d97:	50                   	push   %eax
  800d98:	6a 00                	push   $0x0
  800d9a:	56                   	push   %esi
  800d9b:	6a 00                	push   $0x0
  800d9d:	e8 10 f4 ff ff       	call   8001b2 <sys_page_map>
  800da2:	89 c3                	mov    %eax,%ebx
  800da4:	83 c4 20             	add    $0x20,%esp
  800da7:	85 c0                	test   %eax,%eax
  800da9:	78 55                	js     800e00 <pipe+0x116>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800dab:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800db1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800db4:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800db6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800db9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800dc0:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800dc6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dc9:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800dcb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dce:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800dd5:	83 ec 0c             	sub    $0xc,%esp
  800dd8:	ff 75 f4             	pushl  -0xc(%ebp)
  800ddb:	e8 80 f5 ff ff       	call   800360 <fd2num>
  800de0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800de3:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800de5:	83 c4 04             	add    $0x4,%esp
  800de8:	ff 75 f0             	pushl  -0x10(%ebp)
  800deb:	e8 70 f5 ff ff       	call   800360 <fd2num>
  800df0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800df3:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800df6:	83 c4 10             	add    $0x10,%esp
  800df9:	b8 00 00 00 00       	mov    $0x0,%eax
  800dfe:	eb 30                	jmp    800e30 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  800e00:	83 ec 08             	sub    $0x8,%esp
  800e03:	56                   	push   %esi
  800e04:	6a 00                	push   $0x0
  800e06:	e8 e9 f3 ff ff       	call   8001f4 <sys_page_unmap>
  800e0b:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e0e:	83 ec 08             	sub    $0x8,%esp
  800e11:	ff 75 f0             	pushl  -0x10(%ebp)
  800e14:	6a 00                	push   $0x0
  800e16:	e8 d9 f3 ff ff       	call   8001f4 <sys_page_unmap>
  800e1b:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e1e:	83 ec 08             	sub    $0x8,%esp
  800e21:	ff 75 f4             	pushl  -0xc(%ebp)
  800e24:	6a 00                	push   $0x0
  800e26:	e8 c9 f3 ff ff       	call   8001f4 <sys_page_unmap>
  800e2b:	83 c4 10             	add    $0x10,%esp
  800e2e:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  800e30:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e33:	5b                   	pop    %ebx
  800e34:	5e                   	pop    %esi
  800e35:	5d                   	pop    %ebp
  800e36:	c3                   	ret    

00800e37 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e37:	55                   	push   %ebp
  800e38:	89 e5                	mov    %esp,%ebp
  800e3a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e3d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e40:	50                   	push   %eax
  800e41:	ff 75 08             	pushl  0x8(%ebp)
  800e44:	e8 b2 f5 ff ff       	call   8003fb <fd_lookup>
  800e49:	83 c4 10             	add    $0x10,%esp
  800e4c:	85 c0                	test   %eax,%eax
  800e4e:	78 18                	js     800e68 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800e50:	83 ec 0c             	sub    $0xc,%esp
  800e53:	ff 75 f4             	pushl  -0xc(%ebp)
  800e56:	e8 15 f5 ff ff       	call   800370 <fd2data>
	return _pipeisclosed(fd, p);
  800e5b:	89 c2                	mov    %eax,%edx
  800e5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e60:	e8 17 fd ff ff       	call   800b7c <_pipeisclosed>
  800e65:	83 c4 10             	add    $0x10,%esp
}
  800e68:	c9                   	leave  
  800e69:	c3                   	ret    

00800e6a <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800e6a:	55                   	push   %ebp
  800e6b:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800e6d:	b8 00 00 00 00       	mov    $0x0,%eax
  800e72:	5d                   	pop    %ebp
  800e73:	c3                   	ret    

00800e74 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800e74:	55                   	push   %ebp
  800e75:	89 e5                	mov    %esp,%ebp
  800e77:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800e7a:	68 44 1f 80 00       	push   $0x801f44
  800e7f:	ff 75 0c             	pushl  0xc(%ebp)
  800e82:	e8 2e 08 00 00       	call   8016b5 <strcpy>
	return 0;
}
  800e87:	b8 00 00 00 00       	mov    $0x0,%eax
  800e8c:	c9                   	leave  
  800e8d:	c3                   	ret    

00800e8e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800e8e:	55                   	push   %ebp
  800e8f:	89 e5                	mov    %esp,%ebp
  800e91:	57                   	push   %edi
  800e92:	56                   	push   %esi
  800e93:	53                   	push   %ebx
  800e94:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800e9a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e9e:	74 45                	je     800ee5 <devcons_write+0x57>
  800ea0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea5:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800eaa:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800eb0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eb3:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  800eb5:	83 fb 7f             	cmp    $0x7f,%ebx
  800eb8:	76 05                	jbe    800ebf <devcons_write+0x31>
			m = sizeof(buf) - 1;
  800eba:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800ebf:	83 ec 04             	sub    $0x4,%esp
  800ec2:	53                   	push   %ebx
  800ec3:	03 45 0c             	add    0xc(%ebp),%eax
  800ec6:	50                   	push   %eax
  800ec7:	57                   	push   %edi
  800ec8:	e8 b5 09 00 00       	call   801882 <memmove>
		sys_cputs(buf, m);
  800ecd:	83 c4 08             	add    $0x8,%esp
  800ed0:	53                   	push   %ebx
  800ed1:	57                   	push   %edi
  800ed2:	e8 dc f1 ff ff       	call   8000b3 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ed7:	01 de                	add    %ebx,%esi
  800ed9:	89 f0                	mov    %esi,%eax
  800edb:	83 c4 10             	add    $0x10,%esp
  800ede:	3b 75 10             	cmp    0x10(%ebp),%esi
  800ee1:	72 cd                	jb     800eb0 <devcons_write+0x22>
  800ee3:	eb 05                	jmp    800eea <devcons_write+0x5c>
  800ee5:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800eea:	89 f0                	mov    %esi,%eax
  800eec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eef:	5b                   	pop    %ebx
  800ef0:	5e                   	pop    %esi
  800ef1:	5f                   	pop    %edi
  800ef2:	5d                   	pop    %ebp
  800ef3:	c3                   	ret    

00800ef4 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800ef4:	55                   	push   %ebp
  800ef5:	89 e5                	mov    %esp,%ebp
  800ef7:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  800efa:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800efe:	75 07                	jne    800f07 <devcons_read+0x13>
  800f00:	eb 23                	jmp    800f25 <devcons_read+0x31>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f02:	e8 49 f2 ff ff       	call   800150 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f07:	e8 c5 f1 ff ff       	call   8000d1 <sys_cgetc>
  800f0c:	85 c0                	test   %eax,%eax
  800f0e:	74 f2                	je     800f02 <devcons_read+0xe>
		sys_yield();
	if (c < 0)
  800f10:	85 c0                	test   %eax,%eax
  800f12:	78 1d                	js     800f31 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f14:	83 f8 04             	cmp    $0x4,%eax
  800f17:	74 13                	je     800f2c <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  800f19:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f1c:	88 02                	mov    %al,(%edx)
	return 1;
  800f1e:	b8 01 00 00 00       	mov    $0x1,%eax
  800f23:	eb 0c                	jmp    800f31 <devcons_read+0x3d>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  800f25:	b8 00 00 00 00       	mov    $0x0,%eax
  800f2a:	eb 05                	jmp    800f31 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f2c:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f31:	c9                   	leave  
  800f32:	c3                   	ret    

00800f33 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f33:	55                   	push   %ebp
  800f34:	89 e5                	mov    %esp,%ebp
  800f36:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f39:	8b 45 08             	mov    0x8(%ebp),%eax
  800f3c:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f3f:	6a 01                	push   $0x1
  800f41:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f44:	50                   	push   %eax
  800f45:	e8 69 f1 ff ff       	call   8000b3 <sys_cputs>
}
  800f4a:	83 c4 10             	add    $0x10,%esp
  800f4d:	c9                   	leave  
  800f4e:	c3                   	ret    

00800f4f <getchar>:

int
getchar(void)
{
  800f4f:	55                   	push   %ebp
  800f50:	89 e5                	mov    %esp,%ebp
  800f52:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f55:	6a 01                	push   $0x1
  800f57:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f5a:	50                   	push   %eax
  800f5b:	6a 00                	push   $0x0
  800f5d:	e8 1a f7 ff ff       	call   80067c <read>
	if (r < 0)
  800f62:	83 c4 10             	add    $0x10,%esp
  800f65:	85 c0                	test   %eax,%eax
  800f67:	78 0f                	js     800f78 <getchar+0x29>
		return r;
	if (r < 1)
  800f69:	85 c0                	test   %eax,%eax
  800f6b:	7e 06                	jle    800f73 <getchar+0x24>
		return -E_EOF;
	return c;
  800f6d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800f71:	eb 05                	jmp    800f78 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800f73:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800f78:	c9                   	leave  
  800f79:	c3                   	ret    

00800f7a <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800f7a:	55                   	push   %ebp
  800f7b:	89 e5                	mov    %esp,%ebp
  800f7d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f80:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f83:	50                   	push   %eax
  800f84:	ff 75 08             	pushl  0x8(%ebp)
  800f87:	e8 6f f4 ff ff       	call   8003fb <fd_lookup>
  800f8c:	83 c4 10             	add    $0x10,%esp
  800f8f:	85 c0                	test   %eax,%eax
  800f91:	78 11                	js     800fa4 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800f93:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f96:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800f9c:	39 10                	cmp    %edx,(%eax)
  800f9e:	0f 94 c0             	sete   %al
  800fa1:	0f b6 c0             	movzbl %al,%eax
}
  800fa4:	c9                   	leave  
  800fa5:	c3                   	ret    

00800fa6 <opencons>:

int
opencons(void)
{
  800fa6:	55                   	push   %ebp
  800fa7:	89 e5                	mov    %esp,%ebp
  800fa9:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800faf:	50                   	push   %eax
  800fb0:	e8 d2 f3 ff ff       	call   800387 <fd_alloc>
  800fb5:	83 c4 10             	add    $0x10,%esp
  800fb8:	85 c0                	test   %eax,%eax
  800fba:	78 3a                	js     800ff6 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fbc:	83 ec 04             	sub    $0x4,%esp
  800fbf:	68 07 04 00 00       	push   $0x407
  800fc4:	ff 75 f4             	pushl  -0xc(%ebp)
  800fc7:	6a 00                	push   $0x0
  800fc9:	e8 a1 f1 ff ff       	call   80016f <sys_page_alloc>
  800fce:	83 c4 10             	add    $0x10,%esp
  800fd1:	85 c0                	test   %eax,%eax
  800fd3:	78 21                	js     800ff6 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800fd5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fde:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800fe0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fe3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800fea:	83 ec 0c             	sub    $0xc,%esp
  800fed:	50                   	push   %eax
  800fee:	e8 6d f3 ff ff       	call   800360 <fd2num>
  800ff3:	83 c4 10             	add    $0x10,%esp
}
  800ff6:	c9                   	leave  
  800ff7:	c3                   	ret    

00800ff8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800ff8:	55                   	push   %ebp
  800ff9:	89 e5                	mov    %esp,%ebp
  800ffb:	56                   	push   %esi
  800ffc:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800ffd:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801000:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801006:	e8 26 f1 ff ff       	call   800131 <sys_getenvid>
  80100b:	83 ec 0c             	sub    $0xc,%esp
  80100e:	ff 75 0c             	pushl  0xc(%ebp)
  801011:	ff 75 08             	pushl  0x8(%ebp)
  801014:	56                   	push   %esi
  801015:	50                   	push   %eax
  801016:	68 50 1f 80 00       	push   $0x801f50
  80101b:	e8 b0 00 00 00       	call   8010d0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801020:	83 c4 18             	add    $0x18,%esp
  801023:	53                   	push   %ebx
  801024:	ff 75 10             	pushl  0x10(%ebp)
  801027:	e8 53 00 00 00       	call   80107f <vcprintf>
	cprintf("\n");
  80102c:	c7 04 24 3d 1f 80 00 	movl   $0x801f3d,(%esp)
  801033:	e8 98 00 00 00       	call   8010d0 <cprintf>
  801038:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80103b:	cc                   	int3   
  80103c:	eb fd                	jmp    80103b <_panic+0x43>

0080103e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80103e:	55                   	push   %ebp
  80103f:	89 e5                	mov    %esp,%ebp
  801041:	53                   	push   %ebx
  801042:	83 ec 04             	sub    $0x4,%esp
  801045:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801048:	8b 13                	mov    (%ebx),%edx
  80104a:	8d 42 01             	lea    0x1(%edx),%eax
  80104d:	89 03                	mov    %eax,(%ebx)
  80104f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801052:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801056:	3d ff 00 00 00       	cmp    $0xff,%eax
  80105b:	75 1a                	jne    801077 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80105d:	83 ec 08             	sub    $0x8,%esp
  801060:	68 ff 00 00 00       	push   $0xff
  801065:	8d 43 08             	lea    0x8(%ebx),%eax
  801068:	50                   	push   %eax
  801069:	e8 45 f0 ff ff       	call   8000b3 <sys_cputs>
		b->idx = 0;
  80106e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801074:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801077:	ff 43 04             	incl   0x4(%ebx)
}
  80107a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80107d:	c9                   	leave  
  80107e:	c3                   	ret    

0080107f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80107f:	55                   	push   %ebp
  801080:	89 e5                	mov    %esp,%ebp
  801082:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801088:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80108f:	00 00 00 
	b.cnt = 0;
  801092:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801099:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80109c:	ff 75 0c             	pushl  0xc(%ebp)
  80109f:	ff 75 08             	pushl  0x8(%ebp)
  8010a2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010a8:	50                   	push   %eax
  8010a9:	68 3e 10 80 00       	push   $0x80103e
  8010ae:	e8 54 01 00 00       	call   801207 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010b3:	83 c4 08             	add    $0x8,%esp
  8010b6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010bc:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010c2:	50                   	push   %eax
  8010c3:	e8 eb ef ff ff       	call   8000b3 <sys_cputs>

	return b.cnt;
}
  8010c8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8010ce:	c9                   	leave  
  8010cf:	c3                   	ret    

008010d0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8010d0:	55                   	push   %ebp
  8010d1:	89 e5                	mov    %esp,%ebp
  8010d3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8010d6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8010d9:	50                   	push   %eax
  8010da:	ff 75 08             	pushl  0x8(%ebp)
  8010dd:	e8 9d ff ff ff       	call   80107f <vcprintf>
	va_end(ap);

	return cnt;
}
  8010e2:	c9                   	leave  
  8010e3:	c3                   	ret    

008010e4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8010e4:	55                   	push   %ebp
  8010e5:	89 e5                	mov    %esp,%ebp
  8010e7:	57                   	push   %edi
  8010e8:	56                   	push   %esi
  8010e9:	53                   	push   %ebx
  8010ea:	83 ec 1c             	sub    $0x1c,%esp
  8010ed:	89 c6                	mov    %eax,%esi
  8010ef:	89 d7                	mov    %edx,%edi
  8010f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010f7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8010fa:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8010fd:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801100:	bb 00 00 00 00       	mov    $0x0,%ebx
  801105:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801108:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80110b:	39 d3                	cmp    %edx,%ebx
  80110d:	72 11                	jb     801120 <printnum+0x3c>
  80110f:	39 45 10             	cmp    %eax,0x10(%ebp)
  801112:	76 0c                	jbe    801120 <printnum+0x3c>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801114:	8b 45 14             	mov    0x14(%ebp),%eax
  801117:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80111a:	85 db                	test   %ebx,%ebx
  80111c:	7f 37                	jg     801155 <printnum+0x71>
  80111e:	eb 44                	jmp    801164 <printnum+0x80>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801120:	83 ec 0c             	sub    $0xc,%esp
  801123:	ff 75 18             	pushl  0x18(%ebp)
  801126:	8b 45 14             	mov    0x14(%ebp),%eax
  801129:	48                   	dec    %eax
  80112a:	50                   	push   %eax
  80112b:	ff 75 10             	pushl  0x10(%ebp)
  80112e:	83 ec 08             	sub    $0x8,%esp
  801131:	ff 75 e4             	pushl  -0x1c(%ebp)
  801134:	ff 75 e0             	pushl  -0x20(%ebp)
  801137:	ff 75 dc             	pushl  -0x24(%ebp)
  80113a:	ff 75 d8             	pushl  -0x28(%ebp)
  80113d:	e8 9a 0a 00 00       	call   801bdc <__udivdi3>
  801142:	83 c4 18             	add    $0x18,%esp
  801145:	52                   	push   %edx
  801146:	50                   	push   %eax
  801147:	89 fa                	mov    %edi,%edx
  801149:	89 f0                	mov    %esi,%eax
  80114b:	e8 94 ff ff ff       	call   8010e4 <printnum>
  801150:	83 c4 20             	add    $0x20,%esp
  801153:	eb 0f                	jmp    801164 <printnum+0x80>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801155:	83 ec 08             	sub    $0x8,%esp
  801158:	57                   	push   %edi
  801159:	ff 75 18             	pushl  0x18(%ebp)
  80115c:	ff d6                	call   *%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80115e:	83 c4 10             	add    $0x10,%esp
  801161:	4b                   	dec    %ebx
  801162:	75 f1                	jne    801155 <printnum+0x71>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801164:	83 ec 08             	sub    $0x8,%esp
  801167:	57                   	push   %edi
  801168:	83 ec 04             	sub    $0x4,%esp
  80116b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80116e:	ff 75 e0             	pushl  -0x20(%ebp)
  801171:	ff 75 dc             	pushl  -0x24(%ebp)
  801174:	ff 75 d8             	pushl  -0x28(%ebp)
  801177:	e8 70 0b 00 00       	call   801cec <__umoddi3>
  80117c:	83 c4 14             	add    $0x14,%esp
  80117f:	0f be 80 73 1f 80 00 	movsbl 0x801f73(%eax),%eax
  801186:	50                   	push   %eax
  801187:	ff d6                	call   *%esi
}
  801189:	83 c4 10             	add    $0x10,%esp
  80118c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80118f:	5b                   	pop    %ebx
  801190:	5e                   	pop    %esi
  801191:	5f                   	pop    %edi
  801192:	5d                   	pop    %ebp
  801193:	c3                   	ret    

00801194 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801194:	55                   	push   %ebp
  801195:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801197:	83 fa 01             	cmp    $0x1,%edx
  80119a:	7e 0e                	jle    8011aa <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80119c:	8b 10                	mov    (%eax),%edx
  80119e:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011a1:	89 08                	mov    %ecx,(%eax)
  8011a3:	8b 02                	mov    (%edx),%eax
  8011a5:	8b 52 04             	mov    0x4(%edx),%edx
  8011a8:	eb 22                	jmp    8011cc <getuint+0x38>
	else if (lflag)
  8011aa:	85 d2                	test   %edx,%edx
  8011ac:	74 10                	je     8011be <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8011ae:	8b 10                	mov    (%eax),%edx
  8011b0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011b3:	89 08                	mov    %ecx,(%eax)
  8011b5:	8b 02                	mov    (%edx),%eax
  8011b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8011bc:	eb 0e                	jmp    8011cc <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8011be:	8b 10                	mov    (%eax),%edx
  8011c0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011c3:	89 08                	mov    %ecx,(%eax)
  8011c5:	8b 02                	mov    (%edx),%eax
  8011c7:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8011cc:	5d                   	pop    %ebp
  8011cd:	c3                   	ret    

008011ce <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011ce:	55                   	push   %ebp
  8011cf:	89 e5                	mov    %esp,%ebp
  8011d1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011d4:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8011d7:	8b 10                	mov    (%eax),%edx
  8011d9:	3b 50 04             	cmp    0x4(%eax),%edx
  8011dc:	73 0a                	jae    8011e8 <sprintputch+0x1a>
		*b->buf++ = ch;
  8011de:	8d 4a 01             	lea    0x1(%edx),%ecx
  8011e1:	89 08                	mov    %ecx,(%eax)
  8011e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e6:	88 02                	mov    %al,(%edx)
}
  8011e8:	5d                   	pop    %ebp
  8011e9:	c3                   	ret    

008011ea <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8011ea:	55                   	push   %ebp
  8011eb:	89 e5                	mov    %esp,%ebp
  8011ed:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8011f0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8011f3:	50                   	push   %eax
  8011f4:	ff 75 10             	pushl  0x10(%ebp)
  8011f7:	ff 75 0c             	pushl  0xc(%ebp)
  8011fa:	ff 75 08             	pushl  0x8(%ebp)
  8011fd:	e8 05 00 00 00       	call   801207 <vprintfmt>
	va_end(ap);
}
  801202:	83 c4 10             	add    $0x10,%esp
  801205:	c9                   	leave  
  801206:	c3                   	ret    

00801207 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801207:	55                   	push   %ebp
  801208:	89 e5                	mov    %esp,%ebp
  80120a:	57                   	push   %edi
  80120b:	56                   	push   %esi
  80120c:	53                   	push   %ebx
  80120d:	83 ec 2c             	sub    $0x2c,%esp
  801210:	8b 7d 08             	mov    0x8(%ebp),%edi
  801213:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801216:	eb 03                	jmp    80121b <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  801218:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  80121b:	8b 45 10             	mov    0x10(%ebp),%eax
  80121e:	8d 70 01             	lea    0x1(%eax),%esi
  801221:	0f b6 00             	movzbl (%eax),%eax
  801224:	83 f8 25             	cmp    $0x25,%eax
  801227:	74 25                	je     80124e <vprintfmt+0x47>
			if (ch == '\0')									//当然中间如果遇到'\0'，代表这个字符串的访问结束
  801229:	85 c0                	test   %eax,%eax
  80122b:	75 0d                	jne    80123a <vprintfmt+0x33>
  80122d:	e9 b5 03 00 00       	jmp    8015e7 <vprintfmt+0x3e0>
  801232:	85 c0                	test   %eax,%eax
  801234:	0f 84 ad 03 00 00    	je     8015e7 <vprintfmt+0x3e0>
				return;
			putch(ch, putdat);								//调用putch函数，把一个字符ch输出到putdat指针所指向的地址中所存放的值对应的地址处
  80123a:	83 ec 08             	sub    $0x8,%esp
  80123d:	53                   	push   %ebx
  80123e:	50                   	push   %eax
  80123f:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  801241:	46                   	inc    %esi
  801242:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  801246:	83 c4 10             	add    $0x10,%esp
  801249:	83 f8 25             	cmp    $0x25,%eax
  80124c:	75 e4                	jne    801232 <vprintfmt+0x2b>
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  80124e:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  801252:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801259:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801260:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  801267:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80126e:	eb 07                	jmp    801277 <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  801270:	8b 75 10             	mov    0x10(%ebp),%esi

		// flag to pad on the right
		case '-':											//%后面的'-'代表要进行左对齐输出，右边填空格，如果省略代表右对齐
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
  801273:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  801277:	8d 46 01             	lea    0x1(%esi),%eax
  80127a:	89 45 10             	mov    %eax,0x10(%ebp)
  80127d:	0f b6 16             	movzbl (%esi),%edx
  801280:	8a 06                	mov    (%esi),%al
  801282:	83 e8 23             	sub    $0x23,%eax
  801285:	3c 55                	cmp    $0x55,%al
  801287:	0f 87 03 03 00 00    	ja     801590 <vprintfmt+0x389>
  80128d:	0f b6 c0             	movzbl %al,%eax
  801290:	ff 24 85 c0 20 80 00 	jmp    *0x8020c0(,%eax,4)
  801297:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
			goto reswitch;									//处理下一个字符

		// flag to pad with 0's instead of spaces
		case '0':											//0--有0表示进行对齐输出时填0,如省略表示填入空格，并且如果为0，则一定是右对齐
			padc = '0';										//对其方式标志位变为0
  80129a:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  80129e:	eb d7                	jmp    801277 <vprintfmt+0x70>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
				precision = precision * 10 + ch - '0';
  8012a0:	8d 42 d0             	lea    -0x30(%edx),%eax
  8012a3:	89 c1                	mov    %eax,%ecx
  8012a5:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  8012a8:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8012ac:	8d 50 d0             	lea    -0x30(%eax),%edx
  8012af:	83 fa 09             	cmp    $0x9,%edx
  8012b2:	77 51                	ja     801305 <vprintfmt+0xfe>
  8012b4:	8b 75 10             	mov    0x10(%ebp),%esi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
  8012b7:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8012b8:	8d 14 89             	lea    (%ecx,%ecx,4),%edx
  8012bb:	01 d2                	add    %edx,%edx
  8012bd:	8d 4c 10 d0          	lea    -0x30(%eax,%edx,1),%ecx
				ch = *fmt;
  8012c1:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8012c4:	8d 50 d0             	lea    -0x30(%eax),%edx
  8012c7:	83 fa 09             	cmp    $0x9,%edx
  8012ca:	76 eb                	jbe    8012b7 <vprintfmt+0xb0>
  8012cc:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8012cf:	eb 37                	jmp    801308 <vprintfmt+0x101>
					break;
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
  8012d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8012d4:	8d 50 04             	lea    0x4(%eax),%edx
  8012d7:	89 55 14             	mov    %edx,0x14(%ebp)
  8012da:	8b 00                	mov    (%eax),%eax
  8012dc:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8012df:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
			goto process_precision;
  8012e2:	eb 24                	jmp    801308 <vprintfmt+0x101>
  8012e4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8012e8:	79 07                	jns    8012f1 <vprintfmt+0xea>
  8012ea:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8012f1:	8b 75 10             	mov    0x10(%ebp),%esi
  8012f4:	eb 81                	jmp    801277 <vprintfmt+0x70>
  8012f6:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  8012f9:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801300:	e9 72 ff ff ff       	jmp    801277 <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  801305:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:									//处理输出精度，把width字段赋值为刚刚计算出来的precision值，所以width应该是整数部分的有效数字位数
			if (width < 0)
  801308:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80130c:	0f 89 65 ff ff ff    	jns    801277 <vprintfmt+0x70>
				width = precision, precision = -1;
  801312:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801315:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801318:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80131f:	e9 53 ff ff ff       	jmp    801277 <vprintfmt+0x70>
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
  801324:	ff 45 d4             	incl   -0x2c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  801327:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
			goto reswitch;
  80132a:	e9 48 ff ff ff       	jmp    801277 <vprintfmt+0x70>

		// character
		case 'c':											//如果是'c'代表显示一个字符
			putch(va_arg(ap, int), putdat);					//调用输出一个字符到内存的函数putch
  80132f:	8b 45 14             	mov    0x14(%ebp),%eax
  801332:	8d 50 04             	lea    0x4(%eax),%edx
  801335:	89 55 14             	mov    %edx,0x14(%ebp)
  801338:	83 ec 08             	sub    $0x8,%esp
  80133b:	53                   	push   %ebx
  80133c:	ff 30                	pushl  (%eax)
  80133e:	ff d7                	call   *%edi
			break;
  801340:	83 c4 10             	add    $0x10,%esp
  801343:	e9 d3 fe ff ff       	jmp    80121b <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801348:	8b 45 14             	mov    0x14(%ebp),%eax
  80134b:	8d 50 04             	lea    0x4(%eax),%edx
  80134e:	89 55 14             	mov    %edx,0x14(%ebp)
  801351:	8b 00                	mov    (%eax),%eax
  801353:	85 c0                	test   %eax,%eax
  801355:	79 02                	jns    801359 <vprintfmt+0x152>
  801357:	f7 d8                	neg    %eax
  801359:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80135b:	83 f8 0f             	cmp    $0xf,%eax
  80135e:	7f 0b                	jg     80136b <vprintfmt+0x164>
  801360:	8b 04 85 20 22 80 00 	mov    0x802220(,%eax,4),%eax
  801367:	85 c0                	test   %eax,%eax
  801369:	75 15                	jne    801380 <vprintfmt+0x179>
				printfmt(putch, putdat, "error %d", err);
  80136b:	52                   	push   %edx
  80136c:	68 8b 1f 80 00       	push   $0x801f8b
  801371:	53                   	push   %ebx
  801372:	57                   	push   %edi
  801373:	e8 72 fe ff ff       	call   8011ea <printfmt>
  801378:	83 c4 10             	add    $0x10,%esp
  80137b:	e9 9b fe ff ff       	jmp    80121b <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  801380:	50                   	push   %eax
  801381:	68 0b 1f 80 00       	push   $0x801f0b
  801386:	53                   	push   %ebx
  801387:	57                   	push   %edi
  801388:	e8 5d fe ff ff       	call   8011ea <printfmt>
  80138d:	83 c4 10             	add    $0x10,%esp
  801390:	e9 86 fe ff ff       	jmp    80121b <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801395:	8b 45 14             	mov    0x14(%ebp),%eax
  801398:	8d 50 04             	lea    0x4(%eax),%edx
  80139b:	89 55 14             	mov    %edx,0x14(%ebp)
  80139e:	8b 00                	mov    (%eax),%eax
  8013a0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8013a3:	85 c0                	test   %eax,%eax
  8013a5:	75 07                	jne    8013ae <vprintfmt+0x1a7>
				p = "(null)";
  8013a7:	c7 45 d4 84 1f 80 00 	movl   $0x801f84,-0x2c(%ebp)
			if (width > 0 && padc != '-')
  8013ae:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8013b1:	85 f6                	test   %esi,%esi
  8013b3:	0f 8e fb 01 00 00    	jle    8015b4 <vprintfmt+0x3ad>
  8013b9:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  8013bd:	0f 84 09 02 00 00    	je     8015cc <vprintfmt+0x3c5>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013c3:	83 ec 08             	sub    $0x8,%esp
  8013c6:	ff 75 d0             	pushl  -0x30(%ebp)
  8013c9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013cc:	e8 ad 02 00 00       	call   80167e <strnlen>
  8013d1:	89 f1                	mov    %esi,%ecx
  8013d3:	29 c1                	sub    %eax,%ecx
  8013d5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8013d8:	83 c4 10             	add    $0x10,%esp
  8013db:	85 c9                	test   %ecx,%ecx
  8013dd:	0f 8e d1 01 00 00    	jle    8015b4 <vprintfmt+0x3ad>
					putch(padc, putdat);
  8013e3:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8013e7:	83 ec 08             	sub    $0x8,%esp
  8013ea:	53                   	push   %ebx
  8013eb:	56                   	push   %esi
  8013ec:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013ee:	83 c4 10             	add    $0x10,%esp
  8013f1:	ff 4d e4             	decl   -0x1c(%ebp)
  8013f4:	75 f1                	jne    8013e7 <vprintfmt+0x1e0>
  8013f6:	e9 b9 01 00 00       	jmp    8015b4 <vprintfmt+0x3ad>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8013fb:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8013ff:	74 19                	je     80141a <vprintfmt+0x213>
  801401:	0f be c0             	movsbl %al,%eax
  801404:	83 e8 20             	sub    $0x20,%eax
  801407:	83 f8 5e             	cmp    $0x5e,%eax
  80140a:	76 0e                	jbe    80141a <vprintfmt+0x213>
					putch('?', putdat);
  80140c:	83 ec 08             	sub    $0x8,%esp
  80140f:	53                   	push   %ebx
  801410:	6a 3f                	push   $0x3f
  801412:	ff 55 08             	call   *0x8(%ebp)
  801415:	83 c4 10             	add    $0x10,%esp
  801418:	eb 0b                	jmp    801425 <vprintfmt+0x21e>
				else
					putch(ch, putdat);
  80141a:	83 ec 08             	sub    $0x8,%esp
  80141d:	53                   	push   %ebx
  80141e:	52                   	push   %edx
  80141f:	ff 55 08             	call   *0x8(%ebp)
  801422:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801425:	ff 4d e4             	decl   -0x1c(%ebp)
  801428:	46                   	inc    %esi
  801429:	8a 46 ff             	mov    -0x1(%esi),%al
  80142c:	0f be d0             	movsbl %al,%edx
  80142f:	85 d2                	test   %edx,%edx
  801431:	75 1c                	jne    80144f <vprintfmt+0x248>
  801433:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801436:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80143a:	7f 1f                	jg     80145b <vprintfmt+0x254>
  80143c:	e9 da fd ff ff       	jmp    80121b <vprintfmt+0x14>
  801441:	89 7d 08             	mov    %edi,0x8(%ebp)
  801444:	8b 7d d0             	mov    -0x30(%ebp),%edi
  801447:	eb 06                	jmp    80144f <vprintfmt+0x248>
  801449:	89 7d 08             	mov    %edi,0x8(%ebp)
  80144c:	8b 7d d0             	mov    -0x30(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80144f:	85 ff                	test   %edi,%edi
  801451:	78 a8                	js     8013fb <vprintfmt+0x1f4>
  801453:	4f                   	dec    %edi
  801454:	79 a5                	jns    8013fb <vprintfmt+0x1f4>
  801456:	8b 7d 08             	mov    0x8(%ebp),%edi
  801459:	eb db                	jmp    801436 <vprintfmt+0x22f>
  80145b:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80145e:	83 ec 08             	sub    $0x8,%esp
  801461:	53                   	push   %ebx
  801462:	6a 20                	push   $0x20
  801464:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801466:	4e                   	dec    %esi
  801467:	83 c4 10             	add    $0x10,%esp
  80146a:	85 f6                	test   %esi,%esi
  80146c:	7f f0                	jg     80145e <vprintfmt+0x257>
  80146e:	e9 a8 fd ff ff       	jmp    80121b <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801473:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  801477:	7e 16                	jle    80148f <vprintfmt+0x288>
		return va_arg(*ap, long long);
  801479:	8b 45 14             	mov    0x14(%ebp),%eax
  80147c:	8d 50 08             	lea    0x8(%eax),%edx
  80147f:	89 55 14             	mov    %edx,0x14(%ebp)
  801482:	8b 50 04             	mov    0x4(%eax),%edx
  801485:	8b 00                	mov    (%eax),%eax
  801487:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80148a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80148d:	eb 34                	jmp    8014c3 <vprintfmt+0x2bc>
	else if (lflag)
  80148f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  801493:	74 18                	je     8014ad <vprintfmt+0x2a6>
		return va_arg(*ap, long);
  801495:	8b 45 14             	mov    0x14(%ebp),%eax
  801498:	8d 50 04             	lea    0x4(%eax),%edx
  80149b:	89 55 14             	mov    %edx,0x14(%ebp)
  80149e:	8b 30                	mov    (%eax),%esi
  8014a0:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8014a3:	89 f0                	mov    %esi,%eax
  8014a5:	c1 f8 1f             	sar    $0x1f,%eax
  8014a8:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8014ab:	eb 16                	jmp    8014c3 <vprintfmt+0x2bc>
	else
		return va_arg(*ap, int);
  8014ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8014b0:	8d 50 04             	lea    0x4(%eax),%edx
  8014b3:	89 55 14             	mov    %edx,0x14(%ebp)
  8014b6:	8b 30                	mov    (%eax),%esi
  8014b8:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8014bb:	89 f0                	mov    %esi,%eax
  8014bd:	c1 f8 1f             	sar    $0x1f,%eax
  8014c0:	89 45 dc             	mov    %eax,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8014c3:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8014c6:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
  8014c9:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8014cd:	0f 89 8a 00 00 00    	jns    80155d <vprintfmt+0x356>
				putch('-', putdat);
  8014d3:	83 ec 08             	sub    $0x8,%esp
  8014d6:	53                   	push   %ebx
  8014d7:	6a 2d                	push   $0x2d
  8014d9:	ff d7                	call   *%edi
				num = -(long long) num;
  8014db:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8014de:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8014e1:	f7 d8                	neg    %eax
  8014e3:	83 d2 00             	adc    $0x0,%edx
  8014e6:	f7 da                	neg    %edx
  8014e8:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8014eb:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8014f0:	eb 70                	jmp    801562 <vprintfmt+0x35b>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8014f2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8014f5:	8d 45 14             	lea    0x14(%ebp),%eax
  8014f8:	e8 97 fc ff ff       	call   801194 <getuint>
			base = 10;
  8014fd:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801502:	eb 5e                	jmp    801562 <vprintfmt+0x35b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  801504:	83 ec 08             	sub    $0x8,%esp
  801507:	53                   	push   %ebx
  801508:	6a 30                	push   $0x30
  80150a:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  80150c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80150f:	8d 45 14             	lea    0x14(%ebp),%eax
  801512:	e8 7d fc ff ff       	call   801194 <getuint>
			base = 8;
			goto number;
  801517:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  80151a:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80151f:	eb 41                	jmp    801562 <vprintfmt+0x35b>
		// pointer
		case 'p':
			putch('0', putdat);
  801521:	83 ec 08             	sub    $0x8,%esp
  801524:	53                   	push   %ebx
  801525:	6a 30                	push   $0x30
  801527:	ff d7                	call   *%edi
			putch('x', putdat);
  801529:	83 c4 08             	add    $0x8,%esp
  80152c:	53                   	push   %ebx
  80152d:	6a 78                	push   $0x78
  80152f:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801531:	8b 45 14             	mov    0x14(%ebp),%eax
  801534:	8d 50 04             	lea    0x4(%eax),%edx
  801537:	89 55 14             	mov    %edx,0x14(%ebp)
			goto number;
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80153a:	8b 00                	mov    (%eax),%eax
  80153c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801541:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801544:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801549:	eb 17                	jmp    801562 <vprintfmt+0x35b>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80154b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80154e:	8d 45 14             	lea    0x14(%ebp),%eax
  801551:	e8 3e fc ff ff       	call   801194 <getuint>
			base = 16;
  801556:	b9 10 00 00 00       	mov    $0x10,%ecx
  80155b:	eb 05                	jmp    801562 <vprintfmt+0x35b>
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80155d:	b9 0a 00 00 00       	mov    $0xa,%ecx
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  801562:	83 ec 0c             	sub    $0xc,%esp
  801565:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  801569:	56                   	push   %esi
  80156a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80156d:	51                   	push   %ecx
  80156e:	52                   	push   %edx
  80156f:	50                   	push   %eax
  801570:	89 da                	mov    %ebx,%edx
  801572:	89 f8                	mov    %edi,%eax
  801574:	e8 6b fb ff ff       	call   8010e4 <printnum>
			break;
  801579:	83 c4 20             	add    $0x20,%esp
  80157c:	e9 9a fc ff ff       	jmp    80121b <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801581:	83 ec 08             	sub    $0x8,%esp
  801584:	53                   	push   %ebx
  801585:	52                   	push   %edx
  801586:	ff d7                	call   *%edi
			break;
  801588:	83 c4 10             	add    $0x10,%esp
  80158b:	e9 8b fc ff ff       	jmp    80121b <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801590:	83 ec 08             	sub    $0x8,%esp
  801593:	53                   	push   %ebx
  801594:	6a 25                	push   $0x25
  801596:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801598:	83 c4 10             	add    $0x10,%esp
  80159b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80159f:	0f 84 73 fc ff ff    	je     801218 <vprintfmt+0x11>
  8015a5:	4e                   	dec    %esi
  8015a6:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8015aa:	75 f9                	jne    8015a5 <vprintfmt+0x39e>
  8015ac:	89 75 10             	mov    %esi,0x10(%ebp)
  8015af:	e9 67 fc ff ff       	jmp    80121b <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8015b4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8015b7:	8d 70 01             	lea    0x1(%eax),%esi
  8015ba:	8a 00                	mov    (%eax),%al
  8015bc:	0f be d0             	movsbl %al,%edx
  8015bf:	85 d2                	test   %edx,%edx
  8015c1:	0f 85 7a fe ff ff    	jne    801441 <vprintfmt+0x23a>
  8015c7:	e9 4f fc ff ff       	jmp    80121b <vprintfmt+0x14>
  8015cc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8015cf:	8d 70 01             	lea    0x1(%eax),%esi
  8015d2:	8a 00                	mov    (%eax),%al
  8015d4:	0f be d0             	movsbl %al,%edx
  8015d7:	85 d2                	test   %edx,%edx
  8015d9:	0f 85 6a fe ff ff    	jne    801449 <vprintfmt+0x242>
  8015df:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8015e2:	e9 77 fe ff ff       	jmp    80145e <vprintfmt+0x257>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  8015e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015ea:	5b                   	pop    %ebx
  8015eb:	5e                   	pop    %esi
  8015ec:	5f                   	pop    %edi
  8015ed:	5d                   	pop    %ebp
  8015ee:	c3                   	ret    

008015ef <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8015ef:	55                   	push   %ebp
  8015f0:	89 e5                	mov    %esp,%ebp
  8015f2:	83 ec 18             	sub    $0x18,%esp
  8015f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8015f8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8015fb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8015fe:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801602:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801605:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80160c:	85 c0                	test   %eax,%eax
  80160e:	74 26                	je     801636 <vsnprintf+0x47>
  801610:	85 d2                	test   %edx,%edx
  801612:	7e 29                	jle    80163d <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801614:	ff 75 14             	pushl  0x14(%ebp)
  801617:	ff 75 10             	pushl  0x10(%ebp)
  80161a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80161d:	50                   	push   %eax
  80161e:	68 ce 11 80 00       	push   $0x8011ce
  801623:	e8 df fb ff ff       	call   801207 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801628:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80162b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80162e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801631:	83 c4 10             	add    $0x10,%esp
  801634:	eb 0c                	jmp    801642 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801636:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80163b:	eb 05                	jmp    801642 <vsnprintf+0x53>
  80163d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801642:	c9                   	leave  
  801643:	c3                   	ret    

00801644 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801644:	55                   	push   %ebp
  801645:	89 e5                	mov    %esp,%ebp
  801647:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80164a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80164d:	50                   	push   %eax
  80164e:	ff 75 10             	pushl  0x10(%ebp)
  801651:	ff 75 0c             	pushl  0xc(%ebp)
  801654:	ff 75 08             	pushl  0x8(%ebp)
  801657:	e8 93 ff ff ff       	call   8015ef <vsnprintf>
	va_end(ap);

	return rc;
}
  80165c:	c9                   	leave  
  80165d:	c3                   	ret    

0080165e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80165e:	55                   	push   %ebp
  80165f:	89 e5                	mov    %esp,%ebp
  801661:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801664:	80 3a 00             	cmpb   $0x0,(%edx)
  801667:	74 0e                	je     801677 <strlen+0x19>
  801669:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80166e:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80166f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801673:	75 f9                	jne    80166e <strlen+0x10>
  801675:	eb 05                	jmp    80167c <strlen+0x1e>
  801677:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80167c:	5d                   	pop    %ebp
  80167d:	c3                   	ret    

0080167e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80167e:	55                   	push   %ebp
  80167f:	89 e5                	mov    %esp,%ebp
  801681:	53                   	push   %ebx
  801682:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801685:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801688:	85 c9                	test   %ecx,%ecx
  80168a:	74 1a                	je     8016a6 <strnlen+0x28>
  80168c:	80 3b 00             	cmpb   $0x0,(%ebx)
  80168f:	74 1c                	je     8016ad <strnlen+0x2f>
  801691:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  801696:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801698:	39 ca                	cmp    %ecx,%edx
  80169a:	74 16                	je     8016b2 <strnlen+0x34>
  80169c:	42                   	inc    %edx
  80169d:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8016a2:	75 f2                	jne    801696 <strnlen+0x18>
  8016a4:	eb 0c                	jmp    8016b2 <strnlen+0x34>
  8016a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8016ab:	eb 05                	jmp    8016b2 <strnlen+0x34>
  8016ad:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8016b2:	5b                   	pop    %ebx
  8016b3:	5d                   	pop    %ebp
  8016b4:	c3                   	ret    

008016b5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016b5:	55                   	push   %ebp
  8016b6:	89 e5                	mov    %esp,%ebp
  8016b8:	53                   	push   %ebx
  8016b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8016bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016bf:	89 c2                	mov    %eax,%edx
  8016c1:	42                   	inc    %edx
  8016c2:	41                   	inc    %ecx
  8016c3:	8a 59 ff             	mov    -0x1(%ecx),%bl
  8016c6:	88 5a ff             	mov    %bl,-0x1(%edx)
  8016c9:	84 db                	test   %bl,%bl
  8016cb:	75 f4                	jne    8016c1 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8016cd:	5b                   	pop    %ebx
  8016ce:	5d                   	pop    %ebp
  8016cf:	c3                   	ret    

008016d0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016d0:	55                   	push   %ebp
  8016d1:	89 e5                	mov    %esp,%ebp
  8016d3:	53                   	push   %ebx
  8016d4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016d7:	53                   	push   %ebx
  8016d8:	e8 81 ff ff ff       	call   80165e <strlen>
  8016dd:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8016e0:	ff 75 0c             	pushl  0xc(%ebp)
  8016e3:	01 d8                	add    %ebx,%eax
  8016e5:	50                   	push   %eax
  8016e6:	e8 ca ff ff ff       	call   8016b5 <strcpy>
	return dst;
}
  8016eb:	89 d8                	mov    %ebx,%eax
  8016ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016f0:	c9                   	leave  
  8016f1:	c3                   	ret    

008016f2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016f2:	55                   	push   %ebp
  8016f3:	89 e5                	mov    %esp,%ebp
  8016f5:	56                   	push   %esi
  8016f6:	53                   	push   %ebx
  8016f7:	8b 75 08             	mov    0x8(%ebp),%esi
  8016fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016fd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801700:	85 db                	test   %ebx,%ebx
  801702:	74 14                	je     801718 <strncpy+0x26>
  801704:	01 f3                	add    %esi,%ebx
  801706:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  801708:	41                   	inc    %ecx
  801709:	8a 02                	mov    (%edx),%al
  80170b:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80170e:	80 3a 01             	cmpb   $0x1,(%edx)
  801711:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801714:	39 cb                	cmp    %ecx,%ebx
  801716:	75 f0                	jne    801708 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801718:	89 f0                	mov    %esi,%eax
  80171a:	5b                   	pop    %ebx
  80171b:	5e                   	pop    %esi
  80171c:	5d                   	pop    %ebp
  80171d:	c3                   	ret    

0080171e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80171e:	55                   	push   %ebp
  80171f:	89 e5                	mov    %esp,%ebp
  801721:	53                   	push   %ebx
  801722:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801725:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801728:	85 c0                	test   %eax,%eax
  80172a:	74 30                	je     80175c <strlcpy+0x3e>
		while (--size > 0 && *src != '\0')
  80172c:	48                   	dec    %eax
  80172d:	74 20                	je     80174f <strlcpy+0x31>
  80172f:	8a 0b                	mov    (%ebx),%cl
  801731:	84 c9                	test   %cl,%cl
  801733:	74 1f                	je     801754 <strlcpy+0x36>
  801735:	8d 53 01             	lea    0x1(%ebx),%edx
  801738:	01 c3                	add    %eax,%ebx
  80173a:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
  80173d:	40                   	inc    %eax
  80173e:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801741:	39 da                	cmp    %ebx,%edx
  801743:	74 12                	je     801757 <strlcpy+0x39>
  801745:	42                   	inc    %edx
  801746:	8a 4a ff             	mov    -0x1(%edx),%cl
  801749:	84 c9                	test   %cl,%cl
  80174b:	75 f0                	jne    80173d <strlcpy+0x1f>
  80174d:	eb 08                	jmp    801757 <strlcpy+0x39>
  80174f:	8b 45 08             	mov    0x8(%ebp),%eax
  801752:	eb 03                	jmp    801757 <strlcpy+0x39>
  801754:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
		*dst = '\0';
  801757:	c6 00 00             	movb   $0x0,(%eax)
  80175a:	eb 03                	jmp    80175f <strlcpy+0x41>
  80175c:	8b 45 08             	mov    0x8(%ebp),%eax
	}
	return dst - dst_in;
  80175f:	2b 45 08             	sub    0x8(%ebp),%eax
}
  801762:	5b                   	pop    %ebx
  801763:	5d                   	pop    %ebp
  801764:	c3                   	ret    

00801765 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801765:	55                   	push   %ebp
  801766:	89 e5                	mov    %esp,%ebp
  801768:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80176b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80176e:	8a 01                	mov    (%ecx),%al
  801770:	84 c0                	test   %al,%al
  801772:	74 10                	je     801784 <strcmp+0x1f>
  801774:	3a 02                	cmp    (%edx),%al
  801776:	75 0c                	jne    801784 <strcmp+0x1f>
		p++, q++;
  801778:	41                   	inc    %ecx
  801779:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80177a:	8a 01                	mov    (%ecx),%al
  80177c:	84 c0                	test   %al,%al
  80177e:	74 04                	je     801784 <strcmp+0x1f>
  801780:	3a 02                	cmp    (%edx),%al
  801782:	74 f4                	je     801778 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801784:	0f b6 c0             	movzbl %al,%eax
  801787:	0f b6 12             	movzbl (%edx),%edx
  80178a:	29 d0                	sub    %edx,%eax
}
  80178c:	5d                   	pop    %ebp
  80178d:	c3                   	ret    

0080178e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80178e:	55                   	push   %ebp
  80178f:	89 e5                	mov    %esp,%ebp
  801791:	56                   	push   %esi
  801792:	53                   	push   %ebx
  801793:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801796:	8b 55 0c             	mov    0xc(%ebp),%edx
  801799:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  80179c:	85 f6                	test   %esi,%esi
  80179e:	74 23                	je     8017c3 <strncmp+0x35>
  8017a0:	8a 03                	mov    (%ebx),%al
  8017a2:	84 c0                	test   %al,%al
  8017a4:	74 2b                	je     8017d1 <strncmp+0x43>
  8017a6:	3a 02                	cmp    (%edx),%al
  8017a8:	75 27                	jne    8017d1 <strncmp+0x43>
  8017aa:	8d 43 01             	lea    0x1(%ebx),%eax
  8017ad:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  8017af:	89 c3                	mov    %eax,%ebx
  8017b1:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017b2:	39 c6                	cmp    %eax,%esi
  8017b4:	74 14                	je     8017ca <strncmp+0x3c>
  8017b6:	8a 08                	mov    (%eax),%cl
  8017b8:	84 c9                	test   %cl,%cl
  8017ba:	74 15                	je     8017d1 <strncmp+0x43>
  8017bc:	40                   	inc    %eax
  8017bd:	3a 0a                	cmp    (%edx),%cl
  8017bf:	74 ee                	je     8017af <strncmp+0x21>
  8017c1:	eb 0e                	jmp    8017d1 <strncmp+0x43>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8017c8:	eb 0f                	jmp    8017d9 <strncmp+0x4b>
  8017ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8017cf:	eb 08                	jmp    8017d9 <strncmp+0x4b>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017d1:	0f b6 03             	movzbl (%ebx),%eax
  8017d4:	0f b6 12             	movzbl (%edx),%edx
  8017d7:	29 d0                	sub    %edx,%eax
}
  8017d9:	5b                   	pop    %ebx
  8017da:	5e                   	pop    %esi
  8017db:	5d                   	pop    %ebp
  8017dc:	c3                   	ret    

008017dd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017dd:	55                   	push   %ebp
  8017de:	89 e5                	mov    %esp,%ebp
  8017e0:	53                   	push   %ebx
  8017e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  8017e7:	8a 10                	mov    (%eax),%dl
  8017e9:	84 d2                	test   %dl,%dl
  8017eb:	74 1a                	je     801807 <strchr+0x2a>
  8017ed:	88 d9                	mov    %bl,%cl
		if (*s == c)
  8017ef:	38 d3                	cmp    %dl,%bl
  8017f1:	75 06                	jne    8017f9 <strchr+0x1c>
  8017f3:	eb 17                	jmp    80180c <strchr+0x2f>
  8017f5:	38 ca                	cmp    %cl,%dl
  8017f7:	74 13                	je     80180c <strchr+0x2f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017f9:	40                   	inc    %eax
  8017fa:	8a 10                	mov    (%eax),%dl
  8017fc:	84 d2                	test   %dl,%dl
  8017fe:	75 f5                	jne    8017f5 <strchr+0x18>
		if (*s == c)
			return (char *) s;
	return 0;
  801800:	b8 00 00 00 00       	mov    $0x0,%eax
  801805:	eb 05                	jmp    80180c <strchr+0x2f>
  801807:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80180c:	5b                   	pop    %ebx
  80180d:	5d                   	pop    %ebp
  80180e:	c3                   	ret    

0080180f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80180f:	55                   	push   %ebp
  801810:	89 e5                	mov    %esp,%ebp
  801812:	53                   	push   %ebx
  801813:	8b 45 08             	mov    0x8(%ebp),%eax
  801816:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  801819:	8a 10                	mov    (%eax),%dl
  80181b:	84 d2                	test   %dl,%dl
  80181d:	74 13                	je     801832 <strfind+0x23>
  80181f:	88 d9                	mov    %bl,%cl
		if (*s == c)
  801821:	38 d3                	cmp    %dl,%bl
  801823:	75 06                	jne    80182b <strfind+0x1c>
  801825:	eb 0b                	jmp    801832 <strfind+0x23>
  801827:	38 ca                	cmp    %cl,%dl
  801829:	74 07                	je     801832 <strfind+0x23>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80182b:	40                   	inc    %eax
  80182c:	8a 10                	mov    (%eax),%dl
  80182e:	84 d2                	test   %dl,%dl
  801830:	75 f5                	jne    801827 <strfind+0x18>
		if (*s == c)
			break;
	return (char *) s;
}
  801832:	5b                   	pop    %ebx
  801833:	5d                   	pop    %ebp
  801834:	c3                   	ret    

00801835 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801835:	55                   	push   %ebp
  801836:	89 e5                	mov    %esp,%ebp
  801838:	57                   	push   %edi
  801839:	56                   	push   %esi
  80183a:	53                   	push   %ebx
  80183b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80183e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801841:	85 c9                	test   %ecx,%ecx
  801843:	74 36                	je     80187b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801845:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80184b:	75 28                	jne    801875 <memset+0x40>
  80184d:	f6 c1 03             	test   $0x3,%cl
  801850:	75 23                	jne    801875 <memset+0x40>
		c &= 0xFF;
  801852:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801856:	89 d3                	mov    %edx,%ebx
  801858:	c1 e3 08             	shl    $0x8,%ebx
  80185b:	89 d6                	mov    %edx,%esi
  80185d:	c1 e6 18             	shl    $0x18,%esi
  801860:	89 d0                	mov    %edx,%eax
  801862:	c1 e0 10             	shl    $0x10,%eax
  801865:	09 f0                	or     %esi,%eax
  801867:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801869:	89 d8                	mov    %ebx,%eax
  80186b:	09 d0                	or     %edx,%eax
  80186d:	c1 e9 02             	shr    $0x2,%ecx
  801870:	fc                   	cld    
  801871:	f3 ab                	rep stos %eax,%es:(%edi)
  801873:	eb 06                	jmp    80187b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801875:	8b 45 0c             	mov    0xc(%ebp),%eax
  801878:	fc                   	cld    
  801879:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80187b:	89 f8                	mov    %edi,%eax
  80187d:	5b                   	pop    %ebx
  80187e:	5e                   	pop    %esi
  80187f:	5f                   	pop    %edi
  801880:	5d                   	pop    %ebp
  801881:	c3                   	ret    

00801882 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801882:	55                   	push   %ebp
  801883:	89 e5                	mov    %esp,%ebp
  801885:	57                   	push   %edi
  801886:	56                   	push   %esi
  801887:	8b 45 08             	mov    0x8(%ebp),%eax
  80188a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80188d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801890:	39 c6                	cmp    %eax,%esi
  801892:	73 33                	jae    8018c7 <memmove+0x45>
  801894:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801897:	39 d0                	cmp    %edx,%eax
  801899:	73 2c                	jae    8018c7 <memmove+0x45>
		s += n;
		d += n;
  80189b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80189e:	89 d6                	mov    %edx,%esi
  8018a0:	09 fe                	or     %edi,%esi
  8018a2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018a8:	75 13                	jne    8018bd <memmove+0x3b>
  8018aa:	f6 c1 03             	test   $0x3,%cl
  8018ad:	75 0e                	jne    8018bd <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8018af:	83 ef 04             	sub    $0x4,%edi
  8018b2:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018b5:	c1 e9 02             	shr    $0x2,%ecx
  8018b8:	fd                   	std    
  8018b9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018bb:	eb 07                	jmp    8018c4 <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8018bd:	4f                   	dec    %edi
  8018be:	8d 72 ff             	lea    -0x1(%edx),%esi
  8018c1:	fd                   	std    
  8018c2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018c4:	fc                   	cld    
  8018c5:	eb 1d                	jmp    8018e4 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018c7:	89 f2                	mov    %esi,%edx
  8018c9:	09 c2                	or     %eax,%edx
  8018cb:	f6 c2 03             	test   $0x3,%dl
  8018ce:	75 0f                	jne    8018df <memmove+0x5d>
  8018d0:	f6 c1 03             	test   $0x3,%cl
  8018d3:	75 0a                	jne    8018df <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
  8018d5:	c1 e9 02             	shr    $0x2,%ecx
  8018d8:	89 c7                	mov    %eax,%edi
  8018da:	fc                   	cld    
  8018db:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018dd:	eb 05                	jmp    8018e4 <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018df:	89 c7                	mov    %eax,%edi
  8018e1:	fc                   	cld    
  8018e2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018e4:	5e                   	pop    %esi
  8018e5:	5f                   	pop    %edi
  8018e6:	5d                   	pop    %ebp
  8018e7:	c3                   	ret    

008018e8 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018e8:	55                   	push   %ebp
  8018e9:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018eb:	ff 75 10             	pushl  0x10(%ebp)
  8018ee:	ff 75 0c             	pushl  0xc(%ebp)
  8018f1:	ff 75 08             	pushl  0x8(%ebp)
  8018f4:	e8 89 ff ff ff       	call   801882 <memmove>
}
  8018f9:	c9                   	leave  
  8018fa:	c3                   	ret    

008018fb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018fb:	55                   	push   %ebp
  8018fc:	89 e5                	mov    %esp,%ebp
  8018fe:	57                   	push   %edi
  8018ff:	56                   	push   %esi
  801900:	53                   	push   %ebx
  801901:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801904:	8b 75 0c             	mov    0xc(%ebp),%esi
  801907:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80190a:	85 c0                	test   %eax,%eax
  80190c:	74 33                	je     801941 <memcmp+0x46>
  80190e:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  801911:	8a 13                	mov    (%ebx),%dl
  801913:	8a 0e                	mov    (%esi),%cl
  801915:	38 ca                	cmp    %cl,%dl
  801917:	75 13                	jne    80192c <memcmp+0x31>
  801919:	b8 00 00 00 00       	mov    $0x0,%eax
  80191e:	eb 16                	jmp    801936 <memcmp+0x3b>
  801920:	8a 54 03 01          	mov    0x1(%ebx,%eax,1),%dl
  801924:	40                   	inc    %eax
  801925:	8a 0c 06             	mov    (%esi,%eax,1),%cl
  801928:	38 ca                	cmp    %cl,%dl
  80192a:	74 0a                	je     801936 <memcmp+0x3b>
			return (int) *s1 - (int) *s2;
  80192c:	0f b6 c2             	movzbl %dl,%eax
  80192f:	0f b6 c9             	movzbl %cl,%ecx
  801932:	29 c8                	sub    %ecx,%eax
  801934:	eb 10                	jmp    801946 <memcmp+0x4b>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801936:	39 f8                	cmp    %edi,%eax
  801938:	75 e6                	jne    801920 <memcmp+0x25>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80193a:	b8 00 00 00 00       	mov    $0x0,%eax
  80193f:	eb 05                	jmp    801946 <memcmp+0x4b>
  801941:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801946:	5b                   	pop    %ebx
  801947:	5e                   	pop    %esi
  801948:	5f                   	pop    %edi
  801949:	5d                   	pop    %ebp
  80194a:	c3                   	ret    

0080194b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80194b:	55                   	push   %ebp
  80194c:	89 e5                	mov    %esp,%ebp
  80194e:	53                   	push   %ebx
  80194f:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  801952:	89 d0                	mov    %edx,%eax
  801954:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  801957:	39 c2                	cmp    %eax,%edx
  801959:	73 1b                	jae    801976 <memfind+0x2b>
		if (*(const unsigned char *) s == (unsigned char) c)
  80195b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  80195f:	0f b6 0a             	movzbl (%edx),%ecx
  801962:	39 d9                	cmp    %ebx,%ecx
  801964:	75 09                	jne    80196f <memfind+0x24>
  801966:	eb 12                	jmp    80197a <memfind+0x2f>
  801968:	0f b6 0a             	movzbl (%edx),%ecx
  80196b:	39 d9                	cmp    %ebx,%ecx
  80196d:	74 0f                	je     80197e <memfind+0x33>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80196f:	42                   	inc    %edx
  801970:	39 d0                	cmp    %edx,%eax
  801972:	75 f4                	jne    801968 <memfind+0x1d>
  801974:	eb 0a                	jmp    801980 <memfind+0x35>
  801976:	89 d0                	mov    %edx,%eax
  801978:	eb 06                	jmp    801980 <memfind+0x35>
		if (*(const unsigned char *) s == (unsigned char) c)
  80197a:	89 d0                	mov    %edx,%eax
  80197c:	eb 02                	jmp    801980 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80197e:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801980:	5b                   	pop    %ebx
  801981:	5d                   	pop    %ebp
  801982:	c3                   	ret    

00801983 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801983:	55                   	push   %ebp
  801984:	89 e5                	mov    %esp,%ebp
  801986:	57                   	push   %edi
  801987:	56                   	push   %esi
  801988:	53                   	push   %ebx
  801989:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80198c:	eb 01                	jmp    80198f <strtol+0xc>
		s++;
  80198e:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80198f:	8a 01                	mov    (%ecx),%al
  801991:	3c 20                	cmp    $0x20,%al
  801993:	74 f9                	je     80198e <strtol+0xb>
  801995:	3c 09                	cmp    $0x9,%al
  801997:	74 f5                	je     80198e <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  801999:	3c 2b                	cmp    $0x2b,%al
  80199b:	75 08                	jne    8019a5 <strtol+0x22>
		s++;
  80199d:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80199e:	bf 00 00 00 00       	mov    $0x0,%edi
  8019a3:	eb 11                	jmp    8019b6 <strtol+0x33>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8019a5:	3c 2d                	cmp    $0x2d,%al
  8019a7:	75 08                	jne    8019b1 <strtol+0x2e>
		s++, neg = 1;
  8019a9:	41                   	inc    %ecx
  8019aa:	bf 01 00 00 00       	mov    $0x1,%edi
  8019af:	eb 05                	jmp    8019b6 <strtol+0x33>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8019b1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019b6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019ba:	0f 84 87 00 00 00    	je     801a47 <strtol+0xc4>
  8019c0:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  8019c4:	75 27                	jne    8019ed <strtol+0x6a>
  8019c6:	80 39 30             	cmpb   $0x30,(%ecx)
  8019c9:	75 22                	jne    8019ed <strtol+0x6a>
  8019cb:	e9 88 00 00 00       	jmp    801a58 <strtol+0xd5>
		s += 2, base = 16;
  8019d0:	83 c1 02             	add    $0x2,%ecx
  8019d3:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  8019da:	eb 11                	jmp    8019ed <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
  8019dc:	41                   	inc    %ecx
  8019dd:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  8019e4:	eb 07                	jmp    8019ed <strtol+0x6a>
	else if (base == 0)
		base = 10;
  8019e6:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  8019ed:	b8 00 00 00 00       	mov    $0x0,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019f2:	8a 11                	mov    (%ecx),%dl
  8019f4:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8019f7:	80 fb 09             	cmp    $0x9,%bl
  8019fa:	77 08                	ja     801a04 <strtol+0x81>
			dig = *s - '0';
  8019fc:	0f be d2             	movsbl %dl,%edx
  8019ff:	83 ea 30             	sub    $0x30,%edx
  801a02:	eb 22                	jmp    801a26 <strtol+0xa3>
		else if (*s >= 'a' && *s <= 'z')
  801a04:	8d 72 9f             	lea    -0x61(%edx),%esi
  801a07:	89 f3                	mov    %esi,%ebx
  801a09:	80 fb 19             	cmp    $0x19,%bl
  801a0c:	77 08                	ja     801a16 <strtol+0x93>
			dig = *s - 'a' + 10;
  801a0e:	0f be d2             	movsbl %dl,%edx
  801a11:	83 ea 57             	sub    $0x57,%edx
  801a14:	eb 10                	jmp    801a26 <strtol+0xa3>
		else if (*s >= 'A' && *s <= 'Z')
  801a16:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a19:	89 f3                	mov    %esi,%ebx
  801a1b:	80 fb 19             	cmp    $0x19,%bl
  801a1e:	77 14                	ja     801a34 <strtol+0xb1>
			dig = *s - 'A' + 10;
  801a20:	0f be d2             	movsbl %dl,%edx
  801a23:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801a26:	3b 55 10             	cmp    0x10(%ebp),%edx
  801a29:	7d 09                	jge    801a34 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  801a2b:	41                   	inc    %ecx
  801a2c:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a30:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801a32:	eb be                	jmp    8019f2 <strtol+0x6f>

	if (endptr)
  801a34:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a38:	74 05                	je     801a3f <strtol+0xbc>
		*endptr = (char *) s;
  801a3a:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a3d:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801a3f:	85 ff                	test   %edi,%edi
  801a41:	74 21                	je     801a64 <strtol+0xe1>
  801a43:	f7 d8                	neg    %eax
  801a45:	eb 1d                	jmp    801a64 <strtol+0xe1>
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801a47:	80 39 30             	cmpb   $0x30,(%ecx)
  801a4a:	75 9a                	jne    8019e6 <strtol+0x63>
  801a4c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801a50:	0f 84 7a ff ff ff    	je     8019d0 <strtol+0x4d>
  801a56:	eb 84                	jmp    8019dc <strtol+0x59>
  801a58:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801a5c:	0f 84 6e ff ff ff    	je     8019d0 <strtol+0x4d>
  801a62:	eb 89                	jmp    8019ed <strtol+0x6a>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  801a64:	5b                   	pop    %ebx
  801a65:	5e                   	pop    %esi
  801a66:	5f                   	pop    %edi
  801a67:	5d                   	pop    %ebp
  801a68:	c3                   	ret    

00801a69 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a69:	55                   	push   %ebp
  801a6a:	89 e5                	mov    %esp,%ebp
  801a6c:	56                   	push   %esi
  801a6d:	53                   	push   %ebx
  801a6e:	8b 75 08             	mov    0x8(%ebp),%esi
  801a71:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a74:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");
	int r;
    if (pg != NULL) {
  801a77:	85 c0                	test   %eax,%eax
  801a79:	74 0e                	je     801a89 <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  801a7b:	83 ec 0c             	sub    $0xc,%esp
  801a7e:	50                   	push   %eax
  801a7f:	e8 9b e8 ff ff       	call   80031f <sys_ipc_recv>
  801a84:	83 c4 10             	add    $0x10,%esp
  801a87:	eb 10                	jmp    801a99 <ipc_recv+0x30>
    } else {
        r = sys_ipc_recv((void *) UTOP);
  801a89:	83 ec 0c             	sub    $0xc,%esp
  801a8c:	68 00 00 c0 ee       	push   $0xeec00000
  801a91:	e8 89 e8 ff ff       	call   80031f <sys_ipc_recv>
  801a96:	83 c4 10             	add    $0x10,%esp
    }
    if (r < 0) {
  801a99:	85 c0                	test   %eax,%eax
  801a9b:	79 16                	jns    801ab3 <ipc_recv+0x4a>
        // failed
        if (from_env_store != NULL) *from_env_store = 0;
  801a9d:	85 f6                	test   %esi,%esi
  801a9f:	74 06                	je     801aa7 <ipc_recv+0x3e>
  801aa1:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL) *perm_store = 0;
  801aa7:	85 db                	test   %ebx,%ebx
  801aa9:	74 2c                	je     801ad7 <ipc_recv+0x6e>
  801aab:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801ab1:	eb 24                	jmp    801ad7 <ipc_recv+0x6e>
        return r;
    } else {
        if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801ab3:	85 f6                	test   %esi,%esi
  801ab5:	74 0a                	je     801ac1 <ipc_recv+0x58>
  801ab7:	a1 04 40 80 00       	mov    0x804004,%eax
  801abc:	8b 40 74             	mov    0x74(%eax),%eax
  801abf:	89 06                	mov    %eax,(%esi)
        if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801ac1:	85 db                	test   %ebx,%ebx
  801ac3:	74 0a                	je     801acf <ipc_recv+0x66>
  801ac5:	a1 04 40 80 00       	mov    0x804004,%eax
  801aca:	8b 40 78             	mov    0x78(%eax),%eax
  801acd:	89 03                	mov    %eax,(%ebx)
        return thisenv->env_ipc_value;
  801acf:	a1 04 40 80 00       	mov    0x804004,%eax
  801ad4:	8b 40 70             	mov    0x70(%eax),%eax
    }
 
	return 0;
}
  801ad7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ada:	5b                   	pop    %ebx
  801adb:	5e                   	pop    %esi
  801adc:	5d                   	pop    %ebp
  801add:	c3                   	ret    

00801ade <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ade:	55                   	push   %ebp
  801adf:	89 e5                	mov    %esp,%ebp
  801ae1:	57                   	push   %edi
  801ae2:	56                   	push   %esi
  801ae3:	53                   	push   %ebx
  801ae4:	83 ec 0c             	sub    $0xc,%esp
  801ae7:	8b 75 10             	mov    0x10(%ebp),%esi
  801aea:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;
    if (pg == NULL) pg = (void *)UTOP;
  801aed:	85 f6                	test   %esi,%esi
  801aef:	75 05                	jne    801af6 <ipc_send+0x18>
  801af1:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
  801af6:	57                   	push   %edi
  801af7:	56                   	push   %esi
  801af8:	ff 75 0c             	pushl  0xc(%ebp)
  801afb:	ff 75 08             	pushl  0x8(%ebp)
  801afe:	e8 f9 e7 ff ff       	call   8002fc <sys_ipc_try_send>
  801b03:	89 c3                	mov    %eax,%ebx
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
  801b05:	83 c4 10             	add    $0x10,%esp
  801b08:	85 c0                	test   %eax,%eax
  801b0a:	79 17                	jns    801b23 <ipc_send+0x45>
  801b0c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b0f:	74 1d                	je     801b2e <ipc_send+0x50>
  801b11:	50                   	push   %eax
  801b12:	68 80 22 80 00       	push   $0x802280
  801b17:	6a 40                	push   $0x40
  801b19:	68 94 22 80 00       	push   $0x802294
  801b1e:	e8 d5 f4 ff ff       	call   800ff8 <_panic>
        sys_yield();
  801b23:	e8 28 e6 ff ff       	call   800150 <sys_yield>
    } while (r != 0);
  801b28:	85 db                	test   %ebx,%ebx
  801b2a:	75 ca                	jne    801af6 <ipc_send+0x18>
  801b2c:	eb 07                	jmp    801b35 <ipc_send+0x57>
	int r;
    if (pg == NULL) pg = (void *)UTOP;
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
        sys_yield();
  801b2e:	e8 1d e6 ff ff       	call   800150 <sys_yield>
  801b33:	eb c1                	jmp    801af6 <ipc_send+0x18>
    } while (r != 0);
}
  801b35:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b38:	5b                   	pop    %ebx
  801b39:	5e                   	pop    %esi
  801b3a:	5f                   	pop    %edi
  801b3b:	5d                   	pop    %ebp
  801b3c:	c3                   	ret    

00801b3d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b3d:	55                   	push   %ebp
  801b3e:	89 e5                	mov    %esp,%ebp
  801b40:	53                   	push   %ebx
  801b41:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801b44:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801b49:	39 c1                	cmp    %eax,%ecx
  801b4b:	74 21                	je     801b6e <ipc_find_env+0x31>
  801b4d:	ba 01 00 00 00       	mov    $0x1,%edx
  801b52:	8d 1c 95 00 00 00 00 	lea    0x0(,%edx,4),%ebx
  801b59:	89 d0                	mov    %edx,%eax
  801b5b:	c1 e0 07             	shl    $0x7,%eax
  801b5e:	29 d8                	sub    %ebx,%eax
  801b60:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b65:	8b 40 50             	mov    0x50(%eax),%eax
  801b68:	39 c8                	cmp    %ecx,%eax
  801b6a:	75 1b                	jne    801b87 <ipc_find_env+0x4a>
  801b6c:	eb 05                	jmp    801b73 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b6e:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801b73:	8d 04 95 00 00 00 00 	lea    0x0(,%edx,4),%eax
  801b7a:	c1 e2 07             	shl    $0x7,%edx
  801b7d:	29 c2                	sub    %eax,%edx
  801b7f:	8b 82 48 00 c0 ee    	mov    -0x113fffb8(%edx),%eax
  801b85:	eb 0e                	jmp    801b95 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b87:	42                   	inc    %edx
  801b88:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  801b8e:	75 c2                	jne    801b52 <ipc_find_env+0x15>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b90:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b95:	5b                   	pop    %ebx
  801b96:	5d                   	pop    %ebp
  801b97:	c3                   	ret    

00801b98 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b98:	55                   	push   %ebp
  801b99:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b9b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b9e:	c1 e8 16             	shr    $0x16,%eax
  801ba1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801ba8:	a8 01                	test   $0x1,%al
  801baa:	74 21                	je     801bcd <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801bac:	8b 45 08             	mov    0x8(%ebp),%eax
  801baf:	c1 e8 0c             	shr    $0xc,%eax
  801bb2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801bb9:	a8 01                	test   $0x1,%al
  801bbb:	74 17                	je     801bd4 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bbd:	c1 e8 0c             	shr    $0xc,%eax
  801bc0:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801bc7:	ef 
  801bc8:	0f b7 c0             	movzwl %ax,%eax
  801bcb:	eb 0c                	jmp    801bd9 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801bcd:	b8 00 00 00 00       	mov    $0x0,%eax
  801bd2:	eb 05                	jmp    801bd9 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801bd4:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801bd9:	5d                   	pop    %ebp
  801bda:	c3                   	ret    
  801bdb:	90                   	nop

00801bdc <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801bdc:	55                   	push   %ebp
  801bdd:	57                   	push   %edi
  801bde:	56                   	push   %esi
  801bdf:	53                   	push   %ebx
  801be0:	83 ec 1c             	sub    $0x1c,%esp
  801be3:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801be7:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801beb:	8b 7c 24 38          	mov    0x38(%esp),%edi
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801bef:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bf3:	89 ca                	mov    %ecx,%edx
  const DWunion dd = {.ll = d};
  801bf5:	89 f8                	mov    %edi,%eax
  801bf7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801bfb:	85 f6                	test   %esi,%esi
  801bfd:	75 2d                	jne    801c2c <__udivdi3+0x50>
    {
      if (d0 > n1)
  801bff:	39 cf                	cmp    %ecx,%edi
  801c01:	77 65                	ja     801c68 <__udivdi3+0x8c>
  801c03:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801c05:	85 ff                	test   %edi,%edi
  801c07:	75 0b                	jne    801c14 <__udivdi3+0x38>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801c09:	b8 01 00 00 00       	mov    $0x1,%eax
  801c0e:	31 d2                	xor    %edx,%edx
  801c10:	f7 f7                	div    %edi
  801c12:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801c14:	31 d2                	xor    %edx,%edx
  801c16:	89 c8                	mov    %ecx,%eax
  801c18:	f7 f5                	div    %ebp
  801c1a:	89 c1                	mov    %eax,%ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c1c:	89 d8                	mov    %ebx,%eax
  801c1e:	f7 f5                	div    %ebp
  801c20:	89 cf                	mov    %ecx,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c22:	89 fa                	mov    %edi,%edx
  801c24:	83 c4 1c             	add    $0x1c,%esp
  801c27:	5b                   	pop    %ebx
  801c28:	5e                   	pop    %esi
  801c29:	5f                   	pop    %edi
  801c2a:	5d                   	pop    %ebp
  801c2b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801c2c:	39 ce                	cmp    %ecx,%esi
  801c2e:	77 28                	ja     801c58 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801c30:	0f bd fe             	bsr    %esi,%edi
	  if (bm == 0)
  801c33:	83 f7 1f             	xor    $0x1f,%edi
  801c36:	75 40                	jne    801c78 <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801c38:	39 ce                	cmp    %ecx,%esi
  801c3a:	72 0a                	jb     801c46 <__udivdi3+0x6a>
  801c3c:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801c40:	0f 87 9e 00 00 00    	ja     801ce4 <__udivdi3+0x108>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801c46:	b8 01 00 00 00       	mov    $0x1,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c4b:	89 fa                	mov    %edi,%edx
  801c4d:	83 c4 1c             	add    $0x1c,%esp
  801c50:	5b                   	pop    %ebx
  801c51:	5e                   	pop    %esi
  801c52:	5f                   	pop    %edi
  801c53:	5d                   	pop    %ebp
  801c54:	c3                   	ret    
  801c55:	8d 76 00             	lea    0x0(%esi),%esi
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801c58:	31 ff                	xor    %edi,%edi
  801c5a:	31 c0                	xor    %eax,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c5c:	89 fa                	mov    %edi,%edx
  801c5e:	83 c4 1c             	add    $0x1c,%esp
  801c61:	5b                   	pop    %ebx
  801c62:	5e                   	pop    %esi
  801c63:	5f                   	pop    %edi
  801c64:	5d                   	pop    %ebp
  801c65:	c3                   	ret    
  801c66:	66 90                	xchg   %ax,%ax
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c68:	89 d8                	mov    %ebx,%eax
  801c6a:	f7 f7                	div    %edi
  801c6c:	31 ff                	xor    %edi,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c6e:	89 fa                	mov    %edi,%edx
  801c70:	83 c4 1c             	add    $0x1c,%esp
  801c73:	5b                   	pop    %ebx
  801c74:	5e                   	pop    %esi
  801c75:	5f                   	pop    %edi
  801c76:	5d                   	pop    %ebp
  801c77:	c3                   	ret    
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801c78:	bd 20 00 00 00       	mov    $0x20,%ebp
  801c7d:	89 eb                	mov    %ebp,%ebx
  801c7f:	29 fb                	sub    %edi,%ebx

	      d1 = (d1 << bm) | (d0 >> b);
  801c81:	89 f9                	mov    %edi,%ecx
  801c83:	d3 e6                	shl    %cl,%esi
  801c85:	89 c5                	mov    %eax,%ebp
  801c87:	88 d9                	mov    %bl,%cl
  801c89:	d3 ed                	shr    %cl,%ebp
  801c8b:	89 e9                	mov    %ebp,%ecx
  801c8d:	09 f1                	or     %esi,%ecx
  801c8f:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
	      d0 = d0 << bm;
  801c93:	89 f9                	mov    %edi,%ecx
  801c95:	d3 e0                	shl    %cl,%eax
  801c97:	89 c5                	mov    %eax,%ebp
	      n2 = n1 >> b;
  801c99:	89 d6                	mov    %edx,%esi
  801c9b:	88 d9                	mov    %bl,%cl
  801c9d:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
  801c9f:	89 f9                	mov    %edi,%ecx
  801ca1:	d3 e2                	shl    %cl,%edx
  801ca3:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ca7:	88 d9                	mov    %bl,%cl
  801ca9:	d3 e8                	shr    %cl,%eax
  801cab:	09 c2                	or     %eax,%edx
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801cad:	89 d0                	mov    %edx,%eax
  801caf:	89 f2                	mov    %esi,%edx
  801cb1:	f7 74 24 0c          	divl   0xc(%esp)
  801cb5:	89 d6                	mov    %edx,%esi
  801cb7:	89 c3                	mov    %eax,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  801cb9:	f7 e5                	mul    %ebp

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801cbb:	39 d6                	cmp    %edx,%esi
  801cbd:	72 19                	jb     801cd8 <__udivdi3+0xfc>
  801cbf:	74 0b                	je     801ccc <__udivdi3+0xf0>
  801cc1:	89 d8                	mov    %ebx,%eax
  801cc3:	31 ff                	xor    %edi,%edi
  801cc5:	e9 58 ff ff ff       	jmp    801c22 <__udivdi3+0x46>
  801cca:	66 90                	xchg   %ax,%ax
  801ccc:	8b 54 24 08          	mov    0x8(%esp),%edx
  801cd0:	89 f9                	mov    %edi,%ecx
  801cd2:	d3 e2                	shl    %cl,%edx
  801cd4:	39 c2                	cmp    %eax,%edx
  801cd6:	73 e9                	jae    801cc1 <__udivdi3+0xe5>
  801cd8:	8d 43 ff             	lea    -0x1(%ebx),%eax
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801cdb:	31 ff                	xor    %edi,%edi
  801cdd:	e9 40 ff ff ff       	jmp    801c22 <__udivdi3+0x46>
  801ce2:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801ce4:	31 c0                	xor    %eax,%eax
  801ce6:	e9 37 ff ff ff       	jmp    801c22 <__udivdi3+0x46>
  801ceb:	90                   	nop

00801cec <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801cec:	55                   	push   %ebp
  801ced:	57                   	push   %edi
  801cee:	56                   	push   %esi
  801cef:	53                   	push   %ebx
  801cf0:	83 ec 1c             	sub    $0x1c,%esp
  801cf3:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801cf7:	8b 74 24 34          	mov    0x34(%esp),%esi
  801cfb:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801cff:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801d03:	89 44 24 0c          	mov    %eax,0xc(%esp)
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801d07:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d0b:	89 f3                	mov    %esi,%ebx
  const DWunion dd = {.ll = d};
  801d0d:	89 fa                	mov    %edi,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801d0f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  n1 = nn.s.high;
  801d13:	89 34 24             	mov    %esi,(%esp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801d16:	85 c0                	test   %eax,%eax
  801d18:	75 1a                	jne    801d34 <__umoddi3+0x48>
    {
      if (d0 > n1)
  801d1a:	39 f7                	cmp    %esi,%edi
  801d1c:	0f 86 a2 00 00 00    	jbe    801dc4 <__umoddi3+0xd8>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d22:	89 c8                	mov    %ecx,%eax
  801d24:	89 f2                	mov    %esi,%edx
  801d26:	f7 f7                	div    %edi
  801d28:	89 d0                	mov    %edx,%eax

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801d2a:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d2c:	83 c4 1c             	add    $0x1c,%esp
  801d2f:	5b                   	pop    %ebx
  801d30:	5e                   	pop    %esi
  801d31:	5f                   	pop    %edi
  801d32:	5d                   	pop    %ebp
  801d33:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801d34:	39 f0                	cmp    %esi,%eax
  801d36:	0f 87 ac 00 00 00    	ja     801de8 <__umoddi3+0xfc>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801d3c:	0f bd e8             	bsr    %eax,%ebp
	  if (bm == 0)
  801d3f:	83 f5 1f             	xor    $0x1f,%ebp
  801d42:	0f 84 ac 00 00 00    	je     801df4 <__umoddi3+0x108>
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801d48:	bf 20 00 00 00       	mov    $0x20,%edi
  801d4d:	29 ef                	sub    %ebp,%edi
  801d4f:	89 fe                	mov    %edi,%esi
  801d51:	89 7c 24 0c          	mov    %edi,0xc(%esp)

	      d1 = (d1 << bm) | (d0 >> b);
  801d55:	89 e9                	mov    %ebp,%ecx
  801d57:	d3 e0                	shl    %cl,%eax
  801d59:	89 d7                	mov    %edx,%edi
  801d5b:	89 f1                	mov    %esi,%ecx
  801d5d:	d3 ef                	shr    %cl,%edi
  801d5f:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  801d61:	89 e9                	mov    %ebp,%ecx
  801d63:	d3 e2                	shl    %cl,%edx
  801d65:	89 14 24             	mov    %edx,(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801d68:	89 d8                	mov    %ebx,%eax
  801d6a:	d3 e0                	shl    %cl,%eax
  801d6c:	89 c2                	mov    %eax,%edx
	      n0 = n0 << bm;
  801d6e:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d72:	d3 e0                	shl    %cl,%eax
  801d74:	89 44 24 04          	mov    %eax,0x4(%esp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801d78:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d7c:	89 f1                	mov    %esi,%ecx
  801d7e:	d3 e8                	shr    %cl,%eax
  801d80:	09 d0                	or     %edx,%eax
  801d82:	d3 eb                	shr    %cl,%ebx
  801d84:	89 da                	mov    %ebx,%edx
  801d86:	f7 f7                	div    %edi
  801d88:	89 d3                	mov    %edx,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  801d8a:	f7 24 24             	mull   (%esp)
  801d8d:	89 c6                	mov    %eax,%esi
  801d8f:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d91:	39 d3                	cmp    %edx,%ebx
  801d93:	0f 82 87 00 00 00    	jb     801e20 <__umoddi3+0x134>
  801d99:	0f 84 91 00 00 00    	je     801e30 <__umoddi3+0x144>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801d9f:	8b 54 24 04          	mov    0x4(%esp),%edx
  801da3:	29 f2                	sub    %esi,%edx
  801da5:	19 cb                	sbb    %ecx,%ebx
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801da7:	89 d8                	mov    %ebx,%eax
  801da9:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  801dad:	d3 e0                	shl    %cl,%eax
  801daf:	89 e9                	mov    %ebp,%ecx
  801db1:	d3 ea                	shr    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801db3:	09 d0                	or     %edx,%eax
  801db5:	89 e9                	mov    %ebp,%ecx
  801db7:	d3 eb                	shr    %cl,%ebx
  801db9:	89 da                	mov    %ebx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801dbb:	83 c4 1c             	add    $0x1c,%esp
  801dbe:	5b                   	pop    %ebx
  801dbf:	5e                   	pop    %esi
  801dc0:	5f                   	pop    %edi
  801dc1:	5d                   	pop    %ebp
  801dc2:	c3                   	ret    
  801dc3:	90                   	nop
  801dc4:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801dc6:	85 ff                	test   %edi,%edi
  801dc8:	75 0b                	jne    801dd5 <__umoddi3+0xe9>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801dca:	b8 01 00 00 00       	mov    $0x1,%eax
  801dcf:	31 d2                	xor    %edx,%edx
  801dd1:	f7 f7                	div    %edi
  801dd3:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801dd5:	89 f0                	mov    %esi,%eax
  801dd7:	31 d2                	xor    %edx,%edx
  801dd9:	f7 f5                	div    %ebp
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801ddb:	89 c8                	mov    %ecx,%eax
  801ddd:	f7 f5                	div    %ebp
  801ddf:	89 d0                	mov    %edx,%eax
  801de1:	e9 44 ff ff ff       	jmp    801d2a <__umoddi3+0x3e>
  801de6:	66 90                	xchg   %ax,%ax
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801de8:	89 c8                	mov    %ecx,%eax
  801dea:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801dec:	83 c4 1c             	add    $0x1c,%esp
  801def:	5b                   	pop    %ebx
  801df0:	5e                   	pop    %esi
  801df1:	5f                   	pop    %edi
  801df2:	5d                   	pop    %ebp
  801df3:	c3                   	ret    

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801df4:	3b 04 24             	cmp    (%esp),%eax
  801df7:	72 06                	jb     801dff <__umoddi3+0x113>
  801df9:	3b 7c 24 04          	cmp    0x4(%esp),%edi
  801dfd:	77 0f                	ja     801e0e <__umoddi3+0x122>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801dff:	89 f2                	mov    %esi,%edx
  801e01:	29 f9                	sub    %edi,%ecx
  801e03:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  801e07:	89 14 24             	mov    %edx,(%esp)
  801e0a:	89 4c 24 04          	mov    %ecx,0x4(%esp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801e0e:	8b 44 24 04          	mov    0x4(%esp),%eax
  801e12:	8b 14 24             	mov    (%esp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e15:	83 c4 1c             	add    $0x1c,%esp
  801e18:	5b                   	pop    %ebx
  801e19:	5e                   	pop    %esi
  801e1a:	5f                   	pop    %edi
  801e1b:	5d                   	pop    %ebp
  801e1c:	c3                   	ret    
  801e1d:	8d 76 00             	lea    0x0(%esi),%esi
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801e20:	2b 04 24             	sub    (%esp),%eax
  801e23:	19 fa                	sbb    %edi,%edx
  801e25:	89 d1                	mov    %edx,%ecx
  801e27:	89 c6                	mov    %eax,%esi
  801e29:	e9 71 ff ff ff       	jmp    801d9f <__umoddi3+0xb3>
  801e2e:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e30:	39 44 24 04          	cmp    %eax,0x4(%esp)
  801e34:	72 ea                	jb     801e20 <__umoddi3+0x134>
  801e36:	89 d9                	mov    %ebx,%ecx
  801e38:	e9 62 ff ff ff       	jmp    801d9f <__umoddi3+0xb3>
