
obj/user/faultevilhandler.debug:     file format elf32-i386


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
  80002c:	e8 34 00 00 00       	call   800065 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 0c             	sub    $0xc,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  800039:	6a 07                	push   $0x7
  80003b:	68 00 f0 bf ee       	push   $0xeebff000
  800040:	6a 00                	push   $0x0
  800042:	e8 43 01 00 00       	call   80018a <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xF0100020);
  800047:	83 c4 08             	add    $0x8,%esp
  80004a:	68 20 00 10 f0       	push   $0xf0100020
  80004f:	6a 00                	push   $0x0
  800051:	e8 7f 02 00 00       	call   8002d5 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800056:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80005d:	00 00 00 
}
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	c9                   	leave  
  800064:	c3                   	ret    

00800065 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800065:	55                   	push   %ebp
  800066:	89 e5                	mov    %esp,%ebp
  800068:	56                   	push   %esi
  800069:	53                   	push   %ebx
  80006a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80006d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800070:	e8 d7 00 00 00       	call   80014c <sys_getenvid>
  800075:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800081:	c1 e0 07             	shl    $0x7,%eax
  800084:	29 d0                	sub    %edx,%eax
  800086:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80008b:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800090:	85 db                	test   %ebx,%ebx
  800092:	7e 07                	jle    80009b <libmain+0x36>
		binaryname = argv[0];
  800094:	8b 06                	mov    (%esi),%eax
  800096:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80009b:	83 ec 08             	sub    $0x8,%esp
  80009e:	56                   	push   %esi
  80009f:	53                   	push   %ebx
  8000a0:	e8 8e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000a5:	e8 0a 00 00 00       	call   8000b4 <exit>
}
  8000aa:	83 c4 10             	add    $0x10,%esp
  8000ad:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000b0:	5b                   	pop    %ebx
  8000b1:	5e                   	pop    %esi
  8000b2:	5d                   	pop    %ebp
  8000b3:	c3                   	ret    

008000b4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000ba:	e8 cb 04 00 00       	call   80058a <close_all>
	sys_env_destroy(0);
  8000bf:	83 ec 0c             	sub    $0xc,%esp
  8000c2:	6a 00                	push   $0x0
  8000c4:	e8 42 00 00 00       	call   80010b <sys_env_destroy>
}
  8000c9:	83 c4 10             	add    $0x10,%esp
  8000cc:	c9                   	leave  
  8000cd:	c3                   	ret    

008000ce <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
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
  8000d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000df:	89 c3                	mov    %eax,%ebx
  8000e1:	89 c7                	mov    %eax,%edi
  8000e3:	89 c6                	mov    %eax,%esi
  8000e5:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000e7:	5b                   	pop    %ebx
  8000e8:	5e                   	pop    %esi
  8000e9:	5f                   	pop    %edi
  8000ea:	5d                   	pop    %ebp
  8000eb:	c3                   	ret    

008000ec <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ec:	55                   	push   %ebp
  8000ed:	89 e5                	mov    %esp,%ebp
  8000ef:	57                   	push   %edi
  8000f0:	56                   	push   %esi
  8000f1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8000f7:	b8 01 00 00 00       	mov    $0x1,%eax
  8000fc:	89 d1                	mov    %edx,%ecx
  8000fe:	89 d3                	mov    %edx,%ebx
  800100:	89 d7                	mov    %edx,%edi
  800102:	89 d6                	mov    %edx,%esi
  800104:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800106:	5b                   	pop    %ebx
  800107:	5e                   	pop    %esi
  800108:	5f                   	pop    %edi
  800109:	5d                   	pop    %ebp
  80010a:	c3                   	ret    

0080010b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80010b:	55                   	push   %ebp
  80010c:	89 e5                	mov    %esp,%ebp
  80010e:	57                   	push   %edi
  80010f:	56                   	push   %esi
  800110:	53                   	push   %ebx
  800111:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800114:	b9 00 00 00 00       	mov    $0x0,%ecx
  800119:	b8 03 00 00 00       	mov    $0x3,%eax
  80011e:	8b 55 08             	mov    0x8(%ebp),%edx
  800121:	89 cb                	mov    %ecx,%ebx
  800123:	89 cf                	mov    %ecx,%edi
  800125:	89 ce                	mov    %ecx,%esi
  800127:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800129:	85 c0                	test   %eax,%eax
  80012b:	7e 17                	jle    800144 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80012d:	83 ec 0c             	sub    $0xc,%esp
  800130:	50                   	push   %eax
  800131:	6a 03                	push   $0x3
  800133:	68 6a 1e 80 00       	push   $0x801e6a
  800138:	6a 23                	push   $0x23
  80013a:	68 87 1e 80 00       	push   $0x801e87
  80013f:	e8 cf 0e 00 00       	call   801013 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800144:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800147:	5b                   	pop    %ebx
  800148:	5e                   	pop    %esi
  800149:	5f                   	pop    %edi
  80014a:	5d                   	pop    %ebp
  80014b:	c3                   	ret    

0080014c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	57                   	push   %edi
  800150:	56                   	push   %esi
  800151:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800152:	ba 00 00 00 00       	mov    $0x0,%edx
  800157:	b8 02 00 00 00       	mov    $0x2,%eax
  80015c:	89 d1                	mov    %edx,%ecx
  80015e:	89 d3                	mov    %edx,%ebx
  800160:	89 d7                	mov    %edx,%edi
  800162:	89 d6                	mov    %edx,%esi
  800164:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800166:	5b                   	pop    %ebx
  800167:	5e                   	pop    %esi
  800168:	5f                   	pop    %edi
  800169:	5d                   	pop    %ebp
  80016a:	c3                   	ret    

0080016b <sys_yield>:

void
sys_yield(void)
{
  80016b:	55                   	push   %ebp
  80016c:	89 e5                	mov    %esp,%ebp
  80016e:	57                   	push   %edi
  80016f:	56                   	push   %esi
  800170:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800171:	ba 00 00 00 00       	mov    $0x0,%edx
  800176:	b8 0b 00 00 00       	mov    $0xb,%eax
  80017b:	89 d1                	mov    %edx,%ecx
  80017d:	89 d3                	mov    %edx,%ebx
  80017f:	89 d7                	mov    %edx,%edi
  800181:	89 d6                	mov    %edx,%esi
  800183:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800185:	5b                   	pop    %ebx
  800186:	5e                   	pop    %esi
  800187:	5f                   	pop    %edi
  800188:	5d                   	pop    %ebp
  800189:	c3                   	ret    

0080018a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80018a:	55                   	push   %ebp
  80018b:	89 e5                	mov    %esp,%ebp
  80018d:	57                   	push   %edi
  80018e:	56                   	push   %esi
  80018f:	53                   	push   %ebx
  800190:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800193:	be 00 00 00 00       	mov    $0x0,%esi
  800198:	b8 04 00 00 00       	mov    $0x4,%eax
  80019d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001a6:	89 f7                	mov    %esi,%edi
  8001a8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001aa:	85 c0                	test   %eax,%eax
  8001ac:	7e 17                	jle    8001c5 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ae:	83 ec 0c             	sub    $0xc,%esp
  8001b1:	50                   	push   %eax
  8001b2:	6a 04                	push   $0x4
  8001b4:	68 6a 1e 80 00       	push   $0x801e6a
  8001b9:	6a 23                	push   $0x23
  8001bb:	68 87 1e 80 00       	push   $0x801e87
  8001c0:	e8 4e 0e 00 00       	call   801013 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001c8:	5b                   	pop    %ebx
  8001c9:	5e                   	pop    %esi
  8001ca:	5f                   	pop    %edi
  8001cb:	5d                   	pop    %ebp
  8001cc:	c3                   	ret    

008001cd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001cd:	55                   	push   %ebp
  8001ce:	89 e5                	mov    %esp,%ebp
  8001d0:	57                   	push   %edi
  8001d1:	56                   	push   %esi
  8001d2:	53                   	push   %ebx
  8001d3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001d6:	b8 05 00 00 00       	mov    $0x5,%eax
  8001db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001de:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001e4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001e7:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ea:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001ec:	85 c0                	test   %eax,%eax
  8001ee:	7e 17                	jle    800207 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001f0:	83 ec 0c             	sub    $0xc,%esp
  8001f3:	50                   	push   %eax
  8001f4:	6a 05                	push   $0x5
  8001f6:	68 6a 1e 80 00       	push   $0x801e6a
  8001fb:	6a 23                	push   $0x23
  8001fd:	68 87 1e 80 00       	push   $0x801e87
  800202:	e8 0c 0e 00 00       	call   801013 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800207:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80020a:	5b                   	pop    %ebx
  80020b:	5e                   	pop    %esi
  80020c:	5f                   	pop    %edi
  80020d:	5d                   	pop    %ebp
  80020e:	c3                   	ret    

0080020f <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80020f:	55                   	push   %ebp
  800210:	89 e5                	mov    %esp,%ebp
  800212:	57                   	push   %edi
  800213:	56                   	push   %esi
  800214:	53                   	push   %ebx
  800215:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800218:	bb 00 00 00 00       	mov    $0x0,%ebx
  80021d:	b8 06 00 00 00       	mov    $0x6,%eax
  800222:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800225:	8b 55 08             	mov    0x8(%ebp),%edx
  800228:	89 df                	mov    %ebx,%edi
  80022a:	89 de                	mov    %ebx,%esi
  80022c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80022e:	85 c0                	test   %eax,%eax
  800230:	7e 17                	jle    800249 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800232:	83 ec 0c             	sub    $0xc,%esp
  800235:	50                   	push   %eax
  800236:	6a 06                	push   $0x6
  800238:	68 6a 1e 80 00       	push   $0x801e6a
  80023d:	6a 23                	push   $0x23
  80023f:	68 87 1e 80 00       	push   $0x801e87
  800244:	e8 ca 0d 00 00       	call   801013 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800249:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80024c:	5b                   	pop    %ebx
  80024d:	5e                   	pop    %esi
  80024e:	5f                   	pop    %edi
  80024f:	5d                   	pop    %ebp
  800250:	c3                   	ret    

00800251 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800251:	55                   	push   %ebp
  800252:	89 e5                	mov    %esp,%ebp
  800254:	57                   	push   %edi
  800255:	56                   	push   %esi
  800256:	53                   	push   %ebx
  800257:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80025a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80025f:	b8 08 00 00 00       	mov    $0x8,%eax
  800264:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800267:	8b 55 08             	mov    0x8(%ebp),%edx
  80026a:	89 df                	mov    %ebx,%edi
  80026c:	89 de                	mov    %ebx,%esi
  80026e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800270:	85 c0                	test   %eax,%eax
  800272:	7e 17                	jle    80028b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800274:	83 ec 0c             	sub    $0xc,%esp
  800277:	50                   	push   %eax
  800278:	6a 08                	push   $0x8
  80027a:	68 6a 1e 80 00       	push   $0x801e6a
  80027f:	6a 23                	push   $0x23
  800281:	68 87 1e 80 00       	push   $0x801e87
  800286:	e8 88 0d 00 00       	call   801013 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80028b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80028e:	5b                   	pop    %ebx
  80028f:	5e                   	pop    %esi
  800290:	5f                   	pop    %edi
  800291:	5d                   	pop    %ebp
  800292:	c3                   	ret    

00800293 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800293:	55                   	push   %ebp
  800294:	89 e5                	mov    %esp,%ebp
  800296:	57                   	push   %edi
  800297:	56                   	push   %esi
  800298:	53                   	push   %ebx
  800299:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80029c:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002a1:	b8 09 00 00 00       	mov    $0x9,%eax
  8002a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ac:	89 df                	mov    %ebx,%edi
  8002ae:	89 de                	mov    %ebx,%esi
  8002b0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002b2:	85 c0                	test   %eax,%eax
  8002b4:	7e 17                	jle    8002cd <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002b6:	83 ec 0c             	sub    $0xc,%esp
  8002b9:	50                   	push   %eax
  8002ba:	6a 09                	push   $0x9
  8002bc:	68 6a 1e 80 00       	push   $0x801e6a
  8002c1:	6a 23                	push   $0x23
  8002c3:	68 87 1e 80 00       	push   $0x801e87
  8002c8:	e8 46 0d 00 00       	call   801013 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d0:	5b                   	pop    %ebx
  8002d1:	5e                   	pop    %esi
  8002d2:	5f                   	pop    %edi
  8002d3:	5d                   	pop    %ebp
  8002d4:	c3                   	ret    

008002d5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002d5:	55                   	push   %ebp
  8002d6:	89 e5                	mov    %esp,%ebp
  8002d8:	57                   	push   %edi
  8002d9:	56                   	push   %esi
  8002da:	53                   	push   %ebx
  8002db:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002de:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002e3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ee:	89 df                	mov    %ebx,%edi
  8002f0:	89 de                	mov    %ebx,%esi
  8002f2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002f4:	85 c0                	test   %eax,%eax
  8002f6:	7e 17                	jle    80030f <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f8:	83 ec 0c             	sub    $0xc,%esp
  8002fb:	50                   	push   %eax
  8002fc:	6a 0a                	push   $0xa
  8002fe:	68 6a 1e 80 00       	push   $0x801e6a
  800303:	6a 23                	push   $0x23
  800305:	68 87 1e 80 00       	push   $0x801e87
  80030a:	e8 04 0d 00 00       	call   801013 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80030f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800312:	5b                   	pop    %ebx
  800313:	5e                   	pop    %esi
  800314:	5f                   	pop    %edi
  800315:	5d                   	pop    %ebp
  800316:	c3                   	ret    

00800317 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800317:	55                   	push   %ebp
  800318:	89 e5                	mov    %esp,%ebp
  80031a:	57                   	push   %edi
  80031b:	56                   	push   %esi
  80031c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80031d:	be 00 00 00 00       	mov    $0x0,%esi
  800322:	b8 0c 00 00 00       	mov    $0xc,%eax
  800327:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80032a:	8b 55 08             	mov    0x8(%ebp),%edx
  80032d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800330:	8b 7d 14             	mov    0x14(%ebp),%edi
  800333:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800335:	5b                   	pop    %ebx
  800336:	5e                   	pop    %esi
  800337:	5f                   	pop    %edi
  800338:	5d                   	pop    %ebp
  800339:	c3                   	ret    

0080033a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80033a:	55                   	push   %ebp
  80033b:	89 e5                	mov    %esp,%ebp
  80033d:	57                   	push   %edi
  80033e:	56                   	push   %esi
  80033f:	53                   	push   %ebx
  800340:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800343:	b9 00 00 00 00       	mov    $0x0,%ecx
  800348:	b8 0d 00 00 00       	mov    $0xd,%eax
  80034d:	8b 55 08             	mov    0x8(%ebp),%edx
  800350:	89 cb                	mov    %ecx,%ebx
  800352:	89 cf                	mov    %ecx,%edi
  800354:	89 ce                	mov    %ecx,%esi
  800356:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800358:	85 c0                	test   %eax,%eax
  80035a:	7e 17                	jle    800373 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80035c:	83 ec 0c             	sub    $0xc,%esp
  80035f:	50                   	push   %eax
  800360:	6a 0d                	push   $0xd
  800362:	68 6a 1e 80 00       	push   $0x801e6a
  800367:	6a 23                	push   $0x23
  800369:	68 87 1e 80 00       	push   $0x801e87
  80036e:	e8 a0 0c 00 00       	call   801013 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800373:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800376:	5b                   	pop    %ebx
  800377:	5e                   	pop    %esi
  800378:	5f                   	pop    %edi
  800379:	5d                   	pop    %ebp
  80037a:	c3                   	ret    

0080037b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80037b:	55                   	push   %ebp
  80037c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80037e:	8b 45 08             	mov    0x8(%ebp),%eax
  800381:	05 00 00 00 30       	add    $0x30000000,%eax
  800386:	c1 e8 0c             	shr    $0xc,%eax
}
  800389:	5d                   	pop    %ebp
  80038a:	c3                   	ret    

0080038b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80038b:	55                   	push   %ebp
  80038c:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80038e:	8b 45 08             	mov    0x8(%ebp),%eax
  800391:	05 00 00 00 30       	add    $0x30000000,%eax
  800396:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80039b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003a0:	5d                   	pop    %ebp
  8003a1:	c3                   	ret    

008003a2 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003a2:	55                   	push   %ebp
  8003a3:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003a5:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8003aa:	a8 01                	test   $0x1,%al
  8003ac:	74 34                	je     8003e2 <fd_alloc+0x40>
  8003ae:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8003b3:	a8 01                	test   $0x1,%al
  8003b5:	74 32                	je     8003e9 <fd_alloc+0x47>
  8003b7:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8003bc:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003be:	89 c2                	mov    %eax,%edx
  8003c0:	c1 ea 16             	shr    $0x16,%edx
  8003c3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003ca:	f6 c2 01             	test   $0x1,%dl
  8003cd:	74 1f                	je     8003ee <fd_alloc+0x4c>
  8003cf:	89 c2                	mov    %eax,%edx
  8003d1:	c1 ea 0c             	shr    $0xc,%edx
  8003d4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003db:	f6 c2 01             	test   $0x1,%dl
  8003de:	75 1a                	jne    8003fa <fd_alloc+0x58>
  8003e0:	eb 0c                	jmp    8003ee <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8003e2:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8003e7:	eb 05                	jmp    8003ee <fd_alloc+0x4c>
  8003e9:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8003ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f1:	89 08                	mov    %ecx,(%eax)
			return 0;
  8003f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8003f8:	eb 1a                	jmp    800414 <fd_alloc+0x72>
  8003fa:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003ff:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800404:	75 b6                	jne    8003bc <fd_alloc+0x1a>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800406:	8b 45 08             	mov    0x8(%ebp),%eax
  800409:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  80040f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800414:	5d                   	pop    %ebp
  800415:	c3                   	ret    

00800416 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800416:	55                   	push   %ebp
  800417:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800419:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  80041d:	77 39                	ja     800458 <fd_lookup+0x42>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80041f:	8b 45 08             	mov    0x8(%ebp),%eax
  800422:	c1 e0 0c             	shl    $0xc,%eax
  800425:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80042a:	89 c2                	mov    %eax,%edx
  80042c:	c1 ea 16             	shr    $0x16,%edx
  80042f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800436:	f6 c2 01             	test   $0x1,%dl
  800439:	74 24                	je     80045f <fd_lookup+0x49>
  80043b:	89 c2                	mov    %eax,%edx
  80043d:	c1 ea 0c             	shr    $0xc,%edx
  800440:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800447:	f6 c2 01             	test   $0x1,%dl
  80044a:	74 1a                	je     800466 <fd_lookup+0x50>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80044c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80044f:	89 02                	mov    %eax,(%edx)
	return 0;
  800451:	b8 00 00 00 00       	mov    $0x0,%eax
  800456:	eb 13                	jmp    80046b <fd_lookup+0x55>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800458:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80045d:	eb 0c                	jmp    80046b <fd_lookup+0x55>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80045f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800464:	eb 05                	jmp    80046b <fd_lookup+0x55>
  800466:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80046b:	5d                   	pop    %ebp
  80046c:	c3                   	ret    

