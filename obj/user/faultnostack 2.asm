
obj/user/faultnostack.debug:     file format elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  800039:	68 6a 03 80 00       	push   $0x80036a
  80003e:	6a 00                	push   $0x0
  800040:	e8 7f 02 00 00       	call   8002c4 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800045:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80004c:	00 00 00 
}
  80004f:	83 c4 10             	add    $0x10,%esp
  800052:	c9                   	leave  
  800053:	c3                   	ret    

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	56                   	push   %esi
  800058:	53                   	push   %ebx
  800059:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80005f:	e8 d7 00 00 00       	call   80013b <sys_getenvid>
  800064:	25 ff 03 00 00       	and    $0x3ff,%eax
  800069:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800070:	c1 e0 07             	shl    $0x7,%eax
  800073:	29 d0                	sub    %edx,%eax
  800075:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007a:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007f:	85 db                	test   %ebx,%ebx
  800081:	7e 07                	jle    80008a <libmain+0x36>
		binaryname = argv[0];
  800083:	8b 06                	mov    (%esi),%eax
  800085:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80008a:	83 ec 08             	sub    $0x8,%esp
  80008d:	56                   	push   %esi
  80008e:	53                   	push   %ebx
  80008f:	e8 9f ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800094:	e8 0a 00 00 00       	call   8000a3 <exit>
}
  800099:	83 c4 10             	add    $0x10,%esp
  80009c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80009f:	5b                   	pop    %ebx
  8000a0:	5e                   	pop    %esi
  8000a1:	5d                   	pop    %ebp
  8000a2:	c3                   	ret    

008000a3 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a3:	55                   	push   %ebp
  8000a4:	89 e5                	mov    %esp,%ebp
  8000a6:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000a9:	e8 f1 04 00 00       	call   80059f <close_all>
	sys_env_destroy(0);
  8000ae:	83 ec 0c             	sub    $0xc,%esp
  8000b1:	6a 00                	push   $0x0
  8000b3:	e8 42 00 00 00       	call   8000fa <sys_env_destroy>
}
  8000b8:	83 c4 10             	add    $0x10,%esp
  8000bb:	c9                   	leave  
  8000bc:	c3                   	ret    

008000bd <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000bd:	55                   	push   %ebp
  8000be:	89 e5                	mov    %esp,%ebp
  8000c0:	57                   	push   %edi
  8000c1:	56                   	push   %esi
  8000c2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ce:	89 c3                	mov    %eax,%ebx
  8000d0:	89 c7                	mov    %eax,%edi
  8000d2:	89 c6                	mov    %eax,%esi
  8000d4:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d6:	5b                   	pop    %ebx
  8000d7:	5e                   	pop    %esi
  8000d8:	5f                   	pop    %edi
  8000d9:	5d                   	pop    %ebp
  8000da:	c3                   	ret    

008000db <sys_cgetc>:

int
sys_cgetc(void)
{
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	57                   	push   %edi
  8000df:	56                   	push   %esi
  8000e0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8000eb:	89 d1                	mov    %edx,%ecx
  8000ed:	89 d3                	mov    %edx,%ebx
  8000ef:	89 d7                	mov    %edx,%edi
  8000f1:	89 d6                	mov    %edx,%esi
  8000f3:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f5:	5b                   	pop    %ebx
  8000f6:	5e                   	pop    %esi
  8000f7:	5f                   	pop    %edi
  8000f8:	5d                   	pop    %ebp
  8000f9:	c3                   	ret    

008000fa <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000fa:	55                   	push   %ebp
  8000fb:	89 e5                	mov    %esp,%ebp
  8000fd:	57                   	push   %edi
  8000fe:	56                   	push   %esi
  8000ff:	53                   	push   %ebx
  800100:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800103:	b9 00 00 00 00       	mov    $0x0,%ecx
  800108:	b8 03 00 00 00       	mov    $0x3,%eax
  80010d:	8b 55 08             	mov    0x8(%ebp),%edx
  800110:	89 cb                	mov    %ecx,%ebx
  800112:	89 cf                	mov    %ecx,%edi
  800114:	89 ce                	mov    %ecx,%esi
  800116:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800118:	85 c0                	test   %eax,%eax
  80011a:	7e 17                	jle    800133 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80011c:	83 ec 0c             	sub    $0xc,%esp
  80011f:	50                   	push   %eax
  800120:	6a 03                	push   $0x3
  800122:	68 0a 1f 80 00       	push   $0x801f0a
  800127:	6a 23                	push   $0x23
  800129:	68 27 1f 80 00       	push   $0x801f27
  80012e:	e8 f5 0e 00 00       	call   801028 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800133:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800136:	5b                   	pop    %ebx
  800137:	5e                   	pop    %esi
  800138:	5f                   	pop    %edi
  800139:	5d                   	pop    %ebp
  80013a:	c3                   	ret    

0080013b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	57                   	push   %edi
  80013f:	56                   	push   %esi
  800140:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800141:	ba 00 00 00 00       	mov    $0x0,%edx
  800146:	b8 02 00 00 00       	mov    $0x2,%eax
  80014b:	89 d1                	mov    %edx,%ecx
  80014d:	89 d3                	mov    %edx,%ebx
  80014f:	89 d7                	mov    %edx,%edi
  800151:	89 d6                	mov    %edx,%esi
  800153:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800155:	5b                   	pop    %ebx
  800156:	5e                   	pop    %esi
  800157:	5f                   	pop    %edi
  800158:	5d                   	pop    %ebp
  800159:	c3                   	ret    

0080015a <sys_yield>:

void
sys_yield(void)
{
  80015a:	55                   	push   %ebp
  80015b:	89 e5                	mov    %esp,%ebp
  80015d:	57                   	push   %edi
  80015e:	56                   	push   %esi
  80015f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800160:	ba 00 00 00 00       	mov    $0x0,%edx
  800165:	b8 0b 00 00 00       	mov    $0xb,%eax
  80016a:	89 d1                	mov    %edx,%ecx
  80016c:	89 d3                	mov    %edx,%ebx
  80016e:	89 d7                	mov    %edx,%edi
  800170:	89 d6                	mov    %edx,%esi
  800172:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800174:	5b                   	pop    %ebx
  800175:	5e                   	pop    %esi
  800176:	5f                   	pop    %edi
  800177:	5d                   	pop    %ebp
  800178:	c3                   	ret    

00800179 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800179:	55                   	push   %ebp
  80017a:	89 e5                	mov    %esp,%ebp
  80017c:	57                   	push   %edi
  80017d:	56                   	push   %esi
  80017e:	53                   	push   %ebx
  80017f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800182:	be 00 00 00 00       	mov    $0x0,%esi
  800187:	b8 04 00 00 00       	mov    $0x4,%eax
  80018c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80018f:	8b 55 08             	mov    0x8(%ebp),%edx
  800192:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800195:	89 f7                	mov    %esi,%edi
  800197:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800199:	85 c0                	test   %eax,%eax
  80019b:	7e 17                	jle    8001b4 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80019d:	83 ec 0c             	sub    $0xc,%esp
  8001a0:	50                   	push   %eax
  8001a1:	6a 04                	push   $0x4
  8001a3:	68 0a 1f 80 00       	push   $0x801f0a
  8001a8:	6a 23                	push   $0x23
  8001aa:	68 27 1f 80 00       	push   $0x801f27
  8001af:	e8 74 0e 00 00       	call   801028 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001b7:	5b                   	pop    %ebx
  8001b8:	5e                   	pop    %esi
  8001b9:	5f                   	pop    %edi
  8001ba:	5d                   	pop    %ebp
  8001bb:	c3                   	ret    

008001bc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	57                   	push   %edi
  8001c0:	56                   	push   %esi
  8001c1:	53                   	push   %ebx
  8001c2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001c5:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001cd:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001d3:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001d6:	8b 75 18             	mov    0x18(%ebp),%esi
  8001d9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001db:	85 c0                	test   %eax,%eax
  8001dd:	7e 17                	jle    8001f6 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001df:	83 ec 0c             	sub    $0xc,%esp
  8001e2:	50                   	push   %eax
  8001e3:	6a 05                	push   $0x5
  8001e5:	68 0a 1f 80 00       	push   $0x801f0a
  8001ea:	6a 23                	push   $0x23
  8001ec:	68 27 1f 80 00       	push   $0x801f27
  8001f1:	e8 32 0e 00 00       	call   801028 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001f9:	5b                   	pop    %ebx
  8001fa:	5e                   	pop    %esi
  8001fb:	5f                   	pop    %edi
  8001fc:	5d                   	pop    %ebp
  8001fd:	c3                   	ret    

008001fe <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001fe:	55                   	push   %ebp
  8001ff:	89 e5                	mov    %esp,%ebp
  800201:	57                   	push   %edi
  800202:	56                   	push   %esi
  800203:	53                   	push   %ebx
  800204:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800207:	bb 00 00 00 00       	mov    $0x0,%ebx
  80020c:	b8 06 00 00 00       	mov    $0x6,%eax
  800211:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800214:	8b 55 08             	mov    0x8(%ebp),%edx
  800217:	89 df                	mov    %ebx,%edi
  800219:	89 de                	mov    %ebx,%esi
  80021b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80021d:	85 c0                	test   %eax,%eax
  80021f:	7e 17                	jle    800238 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800221:	83 ec 0c             	sub    $0xc,%esp
  800224:	50                   	push   %eax
  800225:	6a 06                	push   $0x6
  800227:	68 0a 1f 80 00       	push   $0x801f0a
  80022c:	6a 23                	push   $0x23
  80022e:	68 27 1f 80 00       	push   $0x801f27
  800233:	e8 f0 0d 00 00       	call   801028 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800238:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80023b:	5b                   	pop    %ebx
  80023c:	5e                   	pop    %esi
  80023d:	5f                   	pop    %edi
  80023e:	5d                   	pop    %ebp
  80023f:	c3                   	ret    

00800240 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800240:	55                   	push   %ebp
  800241:	89 e5                	mov    %esp,%ebp
  800243:	57                   	push   %edi
  800244:	56                   	push   %esi
  800245:	53                   	push   %ebx
  800246:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800249:	bb 00 00 00 00       	mov    $0x0,%ebx
  80024e:	b8 08 00 00 00       	mov    $0x8,%eax
  800253:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800256:	8b 55 08             	mov    0x8(%ebp),%edx
  800259:	89 df                	mov    %ebx,%edi
  80025b:	89 de                	mov    %ebx,%esi
  80025d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80025f:	85 c0                	test   %eax,%eax
  800261:	7e 17                	jle    80027a <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800263:	83 ec 0c             	sub    $0xc,%esp
  800266:	50                   	push   %eax
  800267:	6a 08                	push   $0x8
  800269:	68 0a 1f 80 00       	push   $0x801f0a
  80026e:	6a 23                	push   $0x23
  800270:	68 27 1f 80 00       	push   $0x801f27
  800275:	e8 ae 0d 00 00       	call   801028 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80027a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80027d:	5b                   	pop    %ebx
  80027e:	5e                   	pop    %esi
  80027f:	5f                   	pop    %edi
  800280:	5d                   	pop    %ebp
  800281:	c3                   	ret    

00800282 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800282:	55                   	push   %ebp
  800283:	89 e5                	mov    %esp,%ebp
  800285:	57                   	push   %edi
  800286:	56                   	push   %esi
  800287:	53                   	push   %ebx
  800288:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80028b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800290:	b8 09 00 00 00       	mov    $0x9,%eax
  800295:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800298:	8b 55 08             	mov    0x8(%ebp),%edx
  80029b:	89 df                	mov    %ebx,%edi
  80029d:	89 de                	mov    %ebx,%esi
  80029f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002a1:	85 c0                	test   %eax,%eax
  8002a3:	7e 17                	jle    8002bc <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002a5:	83 ec 0c             	sub    $0xc,%esp
  8002a8:	50                   	push   %eax
  8002a9:	6a 09                	push   $0x9
  8002ab:	68 0a 1f 80 00       	push   $0x801f0a
  8002b0:	6a 23                	push   $0x23
  8002b2:	68 27 1f 80 00       	push   $0x801f27
  8002b7:	e8 6c 0d 00 00       	call   801028 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002bf:	5b                   	pop    %ebx
  8002c0:	5e                   	pop    %esi
  8002c1:	5f                   	pop    %edi
  8002c2:	5d                   	pop    %ebp
  8002c3:	c3                   	ret    

008002c4 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	57                   	push   %edi
  8002c8:	56                   	push   %esi
  8002c9:	53                   	push   %ebx
  8002ca:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002cd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002d2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002da:	8b 55 08             	mov    0x8(%ebp),%edx
  8002dd:	89 df                	mov    %ebx,%edi
  8002df:	89 de                	mov    %ebx,%esi
  8002e1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002e3:	85 c0                	test   %eax,%eax
  8002e5:	7e 17                	jle    8002fe <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e7:	83 ec 0c             	sub    $0xc,%esp
  8002ea:	50                   	push   %eax
  8002eb:	6a 0a                	push   $0xa
  8002ed:	68 0a 1f 80 00       	push   $0x801f0a
  8002f2:	6a 23                	push   $0x23
  8002f4:	68 27 1f 80 00       	push   $0x801f27
  8002f9:	e8 2a 0d 00 00       	call   801028 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800301:	5b                   	pop    %ebx
  800302:	5e                   	pop    %esi
  800303:	5f                   	pop    %edi
  800304:	5d                   	pop    %ebp
  800305:	c3                   	ret    

00800306 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800306:	55                   	push   %ebp
  800307:	89 e5                	mov    %esp,%ebp
  800309:	57                   	push   %edi
  80030a:	56                   	push   %esi
  80030b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80030c:	be 00 00 00 00       	mov    $0x0,%esi
  800311:	b8 0c 00 00 00       	mov    $0xc,%eax
  800316:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800319:	8b 55 08             	mov    0x8(%ebp),%edx
  80031c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80031f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800322:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800324:	5b                   	pop    %ebx
  800325:	5e                   	pop    %esi
  800326:	5f                   	pop    %edi
  800327:	5d                   	pop    %ebp
  800328:	c3                   	ret    

00800329 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800329:	55                   	push   %ebp
  80032a:	89 e5                	mov    %esp,%ebp
  80032c:	57                   	push   %edi
  80032d:	56                   	push   %esi
  80032e:	53                   	push   %ebx
  80032f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800332:	b9 00 00 00 00       	mov    $0x0,%ecx
  800337:	b8 0d 00 00 00       	mov    $0xd,%eax
  80033c:	8b 55 08             	mov    0x8(%ebp),%edx
  80033f:	89 cb                	mov    %ecx,%ebx
  800341:	89 cf                	mov    %ecx,%edi
  800343:	89 ce                	mov    %ecx,%esi
  800345:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800347:	85 c0                	test   %eax,%eax
  800349:	7e 17                	jle    800362 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80034b:	83 ec 0c             	sub    $0xc,%esp
  80034e:	50                   	push   %eax
  80034f:	6a 0d                	push   $0xd
  800351:	68 0a 1f 80 00       	push   $0x801f0a
  800356:	6a 23                	push   $0x23
  800358:	68 27 1f 80 00       	push   $0x801f27
  80035d:	e8 c6 0c 00 00       	call   801028 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800362:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800365:	5b                   	pop    %ebx
  800366:	5e                   	pop    %esi
  800367:	5f                   	pop    %edi
  800368:	5d                   	pop    %ebp
  800369:	c3                   	ret    

0080036a <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80036a:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80036b:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  800370:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800372:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp,%ebx
  800375:	89 e3                	mov    %esp,%ebx
	movl 40(%esp),%eax 	// esp from utf_fault_va to utf_regs(end)
  800377:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp),%esp 	// 
  80037b:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax
  80037f:	50                   	push   %eax
 
 
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx,%esp
  800380:	89 dc                	mov    %ebx,%esp
	subl $4,48(%esp)
  800382:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	popl %eax
  800387:	58                   	pop    %eax
	popl %eax
  800388:	58                   	pop    %eax
	popal
  800389:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4,%esp
  80038a:	83 c4 04             	add    $0x4,%esp
	popfl
  80038d:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80038e:	5c                   	pop    %esp
 
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80038f:	c3                   	ret    

00800390 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800390:	55                   	push   %ebp
  800391:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800393:	8b 45 08             	mov    0x8(%ebp),%eax
  800396:	05 00 00 00 30       	add    $0x30000000,%eax
  80039b:	c1 e8 0c             	shr    $0xc,%eax
}
  80039e:	5d                   	pop    %ebp
  80039f:	c3                   	ret    

008003a0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003a0:	55                   	push   %ebp
  8003a1:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8003a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a6:	05 00 00 00 30       	add    $0x30000000,%eax
  8003ab:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003b0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003b5:	5d                   	pop    %ebp
  8003b6:	c3                   	ret    

008003b7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003b7:	55                   	push   %ebp
  8003b8:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003ba:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8003bf:	a8 01                	test   $0x1,%al
  8003c1:	74 34                	je     8003f7 <fd_alloc+0x40>
  8003c3:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8003c8:	a8 01                	test   $0x1,%al
  8003ca:	74 32                	je     8003fe <fd_alloc+0x47>
  8003cc:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8003d1:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003d3:	89 c2                	mov    %eax,%edx
  8003d5:	c1 ea 16             	shr    $0x16,%edx
  8003d8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003df:	f6 c2 01             	test   $0x1,%dl
  8003e2:	74 1f                	je     800403 <fd_alloc+0x4c>
  8003e4:	89 c2                	mov    %eax,%edx
  8003e6:	c1 ea 0c             	shr    $0xc,%edx
  8003e9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003f0:	f6 c2 01             	test   $0x1,%dl
  8003f3:	75 1a                	jne    80040f <fd_alloc+0x58>
  8003f5:	eb 0c                	jmp    800403 <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8003f7:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8003fc:	eb 05                	jmp    800403 <fd_alloc+0x4c>
  8003fe:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800403:	8b 45 08             	mov    0x8(%ebp),%eax
  800406:	89 08                	mov    %ecx,(%eax)
			return 0;
  800408:	b8 00 00 00 00       	mov    $0x0,%eax
  80040d:	eb 1a                	jmp    800429 <fd_alloc+0x72>
  80040f:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800414:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800419:	75 b6                	jne    8003d1 <fd_alloc+0x1a>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80041b:	8b 45 08             	mov    0x8(%ebp),%eax
  80041e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800424:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800429:	5d                   	pop    %ebp
  80042a:	c3                   	ret    

0080042b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80042b:	55                   	push   %ebp
  80042c:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80042e:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  800432:	77 39                	ja     80046d <fd_lookup+0x42>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800434:	8b 45 08             	mov    0x8(%ebp),%eax
  800437:	c1 e0 0c             	shl    $0xc,%eax
  80043a:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80043f:	89 c2                	mov    %eax,%edx
  800441:	c1 ea 16             	shr    $0x16,%edx
  800444:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80044b:	f6 c2 01             	test   $0x1,%dl
  80044e:	74 24                	je     800474 <fd_lookup+0x49>
  800450:	89 c2                	mov    %eax,%edx
  800452:	c1 ea 0c             	shr    $0xc,%edx
  800455:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80045c:	f6 c2 01             	test   $0x1,%dl
  80045f:	74 1a                	je     80047b <fd_lookup+0x50>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800461:	8b 55 0c             	mov    0xc(%ebp),%edx
  800464:	89 02                	mov    %eax,(%edx)
	return 0;
  800466:	b8 00 00 00 00       	mov    $0x0,%eax
  80046b:	eb 13                	jmp    800480 <fd_lookup+0x55>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80046d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800472:	eb 0c                	jmp    800480 <fd_lookup+0x55>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800474:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800479:	eb 05                	jmp    800480 <fd_lookup+0x55>
  80047b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800480:	5d                   	pop    %ebp
  800481:	c3                   	ret    

