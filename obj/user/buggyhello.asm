
obj/user/buggyhello.debug:     file format elf32-i386


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
  80002c:	e8 16 00 00 00       	call   800047 <libmain>
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
	sys_cputs((char*)1, 1);
  800039:	6a 01                	push   $0x1
  80003b:	6a 01                	push   $0x1
  80003d:	e8 6e 00 00 00       	call   8000b0 <sys_cputs>
}
  800042:	83 c4 10             	add    $0x10,%esp
  800045:	c9                   	leave  
  800046:	c3                   	ret    

00800047 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800047:	55                   	push   %ebp
  800048:	89 e5                	mov    %esp,%ebp
  80004a:	56                   	push   %esi
  80004b:	53                   	push   %ebx
  80004c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800052:	e8 d7 00 00 00       	call   80012e <sys_getenvid>
  800057:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800063:	c1 e0 07             	shl    $0x7,%eax
  800066:	29 d0                	sub    %edx,%eax
  800068:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006d:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800072:	85 db                	test   %ebx,%ebx
  800074:	7e 07                	jle    80007d <libmain+0x36>
		binaryname = argv[0];
  800076:	8b 06                	mov    (%esi),%eax
  800078:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80007d:	83 ec 08             	sub    $0x8,%esp
  800080:	56                   	push   %esi
  800081:	53                   	push   %ebx
  800082:	e8 ac ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800087:	e8 0a 00 00 00       	call   800096 <exit>
}
  80008c:	83 c4 10             	add    $0x10,%esp
  80008f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800092:	5b                   	pop    %ebx
  800093:	5e                   	pop    %esi
  800094:	5d                   	pop    %ebp
  800095:	c3                   	ret    

00800096 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800096:	55                   	push   %ebp
  800097:	89 e5                	mov    %esp,%ebp
  800099:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80009c:	e8 cb 04 00 00       	call   80056c <close_all>
	sys_env_destroy(0);
  8000a1:	83 ec 0c             	sub    $0xc,%esp
  8000a4:	6a 00                	push   $0x0
  8000a6:	e8 42 00 00 00       	call   8000ed <sys_env_destroy>
}
  8000ab:	83 c4 10             	add    $0x10,%esp
  8000ae:	c9                   	leave  
  8000af:	c3                   	ret    

008000b0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	57                   	push   %edi
  8000b4:	56                   	push   %esi
  8000b5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8000bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000be:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c1:	89 c3                	mov    %eax,%ebx
  8000c3:	89 c7                	mov    %eax,%edi
  8000c5:	89 c6                	mov    %eax,%esi
  8000c7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c9:	5b                   	pop    %ebx
  8000ca:	5e                   	pop    %esi
  8000cb:	5f                   	pop    %edi
  8000cc:	5d                   	pop    %ebp
  8000cd:	c3                   	ret    

008000ce <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ce:	55                   	push   %ebp
  8000cf:	89 e5                	mov    %esp,%ebp
  8000d1:	57                   	push   %edi
  8000d2:	56                   	push   %esi
  8000d3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d9:	b8 01 00 00 00       	mov    $0x1,%eax
  8000de:	89 d1                	mov    %edx,%ecx
  8000e0:	89 d3                	mov    %edx,%ebx
  8000e2:	89 d7                	mov    %edx,%edi
  8000e4:	89 d6                	mov    %edx,%esi
  8000e6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e8:	5b                   	pop    %ebx
  8000e9:	5e                   	pop    %esi
  8000ea:	5f                   	pop    %edi
  8000eb:	5d                   	pop    %ebp
  8000ec:	c3                   	ret    

008000ed <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000ed:	55                   	push   %ebp
  8000ee:	89 e5                	mov    %esp,%ebp
  8000f0:	57                   	push   %edi
  8000f1:	56                   	push   %esi
  8000f2:	53                   	push   %ebx
  8000f3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000fb:	b8 03 00 00 00       	mov    $0x3,%eax
  800100:	8b 55 08             	mov    0x8(%ebp),%edx
  800103:	89 cb                	mov    %ecx,%ebx
  800105:	89 cf                	mov    %ecx,%edi
  800107:	89 ce                	mov    %ecx,%esi
  800109:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80010b:	85 c0                	test   %eax,%eax
  80010d:	7e 17                	jle    800126 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80010f:	83 ec 0c             	sub    $0xc,%esp
  800112:	50                   	push   %eax
  800113:	6a 03                	push   $0x3
  800115:	68 4a 1e 80 00       	push   $0x801e4a
  80011a:	6a 23                	push   $0x23
  80011c:	68 67 1e 80 00       	push   $0x801e67
  800121:	e8 cf 0e 00 00       	call   800ff5 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800126:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800129:	5b                   	pop    %ebx
  80012a:	5e                   	pop    %esi
  80012b:	5f                   	pop    %edi
  80012c:	5d                   	pop    %ebp
  80012d:	c3                   	ret    

0080012e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80012e:	55                   	push   %ebp
  80012f:	89 e5                	mov    %esp,%ebp
  800131:	57                   	push   %edi
  800132:	56                   	push   %esi
  800133:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800134:	ba 00 00 00 00       	mov    $0x0,%edx
  800139:	b8 02 00 00 00       	mov    $0x2,%eax
  80013e:	89 d1                	mov    %edx,%ecx
  800140:	89 d3                	mov    %edx,%ebx
  800142:	89 d7                	mov    %edx,%edi
  800144:	89 d6                	mov    %edx,%esi
  800146:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800148:	5b                   	pop    %ebx
  800149:	5e                   	pop    %esi
  80014a:	5f                   	pop    %edi
  80014b:	5d                   	pop    %ebp
  80014c:	c3                   	ret    

0080014d <sys_yield>:

void
sys_yield(void)
{
  80014d:	55                   	push   %ebp
  80014e:	89 e5                	mov    %esp,%ebp
  800150:	57                   	push   %edi
  800151:	56                   	push   %esi
  800152:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800153:	ba 00 00 00 00       	mov    $0x0,%edx
  800158:	b8 0b 00 00 00       	mov    $0xb,%eax
  80015d:	89 d1                	mov    %edx,%ecx
  80015f:	89 d3                	mov    %edx,%ebx
  800161:	89 d7                	mov    %edx,%edi
  800163:	89 d6                	mov    %edx,%esi
  800165:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800167:	5b                   	pop    %ebx
  800168:	5e                   	pop    %esi
  800169:	5f                   	pop    %edi
  80016a:	5d                   	pop    %ebp
  80016b:	c3                   	ret    

0080016c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80016c:	55                   	push   %ebp
  80016d:	89 e5                	mov    %esp,%ebp
  80016f:	57                   	push   %edi
  800170:	56                   	push   %esi
  800171:	53                   	push   %ebx
  800172:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800175:	be 00 00 00 00       	mov    $0x0,%esi
  80017a:	b8 04 00 00 00       	mov    $0x4,%eax
  80017f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800182:	8b 55 08             	mov    0x8(%ebp),%edx
  800185:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800188:	89 f7                	mov    %esi,%edi
  80018a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80018c:	85 c0                	test   %eax,%eax
  80018e:	7e 17                	jle    8001a7 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800190:	83 ec 0c             	sub    $0xc,%esp
  800193:	50                   	push   %eax
  800194:	6a 04                	push   $0x4
  800196:	68 4a 1e 80 00       	push   $0x801e4a
  80019b:	6a 23                	push   $0x23
  80019d:	68 67 1e 80 00       	push   $0x801e67
  8001a2:	e8 4e 0e 00 00       	call   800ff5 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001aa:	5b                   	pop    %ebx
  8001ab:	5e                   	pop    %esi
  8001ac:	5f                   	pop    %edi
  8001ad:	5d                   	pop    %ebp
  8001ae:	c3                   	ret    

008001af <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001af:	55                   	push   %ebp
  8001b0:	89 e5                	mov    %esp,%ebp
  8001b2:	57                   	push   %edi
  8001b3:	56                   	push   %esi
  8001b4:	53                   	push   %ebx
  8001b5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001b8:	b8 05 00 00 00       	mov    $0x5,%eax
  8001bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c9:	8b 75 18             	mov    0x18(%ebp),%esi
  8001cc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001ce:	85 c0                	test   %eax,%eax
  8001d0:	7e 17                	jle    8001e9 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d2:	83 ec 0c             	sub    $0xc,%esp
  8001d5:	50                   	push   %eax
  8001d6:	6a 05                	push   $0x5
  8001d8:	68 4a 1e 80 00       	push   $0x801e4a
  8001dd:	6a 23                	push   $0x23
  8001df:	68 67 1e 80 00       	push   $0x801e67
  8001e4:	e8 0c 0e 00 00       	call   800ff5 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ec:	5b                   	pop    %ebx
  8001ed:	5e                   	pop    %esi
  8001ee:	5f                   	pop    %edi
  8001ef:	5d                   	pop    %ebp
  8001f0:	c3                   	ret    

008001f1 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001f1:	55                   	push   %ebp
  8001f2:	89 e5                	mov    %esp,%ebp
  8001f4:	57                   	push   %edi
  8001f5:	56                   	push   %esi
  8001f6:	53                   	push   %ebx
  8001f7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001fa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ff:	b8 06 00 00 00       	mov    $0x6,%eax
  800204:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800207:	8b 55 08             	mov    0x8(%ebp),%edx
  80020a:	89 df                	mov    %ebx,%edi
  80020c:	89 de                	mov    %ebx,%esi
  80020e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800210:	85 c0                	test   %eax,%eax
  800212:	7e 17                	jle    80022b <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800214:	83 ec 0c             	sub    $0xc,%esp
  800217:	50                   	push   %eax
  800218:	6a 06                	push   $0x6
  80021a:	68 4a 1e 80 00       	push   $0x801e4a
  80021f:	6a 23                	push   $0x23
  800221:	68 67 1e 80 00       	push   $0x801e67
  800226:	e8 ca 0d 00 00       	call   800ff5 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80022b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80022e:	5b                   	pop    %ebx
  80022f:	5e                   	pop    %esi
  800230:	5f                   	pop    %edi
  800231:	5d                   	pop    %ebp
  800232:	c3                   	ret    

00800233 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800233:	55                   	push   %ebp
  800234:	89 e5                	mov    %esp,%ebp
  800236:	57                   	push   %edi
  800237:	56                   	push   %esi
  800238:	53                   	push   %ebx
  800239:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80023c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800241:	b8 08 00 00 00       	mov    $0x8,%eax
  800246:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800249:	8b 55 08             	mov    0x8(%ebp),%edx
  80024c:	89 df                	mov    %ebx,%edi
  80024e:	89 de                	mov    %ebx,%esi
  800250:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800252:	85 c0                	test   %eax,%eax
  800254:	7e 17                	jle    80026d <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800256:	83 ec 0c             	sub    $0xc,%esp
  800259:	50                   	push   %eax
  80025a:	6a 08                	push   $0x8
  80025c:	68 4a 1e 80 00       	push   $0x801e4a
  800261:	6a 23                	push   $0x23
  800263:	68 67 1e 80 00       	push   $0x801e67
  800268:	e8 88 0d 00 00       	call   800ff5 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80026d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800270:	5b                   	pop    %ebx
  800271:	5e                   	pop    %esi
  800272:	5f                   	pop    %edi
  800273:	5d                   	pop    %ebp
  800274:	c3                   	ret    

00800275 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800275:	55                   	push   %ebp
  800276:	89 e5                	mov    %esp,%ebp
  800278:	57                   	push   %edi
  800279:	56                   	push   %esi
  80027a:	53                   	push   %ebx
  80027b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80027e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800283:	b8 09 00 00 00       	mov    $0x9,%eax
  800288:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80028b:	8b 55 08             	mov    0x8(%ebp),%edx
  80028e:	89 df                	mov    %ebx,%edi
  800290:	89 de                	mov    %ebx,%esi
  800292:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800294:	85 c0                	test   %eax,%eax
  800296:	7e 17                	jle    8002af <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800298:	83 ec 0c             	sub    $0xc,%esp
  80029b:	50                   	push   %eax
  80029c:	6a 09                	push   $0x9
  80029e:	68 4a 1e 80 00       	push   $0x801e4a
  8002a3:	6a 23                	push   $0x23
  8002a5:	68 67 1e 80 00       	push   $0x801e67
  8002aa:	e8 46 0d 00 00       	call   800ff5 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002af:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b2:	5b                   	pop    %ebx
  8002b3:	5e                   	pop    %esi
  8002b4:	5f                   	pop    %edi
  8002b5:	5d                   	pop    %ebp
  8002b6:	c3                   	ret    

008002b7 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002b7:	55                   	push   %ebp
  8002b8:	89 e5                	mov    %esp,%ebp
  8002ba:	57                   	push   %edi
  8002bb:	56                   	push   %esi
  8002bc:	53                   	push   %ebx
  8002bd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002c0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002cd:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d0:	89 df                	mov    %ebx,%edi
  8002d2:	89 de                	mov    %ebx,%esi
  8002d4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002d6:	85 c0                	test   %eax,%eax
  8002d8:	7e 17                	jle    8002f1 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002da:	83 ec 0c             	sub    $0xc,%esp
  8002dd:	50                   	push   %eax
  8002de:	6a 0a                	push   $0xa
  8002e0:	68 4a 1e 80 00       	push   $0x801e4a
  8002e5:	6a 23                	push   $0x23
  8002e7:	68 67 1e 80 00       	push   $0x801e67
  8002ec:	e8 04 0d 00 00       	call   800ff5 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f4:	5b                   	pop    %ebx
  8002f5:	5e                   	pop    %esi
  8002f6:	5f                   	pop    %edi
  8002f7:	5d                   	pop    %ebp
  8002f8:	c3                   	ret    

008002f9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f9:	55                   	push   %ebp
  8002fa:	89 e5                	mov    %esp,%ebp
  8002fc:	57                   	push   %edi
  8002fd:	56                   	push   %esi
  8002fe:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ff:	be 00 00 00 00       	mov    $0x0,%esi
  800304:	b8 0c 00 00 00       	mov    $0xc,%eax
  800309:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80030c:	8b 55 08             	mov    0x8(%ebp),%edx
  80030f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800312:	8b 7d 14             	mov    0x14(%ebp),%edi
  800315:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800317:	5b                   	pop    %ebx
  800318:	5e                   	pop    %esi
  800319:	5f                   	pop    %edi
  80031a:	5d                   	pop    %ebp
  80031b:	c3                   	ret    

0080031c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80031c:	55                   	push   %ebp
  80031d:	89 e5                	mov    %esp,%ebp
  80031f:	57                   	push   %edi
  800320:	56                   	push   %esi
  800321:	53                   	push   %ebx
  800322:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800325:	b9 00 00 00 00       	mov    $0x0,%ecx
  80032a:	b8 0d 00 00 00       	mov    $0xd,%eax
  80032f:	8b 55 08             	mov    0x8(%ebp),%edx
  800332:	89 cb                	mov    %ecx,%ebx
  800334:	89 cf                	mov    %ecx,%edi
  800336:	89 ce                	mov    %ecx,%esi
  800338:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80033a:	85 c0                	test   %eax,%eax
  80033c:	7e 17                	jle    800355 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80033e:	83 ec 0c             	sub    $0xc,%esp
  800341:	50                   	push   %eax
  800342:	6a 0d                	push   $0xd
  800344:	68 4a 1e 80 00       	push   $0x801e4a
  800349:	6a 23                	push   $0x23
  80034b:	68 67 1e 80 00       	push   $0x801e67
  800350:	e8 a0 0c 00 00       	call   800ff5 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800355:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800358:	5b                   	pop    %ebx
  800359:	5e                   	pop    %esi
  80035a:	5f                   	pop    %edi
  80035b:	5d                   	pop    %ebp
  80035c:	c3                   	ret    

0080035d <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80035d:	55                   	push   %ebp
  80035e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800360:	8b 45 08             	mov    0x8(%ebp),%eax
  800363:	05 00 00 00 30       	add    $0x30000000,%eax
  800368:	c1 e8 0c             	shr    $0xc,%eax
}
  80036b:	5d                   	pop    %ebp
  80036c:	c3                   	ret    

0080036d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80036d:	55                   	push   %ebp
  80036e:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800370:	8b 45 08             	mov    0x8(%ebp),%eax
  800373:	05 00 00 00 30       	add    $0x30000000,%eax
  800378:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80037d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800382:	5d                   	pop    %ebp
  800383:	c3                   	ret    

00800384 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800387:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  80038c:	a8 01                	test   $0x1,%al
  80038e:	74 34                	je     8003c4 <fd_alloc+0x40>
  800390:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800395:	a8 01                	test   $0x1,%al
  800397:	74 32                	je     8003cb <fd_alloc+0x47>
  800399:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80039e:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003a0:	89 c2                	mov    %eax,%edx
  8003a2:	c1 ea 16             	shr    $0x16,%edx
  8003a5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003ac:	f6 c2 01             	test   $0x1,%dl
  8003af:	74 1f                	je     8003d0 <fd_alloc+0x4c>
  8003b1:	89 c2                	mov    %eax,%edx
  8003b3:	c1 ea 0c             	shr    $0xc,%edx
  8003b6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003bd:	f6 c2 01             	test   $0x1,%dl
  8003c0:	75 1a                	jne    8003dc <fd_alloc+0x58>
  8003c2:	eb 0c                	jmp    8003d0 <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8003c4:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8003c9:	eb 05                	jmp    8003d0 <fd_alloc+0x4c>
  8003cb:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8003d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d3:	89 08                	mov    %ecx,(%eax)
			return 0;
  8003d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8003da:	eb 1a                	jmp    8003f6 <fd_alloc+0x72>
  8003dc:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003e1:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003e6:	75 b6                	jne    80039e <fd_alloc+0x1a>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8003eb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  8003f1:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003f6:	5d                   	pop    %ebp
  8003f7:	c3                   	ret    

008003f8 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003f8:	55                   	push   %ebp
  8003f9:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003fb:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  8003ff:	77 39                	ja     80043a <fd_lookup+0x42>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800401:	8b 45 08             	mov    0x8(%ebp),%eax
  800404:	c1 e0 0c             	shl    $0xc,%eax
  800407:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80040c:	89 c2                	mov    %eax,%edx
  80040e:	c1 ea 16             	shr    $0x16,%edx
  800411:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800418:	f6 c2 01             	test   $0x1,%dl
  80041b:	74 24                	je     800441 <fd_lookup+0x49>
  80041d:	89 c2                	mov    %eax,%edx
  80041f:	c1 ea 0c             	shr    $0xc,%edx
  800422:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800429:	f6 c2 01             	test   $0x1,%dl
  80042c:	74 1a                	je     800448 <fd_lookup+0x50>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80042e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800431:	89 02                	mov    %eax,(%edx)
	return 0;
  800433:	b8 00 00 00 00       	mov    $0x0,%eax
  800438:	eb 13                	jmp    80044d <fd_lookup+0x55>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80043a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80043f:	eb 0c                	jmp    80044d <fd_lookup+0x55>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800441:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800446:	eb 05                	jmp    80044d <fd_lookup+0x55>
  800448:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80044d:	5d                   	pop    %ebp
  80044e:	c3                   	ret    