0080046d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80046d:	55                   	push   %ebp
  80046e:	89 e5                	mov    %esp,%ebp
  800470:	53                   	push   %ebx
  800471:	83 ec 04             	sub    $0x4,%esp
  800474:	8b 45 08             	mov    0x8(%ebp),%eax
  800477:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80047a:	3b 05 04 30 80 00    	cmp    0x803004,%eax
  800480:	75 1e                	jne    8004a0 <dev_lookup+0x33>
  800482:	eb 0e                	jmp    800492 <dev_lookup+0x25>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800484:	b8 20 30 80 00       	mov    $0x803020,%eax
  800489:	eb 0c                	jmp    800497 <dev_lookup+0x2a>
  80048b:	b8 3c 30 80 00       	mov    $0x80303c,%eax
  800490:	eb 05                	jmp    800497 <dev_lookup+0x2a>
  800492:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800497:	89 03                	mov    %eax,(%ebx)
			return 0;
  800499:	b8 00 00 00 00       	mov    $0x0,%eax
  80049e:	eb 36                	jmp    8004d6 <dev_lookup+0x69>
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8004a0:	3b 05 20 30 80 00    	cmp    0x803020,%eax
  8004a6:	74 dc                	je     800484 <dev_lookup+0x17>
  8004a8:	3b 05 3c 30 80 00    	cmp    0x80303c,%eax
  8004ae:	74 db                	je     80048b <dev_lookup+0x1e>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8004b0:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8004b6:	8b 52 48             	mov    0x48(%edx),%edx
  8004b9:	83 ec 04             	sub    $0x4,%esp
  8004bc:	50                   	push   %eax
  8004bd:	52                   	push   %edx
  8004be:	68 98 1e 80 00       	push   $0x801e98
  8004c3:	e8 23 0c 00 00       	call   8010eb <cprintf>
	*dev = 0;
  8004c8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8004ce:	83 c4 10             	add    $0x10,%esp
  8004d1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004d9:	c9                   	leave  
  8004da:	c3                   	ret    

008004db <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004db:	55                   	push   %ebp
  8004dc:	89 e5                	mov    %esp,%ebp
  8004de:	56                   	push   %esi
  8004df:	53                   	push   %ebx
  8004e0:	83 ec 10             	sub    $0x10,%esp
  8004e3:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004ec:	50                   	push   %eax
  8004ed:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004f3:	c1 e8 0c             	shr    $0xc,%eax
  8004f6:	50                   	push   %eax
  8004f7:	e8 1a ff ff ff       	call   800416 <fd_lookup>
  8004fc:	83 c4 08             	add    $0x8,%esp
  8004ff:	85 c0                	test   %eax,%eax
  800501:	78 05                	js     800508 <fd_close+0x2d>
	    || fd != fd2)
  800503:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800506:	74 06                	je     80050e <fd_close+0x33>
		return (must_exist ? r : 0);
  800508:	84 db                	test   %bl,%bl
  80050a:	74 47                	je     800553 <fd_close+0x78>
  80050c:	eb 4a                	jmp    800558 <fd_close+0x7d>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80050e:	83 ec 08             	sub    $0x8,%esp
  800511:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800514:	50                   	push   %eax
  800515:	ff 36                	pushl  (%esi)
  800517:	e8 51 ff ff ff       	call   80046d <dev_lookup>
  80051c:	89 c3                	mov    %eax,%ebx
  80051e:	83 c4 10             	add    $0x10,%esp
  800521:	85 c0                	test   %eax,%eax
  800523:	78 1c                	js     800541 <fd_close+0x66>
		if (dev->dev_close)
  800525:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800528:	8b 40 10             	mov    0x10(%eax),%eax
  80052b:	85 c0                	test   %eax,%eax
  80052d:	74 0d                	je     80053c <fd_close+0x61>
			r = (*dev->dev_close)(fd);
  80052f:	83 ec 0c             	sub    $0xc,%esp
  800532:	56                   	push   %esi
  800533:	ff d0                	call   *%eax
  800535:	89 c3                	mov    %eax,%ebx
  800537:	83 c4 10             	add    $0x10,%esp
  80053a:	eb 05                	jmp    800541 <fd_close+0x66>
		else
			r = 0;
  80053c:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800541:	83 ec 08             	sub    $0x8,%esp
  800544:	56                   	push   %esi
  800545:	6a 00                	push   $0x0
  800547:	e8 c3 fc ff ff       	call   80020f <sys_page_unmap>
	return r;
  80054c:	83 c4 10             	add    $0x10,%esp
  80054f:	89 d8                	mov    %ebx,%eax
  800551:	eb 05                	jmp    800558 <fd_close+0x7d>
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
  800553:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
	return r;
}
  800558:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80055b:	5b                   	pop    %ebx
  80055c:	5e                   	pop    %esi
  80055d:	5d                   	pop    %ebp
  80055e:	c3                   	ret    

0080055f <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80055f:	55                   	push   %ebp
  800560:	89 e5                	mov    %esp,%ebp
  800562:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800565:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800568:	50                   	push   %eax
  800569:	ff 75 08             	pushl  0x8(%ebp)
  80056c:	e8 a5 fe ff ff       	call   800416 <fd_lookup>
  800571:	83 c4 08             	add    $0x8,%esp
  800574:	85 c0                	test   %eax,%eax
  800576:	78 10                	js     800588 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800578:	83 ec 08             	sub    $0x8,%esp
  80057b:	6a 01                	push   $0x1
  80057d:	ff 75 f4             	pushl  -0xc(%ebp)
  800580:	e8 56 ff ff ff       	call   8004db <fd_close>
  800585:	83 c4 10             	add    $0x10,%esp
}
  800588:	c9                   	leave  
  800589:	c3                   	ret    

0080058a <close_all>:

void
close_all(void)
{
  80058a:	55                   	push   %ebp
  80058b:	89 e5                	mov    %esp,%ebp
  80058d:	53                   	push   %ebx
  80058e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800591:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800596:	83 ec 0c             	sub    $0xc,%esp
  800599:	53                   	push   %ebx
  80059a:	e8 c0 ff ff ff       	call   80055f <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80059f:	43                   	inc    %ebx
  8005a0:	83 c4 10             	add    $0x10,%esp
  8005a3:	83 fb 20             	cmp    $0x20,%ebx
  8005a6:	75 ee                	jne    800596 <close_all+0xc>
		close(i);
}
  8005a8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8005ab:	c9                   	leave  
  8005ac:	c3                   	ret    

008005ad <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8005ad:	55                   	push   %ebp
  8005ae:	89 e5                	mov    %esp,%ebp
  8005b0:	57                   	push   %edi
  8005b1:	56                   	push   %esi
  8005b2:	53                   	push   %ebx
  8005b3:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005b6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005b9:	50                   	push   %eax
  8005ba:	ff 75 08             	pushl  0x8(%ebp)
  8005bd:	e8 54 fe ff ff       	call   800416 <fd_lookup>
  8005c2:	83 c4 08             	add    $0x8,%esp
  8005c5:	85 c0                	test   %eax,%eax
  8005c7:	0f 88 c2 00 00 00    	js     80068f <dup+0xe2>
		return r;
	close(newfdnum);
  8005cd:	83 ec 0c             	sub    $0xc,%esp
  8005d0:	ff 75 0c             	pushl  0xc(%ebp)
  8005d3:	e8 87 ff ff ff       	call   80055f <close>

	newfd = INDEX2FD(newfdnum);
  8005d8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005db:	c1 e3 0c             	shl    $0xc,%ebx
  8005de:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8005e4:	83 c4 04             	add    $0x4,%esp
  8005e7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005ea:	e8 9c fd ff ff       	call   80038b <fd2data>
  8005ef:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  8005f1:	89 1c 24             	mov    %ebx,(%esp)
  8005f4:	e8 92 fd ff ff       	call   80038b <fd2data>
  8005f9:	83 c4 10             	add    $0x10,%esp
  8005fc:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005fe:	89 f0                	mov    %esi,%eax
  800600:	c1 e8 16             	shr    $0x16,%eax
  800603:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80060a:	a8 01                	test   $0x1,%al
  80060c:	74 35                	je     800643 <dup+0x96>
  80060e:	89 f0                	mov    %esi,%eax
  800610:	c1 e8 0c             	shr    $0xc,%eax
  800613:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80061a:	f6 c2 01             	test   $0x1,%dl
  80061d:	74 24                	je     800643 <dup+0x96>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80061f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800626:	83 ec 0c             	sub    $0xc,%esp
  800629:	25 07 0e 00 00       	and    $0xe07,%eax
  80062e:	50                   	push   %eax
  80062f:	57                   	push   %edi
  800630:	6a 00                	push   $0x0
  800632:	56                   	push   %esi
  800633:	6a 00                	push   $0x0
  800635:	e8 93 fb ff ff       	call   8001cd <sys_page_map>
  80063a:	89 c6                	mov    %eax,%esi
  80063c:	83 c4 20             	add    $0x20,%esp
  80063f:	85 c0                	test   %eax,%eax
  800641:	78 2c                	js     80066f <dup+0xc2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800643:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800646:	89 d0                	mov    %edx,%eax
  800648:	c1 e8 0c             	shr    $0xc,%eax
  80064b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800652:	83 ec 0c             	sub    $0xc,%esp
  800655:	25 07 0e 00 00       	and    $0xe07,%eax
  80065a:	50                   	push   %eax
  80065b:	53                   	push   %ebx
  80065c:	6a 00                	push   $0x0
  80065e:	52                   	push   %edx
  80065f:	6a 00                	push   $0x0
  800661:	e8 67 fb ff ff       	call   8001cd <sys_page_map>
  800666:	89 c6                	mov    %eax,%esi
  800668:	83 c4 20             	add    $0x20,%esp
  80066b:	85 c0                	test   %eax,%eax
  80066d:	79 1d                	jns    80068c <dup+0xdf>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80066f:	83 ec 08             	sub    $0x8,%esp
  800672:	53                   	push   %ebx
  800673:	6a 00                	push   $0x0
  800675:	e8 95 fb ff ff       	call   80020f <sys_page_unmap>
	sys_page_unmap(0, nva);
  80067a:	83 c4 08             	add    $0x8,%esp
  80067d:	57                   	push   %edi
  80067e:	6a 00                	push   $0x0
  800680:	e8 8a fb ff ff       	call   80020f <sys_page_unmap>
	return r;
  800685:	83 c4 10             	add    $0x10,%esp
  800688:	89 f0                	mov    %esi,%eax
  80068a:	eb 03                	jmp    80068f <dup+0xe2>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80068c:	8b 45 0c             	mov    0xc(%ebp),%eax

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80068f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800692:	5b                   	pop    %ebx
  800693:	5e                   	pop    %esi
  800694:	5f                   	pop    %edi
  800695:	5d                   	pop    %ebp
  800696:	c3                   	ret    

00800697 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800697:	55                   	push   %ebp
  800698:	89 e5                	mov    %esp,%ebp
  80069a:	53                   	push   %ebx
  80069b:	83 ec 14             	sub    $0x14,%esp
  80069e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006a1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006a4:	50                   	push   %eax
  8006a5:	53                   	push   %ebx
  8006a6:	e8 6b fd ff ff       	call   800416 <fd_lookup>
  8006ab:	83 c4 08             	add    $0x8,%esp
  8006ae:	85 c0                	test   %eax,%eax
  8006b0:	78 67                	js     800719 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006b2:	83 ec 08             	sub    $0x8,%esp
  8006b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006b8:	50                   	push   %eax
  8006b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006bc:	ff 30                	pushl  (%eax)
  8006be:	e8 aa fd ff ff       	call   80046d <dev_lookup>
  8006c3:	83 c4 10             	add    $0x10,%esp
  8006c6:	85 c0                	test   %eax,%eax
  8006c8:	78 4f                	js     800719 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006ca:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006cd:	8b 42 08             	mov    0x8(%edx),%eax
  8006d0:	83 e0 03             	and    $0x3,%eax
  8006d3:	83 f8 01             	cmp    $0x1,%eax
  8006d6:	75 21                	jne    8006f9 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006d8:	a1 04 40 80 00       	mov    0x804004,%eax
  8006dd:	8b 40 48             	mov    0x48(%eax),%eax
  8006e0:	83 ec 04             	sub    $0x4,%esp
  8006e3:	53                   	push   %ebx
  8006e4:	50                   	push   %eax
  8006e5:	68 d9 1e 80 00       	push   $0x801ed9
  8006ea:	e8 fc 09 00 00       	call   8010eb <cprintf>
		return -E_INVAL;
  8006ef:	83 c4 10             	add    $0x10,%esp
  8006f2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006f7:	eb 20                	jmp    800719 <read+0x82>
	}
	if (!dev->dev_read)
  8006f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006fc:	8b 40 08             	mov    0x8(%eax),%eax
  8006ff:	85 c0                	test   %eax,%eax
  800701:	74 11                	je     800714 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800703:	83 ec 04             	sub    $0x4,%esp
  800706:	ff 75 10             	pushl  0x10(%ebp)
  800709:	ff 75 0c             	pushl  0xc(%ebp)
  80070c:	52                   	push   %edx
  80070d:	ff d0                	call   *%eax
  80070f:	83 c4 10             	add    $0x10,%esp
  800712:	eb 05                	jmp    800719 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800714:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  800719:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80071c:	c9                   	leave  
  80071d:	c3                   	ret    

0080071e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80071e:	55                   	push   %ebp
  80071f:	89 e5                	mov    %esp,%ebp
  800721:	57                   	push   %edi
  800722:	56                   	push   %esi
  800723:	53                   	push   %ebx
  800724:	83 ec 0c             	sub    $0xc,%esp
  800727:	8b 7d 08             	mov    0x8(%ebp),%edi
  80072a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80072d:	85 f6                	test   %esi,%esi
  80072f:	74 31                	je     800762 <readn+0x44>
  800731:	b8 00 00 00 00       	mov    $0x0,%eax
  800736:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  80073b:	83 ec 04             	sub    $0x4,%esp
  80073e:	89 f2                	mov    %esi,%edx
  800740:	29 c2                	sub    %eax,%edx
  800742:	52                   	push   %edx
  800743:	03 45 0c             	add    0xc(%ebp),%eax
  800746:	50                   	push   %eax
  800747:	57                   	push   %edi
  800748:	e8 4a ff ff ff       	call   800697 <read>
		if (m < 0)
  80074d:	83 c4 10             	add    $0x10,%esp
  800750:	85 c0                	test   %eax,%eax
  800752:	78 17                	js     80076b <readn+0x4d>
			return m;
		if (m == 0)
  800754:	85 c0                	test   %eax,%eax
  800756:	74 11                	je     800769 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800758:	01 c3                	add    %eax,%ebx
  80075a:	89 d8                	mov    %ebx,%eax
  80075c:	39 f3                	cmp    %esi,%ebx
  80075e:	72 db                	jb     80073b <readn+0x1d>
  800760:	eb 09                	jmp    80076b <readn+0x4d>
  800762:	b8 00 00 00 00       	mov    $0x0,%eax
  800767:	eb 02                	jmp    80076b <readn+0x4d>
  800769:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80076b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80076e:	5b                   	pop    %ebx
  80076f:	5e                   	pop    %esi
  800770:	5f                   	pop    %edi
  800771:	5d                   	pop    %ebp
  800772:	c3                   	ret    

00800773 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800773:	55                   	push   %ebp
  800774:	89 e5                	mov    %esp,%ebp
  800776:	53                   	push   %ebx
  800777:	83 ec 14             	sub    $0x14,%esp
  80077a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80077d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800780:	50                   	push   %eax
  800781:	53                   	push   %ebx
  800782:	e8 8f fc ff ff       	call   800416 <fd_lookup>
  800787:	83 c4 08             	add    $0x8,%esp
  80078a:	85 c0                	test   %eax,%eax
  80078c:	78 62                	js     8007f0 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80078e:	83 ec 08             	sub    $0x8,%esp
  800791:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800794:	50                   	push   %eax
  800795:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800798:	ff 30                	pushl  (%eax)
  80079a:	e8 ce fc ff ff       	call   80046d <dev_lookup>
  80079f:	83 c4 10             	add    $0x10,%esp
  8007a2:	85 c0                	test   %eax,%eax
  8007a4:	78 4a                	js     8007f0 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007a9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007ad:	75 21                	jne    8007d0 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8007af:	a1 04 40 80 00       	mov    0x804004,%eax
  8007b4:	8b 40 48             	mov    0x48(%eax),%eax
  8007b7:	83 ec 04             	sub    $0x4,%esp
  8007ba:	53                   	push   %ebx
  8007bb:	50                   	push   %eax
  8007bc:	68 f5 1e 80 00       	push   $0x801ef5
  8007c1:	e8 25 09 00 00       	call   8010eb <cprintf>
		return -E_INVAL;
  8007c6:	83 c4 10             	add    $0x10,%esp
  8007c9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007ce:	eb 20                	jmp    8007f0 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007d3:	8b 52 0c             	mov    0xc(%edx),%edx
  8007d6:	85 d2                	test   %edx,%edx
  8007d8:	74 11                	je     8007eb <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007da:	83 ec 04             	sub    $0x4,%esp
  8007dd:	ff 75 10             	pushl  0x10(%ebp)
  8007e0:	ff 75 0c             	pushl  0xc(%ebp)
  8007e3:	50                   	push   %eax
  8007e4:	ff d2                	call   *%edx
  8007e6:	83 c4 10             	add    $0x10,%esp
  8007e9:	eb 05                	jmp    8007f0 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007eb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8007f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f3:	c9                   	leave  
  8007f4:	c3                   	ret    

008007f5 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007f5:	55                   	push   %ebp
  8007f6:	89 e5                	mov    %esp,%ebp
  8007f8:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007fb:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007fe:	50                   	push   %eax
  8007ff:	ff 75 08             	pushl  0x8(%ebp)
  800802:	e8 0f fc ff ff       	call   800416 <fd_lookup>
  800807:	83 c4 08             	add    $0x8,%esp
  80080a:	85 c0                	test   %eax,%eax
  80080c:	78 0e                	js     80081c <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80080e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800811:	8b 55 0c             	mov    0xc(%ebp),%edx
  800814:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800817:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80081c:	c9                   	leave  
  80081d:	c3                   	ret    