00800482 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800482:	55                   	push   %ebp
  800483:	89 e5                	mov    %esp,%ebp
  800485:	53                   	push   %ebx
  800486:	83 ec 04             	sub    $0x4,%esp
  800489:	8b 45 08             	mov    0x8(%ebp),%eax
  80048c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80048f:	3b 05 04 30 80 00    	cmp    0x803004,%eax
  800495:	75 1e                	jne    8004b5 <dev_lookup+0x33>
  800497:	eb 0e                	jmp    8004a7 <dev_lookup+0x25>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800499:	b8 20 30 80 00       	mov    $0x803020,%eax
  80049e:	eb 0c                	jmp    8004ac <dev_lookup+0x2a>
  8004a0:	b8 3c 30 80 00       	mov    $0x80303c,%eax
  8004a5:	eb 05                	jmp    8004ac <dev_lookup+0x2a>
  8004a7:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  8004ac:	89 03                	mov    %eax,(%ebx)
			return 0;
  8004ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b3:	eb 36                	jmp    8004eb <dev_lookup+0x69>
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8004b5:	3b 05 20 30 80 00    	cmp    0x803020,%eax
  8004bb:	74 dc                	je     800499 <dev_lookup+0x17>
  8004bd:	3b 05 3c 30 80 00    	cmp    0x80303c,%eax
  8004c3:	74 db                	je     8004a0 <dev_lookup+0x1e>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8004c5:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8004cb:	8b 52 48             	mov    0x48(%edx),%edx
  8004ce:	83 ec 04             	sub    $0x4,%esp
  8004d1:	50                   	push   %eax
  8004d2:	52                   	push   %edx
  8004d3:	68 38 1f 80 00       	push   $0x801f38
  8004d8:	e8 23 0c 00 00       	call   801100 <cprintf>
	*dev = 0;
  8004dd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8004e3:	83 c4 10             	add    $0x10,%esp
  8004e6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004ee:	c9                   	leave  
  8004ef:	c3                   	ret    

008004f0 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004f0:	55                   	push   %ebp
  8004f1:	89 e5                	mov    %esp,%ebp
  8004f3:	56                   	push   %esi
  8004f4:	53                   	push   %ebx
  8004f5:	83 ec 10             	sub    $0x10,%esp
  8004f8:	8b 75 08             	mov    0x8(%ebp),%esi
  8004fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800501:	50                   	push   %eax
  800502:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800508:	c1 e8 0c             	shr    $0xc,%eax
  80050b:	50                   	push   %eax
  80050c:	e8 1a ff ff ff       	call   80042b <fd_lookup>
  800511:	83 c4 08             	add    $0x8,%esp
  800514:	85 c0                	test   %eax,%eax
  800516:	78 05                	js     80051d <fd_close+0x2d>
	    || fd != fd2)
  800518:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80051b:	74 06                	je     800523 <fd_close+0x33>
		return (must_exist ? r : 0);
  80051d:	84 db                	test   %bl,%bl
  80051f:	74 47                	je     800568 <fd_close+0x78>
  800521:	eb 4a                	jmp    80056d <fd_close+0x7d>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800523:	83 ec 08             	sub    $0x8,%esp
  800526:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800529:	50                   	push   %eax
  80052a:	ff 36                	pushl  (%esi)
  80052c:	e8 51 ff ff ff       	call   800482 <dev_lookup>
  800531:	89 c3                	mov    %eax,%ebx
  800533:	83 c4 10             	add    $0x10,%esp
  800536:	85 c0                	test   %eax,%eax
  800538:	78 1c                	js     800556 <fd_close+0x66>
		if (dev->dev_close)
  80053a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80053d:	8b 40 10             	mov    0x10(%eax),%eax
  800540:	85 c0                	test   %eax,%eax
  800542:	74 0d                	je     800551 <fd_close+0x61>
			r = (*dev->dev_close)(fd);
  800544:	83 ec 0c             	sub    $0xc,%esp
  800547:	56                   	push   %esi
  800548:	ff d0                	call   *%eax
  80054a:	89 c3                	mov    %eax,%ebx
  80054c:	83 c4 10             	add    $0x10,%esp
  80054f:	eb 05                	jmp    800556 <fd_close+0x66>
		else
			r = 0;
  800551:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800556:	83 ec 08             	sub    $0x8,%esp
  800559:	56                   	push   %esi
  80055a:	6a 00                	push   $0x0
  80055c:	e8 9d fc ff ff       	call   8001fe <sys_page_unmap>
	return r;
  800561:	83 c4 10             	add    $0x10,%esp
  800564:	89 d8                	mov    %ebx,%eax
  800566:	eb 05                	jmp    80056d <fd_close+0x7d>
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
  800568:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
	return r;
}
  80056d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800570:	5b                   	pop    %ebx
  800571:	5e                   	pop    %esi
  800572:	5d                   	pop    %ebp
  800573:	c3                   	ret    

00800574 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800574:	55                   	push   %ebp
  800575:	89 e5                	mov    %esp,%ebp
  800577:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80057a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80057d:	50                   	push   %eax
  80057e:	ff 75 08             	pushl  0x8(%ebp)
  800581:	e8 a5 fe ff ff       	call   80042b <fd_lookup>
  800586:	83 c4 08             	add    $0x8,%esp
  800589:	85 c0                	test   %eax,%eax
  80058b:	78 10                	js     80059d <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80058d:	83 ec 08             	sub    $0x8,%esp
  800590:	6a 01                	push   $0x1
  800592:	ff 75 f4             	pushl  -0xc(%ebp)
  800595:	e8 56 ff ff ff       	call   8004f0 <fd_close>
  80059a:	83 c4 10             	add    $0x10,%esp
}
  80059d:	c9                   	leave  
  80059e:	c3                   	ret    

0080059f <close_all>:

void
close_all(void)
{
  80059f:	55                   	push   %ebp
  8005a0:	89 e5                	mov    %esp,%ebp
  8005a2:	53                   	push   %ebx
  8005a3:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8005a6:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8005ab:	83 ec 0c             	sub    $0xc,%esp
  8005ae:	53                   	push   %ebx
  8005af:	e8 c0 ff ff ff       	call   800574 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8005b4:	43                   	inc    %ebx
  8005b5:	83 c4 10             	add    $0x10,%esp
  8005b8:	83 fb 20             	cmp    $0x20,%ebx
  8005bb:	75 ee                	jne    8005ab <close_all+0xc>
		close(i);
}
  8005bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8005c0:	c9                   	leave  
  8005c1:	c3                   	ret    

008005c2 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8005c2:	55                   	push   %ebp
  8005c3:	89 e5                	mov    %esp,%ebp
  8005c5:	57                   	push   %edi
  8005c6:	56                   	push   %esi
  8005c7:	53                   	push   %ebx
  8005c8:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005cb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005ce:	50                   	push   %eax
  8005cf:	ff 75 08             	pushl  0x8(%ebp)
  8005d2:	e8 54 fe ff ff       	call   80042b <fd_lookup>
  8005d7:	83 c4 08             	add    $0x8,%esp
  8005da:	85 c0                	test   %eax,%eax
  8005dc:	0f 88 c2 00 00 00    	js     8006a4 <dup+0xe2>
		return r;
	close(newfdnum);
  8005e2:	83 ec 0c             	sub    $0xc,%esp
  8005e5:	ff 75 0c             	pushl  0xc(%ebp)
  8005e8:	e8 87 ff ff ff       	call   800574 <close>

	newfd = INDEX2FD(newfdnum);
  8005ed:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005f0:	c1 e3 0c             	shl    $0xc,%ebx
  8005f3:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8005f9:	83 c4 04             	add    $0x4,%esp
  8005fc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005ff:	e8 9c fd ff ff       	call   8003a0 <fd2data>
  800604:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  800606:	89 1c 24             	mov    %ebx,(%esp)
  800609:	e8 92 fd ff ff       	call   8003a0 <fd2data>
  80060e:	83 c4 10             	add    $0x10,%esp
  800611:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800613:	89 f0                	mov    %esi,%eax
  800615:	c1 e8 16             	shr    $0x16,%eax
  800618:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80061f:	a8 01                	test   $0x1,%al
  800621:	74 35                	je     800658 <dup+0x96>
  800623:	89 f0                	mov    %esi,%eax
  800625:	c1 e8 0c             	shr    $0xc,%eax
  800628:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80062f:	f6 c2 01             	test   $0x1,%dl
  800632:	74 24                	je     800658 <dup+0x96>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800634:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80063b:	83 ec 0c             	sub    $0xc,%esp
  80063e:	25 07 0e 00 00       	and    $0xe07,%eax
  800643:	50                   	push   %eax
  800644:	57                   	push   %edi
  800645:	6a 00                	push   $0x0
  800647:	56                   	push   %esi
  800648:	6a 00                	push   $0x0
  80064a:	e8 6d fb ff ff       	call   8001bc <sys_page_map>
  80064f:	89 c6                	mov    %eax,%esi
  800651:	83 c4 20             	add    $0x20,%esp
  800654:	85 c0                	test   %eax,%eax
  800656:	78 2c                	js     800684 <dup+0xc2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800658:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80065b:	89 d0                	mov    %edx,%eax
  80065d:	c1 e8 0c             	shr    $0xc,%eax
  800660:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800667:	83 ec 0c             	sub    $0xc,%esp
  80066a:	25 07 0e 00 00       	and    $0xe07,%eax
  80066f:	50                   	push   %eax
  800670:	53                   	push   %ebx
  800671:	6a 00                	push   $0x0
  800673:	52                   	push   %edx
  800674:	6a 00                	push   $0x0
  800676:	e8 41 fb ff ff       	call   8001bc <sys_page_map>
  80067b:	89 c6                	mov    %eax,%esi
  80067d:	83 c4 20             	add    $0x20,%esp
  800680:	85 c0                	test   %eax,%eax
  800682:	79 1d                	jns    8006a1 <dup+0xdf>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800684:	83 ec 08             	sub    $0x8,%esp
  800687:	53                   	push   %ebx
  800688:	6a 00                	push   $0x0
  80068a:	e8 6f fb ff ff       	call   8001fe <sys_page_unmap>
	sys_page_unmap(0, nva);
  80068f:	83 c4 08             	add    $0x8,%esp
  800692:	57                   	push   %edi
  800693:	6a 00                	push   $0x0
  800695:	e8 64 fb ff ff       	call   8001fe <sys_page_unmap>
	return r;
  80069a:	83 c4 10             	add    $0x10,%esp
  80069d:	89 f0                	mov    %esi,%eax
  80069f:	eb 03                	jmp    8006a4 <dup+0xe2>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8006a1:	8b 45 0c             	mov    0xc(%ebp),%eax

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8006a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006a7:	5b                   	pop    %ebx
  8006a8:	5e                   	pop    %esi
  8006a9:	5f                   	pop    %edi
  8006aa:	5d                   	pop    %ebp
  8006ab:	c3                   	ret    

008006ac <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8006ac:	55                   	push   %ebp
  8006ad:	89 e5                	mov    %esp,%ebp
  8006af:	53                   	push   %ebx
  8006b0:	83 ec 14             	sub    $0x14,%esp
  8006b3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006b9:	50                   	push   %eax
  8006ba:	53                   	push   %ebx
  8006bb:	e8 6b fd ff ff       	call   80042b <fd_lookup>
  8006c0:	83 c4 08             	add    $0x8,%esp
  8006c3:	85 c0                	test   %eax,%eax
  8006c5:	78 67                	js     80072e <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006c7:	83 ec 08             	sub    $0x8,%esp
  8006ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006cd:	50                   	push   %eax
  8006ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006d1:	ff 30                	pushl  (%eax)
  8006d3:	e8 aa fd ff ff       	call   800482 <dev_lookup>
  8006d8:	83 c4 10             	add    $0x10,%esp
  8006db:	85 c0                	test   %eax,%eax
  8006dd:	78 4f                	js     80072e <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006df:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006e2:	8b 42 08             	mov    0x8(%edx),%eax
  8006e5:	83 e0 03             	and    $0x3,%eax
  8006e8:	83 f8 01             	cmp    $0x1,%eax
  8006eb:	75 21                	jne    80070e <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006ed:	a1 04 40 80 00       	mov    0x804004,%eax
  8006f2:	8b 40 48             	mov    0x48(%eax),%eax
  8006f5:	83 ec 04             	sub    $0x4,%esp
  8006f8:	53                   	push   %ebx
  8006f9:	50                   	push   %eax
  8006fa:	68 79 1f 80 00       	push   $0x801f79
  8006ff:	e8 fc 09 00 00       	call   801100 <cprintf>
		return -E_INVAL;
  800704:	83 c4 10             	add    $0x10,%esp
  800707:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80070c:	eb 20                	jmp    80072e <read+0x82>
	}
	if (!dev->dev_read)
  80070e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800711:	8b 40 08             	mov    0x8(%eax),%eax
  800714:	85 c0                	test   %eax,%eax
  800716:	74 11                	je     800729 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800718:	83 ec 04             	sub    $0x4,%esp
  80071b:	ff 75 10             	pushl  0x10(%ebp)
  80071e:	ff 75 0c             	pushl  0xc(%ebp)
  800721:	52                   	push   %edx
  800722:	ff d0                	call   *%eax
  800724:	83 c4 10             	add    $0x10,%esp
  800727:	eb 05                	jmp    80072e <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800729:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80072e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800731:	c9                   	leave  
  800732:	c3                   	ret    

00800733 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800733:	55                   	push   %ebp
  800734:	89 e5                	mov    %esp,%ebp
  800736:	57                   	push   %edi
  800737:	56                   	push   %esi
  800738:	53                   	push   %ebx
  800739:	83 ec 0c             	sub    $0xc,%esp
  80073c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80073f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800742:	85 f6                	test   %esi,%esi
  800744:	74 31                	je     800777 <readn+0x44>
  800746:	b8 00 00 00 00       	mov    $0x0,%eax
  80074b:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  800750:	83 ec 04             	sub    $0x4,%esp
  800753:	89 f2                	mov    %esi,%edx
  800755:	29 c2                	sub    %eax,%edx
  800757:	52                   	push   %edx
  800758:	03 45 0c             	add    0xc(%ebp),%eax
  80075b:	50                   	push   %eax
  80075c:	57                   	push   %edi
  80075d:	e8 4a ff ff ff       	call   8006ac <read>
		if (m < 0)
  800762:	83 c4 10             	add    $0x10,%esp
  800765:	85 c0                	test   %eax,%eax
  800767:	78 17                	js     800780 <readn+0x4d>
			return m;
		if (m == 0)
  800769:	85 c0                	test   %eax,%eax
  80076b:	74 11                	je     80077e <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80076d:	01 c3                	add    %eax,%ebx
  80076f:	89 d8                	mov    %ebx,%eax
  800771:	39 f3                	cmp    %esi,%ebx
  800773:	72 db                	jb     800750 <readn+0x1d>
  800775:	eb 09                	jmp    800780 <readn+0x4d>
  800777:	b8 00 00 00 00       	mov    $0x0,%eax
  80077c:	eb 02                	jmp    800780 <readn+0x4d>
  80077e:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800780:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800783:	5b                   	pop    %ebx
  800784:	5e                   	pop    %esi
  800785:	5f                   	pop    %edi
  800786:	5d                   	pop    %ebp
  800787:	c3                   	ret    

00800788 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800788:	55                   	push   %ebp
  800789:	89 e5                	mov    %esp,%ebp
  80078b:	53                   	push   %ebx
  80078c:	83 ec 14             	sub    $0x14,%esp
  80078f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800792:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800795:	50                   	push   %eax
  800796:	53                   	push   %ebx
  800797:	e8 8f fc ff ff       	call   80042b <fd_lookup>
  80079c:	83 c4 08             	add    $0x8,%esp
  80079f:	85 c0                	test   %eax,%eax
  8007a1:	78 62                	js     800805 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007a3:	83 ec 08             	sub    $0x8,%esp
  8007a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007a9:	50                   	push   %eax
  8007aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007ad:	ff 30                	pushl  (%eax)
  8007af:	e8 ce fc ff ff       	call   800482 <dev_lookup>
  8007b4:	83 c4 10             	add    $0x10,%esp
  8007b7:	85 c0                	test   %eax,%eax
  8007b9:	78 4a                	js     800805 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007be:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007c2:	75 21                	jne    8007e5 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8007c4:	a1 04 40 80 00       	mov    0x804004,%eax
  8007c9:	8b 40 48             	mov    0x48(%eax),%eax
  8007cc:	83 ec 04             	sub    $0x4,%esp
  8007cf:	53                   	push   %ebx
  8007d0:	50                   	push   %eax
  8007d1:	68 95 1f 80 00       	push   $0x801f95
  8007d6:	e8 25 09 00 00       	call   801100 <cprintf>
		return -E_INVAL;
  8007db:	83 c4 10             	add    $0x10,%esp
  8007de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007e3:	eb 20                	jmp    800805 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007e5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007e8:	8b 52 0c             	mov    0xc(%edx),%edx
  8007eb:	85 d2                	test   %edx,%edx
  8007ed:	74 11                	je     800800 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007ef:	83 ec 04             	sub    $0x4,%esp
  8007f2:	ff 75 10             	pushl  0x10(%ebp)
  8007f5:	ff 75 0c             	pushl  0xc(%ebp)
  8007f8:	50                   	push   %eax
  8007f9:	ff d2                	call   *%edx
  8007fb:	83 c4 10             	add    $0x10,%esp
  8007fe:	eb 05                	jmp    800805 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800800:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  800805:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800808:	c9                   	leave  
  800809:	c3                   	ret    

0080080a <seek>:

int
seek(int fdnum, off_t offset)
{
  80080a:	55                   	push   %ebp
  80080b:	89 e5                	mov    %esp,%ebp
  80080d:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800810:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800813:	50                   	push   %eax
  800814:	ff 75 08             	pushl  0x8(%ebp)
  800817:	e8 0f fc ff ff       	call   80042b <fd_lookup>
  80081c:	83 c4 08             	add    $0x8,%esp
  80081f:	85 c0                	test   %eax,%eax
  800821:	78 0e                	js     800831 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800823:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800826:	8b 55 0c             	mov    0xc(%ebp),%edx
  800829:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80082c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800831:	c9                   	leave  
  800832:	c3                   	ret    

00800833 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800833:	55                   	push   %ebp
  800834:	89 e5                	mov    %esp,%ebp
  800836:	53                   	push   %ebx
  800837:	83 ec 14             	sub    $0x14,%esp
  80083a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80083d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800840:	50                   	push   %eax
  800841:	53                   	push   %ebx
  800842:	e8 e4 fb ff ff       	call   80042b <fd_lookup>
  800847:	83 c4 08             	add    $0x8,%esp
  80084a:	85 c0                	test   %eax,%eax
  80084c:	78 5f                	js     8008ad <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80084e:	83 ec 08             	sub    $0x8,%esp
  800851:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800854:	50                   	push   %eax
  800855:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800858:	ff 30                	pushl  (%eax)
  80085a:	e8 23 fc ff ff       	call   800482 <dev_lookup>
  80085f:	83 c4 10             	add    $0x10,%esp
  800862:	85 c0                	test   %eax,%eax
  800864:	78 47                	js     8008ad <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800866:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800869:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80086d:	75 21                	jne    800890 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80086f:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800874:	8b 40 48             	mov    0x48(%eax),%eax
  800877:	83 ec 04             	sub    $0x4,%esp
  80087a:	53                   	push   %ebx
  80087b:	50                   	push   %eax
  80087c:	68 58 1f 80 00       	push   $0x801f58
  800881:	e8 7a 08 00 00       	call   801100 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800886:	83 c4 10             	add    $0x10,%esp
  800889:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80088e:	eb 1d                	jmp    8008ad <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  800890:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800893:	8b 52 18             	mov    0x18(%edx),%edx
  800896:	85 d2                	test   %edx,%edx
  800898:	74 0e                	je     8008a8 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80089a:	83 ec 08             	sub    $0x8,%esp
  80089d:	ff 75 0c             	pushl  0xc(%ebp)
  8008a0:	50                   	push   %eax
  8008a1:	ff d2                	call   *%edx
  8008a3:	83 c4 10             	add    $0x10,%esp
  8008a6:	eb 05                	jmp    8008ad <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8008a8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8008ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008b0:	c9                   	leave  
  8008b1:	c3                   	ret    

008008b2 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8008b2:	55                   	push   %ebp
  8008b3:	89 e5                	mov    %esp,%ebp
  8008b5:	53                   	push   %ebx
  8008b6:	83 ec 14             	sub    $0x14,%esp
  8008b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008bc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008bf:	50                   	push   %eax
  8008c0:	ff 75 08             	pushl  0x8(%ebp)
  8008c3:	e8 63 fb ff ff       	call   80042b <fd_lookup>
  8008c8:	83 c4 08             	add    $0x8,%esp
  8008cb:	85 c0                	test   %eax,%eax
  8008cd:	78 52                	js     800921 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008cf:	83 ec 08             	sub    $0x8,%esp
  8008d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008d5:	50                   	push   %eax
  8008d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008d9:	ff 30                	pushl  (%eax)
  8008db:	e8 a2 fb ff ff       	call   800482 <dev_lookup>
  8008e0:	83 c4 10             	add    $0x10,%esp
  8008e3:	85 c0                	test   %eax,%eax
  8008e5:	78 3a                	js     800921 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  8008e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008ea:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008ee:	74 2c                	je     80091c <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008f0:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008f3:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008fa:	00 00 00 
	stat->st_isdir = 0;
  8008fd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800904:	00 00 00 
	stat->st_dev = dev;
  800907:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80090d:	83 ec 08             	sub    $0x8,%esp
  800910:	53                   	push   %ebx
  800911:	ff 75 f0             	pushl  -0x10(%ebp)
  800914:	ff 50 14             	call   *0x14(%eax)
  800917:	83 c4 10             	add    $0x10,%esp
  80091a:	eb 05                	jmp    800921 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80091c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800921:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800924:	c9                   	leave  
  800925:	c3                   	ret    

00800926 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800926:	55                   	push   %ebp
  800927:	89 e5                	mov    %esp,%ebp
  800929:	56                   	push   %esi
  80092a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80092b:	83 ec 08             	sub    $0x8,%esp
  80092e:	6a 00                	push   $0x0
  800930:	ff 75 08             	pushl  0x8(%ebp)
  800933:	e8 75 01 00 00       	call   800aad <open>
  800938:	89 c3                	mov    %eax,%ebx
  80093a:	83 c4 10             	add    $0x10,%esp
  80093d:	85 c0                	test   %eax,%eax
  80093f:	78 1d                	js     80095e <stat+0x38>
		return fd;
	r = fstat(fd, stat);
  800941:	83 ec 08             	sub    $0x8,%esp
  800944:	ff 75 0c             	pushl  0xc(%ebp)
  800947:	50                   	push   %eax
  800948:	e8 65 ff ff ff       	call   8008b2 <fstat>
  80094d:	89 c6                	mov    %eax,%esi
	close(fd);
  80094f:	89 1c 24             	mov    %ebx,(%esp)
  800952:	e8 1d fc ff ff       	call   800574 <close>
	return r;
  800957:	83 c4 10             	add    $0x10,%esp
  80095a:	89 f0                	mov    %esi,%eax
  80095c:	eb 00                	jmp    80095e <stat+0x38>
}
  80095e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800961:	5b                   	pop    %ebx
  800962:	5e                   	pop    %esi
  800963:	5d                   	pop    %ebp
  800964:	c3                   	ret    

00800965 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800965:	55                   	push   %ebp
  800966:	89 e5                	mov    %esp,%ebp
  800968:	56                   	push   %esi
  800969:	53                   	push   %ebx
  80096a:	89 c6                	mov    %eax,%esi
  80096c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80096e:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800975:	75 12                	jne    800989 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800977:	83 ec 0c             	sub    $0xc,%esp
  80097a:	6a 01                	push   $0x1
  80097c:	e8 64 12 00 00       	call   801be5 <ipc_find_env>
  800981:	a3 00 40 80 00       	mov    %eax,0x804000
  800986:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800989:	6a 07                	push   $0x7
  80098b:	68 00 50 80 00       	push   $0x805000
  800990:	56                   	push   %esi
  800991:	ff 35 00 40 80 00    	pushl  0x804000
  800997:	e8 ea 11 00 00       	call   801b86 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80099c:	83 c4 0c             	add    $0xc,%esp
  80099f:	6a 00                	push   $0x0
  8009a1:	53                   	push   %ebx
  8009a2:	6a 00                	push   $0x0
  8009a4:	e8 68 11 00 00       	call   801b11 <ipc_recv>
}
  8009a9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009ac:	5b                   	pop    %ebx
  8009ad:	5e                   	pop    %esi
  8009ae:	5d                   	pop    %ebp
  8009af:	c3                   	ret    

008009b0 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009b0:	55                   	push   %ebp
  8009b1:	89 e5                	mov    %esp,%ebp
  8009b3:	53                   	push   %ebx
  8009b4:	83 ec 04             	sub    $0x4,%esp
  8009b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bd:	8b 40 0c             	mov    0xc(%eax),%eax
  8009c0:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ca:	b8 05 00 00 00       	mov    $0x5,%eax
  8009cf:	e8 91 ff ff ff       	call   800965 <fsipc>
  8009d4:	85 c0                	test   %eax,%eax
  8009d6:	78 2c                	js     800a04 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009d8:	83 ec 08             	sub    $0x8,%esp
  8009db:	68 00 50 80 00       	push   $0x805000
  8009e0:	53                   	push   %ebx
  8009e1:	e8 ff 0c 00 00       	call   8016e5 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009e6:	a1 80 50 80 00       	mov    0x805080,%eax
  8009eb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009f1:	a1 84 50 80 00       	mov    0x805084,%eax
  8009f6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009fc:	83 c4 10             	add    $0x10,%esp
  8009ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a04:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a07:	c9                   	leave  
  800a08:	c3                   	ret    

00800a09 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800a09:	55                   	push   %ebp
  800a0a:	89 e5                	mov    %esp,%ebp
  800a0c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800a0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a12:	8b 40 0c             	mov    0xc(%eax),%eax
  800a15:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800a1a:	ba 00 00 00 00       	mov    $0x0,%edx
  800a1f:	b8 06 00 00 00       	mov    $0x6,%eax
  800a24:	e8 3c ff ff ff       	call   800965 <fsipc>
}
  800a29:	c9                   	leave  
  800a2a:	c3                   	ret    

00800a2b <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a2b:	55                   	push   %ebp
  800a2c:	89 e5                	mov    %esp,%ebp
  800a2e:	56                   	push   %esi
  800a2f:	53                   	push   %ebx
  800a30:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a33:	8b 45 08             	mov    0x8(%ebp),%eax
  800a36:	8b 40 0c             	mov    0xc(%eax),%eax
  800a39:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a3e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a44:	ba 00 00 00 00       	mov    $0x0,%edx
  800a49:	b8 03 00 00 00       	mov    $0x3,%eax
  800a4e:	e8 12 ff ff ff       	call   800965 <fsipc>
  800a53:	89 c3                	mov    %eax,%ebx
  800a55:	85 c0                	test   %eax,%eax
  800a57:	78 4b                	js     800aa4 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a59:	39 c6                	cmp    %eax,%esi
  800a5b:	73 16                	jae    800a73 <devfile_read+0x48>
  800a5d:	68 b2 1f 80 00       	push   $0x801fb2
  800a62:	68 b9 1f 80 00       	push   $0x801fb9
  800a67:	6a 7a                	push   $0x7a
  800a69:	68 ce 1f 80 00       	push   $0x801fce
  800a6e:	e8 b5 05 00 00       	call   801028 <_panic>
	assert(r <= PGSIZE);
  800a73:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a78:	7e 16                	jle    800a90 <devfile_read+0x65>
  800a7a:	68 d9 1f 80 00       	push   $0x801fd9
  800a7f:	68 b9 1f 80 00       	push   $0x801fb9
  800a84:	6a 7b                	push   $0x7b
  800a86:	68 ce 1f 80 00       	push   $0x801fce
  800a8b:	e8 98 05 00 00       	call   801028 <_panic>
	memmove(buf, &fsipcbuf, r);
  800a90:	83 ec 04             	sub    $0x4,%esp
  800a93:	50                   	push   %eax
  800a94:	68 00 50 80 00       	push   $0x805000
  800a99:	ff 75 0c             	pushl  0xc(%ebp)
  800a9c:	e8 11 0e 00 00       	call   8018b2 <memmove>
	return r;
  800aa1:	83 c4 10             	add    $0x10,%esp
}
  800aa4:	89 d8                	mov    %ebx,%eax
  800aa6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800aa9:	5b                   	pop    %ebx
  800aaa:	5e                   	pop    %esi
  800aab:	5d                   	pop    %ebp
  800aac:	c3                   	ret    

00800aad <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800aad:	55                   	push   %ebp
  800aae:	89 e5                	mov    %esp,%ebp
  800ab0:	53                   	push   %ebx
  800ab1:	83 ec 20             	sub    $0x20,%esp
  800ab4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800ab7:	53                   	push   %ebx
  800ab8:	e8 d1 0b 00 00       	call   80168e <strlen>
  800abd:	83 c4 10             	add    $0x10,%esp
  800ac0:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ac5:	7f 63                	jg     800b2a <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ac7:	83 ec 0c             	sub    $0xc,%esp
  800aca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800acd:	50                   	push   %eax
  800ace:	e8 e4 f8 ff ff       	call   8003b7 <fd_alloc>
  800ad3:	83 c4 10             	add    $0x10,%esp
  800ad6:	85 c0                	test   %eax,%eax
  800ad8:	78 55                	js     800b2f <open+0x82>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800ada:	83 ec 08             	sub    $0x8,%esp
  800add:	53                   	push   %ebx
  800ade:	68 00 50 80 00       	push   $0x805000
  800ae3:	e8 fd 0b 00 00       	call   8016e5 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800ae8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aeb:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800af0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800af3:	b8 01 00 00 00       	mov    $0x1,%eax
  800af8:	e8 68 fe ff ff       	call   800965 <fsipc>
  800afd:	89 c3                	mov    %eax,%ebx
  800aff:	83 c4 10             	add    $0x10,%esp
  800b02:	85 c0                	test   %eax,%eax
  800b04:	79 14                	jns    800b1a <open+0x6d>
		fd_close(fd, 0);
  800b06:	83 ec 08             	sub    $0x8,%esp
  800b09:	6a 00                	push   $0x0
  800b0b:	ff 75 f4             	pushl  -0xc(%ebp)
  800b0e:	e8 dd f9 ff ff       	call   8004f0 <fd_close>
		return r;
  800b13:	83 c4 10             	add    $0x10,%esp
  800b16:	89 d8                	mov    %ebx,%eax
  800b18:	eb 15                	jmp    800b2f <open+0x82>
	}

	return fd2num(fd);
  800b1a:	83 ec 0c             	sub    $0xc,%esp
  800b1d:	ff 75 f4             	pushl  -0xc(%ebp)
  800b20:	e8 6b f8 ff ff       	call   800390 <fd2num>
  800b25:	83 c4 10             	add    $0x10,%esp
  800b28:	eb 05                	jmp    800b2f <open+0x82>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b2a:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b2f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b32:	c9                   	leave  
  800b33:	c3                   	ret    

00800b34 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b34:	55                   	push   %ebp
  800b35:	89 e5                	mov    %esp,%ebp
  800b37:	56                   	push   %esi
  800b38:	53                   	push   %ebx
  800b39:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b3c:	83 ec 0c             	sub    $0xc,%esp
  800b3f:	ff 75 08             	pushl  0x8(%ebp)
  800b42:	e8 59 f8 ff ff       	call   8003a0 <fd2data>
  800b47:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b49:	83 c4 08             	add    $0x8,%esp
  800b4c:	68 e5 1f 80 00       	push   $0x801fe5
  800b51:	53                   	push   %ebx
  800b52:	e8 8e 0b 00 00       	call   8016e5 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b57:	8b 46 04             	mov    0x4(%esi),%eax
  800b5a:	2b 06                	sub    (%esi),%eax
  800b5c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b62:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b69:	00 00 00 
	stat->st_dev = &devpipe;
  800b6c:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800b73:	30 80 00 
	return 0;
}
  800b76:	b8 00 00 00 00       	mov    $0x0,%eax
  800b7b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b7e:	5b                   	pop    %ebx
  800b7f:	5e                   	pop    %esi
  800b80:	5d                   	pop    %ebp
  800b81:	c3                   	ret    

00800b82 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b82:	55                   	push   %ebp
  800b83:	89 e5                	mov    %esp,%ebp
  800b85:	53                   	push   %ebx
  800b86:	83 ec 0c             	sub    $0xc,%esp
  800b89:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800b8c:	53                   	push   %ebx
  800b8d:	6a 00                	push   $0x0
  800b8f:	e8 6a f6 ff ff       	call   8001fe <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800b94:	89 1c 24             	mov    %ebx,(%esp)
  800b97:	e8 04 f8 ff ff       	call   8003a0 <fd2data>
  800b9c:	83 c4 08             	add    $0x8,%esp
  800b9f:	50                   	push   %eax
  800ba0:	6a 00                	push   $0x0
  800ba2:	e8 57 f6 ff ff       	call   8001fe <sys_page_unmap>
}
  800ba7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800baa:	c9                   	leave  
  800bab:	c3                   	ret    

00800bac <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800bac:	55                   	push   %ebp
  800bad:	89 e5                	mov    %esp,%ebp
  800baf:	57                   	push   %edi
  800bb0:	56                   	push   %esi
  800bb1:	53                   	push   %ebx
  800bb2:	83 ec 1c             	sub    $0x1c,%esp
  800bb5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800bb8:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800bba:	a1 04 40 80 00       	mov    0x804004,%eax
  800bbf:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800bc2:	83 ec 0c             	sub    $0xc,%esp
  800bc5:	ff 75 e0             	pushl  -0x20(%ebp)
  800bc8:	e8 73 10 00 00       	call   801c40 <pageref>
  800bcd:	89 c3                	mov    %eax,%ebx
  800bcf:	89 3c 24             	mov    %edi,(%esp)
  800bd2:	e8 69 10 00 00       	call   801c40 <pageref>
  800bd7:	83 c4 10             	add    $0x10,%esp
  800bda:	39 c3                	cmp    %eax,%ebx
  800bdc:	0f 94 c1             	sete   %cl
  800bdf:	0f b6 c9             	movzbl %cl,%ecx
  800be2:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800be5:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800beb:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800bee:	39 ce                	cmp    %ecx,%esi
  800bf0:	74 1b                	je     800c0d <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800bf2:	39 c3                	cmp    %eax,%ebx
  800bf4:	75 c4                	jne    800bba <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800bf6:	8b 42 58             	mov    0x58(%edx),%eax
  800bf9:	ff 75 e4             	pushl  -0x1c(%ebp)
  800bfc:	50                   	push   %eax
  800bfd:	56                   	push   %esi
  800bfe:	68 ec 1f 80 00       	push   $0x801fec
  800c03:	e8 f8 04 00 00       	call   801100 <cprintf>
  800c08:	83 c4 10             	add    $0x10,%esp
  800c0b:	eb ad                	jmp    800bba <_pipeisclosed+0xe>
	}
}
  800c0d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c10:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c13:	5b                   	pop    %ebx
  800c14:	5e                   	pop    %esi
  800c15:	5f                   	pop    %edi
  800c16:	5d                   	pop    %ebp
  800c17:	c3                   	ret    

00800c18 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c18:	55                   	push   %ebp
  800c19:	89 e5                	mov    %esp,%ebp
  800c1b:	57                   	push   %edi
  800c1c:	56                   	push   %esi
  800c1d:	53                   	push   %ebx
  800c1e:	83 ec 18             	sub    $0x18,%esp
  800c21:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c24:	56                   	push   %esi
  800c25:	e8 76 f7 ff ff       	call   8003a0 <fd2data>
  800c2a:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c2c:	83 c4 10             	add    $0x10,%esp
  800c2f:	bf 00 00 00 00       	mov    $0x0,%edi
  800c34:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c38:	75 42                	jne    800c7c <devpipe_write+0x64>
  800c3a:	eb 4e                	jmp    800c8a <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c3c:	89 da                	mov    %ebx,%edx
  800c3e:	89 f0                	mov    %esi,%eax
  800c40:	e8 67 ff ff ff       	call   800bac <_pipeisclosed>
  800c45:	85 c0                	test   %eax,%eax
  800c47:	75 46                	jne    800c8f <devpipe_write+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c49:	e8 0c f5 ff ff       	call   80015a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c4e:	8b 53 04             	mov    0x4(%ebx),%edx
  800c51:	8b 03                	mov    (%ebx),%eax
  800c53:	83 c0 20             	add    $0x20,%eax
  800c56:	39 c2                	cmp    %eax,%edx
  800c58:	73 e2                	jae    800c3c <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c5a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c5d:	8a 0c 38             	mov    (%eax,%edi,1),%cl
  800c60:	89 d0                	mov    %edx,%eax
  800c62:	25 1f 00 00 80       	and    $0x8000001f,%eax
  800c67:	79 05                	jns    800c6e <devpipe_write+0x56>
  800c69:	48                   	dec    %eax
  800c6a:	83 c8 e0             	or     $0xffffffe0,%eax
  800c6d:	40                   	inc    %eax
  800c6e:	88 4c 03 08          	mov    %cl,0x8(%ebx,%eax,1)
		p->p_wpos++;
  800c72:	42                   	inc    %edx
  800c73:	89 53 04             	mov    %edx,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c76:	47                   	inc    %edi
  800c77:	39 7d 10             	cmp    %edi,0x10(%ebp)
  800c7a:	74 0e                	je     800c8a <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c7c:	8b 53 04             	mov    0x4(%ebx),%edx
  800c7f:	8b 03                	mov    (%ebx),%eax
  800c81:	83 c0 20             	add    $0x20,%eax
  800c84:	39 c2                	cmp    %eax,%edx
  800c86:	73 b4                	jae    800c3c <devpipe_write+0x24>
  800c88:	eb d0                	jmp    800c5a <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800c8a:	8b 45 10             	mov    0x10(%ebp),%eax
  800c8d:	eb 05                	jmp    800c94 <devpipe_write+0x7c>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800c8f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800c94:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c97:	5b                   	pop    %ebx
  800c98:	5e                   	pop    %esi
  800c99:	5f                   	pop    %edi
  800c9a:	5d                   	pop    %ebp
  800c9b:	c3                   	ret    