0080044f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80044f:	55                   	push   %ebp
  800450:	89 e5                	mov    %esp,%ebp
  800452:	53                   	push   %ebx
  800453:	83 ec 04             	sub    $0x4,%esp
  800456:	8b 45 08             	mov    0x8(%ebp),%eax
  800459:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80045c:	3b 05 04 30 80 00    	cmp    0x803004,%eax
  800462:	75 1e                	jne    800482 <dev_lookup+0x33>
  800464:	eb 0e                	jmp    800474 <dev_lookup+0x25>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800466:	b8 20 30 80 00       	mov    $0x803020,%eax
  80046b:	eb 0c                	jmp    800479 <dev_lookup+0x2a>
  80046d:	b8 3c 30 80 00       	mov    $0x80303c,%eax
  800472:	eb 05                	jmp    800479 <dev_lookup+0x2a>
  800474:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800479:	89 03                	mov    %eax,(%ebx)
			return 0;
  80047b:	b8 00 00 00 00       	mov    $0x0,%eax
  800480:	eb 36                	jmp    8004b8 <dev_lookup+0x69>
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800482:	3b 05 20 30 80 00    	cmp    0x803020,%eax
  800488:	74 dc                	je     800466 <dev_lookup+0x17>
  80048a:	3b 05 3c 30 80 00    	cmp    0x80303c,%eax
  800490:	74 db                	je     80046d <dev_lookup+0x1e>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800492:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800498:	8b 52 48             	mov    0x48(%edx),%edx
  80049b:	83 ec 04             	sub    $0x4,%esp
  80049e:	50                   	push   %eax
  80049f:	52                   	push   %edx
  8004a0:	68 78 1e 80 00       	push   $0x801e78
  8004a5:	e8 23 0c 00 00       	call   8010cd <cprintf>
	*dev = 0;
  8004aa:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8004b0:	83 c4 10             	add    $0x10,%esp
  8004b3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004bb:	c9                   	leave  
  8004bc:	c3                   	ret    

008004bd <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004bd:	55                   	push   %ebp
  8004be:	89 e5                	mov    %esp,%ebp
  8004c0:	56                   	push   %esi
  8004c1:	53                   	push   %ebx
  8004c2:	83 ec 10             	sub    $0x10,%esp
  8004c5:	8b 75 08             	mov    0x8(%ebp),%esi
  8004c8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004ce:	50                   	push   %eax
  8004cf:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004d5:	c1 e8 0c             	shr    $0xc,%eax
  8004d8:	50                   	push   %eax
  8004d9:	e8 1a ff ff ff       	call   8003f8 <fd_lookup>
  8004de:	83 c4 08             	add    $0x8,%esp
  8004e1:	85 c0                	test   %eax,%eax
  8004e3:	78 05                	js     8004ea <fd_close+0x2d>
	    || fd != fd2)
  8004e5:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004e8:	74 06                	je     8004f0 <fd_close+0x33>
		return (must_exist ? r : 0);
  8004ea:	84 db                	test   %bl,%bl
  8004ec:	74 47                	je     800535 <fd_close+0x78>
  8004ee:	eb 4a                	jmp    80053a <fd_close+0x7d>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004f0:	83 ec 08             	sub    $0x8,%esp
  8004f3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004f6:	50                   	push   %eax
  8004f7:	ff 36                	pushl  (%esi)
  8004f9:	e8 51 ff ff ff       	call   80044f <dev_lookup>
  8004fe:	89 c3                	mov    %eax,%ebx
  800500:	83 c4 10             	add    $0x10,%esp
  800503:	85 c0                	test   %eax,%eax
  800505:	78 1c                	js     800523 <fd_close+0x66>
		if (dev->dev_close)
  800507:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80050a:	8b 40 10             	mov    0x10(%eax),%eax
  80050d:	85 c0                	test   %eax,%eax
  80050f:	74 0d                	je     80051e <fd_close+0x61>
			r = (*dev->dev_close)(fd);
  800511:	83 ec 0c             	sub    $0xc,%esp
  800514:	56                   	push   %esi
  800515:	ff d0                	call   *%eax
  800517:	89 c3                	mov    %eax,%ebx
  800519:	83 c4 10             	add    $0x10,%esp
  80051c:	eb 05                	jmp    800523 <fd_close+0x66>
		else
			r = 0;
  80051e:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800523:	83 ec 08             	sub    $0x8,%esp
  800526:	56                   	push   %esi
  800527:	6a 00                	push   $0x0
  800529:	e8 c3 fc ff ff       	call   8001f1 <sys_page_unmap>
	return r;
  80052e:	83 c4 10             	add    $0x10,%esp
  800531:	89 d8                	mov    %ebx,%eax
  800533:	eb 05                	jmp    80053a <fd_close+0x7d>
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
  800535:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
	return r;
}
  80053a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80053d:	5b                   	pop    %ebx
  80053e:	5e                   	pop    %esi
  80053f:	5d                   	pop    %ebp
  800540:	c3                   	ret    

00800541 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800541:	55                   	push   %ebp
  800542:	89 e5                	mov    %esp,%ebp
  800544:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800547:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80054a:	50                   	push   %eax
  80054b:	ff 75 08             	pushl  0x8(%ebp)
  80054e:	e8 a5 fe ff ff       	call   8003f8 <fd_lookup>
  800553:	83 c4 08             	add    $0x8,%esp
  800556:	85 c0                	test   %eax,%eax
  800558:	78 10                	js     80056a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80055a:	83 ec 08             	sub    $0x8,%esp
  80055d:	6a 01                	push   $0x1
  80055f:	ff 75 f4             	pushl  -0xc(%ebp)
  800562:	e8 56 ff ff ff       	call   8004bd <fd_close>
  800567:	83 c4 10             	add    $0x10,%esp
}
  80056a:	c9                   	leave  
  80056b:	c3                   	ret    

0080056c <close_all>:

void
close_all(void)
{
  80056c:	55                   	push   %ebp
  80056d:	89 e5                	mov    %esp,%ebp
  80056f:	53                   	push   %ebx
  800570:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800573:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800578:	83 ec 0c             	sub    $0xc,%esp
  80057b:	53                   	push   %ebx
  80057c:	e8 c0 ff ff ff       	call   800541 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800581:	43                   	inc    %ebx
  800582:	83 c4 10             	add    $0x10,%esp
  800585:	83 fb 20             	cmp    $0x20,%ebx
  800588:	75 ee                	jne    800578 <close_all+0xc>
		close(i);
}
  80058a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80058d:	c9                   	leave  
  80058e:	c3                   	ret    

0080058f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80058f:	55                   	push   %ebp
  800590:	89 e5                	mov    %esp,%ebp
  800592:	57                   	push   %edi
  800593:	56                   	push   %esi
  800594:	53                   	push   %ebx
  800595:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800598:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80059b:	50                   	push   %eax
  80059c:	ff 75 08             	pushl  0x8(%ebp)
  80059f:	e8 54 fe ff ff       	call   8003f8 <fd_lookup>
  8005a4:	83 c4 08             	add    $0x8,%esp
  8005a7:	85 c0                	test   %eax,%eax
  8005a9:	0f 88 c2 00 00 00    	js     800671 <dup+0xe2>
		return r;
	close(newfdnum);
  8005af:	83 ec 0c             	sub    $0xc,%esp
  8005b2:	ff 75 0c             	pushl  0xc(%ebp)
  8005b5:	e8 87 ff ff ff       	call   800541 <close>

	newfd = INDEX2FD(newfdnum);
  8005ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005bd:	c1 e3 0c             	shl    $0xc,%ebx
  8005c0:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8005c6:	83 c4 04             	add    $0x4,%esp
  8005c9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005cc:	e8 9c fd ff ff       	call   80036d <fd2data>
  8005d1:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  8005d3:	89 1c 24             	mov    %ebx,(%esp)
  8005d6:	e8 92 fd ff ff       	call   80036d <fd2data>
  8005db:	83 c4 10             	add    $0x10,%esp
  8005de:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005e0:	89 f0                	mov    %esi,%eax
  8005e2:	c1 e8 16             	shr    $0x16,%eax
  8005e5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005ec:	a8 01                	test   $0x1,%al
  8005ee:	74 35                	je     800625 <dup+0x96>
  8005f0:	89 f0                	mov    %esi,%eax
  8005f2:	c1 e8 0c             	shr    $0xc,%eax
  8005f5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005fc:	f6 c2 01             	test   $0x1,%dl
  8005ff:	74 24                	je     800625 <dup+0x96>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800601:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800608:	83 ec 0c             	sub    $0xc,%esp
  80060b:	25 07 0e 00 00       	and    $0xe07,%eax
  800610:	50                   	push   %eax
  800611:	57                   	push   %edi
  800612:	6a 00                	push   $0x0
  800614:	56                   	push   %esi
  800615:	6a 00                	push   $0x0
  800617:	e8 93 fb ff ff       	call   8001af <sys_page_map>
  80061c:	89 c6                	mov    %eax,%esi
  80061e:	83 c4 20             	add    $0x20,%esp
  800621:	85 c0                	test   %eax,%eax
  800623:	78 2c                	js     800651 <dup+0xc2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800625:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800628:	89 d0                	mov    %edx,%eax
  80062a:	c1 e8 0c             	shr    $0xc,%eax
  80062d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800634:	83 ec 0c             	sub    $0xc,%esp
  800637:	25 07 0e 00 00       	and    $0xe07,%eax
  80063c:	50                   	push   %eax
  80063d:	53                   	push   %ebx
  80063e:	6a 00                	push   $0x0
  800640:	52                   	push   %edx
  800641:	6a 00                	push   $0x0
  800643:	e8 67 fb ff ff       	call   8001af <sys_page_map>
  800648:	89 c6                	mov    %eax,%esi
  80064a:	83 c4 20             	add    $0x20,%esp
  80064d:	85 c0                	test   %eax,%eax
  80064f:	79 1d                	jns    80066e <dup+0xdf>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800651:	83 ec 08             	sub    $0x8,%esp
  800654:	53                   	push   %ebx
  800655:	6a 00                	push   $0x0
  800657:	e8 95 fb ff ff       	call   8001f1 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80065c:	83 c4 08             	add    $0x8,%esp
  80065f:	57                   	push   %edi
  800660:	6a 00                	push   $0x0
  800662:	e8 8a fb ff ff       	call   8001f1 <sys_page_unmap>
	return r;
  800667:	83 c4 10             	add    $0x10,%esp
  80066a:	89 f0                	mov    %esi,%eax
  80066c:	eb 03                	jmp    800671 <dup+0xe2>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80066e:	8b 45 0c             	mov    0xc(%ebp),%eax

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800671:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800674:	5b                   	pop    %ebx
  800675:	5e                   	pop    %esi
  800676:	5f                   	pop    %edi
  800677:	5d                   	pop    %ebp
  800678:	c3                   	ret    

00800679 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800679:	55                   	push   %ebp
  80067a:	89 e5                	mov    %esp,%ebp
  80067c:	53                   	push   %ebx
  80067d:	83 ec 14             	sub    $0x14,%esp
  800680:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800683:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800686:	50                   	push   %eax
  800687:	53                   	push   %ebx
  800688:	e8 6b fd ff ff       	call   8003f8 <fd_lookup>
  80068d:	83 c4 08             	add    $0x8,%esp
  800690:	85 c0                	test   %eax,%eax
  800692:	78 67                	js     8006fb <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800694:	83 ec 08             	sub    $0x8,%esp
  800697:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80069a:	50                   	push   %eax
  80069b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80069e:	ff 30                	pushl  (%eax)
  8006a0:	e8 aa fd ff ff       	call   80044f <dev_lookup>
  8006a5:	83 c4 10             	add    $0x10,%esp
  8006a8:	85 c0                	test   %eax,%eax
  8006aa:	78 4f                	js     8006fb <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006ac:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006af:	8b 42 08             	mov    0x8(%edx),%eax
  8006b2:	83 e0 03             	and    $0x3,%eax
  8006b5:	83 f8 01             	cmp    $0x1,%eax
  8006b8:	75 21                	jne    8006db <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006ba:	a1 04 40 80 00       	mov    0x804004,%eax
  8006bf:	8b 40 48             	mov    0x48(%eax),%eax
  8006c2:	83 ec 04             	sub    $0x4,%esp
  8006c5:	53                   	push   %ebx
  8006c6:	50                   	push   %eax
  8006c7:	68 b9 1e 80 00       	push   $0x801eb9
  8006cc:	e8 fc 09 00 00       	call   8010cd <cprintf>
		return -E_INVAL;
  8006d1:	83 c4 10             	add    $0x10,%esp
  8006d4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006d9:	eb 20                	jmp    8006fb <read+0x82>
	}
	if (!dev->dev_read)
  8006db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006de:	8b 40 08             	mov    0x8(%eax),%eax
  8006e1:	85 c0                	test   %eax,%eax
  8006e3:	74 11                	je     8006f6 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006e5:	83 ec 04             	sub    $0x4,%esp
  8006e8:	ff 75 10             	pushl  0x10(%ebp)
  8006eb:	ff 75 0c             	pushl  0xc(%ebp)
  8006ee:	52                   	push   %edx
  8006ef:	ff d0                	call   *%eax
  8006f1:	83 c4 10             	add    $0x10,%esp
  8006f4:	eb 05                	jmp    8006fb <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006f6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8006fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006fe:	c9                   	leave  
  8006ff:	c3                   	ret    

00800700 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800700:	55                   	push   %ebp
  800701:	89 e5                	mov    %esp,%ebp
  800703:	57                   	push   %edi
  800704:	56                   	push   %esi
  800705:	53                   	push   %ebx
  800706:	83 ec 0c             	sub    $0xc,%esp
  800709:	8b 7d 08             	mov    0x8(%ebp),%edi
  80070c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80070f:	85 f6                	test   %esi,%esi
  800711:	74 31                	je     800744 <readn+0x44>
  800713:	b8 00 00 00 00       	mov    $0x0,%eax
  800718:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  80071d:	83 ec 04             	sub    $0x4,%esp
  800720:	89 f2                	mov    %esi,%edx
  800722:	29 c2                	sub    %eax,%edx
  800724:	52                   	push   %edx
  800725:	03 45 0c             	add    0xc(%ebp),%eax
  800728:	50                   	push   %eax
  800729:	57                   	push   %edi
  80072a:	e8 4a ff ff ff       	call   800679 <read>
		if (m < 0)
  80072f:	83 c4 10             	add    $0x10,%esp
  800732:	85 c0                	test   %eax,%eax
  800734:	78 17                	js     80074d <readn+0x4d>
			return m;
		if (m == 0)
  800736:	85 c0                	test   %eax,%eax
  800738:	74 11                	je     80074b <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80073a:	01 c3                	add    %eax,%ebx
  80073c:	89 d8                	mov    %ebx,%eax
  80073e:	39 f3                	cmp    %esi,%ebx
  800740:	72 db                	jb     80071d <readn+0x1d>
  800742:	eb 09                	jmp    80074d <readn+0x4d>
  800744:	b8 00 00 00 00       	mov    $0x0,%eax
  800749:	eb 02                	jmp    80074d <readn+0x4d>
  80074b:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80074d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800750:	5b                   	pop    %ebx
  800751:	5e                   	pop    %esi
  800752:	5f                   	pop    %edi
  800753:	5d                   	pop    %ebp
  800754:	c3                   	ret    

00800755 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800755:	55                   	push   %ebp
  800756:	89 e5                	mov    %esp,%ebp
  800758:	53                   	push   %ebx
  800759:	83 ec 14             	sub    $0x14,%esp
  80075c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80075f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800762:	50                   	push   %eax
  800763:	53                   	push   %ebx
  800764:	e8 8f fc ff ff       	call   8003f8 <fd_lookup>
  800769:	83 c4 08             	add    $0x8,%esp
  80076c:	85 c0                	test   %eax,%eax
  80076e:	78 62                	js     8007d2 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800770:	83 ec 08             	sub    $0x8,%esp
  800773:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800776:	50                   	push   %eax
  800777:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80077a:	ff 30                	pushl  (%eax)
  80077c:	e8 ce fc ff ff       	call   80044f <dev_lookup>
  800781:	83 c4 10             	add    $0x10,%esp
  800784:	85 c0                	test   %eax,%eax
  800786:	78 4a                	js     8007d2 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800788:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80078b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80078f:	75 21                	jne    8007b2 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800791:	a1 04 40 80 00       	mov    0x804004,%eax
  800796:	8b 40 48             	mov    0x48(%eax),%eax
  800799:	83 ec 04             	sub    $0x4,%esp
  80079c:	53                   	push   %ebx
  80079d:	50                   	push   %eax
  80079e:	68 d5 1e 80 00       	push   $0x801ed5
  8007a3:	e8 25 09 00 00       	call   8010cd <cprintf>
		return -E_INVAL;
  8007a8:	83 c4 10             	add    $0x10,%esp
  8007ab:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007b0:	eb 20                	jmp    8007d2 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007b2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007b5:	8b 52 0c             	mov    0xc(%edx),%edx
  8007b8:	85 d2                	test   %edx,%edx
  8007ba:	74 11                	je     8007cd <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007bc:	83 ec 04             	sub    $0x4,%esp
  8007bf:	ff 75 10             	pushl  0x10(%ebp)
  8007c2:	ff 75 0c             	pushl  0xc(%ebp)
  8007c5:	50                   	push   %eax
  8007c6:	ff d2                	call   *%edx
  8007c8:	83 c4 10             	add    $0x10,%esp
  8007cb:	eb 05                	jmp    8007d2 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007cd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8007d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d5:	c9                   	leave  
  8007d6:	c3                   	ret    

008007d7 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007d7:	55                   	push   %ebp
  8007d8:	89 e5                	mov    %esp,%ebp
  8007da:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007dd:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007e0:	50                   	push   %eax
  8007e1:	ff 75 08             	pushl  0x8(%ebp)
  8007e4:	e8 0f fc ff ff       	call   8003f8 <fd_lookup>
  8007e9:	83 c4 08             	add    $0x8,%esp
  8007ec:	85 c0                	test   %eax,%eax
  8007ee:	78 0e                	js     8007fe <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007f0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007f9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007fe:	c9                   	leave  
  8007ff:	c3                   	ret    