0080081e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80081e:	55                   	push   %ebp
  80081f:	89 e5                	mov    %esp,%ebp
  800821:	53                   	push   %ebx
  800822:	83 ec 14             	sub    $0x14,%esp
  800825:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800828:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80082b:	50                   	push   %eax
  80082c:	53                   	push   %ebx
  80082d:	e8 e4 fb ff ff       	call   800416 <fd_lookup>
  800832:	83 c4 08             	add    $0x8,%esp
  800835:	85 c0                	test   %eax,%eax
  800837:	78 5f                	js     800898 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800839:	83 ec 08             	sub    $0x8,%esp
  80083c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80083f:	50                   	push   %eax
  800840:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800843:	ff 30                	pushl  (%eax)
  800845:	e8 23 fc ff ff       	call   80046d <dev_lookup>
  80084a:	83 c4 10             	add    $0x10,%esp
  80084d:	85 c0                	test   %eax,%eax
  80084f:	78 47                	js     800898 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800851:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800854:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800858:	75 21                	jne    80087b <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80085a:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80085f:	8b 40 48             	mov    0x48(%eax),%eax
  800862:	83 ec 04             	sub    $0x4,%esp
  800865:	53                   	push   %ebx
  800866:	50                   	push   %eax
  800867:	68 b8 1e 80 00       	push   $0x801eb8
  80086c:	e8 7a 08 00 00       	call   8010eb <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800871:	83 c4 10             	add    $0x10,%esp
  800874:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800879:	eb 1d                	jmp    800898 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  80087b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80087e:	8b 52 18             	mov    0x18(%edx),%edx
  800881:	85 d2                	test   %edx,%edx
  800883:	74 0e                	je     800893 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800885:	83 ec 08             	sub    $0x8,%esp
  800888:	ff 75 0c             	pushl  0xc(%ebp)
  80088b:	50                   	push   %eax
  80088c:	ff d2                	call   *%edx
  80088e:	83 c4 10             	add    $0x10,%esp
  800891:	eb 05                	jmp    800898 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800893:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  800898:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80089b:	c9                   	leave  
  80089c:	c3                   	ret    

0080089d <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80089d:	55                   	push   %ebp
  80089e:	89 e5                	mov    %esp,%ebp
  8008a0:	53                   	push   %ebx
  8008a1:	83 ec 14             	sub    $0x14,%esp
  8008a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008a7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008aa:	50                   	push   %eax
  8008ab:	ff 75 08             	pushl  0x8(%ebp)
  8008ae:	e8 63 fb ff ff       	call   800416 <fd_lookup>
  8008b3:	83 c4 08             	add    $0x8,%esp
  8008b6:	85 c0                	test   %eax,%eax
  8008b8:	78 52                	js     80090c <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008ba:	83 ec 08             	sub    $0x8,%esp
  8008bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008c0:	50                   	push   %eax
  8008c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008c4:	ff 30                	pushl  (%eax)
  8008c6:	e8 a2 fb ff ff       	call   80046d <dev_lookup>
  8008cb:	83 c4 10             	add    $0x10,%esp
  8008ce:	85 c0                	test   %eax,%eax
  8008d0:	78 3a                	js     80090c <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  8008d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008d5:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008d9:	74 2c                	je     800907 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008db:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008de:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008e5:	00 00 00 
	stat->st_isdir = 0;
  8008e8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008ef:	00 00 00 
	stat->st_dev = dev;
  8008f2:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008f8:	83 ec 08             	sub    $0x8,%esp
  8008fb:	53                   	push   %ebx
  8008fc:	ff 75 f0             	pushl  -0x10(%ebp)
  8008ff:	ff 50 14             	call   *0x14(%eax)
  800902:	83 c4 10             	add    $0x10,%esp
  800905:	eb 05                	jmp    80090c <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800907:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80090c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80090f:	c9                   	leave  
  800910:	c3                   	ret    

00800911 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800911:	55                   	push   %ebp
  800912:	89 e5                	mov    %esp,%ebp
  800914:	56                   	push   %esi
  800915:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800916:	83 ec 08             	sub    $0x8,%esp
  800919:	6a 00                	push   $0x0
  80091b:	ff 75 08             	pushl  0x8(%ebp)
  80091e:	e8 75 01 00 00       	call   800a98 <open>
  800923:	89 c3                	mov    %eax,%ebx
  800925:	83 c4 10             	add    $0x10,%esp
  800928:	85 c0                	test   %eax,%eax
  80092a:	78 1d                	js     800949 <stat+0x38>
		return fd;
	r = fstat(fd, stat);
  80092c:	83 ec 08             	sub    $0x8,%esp
  80092f:	ff 75 0c             	pushl  0xc(%ebp)
  800932:	50                   	push   %eax
  800933:	e8 65 ff ff ff       	call   80089d <fstat>
  800938:	89 c6                	mov    %eax,%esi
	close(fd);
  80093a:	89 1c 24             	mov    %ebx,(%esp)
  80093d:	e8 1d fc ff ff       	call   80055f <close>
	return r;
  800942:	83 c4 10             	add    $0x10,%esp
  800945:	89 f0                	mov    %esi,%eax
  800947:	eb 00                	jmp    800949 <stat+0x38>
}
  800949:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80094c:	5b                   	pop    %ebx
  80094d:	5e                   	pop    %esi
  80094e:	5d                   	pop    %ebp
  80094f:	c3                   	ret    

00800950 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800950:	55                   	push   %ebp
  800951:	89 e5                	mov    %esp,%ebp
  800953:	56                   	push   %esi
  800954:	53                   	push   %ebx
  800955:	89 c6                	mov    %eax,%esi
  800957:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800959:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800960:	75 12                	jne    800974 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800962:	83 ec 0c             	sub    $0xc,%esp
  800965:	6a 01                	push   $0x1
  800967:	e8 ec 11 00 00       	call   801b58 <ipc_find_env>
  80096c:	a3 00 40 80 00       	mov    %eax,0x804000
  800971:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800974:	6a 07                	push   $0x7
  800976:	68 00 50 80 00       	push   $0x805000
  80097b:	56                   	push   %esi
  80097c:	ff 35 00 40 80 00    	pushl  0x804000
  800982:	e8 72 11 00 00       	call   801af9 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800987:	83 c4 0c             	add    $0xc,%esp
  80098a:	6a 00                	push   $0x0
  80098c:	53                   	push   %ebx
  80098d:	6a 00                	push   $0x0
  80098f:	e8 f0 10 00 00       	call   801a84 <ipc_recv>
}
  800994:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800997:	5b                   	pop    %ebx
  800998:	5e                   	pop    %esi
  800999:	5d                   	pop    %ebp
  80099a:	c3                   	ret    

0080099b <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80099b:	55                   	push   %ebp
  80099c:	89 e5                	mov    %esp,%ebp
  80099e:	53                   	push   %ebx
  80099f:	83 ec 04             	sub    $0x4,%esp
  8009a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a8:	8b 40 0c             	mov    0xc(%eax),%eax
  8009ab:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b5:	b8 05 00 00 00       	mov    $0x5,%eax
  8009ba:	e8 91 ff ff ff       	call   800950 <fsipc>
  8009bf:	85 c0                	test   %eax,%eax
  8009c1:	78 2c                	js     8009ef <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009c3:	83 ec 08             	sub    $0x8,%esp
  8009c6:	68 00 50 80 00       	push   $0x805000
  8009cb:	53                   	push   %ebx
  8009cc:	e8 ff 0c 00 00       	call   8016d0 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009d1:	a1 80 50 80 00       	mov    0x805080,%eax
  8009d6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009dc:	a1 84 50 80 00       	mov    0x805084,%eax
  8009e1:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009e7:	83 c4 10             	add    $0x10,%esp
  8009ea:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009f2:	c9                   	leave  
  8009f3:	c3                   	ret    

008009f4 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009f4:	55                   	push   %ebp
  8009f5:	89 e5                	mov    %esp,%ebp
  8009f7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fd:	8b 40 0c             	mov    0xc(%eax),%eax
  800a00:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800a05:	ba 00 00 00 00       	mov    $0x0,%edx
  800a0a:	b8 06 00 00 00       	mov    $0x6,%eax
  800a0f:	e8 3c ff ff ff       	call   800950 <fsipc>
}
  800a14:	c9                   	leave  
  800a15:	c3                   	ret    

00800a16 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a16:	55                   	push   %ebp
  800a17:	89 e5                	mov    %esp,%ebp
  800a19:	56                   	push   %esi
  800a1a:	53                   	push   %ebx
  800a1b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a21:	8b 40 0c             	mov    0xc(%eax),%eax
  800a24:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a29:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a2f:	ba 00 00 00 00       	mov    $0x0,%edx
  800a34:	b8 03 00 00 00       	mov    $0x3,%eax
  800a39:	e8 12 ff ff ff       	call   800950 <fsipc>
  800a3e:	89 c3                	mov    %eax,%ebx
  800a40:	85 c0                	test   %eax,%eax
  800a42:	78 4b                	js     800a8f <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a44:	39 c6                	cmp    %eax,%esi
  800a46:	73 16                	jae    800a5e <devfile_read+0x48>
  800a48:	68 12 1f 80 00       	push   $0x801f12
  800a4d:	68 19 1f 80 00       	push   $0x801f19
  800a52:	6a 7a                	push   $0x7a
  800a54:	68 2e 1f 80 00       	push   $0x801f2e
  800a59:	e8 b5 05 00 00       	call   801013 <_panic>
	assert(r <= PGSIZE);
  800a5e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a63:	7e 16                	jle    800a7b <devfile_read+0x65>
  800a65:	68 39 1f 80 00       	push   $0x801f39
  800a6a:	68 19 1f 80 00       	push   $0x801f19
  800a6f:	6a 7b                	push   $0x7b
  800a71:	68 2e 1f 80 00       	push   $0x801f2e
  800a76:	e8 98 05 00 00       	call   801013 <_panic>
	memmove(buf, &fsipcbuf, r);
  800a7b:	83 ec 04             	sub    $0x4,%esp
  800a7e:	50                   	push   %eax
  800a7f:	68 00 50 80 00       	push   $0x805000
  800a84:	ff 75 0c             	pushl  0xc(%ebp)
  800a87:	e8 11 0e 00 00       	call   80189d <memmove>
	return r;
  800a8c:	83 c4 10             	add    $0x10,%esp
}
  800a8f:	89 d8                	mov    %ebx,%eax
  800a91:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a94:	5b                   	pop    %ebx
  800a95:	5e                   	pop    %esi
  800a96:	5d                   	pop    %ebp
  800a97:	c3                   	ret    

00800a98 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800a98:	55                   	push   %ebp
  800a99:	89 e5                	mov    %esp,%ebp
  800a9b:	53                   	push   %ebx
  800a9c:	83 ec 20             	sub    $0x20,%esp
  800a9f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800aa2:	53                   	push   %ebx
  800aa3:	e8 d1 0b 00 00       	call   801679 <strlen>
  800aa8:	83 c4 10             	add    $0x10,%esp
  800aab:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ab0:	7f 63                	jg     800b15 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ab2:	83 ec 0c             	sub    $0xc,%esp
  800ab5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ab8:	50                   	push   %eax
  800ab9:	e8 e4 f8 ff ff       	call   8003a2 <fd_alloc>
  800abe:	83 c4 10             	add    $0x10,%esp
  800ac1:	85 c0                	test   %eax,%eax
  800ac3:	78 55                	js     800b1a <open+0x82>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800ac5:	83 ec 08             	sub    $0x8,%esp
  800ac8:	53                   	push   %ebx
  800ac9:	68 00 50 80 00       	push   $0x805000
  800ace:	e8 fd 0b 00 00       	call   8016d0 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800ad3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad6:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800adb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ade:	b8 01 00 00 00       	mov    $0x1,%eax
  800ae3:	e8 68 fe ff ff       	call   800950 <fsipc>
  800ae8:	89 c3                	mov    %eax,%ebx
  800aea:	83 c4 10             	add    $0x10,%esp
  800aed:	85 c0                	test   %eax,%eax
  800aef:	79 14                	jns    800b05 <open+0x6d>
		fd_close(fd, 0);
  800af1:	83 ec 08             	sub    $0x8,%esp
  800af4:	6a 00                	push   $0x0
  800af6:	ff 75 f4             	pushl  -0xc(%ebp)
  800af9:	e8 dd f9 ff ff       	call   8004db <fd_close>
		return r;
  800afe:	83 c4 10             	add    $0x10,%esp
  800b01:	89 d8                	mov    %ebx,%eax
  800b03:	eb 15                	jmp    800b1a <open+0x82>
	}

	return fd2num(fd);
  800b05:	83 ec 0c             	sub    $0xc,%esp
  800b08:	ff 75 f4             	pushl  -0xc(%ebp)
  800b0b:	e8 6b f8 ff ff       	call   80037b <fd2num>
  800b10:	83 c4 10             	add    $0x10,%esp
  800b13:	eb 05                	jmp    800b1a <open+0x82>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b15:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b1a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b1d:	c9                   	leave  
  800b1e:	c3                   	ret    

00800b1f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b1f:	55                   	push   %ebp
  800b20:	89 e5                	mov    %esp,%ebp
  800b22:	56                   	push   %esi
  800b23:	53                   	push   %ebx
  800b24:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b27:	83 ec 0c             	sub    $0xc,%esp
  800b2a:	ff 75 08             	pushl  0x8(%ebp)
  800b2d:	e8 59 f8 ff ff       	call   80038b <fd2data>
  800b32:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b34:	83 c4 08             	add    $0x8,%esp
  800b37:	68 45 1f 80 00       	push   $0x801f45
  800b3c:	53                   	push   %ebx
  800b3d:	e8 8e 0b 00 00       	call   8016d0 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b42:	8b 46 04             	mov    0x4(%esi),%eax
  800b45:	2b 06                	sub    (%esi),%eax
  800b47:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b4d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b54:	00 00 00 
	stat->st_dev = &devpipe;
  800b57:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800b5e:	30 80 00 
	return 0;
}
  800b61:	b8 00 00 00 00       	mov    $0x0,%eax
  800b66:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b69:	5b                   	pop    %ebx
  800b6a:	5e                   	pop    %esi
  800b6b:	5d                   	pop    %ebp
  800b6c:	c3                   	ret    

00800b6d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b6d:	55                   	push   %ebp
  800b6e:	89 e5                	mov    %esp,%ebp
  800b70:	53                   	push   %ebx
  800b71:	83 ec 0c             	sub    $0xc,%esp
  800b74:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800b77:	53                   	push   %ebx
  800b78:	6a 00                	push   $0x0
  800b7a:	e8 90 f6 ff ff       	call   80020f <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800b7f:	89 1c 24             	mov    %ebx,(%esp)
  800b82:	e8 04 f8 ff ff       	call   80038b <fd2data>
  800b87:	83 c4 08             	add    $0x8,%esp
  800b8a:	50                   	push   %eax
  800b8b:	6a 00                	push   $0x0
  800b8d:	e8 7d f6 ff ff       	call   80020f <sys_page_unmap>
}
  800b92:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b95:	c9                   	leave  
  800b96:	c3                   	ret    

00800b97 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800b97:	55                   	push   %ebp
  800b98:	89 e5                	mov    %esp,%ebp
  800b9a:	57                   	push   %edi
  800b9b:	56                   	push   %esi
  800b9c:	53                   	push   %ebx
  800b9d:	83 ec 1c             	sub    $0x1c,%esp
  800ba0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800ba3:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800ba5:	a1 04 40 80 00       	mov    0x804004,%eax
  800baa:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800bad:	83 ec 0c             	sub    $0xc,%esp
  800bb0:	ff 75 e0             	pushl  -0x20(%ebp)
  800bb3:	e8 fb 0f 00 00       	call   801bb3 <pageref>
  800bb8:	89 c3                	mov    %eax,%ebx
  800bba:	89 3c 24             	mov    %edi,(%esp)
  800bbd:	e8 f1 0f 00 00       	call   801bb3 <pageref>
  800bc2:	83 c4 10             	add    $0x10,%esp
  800bc5:	39 c3                	cmp    %eax,%ebx
  800bc7:	0f 94 c1             	sete   %cl
  800bca:	0f b6 c9             	movzbl %cl,%ecx
  800bcd:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800bd0:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800bd6:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800bd9:	39 ce                	cmp    %ecx,%esi
  800bdb:	74 1b                	je     800bf8 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800bdd:	39 c3                	cmp    %eax,%ebx
  800bdf:	75 c4                	jne    800ba5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800be1:	8b 42 58             	mov    0x58(%edx),%eax
  800be4:	ff 75 e4             	pushl  -0x1c(%ebp)
  800be7:	50                   	push   %eax
  800be8:	56                   	push   %esi
  800be9:	68 4c 1f 80 00       	push   $0x801f4c
  800bee:	e8 f8 04 00 00       	call   8010eb <cprintf>
  800bf3:	83 c4 10             	add    $0x10,%esp
  800bf6:	eb ad                	jmp    800ba5 <_pipeisclosed+0xe>
	}
}
  800bf8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800bfb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bfe:	5b                   	pop    %ebx
  800bff:	5e                   	pop    %esi
  800c00:	5f                   	pop    %edi
  800c01:	5d                   	pop    %ebp
  800c02:	c3                   	ret    

00800c03 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c03:	55                   	push   %ebp
  800c04:	89 e5                	mov    %esp,%ebp
  800c06:	57                   	push   %edi
  800c07:	56                   	push   %esi
  800c08:	53                   	push   %ebx
  800c09:	83 ec 18             	sub    $0x18,%esp
  800c0c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c0f:	56                   	push   %esi
  800c10:	e8 76 f7 ff ff       	call   80038b <fd2data>
  800c15:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c17:	83 c4 10             	add    $0x10,%esp
  800c1a:	bf 00 00 00 00       	mov    $0x0,%edi
  800c1f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c23:	75 42                	jne    800c67 <devpipe_write+0x64>
  800c25:	eb 4e                	jmp    800c75 <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c27:	89 da                	mov    %ebx,%edx
  800c29:	89 f0                	mov    %esi,%eax
  800c2b:	e8 67 ff ff ff       	call   800b97 <_pipeisclosed>
  800c30:	85 c0                	test   %eax,%eax
  800c32:	75 46                	jne    800c7a <devpipe_write+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c34:	e8 32 f5 ff ff       	call   80016b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c39:	8b 53 04             	mov    0x4(%ebx),%edx
  800c3c:	8b 03                	mov    (%ebx),%eax
  800c3e:	83 c0 20             	add    $0x20,%eax
  800c41:	39 c2                	cmp    %eax,%edx
  800c43:	73 e2                	jae    800c27 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c45:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c48:	8a 0c 38             	mov    (%eax,%edi,1),%cl
  800c4b:	89 d0                	mov    %edx,%eax
  800c4d:	25 1f 00 00 80       	and    $0x8000001f,%eax
  800c52:	79 05                	jns    800c59 <devpipe_write+0x56>
  800c54:	48                   	dec    %eax
  800c55:	83 c8 e0             	or     $0xffffffe0,%eax
  800c58:	40                   	inc    %eax
  800c59:	88 4c 03 08          	mov    %cl,0x8(%ebx,%eax,1)
		p->p_wpos++;
  800c5d:	42                   	inc    %edx
  800c5e:	89 53 04             	mov    %edx,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c61:	47                   	inc    %edi
  800c62:	39 7d 10             	cmp    %edi,0x10(%ebp)
  800c65:	74 0e                	je     800c75 <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c67:	8b 53 04             	mov    0x4(%ebx),%edx
  800c6a:	8b 03                	mov    (%ebx),%eax
  800c6c:	83 c0 20             	add    $0x20,%eax
  800c6f:	39 c2                	cmp    %eax,%edx
  800c71:	73 b4                	jae    800c27 <devpipe_write+0x24>
  800c73:	eb d0                	jmp    800c45 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800c75:	8b 45 10             	mov    0x10(%ebp),%eax
  800c78:	eb 05                	jmp    800c7f <devpipe_write+0x7c>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800c7a:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800c7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c82:	5b                   	pop    %ebx
  800c83:	5e                   	pop    %esi
  800c84:	5f                   	pop    %edi
  800c85:	5d                   	pop    %ebp
  800c86:	c3                   	ret    