00800c9c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800c9c:	55                   	push   %ebp
  800c9d:	89 e5                	mov    %esp,%ebp
  800c9f:	57                   	push   %edi
  800ca0:	56                   	push   %esi
  800ca1:	53                   	push   %ebx
  800ca2:	83 ec 18             	sub    $0x18,%esp
  800ca5:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800ca8:	57                   	push   %edi
  800ca9:	e8 f2 f6 ff ff       	call   8003a0 <fd2data>
  800cae:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cb0:	83 c4 10             	add    $0x10,%esp
  800cb3:	be 00 00 00 00       	mov    $0x0,%esi
  800cb8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800cbc:	75 3d                	jne    800cfb <devpipe_read+0x5f>
  800cbe:	eb 48                	jmp    800d08 <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  800cc0:	89 f0                	mov    %esi,%eax
  800cc2:	eb 4e                	jmp    800d12 <devpipe_read+0x76>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800cc4:	89 da                	mov    %ebx,%edx
  800cc6:	89 f8                	mov    %edi,%eax
  800cc8:	e8 df fe ff ff       	call   800bac <_pipeisclosed>
  800ccd:	85 c0                	test   %eax,%eax
  800ccf:	75 3c                	jne    800d0d <devpipe_read+0x71>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800cd1:	e8 84 f4 ff ff       	call   80015a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800cd6:	8b 03                	mov    (%ebx),%eax
  800cd8:	3b 43 04             	cmp    0x4(%ebx),%eax
  800cdb:	74 e7                	je     800cc4 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800cdd:	25 1f 00 00 80       	and    $0x8000001f,%eax
  800ce2:	79 05                	jns    800ce9 <devpipe_read+0x4d>
  800ce4:	48                   	dec    %eax
  800ce5:	83 c8 e0             	or     $0xffffffe0,%eax
  800ce8:	40                   	inc    %eax
  800ce9:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  800ced:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf0:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800cf3:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cf5:	46                   	inc    %esi
  800cf6:	39 75 10             	cmp    %esi,0x10(%ebp)
  800cf9:	74 0d                	je     800d08 <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
  800cfb:	8b 03                	mov    (%ebx),%eax
  800cfd:	3b 43 04             	cmp    0x4(%ebx),%eax
  800d00:	75 db                	jne    800cdd <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800d02:	85 f6                	test   %esi,%esi
  800d04:	75 ba                	jne    800cc0 <devpipe_read+0x24>
  800d06:	eb bc                	jmp    800cc4 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d08:	8b 45 10             	mov    0x10(%ebp),%eax
  800d0b:	eb 05                	jmp    800d12 <devpipe_read+0x76>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d0d:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d12:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d15:	5b                   	pop    %ebx
  800d16:	5e                   	pop    %esi
  800d17:	5f                   	pop    %edi
  800d18:	5d                   	pop    %ebp
  800d19:	c3                   	ret    

00800d1a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d1a:	55                   	push   %ebp
  800d1b:	89 e5                	mov    %esp,%ebp
  800d1d:	56                   	push   %esi
  800d1e:	53                   	push   %ebx
  800d1f:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d22:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d25:	50                   	push   %eax
  800d26:	e8 8c f6 ff ff       	call   8003b7 <fd_alloc>
  800d2b:	83 c4 10             	add    $0x10,%esp
  800d2e:	85 c0                	test   %eax,%eax
  800d30:	0f 88 2a 01 00 00    	js     800e60 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d36:	83 ec 04             	sub    $0x4,%esp
  800d39:	68 07 04 00 00       	push   $0x407
  800d3e:	ff 75 f4             	pushl  -0xc(%ebp)
  800d41:	6a 00                	push   $0x0
  800d43:	e8 31 f4 ff ff       	call   800179 <sys_page_alloc>
  800d48:	83 c4 10             	add    $0x10,%esp
  800d4b:	85 c0                	test   %eax,%eax
  800d4d:	0f 88 0d 01 00 00    	js     800e60 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d53:	83 ec 0c             	sub    $0xc,%esp
  800d56:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d59:	50                   	push   %eax
  800d5a:	e8 58 f6 ff ff       	call   8003b7 <fd_alloc>
  800d5f:	89 c3                	mov    %eax,%ebx
  800d61:	83 c4 10             	add    $0x10,%esp
  800d64:	85 c0                	test   %eax,%eax
  800d66:	0f 88 e2 00 00 00    	js     800e4e <pipe+0x134>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d6c:	83 ec 04             	sub    $0x4,%esp
  800d6f:	68 07 04 00 00       	push   $0x407
  800d74:	ff 75 f0             	pushl  -0x10(%ebp)
  800d77:	6a 00                	push   $0x0
  800d79:	e8 fb f3 ff ff       	call   800179 <sys_page_alloc>
  800d7e:	89 c3                	mov    %eax,%ebx
  800d80:	83 c4 10             	add    $0x10,%esp
  800d83:	85 c0                	test   %eax,%eax
  800d85:	0f 88 c3 00 00 00    	js     800e4e <pipe+0x134>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800d8b:	83 ec 0c             	sub    $0xc,%esp
  800d8e:	ff 75 f4             	pushl  -0xc(%ebp)
  800d91:	e8 0a f6 ff ff       	call   8003a0 <fd2data>
  800d96:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d98:	83 c4 0c             	add    $0xc,%esp
  800d9b:	68 07 04 00 00       	push   $0x407
  800da0:	50                   	push   %eax
  800da1:	6a 00                	push   $0x0
  800da3:	e8 d1 f3 ff ff       	call   800179 <sys_page_alloc>
  800da8:	89 c3                	mov    %eax,%ebx
  800daa:	83 c4 10             	add    $0x10,%esp
  800dad:	85 c0                	test   %eax,%eax
  800daf:	0f 88 89 00 00 00    	js     800e3e <pipe+0x124>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800db5:	83 ec 0c             	sub    $0xc,%esp
  800db8:	ff 75 f0             	pushl  -0x10(%ebp)
  800dbb:	e8 e0 f5 ff ff       	call   8003a0 <fd2data>
  800dc0:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800dc7:	50                   	push   %eax
  800dc8:	6a 00                	push   $0x0
  800dca:	56                   	push   %esi
  800dcb:	6a 00                	push   $0x0
  800dcd:	e8 ea f3 ff ff       	call   8001bc <sys_page_map>
  800dd2:	89 c3                	mov    %eax,%ebx
  800dd4:	83 c4 20             	add    $0x20,%esp
  800dd7:	85 c0                	test   %eax,%eax
  800dd9:	78 55                	js     800e30 <pipe+0x116>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800ddb:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800de1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800de4:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800de6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800de9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800df0:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800df6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800df9:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800dfb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dfe:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e05:	83 ec 0c             	sub    $0xc,%esp
  800e08:	ff 75 f4             	pushl  -0xc(%ebp)
  800e0b:	e8 80 f5 ff ff       	call   800390 <fd2num>
  800e10:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e13:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e15:	83 c4 04             	add    $0x4,%esp
  800e18:	ff 75 f0             	pushl  -0x10(%ebp)
  800e1b:	e8 70 f5 ff ff       	call   800390 <fd2num>
  800e20:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e23:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e26:	83 c4 10             	add    $0x10,%esp
  800e29:	b8 00 00 00 00       	mov    $0x0,%eax
  800e2e:	eb 30                	jmp    800e60 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  800e30:	83 ec 08             	sub    $0x8,%esp
  800e33:	56                   	push   %esi
  800e34:	6a 00                	push   $0x0
  800e36:	e8 c3 f3 ff ff       	call   8001fe <sys_page_unmap>
  800e3b:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e3e:	83 ec 08             	sub    $0x8,%esp
  800e41:	ff 75 f0             	pushl  -0x10(%ebp)
  800e44:	6a 00                	push   $0x0
  800e46:	e8 b3 f3 ff ff       	call   8001fe <sys_page_unmap>
  800e4b:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e4e:	83 ec 08             	sub    $0x8,%esp
  800e51:	ff 75 f4             	pushl  -0xc(%ebp)
  800e54:	6a 00                	push   $0x0
  800e56:	e8 a3 f3 ff ff       	call   8001fe <sys_page_unmap>
  800e5b:	83 c4 10             	add    $0x10,%esp
  800e5e:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  800e60:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e63:	5b                   	pop    %ebx
  800e64:	5e                   	pop    %esi
  800e65:	5d                   	pop    %ebp
  800e66:	c3                   	ret    

00800e67 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e67:	55                   	push   %ebp
  800e68:	89 e5                	mov    %esp,%ebp
  800e6a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e6d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e70:	50                   	push   %eax
  800e71:	ff 75 08             	pushl  0x8(%ebp)
  800e74:	e8 b2 f5 ff ff       	call   80042b <fd_lookup>
  800e79:	83 c4 10             	add    $0x10,%esp
  800e7c:	85 c0                	test   %eax,%eax
  800e7e:	78 18                	js     800e98 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800e80:	83 ec 0c             	sub    $0xc,%esp
  800e83:	ff 75 f4             	pushl  -0xc(%ebp)
  800e86:	e8 15 f5 ff ff       	call   8003a0 <fd2data>
	return _pipeisclosed(fd, p);
  800e8b:	89 c2                	mov    %eax,%edx
  800e8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e90:	e8 17 fd ff ff       	call   800bac <_pipeisclosed>
  800e95:	83 c4 10             	add    $0x10,%esp
}
  800e98:	c9                   	leave  
  800e99:	c3                   	ret    

00800e9a <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800e9a:	55                   	push   %ebp
  800e9b:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800e9d:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea2:	5d                   	pop    %ebp
  800ea3:	c3                   	ret    

00800ea4 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ea4:	55                   	push   %ebp
  800ea5:	89 e5                	mov    %esp,%ebp
  800ea7:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800eaa:	68 04 20 80 00       	push   $0x802004
  800eaf:	ff 75 0c             	pushl  0xc(%ebp)
  800eb2:	e8 2e 08 00 00       	call   8016e5 <strcpy>
	return 0;
}
  800eb7:	b8 00 00 00 00       	mov    $0x0,%eax
  800ebc:	c9                   	leave  
  800ebd:	c3                   	ret    

00800ebe <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800ebe:	55                   	push   %ebp
  800ebf:	89 e5                	mov    %esp,%ebp
  800ec1:	57                   	push   %edi
  800ec2:	56                   	push   %esi
  800ec3:	53                   	push   %ebx
  800ec4:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800eca:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ece:	74 45                	je     800f15 <devcons_write+0x57>
  800ed0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed5:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800eda:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800ee0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ee3:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  800ee5:	83 fb 7f             	cmp    $0x7f,%ebx
  800ee8:	76 05                	jbe    800eef <devcons_write+0x31>
			m = sizeof(buf) - 1;
  800eea:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800eef:	83 ec 04             	sub    $0x4,%esp
  800ef2:	53                   	push   %ebx
  800ef3:	03 45 0c             	add    0xc(%ebp),%eax
  800ef6:	50                   	push   %eax
  800ef7:	57                   	push   %edi
  800ef8:	e8 b5 09 00 00       	call   8018b2 <memmove>
		sys_cputs(buf, m);
  800efd:	83 c4 08             	add    $0x8,%esp
  800f00:	53                   	push   %ebx
  800f01:	57                   	push   %edi
  800f02:	e8 b6 f1 ff ff       	call   8000bd <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f07:	01 de                	add    %ebx,%esi
  800f09:	89 f0                	mov    %esi,%eax
  800f0b:	83 c4 10             	add    $0x10,%esp
  800f0e:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f11:	72 cd                	jb     800ee0 <devcons_write+0x22>
  800f13:	eb 05                	jmp    800f1a <devcons_write+0x5c>
  800f15:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f1a:	89 f0                	mov    %esi,%eax
  800f1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f1f:	5b                   	pop    %ebx
  800f20:	5e                   	pop    %esi
  800f21:	5f                   	pop    %edi
  800f22:	5d                   	pop    %ebp
  800f23:	c3                   	ret    

00800f24 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f24:	55                   	push   %ebp
  800f25:	89 e5                	mov    %esp,%ebp
  800f27:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  800f2a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f2e:	75 07                	jne    800f37 <devcons_read+0x13>
  800f30:	eb 23                	jmp    800f55 <devcons_read+0x31>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f32:	e8 23 f2 ff ff       	call   80015a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f37:	e8 9f f1 ff ff       	call   8000db <sys_cgetc>
  800f3c:	85 c0                	test   %eax,%eax
  800f3e:	74 f2                	je     800f32 <devcons_read+0xe>
		sys_yield();
	if (c < 0)
  800f40:	85 c0                	test   %eax,%eax
  800f42:	78 1d                	js     800f61 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f44:	83 f8 04             	cmp    $0x4,%eax
  800f47:	74 13                	je     800f5c <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  800f49:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f4c:	88 02                	mov    %al,(%edx)
	return 1;
  800f4e:	b8 01 00 00 00       	mov    $0x1,%eax
  800f53:	eb 0c                	jmp    800f61 <devcons_read+0x3d>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  800f55:	b8 00 00 00 00       	mov    $0x0,%eax
  800f5a:	eb 05                	jmp    800f61 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f5c:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f61:	c9                   	leave  
  800f62:	c3                   	ret    

00800f63 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f63:	55                   	push   %ebp
  800f64:	89 e5                	mov    %esp,%ebp
  800f66:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f69:	8b 45 08             	mov    0x8(%ebp),%eax
  800f6c:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f6f:	6a 01                	push   $0x1
  800f71:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f74:	50                   	push   %eax
  800f75:	e8 43 f1 ff ff       	call   8000bd <sys_cputs>
}
  800f7a:	83 c4 10             	add    $0x10,%esp
  800f7d:	c9                   	leave  
  800f7e:	c3                   	ret    

00800f7f <getchar>:

int
getchar(void)
{
  800f7f:	55                   	push   %ebp
  800f80:	89 e5                	mov    %esp,%ebp
  800f82:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f85:	6a 01                	push   $0x1
  800f87:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f8a:	50                   	push   %eax
  800f8b:	6a 00                	push   $0x0
  800f8d:	e8 1a f7 ff ff       	call   8006ac <read>
	if (r < 0)
  800f92:	83 c4 10             	add    $0x10,%esp
  800f95:	85 c0                	test   %eax,%eax
  800f97:	78 0f                	js     800fa8 <getchar+0x29>
		return r;
	if (r < 1)
  800f99:	85 c0                	test   %eax,%eax
  800f9b:	7e 06                	jle    800fa3 <getchar+0x24>
		return -E_EOF;
	return c;
  800f9d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fa1:	eb 05                	jmp    800fa8 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fa3:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800fa8:	c9                   	leave  
  800fa9:	c3                   	ret    

00800faa <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800faa:	55                   	push   %ebp
  800fab:	89 e5                	mov    %esp,%ebp
  800fad:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fb0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fb3:	50                   	push   %eax
  800fb4:	ff 75 08             	pushl  0x8(%ebp)
  800fb7:	e8 6f f4 ff ff       	call   80042b <fd_lookup>
  800fbc:	83 c4 10             	add    $0x10,%esp
  800fbf:	85 c0                	test   %eax,%eax
  800fc1:	78 11                	js     800fd4 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800fc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fc6:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fcc:	39 10                	cmp    %edx,(%eax)
  800fce:	0f 94 c0             	sete   %al
  800fd1:	0f b6 c0             	movzbl %al,%eax
}
  800fd4:	c9                   	leave  
  800fd5:	c3                   	ret    

00800fd6 <opencons>:

int
opencons(void)
{
  800fd6:	55                   	push   %ebp
  800fd7:	89 e5                	mov    %esp,%ebp
  800fd9:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fdc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fdf:	50                   	push   %eax
  800fe0:	e8 d2 f3 ff ff       	call   8003b7 <fd_alloc>
  800fe5:	83 c4 10             	add    $0x10,%esp
  800fe8:	85 c0                	test   %eax,%eax
  800fea:	78 3a                	js     801026 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fec:	83 ec 04             	sub    $0x4,%esp
  800fef:	68 07 04 00 00       	push   $0x407
  800ff4:	ff 75 f4             	pushl  -0xc(%ebp)
  800ff7:	6a 00                	push   $0x0
  800ff9:	e8 7b f1 ff ff       	call   800179 <sys_page_alloc>
  800ffe:	83 c4 10             	add    $0x10,%esp
  801001:	85 c0                	test   %eax,%eax
  801003:	78 21                	js     801026 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801005:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80100b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80100e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801010:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801013:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80101a:	83 ec 0c             	sub    $0xc,%esp
  80101d:	50                   	push   %eax
  80101e:	e8 6d f3 ff ff       	call   800390 <fd2num>
  801023:	83 c4 10             	add    $0x10,%esp
}
  801026:	c9                   	leave  
  801027:	c3                   	ret    

00801028 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801028:	55                   	push   %ebp
  801029:	89 e5                	mov    %esp,%ebp
  80102b:	56                   	push   %esi
  80102c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80102d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801030:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801036:	e8 00 f1 ff ff       	call   80013b <sys_getenvid>
  80103b:	83 ec 0c             	sub    $0xc,%esp
  80103e:	ff 75 0c             	pushl  0xc(%ebp)
  801041:	ff 75 08             	pushl  0x8(%ebp)
  801044:	56                   	push   %esi
  801045:	50                   	push   %eax
  801046:	68 10 20 80 00       	push   $0x802010
  80104b:	e8 b0 00 00 00       	call   801100 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801050:	83 c4 18             	add    $0x18,%esp
  801053:	53                   	push   %ebx
  801054:	ff 75 10             	pushl  0x10(%ebp)
  801057:	e8 53 00 00 00       	call   8010af <vcprintf>
	cprintf("\n");
  80105c:	c7 04 24 fd 1f 80 00 	movl   $0x801ffd,(%esp)
  801063:	e8 98 00 00 00       	call   801100 <cprintf>
  801068:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80106b:	cc                   	int3   
  80106c:	eb fd                	jmp    80106b <_panic+0x43>

0080106e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80106e:	55                   	push   %ebp
  80106f:	89 e5                	mov    %esp,%ebp
  801071:	53                   	push   %ebx
  801072:	83 ec 04             	sub    $0x4,%esp
  801075:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801078:	8b 13                	mov    (%ebx),%edx
  80107a:	8d 42 01             	lea    0x1(%edx),%eax
  80107d:	89 03                	mov    %eax,(%ebx)
  80107f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801082:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801086:	3d ff 00 00 00       	cmp    $0xff,%eax
  80108b:	75 1a                	jne    8010a7 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80108d:	83 ec 08             	sub    $0x8,%esp
  801090:	68 ff 00 00 00       	push   $0xff
  801095:	8d 43 08             	lea    0x8(%ebx),%eax
  801098:	50                   	push   %eax
  801099:	e8 1f f0 ff ff       	call   8000bd <sys_cputs>
		b->idx = 0;
  80109e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010a4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010a7:	ff 43 04             	incl   0x4(%ebx)
}
  8010aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010ad:	c9                   	leave  
  8010ae:	c3                   	ret    

008010af <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010af:	55                   	push   %ebp
  8010b0:	89 e5                	mov    %esp,%ebp
  8010b2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010b8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010bf:	00 00 00 
	b.cnt = 0;
  8010c2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010c9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010cc:	ff 75 0c             	pushl  0xc(%ebp)
  8010cf:	ff 75 08             	pushl  0x8(%ebp)
  8010d2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010d8:	50                   	push   %eax
  8010d9:	68 6e 10 80 00       	push   $0x80106e
  8010de:	e8 54 01 00 00       	call   801237 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010e3:	83 c4 08             	add    $0x8,%esp
  8010e6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010ec:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010f2:	50                   	push   %eax
  8010f3:	e8 c5 ef ff ff       	call   8000bd <sys_cputs>

	return b.cnt;
}
  8010f8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8010fe:	c9                   	leave  
  8010ff:	c3                   	ret    