00800800 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	53                   	push   %ebx
  800804:	83 ec 14             	sub    $0x14,%esp
  800807:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80080a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80080d:	50                   	push   %eax
  80080e:	53                   	push   %ebx
  80080f:	e8 e4 fb ff ff       	call   8003f8 <fd_lookup>
  800814:	83 c4 08             	add    $0x8,%esp
  800817:	85 c0                	test   %eax,%eax
  800819:	78 5f                	js     80087a <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80081b:	83 ec 08             	sub    $0x8,%esp
  80081e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800821:	50                   	push   %eax
  800822:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800825:	ff 30                	pushl  (%eax)
  800827:	e8 23 fc ff ff       	call   80044f <dev_lookup>
  80082c:	83 c4 10             	add    $0x10,%esp
  80082f:	85 c0                	test   %eax,%eax
  800831:	78 47                	js     80087a <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800833:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800836:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80083a:	75 21                	jne    80085d <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80083c:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800841:	8b 40 48             	mov    0x48(%eax),%eax
  800844:	83 ec 04             	sub    $0x4,%esp
  800847:	53                   	push   %ebx
  800848:	50                   	push   %eax
  800849:	68 98 1e 80 00       	push   $0x801e98
  80084e:	e8 7a 08 00 00       	call   8010cd <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800853:	83 c4 10             	add    $0x10,%esp
  800856:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80085b:	eb 1d                	jmp    80087a <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  80085d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800860:	8b 52 18             	mov    0x18(%edx),%edx
  800863:	85 d2                	test   %edx,%edx
  800865:	74 0e                	je     800875 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800867:	83 ec 08             	sub    $0x8,%esp
  80086a:	ff 75 0c             	pushl  0xc(%ebp)
  80086d:	50                   	push   %eax
  80086e:	ff d2                	call   *%edx
  800870:	83 c4 10             	add    $0x10,%esp
  800873:	eb 05                	jmp    80087a <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800875:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80087a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80087d:	c9                   	leave  
  80087e:	c3                   	ret    

0080087f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80087f:	55                   	push   %ebp
  800880:	89 e5                	mov    %esp,%ebp
  800882:	53                   	push   %ebx
  800883:	83 ec 14             	sub    $0x14,%esp
  800886:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800889:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80088c:	50                   	push   %eax
  80088d:	ff 75 08             	pushl  0x8(%ebp)
  800890:	e8 63 fb ff ff       	call   8003f8 <fd_lookup>
  800895:	83 c4 08             	add    $0x8,%esp
  800898:	85 c0                	test   %eax,%eax
  80089a:	78 52                	js     8008ee <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80089c:	83 ec 08             	sub    $0x8,%esp
  80089f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008a2:	50                   	push   %eax
  8008a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008a6:	ff 30                	pushl  (%eax)
  8008a8:	e8 a2 fb ff ff       	call   80044f <dev_lookup>
  8008ad:	83 c4 10             	add    $0x10,%esp
  8008b0:	85 c0                	test   %eax,%eax
  8008b2:	78 3a                	js     8008ee <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  8008b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008b7:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008bb:	74 2c                	je     8008e9 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008bd:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008c0:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008c7:	00 00 00 
	stat->st_isdir = 0;
  8008ca:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008d1:	00 00 00 
	stat->st_dev = dev;
  8008d4:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008da:	83 ec 08             	sub    $0x8,%esp
  8008dd:	53                   	push   %ebx
  8008de:	ff 75 f0             	pushl  -0x10(%ebp)
  8008e1:	ff 50 14             	call   *0x14(%eax)
  8008e4:	83 c4 10             	add    $0x10,%esp
  8008e7:	eb 05                	jmp    8008ee <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008e9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008f1:	c9                   	leave  
  8008f2:	c3                   	ret    

008008f3 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008f3:	55                   	push   %ebp
  8008f4:	89 e5                	mov    %esp,%ebp
  8008f6:	56                   	push   %esi
  8008f7:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008f8:	83 ec 08             	sub    $0x8,%esp
  8008fb:	6a 00                	push   $0x0
  8008fd:	ff 75 08             	pushl  0x8(%ebp)
  800900:	e8 75 01 00 00       	call   800a7a <open>
  800905:	89 c3                	mov    %eax,%ebx
  800907:	83 c4 10             	add    $0x10,%esp
  80090a:	85 c0                	test   %eax,%eax
  80090c:	78 1d                	js     80092b <stat+0x38>
		return fd;
	r = fstat(fd, stat);
  80090e:	83 ec 08             	sub    $0x8,%esp
  800911:	ff 75 0c             	pushl  0xc(%ebp)
  800914:	50                   	push   %eax
  800915:	e8 65 ff ff ff       	call   80087f <fstat>
  80091a:	89 c6                	mov    %eax,%esi
	close(fd);
  80091c:	89 1c 24             	mov    %ebx,(%esp)
  80091f:	e8 1d fc ff ff       	call   800541 <close>
	return r;
  800924:	83 c4 10             	add    $0x10,%esp
  800927:	89 f0                	mov    %esi,%eax
  800929:	eb 00                	jmp    80092b <stat+0x38>
}
  80092b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80092e:	5b                   	pop    %ebx
  80092f:	5e                   	pop    %esi
  800930:	5d                   	pop    %ebp
  800931:	c3                   	ret    

00800932 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800932:	55                   	push   %ebp
  800933:	89 e5                	mov    %esp,%ebp
  800935:	56                   	push   %esi
  800936:	53                   	push   %ebx
  800937:	89 c6                	mov    %eax,%esi
  800939:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80093b:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800942:	75 12                	jne    800956 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800944:	83 ec 0c             	sub    $0xc,%esp
  800947:	6a 01                	push   $0x1
  800949:	e8 ec 11 00 00       	call   801b3a <ipc_find_env>
  80094e:	a3 00 40 80 00       	mov    %eax,0x804000
  800953:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800956:	6a 07                	push   $0x7
  800958:	68 00 50 80 00       	push   $0x805000
  80095d:	56                   	push   %esi
  80095e:	ff 35 00 40 80 00    	pushl  0x804000
  800964:	e8 72 11 00 00       	call   801adb <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800969:	83 c4 0c             	add    $0xc,%esp
  80096c:	6a 00                	push   $0x0
  80096e:	53                   	push   %ebx
  80096f:	6a 00                	push   $0x0
  800971:	e8 f0 10 00 00       	call   801a66 <ipc_recv>
}
  800976:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800979:	5b                   	pop    %ebx
  80097a:	5e                   	pop    %esi
  80097b:	5d                   	pop    %ebp
  80097c:	c3                   	ret    

0080097d <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80097d:	55                   	push   %ebp
  80097e:	89 e5                	mov    %esp,%ebp
  800980:	53                   	push   %ebx
  800981:	83 ec 04             	sub    $0x4,%esp
  800984:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800987:	8b 45 08             	mov    0x8(%ebp),%eax
  80098a:	8b 40 0c             	mov    0xc(%eax),%eax
  80098d:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800992:	ba 00 00 00 00       	mov    $0x0,%edx
  800997:	b8 05 00 00 00       	mov    $0x5,%eax
  80099c:	e8 91 ff ff ff       	call   800932 <fsipc>
  8009a1:	85 c0                	test   %eax,%eax
  8009a3:	78 2c                	js     8009d1 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009a5:	83 ec 08             	sub    $0x8,%esp
  8009a8:	68 00 50 80 00       	push   $0x805000
  8009ad:	53                   	push   %ebx
  8009ae:	e8 ff 0c 00 00       	call   8016b2 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009b3:	a1 80 50 80 00       	mov    0x805080,%eax
  8009b8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009be:	a1 84 50 80 00       	mov    0x805084,%eax
  8009c3:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009c9:	83 c4 10             	add    $0x10,%esp
  8009cc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009d4:	c9                   	leave  
  8009d5:	c3                   	ret    

008009d6 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009d6:	55                   	push   %ebp
  8009d7:	89 e5                	mov    %esp,%ebp
  8009d9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009df:	8b 40 0c             	mov    0xc(%eax),%eax
  8009e2:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ec:	b8 06 00 00 00       	mov    $0x6,%eax
  8009f1:	e8 3c ff ff ff       	call   800932 <fsipc>
}
  8009f6:	c9                   	leave  
  8009f7:	c3                   	ret    

008009f8 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8009f8:	55                   	push   %ebp
  8009f9:	89 e5                	mov    %esp,%ebp
  8009fb:	56                   	push   %esi
  8009fc:	53                   	push   %ebx
  8009fd:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a00:	8b 45 08             	mov    0x8(%ebp),%eax
  800a03:	8b 40 0c             	mov    0xc(%eax),%eax
  800a06:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a0b:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a11:	ba 00 00 00 00       	mov    $0x0,%edx
  800a16:	b8 03 00 00 00       	mov    $0x3,%eax
  800a1b:	e8 12 ff ff ff       	call   800932 <fsipc>
  800a20:	89 c3                	mov    %eax,%ebx
  800a22:	85 c0                	test   %eax,%eax
  800a24:	78 4b                	js     800a71 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a26:	39 c6                	cmp    %eax,%esi
  800a28:	73 16                	jae    800a40 <devfile_read+0x48>
  800a2a:	68 f2 1e 80 00       	push   $0x801ef2
  800a2f:	68 f9 1e 80 00       	push   $0x801ef9
  800a34:	6a 7a                	push   $0x7a
  800a36:	68 0e 1f 80 00       	push   $0x801f0e
  800a3b:	e8 b5 05 00 00       	call   800ff5 <_panic>
	assert(r <= PGSIZE);
  800a40:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a45:	7e 16                	jle    800a5d <devfile_read+0x65>
  800a47:	68 19 1f 80 00       	push   $0x801f19
  800a4c:	68 f9 1e 80 00       	push   $0x801ef9
  800a51:	6a 7b                	push   $0x7b
  800a53:	68 0e 1f 80 00       	push   $0x801f0e
  800a58:	e8 98 05 00 00       	call   800ff5 <_panic>
	memmove(buf, &fsipcbuf, r);
  800a5d:	83 ec 04             	sub    $0x4,%esp
  800a60:	50                   	push   %eax
  800a61:	68 00 50 80 00       	push   $0x805000
  800a66:	ff 75 0c             	pushl  0xc(%ebp)
  800a69:	e8 11 0e 00 00       	call   80187f <memmove>
	return r;
  800a6e:	83 c4 10             	add    $0x10,%esp
}
  800a71:	89 d8                	mov    %ebx,%eax
  800a73:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a76:	5b                   	pop    %ebx
  800a77:	5e                   	pop    %esi
  800a78:	5d                   	pop    %ebp
  800a79:	c3                   	ret    

00800a7a <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800a7a:	55                   	push   %ebp
  800a7b:	89 e5                	mov    %esp,%ebp
  800a7d:	53                   	push   %ebx
  800a7e:	83 ec 20             	sub    $0x20,%esp
  800a81:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800a84:	53                   	push   %ebx
  800a85:	e8 d1 0b 00 00       	call   80165b <strlen>
  800a8a:	83 c4 10             	add    $0x10,%esp
  800a8d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800a92:	7f 63                	jg     800af7 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800a94:	83 ec 0c             	sub    $0xc,%esp
  800a97:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a9a:	50                   	push   %eax
  800a9b:	e8 e4 f8 ff ff       	call   800384 <fd_alloc>
  800aa0:	83 c4 10             	add    $0x10,%esp
  800aa3:	85 c0                	test   %eax,%eax
  800aa5:	78 55                	js     800afc <open+0x82>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800aa7:	83 ec 08             	sub    $0x8,%esp
  800aaa:	53                   	push   %ebx
  800aab:	68 00 50 80 00       	push   $0x805000
  800ab0:	e8 fd 0b 00 00       	call   8016b2 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800ab5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab8:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800abd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ac0:	b8 01 00 00 00       	mov    $0x1,%eax
  800ac5:	e8 68 fe ff ff       	call   800932 <fsipc>
  800aca:	89 c3                	mov    %eax,%ebx
  800acc:	83 c4 10             	add    $0x10,%esp
  800acf:	85 c0                	test   %eax,%eax
  800ad1:	79 14                	jns    800ae7 <open+0x6d>
		fd_close(fd, 0);
  800ad3:	83 ec 08             	sub    $0x8,%esp
  800ad6:	6a 00                	push   $0x0
  800ad8:	ff 75 f4             	pushl  -0xc(%ebp)
  800adb:	e8 dd f9 ff ff       	call   8004bd <fd_close>
		return r;
  800ae0:	83 c4 10             	add    $0x10,%esp
  800ae3:	89 d8                	mov    %ebx,%eax
  800ae5:	eb 15                	jmp    800afc <open+0x82>
	}

	return fd2num(fd);
  800ae7:	83 ec 0c             	sub    $0xc,%esp
  800aea:	ff 75 f4             	pushl  -0xc(%ebp)
  800aed:	e8 6b f8 ff ff       	call   80035d <fd2num>
  800af2:	83 c4 10             	add    $0x10,%esp
  800af5:	eb 05                	jmp    800afc <open+0x82>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800af7:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800afc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800aff:	c9                   	leave  
  800b00:	c3                   	ret    

00800b01 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b01:	55                   	push   %ebp
  800b02:	89 e5                	mov    %esp,%ebp
  800b04:	56                   	push   %esi
  800b05:	53                   	push   %ebx
  800b06:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b09:	83 ec 0c             	sub    $0xc,%esp
  800b0c:	ff 75 08             	pushl  0x8(%ebp)
  800b0f:	e8 59 f8 ff ff       	call   80036d <fd2data>
  800b14:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b16:	83 c4 08             	add    $0x8,%esp
  800b19:	68 25 1f 80 00       	push   $0x801f25
  800b1e:	53                   	push   %ebx
  800b1f:	e8 8e 0b 00 00       	call   8016b2 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b24:	8b 46 04             	mov    0x4(%esi),%eax
  800b27:	2b 06                	sub    (%esi),%eax
  800b29:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b2f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b36:	00 00 00 
	stat->st_dev = &devpipe;
  800b39:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800b40:	30 80 00 
	return 0;
}
  800b43:	b8 00 00 00 00       	mov    $0x0,%eax
  800b48:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b4b:	5b                   	pop    %ebx
  800b4c:	5e                   	pop    %esi
  800b4d:	5d                   	pop    %ebp
  800b4e:	c3                   	ret    

00800b4f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b4f:	55                   	push   %ebp
  800b50:	89 e5                	mov    %esp,%ebp
  800b52:	53                   	push   %ebx
  800b53:	83 ec 0c             	sub    $0xc,%esp
  800b56:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800b59:	53                   	push   %ebx
  800b5a:	6a 00                	push   $0x0
  800b5c:	e8 90 f6 ff ff       	call   8001f1 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800b61:	89 1c 24             	mov    %ebx,(%esp)
  800b64:	e8 04 f8 ff ff       	call   80036d <fd2data>
  800b69:	83 c4 08             	add    $0x8,%esp
  800b6c:	50                   	push   %eax
  800b6d:	6a 00                	push   $0x0
  800b6f:	e8 7d f6 ff ff       	call   8001f1 <sys_page_unmap>
}
  800b74:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b77:	c9                   	leave  
  800b78:	c3                   	ret    

00800b79 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800b79:	55                   	push   %ebp
  800b7a:	89 e5                	mov    %esp,%ebp
  800b7c:	57                   	push   %edi
  800b7d:	56                   	push   %esi
  800b7e:	53                   	push   %ebx
  800b7f:	83 ec 1c             	sub    $0x1c,%esp
  800b82:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b85:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800b87:	a1 04 40 80 00       	mov    0x804004,%eax
  800b8c:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800b8f:	83 ec 0c             	sub    $0xc,%esp
  800b92:	ff 75 e0             	pushl  -0x20(%ebp)
  800b95:	e8 fb 0f 00 00       	call   801b95 <pageref>
  800b9a:	89 c3                	mov    %eax,%ebx
  800b9c:	89 3c 24             	mov    %edi,(%esp)
  800b9f:	e8 f1 0f 00 00       	call   801b95 <pageref>
  800ba4:	83 c4 10             	add    $0x10,%esp
  800ba7:	39 c3                	cmp    %eax,%ebx
  800ba9:	0f 94 c1             	sete   %cl
  800bac:	0f b6 c9             	movzbl %cl,%ecx
  800baf:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800bb2:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800bb8:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800bbb:	39 ce                	cmp    %ecx,%esi
  800bbd:	74 1b                	je     800bda <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800bbf:	39 c3                	cmp    %eax,%ebx
  800bc1:	75 c4                	jne    800b87 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800bc3:	8b 42 58             	mov    0x58(%edx),%eax
  800bc6:	ff 75 e4             	pushl  -0x1c(%ebp)
  800bc9:	50                   	push   %eax
  800bca:	56                   	push   %esi
  800bcb:	68 2c 1f 80 00       	push   $0x801f2c
  800bd0:	e8 f8 04 00 00       	call   8010cd <cprintf>
  800bd5:	83 c4 10             	add    $0x10,%esp
  800bd8:	eb ad                	jmp    800b87 <_pipeisclosed+0xe>
	}
}
  800bda:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800bdd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be0:	5b                   	pop    %ebx
  800be1:	5e                   	pop    %esi
  800be2:	5f                   	pop    %edi
  800be3:	5d                   	pop    %ebp
  800be4:	c3                   	ret    

00800be5 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800be5:	55                   	push   %ebp
  800be6:	89 e5                	mov    %esp,%ebp
  800be8:	57                   	push   %edi
  800be9:	56                   	push   %esi
  800bea:	53                   	push   %ebx
  800beb:	83 ec 18             	sub    $0x18,%esp
  800bee:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800bf1:	56                   	push   %esi
  800bf2:	e8 76 f7 ff ff       	call   80036d <fd2data>
  800bf7:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800bf9:	83 c4 10             	add    $0x10,%esp
  800bfc:	bf 00 00 00 00       	mov    $0x0,%edi
  800c01:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c05:	75 42                	jne    800c49 <devpipe_write+0x64>
  800c07:	eb 4e                	jmp    800c57 <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c09:	89 da                	mov    %ebx,%edx
  800c0b:	89 f0                	mov    %esi,%eax
  800c0d:	e8 67 ff ff ff       	call   800b79 <_pipeisclosed>
  800c12:	85 c0                	test   %eax,%eax
  800c14:	75 46                	jne    800c5c <devpipe_write+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c16:	e8 32 f5 ff ff       	call   80014d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c1b:	8b 53 04             	mov    0x4(%ebx),%edx
  800c1e:	8b 03                	mov    (%ebx),%eax
  800c20:	83 c0 20             	add    $0x20,%eax
  800c23:	39 c2                	cmp    %eax,%edx
  800c25:	73 e2                	jae    800c09 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c27:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c2a:	8a 0c 38             	mov    (%eax,%edi,1),%cl
  800c2d:	89 d0                	mov    %edx,%eax
  800c2f:	25 1f 00 00 80       	and    $0x8000001f,%eax
  800c34:	79 05                	jns    800c3b <devpipe_write+0x56>
  800c36:	48                   	dec    %eax
  800c37:	83 c8 e0             	or     $0xffffffe0,%eax
  800c3a:	40                   	inc    %eax
  800c3b:	88 4c 03 08          	mov    %cl,0x8(%ebx,%eax,1)
		p->p_wpos++;
  800c3f:	42                   	inc    %edx
  800c40:	89 53 04             	mov    %edx,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c43:	47                   	inc    %edi
  800c44:	39 7d 10             	cmp    %edi,0x10(%ebp)
  800c47:	74 0e                	je     800c57 <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c49:	8b 53 04             	mov    0x4(%ebx),%edx
  800c4c:	8b 03                	mov    (%ebx),%eax
  800c4e:	83 c0 20             	add    $0x20,%eax
  800c51:	39 c2                	cmp    %eax,%edx
  800c53:	73 b4                	jae    800c09 <devpipe_write+0x24>
  800c55:	eb d0                	jmp    800c27 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800c57:	8b 45 10             	mov    0x10(%ebp),%eax
  800c5a:	eb 05                	jmp    800c61 <devpipe_write+0x7c>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800c5c:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800c61:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c64:	5b                   	pop    %ebx
  800c65:	5e                   	pop    %esi
  800c66:	5f                   	pop    %edi
  800c67:	5d                   	pop    %ebp
  800c68:	c3                   	ret    