00800c87 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800c87:	55                   	push   %ebp
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	57                   	push   %edi
  800c8b:	56                   	push   %esi
  800c8c:	53                   	push   %ebx
  800c8d:	83 ec 18             	sub    $0x18,%esp
  800c90:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800c93:	57                   	push   %edi
  800c94:	e8 f2 f6 ff ff       	call   80038b <fd2data>
  800c99:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c9b:	83 c4 10             	add    $0x10,%esp
  800c9e:	be 00 00 00 00       	mov    $0x0,%esi
  800ca3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ca7:	75 3d                	jne    800ce6 <devpipe_read+0x5f>
  800ca9:	eb 48                	jmp    800cf3 <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  800cab:	89 f0                	mov    %esi,%eax
  800cad:	eb 4e                	jmp    800cfd <devpipe_read+0x76>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800caf:	89 da                	mov    %ebx,%edx
  800cb1:	89 f8                	mov    %edi,%eax
  800cb3:	e8 df fe ff ff       	call   800b97 <_pipeisclosed>
  800cb8:	85 c0                	test   %eax,%eax
  800cba:	75 3c                	jne    800cf8 <devpipe_read+0x71>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800cbc:	e8 aa f4 ff ff       	call   80016b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800cc1:	8b 03                	mov    (%ebx),%eax
  800cc3:	3b 43 04             	cmp    0x4(%ebx),%eax
  800cc6:	74 e7                	je     800caf <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800cc8:	25 1f 00 00 80       	and    $0x8000001f,%eax
  800ccd:	79 05                	jns    800cd4 <devpipe_read+0x4d>
  800ccf:	48                   	dec    %eax
  800cd0:	83 c8 e0             	or     $0xffffffe0,%eax
  800cd3:	40                   	inc    %eax
  800cd4:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  800cd8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdb:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800cde:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ce0:	46                   	inc    %esi
  800ce1:	39 75 10             	cmp    %esi,0x10(%ebp)
  800ce4:	74 0d                	je     800cf3 <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
  800ce6:	8b 03                	mov    (%ebx),%eax
  800ce8:	3b 43 04             	cmp    0x4(%ebx),%eax
  800ceb:	75 db                	jne    800cc8 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800ced:	85 f6                	test   %esi,%esi
  800cef:	75 ba                	jne    800cab <devpipe_read+0x24>
  800cf1:	eb bc                	jmp    800caf <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800cf3:	8b 45 10             	mov    0x10(%ebp),%eax
  800cf6:	eb 05                	jmp    800cfd <devpipe_read+0x76>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cf8:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800cfd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d00:	5b                   	pop    %ebx
  800d01:	5e                   	pop    %esi
  800d02:	5f                   	pop    %edi
  800d03:	5d                   	pop    %ebp
  800d04:	c3                   	ret    

00800d05 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d05:	55                   	push   %ebp
  800d06:	89 e5                	mov    %esp,%ebp
  800d08:	56                   	push   %esi
  800d09:	53                   	push   %ebx
  800d0a:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d0d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d10:	50                   	push   %eax
  800d11:	e8 8c f6 ff ff       	call   8003a2 <fd_alloc>
  800d16:	83 c4 10             	add    $0x10,%esp
  800d19:	85 c0                	test   %eax,%eax
  800d1b:	0f 88 2a 01 00 00    	js     800e4b <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d21:	83 ec 04             	sub    $0x4,%esp
  800d24:	68 07 04 00 00       	push   $0x407
  800d29:	ff 75 f4             	pushl  -0xc(%ebp)
  800d2c:	6a 00                	push   $0x0
  800d2e:	e8 57 f4 ff ff       	call   80018a <sys_page_alloc>
  800d33:	83 c4 10             	add    $0x10,%esp
  800d36:	85 c0                	test   %eax,%eax
  800d38:	0f 88 0d 01 00 00    	js     800e4b <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d3e:	83 ec 0c             	sub    $0xc,%esp
  800d41:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d44:	50                   	push   %eax
  800d45:	e8 58 f6 ff ff       	call   8003a2 <fd_alloc>
  800d4a:	89 c3                	mov    %eax,%ebx
  800d4c:	83 c4 10             	add    $0x10,%esp
  800d4f:	85 c0                	test   %eax,%eax
  800d51:	0f 88 e2 00 00 00    	js     800e39 <pipe+0x134>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d57:	83 ec 04             	sub    $0x4,%esp
  800d5a:	68 07 04 00 00       	push   $0x407
  800d5f:	ff 75 f0             	pushl  -0x10(%ebp)
  800d62:	6a 00                	push   $0x0
  800d64:	e8 21 f4 ff ff       	call   80018a <sys_page_alloc>
  800d69:	89 c3                	mov    %eax,%ebx
  800d6b:	83 c4 10             	add    $0x10,%esp
  800d6e:	85 c0                	test   %eax,%eax
  800d70:	0f 88 c3 00 00 00    	js     800e39 <pipe+0x134>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800d76:	83 ec 0c             	sub    $0xc,%esp
  800d79:	ff 75 f4             	pushl  -0xc(%ebp)
  800d7c:	e8 0a f6 ff ff       	call   80038b <fd2data>
  800d81:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d83:	83 c4 0c             	add    $0xc,%esp
  800d86:	68 07 04 00 00       	push   $0x407
  800d8b:	50                   	push   %eax
  800d8c:	6a 00                	push   $0x0
  800d8e:	e8 f7 f3 ff ff       	call   80018a <sys_page_alloc>
  800d93:	89 c3                	mov    %eax,%ebx
  800d95:	83 c4 10             	add    $0x10,%esp
  800d98:	85 c0                	test   %eax,%eax
  800d9a:	0f 88 89 00 00 00    	js     800e29 <pipe+0x124>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800da0:	83 ec 0c             	sub    $0xc,%esp
  800da3:	ff 75 f0             	pushl  -0x10(%ebp)
  800da6:	e8 e0 f5 ff ff       	call   80038b <fd2data>
  800dab:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800db2:	50                   	push   %eax
  800db3:	6a 00                	push   $0x0
  800db5:	56                   	push   %esi
  800db6:	6a 00                	push   $0x0
  800db8:	e8 10 f4 ff ff       	call   8001cd <sys_page_map>
  800dbd:	89 c3                	mov    %eax,%ebx
  800dbf:	83 c4 20             	add    $0x20,%esp
  800dc2:	85 c0                	test   %eax,%eax
  800dc4:	78 55                	js     800e1b <pipe+0x116>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800dc6:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800dcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dcf:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800dd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dd4:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800ddb:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800de1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800de4:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800de6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800de9:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800df0:	83 ec 0c             	sub    $0xc,%esp
  800df3:	ff 75 f4             	pushl  -0xc(%ebp)
  800df6:	e8 80 f5 ff ff       	call   80037b <fd2num>
  800dfb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dfe:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e00:	83 c4 04             	add    $0x4,%esp
  800e03:	ff 75 f0             	pushl  -0x10(%ebp)
  800e06:	e8 70 f5 ff ff       	call   80037b <fd2num>
  800e0b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e0e:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e11:	83 c4 10             	add    $0x10,%esp
  800e14:	b8 00 00 00 00       	mov    $0x0,%eax
  800e19:	eb 30                	jmp    800e4b <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  800e1b:	83 ec 08             	sub    $0x8,%esp
  800e1e:	56                   	push   %esi
  800e1f:	6a 00                	push   $0x0
  800e21:	e8 e9 f3 ff ff       	call   80020f <sys_page_unmap>
  800e26:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e29:	83 ec 08             	sub    $0x8,%esp
  800e2c:	ff 75 f0             	pushl  -0x10(%ebp)
  800e2f:	6a 00                	push   $0x0
  800e31:	e8 d9 f3 ff ff       	call   80020f <sys_page_unmap>
  800e36:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e39:	83 ec 08             	sub    $0x8,%esp
  800e3c:	ff 75 f4             	pushl  -0xc(%ebp)
  800e3f:	6a 00                	push   $0x0
  800e41:	e8 c9 f3 ff ff       	call   80020f <sys_page_unmap>
  800e46:	83 c4 10             	add    $0x10,%esp
  800e49:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  800e4b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e4e:	5b                   	pop    %ebx
  800e4f:	5e                   	pop    %esi
  800e50:	5d                   	pop    %ebp
  800e51:	c3                   	ret    

00800e52 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e52:	55                   	push   %ebp
  800e53:	89 e5                	mov    %esp,%ebp
  800e55:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e58:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e5b:	50                   	push   %eax
  800e5c:	ff 75 08             	pushl  0x8(%ebp)
  800e5f:	e8 b2 f5 ff ff       	call   800416 <fd_lookup>
  800e64:	83 c4 10             	add    $0x10,%esp
  800e67:	85 c0                	test   %eax,%eax
  800e69:	78 18                	js     800e83 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800e6b:	83 ec 0c             	sub    $0xc,%esp
  800e6e:	ff 75 f4             	pushl  -0xc(%ebp)
  800e71:	e8 15 f5 ff ff       	call   80038b <fd2data>
	return _pipeisclosed(fd, p);
  800e76:	89 c2                	mov    %eax,%edx
  800e78:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e7b:	e8 17 fd ff ff       	call   800b97 <_pipeisclosed>
  800e80:	83 c4 10             	add    $0x10,%esp
}
  800e83:	c9                   	leave  
  800e84:	c3                   	ret    

00800e85 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800e85:	55                   	push   %ebp
  800e86:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800e88:	b8 00 00 00 00       	mov    $0x0,%eax
  800e8d:	5d                   	pop    %ebp
  800e8e:	c3                   	ret    

00800e8f <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800e8f:	55                   	push   %ebp
  800e90:	89 e5                	mov    %esp,%ebp
  800e92:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800e95:	68 64 1f 80 00       	push   $0x801f64
  800e9a:	ff 75 0c             	pushl  0xc(%ebp)
  800e9d:	e8 2e 08 00 00       	call   8016d0 <strcpy>
	return 0;
}
  800ea2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea7:	c9                   	leave  
  800ea8:	c3                   	ret    

00800ea9 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800ea9:	55                   	push   %ebp
  800eaa:	89 e5                	mov    %esp,%ebp
  800eac:	57                   	push   %edi
  800ead:	56                   	push   %esi
  800eae:	53                   	push   %ebx
  800eaf:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800eb5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800eb9:	74 45                	je     800f00 <devcons_write+0x57>
  800ebb:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec0:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800ec5:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800ecb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ece:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  800ed0:	83 fb 7f             	cmp    $0x7f,%ebx
  800ed3:	76 05                	jbe    800eda <devcons_write+0x31>
			m = sizeof(buf) - 1;
  800ed5:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800eda:	83 ec 04             	sub    $0x4,%esp
  800edd:	53                   	push   %ebx
  800ede:	03 45 0c             	add    0xc(%ebp),%eax
  800ee1:	50                   	push   %eax
  800ee2:	57                   	push   %edi
  800ee3:	e8 b5 09 00 00       	call   80189d <memmove>
		sys_cputs(buf, m);
  800ee8:	83 c4 08             	add    $0x8,%esp
  800eeb:	53                   	push   %ebx
  800eec:	57                   	push   %edi
  800eed:	e8 dc f1 ff ff       	call   8000ce <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ef2:	01 de                	add    %ebx,%esi
  800ef4:	89 f0                	mov    %esi,%eax
  800ef6:	83 c4 10             	add    $0x10,%esp
  800ef9:	3b 75 10             	cmp    0x10(%ebp),%esi
  800efc:	72 cd                	jb     800ecb <devcons_write+0x22>
  800efe:	eb 05                	jmp    800f05 <devcons_write+0x5c>
  800f00:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f05:	89 f0                	mov    %esi,%eax
  800f07:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f0a:	5b                   	pop    %ebx
  800f0b:	5e                   	pop    %esi
  800f0c:	5f                   	pop    %edi
  800f0d:	5d                   	pop    %ebp
  800f0e:	c3                   	ret    

00800f0f <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f0f:	55                   	push   %ebp
  800f10:	89 e5                	mov    %esp,%ebp
  800f12:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  800f15:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f19:	75 07                	jne    800f22 <devcons_read+0x13>
  800f1b:	eb 23                	jmp    800f40 <devcons_read+0x31>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f1d:	e8 49 f2 ff ff       	call   80016b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f22:	e8 c5 f1 ff ff       	call   8000ec <sys_cgetc>
  800f27:	85 c0                	test   %eax,%eax
  800f29:	74 f2                	je     800f1d <devcons_read+0xe>
		sys_yield();
	if (c < 0)
  800f2b:	85 c0                	test   %eax,%eax
  800f2d:	78 1d                	js     800f4c <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f2f:	83 f8 04             	cmp    $0x4,%eax
  800f32:	74 13                	je     800f47 <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  800f34:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f37:	88 02                	mov    %al,(%edx)
	return 1;
  800f39:	b8 01 00 00 00       	mov    $0x1,%eax
  800f3e:	eb 0c                	jmp    800f4c <devcons_read+0x3d>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  800f40:	b8 00 00 00 00       	mov    $0x0,%eax
  800f45:	eb 05                	jmp    800f4c <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f47:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f4c:	c9                   	leave  
  800f4d:	c3                   	ret    

00800f4e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f4e:	55                   	push   %ebp
  800f4f:	89 e5                	mov    %esp,%ebp
  800f51:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f54:	8b 45 08             	mov    0x8(%ebp),%eax
  800f57:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f5a:	6a 01                	push   $0x1
  800f5c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f5f:	50                   	push   %eax
  800f60:	e8 69 f1 ff ff       	call   8000ce <sys_cputs>
}
  800f65:	83 c4 10             	add    $0x10,%esp
  800f68:	c9                   	leave  
  800f69:	c3                   	ret    

00800f6a <getchar>:

int
getchar(void)
{
  800f6a:	55                   	push   %ebp
  800f6b:	89 e5                	mov    %esp,%ebp
  800f6d:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f70:	6a 01                	push   $0x1
  800f72:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f75:	50                   	push   %eax
  800f76:	6a 00                	push   $0x0
  800f78:	e8 1a f7 ff ff       	call   800697 <read>
	if (r < 0)
  800f7d:	83 c4 10             	add    $0x10,%esp
  800f80:	85 c0                	test   %eax,%eax
  800f82:	78 0f                	js     800f93 <getchar+0x29>
		return r;
	if (r < 1)
  800f84:	85 c0                	test   %eax,%eax
  800f86:	7e 06                	jle    800f8e <getchar+0x24>
		return -E_EOF;
	return c;
  800f88:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800f8c:	eb 05                	jmp    800f93 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800f8e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800f93:	c9                   	leave  
  800f94:	c3                   	ret    

00800f95 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800f95:	55                   	push   %ebp
  800f96:	89 e5                	mov    %esp,%ebp
  800f98:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f9b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f9e:	50                   	push   %eax
  800f9f:	ff 75 08             	pushl  0x8(%ebp)
  800fa2:	e8 6f f4 ff ff       	call   800416 <fd_lookup>
  800fa7:	83 c4 10             	add    $0x10,%esp
  800faa:	85 c0                	test   %eax,%eax
  800fac:	78 11                	js     800fbf <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800fae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fb1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fb7:	39 10                	cmp    %edx,(%eax)
  800fb9:	0f 94 c0             	sete   %al
  800fbc:	0f b6 c0             	movzbl %al,%eax
}
  800fbf:	c9                   	leave  
  800fc0:	c3                   	ret    

00800fc1 <opencons>:

int
opencons(void)
{
  800fc1:	55                   	push   %ebp
  800fc2:	89 e5                	mov    %esp,%ebp
  800fc4:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fc7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fca:	50                   	push   %eax
  800fcb:	e8 d2 f3 ff ff       	call   8003a2 <fd_alloc>
  800fd0:	83 c4 10             	add    $0x10,%esp
  800fd3:	85 c0                	test   %eax,%eax
  800fd5:	78 3a                	js     801011 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fd7:	83 ec 04             	sub    $0x4,%esp
  800fda:	68 07 04 00 00       	push   $0x407
  800fdf:	ff 75 f4             	pushl  -0xc(%ebp)
  800fe2:	6a 00                	push   $0x0
  800fe4:	e8 a1 f1 ff ff       	call   80018a <sys_page_alloc>
  800fe9:	83 c4 10             	add    $0x10,%esp
  800fec:	85 c0                	test   %eax,%eax
  800fee:	78 21                	js     801011 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800ff0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800ff6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ff9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800ffb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ffe:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801005:	83 ec 0c             	sub    $0xc,%esp
  801008:	50                   	push   %eax
  801009:	e8 6d f3 ff ff       	call   80037b <fd2num>
  80100e:	83 c4 10             	add    $0x10,%esp
}
  801011:	c9                   	leave  
  801012:	c3                   	ret    

00801013 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801013:	55                   	push   %ebp
  801014:	89 e5                	mov    %esp,%ebp
  801016:	56                   	push   %esi
  801017:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801018:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80101b:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801021:	e8 26 f1 ff ff       	call   80014c <sys_getenvid>
  801026:	83 ec 0c             	sub    $0xc,%esp
  801029:	ff 75 0c             	pushl  0xc(%ebp)
  80102c:	ff 75 08             	pushl  0x8(%ebp)
  80102f:	56                   	push   %esi
  801030:	50                   	push   %eax
  801031:	68 70 1f 80 00       	push   $0x801f70
  801036:	e8 b0 00 00 00       	call   8010eb <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80103b:	83 c4 18             	add    $0x18,%esp
  80103e:	53                   	push   %ebx
  80103f:	ff 75 10             	pushl  0x10(%ebp)
  801042:	e8 53 00 00 00       	call   80109a <vcprintf>
	cprintf("\n");
  801047:	c7 04 24 5d 1f 80 00 	movl   $0x801f5d,(%esp)
  80104e:	e8 98 00 00 00       	call   8010eb <cprintf>
  801053:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801056:	cc                   	int3   
  801057:	eb fd                	jmp    801056 <_panic+0x43>

00801059 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801059:	55                   	push   %ebp
  80105a:	89 e5                	mov    %esp,%ebp
  80105c:	53                   	push   %ebx
  80105d:	83 ec 04             	sub    $0x4,%esp
  801060:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801063:	8b 13                	mov    (%ebx),%edx
  801065:	8d 42 01             	lea    0x1(%edx),%eax
  801068:	89 03                	mov    %eax,(%ebx)
  80106a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80106d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801071:	3d ff 00 00 00       	cmp    $0xff,%eax
  801076:	75 1a                	jne    801092 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801078:	83 ec 08             	sub    $0x8,%esp
  80107b:	68 ff 00 00 00       	push   $0xff
  801080:	8d 43 08             	lea    0x8(%ebx),%eax
  801083:	50                   	push   %eax
  801084:	e8 45 f0 ff ff       	call   8000ce <sys_cputs>
		b->idx = 0;
  801089:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80108f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801092:	ff 43 04             	incl   0x4(%ebx)
}
  801095:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801098:	c9                   	leave  
  801099:	c3                   	ret    