00801100 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801100:	55                   	push   %ebp
  801101:	89 e5                	mov    %esp,%ebp
  801103:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801106:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801109:	50                   	push   %eax
  80110a:	ff 75 08             	pushl  0x8(%ebp)
  80110d:	e8 9d ff ff ff       	call   8010af <vcprintf>
	va_end(ap);

	return cnt;
}
  801112:	c9                   	leave  
  801113:	c3                   	ret    

00801114 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801114:	55                   	push   %ebp
  801115:	89 e5                	mov    %esp,%ebp
  801117:	57                   	push   %edi
  801118:	56                   	push   %esi
  801119:	53                   	push   %ebx
  80111a:	83 ec 1c             	sub    $0x1c,%esp
  80111d:	89 c6                	mov    %eax,%esi
  80111f:	89 d7                	mov    %edx,%edi
  801121:	8b 45 08             	mov    0x8(%ebp),%eax
  801124:	8b 55 0c             	mov    0xc(%ebp),%edx
  801127:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80112a:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80112d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801130:	bb 00 00 00 00       	mov    $0x0,%ebx
  801135:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801138:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80113b:	39 d3                	cmp    %edx,%ebx
  80113d:	72 11                	jb     801150 <printnum+0x3c>
  80113f:	39 45 10             	cmp    %eax,0x10(%ebp)
  801142:	76 0c                	jbe    801150 <printnum+0x3c>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801144:	8b 45 14             	mov    0x14(%ebp),%eax
  801147:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80114a:	85 db                	test   %ebx,%ebx
  80114c:	7f 37                	jg     801185 <printnum+0x71>
  80114e:	eb 44                	jmp    801194 <printnum+0x80>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801150:	83 ec 0c             	sub    $0xc,%esp
  801153:	ff 75 18             	pushl  0x18(%ebp)
  801156:	8b 45 14             	mov    0x14(%ebp),%eax
  801159:	48                   	dec    %eax
  80115a:	50                   	push   %eax
  80115b:	ff 75 10             	pushl  0x10(%ebp)
  80115e:	83 ec 08             	sub    $0x8,%esp
  801161:	ff 75 e4             	pushl  -0x1c(%ebp)
  801164:	ff 75 e0             	pushl  -0x20(%ebp)
  801167:	ff 75 dc             	pushl  -0x24(%ebp)
  80116a:	ff 75 d8             	pushl  -0x28(%ebp)
  80116d:	e8 12 0b 00 00       	call   801c84 <__udivdi3>
  801172:	83 c4 18             	add    $0x18,%esp
  801175:	52                   	push   %edx
  801176:	50                   	push   %eax
  801177:	89 fa                	mov    %edi,%edx
  801179:	89 f0                	mov    %esi,%eax
  80117b:	e8 94 ff ff ff       	call   801114 <printnum>
  801180:	83 c4 20             	add    $0x20,%esp
  801183:	eb 0f                	jmp    801194 <printnum+0x80>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801185:	83 ec 08             	sub    $0x8,%esp
  801188:	57                   	push   %edi
  801189:	ff 75 18             	pushl  0x18(%ebp)
  80118c:	ff d6                	call   *%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80118e:	83 c4 10             	add    $0x10,%esp
  801191:	4b                   	dec    %ebx
  801192:	75 f1                	jne    801185 <printnum+0x71>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801194:	83 ec 08             	sub    $0x8,%esp
  801197:	57                   	push   %edi
  801198:	83 ec 04             	sub    $0x4,%esp
  80119b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80119e:	ff 75 e0             	pushl  -0x20(%ebp)
  8011a1:	ff 75 dc             	pushl  -0x24(%ebp)
  8011a4:	ff 75 d8             	pushl  -0x28(%ebp)
  8011a7:	e8 e8 0b 00 00       	call   801d94 <__umoddi3>
  8011ac:	83 c4 14             	add    $0x14,%esp
  8011af:	0f be 80 33 20 80 00 	movsbl 0x802033(%eax),%eax
  8011b6:	50                   	push   %eax
  8011b7:	ff d6                	call   *%esi
}
  8011b9:	83 c4 10             	add    $0x10,%esp
  8011bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011bf:	5b                   	pop    %ebx
  8011c0:	5e                   	pop    %esi
  8011c1:	5f                   	pop    %edi
  8011c2:	5d                   	pop    %ebp
  8011c3:	c3                   	ret    

008011c4 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8011c4:	55                   	push   %ebp
  8011c5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011c7:	83 fa 01             	cmp    $0x1,%edx
  8011ca:	7e 0e                	jle    8011da <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8011cc:	8b 10                	mov    (%eax),%edx
  8011ce:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011d1:	89 08                	mov    %ecx,(%eax)
  8011d3:	8b 02                	mov    (%edx),%eax
  8011d5:	8b 52 04             	mov    0x4(%edx),%edx
  8011d8:	eb 22                	jmp    8011fc <getuint+0x38>
	else if (lflag)
  8011da:	85 d2                	test   %edx,%edx
  8011dc:	74 10                	je     8011ee <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8011de:	8b 10                	mov    (%eax),%edx
  8011e0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011e3:	89 08                	mov    %ecx,(%eax)
  8011e5:	8b 02                	mov    (%edx),%eax
  8011e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8011ec:	eb 0e                	jmp    8011fc <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8011ee:	8b 10                	mov    (%eax),%edx
  8011f0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011f3:	89 08                	mov    %ecx,(%eax)
  8011f5:	8b 02                	mov    (%edx),%eax
  8011f7:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8011fc:	5d                   	pop    %ebp
  8011fd:	c3                   	ret    

008011fe <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011fe:	55                   	push   %ebp
  8011ff:	89 e5                	mov    %esp,%ebp
  801201:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801204:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  801207:	8b 10                	mov    (%eax),%edx
  801209:	3b 50 04             	cmp    0x4(%eax),%edx
  80120c:	73 0a                	jae    801218 <sprintputch+0x1a>
		*b->buf++ = ch;
  80120e:	8d 4a 01             	lea    0x1(%edx),%ecx
  801211:	89 08                	mov    %ecx,(%eax)
  801213:	8b 45 08             	mov    0x8(%ebp),%eax
  801216:	88 02                	mov    %al,(%edx)
}
  801218:	5d                   	pop    %ebp
  801219:	c3                   	ret    

0080121a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80121a:	55                   	push   %ebp
  80121b:	89 e5                	mov    %esp,%ebp
  80121d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801220:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801223:	50                   	push   %eax
  801224:	ff 75 10             	pushl  0x10(%ebp)
  801227:	ff 75 0c             	pushl  0xc(%ebp)
  80122a:	ff 75 08             	pushl  0x8(%ebp)
  80122d:	e8 05 00 00 00       	call   801237 <vprintfmt>
	va_end(ap);
}
  801232:	83 c4 10             	add    $0x10,%esp
  801235:	c9                   	leave  
  801236:	c3                   	ret    

00801237 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801237:	55                   	push   %ebp
  801238:	89 e5                	mov    %esp,%ebp
  80123a:	57                   	push   %edi
  80123b:	56                   	push   %esi
  80123c:	53                   	push   %ebx
  80123d:	83 ec 2c             	sub    $0x2c,%esp
  801240:	8b 7d 08             	mov    0x8(%ebp),%edi
  801243:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801246:	eb 03                	jmp    80124b <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  801248:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  80124b:	8b 45 10             	mov    0x10(%ebp),%eax
  80124e:	8d 70 01             	lea    0x1(%eax),%esi
  801251:	0f b6 00             	movzbl (%eax),%eax
  801254:	83 f8 25             	cmp    $0x25,%eax
  801257:	74 25                	je     80127e <vprintfmt+0x47>
			if (ch == '\0')									//当然中间如果遇到'\0'，代表这个字符串的访问结束
  801259:	85 c0                	test   %eax,%eax
  80125b:	75 0d                	jne    80126a <vprintfmt+0x33>
  80125d:	e9 b5 03 00 00       	jmp    801617 <vprintfmt+0x3e0>
  801262:	85 c0                	test   %eax,%eax
  801264:	0f 84 ad 03 00 00    	je     801617 <vprintfmt+0x3e0>
				return;
			putch(ch, putdat);								//调用putch函数，把一个字符ch输出到putdat指针所指向的地址中所存放的值对应的地址处
  80126a:	83 ec 08             	sub    $0x8,%esp
  80126d:	53                   	push   %ebx
  80126e:	50                   	push   %eax
  80126f:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  801271:	46                   	inc    %esi
  801272:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  801276:	83 c4 10             	add    $0x10,%esp
  801279:	83 f8 25             	cmp    $0x25,%eax
  80127c:	75 e4                	jne    801262 <vprintfmt+0x2b>
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  80127e:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  801282:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801289:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801290:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  801297:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80129e:	eb 07                	jmp    8012a7 <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8012a0:	8b 75 10             	mov    0x10(%ebp),%esi

		// flag to pad on the right
		case '-':											//%后面的'-'代表要进行左对齐输出，右边填空格，如果省略代表右对齐
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
  8012a3:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8012a7:	8d 46 01             	lea    0x1(%esi),%eax
  8012aa:	89 45 10             	mov    %eax,0x10(%ebp)
  8012ad:	0f b6 16             	movzbl (%esi),%edx
  8012b0:	8a 06                	mov    (%esi),%al
  8012b2:	83 e8 23             	sub    $0x23,%eax
  8012b5:	3c 55                	cmp    $0x55,%al
  8012b7:	0f 87 03 03 00 00    	ja     8015c0 <vprintfmt+0x389>
  8012bd:	0f b6 c0             	movzbl %al,%eax
  8012c0:	ff 24 85 80 21 80 00 	jmp    *0x802180(,%eax,4)
  8012c7:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
			goto reswitch;									//处理下一个字符

		// flag to pad with 0's instead of spaces
		case '0':											//0--有0表示进行对齐输出时填0,如省略表示填入空格，并且如果为0，则一定是右对齐
			padc = '0';										//对其方式标志位变为0
  8012ca:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  8012ce:	eb d7                	jmp    8012a7 <vprintfmt+0x70>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
				precision = precision * 10 + ch - '0';
  8012d0:	8d 42 d0             	lea    -0x30(%edx),%eax
  8012d3:	89 c1                	mov    %eax,%ecx
  8012d5:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  8012d8:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8012dc:	8d 50 d0             	lea    -0x30(%eax),%edx
  8012df:	83 fa 09             	cmp    $0x9,%edx
  8012e2:	77 51                	ja     801335 <vprintfmt+0xfe>
  8012e4:	8b 75 10             	mov    0x10(%ebp),%esi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
  8012e7:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8012e8:	8d 14 89             	lea    (%ecx,%ecx,4),%edx
  8012eb:	01 d2                	add    %edx,%edx
  8012ed:	8d 4c 10 d0          	lea    -0x30(%eax,%edx,1),%ecx
				ch = *fmt;
  8012f1:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8012f4:	8d 50 d0             	lea    -0x30(%eax),%edx
  8012f7:	83 fa 09             	cmp    $0x9,%edx
  8012fa:	76 eb                	jbe    8012e7 <vprintfmt+0xb0>
  8012fc:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8012ff:	eb 37                	jmp    801338 <vprintfmt+0x101>
					break;
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
  801301:	8b 45 14             	mov    0x14(%ebp),%eax
  801304:	8d 50 04             	lea    0x4(%eax),%edx
  801307:	89 55 14             	mov    %edx,0x14(%ebp)
  80130a:	8b 00                	mov    (%eax),%eax
  80130c:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80130f:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
			goto process_precision;
  801312:	eb 24                	jmp    801338 <vprintfmt+0x101>
  801314:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801318:	79 07                	jns    801321 <vprintfmt+0xea>
  80131a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  801321:	8b 75 10             	mov    0x10(%ebp),%esi
  801324:	eb 81                	jmp    8012a7 <vprintfmt+0x70>
  801326:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  801329:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801330:	e9 72 ff ff ff       	jmp    8012a7 <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  801335:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:									//处理输出精度，把width字段赋值为刚刚计算出来的precision值，所以width应该是整数部分的有效数字位数
			if (width < 0)
  801338:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80133c:	0f 89 65 ff ff ff    	jns    8012a7 <vprintfmt+0x70>
				width = precision, precision = -1;
  801342:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801345:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801348:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80134f:	e9 53 ff ff ff       	jmp    8012a7 <vprintfmt+0x70>
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
  801354:	ff 45 d4             	incl   -0x2c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  801357:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
			goto reswitch;
  80135a:	e9 48 ff ff ff       	jmp    8012a7 <vprintfmt+0x70>

		// character
		case 'c':											//如果是'c'代表显示一个字符
			putch(va_arg(ap, int), putdat);					//调用输出一个字符到内存的函数putch
  80135f:	8b 45 14             	mov    0x14(%ebp),%eax
  801362:	8d 50 04             	lea    0x4(%eax),%edx
  801365:	89 55 14             	mov    %edx,0x14(%ebp)
  801368:	83 ec 08             	sub    $0x8,%esp
  80136b:	53                   	push   %ebx
  80136c:	ff 30                	pushl  (%eax)
  80136e:	ff d7                	call   *%edi
			break;
  801370:	83 c4 10             	add    $0x10,%esp
  801373:	e9 d3 fe ff ff       	jmp    80124b <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801378:	8b 45 14             	mov    0x14(%ebp),%eax
  80137b:	8d 50 04             	lea    0x4(%eax),%edx
  80137e:	89 55 14             	mov    %edx,0x14(%ebp)
  801381:	8b 00                	mov    (%eax),%eax
  801383:	85 c0                	test   %eax,%eax
  801385:	79 02                	jns    801389 <vprintfmt+0x152>
  801387:	f7 d8                	neg    %eax
  801389:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80138b:	83 f8 0f             	cmp    $0xf,%eax
  80138e:	7f 0b                	jg     80139b <vprintfmt+0x164>
  801390:	8b 04 85 e0 22 80 00 	mov    0x8022e0(,%eax,4),%eax
  801397:	85 c0                	test   %eax,%eax
  801399:	75 15                	jne    8013b0 <vprintfmt+0x179>
				printfmt(putch, putdat, "error %d", err);
  80139b:	52                   	push   %edx
  80139c:	68 4b 20 80 00       	push   $0x80204b
  8013a1:	53                   	push   %ebx
  8013a2:	57                   	push   %edi
  8013a3:	e8 72 fe ff ff       	call   80121a <printfmt>
  8013a8:	83 c4 10             	add    $0x10,%esp
  8013ab:	e9 9b fe ff ff       	jmp    80124b <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  8013b0:	50                   	push   %eax
  8013b1:	68 cb 1f 80 00       	push   $0x801fcb
  8013b6:	53                   	push   %ebx
  8013b7:	57                   	push   %edi
  8013b8:	e8 5d fe ff ff       	call   80121a <printfmt>
  8013bd:	83 c4 10             	add    $0x10,%esp
  8013c0:	e9 86 fe ff ff       	jmp    80124b <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8013c8:	8d 50 04             	lea    0x4(%eax),%edx
  8013cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8013ce:	8b 00                	mov    (%eax),%eax
  8013d0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8013d3:	85 c0                	test   %eax,%eax
  8013d5:	75 07                	jne    8013de <vprintfmt+0x1a7>
				p = "(null)";
  8013d7:	c7 45 d4 44 20 80 00 	movl   $0x802044,-0x2c(%ebp)
			if (width > 0 && padc != '-')
  8013de:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8013e1:	85 f6                	test   %esi,%esi
  8013e3:	0f 8e fb 01 00 00    	jle    8015e4 <vprintfmt+0x3ad>
  8013e9:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  8013ed:	0f 84 09 02 00 00    	je     8015fc <vprintfmt+0x3c5>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013f3:	83 ec 08             	sub    $0x8,%esp
  8013f6:	ff 75 d0             	pushl  -0x30(%ebp)
  8013f9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013fc:	e8 ad 02 00 00       	call   8016ae <strnlen>
  801401:	89 f1                	mov    %esi,%ecx
  801403:	29 c1                	sub    %eax,%ecx
  801405:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  801408:	83 c4 10             	add    $0x10,%esp
  80140b:	85 c9                	test   %ecx,%ecx
  80140d:	0f 8e d1 01 00 00    	jle    8015e4 <vprintfmt+0x3ad>
					putch(padc, putdat);
  801413:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  801417:	83 ec 08             	sub    $0x8,%esp
  80141a:	53                   	push   %ebx
  80141b:	56                   	push   %esi
  80141c:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80141e:	83 c4 10             	add    $0x10,%esp
  801421:	ff 4d e4             	decl   -0x1c(%ebp)
  801424:	75 f1                	jne    801417 <vprintfmt+0x1e0>
  801426:	e9 b9 01 00 00       	jmp    8015e4 <vprintfmt+0x3ad>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80142b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80142f:	74 19                	je     80144a <vprintfmt+0x213>
  801431:	0f be c0             	movsbl %al,%eax
  801434:	83 e8 20             	sub    $0x20,%eax
  801437:	83 f8 5e             	cmp    $0x5e,%eax
  80143a:	76 0e                	jbe    80144a <vprintfmt+0x213>
					putch('?', putdat);
  80143c:	83 ec 08             	sub    $0x8,%esp
  80143f:	53                   	push   %ebx
  801440:	6a 3f                	push   $0x3f
  801442:	ff 55 08             	call   *0x8(%ebp)
  801445:	83 c4 10             	add    $0x10,%esp
  801448:	eb 0b                	jmp    801455 <vprintfmt+0x21e>
				else
					putch(ch, putdat);
  80144a:	83 ec 08             	sub    $0x8,%esp
  80144d:	53                   	push   %ebx
  80144e:	52                   	push   %edx
  80144f:	ff 55 08             	call   *0x8(%ebp)
  801452:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801455:	ff 4d e4             	decl   -0x1c(%ebp)
  801458:	46                   	inc    %esi
  801459:	8a 46 ff             	mov    -0x1(%esi),%al
  80145c:	0f be d0             	movsbl %al,%edx
  80145f:	85 d2                	test   %edx,%edx
  801461:	75 1c                	jne    80147f <vprintfmt+0x248>
  801463:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801466:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80146a:	7f 1f                	jg     80148b <vprintfmt+0x254>
  80146c:	e9 da fd ff ff       	jmp    80124b <vprintfmt+0x14>
  801471:	89 7d 08             	mov    %edi,0x8(%ebp)
  801474:	8b 7d d0             	mov    -0x30(%ebp),%edi
  801477:	eb 06                	jmp    80147f <vprintfmt+0x248>
  801479:	89 7d 08             	mov    %edi,0x8(%ebp)
  80147c:	8b 7d d0             	mov    -0x30(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80147f:	85 ff                	test   %edi,%edi
  801481:	78 a8                	js     80142b <vprintfmt+0x1f4>
  801483:	4f                   	dec    %edi
  801484:	79 a5                	jns    80142b <vprintfmt+0x1f4>
  801486:	8b 7d 08             	mov    0x8(%ebp),%edi
  801489:	eb db                	jmp    801466 <vprintfmt+0x22f>
  80148b:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80148e:	83 ec 08             	sub    $0x8,%esp
  801491:	53                   	push   %ebx
  801492:	6a 20                	push   $0x20
  801494:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801496:	4e                   	dec    %esi
  801497:	83 c4 10             	add    $0x10,%esp
  80149a:	85 f6                	test   %esi,%esi
  80149c:	7f f0                	jg     80148e <vprintfmt+0x257>
  80149e:	e9 a8 fd ff ff       	jmp    80124b <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014a3:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  8014a7:	7e 16                	jle    8014bf <vprintfmt+0x288>
		return va_arg(*ap, long long);
  8014a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8014ac:	8d 50 08             	lea    0x8(%eax),%edx
  8014af:	89 55 14             	mov    %edx,0x14(%ebp)
  8014b2:	8b 50 04             	mov    0x4(%eax),%edx
  8014b5:	8b 00                	mov    (%eax),%eax
  8014b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014ba:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8014bd:	eb 34                	jmp    8014f3 <vprintfmt+0x2bc>
	else if (lflag)
  8014bf:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8014c3:	74 18                	je     8014dd <vprintfmt+0x2a6>
		return va_arg(*ap, long);
  8014c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8014c8:	8d 50 04             	lea    0x4(%eax),%edx
  8014cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8014ce:	8b 30                	mov    (%eax),%esi
  8014d0:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8014d3:	89 f0                	mov    %esi,%eax
  8014d5:	c1 f8 1f             	sar    $0x1f,%eax
  8014d8:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8014db:	eb 16                	jmp    8014f3 <vprintfmt+0x2bc>
	else
		return va_arg(*ap, int);
  8014dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8014e0:	8d 50 04             	lea    0x4(%eax),%edx
  8014e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8014e6:	8b 30                	mov    (%eax),%esi
  8014e8:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8014eb:	89 f0                	mov    %esi,%eax
  8014ed:	c1 f8 1f             	sar    $0x1f,%eax
  8014f0:	89 45 dc             	mov    %eax,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8014f3:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8014f6:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
  8014f9:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8014fd:	0f 89 8a 00 00 00    	jns    80158d <vprintfmt+0x356>
				putch('-', putdat);
  801503:	83 ec 08             	sub    $0x8,%esp
  801506:	53                   	push   %ebx
  801507:	6a 2d                	push   $0x2d
  801509:	ff d7                	call   *%edi
				num = -(long long) num;
  80150b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80150e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801511:	f7 d8                	neg    %eax
  801513:	83 d2 00             	adc    $0x0,%edx
  801516:	f7 da                	neg    %edx
  801518:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80151b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801520:	eb 70                	jmp    801592 <vprintfmt+0x35b>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801522:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  801525:	8d 45 14             	lea    0x14(%ebp),%eax
  801528:	e8 97 fc ff ff       	call   8011c4 <getuint>
			base = 10;
  80152d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801532:	eb 5e                	jmp    801592 <vprintfmt+0x35b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  801534:	83 ec 08             	sub    $0x8,%esp
  801537:	53                   	push   %ebx
  801538:	6a 30                	push   $0x30
  80153a:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  80153c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80153f:	8d 45 14             	lea    0x14(%ebp),%eax
  801542:	e8 7d fc ff ff       	call   8011c4 <getuint>
			base = 8;
			goto number;
  801547:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  80154a:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80154f:	eb 41                	jmp    801592 <vprintfmt+0x35b>
		// pointer
		case 'p':
			putch('0', putdat);
  801551:	83 ec 08             	sub    $0x8,%esp
  801554:	53                   	push   %ebx
  801555:	6a 30                	push   $0x30
  801557:	ff d7                	call   *%edi
			putch('x', putdat);
  801559:	83 c4 08             	add    $0x8,%esp
  80155c:	53                   	push   %ebx
  80155d:	6a 78                	push   $0x78
  80155f:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801561:	8b 45 14             	mov    0x14(%ebp),%eax
  801564:	8d 50 04             	lea    0x4(%eax),%edx
  801567:	89 55 14             	mov    %edx,0x14(%ebp)
			goto number;
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80156a:	8b 00                	mov    (%eax),%eax
  80156c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801571:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801574:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801579:	eb 17                	jmp    801592 <vprintfmt+0x35b>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80157b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80157e:	8d 45 14             	lea    0x14(%ebp),%eax
  801581:	e8 3e fc ff ff       	call   8011c4 <getuint>
			base = 16;
  801586:	b9 10 00 00 00       	mov    $0x10,%ecx
  80158b:	eb 05                	jmp    801592 <vprintfmt+0x35b>
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80158d:	b9 0a 00 00 00       	mov    $0xa,%ecx
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  801592:	83 ec 0c             	sub    $0xc,%esp
  801595:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  801599:	56                   	push   %esi
  80159a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80159d:	51                   	push   %ecx
  80159e:	52                   	push   %edx
  80159f:	50                   	push   %eax
  8015a0:	89 da                	mov    %ebx,%edx
  8015a2:	89 f8                	mov    %edi,%eax
  8015a4:	e8 6b fb ff ff       	call   801114 <printnum>
			break;
  8015a9:	83 c4 20             	add    $0x20,%esp
  8015ac:	e9 9a fc ff ff       	jmp    80124b <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8015b1:	83 ec 08             	sub    $0x8,%esp
  8015b4:	53                   	push   %ebx
  8015b5:	52                   	push   %edx
  8015b6:	ff d7                	call   *%edi
			break;
  8015b8:	83 c4 10             	add    $0x10,%esp
  8015bb:	e9 8b fc ff ff       	jmp    80124b <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8015c0:	83 ec 08             	sub    $0x8,%esp
  8015c3:	53                   	push   %ebx
  8015c4:	6a 25                	push   $0x25
  8015c6:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8015c8:	83 c4 10             	add    $0x10,%esp
  8015cb:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8015cf:	0f 84 73 fc ff ff    	je     801248 <vprintfmt+0x11>
  8015d5:	4e                   	dec    %esi
  8015d6:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8015da:	75 f9                	jne    8015d5 <vprintfmt+0x39e>
  8015dc:	89 75 10             	mov    %esi,0x10(%ebp)
  8015df:	e9 67 fc ff ff       	jmp    80124b <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8015e4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8015e7:	8d 70 01             	lea    0x1(%eax),%esi
  8015ea:	8a 00                	mov    (%eax),%al
  8015ec:	0f be d0             	movsbl %al,%edx
  8015ef:	85 d2                	test   %edx,%edx
  8015f1:	0f 85 7a fe ff ff    	jne    801471 <vprintfmt+0x23a>
  8015f7:	e9 4f fc ff ff       	jmp    80124b <vprintfmt+0x14>
  8015fc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8015ff:	8d 70 01             	lea    0x1(%eax),%esi
  801602:	8a 00                	mov    (%eax),%al
  801604:	0f be d0             	movsbl %al,%edx
  801607:	85 d2                	test   %edx,%edx
  801609:	0f 85 6a fe ff ff    	jne    801479 <vprintfmt+0x242>
  80160f:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801612:	e9 77 fe ff ff       	jmp    80148e <vprintfmt+0x257>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  801617:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80161a:	5b                   	pop    %ebx
  80161b:	5e                   	pop    %esi
  80161c:	5f                   	pop    %edi
  80161d:	5d                   	pop    %ebp
  80161e:	c3                   	ret    

0080161f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80161f:	55                   	push   %ebp
  801620:	89 e5                	mov    %esp,%ebp
  801622:	83 ec 18             	sub    $0x18,%esp
  801625:	8b 45 08             	mov    0x8(%ebp),%eax
  801628:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80162b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80162e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801632:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801635:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80163c:	85 c0                	test   %eax,%eax
  80163e:	74 26                	je     801666 <vsnprintf+0x47>
  801640:	85 d2                	test   %edx,%edx
  801642:	7e 29                	jle    80166d <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801644:	ff 75 14             	pushl  0x14(%ebp)
  801647:	ff 75 10             	pushl  0x10(%ebp)
  80164a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80164d:	50                   	push   %eax
  80164e:	68 fe 11 80 00       	push   $0x8011fe
  801653:	e8 df fb ff ff       	call   801237 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801658:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80165b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80165e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801661:	83 c4 10             	add    $0x10,%esp
  801664:	eb 0c                	jmp    801672 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801666:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80166b:	eb 05                	jmp    801672 <vsnprintf+0x53>
  80166d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801672:	c9                   	leave  
  801673:	c3                   	ret    

00801674 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801674:	55                   	push   %ebp
  801675:	89 e5                	mov    %esp,%ebp
  801677:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80167a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80167d:	50                   	push   %eax
  80167e:	ff 75 10             	pushl  0x10(%ebp)
  801681:	ff 75 0c             	pushl  0xc(%ebp)
  801684:	ff 75 08             	pushl  0x8(%ebp)
  801687:	e8 93 ff ff ff       	call   80161f <vsnprintf>
	va_end(ap);

	return rc;
}
  80168c:	c9                   	leave  
  80168d:	c3                   	ret    