00800c69 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800c69:	55                   	push   %ebp
  800c6a:	89 e5                	mov    %esp,%ebp
  800c6c:	57                   	push   %edi
  800c6d:	56                   	push   %esi
  800c6e:	53                   	push   %ebx
  800c6f:	83 ec 18             	sub    $0x18,%esp
  800c72:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800c75:	57                   	push   %edi
  800c76:	e8 f2 f6 ff ff       	call   80036d <fd2data>
  800c7b:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c7d:	83 c4 10             	add    $0x10,%esp
  800c80:	be 00 00 00 00       	mov    $0x0,%esi
  800c85:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c89:	75 3d                	jne    800cc8 <devpipe_read+0x5f>
  800c8b:	eb 48                	jmp    800cd5 <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  800c8d:	89 f0                	mov    %esi,%eax
  800c8f:	eb 4e                	jmp    800cdf <devpipe_read+0x76>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800c91:	89 da                	mov    %ebx,%edx
  800c93:	89 f8                	mov    %edi,%eax
  800c95:	e8 df fe ff ff       	call   800b79 <_pipeisclosed>
  800c9a:	85 c0                	test   %eax,%eax
  800c9c:	75 3c                	jne    800cda <devpipe_read+0x71>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800c9e:	e8 aa f4 ff ff       	call   80014d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800ca3:	8b 03                	mov    (%ebx),%eax
  800ca5:	3b 43 04             	cmp    0x4(%ebx),%eax
  800ca8:	74 e7                	je     800c91 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800caa:	25 1f 00 00 80       	and    $0x8000001f,%eax
  800caf:	79 05                	jns    800cb6 <devpipe_read+0x4d>
  800cb1:	48                   	dec    %eax
  800cb2:	83 c8 e0             	or     $0xffffffe0,%eax
  800cb5:	40                   	inc    %eax
  800cb6:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  800cba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbd:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800cc0:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cc2:	46                   	inc    %esi
  800cc3:	39 75 10             	cmp    %esi,0x10(%ebp)
  800cc6:	74 0d                	je     800cd5 <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
  800cc8:	8b 03                	mov    (%ebx),%eax
  800cca:	3b 43 04             	cmp    0x4(%ebx),%eax
  800ccd:	75 db                	jne    800caa <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800ccf:	85 f6                	test   %esi,%esi
  800cd1:	75 ba                	jne    800c8d <devpipe_read+0x24>
  800cd3:	eb bc                	jmp    800c91 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800cd5:	8b 45 10             	mov    0x10(%ebp),%eax
  800cd8:	eb 05                	jmp    800cdf <devpipe_read+0x76>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cda:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800cdf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce2:	5b                   	pop    %ebx
  800ce3:	5e                   	pop    %esi
  800ce4:	5f                   	pop    %edi
  800ce5:	5d                   	pop    %ebp
  800ce6:	c3                   	ret    

00800ce7 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	56                   	push   %esi
  800ceb:	53                   	push   %ebx
  800cec:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800cef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800cf2:	50                   	push   %eax
  800cf3:	e8 8c f6 ff ff       	call   800384 <fd_alloc>
  800cf8:	83 c4 10             	add    $0x10,%esp
  800cfb:	85 c0                	test   %eax,%eax
  800cfd:	0f 88 2a 01 00 00    	js     800e2d <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d03:	83 ec 04             	sub    $0x4,%esp
  800d06:	68 07 04 00 00       	push   $0x407
  800d0b:	ff 75 f4             	pushl  -0xc(%ebp)
  800d0e:	6a 00                	push   $0x0
  800d10:	e8 57 f4 ff ff       	call   80016c <sys_page_alloc>
  800d15:	83 c4 10             	add    $0x10,%esp
  800d18:	85 c0                	test   %eax,%eax
  800d1a:	0f 88 0d 01 00 00    	js     800e2d <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d20:	83 ec 0c             	sub    $0xc,%esp
  800d23:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d26:	50                   	push   %eax
  800d27:	e8 58 f6 ff ff       	call   800384 <fd_alloc>
  800d2c:	89 c3                	mov    %eax,%ebx
  800d2e:	83 c4 10             	add    $0x10,%esp
  800d31:	85 c0                	test   %eax,%eax
  800d33:	0f 88 e2 00 00 00    	js     800e1b <pipe+0x134>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d39:	83 ec 04             	sub    $0x4,%esp
  800d3c:	68 07 04 00 00       	push   $0x407
  800d41:	ff 75 f0             	pushl  -0x10(%ebp)
  800d44:	6a 00                	push   $0x0
  800d46:	e8 21 f4 ff ff       	call   80016c <sys_page_alloc>
  800d4b:	89 c3                	mov    %eax,%ebx
  800d4d:	83 c4 10             	add    $0x10,%esp
  800d50:	85 c0                	test   %eax,%eax
  800d52:	0f 88 c3 00 00 00    	js     800e1b <pipe+0x134>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800d58:	83 ec 0c             	sub    $0xc,%esp
  800d5b:	ff 75 f4             	pushl  -0xc(%ebp)
  800d5e:	e8 0a f6 ff ff       	call   80036d <fd2data>
  800d63:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d65:	83 c4 0c             	add    $0xc,%esp
  800d68:	68 07 04 00 00       	push   $0x407
  800d6d:	50                   	push   %eax
  800d6e:	6a 00                	push   $0x0
  800d70:	e8 f7 f3 ff ff       	call   80016c <sys_page_alloc>
  800d75:	89 c3                	mov    %eax,%ebx
  800d77:	83 c4 10             	add    $0x10,%esp
  800d7a:	85 c0                	test   %eax,%eax
  800d7c:	0f 88 89 00 00 00    	js     800e0b <pipe+0x124>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d82:	83 ec 0c             	sub    $0xc,%esp
  800d85:	ff 75 f0             	pushl  -0x10(%ebp)
  800d88:	e8 e0 f5 ff ff       	call   80036d <fd2data>
  800d8d:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800d94:	50                   	push   %eax
  800d95:	6a 00                	push   $0x0
  800d97:	56                   	push   %esi
  800d98:	6a 00                	push   $0x0
  800d9a:	e8 10 f4 ff ff       	call   8001af <sys_page_map>
  800d9f:	89 c3                	mov    %eax,%ebx
  800da1:	83 c4 20             	add    $0x20,%esp
  800da4:	85 c0                	test   %eax,%eax
  800da6:	78 55                	js     800dfd <pipe+0x116>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800da8:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800dae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800db1:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800db3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800db6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800dbd:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800dc3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dc6:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800dc8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dcb:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800dd2:	83 ec 0c             	sub    $0xc,%esp
  800dd5:	ff 75 f4             	pushl  -0xc(%ebp)
  800dd8:	e8 80 f5 ff ff       	call   80035d <fd2num>
  800ddd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800de0:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800de2:	83 c4 04             	add    $0x4,%esp
  800de5:	ff 75 f0             	pushl  -0x10(%ebp)
  800de8:	e8 70 f5 ff ff       	call   80035d <fd2num>
  800ded:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800df0:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800df3:	83 c4 10             	add    $0x10,%esp
  800df6:	b8 00 00 00 00       	mov    $0x0,%eax
  800dfb:	eb 30                	jmp    800e2d <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  800dfd:	83 ec 08             	sub    $0x8,%esp
  800e00:	56                   	push   %esi
  800e01:	6a 00                	push   $0x0
  800e03:	e8 e9 f3 ff ff       	call   8001f1 <sys_page_unmap>
  800e08:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e0b:	83 ec 08             	sub    $0x8,%esp
  800e0e:	ff 75 f0             	pushl  -0x10(%ebp)
  800e11:	6a 00                	push   $0x0
  800e13:	e8 d9 f3 ff ff       	call   8001f1 <sys_page_unmap>
  800e18:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e1b:	83 ec 08             	sub    $0x8,%esp
  800e1e:	ff 75 f4             	pushl  -0xc(%ebp)
  800e21:	6a 00                	push   $0x0
  800e23:	e8 c9 f3 ff ff       	call   8001f1 <sys_page_unmap>
  800e28:	83 c4 10             	add    $0x10,%esp
  800e2b:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  800e2d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e30:	5b                   	pop    %ebx
  800e31:	5e                   	pop    %esi
  800e32:	5d                   	pop    %ebp
  800e33:	c3                   	ret    

00800e34 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e34:	55                   	push   %ebp
  800e35:	89 e5                	mov    %esp,%ebp
  800e37:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e3a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e3d:	50                   	push   %eax
  800e3e:	ff 75 08             	pushl  0x8(%ebp)
  800e41:	e8 b2 f5 ff ff       	call   8003f8 <fd_lookup>
  800e46:	83 c4 10             	add    $0x10,%esp
  800e49:	85 c0                	test   %eax,%eax
  800e4b:	78 18                	js     800e65 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800e4d:	83 ec 0c             	sub    $0xc,%esp
  800e50:	ff 75 f4             	pushl  -0xc(%ebp)
  800e53:	e8 15 f5 ff ff       	call   80036d <fd2data>
	return _pipeisclosed(fd, p);
  800e58:	89 c2                	mov    %eax,%edx
  800e5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e5d:	e8 17 fd ff ff       	call   800b79 <_pipeisclosed>
  800e62:	83 c4 10             	add    $0x10,%esp
}
  800e65:	c9                   	leave  
  800e66:	c3                   	ret    

00800e67 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800e67:	55                   	push   %ebp
  800e68:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800e6a:	b8 00 00 00 00       	mov    $0x0,%eax
  800e6f:	5d                   	pop    %ebp
  800e70:	c3                   	ret    

00800e71 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800e71:	55                   	push   %ebp
  800e72:	89 e5                	mov    %esp,%ebp
  800e74:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800e77:	68 44 1f 80 00       	push   $0x801f44
  800e7c:	ff 75 0c             	pushl  0xc(%ebp)
  800e7f:	e8 2e 08 00 00       	call   8016b2 <strcpy>
	return 0;
}
  800e84:	b8 00 00 00 00       	mov    $0x0,%eax
  800e89:	c9                   	leave  
  800e8a:	c3                   	ret    

00800e8b <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800e8b:	55                   	push   %ebp
  800e8c:	89 e5                	mov    %esp,%ebp
  800e8e:	57                   	push   %edi
  800e8f:	56                   	push   %esi
  800e90:	53                   	push   %ebx
  800e91:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800e97:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e9b:	74 45                	je     800ee2 <devcons_write+0x57>
  800e9d:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea2:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800ea7:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800ead:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eb0:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  800eb2:	83 fb 7f             	cmp    $0x7f,%ebx
  800eb5:	76 05                	jbe    800ebc <devcons_write+0x31>
			m = sizeof(buf) - 1;
  800eb7:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800ebc:	83 ec 04             	sub    $0x4,%esp
  800ebf:	53                   	push   %ebx
  800ec0:	03 45 0c             	add    0xc(%ebp),%eax
  800ec3:	50                   	push   %eax
  800ec4:	57                   	push   %edi
  800ec5:	e8 b5 09 00 00       	call   80187f <memmove>
		sys_cputs(buf, m);
  800eca:	83 c4 08             	add    $0x8,%esp
  800ecd:	53                   	push   %ebx
  800ece:	57                   	push   %edi
  800ecf:	e8 dc f1 ff ff       	call   8000b0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ed4:	01 de                	add    %ebx,%esi
  800ed6:	89 f0                	mov    %esi,%eax
  800ed8:	83 c4 10             	add    $0x10,%esp
  800edb:	3b 75 10             	cmp    0x10(%ebp),%esi
  800ede:	72 cd                	jb     800ead <devcons_write+0x22>
  800ee0:	eb 05                	jmp    800ee7 <devcons_write+0x5c>
  800ee2:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800ee7:	89 f0                	mov    %esi,%eax
  800ee9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eec:	5b                   	pop    %ebx
  800eed:	5e                   	pop    %esi
  800eee:	5f                   	pop    %edi
  800eef:	5d                   	pop    %ebp
  800ef0:	c3                   	ret    

00800ef1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800ef1:	55                   	push   %ebp
  800ef2:	89 e5                	mov    %esp,%ebp
  800ef4:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  800ef7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800efb:	75 07                	jne    800f04 <devcons_read+0x13>
  800efd:	eb 23                	jmp    800f22 <devcons_read+0x31>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800eff:	e8 49 f2 ff ff       	call   80014d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f04:	e8 c5 f1 ff ff       	call   8000ce <sys_cgetc>
  800f09:	85 c0                	test   %eax,%eax
  800f0b:	74 f2                	je     800eff <devcons_read+0xe>
		sys_yield();
	if (c < 0)
  800f0d:	85 c0                	test   %eax,%eax
  800f0f:	78 1d                	js     800f2e <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f11:	83 f8 04             	cmp    $0x4,%eax
  800f14:	74 13                	je     800f29 <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  800f16:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f19:	88 02                	mov    %al,(%edx)
	return 1;
  800f1b:	b8 01 00 00 00       	mov    $0x1,%eax
  800f20:	eb 0c                	jmp    800f2e <devcons_read+0x3d>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  800f22:	b8 00 00 00 00       	mov    $0x0,%eax
  800f27:	eb 05                	jmp    800f2e <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f29:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f2e:	c9                   	leave  
  800f2f:	c3                   	ret    

00800f30 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f30:	55                   	push   %ebp
  800f31:	89 e5                	mov    %esp,%ebp
  800f33:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f36:	8b 45 08             	mov    0x8(%ebp),%eax
  800f39:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f3c:	6a 01                	push   $0x1
  800f3e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f41:	50                   	push   %eax
  800f42:	e8 69 f1 ff ff       	call   8000b0 <sys_cputs>
}
  800f47:	83 c4 10             	add    $0x10,%esp
  800f4a:	c9                   	leave  
  800f4b:	c3                   	ret    

00800f4c <getchar>:

int
getchar(void)
{
  800f4c:	55                   	push   %ebp
  800f4d:	89 e5                	mov    %esp,%ebp
  800f4f:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f52:	6a 01                	push   $0x1
  800f54:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f57:	50                   	push   %eax
  800f58:	6a 00                	push   $0x0
  800f5a:	e8 1a f7 ff ff       	call   800679 <read>
	if (r < 0)
  800f5f:	83 c4 10             	add    $0x10,%esp
  800f62:	85 c0                	test   %eax,%eax
  800f64:	78 0f                	js     800f75 <getchar+0x29>
		return r;
	if (r < 1)
  800f66:	85 c0                	test   %eax,%eax
  800f68:	7e 06                	jle    800f70 <getchar+0x24>
		return -E_EOF;
	return c;
  800f6a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800f6e:	eb 05                	jmp    800f75 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800f70:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800f75:	c9                   	leave  
  800f76:	c3                   	ret    

00800f77 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800f77:	55                   	push   %ebp
  800f78:	89 e5                	mov    %esp,%ebp
  800f7a:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f7d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f80:	50                   	push   %eax
  800f81:	ff 75 08             	pushl  0x8(%ebp)
  800f84:	e8 6f f4 ff ff       	call   8003f8 <fd_lookup>
  800f89:	83 c4 10             	add    $0x10,%esp
  800f8c:	85 c0                	test   %eax,%eax
  800f8e:	78 11                	js     800fa1 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800f90:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f93:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800f99:	39 10                	cmp    %edx,(%eax)
  800f9b:	0f 94 c0             	sete   %al
  800f9e:	0f b6 c0             	movzbl %al,%eax
}
  800fa1:	c9                   	leave  
  800fa2:	c3                   	ret    

00800fa3 <opencons>:

int
opencons(void)
{
  800fa3:	55                   	push   %ebp
  800fa4:	89 e5                	mov    %esp,%ebp
  800fa6:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fa9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fac:	50                   	push   %eax
  800fad:	e8 d2 f3 ff ff       	call   800384 <fd_alloc>
  800fb2:	83 c4 10             	add    $0x10,%esp
  800fb5:	85 c0                	test   %eax,%eax
  800fb7:	78 3a                	js     800ff3 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fb9:	83 ec 04             	sub    $0x4,%esp
  800fbc:	68 07 04 00 00       	push   $0x407
  800fc1:	ff 75 f4             	pushl  -0xc(%ebp)
  800fc4:	6a 00                	push   $0x0
  800fc6:	e8 a1 f1 ff ff       	call   80016c <sys_page_alloc>
  800fcb:	83 c4 10             	add    $0x10,%esp
  800fce:	85 c0                	test   %eax,%eax
  800fd0:	78 21                	js     800ff3 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800fd2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fdb:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800fdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fe0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800fe7:	83 ec 0c             	sub    $0xc,%esp
  800fea:	50                   	push   %eax
  800feb:	e8 6d f3 ff ff       	call   80035d <fd2num>
  800ff0:	83 c4 10             	add    $0x10,%esp
}
  800ff3:	c9                   	leave  
  800ff4:	c3                   	ret    

00800ff5 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800ff5:	55                   	push   %ebp
  800ff6:	89 e5                	mov    %esp,%ebp
  800ff8:	56                   	push   %esi
  800ff9:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800ffa:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800ffd:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801003:	e8 26 f1 ff ff       	call   80012e <sys_getenvid>
  801008:	83 ec 0c             	sub    $0xc,%esp
  80100b:	ff 75 0c             	pushl  0xc(%ebp)
  80100e:	ff 75 08             	pushl  0x8(%ebp)
  801011:	56                   	push   %esi
  801012:	50                   	push   %eax
  801013:	68 50 1f 80 00       	push   $0x801f50
  801018:	e8 b0 00 00 00       	call   8010cd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80101d:	83 c4 18             	add    $0x18,%esp
  801020:	53                   	push   %ebx
  801021:	ff 75 10             	pushl  0x10(%ebp)
  801024:	e8 53 00 00 00       	call   80107c <vcprintf>
	cprintf("\n");
  801029:	c7 04 24 3d 1f 80 00 	movl   $0x801f3d,(%esp)
  801030:	e8 98 00 00 00       	call   8010cd <cprintf>
  801035:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801038:	cc                   	int3   
  801039:	eb fd                	jmp    801038 <_panic+0x43>

0080103b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80103b:	55                   	push   %ebp
  80103c:	89 e5                	mov    %esp,%ebp
  80103e:	53                   	push   %ebx
  80103f:	83 ec 04             	sub    $0x4,%esp
  801042:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801045:	8b 13                	mov    (%ebx),%edx
  801047:	8d 42 01             	lea    0x1(%edx),%eax
  80104a:	89 03                	mov    %eax,(%ebx)
  80104c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80104f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801053:	3d ff 00 00 00       	cmp    $0xff,%eax
  801058:	75 1a                	jne    801074 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80105a:	83 ec 08             	sub    $0x8,%esp
  80105d:	68 ff 00 00 00       	push   $0xff
  801062:	8d 43 08             	lea    0x8(%ebx),%eax
  801065:	50                   	push   %eax
  801066:	e8 45 f0 ff ff       	call   8000b0 <sys_cputs>
		b->idx = 0;
  80106b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801071:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801074:	ff 43 04             	incl   0x4(%ebx)
}
  801077:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80107a:	c9                   	leave  
  80107b:	c3                   	ret    