0080109a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80109a:	55                   	push   %ebp
  80109b:	89 e5                	mov    %esp,%ebp
  80109d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010a3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010aa:	00 00 00 
	b.cnt = 0;
  8010ad:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010b4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010b7:	ff 75 0c             	pushl  0xc(%ebp)
  8010ba:	ff 75 08             	pushl  0x8(%ebp)
  8010bd:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010c3:	50                   	push   %eax
  8010c4:	68 59 10 80 00       	push   $0x801059
  8010c9:	e8 54 01 00 00       	call   801222 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010ce:	83 c4 08             	add    $0x8,%esp
  8010d1:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010d7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010dd:	50                   	push   %eax
  8010de:	e8 eb ef ff ff       	call   8000ce <sys_cputs>

	return b.cnt;
}
  8010e3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8010e9:	c9                   	leave  
  8010ea:	c3                   	ret    

008010eb <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8010eb:	55                   	push   %ebp
  8010ec:	89 e5                	mov    %esp,%ebp
  8010ee:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8010f1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8010f4:	50                   	push   %eax
  8010f5:	ff 75 08             	pushl  0x8(%ebp)
  8010f8:	e8 9d ff ff ff       	call   80109a <vcprintf>
	va_end(ap);

	return cnt;
}
  8010fd:	c9                   	leave  
  8010fe:	c3                   	ret    

008010ff <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8010ff:	55                   	push   %ebp
  801100:	89 e5                	mov    %esp,%ebp
  801102:	57                   	push   %edi
  801103:	56                   	push   %esi
  801104:	53                   	push   %ebx
  801105:	83 ec 1c             	sub    $0x1c,%esp
  801108:	89 c6                	mov    %eax,%esi
  80110a:	89 d7                	mov    %edx,%edi
  80110c:	8b 45 08             	mov    0x8(%ebp),%eax
  80110f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801112:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801115:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801118:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80111b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801120:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801123:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801126:	39 d3                	cmp    %edx,%ebx
  801128:	72 11                	jb     80113b <printnum+0x3c>
  80112a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80112d:	76 0c                	jbe    80113b <printnum+0x3c>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80112f:	8b 45 14             	mov    0x14(%ebp),%eax
  801132:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801135:	85 db                	test   %ebx,%ebx
  801137:	7f 37                	jg     801170 <printnum+0x71>
  801139:	eb 44                	jmp    80117f <printnum+0x80>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80113b:	83 ec 0c             	sub    $0xc,%esp
  80113e:	ff 75 18             	pushl  0x18(%ebp)
  801141:	8b 45 14             	mov    0x14(%ebp),%eax
  801144:	48                   	dec    %eax
  801145:	50                   	push   %eax
  801146:	ff 75 10             	pushl  0x10(%ebp)
  801149:	83 ec 08             	sub    $0x8,%esp
  80114c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80114f:	ff 75 e0             	pushl  -0x20(%ebp)
  801152:	ff 75 dc             	pushl  -0x24(%ebp)
  801155:	ff 75 d8             	pushl  -0x28(%ebp)
  801158:	e8 9b 0a 00 00       	call   801bf8 <__udivdi3>
  80115d:	83 c4 18             	add    $0x18,%esp
  801160:	52                   	push   %edx
  801161:	50                   	push   %eax
  801162:	89 fa                	mov    %edi,%edx
  801164:	89 f0                	mov    %esi,%eax
  801166:	e8 94 ff ff ff       	call   8010ff <printnum>
  80116b:	83 c4 20             	add    $0x20,%esp
  80116e:	eb 0f                	jmp    80117f <printnum+0x80>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801170:	83 ec 08             	sub    $0x8,%esp
  801173:	57                   	push   %edi
  801174:	ff 75 18             	pushl  0x18(%ebp)
  801177:	ff d6                	call   *%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801179:	83 c4 10             	add    $0x10,%esp
  80117c:	4b                   	dec    %ebx
  80117d:	75 f1                	jne    801170 <printnum+0x71>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80117f:	83 ec 08             	sub    $0x8,%esp
  801182:	57                   	push   %edi
  801183:	83 ec 04             	sub    $0x4,%esp
  801186:	ff 75 e4             	pushl  -0x1c(%ebp)
  801189:	ff 75 e0             	pushl  -0x20(%ebp)
  80118c:	ff 75 dc             	pushl  -0x24(%ebp)
  80118f:	ff 75 d8             	pushl  -0x28(%ebp)
  801192:	e8 71 0b 00 00       	call   801d08 <__umoddi3>
  801197:	83 c4 14             	add    $0x14,%esp
  80119a:	0f be 80 93 1f 80 00 	movsbl 0x801f93(%eax),%eax
  8011a1:	50                   	push   %eax
  8011a2:	ff d6                	call   *%esi
}
  8011a4:	83 c4 10             	add    $0x10,%esp
  8011a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011aa:	5b                   	pop    %ebx
  8011ab:	5e                   	pop    %esi
  8011ac:	5f                   	pop    %edi
  8011ad:	5d                   	pop    %ebp
  8011ae:	c3                   	ret    

008011af <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8011af:	55                   	push   %ebp
  8011b0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011b2:	83 fa 01             	cmp    $0x1,%edx
  8011b5:	7e 0e                	jle    8011c5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8011b7:	8b 10                	mov    (%eax),%edx
  8011b9:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011bc:	89 08                	mov    %ecx,(%eax)
  8011be:	8b 02                	mov    (%edx),%eax
  8011c0:	8b 52 04             	mov    0x4(%edx),%edx
  8011c3:	eb 22                	jmp    8011e7 <getuint+0x38>
	else if (lflag)
  8011c5:	85 d2                	test   %edx,%edx
  8011c7:	74 10                	je     8011d9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8011c9:	8b 10                	mov    (%eax),%edx
  8011cb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011ce:	89 08                	mov    %ecx,(%eax)
  8011d0:	8b 02                	mov    (%edx),%eax
  8011d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8011d7:	eb 0e                	jmp    8011e7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8011d9:	8b 10                	mov    (%eax),%edx
  8011db:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011de:	89 08                	mov    %ecx,(%eax)
  8011e0:	8b 02                	mov    (%edx),%eax
  8011e2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8011e7:	5d                   	pop    %ebp
  8011e8:	c3                   	ret    

008011e9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011e9:	55                   	push   %ebp
  8011ea:	89 e5                	mov    %esp,%ebp
  8011ec:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011ef:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8011f2:	8b 10                	mov    (%eax),%edx
  8011f4:	3b 50 04             	cmp    0x4(%eax),%edx
  8011f7:	73 0a                	jae    801203 <sprintputch+0x1a>
		*b->buf++ = ch;
  8011f9:	8d 4a 01             	lea    0x1(%edx),%ecx
  8011fc:	89 08                	mov    %ecx,(%eax)
  8011fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801201:	88 02                	mov    %al,(%edx)
}
  801203:	5d                   	pop    %ebp
  801204:	c3                   	ret    

00801205 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801205:	55                   	push   %ebp
  801206:	89 e5                	mov    %esp,%ebp
  801208:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80120b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80120e:	50                   	push   %eax
  80120f:	ff 75 10             	pushl  0x10(%ebp)
  801212:	ff 75 0c             	pushl  0xc(%ebp)
  801215:	ff 75 08             	pushl  0x8(%ebp)
  801218:	e8 05 00 00 00       	call   801222 <vprintfmt>
	va_end(ap);
}
  80121d:	83 c4 10             	add    $0x10,%esp
  801220:	c9                   	leave  
  801221:	c3                   	ret    

00801222 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801222:	55                   	push   %ebp
  801223:	89 e5                	mov    %esp,%ebp
  801225:	57                   	push   %edi
  801226:	56                   	push   %esi
  801227:	53                   	push   %ebx
  801228:	83 ec 2c             	sub    $0x2c,%esp
  80122b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80122e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801231:	eb 03                	jmp    801236 <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  801233:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  801236:	8b 45 10             	mov    0x10(%ebp),%eax
  801239:	8d 70 01             	lea    0x1(%eax),%esi
  80123c:	0f b6 00             	movzbl (%eax),%eax
  80123f:	83 f8 25             	cmp    $0x25,%eax
  801242:	74 25                	je     801269 <vprintfmt+0x47>
			if (ch == '\0')									//当然中间如果遇到'\0'，代表这个字符串的访问结束
  801244:	85 c0                	test   %eax,%eax
  801246:	75 0d                	jne    801255 <vprintfmt+0x33>
  801248:	e9 b5 03 00 00       	jmp    801602 <vprintfmt+0x3e0>
  80124d:	85 c0                	test   %eax,%eax
  80124f:	0f 84 ad 03 00 00    	je     801602 <vprintfmt+0x3e0>
				return;
			putch(ch, putdat);								//调用putch函数，把一个字符ch输出到putdat指针所指向的地址中所存放的值对应的地址处
  801255:	83 ec 08             	sub    $0x8,%esp
  801258:	53                   	push   %ebx
  801259:	50                   	push   %eax
  80125a:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  80125c:	46                   	inc    %esi
  80125d:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  801261:	83 c4 10             	add    $0x10,%esp
  801264:	83 f8 25             	cmp    $0x25,%eax
  801267:	75 e4                	jne    80124d <vprintfmt+0x2b>
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  801269:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  80126d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801274:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80127b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  801282:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  801289:	eb 07                	jmp    801292 <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80128b:	8b 75 10             	mov    0x10(%ebp),%esi

		// flag to pad on the right
		case '-':											//%后面的'-'代表要进行左对齐输出，右边填空格，如果省略代表右对齐
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
  80128e:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  801292:	8d 46 01             	lea    0x1(%esi),%eax
  801295:	89 45 10             	mov    %eax,0x10(%ebp)
  801298:	0f b6 16             	movzbl (%esi),%edx
  80129b:	8a 06                	mov    (%esi),%al
  80129d:	83 e8 23             	sub    $0x23,%eax
  8012a0:	3c 55                	cmp    $0x55,%al
  8012a2:	0f 87 03 03 00 00    	ja     8015ab <vprintfmt+0x389>
  8012a8:	0f b6 c0             	movzbl %al,%eax
  8012ab:	ff 24 85 e0 20 80 00 	jmp    *0x8020e0(,%eax,4)
  8012b2:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
			goto reswitch;									//处理下一个字符

		// flag to pad with 0's instead of spaces
		case '0':											//0--有0表示进行对齐输出时填0,如省略表示填入空格，并且如果为0，则一定是右对齐
			padc = '0';										//对其方式标志位变为0
  8012b5:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  8012b9:	eb d7                	jmp    801292 <vprintfmt+0x70>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
				precision = precision * 10 + ch - '0';
  8012bb:	8d 42 d0             	lea    -0x30(%edx),%eax
  8012be:	89 c1                	mov    %eax,%ecx
  8012c0:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  8012c3:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8012c7:	8d 50 d0             	lea    -0x30(%eax),%edx
  8012ca:	83 fa 09             	cmp    $0x9,%edx
  8012cd:	77 51                	ja     801320 <vprintfmt+0xfe>
  8012cf:	8b 75 10             	mov    0x10(%ebp),%esi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
  8012d2:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8012d3:	8d 14 89             	lea    (%ecx,%ecx,4),%edx
  8012d6:	01 d2                	add    %edx,%edx
  8012d8:	8d 4c 10 d0          	lea    -0x30(%eax,%edx,1),%ecx
				ch = *fmt;
  8012dc:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8012df:	8d 50 d0             	lea    -0x30(%eax),%edx
  8012e2:	83 fa 09             	cmp    $0x9,%edx
  8012e5:	76 eb                	jbe    8012d2 <vprintfmt+0xb0>
  8012e7:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8012ea:	eb 37                	jmp    801323 <vprintfmt+0x101>
					break;
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
  8012ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8012ef:	8d 50 04             	lea    0x4(%eax),%edx
  8012f2:	89 55 14             	mov    %edx,0x14(%ebp)
  8012f5:	8b 00                	mov    (%eax),%eax
  8012f7:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8012fa:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
			goto process_precision;
  8012fd:	eb 24                	jmp    801323 <vprintfmt+0x101>
  8012ff:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801303:	79 07                	jns    80130c <vprintfmt+0xea>
  801305:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80130c:	8b 75 10             	mov    0x10(%ebp),%esi
  80130f:	eb 81                	jmp    801292 <vprintfmt+0x70>
  801311:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  801314:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80131b:	e9 72 ff ff ff       	jmp    801292 <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  801320:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:									//处理输出精度，把width字段赋值为刚刚计算出来的precision值，所以width应该是整数部分的有效数字位数
			if (width < 0)
  801323:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801327:	0f 89 65 ff ff ff    	jns    801292 <vprintfmt+0x70>
				width = precision, precision = -1;
  80132d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801330:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801333:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80133a:	e9 53 ff ff ff       	jmp    801292 <vprintfmt+0x70>
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
  80133f:	ff 45 d4             	incl   -0x2c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  801342:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
			goto reswitch;
  801345:	e9 48 ff ff ff       	jmp    801292 <vprintfmt+0x70>

		// character
		case 'c':											//如果是'c'代表显示一个字符
			putch(va_arg(ap, int), putdat);					//调用输出一个字符到内存的函数putch
  80134a:	8b 45 14             	mov    0x14(%ebp),%eax
  80134d:	8d 50 04             	lea    0x4(%eax),%edx
  801350:	89 55 14             	mov    %edx,0x14(%ebp)
  801353:	83 ec 08             	sub    $0x8,%esp
  801356:	53                   	push   %ebx
  801357:	ff 30                	pushl  (%eax)
  801359:	ff d7                	call   *%edi
			break;
  80135b:	83 c4 10             	add    $0x10,%esp
  80135e:	e9 d3 fe ff ff       	jmp    801236 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801363:	8b 45 14             	mov    0x14(%ebp),%eax
  801366:	8d 50 04             	lea    0x4(%eax),%edx
  801369:	89 55 14             	mov    %edx,0x14(%ebp)
  80136c:	8b 00                	mov    (%eax),%eax
  80136e:	85 c0                	test   %eax,%eax
  801370:	79 02                	jns    801374 <vprintfmt+0x152>
  801372:	f7 d8                	neg    %eax
  801374:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801376:	83 f8 0f             	cmp    $0xf,%eax
  801379:	7f 0b                	jg     801386 <vprintfmt+0x164>
  80137b:	8b 04 85 40 22 80 00 	mov    0x802240(,%eax,4),%eax
  801382:	85 c0                	test   %eax,%eax
  801384:	75 15                	jne    80139b <vprintfmt+0x179>
				printfmt(putch, putdat, "error %d", err);
  801386:	52                   	push   %edx
  801387:	68 ab 1f 80 00       	push   $0x801fab
  80138c:	53                   	push   %ebx
  80138d:	57                   	push   %edi
  80138e:	e8 72 fe ff ff       	call   801205 <printfmt>
  801393:	83 c4 10             	add    $0x10,%esp
  801396:	e9 9b fe ff ff       	jmp    801236 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  80139b:	50                   	push   %eax
  80139c:	68 2b 1f 80 00       	push   $0x801f2b
  8013a1:	53                   	push   %ebx
  8013a2:	57                   	push   %edi
  8013a3:	e8 5d fe ff ff       	call   801205 <printfmt>
  8013a8:	83 c4 10             	add    $0x10,%esp
  8013ab:	e9 86 fe ff ff       	jmp    801236 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8013b3:	8d 50 04             	lea    0x4(%eax),%edx
  8013b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8013b9:	8b 00                	mov    (%eax),%eax
  8013bb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8013be:	85 c0                	test   %eax,%eax
  8013c0:	75 07                	jne    8013c9 <vprintfmt+0x1a7>
				p = "(null)";
  8013c2:	c7 45 d4 a4 1f 80 00 	movl   $0x801fa4,-0x2c(%ebp)
			if (width > 0 && padc != '-')
  8013c9:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8013cc:	85 f6                	test   %esi,%esi
  8013ce:	0f 8e fb 01 00 00    	jle    8015cf <vprintfmt+0x3ad>
  8013d4:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  8013d8:	0f 84 09 02 00 00    	je     8015e7 <vprintfmt+0x3c5>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013de:	83 ec 08             	sub    $0x8,%esp
  8013e1:	ff 75 d0             	pushl  -0x30(%ebp)
  8013e4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013e7:	e8 ad 02 00 00       	call   801699 <strnlen>
  8013ec:	89 f1                	mov    %esi,%ecx
  8013ee:	29 c1                	sub    %eax,%ecx
  8013f0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8013f3:	83 c4 10             	add    $0x10,%esp
  8013f6:	85 c9                	test   %ecx,%ecx
  8013f8:	0f 8e d1 01 00 00    	jle    8015cf <vprintfmt+0x3ad>
					putch(padc, putdat);
  8013fe:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  801402:	83 ec 08             	sub    $0x8,%esp
  801405:	53                   	push   %ebx
  801406:	56                   	push   %esi
  801407:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801409:	83 c4 10             	add    $0x10,%esp
  80140c:	ff 4d e4             	decl   -0x1c(%ebp)
  80140f:	75 f1                	jne    801402 <vprintfmt+0x1e0>
  801411:	e9 b9 01 00 00       	jmp    8015cf <vprintfmt+0x3ad>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801416:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80141a:	74 19                	je     801435 <vprintfmt+0x213>
  80141c:	0f be c0             	movsbl %al,%eax
  80141f:	83 e8 20             	sub    $0x20,%eax
  801422:	83 f8 5e             	cmp    $0x5e,%eax
  801425:	76 0e                	jbe    801435 <vprintfmt+0x213>
					putch('?', putdat);
  801427:	83 ec 08             	sub    $0x8,%esp
  80142a:	53                   	push   %ebx
  80142b:	6a 3f                	push   $0x3f
  80142d:	ff 55 08             	call   *0x8(%ebp)
  801430:	83 c4 10             	add    $0x10,%esp
  801433:	eb 0b                	jmp    801440 <vprintfmt+0x21e>
				else
					putch(ch, putdat);
  801435:	83 ec 08             	sub    $0x8,%esp
  801438:	53                   	push   %ebx
  801439:	52                   	push   %edx
  80143a:	ff 55 08             	call   *0x8(%ebp)
  80143d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801440:	ff 4d e4             	decl   -0x1c(%ebp)
  801443:	46                   	inc    %esi
  801444:	8a 46 ff             	mov    -0x1(%esi),%al
  801447:	0f be d0             	movsbl %al,%edx
  80144a:	85 d2                	test   %edx,%edx
  80144c:	75 1c                	jne    80146a <vprintfmt+0x248>
  80144e:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801451:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801455:	7f 1f                	jg     801476 <vprintfmt+0x254>
  801457:	e9 da fd ff ff       	jmp    801236 <vprintfmt+0x14>
  80145c:	89 7d 08             	mov    %edi,0x8(%ebp)
  80145f:	8b 7d d0             	mov    -0x30(%ebp),%edi
  801462:	eb 06                	jmp    80146a <vprintfmt+0x248>
  801464:	89 7d 08             	mov    %edi,0x8(%ebp)
  801467:	8b 7d d0             	mov    -0x30(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80146a:	85 ff                	test   %edi,%edi
  80146c:	78 a8                	js     801416 <vprintfmt+0x1f4>
  80146e:	4f                   	dec    %edi
  80146f:	79 a5                	jns    801416 <vprintfmt+0x1f4>
  801471:	8b 7d 08             	mov    0x8(%ebp),%edi
  801474:	eb db                	jmp    801451 <vprintfmt+0x22f>
  801476:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801479:	83 ec 08             	sub    $0x8,%esp
  80147c:	53                   	push   %ebx
  80147d:	6a 20                	push   $0x20
  80147f:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801481:	4e                   	dec    %esi
  801482:	83 c4 10             	add    $0x10,%esp
  801485:	85 f6                	test   %esi,%esi
  801487:	7f f0                	jg     801479 <vprintfmt+0x257>
  801489:	e9 a8 fd ff ff       	jmp    801236 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80148e:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  801492:	7e 16                	jle    8014aa <vprintfmt+0x288>
		return va_arg(*ap, long long);
  801494:	8b 45 14             	mov    0x14(%ebp),%eax
  801497:	8d 50 08             	lea    0x8(%eax),%edx
  80149a:	89 55 14             	mov    %edx,0x14(%ebp)
  80149d:	8b 50 04             	mov    0x4(%eax),%edx
  8014a0:	8b 00                	mov    (%eax),%eax
  8014a2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014a5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8014a8:	eb 34                	jmp    8014de <vprintfmt+0x2bc>
	else if (lflag)
  8014aa:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8014ae:	74 18                	je     8014c8 <vprintfmt+0x2a6>
		return va_arg(*ap, long);
  8014b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8014b3:	8d 50 04             	lea    0x4(%eax),%edx
  8014b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8014b9:	8b 30                	mov    (%eax),%esi
  8014bb:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8014be:	89 f0                	mov    %esi,%eax
  8014c0:	c1 f8 1f             	sar    $0x1f,%eax
  8014c3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8014c6:	eb 16                	jmp    8014de <vprintfmt+0x2bc>
	else
		return va_arg(*ap, int);
  8014c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8014cb:	8d 50 04             	lea    0x4(%eax),%edx
  8014ce:	89 55 14             	mov    %edx,0x14(%ebp)
  8014d1:	8b 30                	mov    (%eax),%esi
  8014d3:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8014d6:	89 f0                	mov    %esi,%eax
  8014d8:	c1 f8 1f             	sar    $0x1f,%eax
  8014db:	89 45 dc             	mov    %eax,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8014de:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8014e1:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
  8014e4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8014e8:	0f 89 8a 00 00 00    	jns    801578 <vprintfmt+0x356>
				putch('-', putdat);
  8014ee:	83 ec 08             	sub    $0x8,%esp
  8014f1:	53                   	push   %ebx
  8014f2:	6a 2d                	push   $0x2d
  8014f4:	ff d7                	call   *%edi
				num = -(long long) num;
  8014f6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8014f9:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8014fc:	f7 d8                	neg    %eax
  8014fe:	83 d2 00             	adc    $0x0,%edx
  801501:	f7 da                	neg    %edx
  801503:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801506:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80150b:	eb 70                	jmp    80157d <vprintfmt+0x35b>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80150d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  801510:	8d 45 14             	lea    0x14(%ebp),%eax
  801513:	e8 97 fc ff ff       	call   8011af <getuint>
			base = 10;
  801518:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80151d:	eb 5e                	jmp    80157d <vprintfmt+0x35b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  80151f:	83 ec 08             	sub    $0x8,%esp
  801522:	53                   	push   %ebx
  801523:	6a 30                	push   $0x30
  801525:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  801527:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80152a:	8d 45 14             	lea    0x14(%ebp),%eax
  80152d:	e8 7d fc ff ff       	call   8011af <getuint>
			base = 8;
			goto number;
  801532:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  801535:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80153a:	eb 41                	jmp    80157d <vprintfmt+0x35b>
		// pointer
		case 'p':
			putch('0', putdat);
  80153c:	83 ec 08             	sub    $0x8,%esp
  80153f:	53                   	push   %ebx
  801540:	6a 30                	push   $0x30
  801542:	ff d7                	call   *%edi
			putch('x', putdat);
  801544:	83 c4 08             	add    $0x8,%esp
  801547:	53                   	push   %ebx
  801548:	6a 78                	push   $0x78
  80154a:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80154c:	8b 45 14             	mov    0x14(%ebp),%eax
  80154f:	8d 50 04             	lea    0x4(%eax),%edx
  801552:	89 55 14             	mov    %edx,0x14(%ebp)
			goto number;
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801555:	8b 00                	mov    (%eax),%eax
  801557:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80155c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80155f:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801564:	eb 17                	jmp    80157d <vprintfmt+0x35b>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801566:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  801569:	8d 45 14             	lea    0x14(%ebp),%eax
  80156c:	e8 3e fc ff ff       	call   8011af <getuint>
			base = 16;
  801571:	b9 10 00 00 00       	mov    $0x10,%ecx
  801576:	eb 05                	jmp    80157d <vprintfmt+0x35b>
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801578:	b9 0a 00 00 00       	mov    $0xa,%ecx
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  80157d:	83 ec 0c             	sub    $0xc,%esp
  801580:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  801584:	56                   	push   %esi
  801585:	ff 75 e4             	pushl  -0x1c(%ebp)
  801588:	51                   	push   %ecx
  801589:	52                   	push   %edx
  80158a:	50                   	push   %eax
  80158b:	89 da                	mov    %ebx,%edx
  80158d:	89 f8                	mov    %edi,%eax
  80158f:	e8 6b fb ff ff       	call   8010ff <printnum>
			break;
  801594:	83 c4 20             	add    $0x20,%esp
  801597:	e9 9a fc ff ff       	jmp    801236 <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80159c:	83 ec 08             	sub    $0x8,%esp
  80159f:	53                   	push   %ebx
  8015a0:	52                   	push   %edx
  8015a1:	ff d7                	call   *%edi
			break;
  8015a3:	83 c4 10             	add    $0x10,%esp
  8015a6:	e9 8b fc ff ff       	jmp    801236 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8015ab:	83 ec 08             	sub    $0x8,%esp
  8015ae:	53                   	push   %ebx
  8015af:	6a 25                	push   $0x25
  8015b1:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8015b3:	83 c4 10             	add    $0x10,%esp
  8015b6:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8015ba:	0f 84 73 fc ff ff    	je     801233 <vprintfmt+0x11>
  8015c0:	4e                   	dec    %esi
  8015c1:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8015c5:	75 f9                	jne    8015c0 <vprintfmt+0x39e>
  8015c7:	89 75 10             	mov    %esi,0x10(%ebp)
  8015ca:	e9 67 fc ff ff       	jmp    801236 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8015cf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8015d2:	8d 70 01             	lea    0x1(%eax),%esi
  8015d5:	8a 00                	mov    (%eax),%al
  8015d7:	0f be d0             	movsbl %al,%edx
  8015da:	85 d2                	test   %edx,%edx
  8015dc:	0f 85 7a fe ff ff    	jne    80145c <vprintfmt+0x23a>
  8015e2:	e9 4f fc ff ff       	jmp    801236 <vprintfmt+0x14>
  8015e7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8015ea:	8d 70 01             	lea    0x1(%eax),%esi
  8015ed:	8a 00                	mov    (%eax),%al
  8015ef:	0f be d0             	movsbl %al,%edx
  8015f2:	85 d2                	test   %edx,%edx
  8015f4:	0f 85 6a fe ff ff    	jne    801464 <vprintfmt+0x242>
  8015fa:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8015fd:	e9 77 fe ff ff       	jmp    801479 <vprintfmt+0x257>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  801602:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801605:	5b                   	pop    %ebx
  801606:	5e                   	pop    %esi
  801607:	5f                   	pop    %edi
  801608:	5d                   	pop    %ebp
  801609:	c3                   	ret    

0080160a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80160a:	55                   	push   %ebp
  80160b:	89 e5                	mov    %esp,%ebp
  80160d:	83 ec 18             	sub    $0x18,%esp
  801610:	8b 45 08             	mov    0x8(%ebp),%eax
  801613:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801616:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801619:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80161d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801620:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801627:	85 c0                	test   %eax,%eax
  801629:	74 26                	je     801651 <vsnprintf+0x47>
  80162b:	85 d2                	test   %edx,%edx
  80162d:	7e 29                	jle    801658 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80162f:	ff 75 14             	pushl  0x14(%ebp)
  801632:	ff 75 10             	pushl  0x10(%ebp)
  801635:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801638:	50                   	push   %eax
  801639:	68 e9 11 80 00       	push   $0x8011e9
  80163e:	e8 df fb ff ff       	call   801222 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801643:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801646:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801649:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80164c:	83 c4 10             	add    $0x10,%esp
  80164f:	eb 0c                	jmp    80165d <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801651:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801656:	eb 05                	jmp    80165d <vsnprintf+0x53>
  801658:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80165d:	c9                   	leave  
  80165e:	c3                   	ret    

0080165f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80165f:	55                   	push   %ebp
  801660:	89 e5                	mov    %esp,%ebp
  801662:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801665:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801668:	50                   	push   %eax
  801669:	ff 75 10             	pushl  0x10(%ebp)
  80166c:	ff 75 0c             	pushl  0xc(%ebp)
  80166f:	ff 75 08             	pushl  0x8(%ebp)
  801672:	e8 93 ff ff ff       	call   80160a <vsnprintf>
	va_end(ap);

	return rc;
}
  801677:	c9                   	leave  
  801678:	c3                   	ret    