0080168e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80168e:	55                   	push   %ebp
  80168f:	89 e5                	mov    %esp,%ebp
  801691:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801694:	80 3a 00             	cmpb   $0x0,(%edx)
  801697:	74 0e                	je     8016a7 <strlen+0x19>
  801699:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80169e:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80169f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016a3:	75 f9                	jne    80169e <strlen+0x10>
  8016a5:	eb 05                	jmp    8016ac <strlen+0x1e>
  8016a7:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8016ac:	5d                   	pop    %ebp
  8016ad:	c3                   	ret    

008016ae <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016ae:	55                   	push   %ebp
  8016af:	89 e5                	mov    %esp,%ebp
  8016b1:	53                   	push   %ebx
  8016b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8016b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016b8:	85 c9                	test   %ecx,%ecx
  8016ba:	74 1a                	je     8016d6 <strnlen+0x28>
  8016bc:	80 3b 00             	cmpb   $0x0,(%ebx)
  8016bf:	74 1c                	je     8016dd <strnlen+0x2f>
  8016c1:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8016c6:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016c8:	39 ca                	cmp    %ecx,%edx
  8016ca:	74 16                	je     8016e2 <strnlen+0x34>
  8016cc:	42                   	inc    %edx
  8016cd:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8016d2:	75 f2                	jne    8016c6 <strnlen+0x18>
  8016d4:	eb 0c                	jmp    8016e2 <strnlen+0x34>
  8016d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8016db:	eb 05                	jmp    8016e2 <strnlen+0x34>
  8016dd:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8016e2:	5b                   	pop    %ebx
  8016e3:	5d                   	pop    %ebp
  8016e4:	c3                   	ret    

008016e5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016e5:	55                   	push   %ebp
  8016e6:	89 e5                	mov    %esp,%ebp
  8016e8:	53                   	push   %ebx
  8016e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016ef:	89 c2                	mov    %eax,%edx
  8016f1:	42                   	inc    %edx
  8016f2:	41                   	inc    %ecx
  8016f3:	8a 59 ff             	mov    -0x1(%ecx),%bl
  8016f6:	88 5a ff             	mov    %bl,-0x1(%edx)
  8016f9:	84 db                	test   %bl,%bl
  8016fb:	75 f4                	jne    8016f1 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8016fd:	5b                   	pop    %ebx
  8016fe:	5d                   	pop    %ebp
  8016ff:	c3                   	ret    

00801700 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801700:	55                   	push   %ebp
  801701:	89 e5                	mov    %esp,%ebp
  801703:	53                   	push   %ebx
  801704:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801707:	53                   	push   %ebx
  801708:	e8 81 ff ff ff       	call   80168e <strlen>
  80170d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801710:	ff 75 0c             	pushl  0xc(%ebp)
  801713:	01 d8                	add    %ebx,%eax
  801715:	50                   	push   %eax
  801716:	e8 ca ff ff ff       	call   8016e5 <strcpy>
	return dst;
}
  80171b:	89 d8                	mov    %ebx,%eax
  80171d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801720:	c9                   	leave  
  801721:	c3                   	ret    

00801722 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801722:	55                   	push   %ebp
  801723:	89 e5                	mov    %esp,%ebp
  801725:	56                   	push   %esi
  801726:	53                   	push   %ebx
  801727:	8b 75 08             	mov    0x8(%ebp),%esi
  80172a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80172d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801730:	85 db                	test   %ebx,%ebx
  801732:	74 14                	je     801748 <strncpy+0x26>
  801734:	01 f3                	add    %esi,%ebx
  801736:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  801738:	41                   	inc    %ecx
  801739:	8a 02                	mov    (%edx),%al
  80173b:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80173e:	80 3a 01             	cmpb   $0x1,(%edx)
  801741:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801744:	39 cb                	cmp    %ecx,%ebx
  801746:	75 f0                	jne    801738 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801748:	89 f0                	mov    %esi,%eax
  80174a:	5b                   	pop    %ebx
  80174b:	5e                   	pop    %esi
  80174c:	5d                   	pop    %ebp
  80174d:	c3                   	ret    

0080174e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80174e:	55                   	push   %ebp
  80174f:	89 e5                	mov    %esp,%ebp
  801751:	53                   	push   %ebx
  801752:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801755:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801758:	85 c0                	test   %eax,%eax
  80175a:	74 30                	je     80178c <strlcpy+0x3e>
		while (--size > 0 && *src != '\0')
  80175c:	48                   	dec    %eax
  80175d:	74 20                	je     80177f <strlcpy+0x31>
  80175f:	8a 0b                	mov    (%ebx),%cl
  801761:	84 c9                	test   %cl,%cl
  801763:	74 1f                	je     801784 <strlcpy+0x36>
  801765:	8d 53 01             	lea    0x1(%ebx),%edx
  801768:	01 c3                	add    %eax,%ebx
  80176a:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
  80176d:	40                   	inc    %eax
  80176e:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801771:	39 da                	cmp    %ebx,%edx
  801773:	74 12                	je     801787 <strlcpy+0x39>
  801775:	42                   	inc    %edx
  801776:	8a 4a ff             	mov    -0x1(%edx),%cl
  801779:	84 c9                	test   %cl,%cl
  80177b:	75 f0                	jne    80176d <strlcpy+0x1f>
  80177d:	eb 08                	jmp    801787 <strlcpy+0x39>
  80177f:	8b 45 08             	mov    0x8(%ebp),%eax
  801782:	eb 03                	jmp    801787 <strlcpy+0x39>
  801784:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
		*dst = '\0';
  801787:	c6 00 00             	movb   $0x0,(%eax)
  80178a:	eb 03                	jmp    80178f <strlcpy+0x41>
  80178c:	8b 45 08             	mov    0x8(%ebp),%eax
	}
	return dst - dst_in;
  80178f:	2b 45 08             	sub    0x8(%ebp),%eax
}
  801792:	5b                   	pop    %ebx
  801793:	5d                   	pop    %ebp
  801794:	c3                   	ret    

00801795 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801795:	55                   	push   %ebp
  801796:	89 e5                	mov    %esp,%ebp
  801798:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80179b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80179e:	8a 01                	mov    (%ecx),%al
  8017a0:	84 c0                	test   %al,%al
  8017a2:	74 10                	je     8017b4 <strcmp+0x1f>
  8017a4:	3a 02                	cmp    (%edx),%al
  8017a6:	75 0c                	jne    8017b4 <strcmp+0x1f>
		p++, q++;
  8017a8:	41                   	inc    %ecx
  8017a9:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8017aa:	8a 01                	mov    (%ecx),%al
  8017ac:	84 c0                	test   %al,%al
  8017ae:	74 04                	je     8017b4 <strcmp+0x1f>
  8017b0:	3a 02                	cmp    (%edx),%al
  8017b2:	74 f4                	je     8017a8 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017b4:	0f b6 c0             	movzbl %al,%eax
  8017b7:	0f b6 12             	movzbl (%edx),%edx
  8017ba:	29 d0                	sub    %edx,%eax
}
  8017bc:	5d                   	pop    %ebp
  8017bd:	c3                   	ret    

008017be <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017be:	55                   	push   %ebp
  8017bf:	89 e5                	mov    %esp,%ebp
  8017c1:	56                   	push   %esi
  8017c2:	53                   	push   %ebx
  8017c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8017c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017c9:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  8017cc:	85 f6                	test   %esi,%esi
  8017ce:	74 23                	je     8017f3 <strncmp+0x35>
  8017d0:	8a 03                	mov    (%ebx),%al
  8017d2:	84 c0                	test   %al,%al
  8017d4:	74 2b                	je     801801 <strncmp+0x43>
  8017d6:	3a 02                	cmp    (%edx),%al
  8017d8:	75 27                	jne    801801 <strncmp+0x43>
  8017da:	8d 43 01             	lea    0x1(%ebx),%eax
  8017dd:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  8017df:	89 c3                	mov    %eax,%ebx
  8017e1:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017e2:	39 c6                	cmp    %eax,%esi
  8017e4:	74 14                	je     8017fa <strncmp+0x3c>
  8017e6:	8a 08                	mov    (%eax),%cl
  8017e8:	84 c9                	test   %cl,%cl
  8017ea:	74 15                	je     801801 <strncmp+0x43>
  8017ec:	40                   	inc    %eax
  8017ed:	3a 0a                	cmp    (%edx),%cl
  8017ef:	74 ee                	je     8017df <strncmp+0x21>
  8017f1:	eb 0e                	jmp    801801 <strncmp+0x43>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8017f8:	eb 0f                	jmp    801809 <strncmp+0x4b>
  8017fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8017ff:	eb 08                	jmp    801809 <strncmp+0x4b>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801801:	0f b6 03             	movzbl (%ebx),%eax
  801804:	0f b6 12             	movzbl (%edx),%edx
  801807:	29 d0                	sub    %edx,%eax
}
  801809:	5b                   	pop    %ebx
  80180a:	5e                   	pop    %esi
  80180b:	5d                   	pop    %ebp
  80180c:	c3                   	ret    

0080180d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80180d:	55                   	push   %ebp
  80180e:	89 e5                	mov    %esp,%ebp
  801810:	53                   	push   %ebx
  801811:	8b 45 08             	mov    0x8(%ebp),%eax
  801814:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  801817:	8a 10                	mov    (%eax),%dl
  801819:	84 d2                	test   %dl,%dl
  80181b:	74 1a                	je     801837 <strchr+0x2a>
  80181d:	88 d9                	mov    %bl,%cl
		if (*s == c)
  80181f:	38 d3                	cmp    %dl,%bl
  801821:	75 06                	jne    801829 <strchr+0x1c>
  801823:	eb 17                	jmp    80183c <strchr+0x2f>
  801825:	38 ca                	cmp    %cl,%dl
  801827:	74 13                	je     80183c <strchr+0x2f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801829:	40                   	inc    %eax
  80182a:	8a 10                	mov    (%eax),%dl
  80182c:	84 d2                	test   %dl,%dl
  80182e:	75 f5                	jne    801825 <strchr+0x18>
		if (*s == c)
			return (char *) s;
	return 0;
  801830:	b8 00 00 00 00       	mov    $0x0,%eax
  801835:	eb 05                	jmp    80183c <strchr+0x2f>
  801837:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80183c:	5b                   	pop    %ebx
  80183d:	5d                   	pop    %ebp
  80183e:	c3                   	ret    