0080107c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80107c:	55                   	push   %ebp
  80107d:	89 e5                	mov    %esp,%ebp
  80107f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801085:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80108c:	00 00 00 
	b.cnt = 0;
  80108f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801096:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801099:	ff 75 0c             	pushl  0xc(%ebp)
  80109c:	ff 75 08             	pushl  0x8(%ebp)
  80109f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010a5:	50                   	push   %eax
  8010a6:	68 3b 10 80 00       	push   $0x80103b
  8010ab:	e8 54 01 00 00       	call   801204 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010b0:	83 c4 08             	add    $0x8,%esp
  8010b3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010b9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010bf:	50                   	push   %eax
  8010c0:	e8 eb ef ff ff       	call   8000b0 <sys_cputs>

	return b.cnt;
}
  8010c5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8010cb:	c9                   	leave  
  8010cc:	c3                   	ret    

008010cd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8010cd:	55                   	push   %ebp
  8010ce:	89 e5                	mov    %esp,%ebp
  8010d0:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8010d3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8010d6:	50                   	push   %eax
  8010d7:	ff 75 08             	pushl  0x8(%ebp)
  8010da:	e8 9d ff ff ff       	call   80107c <vcprintf>
	va_end(ap);

	return cnt;
}
  8010df:	c9                   	leave  
  8010e0:	c3                   	ret    

008010e1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8010e1:	55                   	push   %ebp
  8010e2:	89 e5                	mov    %esp,%ebp
  8010e4:	57                   	push   %edi
  8010e5:	56                   	push   %esi
  8010e6:	53                   	push   %ebx
  8010e7:	83 ec 1c             	sub    $0x1c,%esp
  8010ea:	89 c6                	mov    %eax,%esi
  8010ec:	89 d7                	mov    %edx,%edi
  8010ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010f4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8010f7:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8010fa:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8010fd:	bb 00 00 00 00       	mov    $0x0,%ebx
  801102:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801105:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801108:	39 d3                	cmp    %edx,%ebx
  80110a:	72 11                	jb     80111d <printnum+0x3c>
  80110c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80110f:	76 0c                	jbe    80111d <printnum+0x3c>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801111:	8b 45 14             	mov    0x14(%ebp),%eax
  801114:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801117:	85 db                	test   %ebx,%ebx
  801119:	7f 37                	jg     801152 <printnum+0x71>
  80111b:	eb 44                	jmp    801161 <printnum+0x80>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80111d:	83 ec 0c             	sub    $0xc,%esp
  801120:	ff 75 18             	pushl  0x18(%ebp)
  801123:	8b 45 14             	mov    0x14(%ebp),%eax
  801126:	48                   	dec    %eax
  801127:	50                   	push   %eax
  801128:	ff 75 10             	pushl  0x10(%ebp)
  80112b:	83 ec 08             	sub    $0x8,%esp
  80112e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801131:	ff 75 e0             	pushl  -0x20(%ebp)
  801134:	ff 75 dc             	pushl  -0x24(%ebp)
  801137:	ff 75 d8             	pushl  -0x28(%ebp)
  80113a:	e8 99 0a 00 00       	call   801bd8 <__udivdi3>
  80113f:	83 c4 18             	add    $0x18,%esp
  801142:	52                   	push   %edx
  801143:	50                   	push   %eax
  801144:	89 fa                	mov    %edi,%edx
  801146:	89 f0                	mov    %esi,%eax
  801148:	e8 94 ff ff ff       	call   8010e1 <printnum>
  80114d:	83 c4 20             	add    $0x20,%esp
  801150:	eb 0f                	jmp    801161 <printnum+0x80>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801152:	83 ec 08             	sub    $0x8,%esp
  801155:	57                   	push   %edi
  801156:	ff 75 18             	pushl  0x18(%ebp)
  801159:	ff d6                	call   *%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80115b:	83 c4 10             	add    $0x10,%esp
  80115e:	4b                   	dec    %ebx
  80115f:	75 f1                	jne    801152 <printnum+0x71>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801161:	83 ec 08             	sub    $0x8,%esp
  801164:	57                   	push   %edi
  801165:	83 ec 04             	sub    $0x4,%esp
  801168:	ff 75 e4             	pushl  -0x1c(%ebp)
  80116b:	ff 75 e0             	pushl  -0x20(%ebp)
  80116e:	ff 75 dc             	pushl  -0x24(%ebp)
  801171:	ff 75 d8             	pushl  -0x28(%ebp)
  801174:	e8 6f 0b 00 00       	call   801ce8 <__umoddi3>
  801179:	83 c4 14             	add    $0x14,%esp
  80117c:	0f be 80 73 1f 80 00 	movsbl 0x801f73(%eax),%eax
  801183:	50                   	push   %eax
  801184:	ff d6                	call   *%esi
}
  801186:	83 c4 10             	add    $0x10,%esp
  801189:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80118c:	5b                   	pop    %ebx
  80118d:	5e                   	pop    %esi
  80118e:	5f                   	pop    %edi
  80118f:	5d                   	pop    %ebp
  801190:	c3                   	ret    

00801191 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801191:	55                   	push   %ebp
  801192:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801194:	83 fa 01             	cmp    $0x1,%edx
  801197:	7e 0e                	jle    8011a7 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801199:	8b 10                	mov    (%eax),%edx
  80119b:	8d 4a 08             	lea    0x8(%edx),%ecx
  80119e:	89 08                	mov    %ecx,(%eax)
  8011a0:	8b 02                	mov    (%edx),%eax
  8011a2:	8b 52 04             	mov    0x4(%edx),%edx
  8011a5:	eb 22                	jmp    8011c9 <getuint+0x38>
	else if (lflag)
  8011a7:	85 d2                	test   %edx,%edx
  8011a9:	74 10                	je     8011bb <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8011ab:	8b 10                	mov    (%eax),%edx
  8011ad:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011b0:	89 08                	mov    %ecx,(%eax)
  8011b2:	8b 02                	mov    (%edx),%eax
  8011b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8011b9:	eb 0e                	jmp    8011c9 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8011bb:	8b 10                	mov    (%eax),%edx
  8011bd:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011c0:	89 08                	mov    %ecx,(%eax)
  8011c2:	8b 02                	mov    (%edx),%eax
  8011c4:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8011c9:	5d                   	pop    %ebp
  8011ca:	c3                   	ret    

008011cb <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011cb:	55                   	push   %ebp
  8011cc:	89 e5                	mov    %esp,%ebp
  8011ce:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011d1:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8011d4:	8b 10                	mov    (%eax),%edx
  8011d6:	3b 50 04             	cmp    0x4(%eax),%edx
  8011d9:	73 0a                	jae    8011e5 <sprintputch+0x1a>
		*b->buf++ = ch;
  8011db:	8d 4a 01             	lea    0x1(%edx),%ecx
  8011de:	89 08                	mov    %ecx,(%eax)
  8011e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e3:	88 02                	mov    %al,(%edx)
}
  8011e5:	5d                   	pop    %ebp
  8011e6:	c3                   	ret    

008011e7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8011e7:	55                   	push   %ebp
  8011e8:	89 e5                	mov    %esp,%ebp
  8011ea:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8011ed:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8011f0:	50                   	push   %eax
  8011f1:	ff 75 10             	pushl  0x10(%ebp)
  8011f4:	ff 75 0c             	pushl  0xc(%ebp)
  8011f7:	ff 75 08             	pushl  0x8(%ebp)
  8011fa:	e8 05 00 00 00       	call   801204 <vprintfmt>
	va_end(ap);
}
  8011ff:	83 c4 10             	add    $0x10,%esp
  801202:	c9                   	leave  
  801203:	c3                   	ret    

00801204 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801204:	55                   	push   %ebp
  801205:	89 e5                	mov    %esp,%ebp
  801207:	57                   	push   %edi
  801208:	56                   	push   %esi
  801209:	53                   	push   %ebx
  80120a:	83 ec 2c             	sub    $0x2c,%esp
  80120d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801210:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801213:	eb 03                	jmp    801218 <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  801215:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  801218:	8b 45 10             	mov    0x10(%ebp),%eax
  80121b:	8d 70 01             	lea    0x1(%eax),%esi
  80121e:	0f b6 00             	movzbl (%eax),%eax
  801221:	83 f8 25             	cmp    $0x25,%eax
  801224:	74 25                	je     80124b <vprintfmt+0x47>
			if (ch == '\0')									//当然中间如果遇到'\0'，代表这个字符串的访问结束
  801226:	85 c0                	test   %eax,%eax
  801228:	75 0d                	jne    801237 <vprintfmt+0x33>
  80122a:	e9 b5 03 00 00       	jmp    8015e4 <vprintfmt+0x3e0>
  80122f:	85 c0                	test   %eax,%eax
  801231:	0f 84 ad 03 00 00    	je     8015e4 <vprintfmt+0x3e0>
				return;
			putch(ch, putdat);								//调用putch函数，把一个字符ch输出到putdat指针所指向的地址中所存放的值对应的地址处
  801237:	83 ec 08             	sub    $0x8,%esp
  80123a:	53                   	push   %ebx
  80123b:	50                   	push   %eax
  80123c:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  80123e:	46                   	inc    %esi
  80123f:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  801243:	83 c4 10             	add    $0x10,%esp
  801246:	83 f8 25             	cmp    $0x25,%eax
  801249:	75 e4                	jne    80122f <vprintfmt+0x2b>
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  80124b:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  80124f:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801256:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80125d:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  801264:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80126b:	eb 07                	jmp    801274 <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80126d:	8b 75 10             	mov    0x10(%ebp),%esi

		// flag to pad on the right
		case '-':											//%后面的'-'代表要进行左对齐输出，右边填空格，如果省略代表右对齐
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
  801270:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  801274:	8d 46 01             	lea    0x1(%esi),%eax
  801277:	89 45 10             	mov    %eax,0x10(%ebp)
  80127a:	0f b6 16             	movzbl (%esi),%edx
  80127d:	8a 06                	mov    (%esi),%al
  80127f:	83 e8 23             	sub    $0x23,%eax
  801282:	3c 55                	cmp    $0x55,%al
  801284:	0f 87 03 03 00 00    	ja     80158d <vprintfmt+0x389>
  80128a:	0f b6 c0             	movzbl %al,%eax
  80128d:	ff 24 85 c0 20 80 00 	jmp    *0x8020c0(,%eax,4)
  801294:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
			goto reswitch;									//处理下一个字符

		// flag to pad with 0's instead of spaces
		case '0':											//0--有0表示进行对齐输出时填0,如省略表示填入空格，并且如果为0，则一定是右对齐
			padc = '0';										//对其方式标志位变为0
  801297:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  80129b:	eb d7                	jmp    801274 <vprintfmt+0x70>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
				precision = precision * 10 + ch - '0';
  80129d:	8d 42 d0             	lea    -0x30(%edx),%eax
  8012a0:	89 c1                	mov    %eax,%ecx
  8012a2:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  8012a5:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8012a9:	8d 50 d0             	lea    -0x30(%eax),%edx
  8012ac:	83 fa 09             	cmp    $0x9,%edx
  8012af:	77 51                	ja     801302 <vprintfmt+0xfe>
  8012b1:	8b 75 10             	mov    0x10(%ebp),%esi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
  8012b4:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8012b5:	8d 14 89             	lea    (%ecx,%ecx,4),%edx
  8012b8:	01 d2                	add    %edx,%edx
  8012ba:	8d 4c 10 d0          	lea    -0x30(%eax,%edx,1),%ecx
				ch = *fmt;
  8012be:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8012c1:	8d 50 d0             	lea    -0x30(%eax),%edx
  8012c4:	83 fa 09             	cmp    $0x9,%edx
  8012c7:	76 eb                	jbe    8012b4 <vprintfmt+0xb0>
  8012c9:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8012cc:	eb 37                	jmp    801305 <vprintfmt+0x101>
					break;
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
  8012ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8012d1:	8d 50 04             	lea    0x4(%eax),%edx
  8012d4:	89 55 14             	mov    %edx,0x14(%ebp)
  8012d7:	8b 00                	mov    (%eax),%eax
  8012d9:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8012dc:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
			goto process_precision;
  8012df:	eb 24                	jmp    801305 <vprintfmt+0x101>
  8012e1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8012e5:	79 07                	jns    8012ee <vprintfmt+0xea>
  8012e7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8012ee:	8b 75 10             	mov    0x10(%ebp),%esi
  8012f1:	eb 81                	jmp    801274 <vprintfmt+0x70>
  8012f3:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  8012f6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8012fd:	e9 72 ff ff ff       	jmp    801274 <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  801302:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:									//处理输出精度，把width字段赋值为刚刚计算出来的precision值，所以width应该是整数部分的有效数字位数
			if (width < 0)
  801305:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801309:	0f 89 65 ff ff ff    	jns    801274 <vprintfmt+0x70>
				width = precision, precision = -1;
  80130f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801312:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801315:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80131c:	e9 53 ff ff ff       	jmp    801274 <vprintfmt+0x70>
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
  801321:	ff 45 d4             	incl   -0x2c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  801324:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
			goto reswitch;
  801327:	e9 48 ff ff ff       	jmp    801274 <vprintfmt+0x70>

		// character
		case 'c':											//如果是'c'代表显示一个字符
			putch(va_arg(ap, int), putdat);					//调用输出一个字符到内存的函数putch
  80132c:	8b 45 14             	mov    0x14(%ebp),%eax
  80132f:	8d 50 04             	lea    0x4(%eax),%edx
  801332:	89 55 14             	mov    %edx,0x14(%ebp)
  801335:	83 ec 08             	sub    $0x8,%esp
  801338:	53                   	push   %ebx
  801339:	ff 30                	pushl  (%eax)
  80133b:	ff d7                	call   *%edi
			break;
  80133d:	83 c4 10             	add    $0x10,%esp
  801340:	e9 d3 fe ff ff       	jmp    801218 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801345:	8b 45 14             	mov    0x14(%ebp),%eax
  801348:	8d 50 04             	lea    0x4(%eax),%edx
  80134b:	89 55 14             	mov    %edx,0x14(%ebp)
  80134e:	8b 00                	mov    (%eax),%eax
  801350:	85 c0                	test   %eax,%eax
  801352:	79 02                	jns    801356 <vprintfmt+0x152>
  801354:	f7 d8                	neg    %eax
  801356:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801358:	83 f8 0f             	cmp    $0xf,%eax
  80135b:	7f 0b                	jg     801368 <vprintfmt+0x164>
  80135d:	8b 04 85 20 22 80 00 	mov    0x802220(,%eax,4),%eax
  801364:	85 c0                	test   %eax,%eax
  801366:	75 15                	jne    80137d <vprintfmt+0x179>
				printfmt(putch, putdat, "error %d", err);
  801368:	52                   	push   %edx
  801369:	68 8b 1f 80 00       	push   $0x801f8b
  80136e:	53                   	push   %ebx
  80136f:	57                   	push   %edi
  801370:	e8 72 fe ff ff       	call   8011e7 <printfmt>
  801375:	83 c4 10             	add    $0x10,%esp
  801378:	e9 9b fe ff ff       	jmp    801218 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  80137d:	50                   	push   %eax
  80137e:	68 0b 1f 80 00       	push   $0x801f0b
  801383:	53                   	push   %ebx
  801384:	57                   	push   %edi
  801385:	e8 5d fe ff ff       	call   8011e7 <printfmt>
  80138a:	83 c4 10             	add    $0x10,%esp
  80138d:	e9 86 fe ff ff       	jmp    801218 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801392:	8b 45 14             	mov    0x14(%ebp),%eax
  801395:	8d 50 04             	lea    0x4(%eax),%edx
  801398:	89 55 14             	mov    %edx,0x14(%ebp)
  80139b:	8b 00                	mov    (%eax),%eax
  80139d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8013a0:	85 c0                	test   %eax,%eax
  8013a2:	75 07                	jne    8013ab <vprintfmt+0x1a7>
				p = "(null)";
  8013a4:	c7 45 d4 84 1f 80 00 	movl   $0x801f84,-0x2c(%ebp)
			if (width > 0 && padc != '-')
  8013ab:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8013ae:	85 f6                	test   %esi,%esi
  8013b0:	0f 8e fb 01 00 00    	jle    8015b1 <vprintfmt+0x3ad>
  8013b6:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  8013ba:	0f 84 09 02 00 00    	je     8015c9 <vprintfmt+0x3c5>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013c0:	83 ec 08             	sub    $0x8,%esp
  8013c3:	ff 75 d0             	pushl  -0x30(%ebp)
  8013c6:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013c9:	e8 ad 02 00 00       	call   80167b <strnlen>
  8013ce:	89 f1                	mov    %esi,%ecx
  8013d0:	29 c1                	sub    %eax,%ecx
  8013d2:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8013d5:	83 c4 10             	add    $0x10,%esp
  8013d8:	85 c9                	test   %ecx,%ecx
  8013da:	0f 8e d1 01 00 00    	jle    8015b1 <vprintfmt+0x3ad>
					putch(padc, putdat);
  8013e0:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8013e4:	83 ec 08             	sub    $0x8,%esp
  8013e7:	53                   	push   %ebx
  8013e8:	56                   	push   %esi
  8013e9:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013eb:	83 c4 10             	add    $0x10,%esp
  8013ee:	ff 4d e4             	decl   -0x1c(%ebp)
  8013f1:	75 f1                	jne    8013e4 <vprintfmt+0x1e0>
  8013f3:	e9 b9 01 00 00       	jmp    8015b1 <vprintfmt+0x3ad>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8013f8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8013fc:	74 19                	je     801417 <vprintfmt+0x213>
  8013fe:	0f be c0             	movsbl %al,%eax
  801401:	83 e8 20             	sub    $0x20,%eax
  801404:	83 f8 5e             	cmp    $0x5e,%eax
  801407:	76 0e                	jbe    801417 <vprintfmt+0x213>
					putch('?', putdat);
  801409:	83 ec 08             	sub    $0x8,%esp
  80140c:	53                   	push   %ebx
  80140d:	6a 3f                	push   $0x3f
  80140f:	ff 55 08             	call   *0x8(%ebp)
  801412:	83 c4 10             	add    $0x10,%esp
  801415:	eb 0b                	jmp    801422 <vprintfmt+0x21e>
				else
					putch(ch, putdat);
  801417:	83 ec 08             	sub    $0x8,%esp
  80141a:	53                   	push   %ebx
  80141b:	52                   	push   %edx
  80141c:	ff 55 08             	call   *0x8(%ebp)
  80141f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801422:	ff 4d e4             	decl   -0x1c(%ebp)
  801425:	46                   	inc    %esi
  801426:	8a 46 ff             	mov    -0x1(%esi),%al
  801429:	0f be d0             	movsbl %al,%edx
  80142c:	85 d2                	test   %edx,%edx
  80142e:	75 1c                	jne    80144c <vprintfmt+0x248>
  801430:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801433:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801437:	7f 1f                	jg     801458 <vprintfmt+0x254>
  801439:	e9 da fd ff ff       	jmp    801218 <vprintfmt+0x14>
  80143e:	89 7d 08             	mov    %edi,0x8(%ebp)
  801441:	8b 7d d0             	mov    -0x30(%ebp),%edi
  801444:	eb 06                	jmp    80144c <vprintfmt+0x248>
  801446:	89 7d 08             	mov    %edi,0x8(%ebp)
  801449:	8b 7d d0             	mov    -0x30(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80144c:	85 ff                	test   %edi,%edi
  80144e:	78 a8                	js     8013f8 <vprintfmt+0x1f4>
  801450:	4f                   	dec    %edi
  801451:	79 a5                	jns    8013f8 <vprintfmt+0x1f4>
  801453:	8b 7d 08             	mov    0x8(%ebp),%edi
  801456:	eb db                	jmp    801433 <vprintfmt+0x22f>
  801458:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80145b:	83 ec 08             	sub    $0x8,%esp
  80145e:	53                   	push   %ebx
  80145f:	6a 20                	push   $0x20
  801461:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801463:	4e                   	dec    %esi
  801464:	83 c4 10             	add    $0x10,%esp
  801467:	85 f6                	test   %esi,%esi
  801469:	7f f0                	jg     80145b <vprintfmt+0x257>
  80146b:	e9 a8 fd ff ff       	jmp    801218 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801470:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  801474:	7e 16                	jle    80148c <vprintfmt+0x288>
		return va_arg(*ap, long long);
  801476:	8b 45 14             	mov    0x14(%ebp),%eax
  801479:	8d 50 08             	lea    0x8(%eax),%edx
  80147c:	89 55 14             	mov    %edx,0x14(%ebp)
  80147f:	8b 50 04             	mov    0x4(%eax),%edx
  801482:	8b 00                	mov    (%eax),%eax
  801484:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801487:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80148a:	eb 34                	jmp    8014c0 <vprintfmt+0x2bc>
	else if (lflag)
  80148c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  801490:	74 18                	je     8014aa <vprintfmt+0x2a6>
		return va_arg(*ap, long);
  801492:	8b 45 14             	mov    0x14(%ebp),%eax
  801495:	8d 50 04             	lea    0x4(%eax),%edx
  801498:	89 55 14             	mov    %edx,0x14(%ebp)
  80149b:	8b 30                	mov    (%eax),%esi
  80149d:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8014a0:	89 f0                	mov    %esi,%eax
  8014a2:	c1 f8 1f             	sar    $0x1f,%eax
  8014a5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8014a8:	eb 16                	jmp    8014c0 <vprintfmt+0x2bc>
	else
		return va_arg(*ap, int);
  8014aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8014ad:	8d 50 04             	lea    0x4(%eax),%edx
  8014b0:	89 55 14             	mov    %edx,0x14(%ebp)
  8014b3:	8b 30                	mov    (%eax),%esi
  8014b5:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8014b8:	89 f0                	mov    %esi,%eax
  8014ba:	c1 f8 1f             	sar    $0x1f,%eax
  8014bd:	89 45 dc             	mov    %eax,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8014c0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8014c3:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
  8014c6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8014ca:	0f 89 8a 00 00 00    	jns    80155a <vprintfmt+0x356>
				putch('-', putdat);
  8014d0:	83 ec 08             	sub    $0x8,%esp
  8014d3:	53                   	push   %ebx
  8014d4:	6a 2d                	push   $0x2d
  8014d6:	ff d7                	call   *%edi
				num = -(long long) num;
  8014d8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8014db:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8014de:	f7 d8                	neg    %eax
  8014e0:	83 d2 00             	adc    $0x0,%edx
  8014e3:	f7 da                	neg    %edx
  8014e5:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8014e8:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8014ed:	eb 70                	jmp    80155f <vprintfmt+0x35b>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8014ef:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8014f2:	8d 45 14             	lea    0x14(%ebp),%eax
  8014f5:	e8 97 fc ff ff       	call   801191 <getuint>
			base = 10;
  8014fa:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8014ff:	eb 5e                	jmp    80155f <vprintfmt+0x35b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  801501:	83 ec 08             	sub    $0x8,%esp
  801504:	53                   	push   %ebx
  801505:	6a 30                	push   $0x30
  801507:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  801509:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80150c:	8d 45 14             	lea    0x14(%ebp),%eax
  80150f:	e8 7d fc ff ff       	call   801191 <getuint>
			base = 8;
			goto number;
  801514:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  801517:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80151c:	eb 41                	jmp    80155f <vprintfmt+0x35b>
		// pointer
		case 'p':
			putch('0', putdat);
  80151e:	83 ec 08             	sub    $0x8,%esp
  801521:	53                   	push   %ebx
  801522:	6a 30                	push   $0x30
  801524:	ff d7                	call   *%edi
			putch('x', putdat);
  801526:	83 c4 08             	add    $0x8,%esp
  801529:	53                   	push   %ebx
  80152a:	6a 78                	push   $0x78
  80152c:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80152e:	8b 45 14             	mov    0x14(%ebp),%eax
  801531:	8d 50 04             	lea    0x4(%eax),%edx
  801534:	89 55 14             	mov    %edx,0x14(%ebp)
			goto number;
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801537:	8b 00                	mov    (%eax),%eax
  801539:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80153e:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801541:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801546:	eb 17                	jmp    80155f <vprintfmt+0x35b>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801548:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80154b:	8d 45 14             	lea    0x14(%ebp),%eax
  80154e:	e8 3e fc ff ff       	call   801191 <getuint>
			base = 16;
  801553:	b9 10 00 00 00       	mov    $0x10,%ecx
  801558:	eb 05                	jmp    80155f <vprintfmt+0x35b>
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80155a:	b9 0a 00 00 00       	mov    $0xa,%ecx
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  80155f:	83 ec 0c             	sub    $0xc,%esp
  801562:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  801566:	56                   	push   %esi
  801567:	ff 75 e4             	pushl  -0x1c(%ebp)
  80156a:	51                   	push   %ecx
  80156b:	52                   	push   %edx
  80156c:	50                   	push   %eax
  80156d:	89 da                	mov    %ebx,%edx
  80156f:	89 f8                	mov    %edi,%eax
  801571:	e8 6b fb ff ff       	call   8010e1 <printnum>
			break;
  801576:	83 c4 20             	add    $0x20,%esp
  801579:	e9 9a fc ff ff       	jmp    801218 <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80157e:	83 ec 08             	sub    $0x8,%esp
  801581:	53                   	push   %ebx
  801582:	52                   	push   %edx
  801583:	ff d7                	call   *%edi
			break;
  801585:	83 c4 10             	add    $0x10,%esp
  801588:	e9 8b fc ff ff       	jmp    801218 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80158d:	83 ec 08             	sub    $0x8,%esp
  801590:	53                   	push   %ebx
  801591:	6a 25                	push   $0x25
  801593:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801595:	83 c4 10             	add    $0x10,%esp
  801598:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80159c:	0f 84 73 fc ff ff    	je     801215 <vprintfmt+0x11>
  8015a2:	4e                   	dec    %esi
  8015a3:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8015a7:	75 f9                	jne    8015a2 <vprintfmt+0x39e>
  8015a9:	89 75 10             	mov    %esi,0x10(%ebp)
  8015ac:	e9 67 fc ff ff       	jmp    801218 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8015b1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8015b4:	8d 70 01             	lea    0x1(%eax),%esi
  8015b7:	8a 00                	mov    (%eax),%al
  8015b9:	0f be d0             	movsbl %al,%edx
  8015bc:	85 d2                	test   %edx,%edx
  8015be:	0f 85 7a fe ff ff    	jne    80143e <vprintfmt+0x23a>
  8015c4:	e9 4f fc ff ff       	jmp    801218 <vprintfmt+0x14>
  8015c9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8015cc:	8d 70 01             	lea    0x1(%eax),%esi
  8015cf:	8a 00                	mov    (%eax),%al
  8015d1:	0f be d0             	movsbl %al,%edx
  8015d4:	85 d2                	test   %edx,%edx
  8015d6:	0f 85 6a fe ff ff    	jne    801446 <vprintfmt+0x242>
  8015dc:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8015df:	e9 77 fe ff ff       	jmp    80145b <vprintfmt+0x257>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  8015e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015e7:	5b                   	pop    %ebx
  8015e8:	5e                   	pop    %esi
  8015e9:	5f                   	pop    %edi
  8015ea:	5d                   	pop    %ebp
  8015eb:	c3                   	ret    

008015ec <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8015ec:	55                   	push   %ebp
  8015ed:	89 e5                	mov    %esp,%ebp
  8015ef:	83 ec 18             	sub    $0x18,%esp
  8015f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8015f5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8015f8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8015fb:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8015ff:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801602:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801609:	85 c0                	test   %eax,%eax
  80160b:	74 26                	je     801633 <vsnprintf+0x47>
  80160d:	85 d2                	test   %edx,%edx
  80160f:	7e 29                	jle    80163a <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801611:	ff 75 14             	pushl  0x14(%ebp)
  801614:	ff 75 10             	pushl  0x10(%ebp)
  801617:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80161a:	50                   	push   %eax
  80161b:	68 cb 11 80 00       	push   $0x8011cb
  801620:	e8 df fb ff ff       	call   801204 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801625:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801628:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80162b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80162e:	83 c4 10             	add    $0x10,%esp
  801631:	eb 0c                	jmp    80163f <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801633:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801638:	eb 05                	jmp    80163f <vsnprintf+0x53>
  80163a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80163f:	c9                   	leave  
  801640:	c3                   	ret    

00801641 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801641:	55                   	push   %ebp
  801642:	89 e5                	mov    %esp,%ebp
  801644:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801647:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80164a:	50                   	push   %eax
  80164b:	ff 75 10             	pushl  0x10(%ebp)
  80164e:	ff 75 0c             	pushl  0xc(%ebp)
  801651:	ff 75 08             	pushl  0x8(%ebp)
  801654:	e8 93 ff ff ff       	call   8015ec <vsnprintf>
	va_end(ap);

	return rc;
}
  801659:	c9                   	leave  
  80165a:	c3                   	ret    