00801679 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801679:	55                   	push   %ebp
  80167a:	89 e5                	mov    %esp,%ebp
  80167c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80167f:	80 3a 00             	cmpb   $0x0,(%edx)
  801682:	74 0e                	je     801692 <strlen+0x19>
  801684:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801689:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80168a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80168e:	75 f9                	jne    801689 <strlen+0x10>
  801690:	eb 05                	jmp    801697 <strlen+0x1e>
  801692:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801697:	5d                   	pop    %ebp
  801698:	c3                   	ret    

00801699 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801699:	55                   	push   %ebp
  80169a:	89 e5                	mov    %esp,%ebp
  80169c:	53                   	push   %ebx
  80169d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8016a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016a3:	85 c9                	test   %ecx,%ecx
  8016a5:	74 1a                	je     8016c1 <strnlen+0x28>
  8016a7:	80 3b 00             	cmpb   $0x0,(%ebx)
  8016aa:	74 1c                	je     8016c8 <strnlen+0x2f>
  8016ac:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8016b1:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016b3:	39 ca                	cmp    %ecx,%edx
  8016b5:	74 16                	je     8016cd <strnlen+0x34>
  8016b7:	42                   	inc    %edx
  8016b8:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8016bd:	75 f2                	jne    8016b1 <strnlen+0x18>
  8016bf:	eb 0c                	jmp    8016cd <strnlen+0x34>
  8016c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8016c6:	eb 05                	jmp    8016cd <strnlen+0x34>
  8016c8:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8016cd:	5b                   	pop    %ebx
  8016ce:	5d                   	pop    %ebp
  8016cf:	c3                   	ret    

008016d0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016d0:	55                   	push   %ebp
  8016d1:	89 e5                	mov    %esp,%ebp
  8016d3:	53                   	push   %ebx
  8016d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016da:	89 c2                	mov    %eax,%edx
  8016dc:	42                   	inc    %edx
  8016dd:	41                   	inc    %ecx
  8016de:	8a 59 ff             	mov    -0x1(%ecx),%bl
  8016e1:	88 5a ff             	mov    %bl,-0x1(%edx)
  8016e4:	84 db                	test   %bl,%bl
  8016e6:	75 f4                	jne    8016dc <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8016e8:	5b                   	pop    %ebx
  8016e9:	5d                   	pop    %ebp
  8016ea:	c3                   	ret    

008016eb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016eb:	55                   	push   %ebp
  8016ec:	89 e5                	mov    %esp,%ebp
  8016ee:	53                   	push   %ebx
  8016ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016f2:	53                   	push   %ebx
  8016f3:	e8 81 ff ff ff       	call   801679 <strlen>
  8016f8:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8016fb:	ff 75 0c             	pushl  0xc(%ebp)
  8016fe:	01 d8                	add    %ebx,%eax
  801700:	50                   	push   %eax
  801701:	e8 ca ff ff ff       	call   8016d0 <strcpy>
	return dst;
}
  801706:	89 d8                	mov    %ebx,%eax
  801708:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80170b:	c9                   	leave  
  80170c:	c3                   	ret    

0080170d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80170d:	55                   	push   %ebp
  80170e:	89 e5                	mov    %esp,%ebp
  801710:	56                   	push   %esi
  801711:	53                   	push   %ebx
  801712:	8b 75 08             	mov    0x8(%ebp),%esi
  801715:	8b 55 0c             	mov    0xc(%ebp),%edx
  801718:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80171b:	85 db                	test   %ebx,%ebx
  80171d:	74 14                	je     801733 <strncpy+0x26>
  80171f:	01 f3                	add    %esi,%ebx
  801721:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  801723:	41                   	inc    %ecx
  801724:	8a 02                	mov    (%edx),%al
  801726:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801729:	80 3a 01             	cmpb   $0x1,(%edx)
  80172c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80172f:	39 cb                	cmp    %ecx,%ebx
  801731:	75 f0                	jne    801723 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801733:	89 f0                	mov    %esi,%eax
  801735:	5b                   	pop    %ebx
  801736:	5e                   	pop    %esi
  801737:	5d                   	pop    %ebp
  801738:	c3                   	ret    

00801739 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801739:	55                   	push   %ebp
  80173a:	89 e5                	mov    %esp,%ebp
  80173c:	53                   	push   %ebx
  80173d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801740:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801743:	85 c0                	test   %eax,%eax
  801745:	74 30                	je     801777 <strlcpy+0x3e>
		while (--size > 0 && *src != '\0')
  801747:	48                   	dec    %eax
  801748:	74 20                	je     80176a <strlcpy+0x31>
  80174a:	8a 0b                	mov    (%ebx),%cl
  80174c:	84 c9                	test   %cl,%cl
  80174e:	74 1f                	je     80176f <strlcpy+0x36>
  801750:	8d 53 01             	lea    0x1(%ebx),%edx
  801753:	01 c3                	add    %eax,%ebx
  801755:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
  801758:	40                   	inc    %eax
  801759:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80175c:	39 da                	cmp    %ebx,%edx
  80175e:	74 12                	je     801772 <strlcpy+0x39>
  801760:	42                   	inc    %edx
  801761:	8a 4a ff             	mov    -0x1(%edx),%cl
  801764:	84 c9                	test   %cl,%cl
  801766:	75 f0                	jne    801758 <strlcpy+0x1f>
  801768:	eb 08                	jmp    801772 <strlcpy+0x39>
  80176a:	8b 45 08             	mov    0x8(%ebp),%eax
  80176d:	eb 03                	jmp    801772 <strlcpy+0x39>
  80176f:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
		*dst = '\0';
  801772:	c6 00 00             	movb   $0x0,(%eax)
  801775:	eb 03                	jmp    80177a <strlcpy+0x41>
  801777:	8b 45 08             	mov    0x8(%ebp),%eax
	}
	return dst - dst_in;
  80177a:	2b 45 08             	sub    0x8(%ebp),%eax
}
  80177d:	5b                   	pop    %ebx
  80177e:	5d                   	pop    %ebp
  80177f:	c3                   	ret    

00801780 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801780:	55                   	push   %ebp
  801781:	89 e5                	mov    %esp,%ebp
  801783:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801786:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801789:	8a 01                	mov    (%ecx),%al
  80178b:	84 c0                	test   %al,%al
  80178d:	74 10                	je     80179f <strcmp+0x1f>
  80178f:	3a 02                	cmp    (%edx),%al
  801791:	75 0c                	jne    80179f <strcmp+0x1f>
		p++, q++;
  801793:	41                   	inc    %ecx
  801794:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801795:	8a 01                	mov    (%ecx),%al
  801797:	84 c0                	test   %al,%al
  801799:	74 04                	je     80179f <strcmp+0x1f>
  80179b:	3a 02                	cmp    (%edx),%al
  80179d:	74 f4                	je     801793 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80179f:	0f b6 c0             	movzbl %al,%eax
  8017a2:	0f b6 12             	movzbl (%edx),%edx
  8017a5:	29 d0                	sub    %edx,%eax
}
  8017a7:	5d                   	pop    %ebp
  8017a8:	c3                   	ret    

008017a9 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017a9:	55                   	push   %ebp
  8017aa:	89 e5                	mov    %esp,%ebp
  8017ac:	56                   	push   %esi
  8017ad:	53                   	push   %ebx
  8017ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8017b1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017b4:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  8017b7:	85 f6                	test   %esi,%esi
  8017b9:	74 23                	je     8017de <strncmp+0x35>
  8017bb:	8a 03                	mov    (%ebx),%al
  8017bd:	84 c0                	test   %al,%al
  8017bf:	74 2b                	je     8017ec <strncmp+0x43>
  8017c1:	3a 02                	cmp    (%edx),%al
  8017c3:	75 27                	jne    8017ec <strncmp+0x43>
  8017c5:	8d 43 01             	lea    0x1(%ebx),%eax
  8017c8:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  8017ca:	89 c3                	mov    %eax,%ebx
  8017cc:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017cd:	39 c6                	cmp    %eax,%esi
  8017cf:	74 14                	je     8017e5 <strncmp+0x3c>
  8017d1:	8a 08                	mov    (%eax),%cl
  8017d3:	84 c9                	test   %cl,%cl
  8017d5:	74 15                	je     8017ec <strncmp+0x43>
  8017d7:	40                   	inc    %eax
  8017d8:	3a 0a                	cmp    (%edx),%cl
  8017da:	74 ee                	je     8017ca <strncmp+0x21>
  8017dc:	eb 0e                	jmp    8017ec <strncmp+0x43>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017de:	b8 00 00 00 00       	mov    $0x0,%eax
  8017e3:	eb 0f                	jmp    8017f4 <strncmp+0x4b>
  8017e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8017ea:	eb 08                	jmp    8017f4 <strncmp+0x4b>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017ec:	0f b6 03             	movzbl (%ebx),%eax
  8017ef:	0f b6 12             	movzbl (%edx),%edx
  8017f2:	29 d0                	sub    %edx,%eax
}
  8017f4:	5b                   	pop    %ebx
  8017f5:	5e                   	pop    %esi
  8017f6:	5d                   	pop    %ebp
  8017f7:	c3                   	ret    