0080183f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80183f:	55                   	push   %ebp
  801840:	89 e5                	mov    %esp,%ebp
  801842:	53                   	push   %ebx
  801843:	8b 45 08             	mov    0x8(%ebp),%eax
  801846:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  801849:	8a 10                	mov    (%eax),%dl
  80184b:	84 d2                	test   %dl,%dl
  80184d:	74 13                	je     801862 <strfind+0x23>
  80184f:	88 d9                	mov    %bl,%cl
		if (*s == c)
  801851:	38 d3                	cmp    %dl,%bl
  801853:	75 06                	jne    80185b <strfind+0x1c>
  801855:	eb 0b                	jmp    801862 <strfind+0x23>
  801857:	38 ca                	cmp    %cl,%dl
  801859:	74 07                	je     801862 <strfind+0x23>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80185b:	40                   	inc    %eax
  80185c:	8a 10                	mov    (%eax),%dl
  80185e:	84 d2                	test   %dl,%dl
  801860:	75 f5                	jne    801857 <strfind+0x18>
		if (*s == c)
			break;
	return (char *) s;
}
  801862:	5b                   	pop    %ebx
  801863:	5d                   	pop    %ebp
  801864:	c3                   	ret    

00801865 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801865:	55                   	push   %ebp
  801866:	89 e5                	mov    %esp,%ebp
  801868:	57                   	push   %edi
  801869:	56                   	push   %esi
  80186a:	53                   	push   %ebx
  80186b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80186e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801871:	85 c9                	test   %ecx,%ecx
  801873:	74 36                	je     8018ab <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801875:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80187b:	75 28                	jne    8018a5 <memset+0x40>
  80187d:	f6 c1 03             	test   $0x3,%cl
  801880:	75 23                	jne    8018a5 <memset+0x40>
		c &= 0xFF;
  801882:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801886:	89 d3                	mov    %edx,%ebx
  801888:	c1 e3 08             	shl    $0x8,%ebx
  80188b:	89 d6                	mov    %edx,%esi
  80188d:	c1 e6 18             	shl    $0x18,%esi
  801890:	89 d0                	mov    %edx,%eax
  801892:	c1 e0 10             	shl    $0x10,%eax
  801895:	09 f0                	or     %esi,%eax
  801897:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801899:	89 d8                	mov    %ebx,%eax
  80189b:	09 d0                	or     %edx,%eax
  80189d:	c1 e9 02             	shr    $0x2,%ecx
  8018a0:	fc                   	cld    
  8018a1:	f3 ab                	rep stos %eax,%es:(%edi)
  8018a3:	eb 06                	jmp    8018ab <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8018a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018a8:	fc                   	cld    
  8018a9:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8018ab:	89 f8                	mov    %edi,%eax
  8018ad:	5b                   	pop    %ebx
  8018ae:	5e                   	pop    %esi
  8018af:	5f                   	pop    %edi
  8018b0:	5d                   	pop    %ebp
  8018b1:	c3                   	ret    

008018b2 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8018b2:	55                   	push   %ebp
  8018b3:	89 e5                	mov    %esp,%ebp
  8018b5:	57                   	push   %edi
  8018b6:	56                   	push   %esi
  8018b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ba:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018bd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8018c0:	39 c6                	cmp    %eax,%esi
  8018c2:	73 33                	jae    8018f7 <memmove+0x45>
  8018c4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8018c7:	39 d0                	cmp    %edx,%eax
  8018c9:	73 2c                	jae    8018f7 <memmove+0x45>
		s += n;
		d += n;
  8018cb:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018ce:	89 d6                	mov    %edx,%esi
  8018d0:	09 fe                	or     %edi,%esi
  8018d2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018d8:	75 13                	jne    8018ed <memmove+0x3b>
  8018da:	f6 c1 03             	test   $0x3,%cl
  8018dd:	75 0e                	jne    8018ed <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8018df:	83 ef 04             	sub    $0x4,%edi
  8018e2:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018e5:	c1 e9 02             	shr    $0x2,%ecx
  8018e8:	fd                   	std    
  8018e9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018eb:	eb 07                	jmp    8018f4 <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8018ed:	4f                   	dec    %edi
  8018ee:	8d 72 ff             	lea    -0x1(%edx),%esi
  8018f1:	fd                   	std    
  8018f2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018f4:	fc                   	cld    
  8018f5:	eb 1d                	jmp    801914 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018f7:	89 f2                	mov    %esi,%edx
  8018f9:	09 c2                	or     %eax,%edx
  8018fb:	f6 c2 03             	test   $0x3,%dl
  8018fe:	75 0f                	jne    80190f <memmove+0x5d>
  801900:	f6 c1 03             	test   $0x3,%cl
  801903:	75 0a                	jne    80190f <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
  801905:	c1 e9 02             	shr    $0x2,%ecx
  801908:	89 c7                	mov    %eax,%edi
  80190a:	fc                   	cld    
  80190b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80190d:	eb 05                	jmp    801914 <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80190f:	89 c7                	mov    %eax,%edi
  801911:	fc                   	cld    
  801912:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801914:	5e                   	pop    %esi
  801915:	5f                   	pop    %edi
  801916:	5d                   	pop    %ebp
  801917:	c3                   	ret    

00801918 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801918:	55                   	push   %ebp
  801919:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80191b:	ff 75 10             	pushl  0x10(%ebp)
  80191e:	ff 75 0c             	pushl  0xc(%ebp)
  801921:	ff 75 08             	pushl  0x8(%ebp)
  801924:	e8 89 ff ff ff       	call   8018b2 <memmove>
}
  801929:	c9                   	leave  
  80192a:	c3                   	ret    

0080192b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80192b:	55                   	push   %ebp
  80192c:	89 e5                	mov    %esp,%ebp
  80192e:	57                   	push   %edi
  80192f:	56                   	push   %esi
  801930:	53                   	push   %ebx
  801931:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801934:	8b 75 0c             	mov    0xc(%ebp),%esi
  801937:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80193a:	85 c0                	test   %eax,%eax
  80193c:	74 33                	je     801971 <memcmp+0x46>
  80193e:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  801941:	8a 13                	mov    (%ebx),%dl
  801943:	8a 0e                	mov    (%esi),%cl
  801945:	38 ca                	cmp    %cl,%dl
  801947:	75 13                	jne    80195c <memcmp+0x31>
  801949:	b8 00 00 00 00       	mov    $0x0,%eax
  80194e:	eb 16                	jmp    801966 <memcmp+0x3b>
  801950:	8a 54 03 01          	mov    0x1(%ebx,%eax,1),%dl
  801954:	40                   	inc    %eax
  801955:	8a 0c 06             	mov    (%esi,%eax,1),%cl
  801958:	38 ca                	cmp    %cl,%dl
  80195a:	74 0a                	je     801966 <memcmp+0x3b>
			return (int) *s1 - (int) *s2;
  80195c:	0f b6 c2             	movzbl %dl,%eax
  80195f:	0f b6 c9             	movzbl %cl,%ecx
  801962:	29 c8                	sub    %ecx,%eax
  801964:	eb 10                	jmp    801976 <memcmp+0x4b>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801966:	39 f8                	cmp    %edi,%eax
  801968:	75 e6                	jne    801950 <memcmp+0x25>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80196a:	b8 00 00 00 00       	mov    $0x0,%eax
  80196f:	eb 05                	jmp    801976 <memcmp+0x4b>
  801971:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801976:	5b                   	pop    %ebx
  801977:	5e                   	pop    %esi
  801978:	5f                   	pop    %edi
  801979:	5d                   	pop    %ebp
  80197a:	c3                   	ret    

0080197b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80197b:	55                   	push   %ebp
  80197c:	89 e5                	mov    %esp,%ebp
  80197e:	53                   	push   %ebx
  80197f:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  801982:	89 d0                	mov    %edx,%eax
  801984:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  801987:	39 c2                	cmp    %eax,%edx
  801989:	73 1b                	jae    8019a6 <memfind+0x2b>
		if (*(const unsigned char *) s == (unsigned char) c)
  80198b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  80198f:	0f b6 0a             	movzbl (%edx),%ecx
  801992:	39 d9                	cmp    %ebx,%ecx
  801994:	75 09                	jne    80199f <memfind+0x24>
  801996:	eb 12                	jmp    8019aa <memfind+0x2f>
  801998:	0f b6 0a             	movzbl (%edx),%ecx
  80199b:	39 d9                	cmp    %ebx,%ecx
  80199d:	74 0f                	je     8019ae <memfind+0x33>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80199f:	42                   	inc    %edx
  8019a0:	39 d0                	cmp    %edx,%eax
  8019a2:	75 f4                	jne    801998 <memfind+0x1d>
  8019a4:	eb 0a                	jmp    8019b0 <memfind+0x35>
  8019a6:	89 d0                	mov    %edx,%eax
  8019a8:	eb 06                	jmp    8019b0 <memfind+0x35>
		if (*(const unsigned char *) s == (unsigned char) c)
  8019aa:	89 d0                	mov    %edx,%eax
  8019ac:	eb 02                	jmp    8019b0 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8019ae:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8019b0:	5b                   	pop    %ebx
  8019b1:	5d                   	pop    %ebp
  8019b2:	c3                   	ret    

008019b3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8019b3:	55                   	push   %ebp
  8019b4:	89 e5                	mov    %esp,%ebp
  8019b6:	57                   	push   %edi
  8019b7:	56                   	push   %esi
  8019b8:	53                   	push   %ebx
  8019b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8019bc:	eb 01                	jmp    8019bf <strtol+0xc>
		s++;
  8019be:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8019bf:	8a 01                	mov    (%ecx),%al
  8019c1:	3c 20                	cmp    $0x20,%al
  8019c3:	74 f9                	je     8019be <strtol+0xb>
  8019c5:	3c 09                	cmp    $0x9,%al
  8019c7:	74 f5                	je     8019be <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  8019c9:	3c 2b                	cmp    $0x2b,%al
  8019cb:	75 08                	jne    8019d5 <strtol+0x22>
		s++;
  8019cd:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8019ce:	bf 00 00 00 00       	mov    $0x0,%edi
  8019d3:	eb 11                	jmp    8019e6 <strtol+0x33>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8019d5:	3c 2d                	cmp    $0x2d,%al
  8019d7:	75 08                	jne    8019e1 <strtol+0x2e>
		s++, neg = 1;
  8019d9:	41                   	inc    %ecx
  8019da:	bf 01 00 00 00       	mov    $0x1,%edi
  8019df:	eb 05                	jmp    8019e6 <strtol+0x33>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8019e1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019e6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019ea:	0f 84 87 00 00 00    	je     801a77 <strtol+0xc4>
  8019f0:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  8019f4:	75 27                	jne    801a1d <strtol+0x6a>
  8019f6:	80 39 30             	cmpb   $0x30,(%ecx)
  8019f9:	75 22                	jne    801a1d <strtol+0x6a>
  8019fb:	e9 88 00 00 00       	jmp    801a88 <strtol+0xd5>
		s += 2, base = 16;
  801a00:	83 c1 02             	add    $0x2,%ecx
  801a03:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  801a0a:	eb 11                	jmp    801a1d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
  801a0c:	41                   	inc    %ecx
  801a0d:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  801a14:	eb 07                	jmp    801a1d <strtol+0x6a>
	else if (base == 0)
		base = 10;
  801a16:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  801a1d:	b8 00 00 00 00       	mov    $0x0,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801a22:	8a 11                	mov    (%ecx),%dl
  801a24:	8d 5a d0             	lea    -0x30(%edx),%ebx
  801a27:	80 fb 09             	cmp    $0x9,%bl
  801a2a:	77 08                	ja     801a34 <strtol+0x81>
			dig = *s - '0';
  801a2c:	0f be d2             	movsbl %dl,%edx
  801a2f:	83 ea 30             	sub    $0x30,%edx
  801a32:	eb 22                	jmp    801a56 <strtol+0xa3>
		else if (*s >= 'a' && *s <= 'z')
  801a34:	8d 72 9f             	lea    -0x61(%edx),%esi
  801a37:	89 f3                	mov    %esi,%ebx
  801a39:	80 fb 19             	cmp    $0x19,%bl
  801a3c:	77 08                	ja     801a46 <strtol+0x93>
			dig = *s - 'a' + 10;
  801a3e:	0f be d2             	movsbl %dl,%edx
  801a41:	83 ea 57             	sub    $0x57,%edx
  801a44:	eb 10                	jmp    801a56 <strtol+0xa3>
		else if (*s >= 'A' && *s <= 'Z')
  801a46:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a49:	89 f3                	mov    %esi,%ebx
  801a4b:	80 fb 19             	cmp    $0x19,%bl
  801a4e:	77 14                	ja     801a64 <strtol+0xb1>
			dig = *s - 'A' + 10;
  801a50:	0f be d2             	movsbl %dl,%edx
  801a53:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801a56:	3b 55 10             	cmp    0x10(%ebp),%edx
  801a59:	7d 09                	jge    801a64 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  801a5b:	41                   	inc    %ecx
  801a5c:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a60:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801a62:	eb be                	jmp    801a22 <strtol+0x6f>

	if (endptr)
  801a64:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a68:	74 05                	je     801a6f <strtol+0xbc>
		*endptr = (char *) s;
  801a6a:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a6d:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801a6f:	85 ff                	test   %edi,%edi
  801a71:	74 21                	je     801a94 <strtol+0xe1>
  801a73:	f7 d8                	neg    %eax
  801a75:	eb 1d                	jmp    801a94 <strtol+0xe1>
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801a77:	80 39 30             	cmpb   $0x30,(%ecx)
  801a7a:	75 9a                	jne    801a16 <strtol+0x63>
  801a7c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801a80:	0f 84 7a ff ff ff    	je     801a00 <strtol+0x4d>
  801a86:	eb 84                	jmp    801a0c <strtol+0x59>
  801a88:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801a8c:	0f 84 6e ff ff ff    	je     801a00 <strtol+0x4d>
  801a92:	eb 89                	jmp    801a1d <strtol+0x6a>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  801a94:	5b                   	pop    %ebx
  801a95:	5e                   	pop    %esi
  801a96:	5f                   	pop    %edi
  801a97:	5d                   	pop    %ebp
  801a98:	c3                   	ret    

00801a99 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801a99:	55                   	push   %ebp
  801a9a:	89 e5                	mov    %esp,%ebp
  801a9c:	53                   	push   %ebx
  801a9d:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  801aa0:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801aa7:	75 5b                	jne    801b04 <set_pgfault_handler+0x6b>
		// First time through!
		// LAB 4: Your code here.
		void *va = (void *)(UXSTACKTOP - PGSIZE);
		envid_t eid = sys_getenvid();
  801aa9:	e8 8d e6 ff ff       	call   80013b <sys_getenvid>
  801aae:	89 c3                	mov    %eax,%ebx
		r = sys_page_alloc(eid,va,PTE_P | PTE_U | PTE_W);
  801ab0:	83 ec 04             	sub    $0x4,%esp
  801ab3:	6a 07                	push   $0x7
  801ab5:	68 00 f0 bf ee       	push   $0xeebff000
  801aba:	50                   	push   %eax
  801abb:	e8 b9 e6 ff ff       	call   800179 <sys_page_alloc>
		if(r<0) panic("set_pgfault_handler\n");
  801ac0:	83 c4 10             	add    $0x10,%esp
  801ac3:	85 c0                	test   %eax,%eax
  801ac5:	79 14                	jns    801adb <set_pgfault_handler+0x42>
  801ac7:	83 ec 04             	sub    $0x4,%esp
  801aca:	68 40 23 80 00       	push   $0x802340
  801acf:	6a 23                	push   $0x23
  801ad1:	68 55 23 80 00       	push   $0x802355
  801ad6:	e8 4d f5 ff ff       	call   801028 <_panic>
		r = sys_env_set_pgfault_upcall(eid,_pgfault_upcall);
  801adb:	83 ec 08             	sub    $0x8,%esp
  801ade:	68 6a 03 80 00       	push   $0x80036a
  801ae3:	53                   	push   %ebx
  801ae4:	e8 db e7 ff ff       	call   8002c4 <sys_env_set_pgfault_upcall>
		if(r<0) panic("set_pgfault_handler\n");
  801ae9:	83 c4 10             	add    $0x10,%esp
  801aec:	85 c0                	test   %eax,%eax
  801aee:	79 14                	jns    801b04 <set_pgfault_handler+0x6b>
  801af0:	83 ec 04             	sub    $0x4,%esp
  801af3:	68 40 23 80 00       	push   $0x802340
  801af8:	6a 25                	push   $0x25
  801afa:	68 55 23 80 00       	push   $0x802355
  801aff:	e8 24 f5 ff ff       	call   801028 <_panic>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801b04:	8b 45 08             	mov    0x8(%ebp),%eax
  801b07:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801b0c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b0f:	c9                   	leave  
  801b10:	c3                   	ret    

00801b11 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b11:	55                   	push   %ebp
  801b12:	89 e5                	mov    %esp,%ebp
  801b14:	56                   	push   %esi
  801b15:	53                   	push   %ebx
  801b16:	8b 75 08             	mov    0x8(%ebp),%esi
  801b19:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");
	int r;
    if (pg != NULL) {
  801b1f:	85 c0                	test   %eax,%eax
  801b21:	74 0e                	je     801b31 <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  801b23:	83 ec 0c             	sub    $0xc,%esp
  801b26:	50                   	push   %eax
  801b27:	e8 fd e7 ff ff       	call   800329 <sys_ipc_recv>
  801b2c:	83 c4 10             	add    $0x10,%esp
  801b2f:	eb 10                	jmp    801b41 <ipc_recv+0x30>
    } else {
        r = sys_ipc_recv((void *) UTOP);
  801b31:	83 ec 0c             	sub    $0xc,%esp
  801b34:	68 00 00 c0 ee       	push   $0xeec00000
  801b39:	e8 eb e7 ff ff       	call   800329 <sys_ipc_recv>
  801b3e:	83 c4 10             	add    $0x10,%esp
    }
    if (r < 0) {
  801b41:	85 c0                	test   %eax,%eax
  801b43:	79 16                	jns    801b5b <ipc_recv+0x4a>
        // failed
        if (from_env_store != NULL) *from_env_store = 0;
  801b45:	85 f6                	test   %esi,%esi
  801b47:	74 06                	je     801b4f <ipc_recv+0x3e>
  801b49:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL) *perm_store = 0;
  801b4f:	85 db                	test   %ebx,%ebx
  801b51:	74 2c                	je     801b7f <ipc_recv+0x6e>
  801b53:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801b59:	eb 24                	jmp    801b7f <ipc_recv+0x6e>
        return r;
    } else {
        if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801b5b:	85 f6                	test   %esi,%esi
  801b5d:	74 0a                	je     801b69 <ipc_recv+0x58>
  801b5f:	a1 04 40 80 00       	mov    0x804004,%eax
  801b64:	8b 40 74             	mov    0x74(%eax),%eax
  801b67:	89 06                	mov    %eax,(%esi)
        if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801b69:	85 db                	test   %ebx,%ebx
  801b6b:	74 0a                	je     801b77 <ipc_recv+0x66>
  801b6d:	a1 04 40 80 00       	mov    0x804004,%eax
  801b72:	8b 40 78             	mov    0x78(%eax),%eax
  801b75:	89 03                	mov    %eax,(%ebx)
        return thisenv->env_ipc_value;
  801b77:	a1 04 40 80 00       	mov    0x804004,%eax
  801b7c:	8b 40 70             	mov    0x70(%eax),%eax
    }
 
	return 0;
}
  801b7f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b82:	5b                   	pop    %ebx
  801b83:	5e                   	pop    %esi
  801b84:	5d                   	pop    %ebp
  801b85:	c3                   	ret    