0080165b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80165b:	55                   	push   %ebp
  80165c:	89 e5                	mov    %esp,%ebp
  80165e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801661:	80 3a 00             	cmpb   $0x0,(%edx)
  801664:	74 0e                	je     801674 <strlen+0x19>
  801666:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80166b:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80166c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801670:	75 f9                	jne    80166b <strlen+0x10>
  801672:	eb 05                	jmp    801679 <strlen+0x1e>
  801674:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801679:	5d                   	pop    %ebp
  80167a:	c3                   	ret    

0080167b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80167b:	55                   	push   %ebp
  80167c:	89 e5                	mov    %esp,%ebp
  80167e:	53                   	push   %ebx
  80167f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801682:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801685:	85 c9                	test   %ecx,%ecx
  801687:	74 1a                	je     8016a3 <strnlen+0x28>
  801689:	80 3b 00             	cmpb   $0x0,(%ebx)
  80168c:	74 1c                	je     8016aa <strnlen+0x2f>
  80168e:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  801693:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801695:	39 ca                	cmp    %ecx,%edx
  801697:	74 16                	je     8016af <strnlen+0x34>
  801699:	42                   	inc    %edx
  80169a:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  80169f:	75 f2                	jne    801693 <strnlen+0x18>
  8016a1:	eb 0c                	jmp    8016af <strnlen+0x34>
  8016a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8016a8:	eb 05                	jmp    8016af <strnlen+0x34>
  8016aa:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8016af:	5b                   	pop    %ebx
  8016b0:	5d                   	pop    %ebp
  8016b1:	c3                   	ret    

008016b2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016b2:	55                   	push   %ebp
  8016b3:	89 e5                	mov    %esp,%ebp
  8016b5:	53                   	push   %ebx
  8016b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016bc:	89 c2                	mov    %eax,%edx
  8016be:	42                   	inc    %edx
  8016bf:	41                   	inc    %ecx
  8016c0:	8a 59 ff             	mov    -0x1(%ecx),%bl
  8016c3:	88 5a ff             	mov    %bl,-0x1(%edx)
  8016c6:	84 db                	test   %bl,%bl
  8016c8:	75 f4                	jne    8016be <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8016ca:	5b                   	pop    %ebx
  8016cb:	5d                   	pop    %ebp
  8016cc:	c3                   	ret    

008016cd <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016cd:	55                   	push   %ebp
  8016ce:	89 e5                	mov    %esp,%ebp
  8016d0:	53                   	push   %ebx
  8016d1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016d4:	53                   	push   %ebx
  8016d5:	e8 81 ff ff ff       	call   80165b <strlen>
  8016da:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8016dd:	ff 75 0c             	pushl  0xc(%ebp)
  8016e0:	01 d8                	add    %ebx,%eax
  8016e2:	50                   	push   %eax
  8016e3:	e8 ca ff ff ff       	call   8016b2 <strcpy>
	return dst;
}
  8016e8:	89 d8                	mov    %ebx,%eax
  8016ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ed:	c9                   	leave  
  8016ee:	c3                   	ret    

008016ef <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016ef:	55                   	push   %ebp
  8016f0:	89 e5                	mov    %esp,%ebp
  8016f2:	56                   	push   %esi
  8016f3:	53                   	push   %ebx
  8016f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8016f7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016fa:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016fd:	85 db                	test   %ebx,%ebx
  8016ff:	74 14                	je     801715 <strncpy+0x26>
  801701:	01 f3                	add    %esi,%ebx
  801703:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  801705:	41                   	inc    %ecx
  801706:	8a 02                	mov    (%edx),%al
  801708:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80170b:	80 3a 01             	cmpb   $0x1,(%edx)
  80170e:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801711:	39 cb                	cmp    %ecx,%ebx
  801713:	75 f0                	jne    801705 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801715:	89 f0                	mov    %esi,%eax
  801717:	5b                   	pop    %ebx
  801718:	5e                   	pop    %esi
  801719:	5d                   	pop    %ebp
  80171a:	c3                   	ret    

0080171b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80171b:	55                   	push   %ebp
  80171c:	89 e5                	mov    %esp,%ebp
  80171e:	53                   	push   %ebx
  80171f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801722:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801725:	85 c0                	test   %eax,%eax
  801727:	74 30                	je     801759 <strlcpy+0x3e>
		while (--size > 0 && *src != '\0')
  801729:	48                   	dec    %eax
  80172a:	74 20                	je     80174c <strlcpy+0x31>
  80172c:	8a 0b                	mov    (%ebx),%cl
  80172e:	84 c9                	test   %cl,%cl
  801730:	74 1f                	je     801751 <strlcpy+0x36>
  801732:	8d 53 01             	lea    0x1(%ebx),%edx
  801735:	01 c3                	add    %eax,%ebx
  801737:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
  80173a:	40                   	inc    %eax
  80173b:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80173e:	39 da                	cmp    %ebx,%edx
  801740:	74 12                	je     801754 <strlcpy+0x39>
  801742:	42                   	inc    %edx
  801743:	8a 4a ff             	mov    -0x1(%edx),%cl
  801746:	84 c9                	test   %cl,%cl
  801748:	75 f0                	jne    80173a <strlcpy+0x1f>
  80174a:	eb 08                	jmp    801754 <strlcpy+0x39>
  80174c:	8b 45 08             	mov    0x8(%ebp),%eax
  80174f:	eb 03                	jmp    801754 <strlcpy+0x39>
  801751:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
		*dst = '\0';
  801754:	c6 00 00             	movb   $0x0,(%eax)
  801757:	eb 03                	jmp    80175c <strlcpy+0x41>
  801759:	8b 45 08             	mov    0x8(%ebp),%eax
	}
	return dst - dst_in;
  80175c:	2b 45 08             	sub    0x8(%ebp),%eax
}
  80175f:	5b                   	pop    %ebx
  801760:	5d                   	pop    %ebp
  801761:	c3                   	ret    

00801762 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801762:	55                   	push   %ebp
  801763:	89 e5                	mov    %esp,%ebp
  801765:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801768:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80176b:	8a 01                	mov    (%ecx),%al
  80176d:	84 c0                	test   %al,%al
  80176f:	74 10                	je     801781 <strcmp+0x1f>
  801771:	3a 02                	cmp    (%edx),%al
  801773:	75 0c                	jne    801781 <strcmp+0x1f>
		p++, q++;
  801775:	41                   	inc    %ecx
  801776:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801777:	8a 01                	mov    (%ecx),%al
  801779:	84 c0                	test   %al,%al
  80177b:	74 04                	je     801781 <strcmp+0x1f>
  80177d:	3a 02                	cmp    (%edx),%al
  80177f:	74 f4                	je     801775 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801781:	0f b6 c0             	movzbl %al,%eax
  801784:	0f b6 12             	movzbl (%edx),%edx
  801787:	29 d0                	sub    %edx,%eax
}
  801789:	5d                   	pop    %ebp
  80178a:	c3                   	ret    

0080178b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80178b:	55                   	push   %ebp
  80178c:	89 e5                	mov    %esp,%ebp
  80178e:	56                   	push   %esi
  80178f:	53                   	push   %ebx
  801790:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801793:	8b 55 0c             	mov    0xc(%ebp),%edx
  801796:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  801799:	85 f6                	test   %esi,%esi
  80179b:	74 23                	je     8017c0 <strncmp+0x35>
  80179d:	8a 03                	mov    (%ebx),%al
  80179f:	84 c0                	test   %al,%al
  8017a1:	74 2b                	je     8017ce <strncmp+0x43>
  8017a3:	3a 02                	cmp    (%edx),%al
  8017a5:	75 27                	jne    8017ce <strncmp+0x43>
  8017a7:	8d 43 01             	lea    0x1(%ebx),%eax
  8017aa:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  8017ac:	89 c3                	mov    %eax,%ebx
  8017ae:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017af:	39 c6                	cmp    %eax,%esi
  8017b1:	74 14                	je     8017c7 <strncmp+0x3c>
  8017b3:	8a 08                	mov    (%eax),%cl
  8017b5:	84 c9                	test   %cl,%cl
  8017b7:	74 15                	je     8017ce <strncmp+0x43>
  8017b9:	40                   	inc    %eax
  8017ba:	3a 0a                	cmp    (%edx),%cl
  8017bc:	74 ee                	je     8017ac <strncmp+0x21>
  8017be:	eb 0e                	jmp    8017ce <strncmp+0x43>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8017c5:	eb 0f                	jmp    8017d6 <strncmp+0x4b>
  8017c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8017cc:	eb 08                	jmp    8017d6 <strncmp+0x4b>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017ce:	0f b6 03             	movzbl (%ebx),%eax
  8017d1:	0f b6 12             	movzbl (%edx),%edx
  8017d4:	29 d0                	sub    %edx,%eax
}
  8017d6:	5b                   	pop    %ebx
  8017d7:	5e                   	pop    %esi
  8017d8:	5d                   	pop    %ebp
  8017d9:	c3                   	ret    