008017f8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017f8:	55                   	push   %ebp
  8017f9:	89 e5                	mov    %esp,%ebp
  8017fb:	53                   	push   %ebx
  8017fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  801802:	8a 10                	mov    (%eax),%dl
  801804:	84 d2                	test   %dl,%dl
  801806:	74 1a                	je     801822 <strchr+0x2a>
  801808:	88 d9                	mov    %bl,%cl
		if (*s == c)
  80180a:	38 d3                	cmp    %dl,%bl
  80180c:	75 06                	jne    801814 <strchr+0x1c>
  80180e:	eb 17                	jmp    801827 <strchr+0x2f>
  801810:	38 ca                	cmp    %cl,%dl
  801812:	74 13                	je     801827 <strchr+0x2f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801814:	40                   	inc    %eax
  801815:	8a 10                	mov    (%eax),%dl
  801817:	84 d2                	test   %dl,%dl
  801819:	75 f5                	jne    801810 <strchr+0x18>
		if (*s == c)
			return (char *) s;
	return 0;
  80181b:	b8 00 00 00 00       	mov    $0x0,%eax
  801820:	eb 05                	jmp    801827 <strchr+0x2f>
  801822:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801827:	5b                   	pop    %ebx
  801828:	5d                   	pop    %ebp
  801829:	c3                   	ret    

0080182a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80182a:	55                   	push   %ebp
  80182b:	89 e5                	mov    %esp,%ebp
  80182d:	53                   	push   %ebx
  80182e:	8b 45 08             	mov    0x8(%ebp),%eax
  801831:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  801834:	8a 10                	mov    (%eax),%dl
  801836:	84 d2                	test   %dl,%dl
  801838:	74 13                	je     80184d <strfind+0x23>
  80183a:	88 d9                	mov    %bl,%cl
		if (*s == c)
  80183c:	38 d3                	cmp    %dl,%bl
  80183e:	75 06                	jne    801846 <strfind+0x1c>
  801840:	eb 0b                	jmp    80184d <strfind+0x23>
  801842:	38 ca                	cmp    %cl,%dl
  801844:	74 07                	je     80184d <strfind+0x23>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801846:	40                   	inc    %eax
  801847:	8a 10                	mov    (%eax),%dl
  801849:	84 d2                	test   %dl,%dl
  80184b:	75 f5                	jne    801842 <strfind+0x18>
		if (*s == c)
			break;
	return (char *) s;
}
  80184d:	5b                   	pop    %ebx
  80184e:	5d                   	pop    %ebp
  80184f:	c3                   	ret    

00801850 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801850:	55                   	push   %ebp
  801851:	89 e5                	mov    %esp,%ebp
  801853:	57                   	push   %edi
  801854:	56                   	push   %esi
  801855:	53                   	push   %ebx
  801856:	8b 7d 08             	mov    0x8(%ebp),%edi
  801859:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80185c:	85 c9                	test   %ecx,%ecx
  80185e:	74 36                	je     801896 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801860:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801866:	75 28                	jne    801890 <memset+0x40>
  801868:	f6 c1 03             	test   $0x3,%cl
  80186b:	75 23                	jne    801890 <memset+0x40>
		c &= 0xFF;
  80186d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801871:	89 d3                	mov    %edx,%ebx
  801873:	c1 e3 08             	shl    $0x8,%ebx
  801876:	89 d6                	mov    %edx,%esi
  801878:	c1 e6 18             	shl    $0x18,%esi
  80187b:	89 d0                	mov    %edx,%eax
  80187d:	c1 e0 10             	shl    $0x10,%eax
  801880:	09 f0                	or     %esi,%eax
  801882:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801884:	89 d8                	mov    %ebx,%eax
  801886:	09 d0                	or     %edx,%eax
  801888:	c1 e9 02             	shr    $0x2,%ecx
  80188b:	fc                   	cld    
  80188c:	f3 ab                	rep stos %eax,%es:(%edi)
  80188e:	eb 06                	jmp    801896 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801890:	8b 45 0c             	mov    0xc(%ebp),%eax
  801893:	fc                   	cld    
  801894:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801896:	89 f8                	mov    %edi,%eax
  801898:	5b                   	pop    %ebx
  801899:	5e                   	pop    %esi
  80189a:	5f                   	pop    %edi
  80189b:	5d                   	pop    %ebp
  80189c:	c3                   	ret    

0080189d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80189d:	55                   	push   %ebp
  80189e:	89 e5                	mov    %esp,%ebp
  8018a0:	57                   	push   %edi
  8018a1:	56                   	push   %esi
  8018a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018a8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8018ab:	39 c6                	cmp    %eax,%esi
  8018ad:	73 33                	jae    8018e2 <memmove+0x45>
  8018af:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8018b2:	39 d0                	cmp    %edx,%eax
  8018b4:	73 2c                	jae    8018e2 <memmove+0x45>
		s += n;
		d += n;
  8018b6:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018b9:	89 d6                	mov    %edx,%esi
  8018bb:	09 fe                	or     %edi,%esi
  8018bd:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018c3:	75 13                	jne    8018d8 <memmove+0x3b>
  8018c5:	f6 c1 03             	test   $0x3,%cl
  8018c8:	75 0e                	jne    8018d8 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8018ca:	83 ef 04             	sub    $0x4,%edi
  8018cd:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018d0:	c1 e9 02             	shr    $0x2,%ecx
  8018d3:	fd                   	std    
  8018d4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018d6:	eb 07                	jmp    8018df <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8018d8:	4f                   	dec    %edi
  8018d9:	8d 72 ff             	lea    -0x1(%edx),%esi
  8018dc:	fd                   	std    
  8018dd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018df:	fc                   	cld    
  8018e0:	eb 1d                	jmp    8018ff <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018e2:	89 f2                	mov    %esi,%edx
  8018e4:	09 c2                	or     %eax,%edx
  8018e6:	f6 c2 03             	test   $0x3,%dl
  8018e9:	75 0f                	jne    8018fa <memmove+0x5d>
  8018eb:	f6 c1 03             	test   $0x3,%cl
  8018ee:	75 0a                	jne    8018fa <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
  8018f0:	c1 e9 02             	shr    $0x2,%ecx
  8018f3:	89 c7                	mov    %eax,%edi
  8018f5:	fc                   	cld    
  8018f6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018f8:	eb 05                	jmp    8018ff <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018fa:	89 c7                	mov    %eax,%edi
  8018fc:	fc                   	cld    
  8018fd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018ff:	5e                   	pop    %esi
  801900:	5f                   	pop    %edi
  801901:	5d                   	pop    %ebp
  801902:	c3                   	ret    

00801903 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801903:	55                   	push   %ebp
  801904:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801906:	ff 75 10             	pushl  0x10(%ebp)
  801909:	ff 75 0c             	pushl  0xc(%ebp)
  80190c:	ff 75 08             	pushl  0x8(%ebp)
  80190f:	e8 89 ff ff ff       	call   80189d <memmove>
}
  801914:	c9                   	leave  
  801915:	c3                   	ret    

00801916 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801916:	55                   	push   %ebp
  801917:	89 e5                	mov    %esp,%ebp
  801919:	57                   	push   %edi
  80191a:	56                   	push   %esi
  80191b:	53                   	push   %ebx
  80191c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80191f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801922:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801925:	85 c0                	test   %eax,%eax
  801927:	74 33                	je     80195c <memcmp+0x46>
  801929:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  80192c:	8a 13                	mov    (%ebx),%dl
  80192e:	8a 0e                	mov    (%esi),%cl
  801930:	38 ca                	cmp    %cl,%dl
  801932:	75 13                	jne    801947 <memcmp+0x31>
  801934:	b8 00 00 00 00       	mov    $0x0,%eax
  801939:	eb 16                	jmp    801951 <memcmp+0x3b>
  80193b:	8a 54 03 01          	mov    0x1(%ebx,%eax,1),%dl
  80193f:	40                   	inc    %eax
  801940:	8a 0c 06             	mov    (%esi,%eax,1),%cl
  801943:	38 ca                	cmp    %cl,%dl
  801945:	74 0a                	je     801951 <memcmp+0x3b>
			return (int) *s1 - (int) *s2;
  801947:	0f b6 c2             	movzbl %dl,%eax
  80194a:	0f b6 c9             	movzbl %cl,%ecx
  80194d:	29 c8                	sub    %ecx,%eax
  80194f:	eb 10                	jmp    801961 <memcmp+0x4b>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801951:	39 f8                	cmp    %edi,%eax
  801953:	75 e6                	jne    80193b <memcmp+0x25>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801955:	b8 00 00 00 00       	mov    $0x0,%eax
  80195a:	eb 05                	jmp    801961 <memcmp+0x4b>
  80195c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801961:	5b                   	pop    %ebx
  801962:	5e                   	pop    %esi
  801963:	5f                   	pop    %edi
  801964:	5d                   	pop    %ebp
  801965:	c3                   	ret    

00801966 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801966:	55                   	push   %ebp
  801967:	89 e5                	mov    %esp,%ebp
  801969:	53                   	push   %ebx
  80196a:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  80196d:	89 d0                	mov    %edx,%eax
  80196f:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  801972:	39 c2                	cmp    %eax,%edx
  801974:	73 1b                	jae    801991 <memfind+0x2b>
		if (*(const unsigned char *) s == (unsigned char) c)
  801976:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  80197a:	0f b6 0a             	movzbl (%edx),%ecx
  80197d:	39 d9                	cmp    %ebx,%ecx
  80197f:	75 09                	jne    80198a <memfind+0x24>
  801981:	eb 12                	jmp    801995 <memfind+0x2f>
  801983:	0f b6 0a             	movzbl (%edx),%ecx
  801986:	39 d9                	cmp    %ebx,%ecx
  801988:	74 0f                	je     801999 <memfind+0x33>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80198a:	42                   	inc    %edx
  80198b:	39 d0                	cmp    %edx,%eax
  80198d:	75 f4                	jne    801983 <memfind+0x1d>
  80198f:	eb 0a                	jmp    80199b <memfind+0x35>
  801991:	89 d0                	mov    %edx,%eax
  801993:	eb 06                	jmp    80199b <memfind+0x35>
		if (*(const unsigned char *) s == (unsigned char) c)
  801995:	89 d0                	mov    %edx,%eax
  801997:	eb 02                	jmp    80199b <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801999:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80199b:	5b                   	pop    %ebx
  80199c:	5d                   	pop    %ebp
  80199d:	c3                   	ret    

0080199e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80199e:	55                   	push   %ebp
  80199f:	89 e5                	mov    %esp,%ebp
  8019a1:	57                   	push   %edi
  8019a2:	56                   	push   %esi
  8019a3:	53                   	push   %ebx
  8019a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8019a7:	eb 01                	jmp    8019aa <strtol+0xc>
		s++;
  8019a9:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8019aa:	8a 01                	mov    (%ecx),%al
  8019ac:	3c 20                	cmp    $0x20,%al
  8019ae:	74 f9                	je     8019a9 <strtol+0xb>
  8019b0:	3c 09                	cmp    $0x9,%al
  8019b2:	74 f5                	je     8019a9 <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  8019b4:	3c 2b                	cmp    $0x2b,%al
  8019b6:	75 08                	jne    8019c0 <strtol+0x22>
		s++;
  8019b8:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8019b9:	bf 00 00 00 00       	mov    $0x0,%edi
  8019be:	eb 11                	jmp    8019d1 <strtol+0x33>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8019c0:	3c 2d                	cmp    $0x2d,%al
  8019c2:	75 08                	jne    8019cc <strtol+0x2e>
		s++, neg = 1;
  8019c4:	41                   	inc    %ecx
  8019c5:	bf 01 00 00 00       	mov    $0x1,%edi
  8019ca:	eb 05                	jmp    8019d1 <strtol+0x33>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8019cc:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019d1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019d5:	0f 84 87 00 00 00    	je     801a62 <strtol+0xc4>
  8019db:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  8019df:	75 27                	jne    801a08 <strtol+0x6a>
  8019e1:	80 39 30             	cmpb   $0x30,(%ecx)
  8019e4:	75 22                	jne    801a08 <strtol+0x6a>
  8019e6:	e9 88 00 00 00       	jmp    801a73 <strtol+0xd5>
		s += 2, base = 16;
  8019eb:	83 c1 02             	add    $0x2,%ecx
  8019ee:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  8019f5:	eb 11                	jmp    801a08 <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
  8019f7:	41                   	inc    %ecx
  8019f8:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  8019ff:	eb 07                	jmp    801a08 <strtol+0x6a>
	else if (base == 0)
		base = 10;
  801a01:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  801a08:	b8 00 00 00 00       	mov    $0x0,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801a0d:	8a 11                	mov    (%ecx),%dl
  801a0f:	8d 5a d0             	lea    -0x30(%edx),%ebx
  801a12:	80 fb 09             	cmp    $0x9,%bl
  801a15:	77 08                	ja     801a1f <strtol+0x81>
			dig = *s - '0';
  801a17:	0f be d2             	movsbl %dl,%edx
  801a1a:	83 ea 30             	sub    $0x30,%edx
  801a1d:	eb 22                	jmp    801a41 <strtol+0xa3>
		else if (*s >= 'a' && *s <= 'z')
  801a1f:	8d 72 9f             	lea    -0x61(%edx),%esi
  801a22:	89 f3                	mov    %esi,%ebx
  801a24:	80 fb 19             	cmp    $0x19,%bl
  801a27:	77 08                	ja     801a31 <strtol+0x93>
			dig = *s - 'a' + 10;
  801a29:	0f be d2             	movsbl %dl,%edx
  801a2c:	83 ea 57             	sub    $0x57,%edx
  801a2f:	eb 10                	jmp    801a41 <strtol+0xa3>
		else if (*s >= 'A' && *s <= 'Z')
  801a31:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a34:	89 f3                	mov    %esi,%ebx
  801a36:	80 fb 19             	cmp    $0x19,%bl
  801a39:	77 14                	ja     801a4f <strtol+0xb1>
			dig = *s - 'A' + 10;
  801a3b:	0f be d2             	movsbl %dl,%edx
  801a3e:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801a41:	3b 55 10             	cmp    0x10(%ebp),%edx
  801a44:	7d 09                	jge    801a4f <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  801a46:	41                   	inc    %ecx
  801a47:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a4b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801a4d:	eb be                	jmp    801a0d <strtol+0x6f>

	if (endptr)
  801a4f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a53:	74 05                	je     801a5a <strtol+0xbc>
		*endptr = (char *) s;
  801a55:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a58:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801a5a:	85 ff                	test   %edi,%edi
  801a5c:	74 21                	je     801a7f <strtol+0xe1>
  801a5e:	f7 d8                	neg    %eax
  801a60:	eb 1d                	jmp    801a7f <strtol+0xe1>
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801a62:	80 39 30             	cmpb   $0x30,(%ecx)
  801a65:	75 9a                	jne    801a01 <strtol+0x63>
  801a67:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801a6b:	0f 84 7a ff ff ff    	je     8019eb <strtol+0x4d>
  801a71:	eb 84                	jmp    8019f7 <strtol+0x59>
  801a73:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801a77:	0f 84 6e ff ff ff    	je     8019eb <strtol+0x4d>
  801a7d:	eb 89                	jmp    801a08 <strtol+0x6a>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  801a7f:	5b                   	pop    %ebx
  801a80:	5e                   	pop    %esi
  801a81:	5f                   	pop    %edi
  801a82:	5d                   	pop    %ebp
  801a83:	c3                   	ret    

00801a84 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a84:	55                   	push   %ebp
  801a85:	89 e5                	mov    %esp,%ebp
  801a87:	56                   	push   %esi
  801a88:	53                   	push   %ebx
  801a89:	8b 75 08             	mov    0x8(%ebp),%esi
  801a8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a8f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");
	int r;
    if (pg != NULL) {
  801a92:	85 c0                	test   %eax,%eax
  801a94:	74 0e                	je     801aa4 <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  801a96:	83 ec 0c             	sub    $0xc,%esp
  801a99:	50                   	push   %eax
  801a9a:	e8 9b e8 ff ff       	call   80033a <sys_ipc_recv>
  801a9f:	83 c4 10             	add    $0x10,%esp
  801aa2:	eb 10                	jmp    801ab4 <ipc_recv+0x30>
    } else {
        r = sys_ipc_recv((void *) UTOP);
  801aa4:	83 ec 0c             	sub    $0xc,%esp
  801aa7:	68 00 00 c0 ee       	push   $0xeec00000
  801aac:	e8 89 e8 ff ff       	call   80033a <sys_ipc_recv>
  801ab1:	83 c4 10             	add    $0x10,%esp
    }
    if (r < 0) {
  801ab4:	85 c0                	test   %eax,%eax
  801ab6:	79 16                	jns    801ace <ipc_recv+0x4a>
        // failed
        if (from_env_store != NULL) *from_env_store = 0;
  801ab8:	85 f6                	test   %esi,%esi
  801aba:	74 06                	je     801ac2 <ipc_recv+0x3e>
  801abc:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL) *perm_store = 0;
  801ac2:	85 db                	test   %ebx,%ebx
  801ac4:	74 2c                	je     801af2 <ipc_recv+0x6e>
  801ac6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801acc:	eb 24                	jmp    801af2 <ipc_recv+0x6e>
        return r;
    } else {
        if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801ace:	85 f6                	test   %esi,%esi
  801ad0:	74 0a                	je     801adc <ipc_recv+0x58>
  801ad2:	a1 04 40 80 00       	mov    0x804004,%eax
  801ad7:	8b 40 74             	mov    0x74(%eax),%eax
  801ada:	89 06                	mov    %eax,(%esi)
        if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801adc:	85 db                	test   %ebx,%ebx
  801ade:	74 0a                	je     801aea <ipc_recv+0x66>
  801ae0:	a1 04 40 80 00       	mov    0x804004,%eax
  801ae5:	8b 40 78             	mov    0x78(%eax),%eax
  801ae8:	89 03                	mov    %eax,(%ebx)
        return thisenv->env_ipc_value;
  801aea:	a1 04 40 80 00       	mov    0x804004,%eax
  801aef:	8b 40 70             	mov    0x70(%eax),%eax
    }
 
	return 0;
}
  801af2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801af5:	5b                   	pop    %ebx
  801af6:	5e                   	pop    %esi
  801af7:	5d                   	pop    %ebp
  801af8:	c3                   	ret    