00801b86 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b86:	55                   	push   %ebp
  801b87:	89 e5                	mov    %esp,%ebp
  801b89:	57                   	push   %edi
  801b8a:	56                   	push   %esi
  801b8b:	53                   	push   %ebx
  801b8c:	83 ec 0c             	sub    $0xc,%esp
  801b8f:	8b 75 10             	mov    0x10(%ebp),%esi
  801b92:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;
    if (pg == NULL) pg = (void *)UTOP;
  801b95:	85 f6                	test   %esi,%esi
  801b97:	75 05                	jne    801b9e <ipc_send+0x18>
  801b99:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
  801b9e:	57                   	push   %edi
  801b9f:	56                   	push   %esi
  801ba0:	ff 75 0c             	pushl  0xc(%ebp)
  801ba3:	ff 75 08             	pushl  0x8(%ebp)
  801ba6:	e8 5b e7 ff ff       	call   800306 <sys_ipc_try_send>
  801bab:	89 c3                	mov    %eax,%ebx
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
  801bad:	83 c4 10             	add    $0x10,%esp
  801bb0:	85 c0                	test   %eax,%eax
  801bb2:	79 17                	jns    801bcb <ipc_send+0x45>
  801bb4:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801bb7:	74 1d                	je     801bd6 <ipc_send+0x50>
  801bb9:	50                   	push   %eax
  801bba:	68 63 23 80 00       	push   $0x802363
  801bbf:	6a 40                	push   $0x40
  801bc1:	68 77 23 80 00       	push   $0x802377
  801bc6:	e8 5d f4 ff ff       	call   801028 <_panic>
        sys_yield();
  801bcb:	e8 8a e5 ff ff       	call   80015a <sys_yield>
    } while (r != 0);
  801bd0:	85 db                	test   %ebx,%ebx
  801bd2:	75 ca                	jne    801b9e <ipc_send+0x18>
  801bd4:	eb 07                	jmp    801bdd <ipc_send+0x57>
	int r;
    if (pg == NULL) pg = (void *)UTOP;
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
        sys_yield();
  801bd6:	e8 7f e5 ff ff       	call   80015a <sys_yield>
  801bdb:	eb c1                	jmp    801b9e <ipc_send+0x18>
    } while (r != 0);
}
  801bdd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801be0:	5b                   	pop    %ebx
  801be1:	5e                   	pop    %esi
  801be2:	5f                   	pop    %edi
  801be3:	5d                   	pop    %ebp
  801be4:	c3                   	ret    

00801be5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801be5:	55                   	push   %ebp
  801be6:	89 e5                	mov    %esp,%ebp
  801be8:	53                   	push   %ebx
  801be9:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801bec:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801bf1:	39 c1                	cmp    %eax,%ecx
  801bf3:	74 21                	je     801c16 <ipc_find_env+0x31>
  801bf5:	ba 01 00 00 00       	mov    $0x1,%edx
  801bfa:	8d 1c 95 00 00 00 00 	lea    0x0(,%edx,4),%ebx
  801c01:	89 d0                	mov    %edx,%eax
  801c03:	c1 e0 07             	shl    $0x7,%eax
  801c06:	29 d8                	sub    %ebx,%eax
  801c08:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c0d:	8b 40 50             	mov    0x50(%eax),%eax
  801c10:	39 c8                	cmp    %ecx,%eax
  801c12:	75 1b                	jne    801c2f <ipc_find_env+0x4a>
  801c14:	eb 05                	jmp    801c1b <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c16:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801c1b:	8d 04 95 00 00 00 00 	lea    0x0(,%edx,4),%eax
  801c22:	c1 e2 07             	shl    $0x7,%edx
  801c25:	29 c2                	sub    %eax,%edx
  801c27:	8b 82 48 00 c0 ee    	mov    -0x113fffb8(%edx),%eax
  801c2d:	eb 0e                	jmp    801c3d <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c2f:	42                   	inc    %edx
  801c30:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  801c36:	75 c2                	jne    801bfa <ipc_find_env+0x15>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801c38:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c3d:	5b                   	pop    %ebx
  801c3e:	5d                   	pop    %ebp
  801c3f:	c3                   	ret    

00801c40 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c40:	55                   	push   %ebp
  801c41:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c43:	8b 45 08             	mov    0x8(%ebp),%eax
  801c46:	c1 e8 16             	shr    $0x16,%eax
  801c49:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801c50:	a8 01                	test   $0x1,%al
  801c52:	74 21                	je     801c75 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c54:	8b 45 08             	mov    0x8(%ebp),%eax
  801c57:	c1 e8 0c             	shr    $0xc,%eax
  801c5a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801c61:	a8 01                	test   $0x1,%al
  801c63:	74 17                	je     801c7c <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c65:	c1 e8 0c             	shr    $0xc,%eax
  801c68:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801c6f:	ef 
  801c70:	0f b7 c0             	movzwl %ax,%eax
  801c73:	eb 0c                	jmp    801c81 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801c75:	b8 00 00 00 00       	mov    $0x0,%eax
  801c7a:	eb 05                	jmp    801c81 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801c7c:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801c81:	5d                   	pop    %ebp
  801c82:	c3                   	ret    
  801c83:	90                   	nop

00801c84 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801c84:	55                   	push   %ebp
  801c85:	57                   	push   %edi
  801c86:	56                   	push   %esi
  801c87:	53                   	push   %ebx
  801c88:	83 ec 1c             	sub    $0x1c,%esp
  801c8b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801c8f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801c93:	8b 7c 24 38          	mov    0x38(%esp),%edi
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801c97:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c9b:	89 ca                	mov    %ecx,%edx
  const DWunion dd = {.ll = d};
  801c9d:	89 f8                	mov    %edi,%eax
  801c9f:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801ca3:	85 f6                	test   %esi,%esi
  801ca5:	75 2d                	jne    801cd4 <__udivdi3+0x50>
    {
      if (d0 > n1)
  801ca7:	39 cf                	cmp    %ecx,%edi
  801ca9:	77 65                	ja     801d10 <__udivdi3+0x8c>
  801cab:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801cad:	85 ff                	test   %edi,%edi
  801caf:	75 0b                	jne    801cbc <__udivdi3+0x38>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801cb1:	b8 01 00 00 00       	mov    $0x1,%eax
  801cb6:	31 d2                	xor    %edx,%edx
  801cb8:	f7 f7                	div    %edi
  801cba:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801cbc:	31 d2                	xor    %edx,%edx
  801cbe:	89 c8                	mov    %ecx,%eax
  801cc0:	f7 f5                	div    %ebp
  801cc2:	89 c1                	mov    %eax,%ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801cc4:	89 d8                	mov    %ebx,%eax
  801cc6:	f7 f5                	div    %ebp
  801cc8:	89 cf                	mov    %ecx,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801cca:	89 fa                	mov    %edi,%edx
  801ccc:	83 c4 1c             	add    $0x1c,%esp
  801ccf:	5b                   	pop    %ebx
  801cd0:	5e                   	pop    %esi
  801cd1:	5f                   	pop    %edi
  801cd2:	5d                   	pop    %ebp
  801cd3:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801cd4:	39 ce                	cmp    %ecx,%esi
  801cd6:	77 28                	ja     801d00 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801cd8:	0f bd fe             	bsr    %esi,%edi
	  if (bm == 0)
  801cdb:	83 f7 1f             	xor    $0x1f,%edi
  801cde:	75 40                	jne    801d20 <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801ce0:	39 ce                	cmp    %ecx,%esi
  801ce2:	72 0a                	jb     801cee <__udivdi3+0x6a>
  801ce4:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801ce8:	0f 87 9e 00 00 00    	ja     801d8c <__udivdi3+0x108>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801cee:	b8 01 00 00 00       	mov    $0x1,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801cf3:	89 fa                	mov    %edi,%edx
  801cf5:	83 c4 1c             	add    $0x1c,%esp
  801cf8:	5b                   	pop    %ebx
  801cf9:	5e                   	pop    %esi
  801cfa:	5f                   	pop    %edi
  801cfb:	5d                   	pop    %ebp
  801cfc:	c3                   	ret    
  801cfd:	8d 76 00             	lea    0x0(%esi),%esi
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801d00:	31 ff                	xor    %edi,%edi
  801d02:	31 c0                	xor    %eax,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801d04:	89 fa                	mov    %edi,%edx
  801d06:	83 c4 1c             	add    $0x1c,%esp
  801d09:	5b                   	pop    %ebx
  801d0a:	5e                   	pop    %esi
  801d0b:	5f                   	pop    %edi
  801d0c:	5d                   	pop    %ebp
  801d0d:	c3                   	ret    
  801d0e:	66 90                	xchg   %ax,%ax
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d10:	89 d8                	mov    %ebx,%eax
  801d12:	f7 f7                	div    %edi
  801d14:	31 ff                	xor    %edi,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801d16:	89 fa                	mov    %edi,%edx
  801d18:	83 c4 1c             	add    $0x1c,%esp
  801d1b:	5b                   	pop    %ebx
  801d1c:	5e                   	pop    %esi
  801d1d:	5f                   	pop    %edi
  801d1e:	5d                   	pop    %ebp
  801d1f:	c3                   	ret    
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801d20:	bd 20 00 00 00       	mov    $0x20,%ebp
  801d25:	89 eb                	mov    %ebp,%ebx
  801d27:	29 fb                	sub    %edi,%ebx

	      d1 = (d1 << bm) | (d0 >> b);
  801d29:	89 f9                	mov    %edi,%ecx
  801d2b:	d3 e6                	shl    %cl,%esi
  801d2d:	89 c5                	mov    %eax,%ebp
  801d2f:	88 d9                	mov    %bl,%cl
  801d31:	d3 ed                	shr    %cl,%ebp
  801d33:	89 e9                	mov    %ebp,%ecx
  801d35:	09 f1                	or     %esi,%ecx
  801d37:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
	      d0 = d0 << bm;
  801d3b:	89 f9                	mov    %edi,%ecx
  801d3d:	d3 e0                	shl    %cl,%eax
  801d3f:	89 c5                	mov    %eax,%ebp
	      n2 = n1 >> b;
  801d41:	89 d6                	mov    %edx,%esi
  801d43:	88 d9                	mov    %bl,%cl
  801d45:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
  801d47:	89 f9                	mov    %edi,%ecx
  801d49:	d3 e2                	shl    %cl,%edx
  801d4b:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d4f:	88 d9                	mov    %bl,%cl
  801d51:	d3 e8                	shr    %cl,%eax
  801d53:	09 c2                	or     %eax,%edx
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801d55:	89 d0                	mov    %edx,%eax
  801d57:	89 f2                	mov    %esi,%edx
  801d59:	f7 74 24 0c          	divl   0xc(%esp)
  801d5d:	89 d6                	mov    %edx,%esi
  801d5f:	89 c3                	mov    %eax,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  801d61:	f7 e5                	mul    %ebp

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d63:	39 d6                	cmp    %edx,%esi
  801d65:	72 19                	jb     801d80 <__udivdi3+0xfc>
  801d67:	74 0b                	je     801d74 <__udivdi3+0xf0>
  801d69:	89 d8                	mov    %ebx,%eax
  801d6b:	31 ff                	xor    %edi,%edi
  801d6d:	e9 58 ff ff ff       	jmp    801cca <__udivdi3+0x46>
  801d72:	66 90                	xchg   %ax,%ax
  801d74:	8b 54 24 08          	mov    0x8(%esp),%edx
  801d78:	89 f9                	mov    %edi,%ecx
  801d7a:	d3 e2                	shl    %cl,%edx
  801d7c:	39 c2                	cmp    %eax,%edx
  801d7e:	73 e9                	jae    801d69 <__udivdi3+0xe5>
  801d80:	8d 43 ff             	lea    -0x1(%ebx),%eax
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801d83:	31 ff                	xor    %edi,%edi
  801d85:	e9 40 ff ff ff       	jmp    801cca <__udivdi3+0x46>
  801d8a:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801d8c:	31 c0                	xor    %eax,%eax
  801d8e:	e9 37 ff ff ff       	jmp    801cca <__udivdi3+0x46>
  801d93:	90                   	nop

00801d94 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801d94:	55                   	push   %ebp
  801d95:	57                   	push   %edi
  801d96:	56                   	push   %esi
  801d97:	53                   	push   %ebx
  801d98:	83 ec 1c             	sub    $0x1c,%esp
  801d9b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d9f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801da3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801da7:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801dab:	89 44 24 0c          	mov    %eax,0xc(%esp)
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801daf:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801db3:	89 f3                	mov    %esi,%ebx
  const DWunion dd = {.ll = d};
  801db5:	89 fa                	mov    %edi,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801db7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  n1 = nn.s.high;
  801dbb:	89 34 24             	mov    %esi,(%esp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801dbe:	85 c0                	test   %eax,%eax
  801dc0:	75 1a                	jne    801ddc <__umoddi3+0x48>
    {
      if (d0 > n1)
  801dc2:	39 f7                	cmp    %esi,%edi
  801dc4:	0f 86 a2 00 00 00    	jbe    801e6c <__umoddi3+0xd8>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801dca:	89 c8                	mov    %ecx,%eax
  801dcc:	89 f2                	mov    %esi,%edx
  801dce:	f7 f7                	div    %edi
  801dd0:	89 d0                	mov    %edx,%eax

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801dd2:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801dd4:	83 c4 1c             	add    $0x1c,%esp
  801dd7:	5b                   	pop    %ebx
  801dd8:	5e                   	pop    %esi
  801dd9:	5f                   	pop    %edi
  801dda:	5d                   	pop    %ebp
  801ddb:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801ddc:	39 f0                	cmp    %esi,%eax
  801dde:	0f 87 ac 00 00 00    	ja     801e90 <__umoddi3+0xfc>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801de4:	0f bd e8             	bsr    %eax,%ebp
	  if (bm == 0)
  801de7:	83 f5 1f             	xor    $0x1f,%ebp
  801dea:	0f 84 ac 00 00 00    	je     801e9c <__umoddi3+0x108>
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801df0:	bf 20 00 00 00       	mov    $0x20,%edi
  801df5:	29 ef                	sub    %ebp,%edi
  801df7:	89 fe                	mov    %edi,%esi
  801df9:	89 7c 24 0c          	mov    %edi,0xc(%esp)

	      d1 = (d1 << bm) | (d0 >> b);
  801dfd:	89 e9                	mov    %ebp,%ecx
  801dff:	d3 e0                	shl    %cl,%eax
  801e01:	89 d7                	mov    %edx,%edi
  801e03:	89 f1                	mov    %esi,%ecx
  801e05:	d3 ef                	shr    %cl,%edi
  801e07:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  801e09:	89 e9                	mov    %ebp,%ecx
  801e0b:	d3 e2                	shl    %cl,%edx
  801e0d:	89 14 24             	mov    %edx,(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801e10:	89 d8                	mov    %ebx,%eax
  801e12:	d3 e0                	shl    %cl,%eax
  801e14:	89 c2                	mov    %eax,%edx
	      n0 = n0 << bm;
  801e16:	8b 44 24 08          	mov    0x8(%esp),%eax
  801e1a:	d3 e0                	shl    %cl,%eax
  801e1c:	89 44 24 04          	mov    %eax,0x4(%esp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801e20:	8b 44 24 08          	mov    0x8(%esp),%eax
  801e24:	89 f1                	mov    %esi,%ecx
  801e26:	d3 e8                	shr    %cl,%eax
  801e28:	09 d0                	or     %edx,%eax
  801e2a:	d3 eb                	shr    %cl,%ebx
  801e2c:	89 da                	mov    %ebx,%edx
  801e2e:	f7 f7                	div    %edi
  801e30:	89 d3                	mov    %edx,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  801e32:	f7 24 24             	mull   (%esp)
  801e35:	89 c6                	mov    %eax,%esi
  801e37:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e39:	39 d3                	cmp    %edx,%ebx
  801e3b:	0f 82 87 00 00 00    	jb     801ec8 <__umoddi3+0x134>
  801e41:	0f 84 91 00 00 00    	je     801ed8 <__umoddi3+0x144>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801e47:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e4b:	29 f2                	sub    %esi,%edx
  801e4d:	19 cb                	sbb    %ecx,%ebx
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801e4f:	89 d8                	mov    %ebx,%eax
  801e51:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  801e55:	d3 e0                	shl    %cl,%eax
  801e57:	89 e9                	mov    %ebp,%ecx
  801e59:	d3 ea                	shr    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801e5b:	09 d0                	or     %edx,%eax
  801e5d:	89 e9                	mov    %ebp,%ecx
  801e5f:	d3 eb                	shr    %cl,%ebx
  801e61:	89 da                	mov    %ebx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e63:	83 c4 1c             	add    $0x1c,%esp
  801e66:	5b                   	pop    %ebx
  801e67:	5e                   	pop    %esi
  801e68:	5f                   	pop    %edi
  801e69:	5d                   	pop    %ebp
  801e6a:	c3                   	ret    
  801e6b:	90                   	nop
  801e6c:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801e6e:	85 ff                	test   %edi,%edi
  801e70:	75 0b                	jne    801e7d <__umoddi3+0xe9>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801e72:	b8 01 00 00 00       	mov    $0x1,%eax
  801e77:	31 d2                	xor    %edx,%edx
  801e79:	f7 f7                	div    %edi
  801e7b:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801e7d:	89 f0                	mov    %esi,%eax
  801e7f:	31 d2                	xor    %edx,%edx
  801e81:	f7 f5                	div    %ebp
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801e83:	89 c8                	mov    %ecx,%eax
  801e85:	f7 f5                	div    %ebp
  801e87:	89 d0                	mov    %edx,%eax
  801e89:	e9 44 ff ff ff       	jmp    801dd2 <__umoddi3+0x3e>
  801e8e:	66 90                	xchg   %ax,%ax
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801e90:	89 c8                	mov    %ecx,%eax
  801e92:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e94:	83 c4 1c             	add    $0x1c,%esp
  801e97:	5b                   	pop    %ebx
  801e98:	5e                   	pop    %esi
  801e99:	5f                   	pop    %edi
  801e9a:	5d                   	pop    %ebp
  801e9b:	c3                   	ret    

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801e9c:	3b 04 24             	cmp    (%esp),%eax
  801e9f:	72 06                	jb     801ea7 <__umoddi3+0x113>
  801ea1:	3b 7c 24 04          	cmp    0x4(%esp),%edi
  801ea5:	77 0f                	ja     801eb6 <__umoddi3+0x122>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801ea7:	89 f2                	mov    %esi,%edx
  801ea9:	29 f9                	sub    %edi,%ecx
  801eab:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  801eaf:	89 14 24             	mov    %edx,(%esp)
  801eb2:	89 4c 24 04          	mov    %ecx,0x4(%esp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801eb6:	8b 44 24 04          	mov    0x4(%esp),%eax
  801eba:	8b 14 24             	mov    (%esp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801ebd:	83 c4 1c             	add    $0x1c,%esp
  801ec0:	5b                   	pop    %ebx
  801ec1:	5e                   	pop    %esi
  801ec2:	5f                   	pop    %edi
  801ec3:	5d                   	pop    %ebp
  801ec4:	c3                   	ret    
  801ec5:	8d 76 00             	lea    0x0(%esi),%esi
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801ec8:	2b 04 24             	sub    (%esp),%eax
  801ecb:	19 fa                	sbb    %edi,%edx
  801ecd:	89 d1                	mov    %edx,%ecx
  801ecf:	89 c6                	mov    %eax,%esi
  801ed1:	e9 71 ff ff ff       	jmp    801e47 <__umoddi3+0xb3>
  801ed6:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801ed8:	39 44 24 04          	cmp    %eax,0x4(%esp)
  801edc:	72 ea                	jb     801ec8 <__umoddi3+0x134>
  801ede:	89 d9                	mov    %ebx,%ecx
  801ee0:	e9 62 ff ff ff       	jmp    801e47 <__umoddi3+0xb3>