008017da <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017da:	55                   	push   %ebp
  8017db:	89 e5                	mov    %esp,%ebp
  8017dd:	53                   	push   %ebx
  8017de:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  8017e4:	8a 10                	mov    (%eax),%dl
  8017e6:	84 d2                	test   %dl,%dl
  8017e8:	74 1a                	je     801804 <strchr+0x2a>
  8017ea:	88 d9                	mov    %bl,%cl
		if (*s == c)
  8017ec:	38 d3                	cmp    %dl,%bl
  8017ee:	75 06                	jne    8017f6 <strchr+0x1c>
  8017f0:	eb 17                	jmp    801809 <strchr+0x2f>
  8017f2:	38 ca                	cmp    %cl,%dl
  8017f4:	74 13                	je     801809 <strchr+0x2f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017f6:	40                   	inc    %eax
  8017f7:	8a 10                	mov    (%eax),%dl
  8017f9:	84 d2                	test   %dl,%dl
  8017fb:	75 f5                	jne    8017f2 <strchr+0x18>
		if (*s == c)
			return (char *) s;
	return 0;
  8017fd:	b8 00 00 00 00       	mov    $0x0,%eax
  801802:	eb 05                	jmp    801809 <strchr+0x2f>
  801804:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801809:	5b                   	pop    %ebx
  80180a:	5d                   	pop    %ebp
  80180b:	c3                   	ret    

0080180c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80180c:	55                   	push   %ebp
  80180d:	89 e5                	mov    %esp,%ebp
  80180f:	53                   	push   %ebx
  801810:	8b 45 08             	mov    0x8(%ebp),%eax
  801813:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  801816:	8a 10                	mov    (%eax),%dl
  801818:	84 d2                	test   %dl,%dl
  80181a:	74 13                	je     80182f <strfind+0x23>
  80181c:	88 d9                	mov    %bl,%cl
		if (*s == c)
  80181e:	38 d3                	cmp    %dl,%bl
  801820:	75 06                	jne    801828 <strfind+0x1c>
  801822:	eb 0b                	jmp    80182f <strfind+0x23>
  801824:	38 ca                	cmp    %cl,%dl
  801826:	74 07                	je     80182f <strfind+0x23>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801828:	40                   	inc    %eax
  801829:	8a 10                	mov    (%eax),%dl
  80182b:	84 d2                	test   %dl,%dl
  80182d:	75 f5                	jne    801824 <strfind+0x18>
		if (*s == c)
			break;
	return (char *) s;
}
  80182f:	5b                   	pop    %ebx
  801830:	5d                   	pop    %ebp
  801831:	c3                   	ret    

00801832 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801832:	55                   	push   %ebp
  801833:	89 e5                	mov    %esp,%ebp
  801835:	57                   	push   %edi
  801836:	56                   	push   %esi
  801837:	53                   	push   %ebx
  801838:	8b 7d 08             	mov    0x8(%ebp),%edi
  80183b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80183e:	85 c9                	test   %ecx,%ecx
  801840:	74 36                	je     801878 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801842:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801848:	75 28                	jne    801872 <memset+0x40>
  80184a:	f6 c1 03             	test   $0x3,%cl
  80184d:	75 23                	jne    801872 <memset+0x40>
		c &= 0xFF;
  80184f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801853:	89 d3                	mov    %edx,%ebx
  801855:	c1 e3 08             	shl    $0x8,%ebx
  801858:	89 d6                	mov    %edx,%esi
  80185a:	c1 e6 18             	shl    $0x18,%esi
  80185d:	89 d0                	mov    %edx,%eax
  80185f:	c1 e0 10             	shl    $0x10,%eax
  801862:	09 f0                	or     %esi,%eax
  801864:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801866:	89 d8                	mov    %ebx,%eax
  801868:	09 d0                	or     %edx,%eax
  80186a:	c1 e9 02             	shr    $0x2,%ecx
  80186d:	fc                   	cld    
  80186e:	f3 ab                	rep stos %eax,%es:(%edi)
  801870:	eb 06                	jmp    801878 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801872:	8b 45 0c             	mov    0xc(%ebp),%eax
  801875:	fc                   	cld    
  801876:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801878:	89 f8                	mov    %edi,%eax
  80187a:	5b                   	pop    %ebx
  80187b:	5e                   	pop    %esi
  80187c:	5f                   	pop    %edi
  80187d:	5d                   	pop    %ebp
  80187e:	c3                   	ret    

0080187f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80187f:	55                   	push   %ebp
  801880:	89 e5                	mov    %esp,%ebp
  801882:	57                   	push   %edi
  801883:	56                   	push   %esi
  801884:	8b 45 08             	mov    0x8(%ebp),%eax
  801887:	8b 75 0c             	mov    0xc(%ebp),%esi
  80188a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80188d:	39 c6                	cmp    %eax,%esi
  80188f:	73 33                	jae    8018c4 <memmove+0x45>
  801891:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801894:	39 d0                	cmp    %edx,%eax
  801896:	73 2c                	jae    8018c4 <memmove+0x45>
		s += n;
		d += n;
  801898:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80189b:	89 d6                	mov    %edx,%esi
  80189d:	09 fe                	or     %edi,%esi
  80189f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018a5:	75 13                	jne    8018ba <memmove+0x3b>
  8018a7:	f6 c1 03             	test   $0x3,%cl
  8018aa:	75 0e                	jne    8018ba <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8018ac:	83 ef 04             	sub    $0x4,%edi
  8018af:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018b2:	c1 e9 02             	shr    $0x2,%ecx
  8018b5:	fd                   	std    
  8018b6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018b8:	eb 07                	jmp    8018c1 <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8018ba:	4f                   	dec    %edi
  8018bb:	8d 72 ff             	lea    -0x1(%edx),%esi
  8018be:	fd                   	std    
  8018bf:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018c1:	fc                   	cld    
  8018c2:	eb 1d                	jmp    8018e1 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018c4:	89 f2                	mov    %esi,%edx
  8018c6:	09 c2                	or     %eax,%edx
  8018c8:	f6 c2 03             	test   $0x3,%dl
  8018cb:	75 0f                	jne    8018dc <memmove+0x5d>
  8018cd:	f6 c1 03             	test   $0x3,%cl
  8018d0:	75 0a                	jne    8018dc <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
  8018d2:	c1 e9 02             	shr    $0x2,%ecx
  8018d5:	89 c7                	mov    %eax,%edi
  8018d7:	fc                   	cld    
  8018d8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018da:	eb 05                	jmp    8018e1 <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018dc:	89 c7                	mov    %eax,%edi
  8018de:	fc                   	cld    
  8018df:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018e1:	5e                   	pop    %esi
  8018e2:	5f                   	pop    %edi
  8018e3:	5d                   	pop    %ebp
  8018e4:	c3                   	ret    

008018e5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018e5:	55                   	push   %ebp
  8018e6:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018e8:	ff 75 10             	pushl  0x10(%ebp)
  8018eb:	ff 75 0c             	pushl  0xc(%ebp)
  8018ee:	ff 75 08             	pushl  0x8(%ebp)
  8018f1:	e8 89 ff ff ff       	call   80187f <memmove>
}
  8018f6:	c9                   	leave  
  8018f7:	c3                   	ret    

008018f8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018f8:	55                   	push   %ebp
  8018f9:	89 e5                	mov    %esp,%ebp
  8018fb:	57                   	push   %edi
  8018fc:	56                   	push   %esi
  8018fd:	53                   	push   %ebx
  8018fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801901:	8b 75 0c             	mov    0xc(%ebp),%esi
  801904:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801907:	85 c0                	test   %eax,%eax
  801909:	74 33                	je     80193e <memcmp+0x46>
  80190b:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  80190e:	8a 13                	mov    (%ebx),%dl
  801910:	8a 0e                	mov    (%esi),%cl
  801912:	38 ca                	cmp    %cl,%dl
  801914:	75 13                	jne    801929 <memcmp+0x31>
  801916:	b8 00 00 00 00       	mov    $0x0,%eax
  80191b:	eb 16                	jmp    801933 <memcmp+0x3b>
  80191d:	8a 54 03 01          	mov    0x1(%ebx,%eax,1),%dl
  801921:	40                   	inc    %eax
  801922:	8a 0c 06             	mov    (%esi,%eax,1),%cl
  801925:	38 ca                	cmp    %cl,%dl
  801927:	74 0a                	je     801933 <memcmp+0x3b>
			return (int) *s1 - (int) *s2;
  801929:	0f b6 c2             	movzbl %dl,%eax
  80192c:	0f b6 c9             	movzbl %cl,%ecx
  80192f:	29 c8                	sub    %ecx,%eax
  801931:	eb 10                	jmp    801943 <memcmp+0x4b>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801933:	39 f8                	cmp    %edi,%eax
  801935:	75 e6                	jne    80191d <memcmp+0x25>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801937:	b8 00 00 00 00       	mov    $0x0,%eax
  80193c:	eb 05                	jmp    801943 <memcmp+0x4b>
  80193e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801943:	5b                   	pop    %ebx
  801944:	5e                   	pop    %esi
  801945:	5f                   	pop    %edi
  801946:	5d                   	pop    %ebp
  801947:	c3                   	ret    

00801948 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801948:	55                   	push   %ebp
  801949:	89 e5                	mov    %esp,%ebp
  80194b:	53                   	push   %ebx
  80194c:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  80194f:	89 d0                	mov    %edx,%eax
  801951:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  801954:	39 c2                	cmp    %eax,%edx
  801956:	73 1b                	jae    801973 <memfind+0x2b>
		if (*(const unsigned char *) s == (unsigned char) c)
  801958:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  80195c:	0f b6 0a             	movzbl (%edx),%ecx
  80195f:	39 d9                	cmp    %ebx,%ecx
  801961:	75 09                	jne    80196c <memfind+0x24>
  801963:	eb 12                	jmp    801977 <memfind+0x2f>
  801965:	0f b6 0a             	movzbl (%edx),%ecx
  801968:	39 d9                	cmp    %ebx,%ecx
  80196a:	74 0f                	je     80197b <memfind+0x33>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80196c:	42                   	inc    %edx
  80196d:	39 d0                	cmp    %edx,%eax
  80196f:	75 f4                	jne    801965 <memfind+0x1d>
  801971:	eb 0a                	jmp    80197d <memfind+0x35>
  801973:	89 d0                	mov    %edx,%eax
  801975:	eb 06                	jmp    80197d <memfind+0x35>
		if (*(const unsigned char *) s == (unsigned char) c)
  801977:	89 d0                	mov    %edx,%eax
  801979:	eb 02                	jmp    80197d <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80197b:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80197d:	5b                   	pop    %ebx
  80197e:	5d                   	pop    %ebp
  80197f:	c3                   	ret    

00801980 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801980:	55                   	push   %ebp
  801981:	89 e5                	mov    %esp,%ebp
  801983:	57                   	push   %edi
  801984:	56                   	push   %esi
  801985:	53                   	push   %ebx
  801986:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801989:	eb 01                	jmp    80198c <strtol+0xc>
		s++;
  80198b:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80198c:	8a 01                	mov    (%ecx),%al
  80198e:	3c 20                	cmp    $0x20,%al
  801990:	74 f9                	je     80198b <strtol+0xb>
  801992:	3c 09                	cmp    $0x9,%al
  801994:	74 f5                	je     80198b <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  801996:	3c 2b                	cmp    $0x2b,%al
  801998:	75 08                	jne    8019a2 <strtol+0x22>
		s++;
  80199a:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80199b:	bf 00 00 00 00       	mov    $0x0,%edi
  8019a0:	eb 11                	jmp    8019b3 <strtol+0x33>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8019a2:	3c 2d                	cmp    $0x2d,%al
  8019a4:	75 08                	jne    8019ae <strtol+0x2e>
		s++, neg = 1;
  8019a6:	41                   	inc    %ecx
  8019a7:	bf 01 00 00 00       	mov    $0x1,%edi
  8019ac:	eb 05                	jmp    8019b3 <strtol+0x33>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8019ae:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019b3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019b7:	0f 84 87 00 00 00    	je     801a44 <strtol+0xc4>
  8019bd:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  8019c1:	75 27                	jne    8019ea <strtol+0x6a>
  8019c3:	80 39 30             	cmpb   $0x30,(%ecx)
  8019c6:	75 22                	jne    8019ea <strtol+0x6a>
  8019c8:	e9 88 00 00 00       	jmp    801a55 <strtol+0xd5>
		s += 2, base = 16;
  8019cd:	83 c1 02             	add    $0x2,%ecx
  8019d0:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  8019d7:	eb 11                	jmp    8019ea <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
  8019d9:	41                   	inc    %ecx
  8019da:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  8019e1:	eb 07                	jmp    8019ea <strtol+0x6a>
	else if (base == 0)
		base = 10;
  8019e3:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  8019ea:	b8 00 00 00 00       	mov    $0x0,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019ef:	8a 11                	mov    (%ecx),%dl
  8019f1:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8019f4:	80 fb 09             	cmp    $0x9,%bl
  8019f7:	77 08                	ja     801a01 <strtol+0x81>
			dig = *s - '0';
  8019f9:	0f be d2             	movsbl %dl,%edx
  8019fc:	83 ea 30             	sub    $0x30,%edx
  8019ff:	eb 22                	jmp    801a23 <strtol+0xa3>
		else if (*s >= 'a' && *s <= 'z')
  801a01:	8d 72 9f             	lea    -0x61(%edx),%esi
  801a04:	89 f3                	mov    %esi,%ebx
  801a06:	80 fb 19             	cmp    $0x19,%bl
  801a09:	77 08                	ja     801a13 <strtol+0x93>
			dig = *s - 'a' + 10;
  801a0b:	0f be d2             	movsbl %dl,%edx
  801a0e:	83 ea 57             	sub    $0x57,%edx
  801a11:	eb 10                	jmp    801a23 <strtol+0xa3>
		else if (*s >= 'A' && *s <= 'Z')
  801a13:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a16:	89 f3                	mov    %esi,%ebx
  801a18:	80 fb 19             	cmp    $0x19,%bl
  801a1b:	77 14                	ja     801a31 <strtol+0xb1>
			dig = *s - 'A' + 10;
  801a1d:	0f be d2             	movsbl %dl,%edx
  801a20:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801a23:	3b 55 10             	cmp    0x10(%ebp),%edx
  801a26:	7d 09                	jge    801a31 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  801a28:	41                   	inc    %ecx
  801a29:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a2d:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801a2f:	eb be                	jmp    8019ef <strtol+0x6f>

	if (endptr)
  801a31:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a35:	74 05                	je     801a3c <strtol+0xbc>
		*endptr = (char *) s;
  801a37:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a3a:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801a3c:	85 ff                	test   %edi,%edi
  801a3e:	74 21                	je     801a61 <strtol+0xe1>
  801a40:	f7 d8                	neg    %eax
  801a42:	eb 1d                	jmp    801a61 <strtol+0xe1>
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801a44:	80 39 30             	cmpb   $0x30,(%ecx)
  801a47:	75 9a                	jne    8019e3 <strtol+0x63>
  801a49:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801a4d:	0f 84 7a ff ff ff    	je     8019cd <strtol+0x4d>
  801a53:	eb 84                	jmp    8019d9 <strtol+0x59>
  801a55:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801a59:	0f 84 6e ff ff ff    	je     8019cd <strtol+0x4d>
  801a5f:	eb 89                	jmp    8019ea <strtol+0x6a>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  801a61:	5b                   	pop    %ebx
  801a62:	5e                   	pop    %esi
  801a63:	5f                   	pop    %edi
  801a64:	5d                   	pop    %ebp
  801a65:	c3                   	ret    

00801a66 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a66:	55                   	push   %ebp
  801a67:	89 e5                	mov    %esp,%ebp
  801a69:	56                   	push   %esi
  801a6a:	53                   	push   %ebx
  801a6b:	8b 75 08             	mov    0x8(%ebp),%esi
  801a6e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a71:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");
	int r;
    if (pg != NULL) {
  801a74:	85 c0                	test   %eax,%eax
  801a76:	74 0e                	je     801a86 <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  801a78:	83 ec 0c             	sub    $0xc,%esp
  801a7b:	50                   	push   %eax
  801a7c:	e8 9b e8 ff ff       	call   80031c <sys_ipc_recv>
  801a81:	83 c4 10             	add    $0x10,%esp
  801a84:	eb 10                	jmp    801a96 <ipc_recv+0x30>
    } else {
        r = sys_ipc_recv((void *) UTOP);
  801a86:	83 ec 0c             	sub    $0xc,%esp
  801a89:	68 00 00 c0 ee       	push   $0xeec00000
  801a8e:	e8 89 e8 ff ff       	call   80031c <sys_ipc_recv>
  801a93:	83 c4 10             	add    $0x10,%esp
    }
    if (r < 0) {
  801a96:	85 c0                	test   %eax,%eax
  801a98:	79 16                	jns    801ab0 <ipc_recv+0x4a>
        // failed
        if (from_env_store != NULL) *from_env_store = 0;
  801a9a:	85 f6                	test   %esi,%esi
  801a9c:	74 06                	je     801aa4 <ipc_recv+0x3e>
  801a9e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL) *perm_store = 0;
  801aa4:	85 db                	test   %ebx,%ebx
  801aa6:	74 2c                	je     801ad4 <ipc_recv+0x6e>
  801aa8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801aae:	eb 24                	jmp    801ad4 <ipc_recv+0x6e>
        return r;
    } else {
        if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801ab0:	85 f6                	test   %esi,%esi
  801ab2:	74 0a                	je     801abe <ipc_recv+0x58>
  801ab4:	a1 04 40 80 00       	mov    0x804004,%eax
  801ab9:	8b 40 74             	mov    0x74(%eax),%eax
  801abc:	89 06                	mov    %eax,(%esi)
        if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801abe:	85 db                	test   %ebx,%ebx
  801ac0:	74 0a                	je     801acc <ipc_recv+0x66>
  801ac2:	a1 04 40 80 00       	mov    0x804004,%eax
  801ac7:	8b 40 78             	mov    0x78(%eax),%eax
  801aca:	89 03                	mov    %eax,(%ebx)
        return thisenv->env_ipc_value;
  801acc:	a1 04 40 80 00       	mov    0x804004,%eax
  801ad1:	8b 40 70             	mov    0x70(%eax),%eax
    }
 
	return 0;
}
  801ad4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ad7:	5b                   	pop    %ebx
  801ad8:	5e                   	pop    %esi
  801ad9:	5d                   	pop    %ebp
  801ada:	c3                   	ret    