00801af9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801af9:	55                   	push   %ebp
  801afa:	89 e5                	mov    %esp,%ebp
  801afc:	57                   	push   %edi
  801afd:	56                   	push   %esi
  801afe:	53                   	push   %ebx
  801aff:	83 ec 0c             	sub    $0xc,%esp
  801b02:	8b 75 10             	mov    0x10(%ebp),%esi
  801b05:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;
    if (pg == NULL) pg = (void *)UTOP;
  801b08:	85 f6                	test   %esi,%esi
  801b0a:	75 05                	jne    801b11 <ipc_send+0x18>
  801b0c:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
  801b11:	57                   	push   %edi
  801b12:	56                   	push   %esi
  801b13:	ff 75 0c             	pushl  0xc(%ebp)
  801b16:	ff 75 08             	pushl  0x8(%ebp)
  801b19:	e8 f9 e7 ff ff       	call   800317 <sys_ipc_try_send>
  801b1e:	89 c3                	mov    %eax,%ebx
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
  801b20:	83 c4 10             	add    $0x10,%esp
  801b23:	85 c0                	test   %eax,%eax
  801b25:	79 17                	jns    801b3e <ipc_send+0x45>
  801b27:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b2a:	74 1d                	je     801b49 <ipc_send+0x50>
  801b2c:	50                   	push   %eax
  801b2d:	68 a0 22 80 00       	push   $0x8022a0
  801b32:	6a 40                	push   $0x40
  801b34:	68 b4 22 80 00       	push   $0x8022b4
  801b39:	e8 d5 f4 ff ff       	call   801013 <_panic>
        sys_yield();
  801b3e:	e8 28 e6 ff ff       	call   80016b <sys_yield>
    } while (r != 0);
  801b43:	85 db                	test   %ebx,%ebx
  801b45:	75 ca                	jne    801b11 <ipc_send+0x18>
  801b47:	eb 07                	jmp    801b50 <ipc_send+0x57>
	int r;
    if (pg == NULL) pg = (void *)UTOP;
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
        sys_yield();
  801b49:	e8 1d e6 ff ff       	call   80016b <sys_yield>
  801b4e:	eb c1                	jmp    801b11 <ipc_send+0x18>
    } while (r != 0);
}
  801b50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b53:	5b                   	pop    %ebx
  801b54:	5e                   	pop    %esi
  801b55:	5f                   	pop    %edi
  801b56:	5d                   	pop    %ebp
  801b57:	c3                   	ret    

00801b58 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b58:	55                   	push   %ebp
  801b59:	89 e5                	mov    %esp,%ebp
  801b5b:	53                   	push   %ebx
  801b5c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801b5f:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801b64:	39 c1                	cmp    %eax,%ecx
  801b66:	74 21                	je     801b89 <ipc_find_env+0x31>
  801b68:	ba 01 00 00 00       	mov    $0x1,%edx
  801b6d:	8d 1c 95 00 00 00 00 	lea    0x0(,%edx,4),%ebx
  801b74:	89 d0                	mov    %edx,%eax
  801b76:	c1 e0 07             	shl    $0x7,%eax
  801b79:	29 d8                	sub    %ebx,%eax
  801b7b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b80:	8b 40 50             	mov    0x50(%eax),%eax
  801b83:	39 c8                	cmp    %ecx,%eax
  801b85:	75 1b                	jne    801ba2 <ipc_find_env+0x4a>
  801b87:	eb 05                	jmp    801b8e <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b89:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801b8e:	8d 04 95 00 00 00 00 	lea    0x0(,%edx,4),%eax
  801b95:	c1 e2 07             	shl    $0x7,%edx
  801b98:	29 c2                	sub    %eax,%edx
  801b9a:	8b 82 48 00 c0 ee    	mov    -0x113fffb8(%edx),%eax
  801ba0:	eb 0e                	jmp    801bb0 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ba2:	42                   	inc    %edx
  801ba3:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  801ba9:	75 c2                	jne    801b6d <ipc_find_env+0x15>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801bab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bb0:	5b                   	pop    %ebx
  801bb1:	5d                   	pop    %ebp
  801bb2:	c3                   	ret    

00801bb3 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801bb3:	55                   	push   %ebp
  801bb4:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bb6:	8b 45 08             	mov    0x8(%ebp),%eax
  801bb9:	c1 e8 16             	shr    $0x16,%eax
  801bbc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801bc3:	a8 01                	test   $0x1,%al
  801bc5:	74 21                	je     801be8 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801bc7:	8b 45 08             	mov    0x8(%ebp),%eax
  801bca:	c1 e8 0c             	shr    $0xc,%eax
  801bcd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801bd4:	a8 01                	test   $0x1,%al
  801bd6:	74 17                	je     801bef <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bd8:	c1 e8 0c             	shr    $0xc,%eax
  801bdb:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801be2:	ef 
  801be3:	0f b7 c0             	movzwl %ax,%eax
  801be6:	eb 0c                	jmp    801bf4 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801be8:	b8 00 00 00 00       	mov    $0x0,%eax
  801bed:	eb 05                	jmp    801bf4 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801bef:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801bf4:	5d                   	pop    %ebp
  801bf5:	c3                   	ret    
  801bf6:	66 90                	xchg   %ax,%ax

00801bf8 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801bf8:	55                   	push   %ebp
  801bf9:	57                   	push   %edi
  801bfa:	56                   	push   %esi
  801bfb:	53                   	push   %ebx
  801bfc:	83 ec 1c             	sub    $0x1c,%esp
  801bff:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801c03:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801c07:	8b 7c 24 38          	mov    0x38(%esp),%edi
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801c0b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c0f:	89 ca                	mov    %ecx,%edx
  const DWunion dd = {.ll = d};
  801c11:	89 f8                	mov    %edi,%eax
  801c13:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801c17:	85 f6                	test   %esi,%esi
  801c19:	75 2d                	jne    801c48 <__udivdi3+0x50>
    {
      if (d0 > n1)
  801c1b:	39 cf                	cmp    %ecx,%edi
  801c1d:	77 65                	ja     801c84 <__udivdi3+0x8c>
  801c1f:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801c21:	85 ff                	test   %edi,%edi
  801c23:	75 0b                	jne    801c30 <__udivdi3+0x38>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801c25:	b8 01 00 00 00       	mov    $0x1,%eax
  801c2a:	31 d2                	xor    %edx,%edx
  801c2c:	f7 f7                	div    %edi
  801c2e:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801c30:	31 d2                	xor    %edx,%edx
  801c32:	89 c8                	mov    %ecx,%eax
  801c34:	f7 f5                	div    %ebp
  801c36:	89 c1                	mov    %eax,%ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c38:	89 d8                	mov    %ebx,%eax
  801c3a:	f7 f5                	div    %ebp
  801c3c:	89 cf                	mov    %ecx,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c3e:	89 fa                	mov    %edi,%edx
  801c40:	83 c4 1c             	add    $0x1c,%esp
  801c43:	5b                   	pop    %ebx
  801c44:	5e                   	pop    %esi
  801c45:	5f                   	pop    %edi
  801c46:	5d                   	pop    %ebp
  801c47:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801c48:	39 ce                	cmp    %ecx,%esi
  801c4a:	77 28                	ja     801c74 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801c4c:	0f bd fe             	bsr    %esi,%edi
	  if (bm == 0)
  801c4f:	83 f7 1f             	xor    $0x1f,%edi
  801c52:	75 40                	jne    801c94 <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801c54:	39 ce                	cmp    %ecx,%esi
  801c56:	72 0a                	jb     801c62 <__udivdi3+0x6a>
  801c58:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801c5c:	0f 87 9e 00 00 00    	ja     801d00 <__udivdi3+0x108>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801c62:	b8 01 00 00 00       	mov    $0x1,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c67:	89 fa                	mov    %edi,%edx
  801c69:	83 c4 1c             	add    $0x1c,%esp
  801c6c:	5b                   	pop    %ebx
  801c6d:	5e                   	pop    %esi
  801c6e:	5f                   	pop    %edi
  801c6f:	5d                   	pop    %ebp
  801c70:	c3                   	ret    
  801c71:	8d 76 00             	lea    0x0(%esi),%esi
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801c74:	31 ff                	xor    %edi,%edi
  801c76:	31 c0                	xor    %eax,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c78:	89 fa                	mov    %edi,%edx
  801c7a:	83 c4 1c             	add    $0x1c,%esp
  801c7d:	5b                   	pop    %ebx
  801c7e:	5e                   	pop    %esi
  801c7f:	5f                   	pop    %edi
  801c80:	5d                   	pop    %ebp
  801c81:	c3                   	ret    
  801c82:	66 90                	xchg   %ax,%ax
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c84:	89 d8                	mov    %ebx,%eax
  801c86:	f7 f7                	div    %edi
  801c88:	31 ff                	xor    %edi,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c8a:	89 fa                	mov    %edi,%edx
  801c8c:	83 c4 1c             	add    $0x1c,%esp
  801c8f:	5b                   	pop    %ebx
  801c90:	5e                   	pop    %esi
  801c91:	5f                   	pop    %edi
  801c92:	5d                   	pop    %ebp
  801c93:	c3                   	ret    
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801c94:	bd 20 00 00 00       	mov    $0x20,%ebp
  801c99:	89 eb                	mov    %ebp,%ebx
  801c9b:	29 fb                	sub    %edi,%ebx

	      d1 = (d1 << bm) | (d0 >> b);
  801c9d:	89 f9                	mov    %edi,%ecx
  801c9f:	d3 e6                	shl    %cl,%esi
  801ca1:	89 c5                	mov    %eax,%ebp
  801ca3:	88 d9                	mov    %bl,%cl
  801ca5:	d3 ed                	shr    %cl,%ebp
  801ca7:	89 e9                	mov    %ebp,%ecx
  801ca9:	09 f1                	or     %esi,%ecx
  801cab:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
	      d0 = d0 << bm;
  801caf:	89 f9                	mov    %edi,%ecx
  801cb1:	d3 e0                	shl    %cl,%eax
  801cb3:	89 c5                	mov    %eax,%ebp
	      n2 = n1 >> b;
  801cb5:	89 d6                	mov    %edx,%esi
  801cb7:	88 d9                	mov    %bl,%cl
  801cb9:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
  801cbb:	89 f9                	mov    %edi,%ecx
  801cbd:	d3 e2                	shl    %cl,%edx
  801cbf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801cc3:	88 d9                	mov    %bl,%cl
  801cc5:	d3 e8                	shr    %cl,%eax
  801cc7:	09 c2                	or     %eax,%edx
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801cc9:	89 d0                	mov    %edx,%eax
  801ccb:	89 f2                	mov    %esi,%edx
  801ccd:	f7 74 24 0c          	divl   0xc(%esp)
  801cd1:	89 d6                	mov    %edx,%esi
  801cd3:	89 c3                	mov    %eax,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  801cd5:	f7 e5                	mul    %ebp

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801cd7:	39 d6                	cmp    %edx,%esi
  801cd9:	72 19                	jb     801cf4 <__udivdi3+0xfc>
  801cdb:	74 0b                	je     801ce8 <__udivdi3+0xf0>
  801cdd:	89 d8                	mov    %ebx,%eax
  801cdf:	31 ff                	xor    %edi,%edi
  801ce1:	e9 58 ff ff ff       	jmp    801c3e <__udivdi3+0x46>
  801ce6:	66 90                	xchg   %ax,%ax
  801ce8:	8b 54 24 08          	mov    0x8(%esp),%edx
  801cec:	89 f9                	mov    %edi,%ecx
  801cee:	d3 e2                	shl    %cl,%edx
  801cf0:	39 c2                	cmp    %eax,%edx
  801cf2:	73 e9                	jae    801cdd <__udivdi3+0xe5>
  801cf4:	8d 43 ff             	lea    -0x1(%ebx),%eax
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801cf7:	31 ff                	xor    %edi,%edi
  801cf9:	e9 40 ff ff ff       	jmp    801c3e <__udivdi3+0x46>
  801cfe:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801d00:	31 c0                	xor    %eax,%eax
  801d02:	e9 37 ff ff ff       	jmp    801c3e <__udivdi3+0x46>
  801d07:	90                   	nop

00801d08 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801d08:	55                   	push   %ebp
  801d09:	57                   	push   %edi
  801d0a:	56                   	push   %esi
  801d0b:	53                   	push   %ebx
  801d0c:	83 ec 1c             	sub    $0x1c,%esp
  801d0f:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d13:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d17:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d1b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801d1f:	89 44 24 0c          	mov    %eax,0xc(%esp)
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801d23:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d27:	89 f3                	mov    %esi,%ebx
  const DWunion dd = {.ll = d};
  801d29:	89 fa                	mov    %edi,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801d2b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  n1 = nn.s.high;
  801d2f:	89 34 24             	mov    %esi,(%esp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801d32:	85 c0                	test   %eax,%eax
  801d34:	75 1a                	jne    801d50 <__umoddi3+0x48>
    {
      if (d0 > n1)
  801d36:	39 f7                	cmp    %esi,%edi
  801d38:	0f 86 a2 00 00 00    	jbe    801de0 <__umoddi3+0xd8>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d3e:	89 c8                	mov    %ecx,%eax
  801d40:	89 f2                	mov    %esi,%edx
  801d42:	f7 f7                	div    %edi
  801d44:	89 d0                	mov    %edx,%eax

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801d46:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d48:	83 c4 1c             	add    $0x1c,%esp
  801d4b:	5b                   	pop    %ebx
  801d4c:	5e                   	pop    %esi
  801d4d:	5f                   	pop    %edi
  801d4e:	5d                   	pop    %ebp
  801d4f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801d50:	39 f0                	cmp    %esi,%eax
  801d52:	0f 87 ac 00 00 00    	ja     801e04 <__umoddi3+0xfc>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801d58:	0f bd e8             	bsr    %eax,%ebp
	  if (bm == 0)
  801d5b:	83 f5 1f             	xor    $0x1f,%ebp
  801d5e:	0f 84 ac 00 00 00    	je     801e10 <__umoddi3+0x108>
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801d64:	bf 20 00 00 00       	mov    $0x20,%edi
  801d69:	29 ef                	sub    %ebp,%edi
  801d6b:	89 fe                	mov    %edi,%esi
  801d6d:	89 7c 24 0c          	mov    %edi,0xc(%esp)

	      d1 = (d1 << bm) | (d0 >> b);
  801d71:	89 e9                	mov    %ebp,%ecx
  801d73:	d3 e0                	shl    %cl,%eax
  801d75:	89 d7                	mov    %edx,%edi
  801d77:	89 f1                	mov    %esi,%ecx
  801d79:	d3 ef                	shr    %cl,%edi
  801d7b:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  801d7d:	89 e9                	mov    %ebp,%ecx
  801d7f:	d3 e2                	shl    %cl,%edx
  801d81:	89 14 24             	mov    %edx,(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801d84:	89 d8                	mov    %ebx,%eax
  801d86:	d3 e0                	shl    %cl,%eax
  801d88:	89 c2                	mov    %eax,%edx
	      n0 = n0 << bm;
  801d8a:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d8e:	d3 e0                	shl    %cl,%eax
  801d90:	89 44 24 04          	mov    %eax,0x4(%esp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801d94:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d98:	89 f1                	mov    %esi,%ecx
  801d9a:	d3 e8                	shr    %cl,%eax
  801d9c:	09 d0                	or     %edx,%eax
  801d9e:	d3 eb                	shr    %cl,%ebx
  801da0:	89 da                	mov    %ebx,%edx
  801da2:	f7 f7                	div    %edi
  801da4:	89 d3                	mov    %edx,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  801da6:	f7 24 24             	mull   (%esp)
  801da9:	89 c6                	mov    %eax,%esi
  801dab:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801dad:	39 d3                	cmp    %edx,%ebx
  801daf:	0f 82 87 00 00 00    	jb     801e3c <__umoddi3+0x134>
  801db5:	0f 84 91 00 00 00    	je     801e4c <__umoddi3+0x144>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801dbb:	8b 54 24 04          	mov    0x4(%esp),%edx
  801dbf:	29 f2                	sub    %esi,%edx
  801dc1:	19 cb                	sbb    %ecx,%ebx
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801dc3:	89 d8                	mov    %ebx,%eax
  801dc5:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  801dc9:	d3 e0                	shl    %cl,%eax
  801dcb:	89 e9                	mov    %ebp,%ecx
  801dcd:	d3 ea                	shr    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801dcf:	09 d0                	or     %edx,%eax
  801dd1:	89 e9                	mov    %ebp,%ecx
  801dd3:	d3 eb                	shr    %cl,%ebx
  801dd5:	89 da                	mov    %ebx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801dd7:	83 c4 1c             	add    $0x1c,%esp
  801dda:	5b                   	pop    %ebx
  801ddb:	5e                   	pop    %esi
  801ddc:	5f                   	pop    %edi
  801ddd:	5d                   	pop    %ebp
  801dde:	c3                   	ret    
  801ddf:	90                   	nop
  801de0:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801de2:	85 ff                	test   %edi,%edi
  801de4:	75 0b                	jne    801df1 <__umoddi3+0xe9>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801de6:	b8 01 00 00 00       	mov    $0x1,%eax
  801deb:	31 d2                	xor    %edx,%edx
  801ded:	f7 f7                	div    %edi
  801def:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801df1:	89 f0                	mov    %esi,%eax
  801df3:	31 d2                	xor    %edx,%edx
  801df5:	f7 f5                	div    %ebp
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801df7:	89 c8                	mov    %ecx,%eax
  801df9:	f7 f5                	div    %ebp
  801dfb:	89 d0                	mov    %edx,%eax
  801dfd:	e9 44 ff ff ff       	jmp    801d46 <__umoddi3+0x3e>
  801e02:	66 90                	xchg   %ax,%ax
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801e04:	89 c8                	mov    %ecx,%eax
  801e06:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e08:	83 c4 1c             	add    $0x1c,%esp
  801e0b:	5b                   	pop    %ebx
  801e0c:	5e                   	pop    %esi
  801e0d:	5f                   	pop    %edi
  801e0e:	5d                   	pop    %ebp
  801e0f:	c3                   	ret    

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801e10:	3b 04 24             	cmp    (%esp),%eax
  801e13:	72 06                	jb     801e1b <__umoddi3+0x113>
  801e15:	3b 7c 24 04          	cmp    0x4(%esp),%edi
  801e19:	77 0f                	ja     801e2a <__umoddi3+0x122>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801e1b:	89 f2                	mov    %esi,%edx
  801e1d:	29 f9                	sub    %edi,%ecx
  801e1f:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  801e23:	89 14 24             	mov    %edx,(%esp)
  801e26:	89 4c 24 04          	mov    %ecx,0x4(%esp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801e2a:	8b 44 24 04          	mov    0x4(%esp),%eax
  801e2e:	8b 14 24             	mov    (%esp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e31:	83 c4 1c             	add    $0x1c,%esp
  801e34:	5b                   	pop    %ebx
  801e35:	5e                   	pop    %esi
  801e36:	5f                   	pop    %edi
  801e37:	5d                   	pop    %ebp
  801e38:	c3                   	ret    
  801e39:	8d 76 00             	lea    0x0(%esi),%esi
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801e3c:	2b 04 24             	sub    (%esp),%eax
  801e3f:	19 fa                	sbb    %edi,%edx
  801e41:	89 d1                	mov    %edx,%ecx
  801e43:	89 c6                	mov    %eax,%esi
  801e45:	e9 71 ff ff ff       	jmp    801dbb <__umoddi3+0xb3>
  801e4a:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e4c:	39 44 24 04          	cmp    %eax,0x4(%esp)
  801e50:	72 ea                	jb     801e3c <__umoddi3+0x134>
  801e52:	89 d9                	mov    %ebx,%ecx
  801e54:	e9 62 ff ff ff       	jmp    801dbb <__umoddi3+0xb3>