00801adb <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801adb:	55                   	push   %ebp
  801adc:	89 e5                	mov    %esp,%ebp
  801ade:	57                   	push   %edi
  801adf:	56                   	push   %esi
  801ae0:	53                   	push   %ebx
  801ae1:	83 ec 0c             	sub    $0xc,%esp
  801ae4:	8b 75 10             	mov    0x10(%ebp),%esi
  801ae7:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;
    if (pg == NULL) pg = (void *)UTOP;
  801aea:	85 f6                	test   %esi,%esi
  801aec:	75 05                	jne    801af3 <ipc_send+0x18>
  801aee:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
  801af3:	57                   	push   %edi
  801af4:	56                   	push   %esi
  801af5:	ff 75 0c             	pushl  0xc(%ebp)
  801af8:	ff 75 08             	pushl  0x8(%ebp)
  801afb:	e8 f9 e7 ff ff       	call   8002f9 <sys_ipc_try_send>
  801b00:	89 c3                	mov    %eax,%ebx
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
  801b02:	83 c4 10             	add    $0x10,%esp
  801b05:	85 c0                	test   %eax,%eax
  801b07:	79 17                	jns    801b20 <ipc_send+0x45>
  801b09:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b0c:	74 1d                	je     801b2b <ipc_send+0x50>
  801b0e:	50                   	push   %eax
  801b0f:	68 80 22 80 00       	push   $0x802280
  801b14:	6a 40                	push   $0x40
  801b16:	68 94 22 80 00       	push   $0x802294
  801b1b:	e8 d5 f4 ff ff       	call   800ff5 <_panic>
        sys_yield();
  801b20:	e8 28 e6 ff ff       	call   80014d <sys_yield>
    } while (r != 0);
  801b25:	85 db                	test   %ebx,%ebx
  801b27:	75 ca                	jne    801af3 <ipc_send+0x18>
  801b29:	eb 07                	jmp    801b32 <ipc_send+0x57>
	int r;
    if (pg == NULL) pg = (void *)UTOP;
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
        sys_yield();
  801b2b:	e8 1d e6 ff ff       	call   80014d <sys_yield>
  801b30:	eb c1                	jmp    801af3 <ipc_send+0x18>
    } while (r != 0);
}
  801b32:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b35:	5b                   	pop    %ebx
  801b36:	5e                   	pop    %esi
  801b37:	5f                   	pop    %edi
  801b38:	5d                   	pop    %ebp
  801b39:	c3                   	ret    

00801b3a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b3a:	55                   	push   %ebp
  801b3b:	89 e5                	mov    %esp,%ebp
  801b3d:	53                   	push   %ebx
  801b3e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801b41:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801b46:	39 c1                	cmp    %eax,%ecx
  801b48:	74 21                	je     801b6b <ipc_find_env+0x31>
  801b4a:	ba 01 00 00 00       	mov    $0x1,%edx
  801b4f:	8d 1c 95 00 00 00 00 	lea    0x0(,%edx,4),%ebx
  801b56:	89 d0                	mov    %edx,%eax
  801b58:	c1 e0 07             	shl    $0x7,%eax
  801b5b:	29 d8                	sub    %ebx,%eax
  801b5d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b62:	8b 40 50             	mov    0x50(%eax),%eax
  801b65:	39 c8                	cmp    %ecx,%eax
  801b67:	75 1b                	jne    801b84 <ipc_find_env+0x4a>
  801b69:	eb 05                	jmp    801b70 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b6b:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801b70:	8d 04 95 00 00 00 00 	lea    0x0(,%edx,4),%eax
  801b77:	c1 e2 07             	shl    $0x7,%edx
  801b7a:	29 c2                	sub    %eax,%edx
  801b7c:	8b 82 48 00 c0 ee    	mov    -0x113fffb8(%edx),%eax
  801b82:	eb 0e                	jmp    801b92 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b84:	42                   	inc    %edx
  801b85:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  801b8b:	75 c2                	jne    801b4f <ipc_find_env+0x15>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b8d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b92:	5b                   	pop    %ebx
  801b93:	5d                   	pop    %ebp
  801b94:	c3                   	ret    

00801b95 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b95:	55                   	push   %ebp
  801b96:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b98:	8b 45 08             	mov    0x8(%ebp),%eax
  801b9b:	c1 e8 16             	shr    $0x16,%eax
  801b9e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801ba5:	a8 01                	test   $0x1,%al
  801ba7:	74 21                	je     801bca <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801ba9:	8b 45 08             	mov    0x8(%ebp),%eax
  801bac:	c1 e8 0c             	shr    $0xc,%eax
  801baf:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801bb6:	a8 01                	test   $0x1,%al
  801bb8:	74 17                	je     801bd1 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bba:	c1 e8 0c             	shr    $0xc,%eax
  801bbd:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801bc4:	ef 
  801bc5:	0f b7 c0             	movzwl %ax,%eax
  801bc8:	eb 0c                	jmp    801bd6 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801bca:	b8 00 00 00 00       	mov    $0x0,%eax
  801bcf:	eb 05                	jmp    801bd6 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801bd1:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801bd6:	5d                   	pop    %ebp
  801bd7:	c3                   	ret    

00801bd8 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801bd8:	55                   	push   %ebp
  801bd9:	57                   	push   %edi
  801bda:	56                   	push   %esi
  801bdb:	53                   	push   %ebx
  801bdc:	83 ec 1c             	sub    $0x1c,%esp
  801bdf:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801be3:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801be7:	8b 7c 24 38          	mov    0x38(%esp),%edi
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801beb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bef:	89 ca                	mov    %ecx,%edx
  const DWunion dd = {.ll = d};
  801bf1:	89 f8                	mov    %edi,%eax
  801bf3:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801bf7:	85 f6                	test   %esi,%esi
  801bf9:	75 2d                	jne    801c28 <__udivdi3+0x50>
    {
      if (d0 > n1)
  801bfb:	39 cf                	cmp    %ecx,%edi
  801bfd:	77 65                	ja     801c64 <__udivdi3+0x8c>
  801bff:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801c01:	85 ff                	test   %edi,%edi
  801c03:	75 0b                	jne    801c10 <__udivdi3+0x38>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801c05:	b8 01 00 00 00       	mov    $0x1,%eax
  801c0a:	31 d2                	xor    %edx,%edx
  801c0c:	f7 f7                	div    %edi
  801c0e:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801c10:	31 d2                	xor    %edx,%edx
  801c12:	89 c8                	mov    %ecx,%eax
  801c14:	f7 f5                	div    %ebp
  801c16:	89 c1                	mov    %eax,%ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c18:	89 d8                	mov    %ebx,%eax
  801c1a:	f7 f5                	div    %ebp
  801c1c:	89 cf                	mov    %ecx,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c1e:	89 fa                	mov    %edi,%edx
  801c20:	83 c4 1c             	add    $0x1c,%esp
  801c23:	5b                   	pop    %ebx
  801c24:	5e                   	pop    %esi
  801c25:	5f                   	pop    %edi
  801c26:	5d                   	pop    %ebp
  801c27:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801c28:	39 ce                	cmp    %ecx,%esi
  801c2a:	77 28                	ja     801c54 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801c2c:	0f bd fe             	bsr    %esi,%edi
	  if (bm == 0)
  801c2f:	83 f7 1f             	xor    $0x1f,%edi
  801c32:	75 40                	jne    801c74 <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801c34:	39 ce                	cmp    %ecx,%esi
  801c36:	72 0a                	jb     801c42 <__udivdi3+0x6a>
  801c38:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801c3c:	0f 87 9e 00 00 00    	ja     801ce0 <__udivdi3+0x108>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801c42:	b8 01 00 00 00       	mov    $0x1,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c47:	89 fa                	mov    %edi,%edx
  801c49:	83 c4 1c             	add    $0x1c,%esp
  801c4c:	5b                   	pop    %ebx
  801c4d:	5e                   	pop    %esi
  801c4e:	5f                   	pop    %edi
  801c4f:	5d                   	pop    %ebp
  801c50:	c3                   	ret    
  801c51:	8d 76 00             	lea    0x0(%esi),%esi
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801c54:	31 ff                	xor    %edi,%edi
  801c56:	31 c0                	xor    %eax,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c58:	89 fa                	mov    %edi,%edx
  801c5a:	83 c4 1c             	add    $0x1c,%esp
  801c5d:	5b                   	pop    %ebx
  801c5e:	5e                   	pop    %esi
  801c5f:	5f                   	pop    %edi
  801c60:	5d                   	pop    %ebp
  801c61:	c3                   	ret    
  801c62:	66 90                	xchg   %ax,%ax
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c64:	89 d8                	mov    %ebx,%eax
  801c66:	f7 f7                	div    %edi
  801c68:	31 ff                	xor    %edi,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c6a:	89 fa                	mov    %edi,%edx
  801c6c:	83 c4 1c             	add    $0x1c,%esp
  801c6f:	5b                   	pop    %ebx
  801c70:	5e                   	pop    %esi
  801c71:	5f                   	pop    %edi
  801c72:	5d                   	pop    %ebp
  801c73:	c3                   	ret    
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801c74:	bd 20 00 00 00       	mov    $0x20,%ebp
  801c79:	89 eb                	mov    %ebp,%ebx
  801c7b:	29 fb                	sub    %edi,%ebx

	      d1 = (d1 << bm) | (d0 >> b);
  801c7d:	89 f9                	mov    %edi,%ecx
  801c7f:	d3 e6                	shl    %cl,%esi
  801c81:	89 c5                	mov    %eax,%ebp
  801c83:	88 d9                	mov    %bl,%cl
  801c85:	d3 ed                	shr    %cl,%ebp
  801c87:	89 e9                	mov    %ebp,%ecx
  801c89:	09 f1                	or     %esi,%ecx
  801c8b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
	      d0 = d0 << bm;
  801c8f:	89 f9                	mov    %edi,%ecx
  801c91:	d3 e0                	shl    %cl,%eax
  801c93:	89 c5                	mov    %eax,%ebp
	      n2 = n1 >> b;
  801c95:	89 d6                	mov    %edx,%esi
  801c97:	88 d9                	mov    %bl,%cl
  801c99:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
  801c9b:	89 f9                	mov    %edi,%ecx
  801c9d:	d3 e2                	shl    %cl,%edx
  801c9f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ca3:	88 d9                	mov    %bl,%cl
  801ca5:	d3 e8                	shr    %cl,%eax
  801ca7:	09 c2                	or     %eax,%edx
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801ca9:	89 d0                	mov    %edx,%eax
  801cab:	89 f2                	mov    %esi,%edx
  801cad:	f7 74 24 0c          	divl   0xc(%esp)
  801cb1:	89 d6                	mov    %edx,%esi
  801cb3:	89 c3                	mov    %eax,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  801cb5:	f7 e5                	mul    %ebp

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801cb7:	39 d6                	cmp    %edx,%esi
  801cb9:	72 19                	jb     801cd4 <__udivdi3+0xfc>
  801cbb:	74 0b                	je     801cc8 <__udivdi3+0xf0>
  801cbd:	89 d8                	mov    %ebx,%eax
  801cbf:	31 ff                	xor    %edi,%edi
  801cc1:	e9 58 ff ff ff       	jmp    801c1e <__udivdi3+0x46>
  801cc6:	66 90                	xchg   %ax,%ax
  801cc8:	8b 54 24 08          	mov    0x8(%esp),%edx
  801ccc:	89 f9                	mov    %edi,%ecx
  801cce:	d3 e2                	shl    %cl,%edx
  801cd0:	39 c2                	cmp    %eax,%edx
  801cd2:	73 e9                	jae    801cbd <__udivdi3+0xe5>
  801cd4:	8d 43 ff             	lea    -0x1(%ebx),%eax
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801cd7:	31 ff                	xor    %edi,%edi
  801cd9:	e9 40 ff ff ff       	jmp    801c1e <__udivdi3+0x46>
  801cde:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801ce0:	31 c0                	xor    %eax,%eax
  801ce2:	e9 37 ff ff ff       	jmp    801c1e <__udivdi3+0x46>
  801ce7:	90                   	nop

00801ce8 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801ce8:	55                   	push   %ebp
  801ce9:	57                   	push   %edi
  801cea:	56                   	push   %esi
  801ceb:	53                   	push   %ebx
  801cec:	83 ec 1c             	sub    $0x1c,%esp
  801cef:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801cf3:	8b 74 24 34          	mov    0x34(%esp),%esi
  801cf7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801cfb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801cff:	89 44 24 0c          	mov    %eax,0xc(%esp)
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801d03:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d07:	89 f3                	mov    %esi,%ebx
  const DWunion dd = {.ll = d};
  801d09:	89 fa                	mov    %edi,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801d0b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  n1 = nn.s.high;
  801d0f:	89 34 24             	mov    %esi,(%esp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801d12:	85 c0                	test   %eax,%eax
  801d14:	75 1a                	jne    801d30 <__umoddi3+0x48>
    {
      if (d0 > n1)
  801d16:	39 f7                	cmp    %esi,%edi
  801d18:	0f 86 a2 00 00 00    	jbe    801dc0 <__umoddi3+0xd8>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d1e:	89 c8                	mov    %ecx,%eax
  801d20:	89 f2                	mov    %esi,%edx
  801d22:	f7 f7                	div    %edi
  801d24:	89 d0                	mov    %edx,%eax

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801d26:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d28:	83 c4 1c             	add    $0x1c,%esp
  801d2b:	5b                   	pop    %ebx
  801d2c:	5e                   	pop    %esi
  801d2d:	5f                   	pop    %edi
  801d2e:	5d                   	pop    %ebp
  801d2f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801d30:	39 f0                	cmp    %esi,%eax
  801d32:	0f 87 ac 00 00 00    	ja     801de4 <__umoddi3+0xfc>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801d38:	0f bd e8             	bsr    %eax,%ebp
	  if (bm == 0)
  801d3b:	83 f5 1f             	xor    $0x1f,%ebp
  801d3e:	0f 84 ac 00 00 00    	je     801df0 <__umoddi3+0x108>
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801d44:	bf 20 00 00 00       	mov    $0x20,%edi
  801d49:	29 ef                	sub    %ebp,%edi
  801d4b:	89 fe                	mov    %edi,%esi
  801d4d:	89 7c 24 0c          	mov    %edi,0xc(%esp)

	      d1 = (d1 << bm) | (d0 >> b);
  801d51:	89 e9                	mov    %ebp,%ecx
  801d53:	d3 e0                	shl    %cl,%eax
  801d55:	89 d7                	mov    %edx,%edi
  801d57:	89 f1                	mov    %esi,%ecx
  801d59:	d3 ef                	shr    %cl,%edi
  801d5b:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  801d5d:	89 e9                	mov    %ebp,%ecx
  801d5f:	d3 e2                	shl    %cl,%edx
  801d61:	89 14 24             	mov    %edx,(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801d64:	89 d8                	mov    %ebx,%eax
  801d66:	d3 e0                	shl    %cl,%eax
  801d68:	89 c2                	mov    %eax,%edx
	      n0 = n0 << bm;
  801d6a:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d6e:	d3 e0                	shl    %cl,%eax
  801d70:	89 44 24 04          	mov    %eax,0x4(%esp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801d74:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d78:	89 f1                	mov    %esi,%ecx
  801d7a:	d3 e8                	shr    %cl,%eax
  801d7c:	09 d0                	or     %edx,%eax
  801d7e:	d3 eb                	shr    %cl,%ebx
  801d80:	89 da                	mov    %ebx,%edx
  801d82:	f7 f7                	div    %edi
  801d84:	89 d3                	mov    %edx,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  801d86:	f7 24 24             	mull   (%esp)
  801d89:	89 c6                	mov    %eax,%esi
  801d8b:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d8d:	39 d3                	cmp    %edx,%ebx
  801d8f:	0f 82 87 00 00 00    	jb     801e1c <__umoddi3+0x134>
  801d95:	0f 84 91 00 00 00    	je     801e2c <__umoddi3+0x144>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801d9b:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d9f:	29 f2                	sub    %esi,%edx
  801da1:	19 cb                	sbb    %ecx,%ebx
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801da3:	89 d8                	mov    %ebx,%eax
  801da5:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  801da9:	d3 e0                	shl    %cl,%eax
  801dab:	89 e9                	mov    %ebp,%ecx
  801dad:	d3 ea                	shr    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801daf:	09 d0                	or     %edx,%eax
  801db1:	89 e9                	mov    %ebp,%ecx
  801db3:	d3 eb                	shr    %cl,%ebx
  801db5:	89 da                	mov    %ebx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801db7:	83 c4 1c             	add    $0x1c,%esp
  801dba:	5b                   	pop    %ebx
  801dbb:	5e                   	pop    %esi
  801dbc:	5f                   	pop    %edi
  801dbd:	5d                   	pop    %ebp
  801dbe:	c3                   	ret    
  801dbf:	90                   	nop
  801dc0:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801dc2:	85 ff                	test   %edi,%edi
  801dc4:	75 0b                	jne    801dd1 <__umoddi3+0xe9>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801dc6:	b8 01 00 00 00       	mov    $0x1,%eax
  801dcb:	31 d2                	xor    %edx,%edx
  801dcd:	f7 f7                	div    %edi
  801dcf:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801dd1:	89 f0                	mov    %esi,%eax
  801dd3:	31 d2                	xor    %edx,%edx
  801dd5:	f7 f5                	div    %ebp
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801dd7:	89 c8                	mov    %ecx,%eax
  801dd9:	f7 f5                	div    %ebp
  801ddb:	89 d0                	mov    %edx,%eax
  801ddd:	e9 44 ff ff ff       	jmp    801d26 <__umoddi3+0x3e>
  801de2:	66 90                	xchg   %ax,%ax
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801de4:	89 c8                	mov    %ecx,%eax
  801de6:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801de8:	83 c4 1c             	add    $0x1c,%esp
  801deb:	5b                   	pop    %ebx
  801dec:	5e                   	pop    %esi
  801ded:	5f                   	pop    %edi
  801dee:	5d                   	pop    %ebp
  801def:	c3                   	ret    

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801df0:	3b 04 24             	cmp    (%esp),%eax
  801df3:	72 06                	jb     801dfb <__umoddi3+0x113>
  801df5:	3b 7c 24 04          	cmp    0x4(%esp),%edi
  801df9:	77 0f                	ja     801e0a <__umoddi3+0x122>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801dfb:	89 f2                	mov    %esi,%edx
  801dfd:	29 f9                	sub    %edi,%ecx
  801dff:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  801e03:	89 14 24             	mov    %edx,(%esp)
  801e06:	89 4c 24 04          	mov    %ecx,0x4(%esp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801e0a:	8b 44 24 04          	mov    0x4(%esp),%eax
  801e0e:	8b 14 24             	mov    (%esp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e11:	83 c4 1c             	add    $0x1c,%esp
  801e14:	5b                   	pop    %ebx
  801e15:	5e                   	pop    %esi
  801e16:	5f                   	pop    %edi
  801e17:	5d                   	pop    %ebp
  801e18:	c3                   	ret    
  801e19:	8d 76 00             	lea    0x0(%esi),%esi
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801e1c:	2b 04 24             	sub    (%esp),%eax
  801e1f:	19 fa                	sbb    %edi,%edx
  801e21:	89 d1                	mov    %edx,%ecx
  801e23:	89 c6                	mov    %eax,%esi
  801e25:	e9 71 ff ff ff       	jmp    801d9b <__umoddi3+0xb3>
  801e2a:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e2c:	39 44 24 04          	cmp    %eax,0x4(%esp)
  801e30:	72 ea                	jb     801e1c <__umoddi3+0x134>
  801e32:	89 d9                	mov    %ebx,%ecx
  801e34:	e9 62 ff ff ff       	jmp    801d9b <__umoddi3+0xb3>
