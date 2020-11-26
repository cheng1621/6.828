
obj/user/softint.debug:     file format elf32-i386


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
  80002c:	e8 09 00 00 00       	call   80003a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $14");	// page fault
  800036:	cd 0e                	int    $0xe
}
  800038:	5d                   	pop    %ebp
  800039:	c3                   	ret    

0080003a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003a:	55                   	push   %ebp
  80003b:	89 e5                	mov    %esp,%ebp
  80003d:	56                   	push   %esi
  80003e:	53                   	push   %ebx
  80003f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800042:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800045:	e8 d7 00 00 00       	call   800121 <sys_getenvid>
  80004a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800056:	c1 e0 07             	shl    $0x7,%eax
  800059:	29 d0                	sub    %edx,%eax
  80005b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800060:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800065:	85 db                	test   %ebx,%ebx
  800067:	7e 07                	jle    800070 <libmain+0x36>
		binaryname = argv[0];
  800069:	8b 06                	mov    (%esi),%eax
  80006b:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800070:	83 ec 08             	sub    $0x8,%esp
  800073:	56                   	push   %esi
  800074:	53                   	push   %ebx
  800075:	e8 b9 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80007a:	e8 0a 00 00 00       	call   800089 <exit>
}
  80007f:	83 c4 10             	add    $0x10,%esp
  800082:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800085:	5b                   	pop    %ebx
  800086:	5e                   	pop    %esi
  800087:	5d                   	pop    %ebp
  800088:	c3                   	ret    

00800089 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800089:	55                   	push   %ebp
  80008a:	89 e5                	mov    %esp,%ebp
  80008c:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80008f:	e8 cb 04 00 00       	call   80055f <close_all>
	sys_env_destroy(0);
  800094:	83 ec 0c             	sub    $0xc,%esp
  800097:	6a 00                	push   $0x0
  800099:	e8 42 00 00 00       	call   8000e0 <sys_env_destroy>
}
  80009e:	83 c4 10             	add    $0x10,%esp
  8000a1:	c9                   	leave  
  8000a2:	c3                   	ret    

008000a3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a3:	55                   	push   %ebp
  8000a4:	89 e5                	mov    %esp,%ebp
  8000a6:	57                   	push   %edi
  8000a7:	56                   	push   %esi
  8000a8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b4:	89 c3                	mov    %eax,%ebx
  8000b6:	89 c7                	mov    %eax,%edi
  8000b8:	89 c6                	mov    %eax,%esi
  8000ba:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000bc:	5b                   	pop    %ebx
  8000bd:	5e                   	pop    %esi
  8000be:	5f                   	pop    %edi
  8000bf:	5d                   	pop    %ebp
  8000c0:	c3                   	ret    

008000c1 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c1:	55                   	push   %ebp
  8000c2:	89 e5                	mov    %esp,%ebp
  8000c4:	57                   	push   %edi
  8000c5:	56                   	push   %esi
  8000c6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cc:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d1:	89 d1                	mov    %edx,%ecx
  8000d3:	89 d3                	mov    %edx,%ebx
  8000d5:	89 d7                	mov    %edx,%edi
  8000d7:	89 d6                	mov    %edx,%esi
  8000d9:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000db:	5b                   	pop    %ebx
  8000dc:	5e                   	pop    %esi
  8000dd:	5f                   	pop    %edi
  8000de:	5d                   	pop    %ebp
  8000df:	c3                   	ret    

008000e0 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	57                   	push   %edi
  8000e4:	56                   	push   %esi
  8000e5:	53                   	push   %ebx
  8000e6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ee:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f6:	89 cb                	mov    %ecx,%ebx
  8000f8:	89 cf                	mov    %ecx,%edi
  8000fa:	89 ce                	mov    %ecx,%esi
  8000fc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000fe:	85 c0                	test   %eax,%eax
  800100:	7e 17                	jle    800119 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800102:	83 ec 0c             	sub    $0xc,%esp
  800105:	50                   	push   %eax
  800106:	6a 03                	push   $0x3
  800108:	68 4a 1e 80 00       	push   $0x801e4a
  80010d:	6a 23                	push   $0x23
  80010f:	68 67 1e 80 00       	push   $0x801e67
  800114:	e8 cf 0e 00 00       	call   800fe8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800119:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80011c:	5b                   	pop    %ebx
  80011d:	5e                   	pop    %esi
  80011e:	5f                   	pop    %edi
  80011f:	5d                   	pop    %ebp
  800120:	c3                   	ret    

00800121 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800121:	55                   	push   %ebp
  800122:	89 e5                	mov    %esp,%ebp
  800124:	57                   	push   %edi
  800125:	56                   	push   %esi
  800126:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800127:	ba 00 00 00 00       	mov    $0x0,%edx
  80012c:	b8 02 00 00 00       	mov    $0x2,%eax
  800131:	89 d1                	mov    %edx,%ecx
  800133:	89 d3                	mov    %edx,%ebx
  800135:	89 d7                	mov    %edx,%edi
  800137:	89 d6                	mov    %edx,%esi
  800139:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013b:	5b                   	pop    %ebx
  80013c:	5e                   	pop    %esi
  80013d:	5f                   	pop    %edi
  80013e:	5d                   	pop    %ebp
  80013f:	c3                   	ret    

00800140 <sys_yield>:

void
sys_yield(void)
{
  800140:	55                   	push   %ebp
  800141:	89 e5                	mov    %esp,%ebp
  800143:	57                   	push   %edi
  800144:	56                   	push   %esi
  800145:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800146:	ba 00 00 00 00       	mov    $0x0,%edx
  80014b:	b8 0b 00 00 00       	mov    $0xb,%eax
  800150:	89 d1                	mov    %edx,%ecx
  800152:	89 d3                	mov    %edx,%ebx
  800154:	89 d7                	mov    %edx,%edi
  800156:	89 d6                	mov    %edx,%esi
  800158:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80015a:	5b                   	pop    %ebx
  80015b:	5e                   	pop    %esi
  80015c:	5f                   	pop    %edi
  80015d:	5d                   	pop    %ebp
  80015e:	c3                   	ret    

0080015f <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80015f:	55                   	push   %ebp
  800160:	89 e5                	mov    %esp,%ebp
  800162:	57                   	push   %edi
  800163:	56                   	push   %esi
  800164:	53                   	push   %ebx
  800165:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800168:	be 00 00 00 00       	mov    $0x0,%esi
  80016d:	b8 04 00 00 00       	mov    $0x4,%eax
  800172:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800175:	8b 55 08             	mov    0x8(%ebp),%edx
  800178:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017b:	89 f7                	mov    %esi,%edi
  80017d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80017f:	85 c0                	test   %eax,%eax
  800181:	7e 17                	jle    80019a <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800183:	83 ec 0c             	sub    $0xc,%esp
  800186:	50                   	push   %eax
  800187:	6a 04                	push   $0x4
  800189:	68 4a 1e 80 00       	push   $0x801e4a
  80018e:	6a 23                	push   $0x23
  800190:	68 67 1e 80 00       	push   $0x801e67
  800195:	e8 4e 0e 00 00       	call   800fe8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80019a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80019d:	5b                   	pop    %ebx
  80019e:	5e                   	pop    %esi
  80019f:	5f                   	pop    %edi
  8001a0:	5d                   	pop    %ebp
  8001a1:	c3                   	ret    

008001a2 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a2:	55                   	push   %ebp
  8001a3:	89 e5                	mov    %esp,%ebp
  8001a5:	57                   	push   %edi
  8001a6:	56                   	push   %esi
  8001a7:	53                   	push   %ebx
  8001a8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ab:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b9:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001bc:	8b 75 18             	mov    0x18(%ebp),%esi
  8001bf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001c1:	85 c0                	test   %eax,%eax
  8001c3:	7e 17                	jle    8001dc <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c5:	83 ec 0c             	sub    $0xc,%esp
  8001c8:	50                   	push   %eax
  8001c9:	6a 05                	push   $0x5
  8001cb:	68 4a 1e 80 00       	push   $0x801e4a
  8001d0:	6a 23                	push   $0x23
  8001d2:	68 67 1e 80 00       	push   $0x801e67
  8001d7:	e8 0c 0e 00 00       	call   800fe8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001df:	5b                   	pop    %ebx
  8001e0:	5e                   	pop    %esi
  8001e1:	5f                   	pop    %edi
  8001e2:	5d                   	pop    %ebp
  8001e3:	c3                   	ret    

008001e4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e4:	55                   	push   %ebp
  8001e5:	89 e5                	mov    %esp,%ebp
  8001e7:	57                   	push   %edi
  8001e8:	56                   	push   %esi
  8001e9:	53                   	push   %ebx
  8001ea:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ed:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f2:	b8 06 00 00 00       	mov    $0x6,%eax
  8001f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fd:	89 df                	mov    %ebx,%edi
  8001ff:	89 de                	mov    %ebx,%esi
  800201:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800203:	85 c0                	test   %eax,%eax
  800205:	7e 17                	jle    80021e <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800207:	83 ec 0c             	sub    $0xc,%esp
  80020a:	50                   	push   %eax
  80020b:	6a 06                	push   $0x6
  80020d:	68 4a 1e 80 00       	push   $0x801e4a
  800212:	6a 23                	push   $0x23
  800214:	68 67 1e 80 00       	push   $0x801e67
  800219:	e8 ca 0d 00 00       	call   800fe8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80021e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800221:	5b                   	pop    %ebx
  800222:	5e                   	pop    %esi
  800223:	5f                   	pop    %edi
  800224:	5d                   	pop    %ebp
  800225:	c3                   	ret    

00800226 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800226:	55                   	push   %ebp
  800227:	89 e5                	mov    %esp,%ebp
  800229:	57                   	push   %edi
  80022a:	56                   	push   %esi
  80022b:	53                   	push   %ebx
  80022c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80022f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800234:	b8 08 00 00 00       	mov    $0x8,%eax
  800239:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023c:	8b 55 08             	mov    0x8(%ebp),%edx
  80023f:	89 df                	mov    %ebx,%edi
  800241:	89 de                	mov    %ebx,%esi
  800243:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800245:	85 c0                	test   %eax,%eax
  800247:	7e 17                	jle    800260 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800249:	83 ec 0c             	sub    $0xc,%esp
  80024c:	50                   	push   %eax
  80024d:	6a 08                	push   $0x8
  80024f:	68 4a 1e 80 00       	push   $0x801e4a
  800254:	6a 23                	push   $0x23
  800256:	68 67 1e 80 00       	push   $0x801e67
  80025b:	e8 88 0d 00 00       	call   800fe8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800260:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800263:	5b                   	pop    %ebx
  800264:	5e                   	pop    %esi
  800265:	5f                   	pop    %edi
  800266:	5d                   	pop    %ebp
  800267:	c3                   	ret    

00800268 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800268:	55                   	push   %ebp
  800269:	89 e5                	mov    %esp,%ebp
  80026b:	57                   	push   %edi
  80026c:	56                   	push   %esi
  80026d:	53                   	push   %ebx
  80026e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800271:	bb 00 00 00 00       	mov    $0x0,%ebx
  800276:	b8 09 00 00 00       	mov    $0x9,%eax
  80027b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80027e:	8b 55 08             	mov    0x8(%ebp),%edx
  800281:	89 df                	mov    %ebx,%edi
  800283:	89 de                	mov    %ebx,%esi
  800285:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800287:	85 c0                	test   %eax,%eax
  800289:	7e 17                	jle    8002a2 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028b:	83 ec 0c             	sub    $0xc,%esp
  80028e:	50                   	push   %eax
  80028f:	6a 09                	push   $0x9
  800291:	68 4a 1e 80 00       	push   $0x801e4a
  800296:	6a 23                	push   $0x23
  800298:	68 67 1e 80 00       	push   $0x801e67
  80029d:	e8 46 0d 00 00       	call   800fe8 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a5:	5b                   	pop    %ebx
  8002a6:	5e                   	pop    %esi
  8002a7:	5f                   	pop    %edi
  8002a8:	5d                   	pop    %ebp
  8002a9:	c3                   	ret    

008002aa <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002aa:	55                   	push   %ebp
  8002ab:	89 e5                	mov    %esp,%ebp
  8002ad:	57                   	push   %edi
  8002ae:	56                   	push   %esi
  8002af:	53                   	push   %ebx
  8002b0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c3:	89 df                	mov    %ebx,%edi
  8002c5:	89 de                	mov    %ebx,%esi
  8002c7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002c9:	85 c0                	test   %eax,%eax
  8002cb:	7e 17                	jle    8002e4 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002cd:	83 ec 0c             	sub    $0xc,%esp
  8002d0:	50                   	push   %eax
  8002d1:	6a 0a                	push   $0xa
  8002d3:	68 4a 1e 80 00       	push   $0x801e4a
  8002d8:	6a 23                	push   $0x23
  8002da:	68 67 1e 80 00       	push   $0x801e67
  8002df:	e8 04 0d 00 00       	call   800fe8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e7:	5b                   	pop    %ebx
  8002e8:	5e                   	pop    %esi
  8002e9:	5f                   	pop    %edi
  8002ea:	5d                   	pop    %ebp
  8002eb:	c3                   	ret    

008002ec <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002ec:	55                   	push   %ebp
  8002ed:	89 e5                	mov    %esp,%ebp
  8002ef:	57                   	push   %edi
  8002f0:	56                   	push   %esi
  8002f1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f2:	be 00 00 00 00       	mov    $0x0,%esi
  8002f7:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ff:	8b 55 08             	mov    0x8(%ebp),%edx
  800302:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800305:	8b 7d 14             	mov    0x14(%ebp),%edi
  800308:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80030a:	5b                   	pop    %ebx
  80030b:	5e                   	pop    %esi
  80030c:	5f                   	pop    %edi
  80030d:	5d                   	pop    %ebp
  80030e:	c3                   	ret    

0080030f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80030f:	55                   	push   %ebp
  800310:	89 e5                	mov    %esp,%ebp
  800312:	57                   	push   %edi
  800313:	56                   	push   %esi
  800314:	53                   	push   %ebx
  800315:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800318:	b9 00 00 00 00       	mov    $0x0,%ecx
  80031d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800322:	8b 55 08             	mov    0x8(%ebp),%edx
  800325:	89 cb                	mov    %ecx,%ebx
  800327:	89 cf                	mov    %ecx,%edi
  800329:	89 ce                	mov    %ecx,%esi
  80032b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80032d:	85 c0                	test   %eax,%eax
  80032f:	7e 17                	jle    800348 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800331:	83 ec 0c             	sub    $0xc,%esp
  800334:	50                   	push   %eax
  800335:	6a 0d                	push   $0xd
  800337:	68 4a 1e 80 00       	push   $0x801e4a
  80033c:	6a 23                	push   $0x23
  80033e:	68 67 1e 80 00       	push   $0x801e67
  800343:	e8 a0 0c 00 00       	call   800fe8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800348:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034b:	5b                   	pop    %ebx
  80034c:	5e                   	pop    %esi
  80034d:	5f                   	pop    %edi
  80034e:	5d                   	pop    %ebp
  80034f:	c3                   	ret    

00800350 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800350:	55                   	push   %ebp
  800351:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800353:	8b 45 08             	mov    0x8(%ebp),%eax
  800356:	05 00 00 00 30       	add    $0x30000000,%eax
  80035b:	c1 e8 0c             	shr    $0xc,%eax
}
  80035e:	5d                   	pop    %ebp
  80035f:	c3                   	ret    

00800360 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800360:	55                   	push   %ebp
  800361:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800363:	8b 45 08             	mov    0x8(%ebp),%eax
  800366:	05 00 00 00 30       	add    $0x30000000,%eax
  80036b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800370:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800375:	5d                   	pop    %ebp
  800376:	c3                   	ret    

00800377 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800377:	55                   	push   %ebp
  800378:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80037a:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  80037f:	a8 01                	test   $0x1,%al
  800381:	74 34                	je     8003b7 <fd_alloc+0x40>
  800383:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800388:	a8 01                	test   $0x1,%al
  80038a:	74 32                	je     8003be <fd_alloc+0x47>
  80038c:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800391:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800393:	89 c2                	mov    %eax,%edx
  800395:	c1 ea 16             	shr    $0x16,%edx
  800398:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80039f:	f6 c2 01             	test   $0x1,%dl
  8003a2:	74 1f                	je     8003c3 <fd_alloc+0x4c>
  8003a4:	89 c2                	mov    %eax,%edx
  8003a6:	c1 ea 0c             	shr    $0xc,%edx
  8003a9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003b0:	f6 c2 01             	test   $0x1,%dl
  8003b3:	75 1a                	jne    8003cf <fd_alloc+0x58>
  8003b5:	eb 0c                	jmp    8003c3 <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8003b7:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8003bc:	eb 05                	jmp    8003c3 <fd_alloc+0x4c>
  8003be:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8003c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c6:	89 08                	mov    %ecx,(%eax)
			return 0;
  8003c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8003cd:	eb 1a                	jmp    8003e9 <fd_alloc+0x72>
  8003cf:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003d4:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003d9:	75 b6                	jne    800391 <fd_alloc+0x1a>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003db:	8b 45 08             	mov    0x8(%ebp),%eax
  8003de:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  8003e4:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003e9:	5d                   	pop    %ebp
  8003ea:	c3                   	ret    

008003eb <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003eb:	55                   	push   %ebp
  8003ec:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003ee:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  8003f2:	77 39                	ja     80042d <fd_lookup+0x42>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f7:	c1 e0 0c             	shl    $0xc,%eax
  8003fa:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003ff:	89 c2                	mov    %eax,%edx
  800401:	c1 ea 16             	shr    $0x16,%edx
  800404:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80040b:	f6 c2 01             	test   $0x1,%dl
  80040e:	74 24                	je     800434 <fd_lookup+0x49>
  800410:	89 c2                	mov    %eax,%edx
  800412:	c1 ea 0c             	shr    $0xc,%edx
  800415:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80041c:	f6 c2 01             	test   $0x1,%dl
  80041f:	74 1a                	je     80043b <fd_lookup+0x50>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800421:	8b 55 0c             	mov    0xc(%ebp),%edx
  800424:	89 02                	mov    %eax,(%edx)
	return 0;
  800426:	b8 00 00 00 00       	mov    $0x0,%eax
  80042b:	eb 13                	jmp    800440 <fd_lookup+0x55>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80042d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800432:	eb 0c                	jmp    800440 <fd_lookup+0x55>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800434:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800439:	eb 05                	jmp    800440 <fd_lookup+0x55>
  80043b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800440:	5d                   	pop    %ebp
  800441:	c3                   	ret    

00800442 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800442:	55                   	push   %ebp
  800443:	89 e5                	mov    %esp,%ebp
  800445:	53                   	push   %ebx
  800446:	83 ec 04             	sub    $0x4,%esp
  800449:	8b 45 08             	mov    0x8(%ebp),%eax
  80044c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80044f:	3b 05 04 30 80 00    	cmp    0x803004,%eax
  800455:	75 1e                	jne    800475 <dev_lookup+0x33>
  800457:	eb 0e                	jmp    800467 <dev_lookup+0x25>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800459:	b8 20 30 80 00       	mov    $0x803020,%eax
  80045e:	eb 0c                	jmp    80046c <dev_lookup+0x2a>
  800460:	b8 3c 30 80 00       	mov    $0x80303c,%eax
  800465:	eb 05                	jmp    80046c <dev_lookup+0x2a>
  800467:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  80046c:	89 03                	mov    %eax,(%ebx)
			return 0;
  80046e:	b8 00 00 00 00       	mov    $0x0,%eax
  800473:	eb 36                	jmp    8004ab <dev_lookup+0x69>
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800475:	3b 05 20 30 80 00    	cmp    0x803020,%eax
  80047b:	74 dc                	je     800459 <dev_lookup+0x17>
  80047d:	3b 05 3c 30 80 00    	cmp    0x80303c,%eax
  800483:	74 db                	je     800460 <dev_lookup+0x1e>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800485:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80048b:	8b 52 48             	mov    0x48(%edx),%edx
  80048e:	83 ec 04             	sub    $0x4,%esp
  800491:	50                   	push   %eax
  800492:	52                   	push   %edx
  800493:	68 78 1e 80 00       	push   $0x801e78
  800498:	e8 23 0c 00 00       	call   8010c0 <cprintf>
	*dev = 0;
  80049d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8004a3:	83 c4 10             	add    $0x10,%esp
  8004a6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004ab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004ae:	c9                   	leave  
  8004af:	c3                   	ret    

008004b0 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004b0:	55                   	push   %ebp
  8004b1:	89 e5                	mov    %esp,%ebp
  8004b3:	56                   	push   %esi
  8004b4:	53                   	push   %ebx
  8004b5:	83 ec 10             	sub    $0x10,%esp
  8004b8:	8b 75 08             	mov    0x8(%ebp),%esi
  8004bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004c1:	50                   	push   %eax
  8004c2:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004c8:	c1 e8 0c             	shr    $0xc,%eax
  8004cb:	50                   	push   %eax
  8004cc:	e8 1a ff ff ff       	call   8003eb <fd_lookup>
  8004d1:	83 c4 08             	add    $0x8,%esp
  8004d4:	85 c0                	test   %eax,%eax
  8004d6:	78 05                	js     8004dd <fd_close+0x2d>
	    || fd != fd2)
  8004d8:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004db:	74 06                	je     8004e3 <fd_close+0x33>
		return (must_exist ? r : 0);
  8004dd:	84 db                	test   %bl,%bl
  8004df:	74 47                	je     800528 <fd_close+0x78>
  8004e1:	eb 4a                	jmp    80052d <fd_close+0x7d>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004e3:	83 ec 08             	sub    $0x8,%esp
  8004e6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004e9:	50                   	push   %eax
  8004ea:	ff 36                	pushl  (%esi)
  8004ec:	e8 51 ff ff ff       	call   800442 <dev_lookup>
  8004f1:	89 c3                	mov    %eax,%ebx
  8004f3:	83 c4 10             	add    $0x10,%esp
  8004f6:	85 c0                	test   %eax,%eax
  8004f8:	78 1c                	js     800516 <fd_close+0x66>
		if (dev->dev_close)
  8004fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004fd:	8b 40 10             	mov    0x10(%eax),%eax
  800500:	85 c0                	test   %eax,%eax
  800502:	74 0d                	je     800511 <fd_close+0x61>
			r = (*dev->dev_close)(fd);
  800504:	83 ec 0c             	sub    $0xc,%esp
  800507:	56                   	push   %esi
  800508:	ff d0                	call   *%eax
  80050a:	89 c3                	mov    %eax,%ebx
  80050c:	83 c4 10             	add    $0x10,%esp
  80050f:	eb 05                	jmp    800516 <fd_close+0x66>
		else
			r = 0;
  800511:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800516:	83 ec 08             	sub    $0x8,%esp
  800519:	56                   	push   %esi
  80051a:	6a 00                	push   $0x0
  80051c:	e8 c3 fc ff ff       	call   8001e4 <sys_page_unmap>
	return r;
  800521:	83 c4 10             	add    $0x10,%esp
  800524:	89 d8                	mov    %ebx,%eax
  800526:	eb 05                	jmp    80052d <fd_close+0x7d>
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
  800528:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
	return r;
}
  80052d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800530:	5b                   	pop    %ebx
  800531:	5e                   	pop    %esi
  800532:	5d                   	pop    %ebp
  800533:	c3                   	ret    

00800534 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800534:	55                   	push   %ebp
  800535:	89 e5                	mov    %esp,%ebp
  800537:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80053a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80053d:	50                   	push   %eax
  80053e:	ff 75 08             	pushl  0x8(%ebp)
  800541:	e8 a5 fe ff ff       	call   8003eb <fd_lookup>
  800546:	83 c4 08             	add    $0x8,%esp
  800549:	85 c0                	test   %eax,%eax
  80054b:	78 10                	js     80055d <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80054d:	83 ec 08             	sub    $0x8,%esp
  800550:	6a 01                	push   $0x1
  800552:	ff 75 f4             	pushl  -0xc(%ebp)
  800555:	e8 56 ff ff ff       	call   8004b0 <fd_close>
  80055a:	83 c4 10             	add    $0x10,%esp
}
  80055d:	c9                   	leave  
  80055e:	c3                   	ret    

0080055f <close_all>:

void
close_all(void)
{
  80055f:	55                   	push   %ebp
  800560:	89 e5                	mov    %esp,%ebp
  800562:	53                   	push   %ebx
  800563:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800566:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80056b:	83 ec 0c             	sub    $0xc,%esp
  80056e:	53                   	push   %ebx
  80056f:	e8 c0 ff ff ff       	call   800534 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800574:	43                   	inc    %ebx
  800575:	83 c4 10             	add    $0x10,%esp
  800578:	83 fb 20             	cmp    $0x20,%ebx
  80057b:	75 ee                	jne    80056b <close_all+0xc>
		close(i);
}
  80057d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800580:	c9                   	leave  
  800581:	c3                   	ret    

00800582 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800582:	55                   	push   %ebp
  800583:	89 e5                	mov    %esp,%ebp
  800585:	57                   	push   %edi
  800586:	56                   	push   %esi
  800587:	53                   	push   %ebx
  800588:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80058b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80058e:	50                   	push   %eax
  80058f:	ff 75 08             	pushl  0x8(%ebp)
  800592:	e8 54 fe ff ff       	call   8003eb <fd_lookup>
  800597:	83 c4 08             	add    $0x8,%esp
  80059a:	85 c0                	test   %eax,%eax
  80059c:	0f 88 c2 00 00 00    	js     800664 <dup+0xe2>
		return r;
	close(newfdnum);
  8005a2:	83 ec 0c             	sub    $0xc,%esp
  8005a5:	ff 75 0c             	pushl  0xc(%ebp)
  8005a8:	e8 87 ff ff ff       	call   800534 <close>

	newfd = INDEX2FD(newfdnum);
  8005ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005b0:	c1 e3 0c             	shl    $0xc,%ebx
  8005b3:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8005b9:	83 c4 04             	add    $0x4,%esp
  8005bc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005bf:	e8 9c fd ff ff       	call   800360 <fd2data>
  8005c4:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  8005c6:	89 1c 24             	mov    %ebx,(%esp)
  8005c9:	e8 92 fd ff ff       	call   800360 <fd2data>
  8005ce:	83 c4 10             	add    $0x10,%esp
  8005d1:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005d3:	89 f0                	mov    %esi,%eax
  8005d5:	c1 e8 16             	shr    $0x16,%eax
  8005d8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005df:	a8 01                	test   $0x1,%al
  8005e1:	74 35                	je     800618 <dup+0x96>
  8005e3:	89 f0                	mov    %esi,%eax
  8005e5:	c1 e8 0c             	shr    $0xc,%eax
  8005e8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005ef:	f6 c2 01             	test   $0x1,%dl
  8005f2:	74 24                	je     800618 <dup+0x96>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005f4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005fb:	83 ec 0c             	sub    $0xc,%esp
  8005fe:	25 07 0e 00 00       	and    $0xe07,%eax
  800603:	50                   	push   %eax
  800604:	57                   	push   %edi
  800605:	6a 00                	push   $0x0
  800607:	56                   	push   %esi
  800608:	6a 00                	push   $0x0
  80060a:	e8 93 fb ff ff       	call   8001a2 <sys_page_map>
  80060f:	89 c6                	mov    %eax,%esi
  800611:	83 c4 20             	add    $0x20,%esp
  800614:	85 c0                	test   %eax,%eax
  800616:	78 2c                	js     800644 <dup+0xc2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800618:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80061b:	89 d0                	mov    %edx,%eax
  80061d:	c1 e8 0c             	shr    $0xc,%eax
  800620:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800627:	83 ec 0c             	sub    $0xc,%esp
  80062a:	25 07 0e 00 00       	and    $0xe07,%eax
  80062f:	50                   	push   %eax
  800630:	53                   	push   %ebx
  800631:	6a 00                	push   $0x0
  800633:	52                   	push   %edx
  800634:	6a 00                	push   $0x0
  800636:	e8 67 fb ff ff       	call   8001a2 <sys_page_map>
  80063b:	89 c6                	mov    %eax,%esi
  80063d:	83 c4 20             	add    $0x20,%esp
  800640:	85 c0                	test   %eax,%eax
  800642:	79 1d                	jns    800661 <dup+0xdf>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800644:	83 ec 08             	sub    $0x8,%esp
  800647:	53                   	push   %ebx
  800648:	6a 00                	push   $0x0
  80064a:	e8 95 fb ff ff       	call   8001e4 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80064f:	83 c4 08             	add    $0x8,%esp
  800652:	57                   	push   %edi
  800653:	6a 00                	push   $0x0
  800655:	e8 8a fb ff ff       	call   8001e4 <sys_page_unmap>
	return r;
  80065a:	83 c4 10             	add    $0x10,%esp
  80065d:	89 f0                	mov    %esi,%eax
  80065f:	eb 03                	jmp    800664 <dup+0xe2>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  800661:	8b 45 0c             	mov    0xc(%ebp),%eax

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800664:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800667:	5b                   	pop    %ebx
  800668:	5e                   	pop    %esi
  800669:	5f                   	pop    %edi
  80066a:	5d                   	pop    %ebp
  80066b:	c3                   	ret    

0080066c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80066c:	55                   	push   %ebp
  80066d:	89 e5                	mov    %esp,%ebp
  80066f:	53                   	push   %ebx
  800670:	83 ec 14             	sub    $0x14,%esp
  800673:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800676:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800679:	50                   	push   %eax
  80067a:	53                   	push   %ebx
  80067b:	e8 6b fd ff ff       	call   8003eb <fd_lookup>
  800680:	83 c4 08             	add    $0x8,%esp
  800683:	85 c0                	test   %eax,%eax
  800685:	78 67                	js     8006ee <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800687:	83 ec 08             	sub    $0x8,%esp
  80068a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80068d:	50                   	push   %eax
  80068e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800691:	ff 30                	pushl  (%eax)
  800693:	e8 aa fd ff ff       	call   800442 <dev_lookup>
  800698:	83 c4 10             	add    $0x10,%esp
  80069b:	85 c0                	test   %eax,%eax
  80069d:	78 4f                	js     8006ee <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80069f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006a2:	8b 42 08             	mov    0x8(%edx),%eax
  8006a5:	83 e0 03             	and    $0x3,%eax
  8006a8:	83 f8 01             	cmp    $0x1,%eax
  8006ab:	75 21                	jne    8006ce <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006ad:	a1 04 40 80 00       	mov    0x804004,%eax
  8006b2:	8b 40 48             	mov    0x48(%eax),%eax
  8006b5:	83 ec 04             	sub    $0x4,%esp
  8006b8:	53                   	push   %ebx
  8006b9:	50                   	push   %eax
  8006ba:	68 b9 1e 80 00       	push   $0x801eb9
  8006bf:	e8 fc 09 00 00       	call   8010c0 <cprintf>
		return -E_INVAL;
  8006c4:	83 c4 10             	add    $0x10,%esp
  8006c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006cc:	eb 20                	jmp    8006ee <read+0x82>
	}
	if (!dev->dev_read)
  8006ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006d1:	8b 40 08             	mov    0x8(%eax),%eax
  8006d4:	85 c0                	test   %eax,%eax
  8006d6:	74 11                	je     8006e9 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006d8:	83 ec 04             	sub    $0x4,%esp
  8006db:	ff 75 10             	pushl  0x10(%ebp)
  8006de:	ff 75 0c             	pushl  0xc(%ebp)
  8006e1:	52                   	push   %edx
  8006e2:	ff d0                	call   *%eax
  8006e4:	83 c4 10             	add    $0x10,%esp
  8006e7:	eb 05                	jmp    8006ee <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006e9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8006ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006f1:	c9                   	leave  
  8006f2:	c3                   	ret    

008006f3 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006f3:	55                   	push   %ebp
  8006f4:	89 e5                	mov    %esp,%ebp
  8006f6:	57                   	push   %edi
  8006f7:	56                   	push   %esi
  8006f8:	53                   	push   %ebx
  8006f9:	83 ec 0c             	sub    $0xc,%esp
  8006fc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006ff:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800702:	85 f6                	test   %esi,%esi
  800704:	74 31                	je     800737 <readn+0x44>
  800706:	b8 00 00 00 00       	mov    $0x0,%eax
  80070b:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  800710:	83 ec 04             	sub    $0x4,%esp
  800713:	89 f2                	mov    %esi,%edx
  800715:	29 c2                	sub    %eax,%edx
  800717:	52                   	push   %edx
  800718:	03 45 0c             	add    0xc(%ebp),%eax
  80071b:	50                   	push   %eax
  80071c:	57                   	push   %edi
  80071d:	e8 4a ff ff ff       	call   80066c <read>
		if (m < 0)
  800722:	83 c4 10             	add    $0x10,%esp
  800725:	85 c0                	test   %eax,%eax
  800727:	78 17                	js     800740 <readn+0x4d>
			return m;
		if (m == 0)
  800729:	85 c0                	test   %eax,%eax
  80072b:	74 11                	je     80073e <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80072d:	01 c3                	add    %eax,%ebx
  80072f:	89 d8                	mov    %ebx,%eax
  800731:	39 f3                	cmp    %esi,%ebx
  800733:	72 db                	jb     800710 <readn+0x1d>
  800735:	eb 09                	jmp    800740 <readn+0x4d>
  800737:	b8 00 00 00 00       	mov    $0x0,%eax
  80073c:	eb 02                	jmp    800740 <readn+0x4d>
  80073e:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800740:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800743:	5b                   	pop    %ebx
  800744:	5e                   	pop    %esi
  800745:	5f                   	pop    %edi
  800746:	5d                   	pop    %ebp
  800747:	c3                   	ret    

00800748 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800748:	55                   	push   %ebp
  800749:	89 e5                	mov    %esp,%ebp
  80074b:	53                   	push   %ebx
  80074c:	83 ec 14             	sub    $0x14,%esp
  80074f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800752:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800755:	50                   	push   %eax
  800756:	53                   	push   %ebx
  800757:	e8 8f fc ff ff       	call   8003eb <fd_lookup>
  80075c:	83 c4 08             	add    $0x8,%esp
  80075f:	85 c0                	test   %eax,%eax
  800761:	78 62                	js     8007c5 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800763:	83 ec 08             	sub    $0x8,%esp
  800766:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800769:	50                   	push   %eax
  80076a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80076d:	ff 30                	pushl  (%eax)
  80076f:	e8 ce fc ff ff       	call   800442 <dev_lookup>
  800774:	83 c4 10             	add    $0x10,%esp
  800777:	85 c0                	test   %eax,%eax
  800779:	78 4a                	js     8007c5 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80077b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80077e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800782:	75 21                	jne    8007a5 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800784:	a1 04 40 80 00       	mov    0x804004,%eax
  800789:	8b 40 48             	mov    0x48(%eax),%eax
  80078c:	83 ec 04             	sub    $0x4,%esp
  80078f:	53                   	push   %ebx
  800790:	50                   	push   %eax
  800791:	68 d5 1e 80 00       	push   $0x801ed5
  800796:	e8 25 09 00 00       	call   8010c0 <cprintf>
		return -E_INVAL;
  80079b:	83 c4 10             	add    $0x10,%esp
  80079e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007a3:	eb 20                	jmp    8007c5 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007a5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007a8:	8b 52 0c             	mov    0xc(%edx),%edx
  8007ab:	85 d2                	test   %edx,%edx
  8007ad:	74 11                	je     8007c0 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007af:	83 ec 04             	sub    $0x4,%esp
  8007b2:	ff 75 10             	pushl  0x10(%ebp)
  8007b5:	ff 75 0c             	pushl  0xc(%ebp)
  8007b8:	50                   	push   %eax
  8007b9:	ff d2                	call   *%edx
  8007bb:	83 c4 10             	add    $0x10,%esp
  8007be:	eb 05                	jmp    8007c5 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007c0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8007c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007c8:	c9                   	leave  
  8007c9:	c3                   	ret    

008007ca <seek>:

int
seek(int fdnum, off_t offset)
{
  8007ca:	55                   	push   %ebp
  8007cb:	89 e5                	mov    %esp,%ebp
  8007cd:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007d0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007d3:	50                   	push   %eax
  8007d4:	ff 75 08             	pushl  0x8(%ebp)
  8007d7:	e8 0f fc ff ff       	call   8003eb <fd_lookup>
  8007dc:	83 c4 08             	add    $0x8,%esp
  8007df:	85 c0                	test   %eax,%eax
  8007e1:	78 0e                	js     8007f1 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007e6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007e9:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007f1:	c9                   	leave  
  8007f2:	c3                   	ret    

008007f3 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007f3:	55                   	push   %ebp
  8007f4:	89 e5                	mov    %esp,%ebp
  8007f6:	53                   	push   %ebx
  8007f7:	83 ec 14             	sub    $0x14,%esp
  8007fa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007fd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800800:	50                   	push   %eax
  800801:	53                   	push   %ebx
  800802:	e8 e4 fb ff ff       	call   8003eb <fd_lookup>
  800807:	83 c4 08             	add    $0x8,%esp
  80080a:	85 c0                	test   %eax,%eax
  80080c:	78 5f                	js     80086d <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80080e:	83 ec 08             	sub    $0x8,%esp
  800811:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800814:	50                   	push   %eax
  800815:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800818:	ff 30                	pushl  (%eax)
  80081a:	e8 23 fc ff ff       	call   800442 <dev_lookup>
  80081f:	83 c4 10             	add    $0x10,%esp
  800822:	85 c0                	test   %eax,%eax
  800824:	78 47                	js     80086d <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800826:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800829:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80082d:	75 21                	jne    800850 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80082f:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800834:	8b 40 48             	mov    0x48(%eax),%eax
  800837:	83 ec 04             	sub    $0x4,%esp
  80083a:	53                   	push   %ebx
  80083b:	50                   	push   %eax
  80083c:	68 98 1e 80 00       	push   $0x801e98
  800841:	e8 7a 08 00 00       	call   8010c0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800846:	83 c4 10             	add    $0x10,%esp
  800849:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80084e:	eb 1d                	jmp    80086d <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  800850:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800853:	8b 52 18             	mov    0x18(%edx),%edx
  800856:	85 d2                	test   %edx,%edx
  800858:	74 0e                	je     800868 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80085a:	83 ec 08             	sub    $0x8,%esp
  80085d:	ff 75 0c             	pushl  0xc(%ebp)
  800860:	50                   	push   %eax
  800861:	ff d2                	call   *%edx
  800863:	83 c4 10             	add    $0x10,%esp
  800866:	eb 05                	jmp    80086d <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800868:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80086d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800870:	c9                   	leave  
  800871:	c3                   	ret    

00800872 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800872:	55                   	push   %ebp
  800873:	89 e5                	mov    %esp,%ebp
  800875:	53                   	push   %ebx
  800876:	83 ec 14             	sub    $0x14,%esp
  800879:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80087c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80087f:	50                   	push   %eax
  800880:	ff 75 08             	pushl  0x8(%ebp)
  800883:	e8 63 fb ff ff       	call   8003eb <fd_lookup>
  800888:	83 c4 08             	add    $0x8,%esp
  80088b:	85 c0                	test   %eax,%eax
  80088d:	78 52                	js     8008e1 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80088f:	83 ec 08             	sub    $0x8,%esp
  800892:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800895:	50                   	push   %eax
  800896:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800899:	ff 30                	pushl  (%eax)
  80089b:	e8 a2 fb ff ff       	call   800442 <dev_lookup>
  8008a0:	83 c4 10             	add    $0x10,%esp
  8008a3:	85 c0                	test   %eax,%eax
  8008a5:	78 3a                	js     8008e1 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  8008a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008aa:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008ae:	74 2c                	je     8008dc <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008b0:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008b3:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008ba:	00 00 00 
	stat->st_isdir = 0;
  8008bd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008c4:	00 00 00 
	stat->st_dev = dev;
  8008c7:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008cd:	83 ec 08             	sub    $0x8,%esp
  8008d0:	53                   	push   %ebx
  8008d1:	ff 75 f0             	pushl  -0x10(%ebp)
  8008d4:	ff 50 14             	call   *0x14(%eax)
  8008d7:	83 c4 10             	add    $0x10,%esp
  8008da:	eb 05                	jmp    8008e1 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008dc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008e4:	c9                   	leave  
  8008e5:	c3                   	ret    

008008e6 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008e6:	55                   	push   %ebp
  8008e7:	89 e5                	mov    %esp,%ebp
  8008e9:	56                   	push   %esi
  8008ea:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008eb:	83 ec 08             	sub    $0x8,%esp
  8008ee:	6a 00                	push   $0x0
  8008f0:	ff 75 08             	pushl  0x8(%ebp)
  8008f3:	e8 75 01 00 00       	call   800a6d <open>
  8008f8:	89 c3                	mov    %eax,%ebx
  8008fa:	83 c4 10             	add    $0x10,%esp
  8008fd:	85 c0                	test   %eax,%eax
  8008ff:	78 1d                	js     80091e <stat+0x38>
		return fd;
	r = fstat(fd, stat);
  800901:	83 ec 08             	sub    $0x8,%esp
  800904:	ff 75 0c             	pushl  0xc(%ebp)
  800907:	50                   	push   %eax
  800908:	e8 65 ff ff ff       	call   800872 <fstat>
  80090d:	89 c6                	mov    %eax,%esi
	close(fd);
  80090f:	89 1c 24             	mov    %ebx,(%esp)
  800912:	e8 1d fc ff ff       	call   800534 <close>
	return r;
  800917:	83 c4 10             	add    $0x10,%esp
  80091a:	89 f0                	mov    %esi,%eax
  80091c:	eb 00                	jmp    80091e <stat+0x38>
}
  80091e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800921:	5b                   	pop    %ebx
  800922:	5e                   	pop    %esi
  800923:	5d                   	pop    %ebp
  800924:	c3                   	ret    

00800925 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800925:	55                   	push   %ebp
  800926:	89 e5                	mov    %esp,%ebp
  800928:	56                   	push   %esi
  800929:	53                   	push   %ebx
  80092a:	89 c6                	mov    %eax,%esi
  80092c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80092e:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800935:	75 12                	jne    800949 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800937:	83 ec 0c             	sub    $0xc,%esp
  80093a:	6a 01                	push   $0x1
  80093c:	e8 ec 11 00 00       	call   801b2d <ipc_find_env>
  800941:	a3 00 40 80 00       	mov    %eax,0x804000
  800946:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800949:	6a 07                	push   $0x7
  80094b:	68 00 50 80 00       	push   $0x805000
  800950:	56                   	push   %esi
  800951:	ff 35 00 40 80 00    	pushl  0x804000
  800957:	e8 72 11 00 00       	call   801ace <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80095c:	83 c4 0c             	add    $0xc,%esp
  80095f:	6a 00                	push   $0x0
  800961:	53                   	push   %ebx
  800962:	6a 00                	push   $0x0
  800964:	e8 f0 10 00 00       	call   801a59 <ipc_recv>
}
  800969:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80096c:	5b                   	pop    %ebx
  80096d:	5e                   	pop    %esi
  80096e:	5d                   	pop    %ebp
  80096f:	c3                   	ret    

00800970 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
  800973:	53                   	push   %ebx
  800974:	83 ec 04             	sub    $0x4,%esp
  800977:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80097a:	8b 45 08             	mov    0x8(%ebp),%eax
  80097d:	8b 40 0c             	mov    0xc(%eax),%eax
  800980:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800985:	ba 00 00 00 00       	mov    $0x0,%edx
  80098a:	b8 05 00 00 00       	mov    $0x5,%eax
  80098f:	e8 91 ff ff ff       	call   800925 <fsipc>
  800994:	85 c0                	test   %eax,%eax
  800996:	78 2c                	js     8009c4 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800998:	83 ec 08             	sub    $0x8,%esp
  80099b:	68 00 50 80 00       	push   $0x805000
  8009a0:	53                   	push   %ebx
  8009a1:	e8 ff 0c 00 00       	call   8016a5 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009a6:	a1 80 50 80 00       	mov    0x805080,%eax
  8009ab:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009b1:	a1 84 50 80 00       	mov    0x805084,%eax
  8009b6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009bc:	83 c4 10             	add    $0x10,%esp
  8009bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009c7:	c9                   	leave  
  8009c8:	c3                   	ret    

008009c9 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009c9:	55                   	push   %ebp
  8009ca:	89 e5                	mov    %esp,%ebp
  8009cc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d2:	8b 40 0c             	mov    0xc(%eax),%eax
  8009d5:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009da:	ba 00 00 00 00       	mov    $0x0,%edx
  8009df:	b8 06 00 00 00       	mov    $0x6,%eax
  8009e4:	e8 3c ff ff ff       	call   800925 <fsipc>
}
  8009e9:	c9                   	leave  
  8009ea:	c3                   	ret    

008009eb <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8009eb:	55                   	push   %ebp
  8009ec:	89 e5                	mov    %esp,%ebp
  8009ee:	56                   	push   %esi
  8009ef:	53                   	push   %ebx
  8009f0:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8009f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f6:	8b 40 0c             	mov    0xc(%eax),%eax
  8009f9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8009fe:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a04:	ba 00 00 00 00       	mov    $0x0,%edx
  800a09:	b8 03 00 00 00       	mov    $0x3,%eax
  800a0e:	e8 12 ff ff ff       	call   800925 <fsipc>
  800a13:	89 c3                	mov    %eax,%ebx
  800a15:	85 c0                	test   %eax,%eax
  800a17:	78 4b                	js     800a64 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a19:	39 c6                	cmp    %eax,%esi
  800a1b:	73 16                	jae    800a33 <devfile_read+0x48>
  800a1d:	68 f2 1e 80 00       	push   $0x801ef2
  800a22:	68 f9 1e 80 00       	push   $0x801ef9
  800a27:	6a 7a                	push   $0x7a
  800a29:	68 0e 1f 80 00       	push   $0x801f0e
  800a2e:	e8 b5 05 00 00       	call   800fe8 <_panic>
	assert(r <= PGSIZE);
  800a33:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a38:	7e 16                	jle    800a50 <devfile_read+0x65>
  800a3a:	68 19 1f 80 00       	push   $0x801f19
  800a3f:	68 f9 1e 80 00       	push   $0x801ef9
  800a44:	6a 7b                	push   $0x7b
  800a46:	68 0e 1f 80 00       	push   $0x801f0e
  800a4b:	e8 98 05 00 00       	call   800fe8 <_panic>
	memmove(buf, &fsipcbuf, r);
  800a50:	83 ec 04             	sub    $0x4,%esp
  800a53:	50                   	push   %eax
  800a54:	68 00 50 80 00       	push   $0x805000
  800a59:	ff 75 0c             	pushl  0xc(%ebp)
  800a5c:	e8 11 0e 00 00       	call   801872 <memmove>
	return r;
  800a61:	83 c4 10             	add    $0x10,%esp
}
  800a64:	89 d8                	mov    %ebx,%eax
  800a66:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a69:	5b                   	pop    %ebx
  800a6a:	5e                   	pop    %esi
  800a6b:	5d                   	pop    %ebp
  800a6c:	c3                   	ret    

00800a6d <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800a6d:	55                   	push   %ebp
  800a6e:	89 e5                	mov    %esp,%ebp
  800a70:	53                   	push   %ebx
  800a71:	83 ec 20             	sub    $0x20,%esp
  800a74:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800a77:	53                   	push   %ebx
  800a78:	e8 d1 0b 00 00       	call   80164e <strlen>
  800a7d:	83 c4 10             	add    $0x10,%esp
  800a80:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800a85:	7f 63                	jg     800aea <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800a87:	83 ec 0c             	sub    $0xc,%esp
  800a8a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a8d:	50                   	push   %eax
  800a8e:	e8 e4 f8 ff ff       	call   800377 <fd_alloc>
  800a93:	83 c4 10             	add    $0x10,%esp
  800a96:	85 c0                	test   %eax,%eax
  800a98:	78 55                	js     800aef <open+0x82>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800a9a:	83 ec 08             	sub    $0x8,%esp
  800a9d:	53                   	push   %ebx
  800a9e:	68 00 50 80 00       	push   $0x805000
  800aa3:	e8 fd 0b 00 00       	call   8016a5 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800aa8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aab:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800ab0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ab3:	b8 01 00 00 00       	mov    $0x1,%eax
  800ab8:	e8 68 fe ff ff       	call   800925 <fsipc>
  800abd:	89 c3                	mov    %eax,%ebx
  800abf:	83 c4 10             	add    $0x10,%esp
  800ac2:	85 c0                	test   %eax,%eax
  800ac4:	79 14                	jns    800ada <open+0x6d>
		fd_close(fd, 0);
  800ac6:	83 ec 08             	sub    $0x8,%esp
  800ac9:	6a 00                	push   $0x0
  800acb:	ff 75 f4             	pushl  -0xc(%ebp)
  800ace:	e8 dd f9 ff ff       	call   8004b0 <fd_close>
		return r;
  800ad3:	83 c4 10             	add    $0x10,%esp
  800ad6:	89 d8                	mov    %ebx,%eax
  800ad8:	eb 15                	jmp    800aef <open+0x82>
	}

	return fd2num(fd);
  800ada:	83 ec 0c             	sub    $0xc,%esp
  800add:	ff 75 f4             	pushl  -0xc(%ebp)
  800ae0:	e8 6b f8 ff ff       	call   800350 <fd2num>
  800ae5:	83 c4 10             	add    $0x10,%esp
  800ae8:	eb 05                	jmp    800aef <open+0x82>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800aea:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800aef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800af2:	c9                   	leave  
  800af3:	c3                   	ret    

00800af4 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800af4:	55                   	push   %ebp
  800af5:	89 e5                	mov    %esp,%ebp
  800af7:	56                   	push   %esi
  800af8:	53                   	push   %ebx
  800af9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800afc:	83 ec 0c             	sub    $0xc,%esp
  800aff:	ff 75 08             	pushl  0x8(%ebp)
  800b02:	e8 59 f8 ff ff       	call   800360 <fd2data>
  800b07:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b09:	83 c4 08             	add    $0x8,%esp
  800b0c:	68 25 1f 80 00       	push   $0x801f25
  800b11:	53                   	push   %ebx
  800b12:	e8 8e 0b 00 00       	call   8016a5 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b17:	8b 46 04             	mov    0x4(%esi),%eax
  800b1a:	2b 06                	sub    (%esi),%eax
  800b1c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b22:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b29:	00 00 00 
	stat->st_dev = &devpipe;
  800b2c:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800b33:	30 80 00 
	return 0;
}
  800b36:	b8 00 00 00 00       	mov    $0x0,%eax
  800b3b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b3e:	5b                   	pop    %ebx
  800b3f:	5e                   	pop    %esi
  800b40:	5d                   	pop    %ebp
  800b41:	c3                   	ret    

00800b42 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b42:	55                   	push   %ebp
  800b43:	89 e5                	mov    %esp,%ebp
  800b45:	53                   	push   %ebx
  800b46:	83 ec 0c             	sub    $0xc,%esp
  800b49:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800b4c:	53                   	push   %ebx
  800b4d:	6a 00                	push   $0x0
  800b4f:	e8 90 f6 ff ff       	call   8001e4 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800b54:	89 1c 24             	mov    %ebx,(%esp)
  800b57:	e8 04 f8 ff ff       	call   800360 <fd2data>
  800b5c:	83 c4 08             	add    $0x8,%esp
  800b5f:	50                   	push   %eax
  800b60:	6a 00                	push   $0x0
  800b62:	e8 7d f6 ff ff       	call   8001e4 <sys_page_unmap>
}
  800b67:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b6a:	c9                   	leave  
  800b6b:	c3                   	ret    

00800b6c <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800b6c:	55                   	push   %ebp
  800b6d:	89 e5                	mov    %esp,%ebp
  800b6f:	57                   	push   %edi
  800b70:	56                   	push   %esi
  800b71:	53                   	push   %ebx
  800b72:	83 ec 1c             	sub    $0x1c,%esp
  800b75:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b78:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800b7a:	a1 04 40 80 00       	mov    0x804004,%eax
  800b7f:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800b82:	83 ec 0c             	sub    $0xc,%esp
  800b85:	ff 75 e0             	pushl  -0x20(%ebp)
  800b88:	e8 fb 0f 00 00       	call   801b88 <pageref>
  800b8d:	89 c3                	mov    %eax,%ebx
  800b8f:	89 3c 24             	mov    %edi,(%esp)
  800b92:	e8 f1 0f 00 00       	call   801b88 <pageref>
  800b97:	83 c4 10             	add    $0x10,%esp
  800b9a:	39 c3                	cmp    %eax,%ebx
  800b9c:	0f 94 c1             	sete   %cl
  800b9f:	0f b6 c9             	movzbl %cl,%ecx
  800ba2:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800ba5:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800bab:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800bae:	39 ce                	cmp    %ecx,%esi
  800bb0:	74 1b                	je     800bcd <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800bb2:	39 c3                	cmp    %eax,%ebx
  800bb4:	75 c4                	jne    800b7a <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800bb6:	8b 42 58             	mov    0x58(%edx),%eax
  800bb9:	ff 75 e4             	pushl  -0x1c(%ebp)
  800bbc:	50                   	push   %eax
  800bbd:	56                   	push   %esi
  800bbe:	68 2c 1f 80 00       	push   $0x801f2c
  800bc3:	e8 f8 04 00 00       	call   8010c0 <cprintf>
  800bc8:	83 c4 10             	add    $0x10,%esp
  800bcb:	eb ad                	jmp    800b7a <_pipeisclosed+0xe>
	}
}
  800bcd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800bd0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd3:	5b                   	pop    %ebx
  800bd4:	5e                   	pop    %esi
  800bd5:	5f                   	pop    %edi
  800bd6:	5d                   	pop    %ebp
  800bd7:	c3                   	ret    

00800bd8 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800bd8:	55                   	push   %ebp
  800bd9:	89 e5                	mov    %esp,%ebp
  800bdb:	57                   	push   %edi
  800bdc:	56                   	push   %esi
  800bdd:	53                   	push   %ebx
  800bde:	83 ec 18             	sub    $0x18,%esp
  800be1:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800be4:	56                   	push   %esi
  800be5:	e8 76 f7 ff ff       	call   800360 <fd2data>
  800bea:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800bec:	83 c4 10             	add    $0x10,%esp
  800bef:	bf 00 00 00 00       	mov    $0x0,%edi
  800bf4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800bf8:	75 42                	jne    800c3c <devpipe_write+0x64>
  800bfa:	eb 4e                	jmp    800c4a <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800bfc:	89 da                	mov    %ebx,%edx
  800bfe:	89 f0                	mov    %esi,%eax
  800c00:	e8 67 ff ff ff       	call   800b6c <_pipeisclosed>
  800c05:	85 c0                	test   %eax,%eax
  800c07:	75 46                	jne    800c4f <devpipe_write+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c09:	e8 32 f5 ff ff       	call   800140 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c0e:	8b 53 04             	mov    0x4(%ebx),%edx
  800c11:	8b 03                	mov    (%ebx),%eax
  800c13:	83 c0 20             	add    $0x20,%eax
  800c16:	39 c2                	cmp    %eax,%edx
  800c18:	73 e2                	jae    800bfc <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c1d:	8a 0c 38             	mov    (%eax,%edi,1),%cl
  800c20:	89 d0                	mov    %edx,%eax
  800c22:	25 1f 00 00 80       	and    $0x8000001f,%eax
  800c27:	79 05                	jns    800c2e <devpipe_write+0x56>
  800c29:	48                   	dec    %eax
  800c2a:	83 c8 e0             	or     $0xffffffe0,%eax
  800c2d:	40                   	inc    %eax
  800c2e:	88 4c 03 08          	mov    %cl,0x8(%ebx,%eax,1)
		p->p_wpos++;
  800c32:	42                   	inc    %edx
  800c33:	89 53 04             	mov    %edx,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c36:	47                   	inc    %edi
  800c37:	39 7d 10             	cmp    %edi,0x10(%ebp)
  800c3a:	74 0e                	je     800c4a <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c3c:	8b 53 04             	mov    0x4(%ebx),%edx
  800c3f:	8b 03                	mov    (%ebx),%eax
  800c41:	83 c0 20             	add    $0x20,%eax
  800c44:	39 c2                	cmp    %eax,%edx
  800c46:	73 b4                	jae    800bfc <devpipe_write+0x24>
  800c48:	eb d0                	jmp    800c1a <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800c4a:	8b 45 10             	mov    0x10(%ebp),%eax
  800c4d:	eb 05                	jmp    800c54 <devpipe_write+0x7c>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800c4f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800c54:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c57:	5b                   	pop    %ebx
  800c58:	5e                   	pop    %esi
  800c59:	5f                   	pop    %edi
  800c5a:	5d                   	pop    %ebp
  800c5b:	c3                   	ret    

00800c5c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800c5c:	55                   	push   %ebp
  800c5d:	89 e5                	mov    %esp,%ebp
  800c5f:	57                   	push   %edi
  800c60:	56                   	push   %esi
  800c61:	53                   	push   %ebx
  800c62:	83 ec 18             	sub    $0x18,%esp
  800c65:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800c68:	57                   	push   %edi
  800c69:	e8 f2 f6 ff ff       	call   800360 <fd2data>
  800c6e:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c70:	83 c4 10             	add    $0x10,%esp
  800c73:	be 00 00 00 00       	mov    $0x0,%esi
  800c78:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c7c:	75 3d                	jne    800cbb <devpipe_read+0x5f>
  800c7e:	eb 48                	jmp    800cc8 <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  800c80:	89 f0                	mov    %esi,%eax
  800c82:	eb 4e                	jmp    800cd2 <devpipe_read+0x76>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800c84:	89 da                	mov    %ebx,%edx
  800c86:	89 f8                	mov    %edi,%eax
  800c88:	e8 df fe ff ff       	call   800b6c <_pipeisclosed>
  800c8d:	85 c0                	test   %eax,%eax
  800c8f:	75 3c                	jne    800ccd <devpipe_read+0x71>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800c91:	e8 aa f4 ff ff       	call   800140 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800c96:	8b 03                	mov    (%ebx),%eax
  800c98:	3b 43 04             	cmp    0x4(%ebx),%eax
  800c9b:	74 e7                	je     800c84 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800c9d:	25 1f 00 00 80       	and    $0x8000001f,%eax
  800ca2:	79 05                	jns    800ca9 <devpipe_read+0x4d>
  800ca4:	48                   	dec    %eax
  800ca5:	83 c8 e0             	or     $0xffffffe0,%eax
  800ca8:	40                   	inc    %eax
  800ca9:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  800cad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb0:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800cb3:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cb5:	46                   	inc    %esi
  800cb6:	39 75 10             	cmp    %esi,0x10(%ebp)
  800cb9:	74 0d                	je     800cc8 <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
  800cbb:	8b 03                	mov    (%ebx),%eax
  800cbd:	3b 43 04             	cmp    0x4(%ebx),%eax
  800cc0:	75 db                	jne    800c9d <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800cc2:	85 f6                	test   %esi,%esi
  800cc4:	75 ba                	jne    800c80 <devpipe_read+0x24>
  800cc6:	eb bc                	jmp    800c84 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800cc8:	8b 45 10             	mov    0x10(%ebp),%eax
  800ccb:	eb 05                	jmp    800cd2 <devpipe_read+0x76>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800ccd:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800cd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd5:	5b                   	pop    %ebx
  800cd6:	5e                   	pop    %esi
  800cd7:	5f                   	pop    %edi
  800cd8:	5d                   	pop    %ebp
  800cd9:	c3                   	ret    

00800cda <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800cda:	55                   	push   %ebp
  800cdb:	89 e5                	mov    %esp,%ebp
  800cdd:	56                   	push   %esi
  800cde:	53                   	push   %ebx
  800cdf:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800ce2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ce5:	50                   	push   %eax
  800ce6:	e8 8c f6 ff ff       	call   800377 <fd_alloc>
  800ceb:	83 c4 10             	add    $0x10,%esp
  800cee:	85 c0                	test   %eax,%eax
  800cf0:	0f 88 2a 01 00 00    	js     800e20 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800cf6:	83 ec 04             	sub    $0x4,%esp
  800cf9:	68 07 04 00 00       	push   $0x407
  800cfe:	ff 75 f4             	pushl  -0xc(%ebp)
  800d01:	6a 00                	push   $0x0
  800d03:	e8 57 f4 ff ff       	call   80015f <sys_page_alloc>
  800d08:	83 c4 10             	add    $0x10,%esp
  800d0b:	85 c0                	test   %eax,%eax
  800d0d:	0f 88 0d 01 00 00    	js     800e20 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d13:	83 ec 0c             	sub    $0xc,%esp
  800d16:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d19:	50                   	push   %eax
  800d1a:	e8 58 f6 ff ff       	call   800377 <fd_alloc>
  800d1f:	89 c3                	mov    %eax,%ebx
  800d21:	83 c4 10             	add    $0x10,%esp
  800d24:	85 c0                	test   %eax,%eax
  800d26:	0f 88 e2 00 00 00    	js     800e0e <pipe+0x134>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d2c:	83 ec 04             	sub    $0x4,%esp
  800d2f:	68 07 04 00 00       	push   $0x407
  800d34:	ff 75 f0             	pushl  -0x10(%ebp)
  800d37:	6a 00                	push   $0x0
  800d39:	e8 21 f4 ff ff       	call   80015f <sys_page_alloc>
  800d3e:	89 c3                	mov    %eax,%ebx
  800d40:	83 c4 10             	add    $0x10,%esp
  800d43:	85 c0                	test   %eax,%eax
  800d45:	0f 88 c3 00 00 00    	js     800e0e <pipe+0x134>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800d4b:	83 ec 0c             	sub    $0xc,%esp
  800d4e:	ff 75 f4             	pushl  -0xc(%ebp)
  800d51:	e8 0a f6 ff ff       	call   800360 <fd2data>
  800d56:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d58:	83 c4 0c             	add    $0xc,%esp
  800d5b:	68 07 04 00 00       	push   $0x407
  800d60:	50                   	push   %eax
  800d61:	6a 00                	push   $0x0
  800d63:	e8 f7 f3 ff ff       	call   80015f <sys_page_alloc>
  800d68:	89 c3                	mov    %eax,%ebx
  800d6a:	83 c4 10             	add    $0x10,%esp
  800d6d:	85 c0                	test   %eax,%eax
  800d6f:	0f 88 89 00 00 00    	js     800dfe <pipe+0x124>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d75:	83 ec 0c             	sub    $0xc,%esp
  800d78:	ff 75 f0             	pushl  -0x10(%ebp)
  800d7b:	e8 e0 f5 ff ff       	call   800360 <fd2data>
  800d80:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800d87:	50                   	push   %eax
  800d88:	6a 00                	push   $0x0
  800d8a:	56                   	push   %esi
  800d8b:	6a 00                	push   $0x0
  800d8d:	e8 10 f4 ff ff       	call   8001a2 <sys_page_map>
  800d92:	89 c3                	mov    %eax,%ebx
  800d94:	83 c4 20             	add    $0x20,%esp
  800d97:	85 c0                	test   %eax,%eax
  800d99:	78 55                	js     800df0 <pipe+0x116>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800d9b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800da1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800da4:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800da6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800da9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800db0:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800db6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800db9:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800dbb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dbe:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800dc5:	83 ec 0c             	sub    $0xc,%esp
  800dc8:	ff 75 f4             	pushl  -0xc(%ebp)
  800dcb:	e8 80 f5 ff ff       	call   800350 <fd2num>
  800dd0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dd3:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800dd5:	83 c4 04             	add    $0x4,%esp
  800dd8:	ff 75 f0             	pushl  -0x10(%ebp)
  800ddb:	e8 70 f5 ff ff       	call   800350 <fd2num>
  800de0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800de3:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800de6:	83 c4 10             	add    $0x10,%esp
  800de9:	b8 00 00 00 00       	mov    $0x0,%eax
  800dee:	eb 30                	jmp    800e20 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  800df0:	83 ec 08             	sub    $0x8,%esp
  800df3:	56                   	push   %esi
  800df4:	6a 00                	push   $0x0
  800df6:	e8 e9 f3 ff ff       	call   8001e4 <sys_page_unmap>
  800dfb:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800dfe:	83 ec 08             	sub    $0x8,%esp
  800e01:	ff 75 f0             	pushl  -0x10(%ebp)
  800e04:	6a 00                	push   $0x0
  800e06:	e8 d9 f3 ff ff       	call   8001e4 <sys_page_unmap>
  800e0b:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e0e:	83 ec 08             	sub    $0x8,%esp
  800e11:	ff 75 f4             	pushl  -0xc(%ebp)
  800e14:	6a 00                	push   $0x0
  800e16:	e8 c9 f3 ff ff       	call   8001e4 <sys_page_unmap>
  800e1b:	83 c4 10             	add    $0x10,%esp
  800e1e:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  800e20:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e23:	5b                   	pop    %ebx
  800e24:	5e                   	pop    %esi
  800e25:	5d                   	pop    %ebp
  800e26:	c3                   	ret    

00800e27 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e27:	55                   	push   %ebp
  800e28:	89 e5                	mov    %esp,%ebp
  800e2a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e2d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e30:	50                   	push   %eax
  800e31:	ff 75 08             	pushl  0x8(%ebp)
  800e34:	e8 b2 f5 ff ff       	call   8003eb <fd_lookup>
  800e39:	83 c4 10             	add    $0x10,%esp
  800e3c:	85 c0                	test   %eax,%eax
  800e3e:	78 18                	js     800e58 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800e40:	83 ec 0c             	sub    $0xc,%esp
  800e43:	ff 75 f4             	pushl  -0xc(%ebp)
  800e46:	e8 15 f5 ff ff       	call   800360 <fd2data>
	return _pipeisclosed(fd, p);
  800e4b:	89 c2                	mov    %eax,%edx
  800e4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e50:	e8 17 fd ff ff       	call   800b6c <_pipeisclosed>
  800e55:	83 c4 10             	add    $0x10,%esp
}
  800e58:	c9                   	leave  
  800e59:	c3                   	ret    

00800e5a <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800e5a:	55                   	push   %ebp
  800e5b:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800e5d:	b8 00 00 00 00       	mov    $0x0,%eax
  800e62:	5d                   	pop    %ebp
  800e63:	c3                   	ret    

00800e64 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800e64:	55                   	push   %ebp
  800e65:	89 e5                	mov    %esp,%ebp
  800e67:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800e6a:	68 44 1f 80 00       	push   $0x801f44
  800e6f:	ff 75 0c             	pushl  0xc(%ebp)
  800e72:	e8 2e 08 00 00       	call   8016a5 <strcpy>
	return 0;
}
  800e77:	b8 00 00 00 00       	mov    $0x0,%eax
  800e7c:	c9                   	leave  
  800e7d:	c3                   	ret    

00800e7e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800e7e:	55                   	push   %ebp
  800e7f:	89 e5                	mov    %esp,%ebp
  800e81:	57                   	push   %edi
  800e82:	56                   	push   %esi
  800e83:	53                   	push   %ebx
  800e84:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800e8a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e8e:	74 45                	je     800ed5 <devcons_write+0x57>
  800e90:	b8 00 00 00 00       	mov    $0x0,%eax
  800e95:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800e9a:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800ea0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ea3:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  800ea5:	83 fb 7f             	cmp    $0x7f,%ebx
  800ea8:	76 05                	jbe    800eaf <devcons_write+0x31>
			m = sizeof(buf) - 1;
  800eaa:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800eaf:	83 ec 04             	sub    $0x4,%esp
  800eb2:	53                   	push   %ebx
  800eb3:	03 45 0c             	add    0xc(%ebp),%eax
  800eb6:	50                   	push   %eax
  800eb7:	57                   	push   %edi
  800eb8:	e8 b5 09 00 00       	call   801872 <memmove>
		sys_cputs(buf, m);
  800ebd:	83 c4 08             	add    $0x8,%esp
  800ec0:	53                   	push   %ebx
  800ec1:	57                   	push   %edi
  800ec2:	e8 dc f1 ff ff       	call   8000a3 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ec7:	01 de                	add    %ebx,%esi
  800ec9:	89 f0                	mov    %esi,%eax
  800ecb:	83 c4 10             	add    $0x10,%esp
  800ece:	3b 75 10             	cmp    0x10(%ebp),%esi
  800ed1:	72 cd                	jb     800ea0 <devcons_write+0x22>
  800ed3:	eb 05                	jmp    800eda <devcons_write+0x5c>
  800ed5:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800eda:	89 f0                	mov    %esi,%eax
  800edc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800edf:	5b                   	pop    %ebx
  800ee0:	5e                   	pop    %esi
  800ee1:	5f                   	pop    %edi
  800ee2:	5d                   	pop    %ebp
  800ee3:	c3                   	ret    

00800ee4 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800ee4:	55                   	push   %ebp
  800ee5:	89 e5                	mov    %esp,%ebp
  800ee7:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  800eea:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800eee:	75 07                	jne    800ef7 <devcons_read+0x13>
  800ef0:	eb 23                	jmp    800f15 <devcons_read+0x31>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800ef2:	e8 49 f2 ff ff       	call   800140 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800ef7:	e8 c5 f1 ff ff       	call   8000c1 <sys_cgetc>
  800efc:	85 c0                	test   %eax,%eax
  800efe:	74 f2                	je     800ef2 <devcons_read+0xe>
		sys_yield();
	if (c < 0)
  800f00:	85 c0                	test   %eax,%eax
  800f02:	78 1d                	js     800f21 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f04:	83 f8 04             	cmp    $0x4,%eax
  800f07:	74 13                	je     800f1c <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  800f09:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f0c:	88 02                	mov    %al,(%edx)
	return 1;
  800f0e:	b8 01 00 00 00       	mov    $0x1,%eax
  800f13:	eb 0c                	jmp    800f21 <devcons_read+0x3d>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  800f15:	b8 00 00 00 00       	mov    $0x0,%eax
  800f1a:	eb 05                	jmp    800f21 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f1c:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f21:	c9                   	leave  
  800f22:	c3                   	ret    

00800f23 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f23:	55                   	push   %ebp
  800f24:	89 e5                	mov    %esp,%ebp
  800f26:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f29:	8b 45 08             	mov    0x8(%ebp),%eax
  800f2c:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f2f:	6a 01                	push   $0x1
  800f31:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f34:	50                   	push   %eax
  800f35:	e8 69 f1 ff ff       	call   8000a3 <sys_cputs>
}
  800f3a:	83 c4 10             	add    $0x10,%esp
  800f3d:	c9                   	leave  
  800f3e:	c3                   	ret    

00800f3f <getchar>:

int
getchar(void)
{
  800f3f:	55                   	push   %ebp
  800f40:	89 e5                	mov    %esp,%ebp
  800f42:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f45:	6a 01                	push   $0x1
  800f47:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f4a:	50                   	push   %eax
  800f4b:	6a 00                	push   $0x0
  800f4d:	e8 1a f7 ff ff       	call   80066c <read>
	if (r < 0)
  800f52:	83 c4 10             	add    $0x10,%esp
  800f55:	85 c0                	test   %eax,%eax
  800f57:	78 0f                	js     800f68 <getchar+0x29>
		return r;
	if (r < 1)
  800f59:	85 c0                	test   %eax,%eax
  800f5b:	7e 06                	jle    800f63 <getchar+0x24>
		return -E_EOF;
	return c;
  800f5d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800f61:	eb 05                	jmp    800f68 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800f63:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800f68:	c9                   	leave  
  800f69:	c3                   	ret    

00800f6a <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800f6a:	55                   	push   %ebp
  800f6b:	89 e5                	mov    %esp,%ebp
  800f6d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f70:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f73:	50                   	push   %eax
  800f74:	ff 75 08             	pushl  0x8(%ebp)
  800f77:	e8 6f f4 ff ff       	call   8003eb <fd_lookup>
  800f7c:	83 c4 10             	add    $0x10,%esp
  800f7f:	85 c0                	test   %eax,%eax
  800f81:	78 11                	js     800f94 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800f83:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f86:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800f8c:	39 10                	cmp    %edx,(%eax)
  800f8e:	0f 94 c0             	sete   %al
  800f91:	0f b6 c0             	movzbl %al,%eax
}
  800f94:	c9                   	leave  
  800f95:	c3                   	ret    

00800f96 <opencons>:

int
opencons(void)
{
  800f96:	55                   	push   %ebp
  800f97:	89 e5                	mov    %esp,%ebp
  800f99:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800f9c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f9f:	50                   	push   %eax
  800fa0:	e8 d2 f3 ff ff       	call   800377 <fd_alloc>
  800fa5:	83 c4 10             	add    $0x10,%esp
  800fa8:	85 c0                	test   %eax,%eax
  800faa:	78 3a                	js     800fe6 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fac:	83 ec 04             	sub    $0x4,%esp
  800faf:	68 07 04 00 00       	push   $0x407
  800fb4:	ff 75 f4             	pushl  -0xc(%ebp)
  800fb7:	6a 00                	push   $0x0
  800fb9:	e8 a1 f1 ff ff       	call   80015f <sys_page_alloc>
  800fbe:	83 c4 10             	add    $0x10,%esp
  800fc1:	85 c0                	test   %eax,%eax
  800fc3:	78 21                	js     800fe6 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800fc5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fce:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800fd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fd3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800fda:	83 ec 0c             	sub    $0xc,%esp
  800fdd:	50                   	push   %eax
  800fde:	e8 6d f3 ff ff       	call   800350 <fd2num>
  800fe3:	83 c4 10             	add    $0x10,%esp
}
  800fe6:	c9                   	leave  
  800fe7:	c3                   	ret    

00800fe8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800fe8:	55                   	push   %ebp
  800fe9:	89 e5                	mov    %esp,%ebp
  800feb:	56                   	push   %esi
  800fec:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800fed:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800ff0:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800ff6:	e8 26 f1 ff ff       	call   800121 <sys_getenvid>
  800ffb:	83 ec 0c             	sub    $0xc,%esp
  800ffe:	ff 75 0c             	pushl  0xc(%ebp)
  801001:	ff 75 08             	pushl  0x8(%ebp)
  801004:	56                   	push   %esi
  801005:	50                   	push   %eax
  801006:	68 50 1f 80 00       	push   $0x801f50
  80100b:	e8 b0 00 00 00       	call   8010c0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801010:	83 c4 18             	add    $0x18,%esp
  801013:	53                   	push   %ebx
  801014:	ff 75 10             	pushl  0x10(%ebp)
  801017:	e8 53 00 00 00       	call   80106f <vcprintf>
	cprintf("\n");
  80101c:	c7 04 24 3d 1f 80 00 	movl   $0x801f3d,(%esp)
  801023:	e8 98 00 00 00       	call   8010c0 <cprintf>
  801028:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80102b:	cc                   	int3   
  80102c:	eb fd                	jmp    80102b <_panic+0x43>

0080102e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80102e:	55                   	push   %ebp
  80102f:	89 e5                	mov    %esp,%ebp
  801031:	53                   	push   %ebx
  801032:	83 ec 04             	sub    $0x4,%esp
  801035:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801038:	8b 13                	mov    (%ebx),%edx
  80103a:	8d 42 01             	lea    0x1(%edx),%eax
  80103d:	89 03                	mov    %eax,(%ebx)
  80103f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801042:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801046:	3d ff 00 00 00       	cmp    $0xff,%eax
  80104b:	75 1a                	jne    801067 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80104d:	83 ec 08             	sub    $0x8,%esp
  801050:	68 ff 00 00 00       	push   $0xff
  801055:	8d 43 08             	lea    0x8(%ebx),%eax
  801058:	50                   	push   %eax
  801059:	e8 45 f0 ff ff       	call   8000a3 <sys_cputs>
		b->idx = 0;
  80105e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801064:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801067:	ff 43 04             	incl   0x4(%ebx)
}
  80106a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80106d:	c9                   	leave  
  80106e:	c3                   	ret    

0080106f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80106f:	55                   	push   %ebp
  801070:	89 e5                	mov    %esp,%ebp
  801072:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801078:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80107f:	00 00 00 
	b.cnt = 0;
  801082:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801089:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80108c:	ff 75 0c             	pushl  0xc(%ebp)
  80108f:	ff 75 08             	pushl  0x8(%ebp)
  801092:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801098:	50                   	push   %eax
  801099:	68 2e 10 80 00       	push   $0x80102e
  80109e:	e8 54 01 00 00       	call   8011f7 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010a3:	83 c4 08             	add    $0x8,%esp
  8010a6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010ac:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010b2:	50                   	push   %eax
  8010b3:	e8 eb ef ff ff       	call   8000a3 <sys_cputs>

	return b.cnt;
}
  8010b8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8010be:	c9                   	leave  
  8010bf:	c3                   	ret    

008010c0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8010c0:	55                   	push   %ebp
  8010c1:	89 e5                	mov    %esp,%ebp
  8010c3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8010c6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8010c9:	50                   	push   %eax
  8010ca:	ff 75 08             	pushl  0x8(%ebp)
  8010cd:	e8 9d ff ff ff       	call   80106f <vcprintf>
	va_end(ap);

	return cnt;
}
  8010d2:	c9                   	leave  
  8010d3:	c3                   	ret    

008010d4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8010d4:	55                   	push   %ebp
  8010d5:	89 e5                	mov    %esp,%ebp
  8010d7:	57                   	push   %edi
  8010d8:	56                   	push   %esi
  8010d9:	53                   	push   %ebx
  8010da:	83 ec 1c             	sub    $0x1c,%esp
  8010dd:	89 c6                	mov    %eax,%esi
  8010df:	89 d7                	mov    %edx,%edi
  8010e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010e7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8010ea:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8010ed:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8010f0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010f5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8010f8:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8010fb:	39 d3                	cmp    %edx,%ebx
  8010fd:	72 11                	jb     801110 <printnum+0x3c>
  8010ff:	39 45 10             	cmp    %eax,0x10(%ebp)
  801102:	76 0c                	jbe    801110 <printnum+0x3c>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801104:	8b 45 14             	mov    0x14(%ebp),%eax
  801107:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80110a:	85 db                	test   %ebx,%ebx
  80110c:	7f 37                	jg     801145 <printnum+0x71>
  80110e:	eb 44                	jmp    801154 <printnum+0x80>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801110:	83 ec 0c             	sub    $0xc,%esp
  801113:	ff 75 18             	pushl  0x18(%ebp)
  801116:	8b 45 14             	mov    0x14(%ebp),%eax
  801119:	48                   	dec    %eax
  80111a:	50                   	push   %eax
  80111b:	ff 75 10             	pushl  0x10(%ebp)
  80111e:	83 ec 08             	sub    $0x8,%esp
  801121:	ff 75 e4             	pushl  -0x1c(%ebp)
  801124:	ff 75 e0             	pushl  -0x20(%ebp)
  801127:	ff 75 dc             	pushl  -0x24(%ebp)
  80112a:	ff 75 d8             	pushl  -0x28(%ebp)
  80112d:	e8 9a 0a 00 00       	call   801bcc <__udivdi3>
  801132:	83 c4 18             	add    $0x18,%esp
  801135:	52                   	push   %edx
  801136:	50                   	push   %eax
  801137:	89 fa                	mov    %edi,%edx
  801139:	89 f0                	mov    %esi,%eax
  80113b:	e8 94 ff ff ff       	call   8010d4 <printnum>
  801140:	83 c4 20             	add    $0x20,%esp
  801143:	eb 0f                	jmp    801154 <printnum+0x80>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801145:	83 ec 08             	sub    $0x8,%esp
  801148:	57                   	push   %edi
  801149:	ff 75 18             	pushl  0x18(%ebp)
  80114c:	ff d6                	call   *%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80114e:	83 c4 10             	add    $0x10,%esp
  801151:	4b                   	dec    %ebx
  801152:	75 f1                	jne    801145 <printnum+0x71>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801154:	83 ec 08             	sub    $0x8,%esp
  801157:	57                   	push   %edi
  801158:	83 ec 04             	sub    $0x4,%esp
  80115b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80115e:	ff 75 e0             	pushl  -0x20(%ebp)
  801161:	ff 75 dc             	pushl  -0x24(%ebp)
  801164:	ff 75 d8             	pushl  -0x28(%ebp)
  801167:	e8 70 0b 00 00       	call   801cdc <__umoddi3>
  80116c:	83 c4 14             	add    $0x14,%esp
  80116f:	0f be 80 73 1f 80 00 	movsbl 0x801f73(%eax),%eax
  801176:	50                   	push   %eax
  801177:	ff d6                	call   *%esi
}
  801179:	83 c4 10             	add    $0x10,%esp
  80117c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80117f:	5b                   	pop    %ebx
  801180:	5e                   	pop    %esi
  801181:	5f                   	pop    %edi
  801182:	5d                   	pop    %ebp
  801183:	c3                   	ret    

00801184 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801184:	55                   	push   %ebp
  801185:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801187:	83 fa 01             	cmp    $0x1,%edx
  80118a:	7e 0e                	jle    80119a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80118c:	8b 10                	mov    (%eax),%edx
  80118e:	8d 4a 08             	lea    0x8(%edx),%ecx
  801191:	89 08                	mov    %ecx,(%eax)
  801193:	8b 02                	mov    (%edx),%eax
  801195:	8b 52 04             	mov    0x4(%edx),%edx
  801198:	eb 22                	jmp    8011bc <getuint+0x38>
	else if (lflag)
  80119a:	85 d2                	test   %edx,%edx
  80119c:	74 10                	je     8011ae <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80119e:	8b 10                	mov    (%eax),%edx
  8011a0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011a3:	89 08                	mov    %ecx,(%eax)
  8011a5:	8b 02                	mov    (%edx),%eax
  8011a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8011ac:	eb 0e                	jmp    8011bc <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8011ae:	8b 10                	mov    (%eax),%edx
  8011b0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011b3:	89 08                	mov    %ecx,(%eax)
  8011b5:	8b 02                	mov    (%edx),%eax
  8011b7:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8011bc:	5d                   	pop    %ebp
  8011bd:	c3                   	ret    

008011be <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011be:	55                   	push   %ebp
  8011bf:	89 e5                	mov    %esp,%ebp
  8011c1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011c4:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8011c7:	8b 10                	mov    (%eax),%edx
  8011c9:	3b 50 04             	cmp    0x4(%eax),%edx
  8011cc:	73 0a                	jae    8011d8 <sprintputch+0x1a>
		*b->buf++ = ch;
  8011ce:	8d 4a 01             	lea    0x1(%edx),%ecx
  8011d1:	89 08                	mov    %ecx,(%eax)
  8011d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d6:	88 02                	mov    %al,(%edx)
}
  8011d8:	5d                   	pop    %ebp
  8011d9:	c3                   	ret    

008011da <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8011da:	55                   	push   %ebp
  8011db:	89 e5                	mov    %esp,%ebp
  8011dd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8011e0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8011e3:	50                   	push   %eax
  8011e4:	ff 75 10             	pushl  0x10(%ebp)
  8011e7:	ff 75 0c             	pushl  0xc(%ebp)
  8011ea:	ff 75 08             	pushl  0x8(%ebp)
  8011ed:	e8 05 00 00 00       	call   8011f7 <vprintfmt>
	va_end(ap);
}
  8011f2:	83 c4 10             	add    $0x10,%esp
  8011f5:	c9                   	leave  
  8011f6:	c3                   	ret    

008011f7 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8011f7:	55                   	push   %ebp
  8011f8:	89 e5                	mov    %esp,%ebp
  8011fa:	57                   	push   %edi
  8011fb:	56                   	push   %esi
  8011fc:	53                   	push   %ebx
  8011fd:	83 ec 2c             	sub    $0x2c,%esp
  801200:	8b 7d 08             	mov    0x8(%ebp),%edi
  801203:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801206:	eb 03                	jmp    80120b <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  801208:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  80120b:	8b 45 10             	mov    0x10(%ebp),%eax
  80120e:	8d 70 01             	lea    0x1(%eax),%esi
  801211:	0f b6 00             	movzbl (%eax),%eax
  801214:	83 f8 25             	cmp    $0x25,%eax
  801217:	74 25                	je     80123e <vprintfmt+0x47>
			if (ch == '\0')									//当然中间如果遇到'\0'，代表这个字符串的访问结束
  801219:	85 c0                	test   %eax,%eax
  80121b:	75 0d                	jne    80122a <vprintfmt+0x33>
  80121d:	e9 b5 03 00 00       	jmp    8015d7 <vprintfmt+0x3e0>
  801222:	85 c0                	test   %eax,%eax
  801224:	0f 84 ad 03 00 00    	je     8015d7 <vprintfmt+0x3e0>
				return;
			putch(ch, putdat);								//调用putch函数，把一个字符ch输出到putdat指针所指向的地址中所存放的值对应的地址处
  80122a:	83 ec 08             	sub    $0x8,%esp
  80122d:	53                   	push   %ebx
  80122e:	50                   	push   %eax
  80122f:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  801231:	46                   	inc    %esi
  801232:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  801236:	83 c4 10             	add    $0x10,%esp
  801239:	83 f8 25             	cmp    $0x25,%eax
  80123c:	75 e4                	jne    801222 <vprintfmt+0x2b>
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  80123e:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  801242:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801249:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801250:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  801257:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80125e:	eb 07                	jmp    801267 <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  801260:	8b 75 10             	mov    0x10(%ebp),%esi

		// flag to pad on the right
		case '-':											//%后面的'-'代表要进行左对齐输出，右边填空格，如果省略代表右对齐
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
  801263:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  801267:	8d 46 01             	lea    0x1(%esi),%eax
  80126a:	89 45 10             	mov    %eax,0x10(%ebp)
  80126d:	0f b6 16             	movzbl (%esi),%edx
  801270:	8a 06                	mov    (%esi),%al
  801272:	83 e8 23             	sub    $0x23,%eax
  801275:	3c 55                	cmp    $0x55,%al
  801277:	0f 87 03 03 00 00    	ja     801580 <vprintfmt+0x389>
  80127d:	0f b6 c0             	movzbl %al,%eax
  801280:	ff 24 85 c0 20 80 00 	jmp    *0x8020c0(,%eax,4)
  801287:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
			goto reswitch;									//处理下一个字符

		// flag to pad with 0's instead of spaces
		case '0':											//0--有0表示进行对齐输出时填0,如省略表示填入空格，并且如果为0，则一定是右对齐
			padc = '0';										//对其方式标志位变为0
  80128a:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  80128e:	eb d7                	jmp    801267 <vprintfmt+0x70>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
				precision = precision * 10 + ch - '0';
  801290:	8d 42 d0             	lea    -0x30(%edx),%eax
  801293:	89 c1                	mov    %eax,%ecx
  801295:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  801298:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  80129c:	8d 50 d0             	lea    -0x30(%eax),%edx
  80129f:	83 fa 09             	cmp    $0x9,%edx
  8012a2:	77 51                	ja     8012f5 <vprintfmt+0xfe>
  8012a4:	8b 75 10             	mov    0x10(%ebp),%esi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
  8012a7:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8012a8:	8d 14 89             	lea    (%ecx,%ecx,4),%edx
  8012ab:	01 d2                	add    %edx,%edx
  8012ad:	8d 4c 10 d0          	lea    -0x30(%eax,%edx,1),%ecx
				ch = *fmt;
  8012b1:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8012b4:	8d 50 d0             	lea    -0x30(%eax),%edx
  8012b7:	83 fa 09             	cmp    $0x9,%edx
  8012ba:	76 eb                	jbe    8012a7 <vprintfmt+0xb0>
  8012bc:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8012bf:	eb 37                	jmp    8012f8 <vprintfmt+0x101>
					break;
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
  8012c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8012c4:	8d 50 04             	lea    0x4(%eax),%edx
  8012c7:	89 55 14             	mov    %edx,0x14(%ebp)
  8012ca:	8b 00                	mov    (%eax),%eax
  8012cc:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8012cf:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
			goto process_precision;
  8012d2:	eb 24                	jmp    8012f8 <vprintfmt+0x101>
  8012d4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8012d8:	79 07                	jns    8012e1 <vprintfmt+0xea>
  8012da:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8012e1:	8b 75 10             	mov    0x10(%ebp),%esi
  8012e4:	eb 81                	jmp    801267 <vprintfmt+0x70>
  8012e6:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  8012e9:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8012f0:	e9 72 ff ff ff       	jmp    801267 <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8012f5:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:									//处理输出精度，把width字段赋值为刚刚计算出来的precision值，所以width应该是整数部分的有效数字位数
			if (width < 0)
  8012f8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8012fc:	0f 89 65 ff ff ff    	jns    801267 <vprintfmt+0x70>
				width = precision, precision = -1;
  801302:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801305:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801308:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80130f:	e9 53 ff ff ff       	jmp    801267 <vprintfmt+0x70>
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
  801314:	ff 45 d4             	incl   -0x2c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  801317:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
			goto reswitch;
  80131a:	e9 48 ff ff ff       	jmp    801267 <vprintfmt+0x70>

		// character
		case 'c':											//如果是'c'代表显示一个字符
			putch(va_arg(ap, int), putdat);					//调用输出一个字符到内存的函数putch
  80131f:	8b 45 14             	mov    0x14(%ebp),%eax
  801322:	8d 50 04             	lea    0x4(%eax),%edx
  801325:	89 55 14             	mov    %edx,0x14(%ebp)
  801328:	83 ec 08             	sub    $0x8,%esp
  80132b:	53                   	push   %ebx
  80132c:	ff 30                	pushl  (%eax)
  80132e:	ff d7                	call   *%edi
			break;
  801330:	83 c4 10             	add    $0x10,%esp
  801333:	e9 d3 fe ff ff       	jmp    80120b <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801338:	8b 45 14             	mov    0x14(%ebp),%eax
  80133b:	8d 50 04             	lea    0x4(%eax),%edx
  80133e:	89 55 14             	mov    %edx,0x14(%ebp)
  801341:	8b 00                	mov    (%eax),%eax
  801343:	85 c0                	test   %eax,%eax
  801345:	79 02                	jns    801349 <vprintfmt+0x152>
  801347:	f7 d8                	neg    %eax
  801349:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80134b:	83 f8 0f             	cmp    $0xf,%eax
  80134e:	7f 0b                	jg     80135b <vprintfmt+0x164>
  801350:	8b 04 85 20 22 80 00 	mov    0x802220(,%eax,4),%eax
  801357:	85 c0                	test   %eax,%eax
  801359:	75 15                	jne    801370 <vprintfmt+0x179>
				printfmt(putch, putdat, "error %d", err);
  80135b:	52                   	push   %edx
  80135c:	68 8b 1f 80 00       	push   $0x801f8b
  801361:	53                   	push   %ebx
  801362:	57                   	push   %edi
  801363:	e8 72 fe ff ff       	call   8011da <printfmt>
  801368:	83 c4 10             	add    $0x10,%esp
  80136b:	e9 9b fe ff ff       	jmp    80120b <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  801370:	50                   	push   %eax
  801371:	68 0b 1f 80 00       	push   $0x801f0b
  801376:	53                   	push   %ebx
  801377:	57                   	push   %edi
  801378:	e8 5d fe ff ff       	call   8011da <printfmt>
  80137d:	83 c4 10             	add    $0x10,%esp
  801380:	e9 86 fe ff ff       	jmp    80120b <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801385:	8b 45 14             	mov    0x14(%ebp),%eax
  801388:	8d 50 04             	lea    0x4(%eax),%edx
  80138b:	89 55 14             	mov    %edx,0x14(%ebp)
  80138e:	8b 00                	mov    (%eax),%eax
  801390:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  801393:	85 c0                	test   %eax,%eax
  801395:	75 07                	jne    80139e <vprintfmt+0x1a7>
				p = "(null)";
  801397:	c7 45 d4 84 1f 80 00 	movl   $0x801f84,-0x2c(%ebp)
			if (width > 0 && padc != '-')
  80139e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8013a1:	85 f6                	test   %esi,%esi
  8013a3:	0f 8e fb 01 00 00    	jle    8015a4 <vprintfmt+0x3ad>
  8013a9:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  8013ad:	0f 84 09 02 00 00    	je     8015bc <vprintfmt+0x3c5>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013b3:	83 ec 08             	sub    $0x8,%esp
  8013b6:	ff 75 d0             	pushl  -0x30(%ebp)
  8013b9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013bc:	e8 ad 02 00 00       	call   80166e <strnlen>
  8013c1:	89 f1                	mov    %esi,%ecx
  8013c3:	29 c1                	sub    %eax,%ecx
  8013c5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8013c8:	83 c4 10             	add    $0x10,%esp
  8013cb:	85 c9                	test   %ecx,%ecx
  8013cd:	0f 8e d1 01 00 00    	jle    8015a4 <vprintfmt+0x3ad>
					putch(padc, putdat);
  8013d3:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8013d7:	83 ec 08             	sub    $0x8,%esp
  8013da:	53                   	push   %ebx
  8013db:	56                   	push   %esi
  8013dc:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013de:	83 c4 10             	add    $0x10,%esp
  8013e1:	ff 4d e4             	decl   -0x1c(%ebp)
  8013e4:	75 f1                	jne    8013d7 <vprintfmt+0x1e0>
  8013e6:	e9 b9 01 00 00       	jmp    8015a4 <vprintfmt+0x3ad>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8013eb:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8013ef:	74 19                	je     80140a <vprintfmt+0x213>
  8013f1:	0f be c0             	movsbl %al,%eax
  8013f4:	83 e8 20             	sub    $0x20,%eax
  8013f7:	83 f8 5e             	cmp    $0x5e,%eax
  8013fa:	76 0e                	jbe    80140a <vprintfmt+0x213>
					putch('?', putdat);
  8013fc:	83 ec 08             	sub    $0x8,%esp
  8013ff:	53                   	push   %ebx
  801400:	6a 3f                	push   $0x3f
  801402:	ff 55 08             	call   *0x8(%ebp)
  801405:	83 c4 10             	add    $0x10,%esp
  801408:	eb 0b                	jmp    801415 <vprintfmt+0x21e>
				else
					putch(ch, putdat);
  80140a:	83 ec 08             	sub    $0x8,%esp
  80140d:	53                   	push   %ebx
  80140e:	52                   	push   %edx
  80140f:	ff 55 08             	call   *0x8(%ebp)
  801412:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801415:	ff 4d e4             	decl   -0x1c(%ebp)
  801418:	46                   	inc    %esi
  801419:	8a 46 ff             	mov    -0x1(%esi),%al
  80141c:	0f be d0             	movsbl %al,%edx
  80141f:	85 d2                	test   %edx,%edx
  801421:	75 1c                	jne    80143f <vprintfmt+0x248>
  801423:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801426:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80142a:	7f 1f                	jg     80144b <vprintfmt+0x254>
  80142c:	e9 da fd ff ff       	jmp    80120b <vprintfmt+0x14>
  801431:	89 7d 08             	mov    %edi,0x8(%ebp)
  801434:	8b 7d d0             	mov    -0x30(%ebp),%edi
  801437:	eb 06                	jmp    80143f <vprintfmt+0x248>
  801439:	89 7d 08             	mov    %edi,0x8(%ebp)
  80143c:	8b 7d d0             	mov    -0x30(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80143f:	85 ff                	test   %edi,%edi
  801441:	78 a8                	js     8013eb <vprintfmt+0x1f4>
  801443:	4f                   	dec    %edi
  801444:	79 a5                	jns    8013eb <vprintfmt+0x1f4>
  801446:	8b 7d 08             	mov    0x8(%ebp),%edi
  801449:	eb db                	jmp    801426 <vprintfmt+0x22f>
  80144b:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80144e:	83 ec 08             	sub    $0x8,%esp
  801451:	53                   	push   %ebx
  801452:	6a 20                	push   $0x20
  801454:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801456:	4e                   	dec    %esi
  801457:	83 c4 10             	add    $0x10,%esp
  80145a:	85 f6                	test   %esi,%esi
  80145c:	7f f0                	jg     80144e <vprintfmt+0x257>
  80145e:	e9 a8 fd ff ff       	jmp    80120b <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801463:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  801467:	7e 16                	jle    80147f <vprintfmt+0x288>
		return va_arg(*ap, long long);
  801469:	8b 45 14             	mov    0x14(%ebp),%eax
  80146c:	8d 50 08             	lea    0x8(%eax),%edx
  80146f:	89 55 14             	mov    %edx,0x14(%ebp)
  801472:	8b 50 04             	mov    0x4(%eax),%edx
  801475:	8b 00                	mov    (%eax),%eax
  801477:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80147a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80147d:	eb 34                	jmp    8014b3 <vprintfmt+0x2bc>
	else if (lflag)
  80147f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  801483:	74 18                	je     80149d <vprintfmt+0x2a6>
		return va_arg(*ap, long);
  801485:	8b 45 14             	mov    0x14(%ebp),%eax
  801488:	8d 50 04             	lea    0x4(%eax),%edx
  80148b:	89 55 14             	mov    %edx,0x14(%ebp)
  80148e:	8b 30                	mov    (%eax),%esi
  801490:	89 75 d8             	mov    %esi,-0x28(%ebp)
  801493:	89 f0                	mov    %esi,%eax
  801495:	c1 f8 1f             	sar    $0x1f,%eax
  801498:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80149b:	eb 16                	jmp    8014b3 <vprintfmt+0x2bc>
	else
		return va_arg(*ap, int);
  80149d:	8b 45 14             	mov    0x14(%ebp),%eax
  8014a0:	8d 50 04             	lea    0x4(%eax),%edx
  8014a3:	89 55 14             	mov    %edx,0x14(%ebp)
  8014a6:	8b 30                	mov    (%eax),%esi
  8014a8:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8014ab:	89 f0                	mov    %esi,%eax
  8014ad:	c1 f8 1f             	sar    $0x1f,%eax
  8014b0:	89 45 dc             	mov    %eax,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8014b3:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8014b6:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
  8014b9:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8014bd:	0f 89 8a 00 00 00    	jns    80154d <vprintfmt+0x356>
				putch('-', putdat);
  8014c3:	83 ec 08             	sub    $0x8,%esp
  8014c6:	53                   	push   %ebx
  8014c7:	6a 2d                	push   $0x2d
  8014c9:	ff d7                	call   *%edi
				num = -(long long) num;
  8014cb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8014ce:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8014d1:	f7 d8                	neg    %eax
  8014d3:	83 d2 00             	adc    $0x0,%edx
  8014d6:	f7 da                	neg    %edx
  8014d8:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8014db:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8014e0:	eb 70                	jmp    801552 <vprintfmt+0x35b>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8014e2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8014e5:	8d 45 14             	lea    0x14(%ebp),%eax
  8014e8:	e8 97 fc ff ff       	call   801184 <getuint>
			base = 10;
  8014ed:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8014f2:	eb 5e                	jmp    801552 <vprintfmt+0x35b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  8014f4:	83 ec 08             	sub    $0x8,%esp
  8014f7:	53                   	push   %ebx
  8014f8:	6a 30                	push   $0x30
  8014fa:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  8014fc:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8014ff:	8d 45 14             	lea    0x14(%ebp),%eax
  801502:	e8 7d fc ff ff       	call   801184 <getuint>
			base = 8;
			goto number;
  801507:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  80150a:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80150f:	eb 41                	jmp    801552 <vprintfmt+0x35b>
		// pointer
		case 'p':
			putch('0', putdat);
  801511:	83 ec 08             	sub    $0x8,%esp
  801514:	53                   	push   %ebx
  801515:	6a 30                	push   $0x30
  801517:	ff d7                	call   *%edi
			putch('x', putdat);
  801519:	83 c4 08             	add    $0x8,%esp
  80151c:	53                   	push   %ebx
  80151d:	6a 78                	push   $0x78
  80151f:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801521:	8b 45 14             	mov    0x14(%ebp),%eax
  801524:	8d 50 04             	lea    0x4(%eax),%edx
  801527:	89 55 14             	mov    %edx,0x14(%ebp)
			goto number;
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80152a:	8b 00                	mov    (%eax),%eax
  80152c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801531:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801534:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801539:	eb 17                	jmp    801552 <vprintfmt+0x35b>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80153b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80153e:	8d 45 14             	lea    0x14(%ebp),%eax
  801541:	e8 3e fc ff ff       	call   801184 <getuint>
			base = 16;
  801546:	b9 10 00 00 00       	mov    $0x10,%ecx
  80154b:	eb 05                	jmp    801552 <vprintfmt+0x35b>
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80154d:	b9 0a 00 00 00       	mov    $0xa,%ecx
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  801552:	83 ec 0c             	sub    $0xc,%esp
  801555:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  801559:	56                   	push   %esi
  80155a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80155d:	51                   	push   %ecx
  80155e:	52                   	push   %edx
  80155f:	50                   	push   %eax
  801560:	89 da                	mov    %ebx,%edx
  801562:	89 f8                	mov    %edi,%eax
  801564:	e8 6b fb ff ff       	call   8010d4 <printnum>
			break;
  801569:	83 c4 20             	add    $0x20,%esp
  80156c:	e9 9a fc ff ff       	jmp    80120b <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801571:	83 ec 08             	sub    $0x8,%esp
  801574:	53                   	push   %ebx
  801575:	52                   	push   %edx
  801576:	ff d7                	call   *%edi
			break;
  801578:	83 c4 10             	add    $0x10,%esp
  80157b:	e9 8b fc ff ff       	jmp    80120b <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801580:	83 ec 08             	sub    $0x8,%esp
  801583:	53                   	push   %ebx
  801584:	6a 25                	push   $0x25
  801586:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801588:	83 c4 10             	add    $0x10,%esp
  80158b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80158f:	0f 84 73 fc ff ff    	je     801208 <vprintfmt+0x11>
  801595:	4e                   	dec    %esi
  801596:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80159a:	75 f9                	jne    801595 <vprintfmt+0x39e>
  80159c:	89 75 10             	mov    %esi,0x10(%ebp)
  80159f:	e9 67 fc ff ff       	jmp    80120b <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8015a4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8015a7:	8d 70 01             	lea    0x1(%eax),%esi
  8015aa:	8a 00                	mov    (%eax),%al
  8015ac:	0f be d0             	movsbl %al,%edx
  8015af:	85 d2                	test   %edx,%edx
  8015b1:	0f 85 7a fe ff ff    	jne    801431 <vprintfmt+0x23a>
  8015b7:	e9 4f fc ff ff       	jmp    80120b <vprintfmt+0x14>
  8015bc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8015bf:	8d 70 01             	lea    0x1(%eax),%esi
  8015c2:	8a 00                	mov    (%eax),%al
  8015c4:	0f be d0             	movsbl %al,%edx
  8015c7:	85 d2                	test   %edx,%edx
  8015c9:	0f 85 6a fe ff ff    	jne    801439 <vprintfmt+0x242>
  8015cf:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8015d2:	e9 77 fe ff ff       	jmp    80144e <vprintfmt+0x257>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  8015d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015da:	5b                   	pop    %ebx
  8015db:	5e                   	pop    %esi
  8015dc:	5f                   	pop    %edi
  8015dd:	5d                   	pop    %ebp
  8015de:	c3                   	ret    

008015df <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8015df:	55                   	push   %ebp
  8015e0:	89 e5                	mov    %esp,%ebp
  8015e2:	83 ec 18             	sub    $0x18,%esp
  8015e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8015eb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8015ee:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8015f2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8015f5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8015fc:	85 c0                	test   %eax,%eax
  8015fe:	74 26                	je     801626 <vsnprintf+0x47>
  801600:	85 d2                	test   %edx,%edx
  801602:	7e 29                	jle    80162d <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801604:	ff 75 14             	pushl  0x14(%ebp)
  801607:	ff 75 10             	pushl  0x10(%ebp)
  80160a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80160d:	50                   	push   %eax
  80160e:	68 be 11 80 00       	push   $0x8011be
  801613:	e8 df fb ff ff       	call   8011f7 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801618:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80161b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80161e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801621:	83 c4 10             	add    $0x10,%esp
  801624:	eb 0c                	jmp    801632 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801626:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80162b:	eb 05                	jmp    801632 <vsnprintf+0x53>
  80162d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801632:	c9                   	leave  
  801633:	c3                   	ret    

00801634 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801634:	55                   	push   %ebp
  801635:	89 e5                	mov    %esp,%ebp
  801637:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80163a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80163d:	50                   	push   %eax
  80163e:	ff 75 10             	pushl  0x10(%ebp)
  801641:	ff 75 0c             	pushl  0xc(%ebp)
  801644:	ff 75 08             	pushl  0x8(%ebp)
  801647:	e8 93 ff ff ff       	call   8015df <vsnprintf>
	va_end(ap);

	return rc;
}
  80164c:	c9                   	leave  
  80164d:	c3                   	ret    

0080164e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80164e:	55                   	push   %ebp
  80164f:	89 e5                	mov    %esp,%ebp
  801651:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801654:	80 3a 00             	cmpb   $0x0,(%edx)
  801657:	74 0e                	je     801667 <strlen+0x19>
  801659:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80165e:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80165f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801663:	75 f9                	jne    80165e <strlen+0x10>
  801665:	eb 05                	jmp    80166c <strlen+0x1e>
  801667:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80166c:	5d                   	pop    %ebp
  80166d:	c3                   	ret    

0080166e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80166e:	55                   	push   %ebp
  80166f:	89 e5                	mov    %esp,%ebp
  801671:	53                   	push   %ebx
  801672:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801675:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801678:	85 c9                	test   %ecx,%ecx
  80167a:	74 1a                	je     801696 <strnlen+0x28>
  80167c:	80 3b 00             	cmpb   $0x0,(%ebx)
  80167f:	74 1c                	je     80169d <strnlen+0x2f>
  801681:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  801686:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801688:	39 ca                	cmp    %ecx,%edx
  80168a:	74 16                	je     8016a2 <strnlen+0x34>
  80168c:	42                   	inc    %edx
  80168d:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  801692:	75 f2                	jne    801686 <strnlen+0x18>
  801694:	eb 0c                	jmp    8016a2 <strnlen+0x34>
  801696:	b8 00 00 00 00       	mov    $0x0,%eax
  80169b:	eb 05                	jmp    8016a2 <strnlen+0x34>
  80169d:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8016a2:	5b                   	pop    %ebx
  8016a3:	5d                   	pop    %ebp
  8016a4:	c3                   	ret    

008016a5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016a5:	55                   	push   %ebp
  8016a6:	89 e5                	mov    %esp,%ebp
  8016a8:	53                   	push   %ebx
  8016a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016af:	89 c2                	mov    %eax,%edx
  8016b1:	42                   	inc    %edx
  8016b2:	41                   	inc    %ecx
  8016b3:	8a 59 ff             	mov    -0x1(%ecx),%bl
  8016b6:	88 5a ff             	mov    %bl,-0x1(%edx)
  8016b9:	84 db                	test   %bl,%bl
  8016bb:	75 f4                	jne    8016b1 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8016bd:	5b                   	pop    %ebx
  8016be:	5d                   	pop    %ebp
  8016bf:	c3                   	ret    

008016c0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016c0:	55                   	push   %ebp
  8016c1:	89 e5                	mov    %esp,%ebp
  8016c3:	53                   	push   %ebx
  8016c4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016c7:	53                   	push   %ebx
  8016c8:	e8 81 ff ff ff       	call   80164e <strlen>
  8016cd:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8016d0:	ff 75 0c             	pushl  0xc(%ebp)
  8016d3:	01 d8                	add    %ebx,%eax
  8016d5:	50                   	push   %eax
  8016d6:	e8 ca ff ff ff       	call   8016a5 <strcpy>
	return dst;
}
  8016db:	89 d8                	mov    %ebx,%eax
  8016dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016e0:	c9                   	leave  
  8016e1:	c3                   	ret    

008016e2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016e2:	55                   	push   %ebp
  8016e3:	89 e5                	mov    %esp,%ebp
  8016e5:	56                   	push   %esi
  8016e6:	53                   	push   %ebx
  8016e7:	8b 75 08             	mov    0x8(%ebp),%esi
  8016ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016ed:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016f0:	85 db                	test   %ebx,%ebx
  8016f2:	74 14                	je     801708 <strncpy+0x26>
  8016f4:	01 f3                	add    %esi,%ebx
  8016f6:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  8016f8:	41                   	inc    %ecx
  8016f9:	8a 02                	mov    (%edx),%al
  8016fb:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8016fe:	80 3a 01             	cmpb   $0x1,(%edx)
  801701:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801704:	39 cb                	cmp    %ecx,%ebx
  801706:	75 f0                	jne    8016f8 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801708:	89 f0                	mov    %esi,%eax
  80170a:	5b                   	pop    %ebx
  80170b:	5e                   	pop    %esi
  80170c:	5d                   	pop    %ebp
  80170d:	c3                   	ret    

0080170e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80170e:	55                   	push   %ebp
  80170f:	89 e5                	mov    %esp,%ebp
  801711:	53                   	push   %ebx
  801712:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801715:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801718:	85 c0                	test   %eax,%eax
  80171a:	74 30                	je     80174c <strlcpy+0x3e>
		while (--size > 0 && *src != '\0')
  80171c:	48                   	dec    %eax
  80171d:	74 20                	je     80173f <strlcpy+0x31>
  80171f:	8a 0b                	mov    (%ebx),%cl
  801721:	84 c9                	test   %cl,%cl
  801723:	74 1f                	je     801744 <strlcpy+0x36>
  801725:	8d 53 01             	lea    0x1(%ebx),%edx
  801728:	01 c3                	add    %eax,%ebx
  80172a:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
  80172d:	40                   	inc    %eax
  80172e:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801731:	39 da                	cmp    %ebx,%edx
  801733:	74 12                	je     801747 <strlcpy+0x39>
  801735:	42                   	inc    %edx
  801736:	8a 4a ff             	mov    -0x1(%edx),%cl
  801739:	84 c9                	test   %cl,%cl
  80173b:	75 f0                	jne    80172d <strlcpy+0x1f>
  80173d:	eb 08                	jmp    801747 <strlcpy+0x39>
  80173f:	8b 45 08             	mov    0x8(%ebp),%eax
  801742:	eb 03                	jmp    801747 <strlcpy+0x39>
  801744:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
		*dst = '\0';
  801747:	c6 00 00             	movb   $0x0,(%eax)
  80174a:	eb 03                	jmp    80174f <strlcpy+0x41>
  80174c:	8b 45 08             	mov    0x8(%ebp),%eax
	}
	return dst - dst_in;
  80174f:	2b 45 08             	sub    0x8(%ebp),%eax
}
  801752:	5b                   	pop    %ebx
  801753:	5d                   	pop    %ebp
  801754:	c3                   	ret    

00801755 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801755:	55                   	push   %ebp
  801756:	89 e5                	mov    %esp,%ebp
  801758:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80175b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80175e:	8a 01                	mov    (%ecx),%al
  801760:	84 c0                	test   %al,%al
  801762:	74 10                	je     801774 <strcmp+0x1f>
  801764:	3a 02                	cmp    (%edx),%al
  801766:	75 0c                	jne    801774 <strcmp+0x1f>
		p++, q++;
  801768:	41                   	inc    %ecx
  801769:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80176a:	8a 01                	mov    (%ecx),%al
  80176c:	84 c0                	test   %al,%al
  80176e:	74 04                	je     801774 <strcmp+0x1f>
  801770:	3a 02                	cmp    (%edx),%al
  801772:	74 f4                	je     801768 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801774:	0f b6 c0             	movzbl %al,%eax
  801777:	0f b6 12             	movzbl (%edx),%edx
  80177a:	29 d0                	sub    %edx,%eax
}
  80177c:	5d                   	pop    %ebp
  80177d:	c3                   	ret    

0080177e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80177e:	55                   	push   %ebp
  80177f:	89 e5                	mov    %esp,%ebp
  801781:	56                   	push   %esi
  801782:	53                   	push   %ebx
  801783:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801786:	8b 55 0c             	mov    0xc(%ebp),%edx
  801789:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  80178c:	85 f6                	test   %esi,%esi
  80178e:	74 23                	je     8017b3 <strncmp+0x35>
  801790:	8a 03                	mov    (%ebx),%al
  801792:	84 c0                	test   %al,%al
  801794:	74 2b                	je     8017c1 <strncmp+0x43>
  801796:	3a 02                	cmp    (%edx),%al
  801798:	75 27                	jne    8017c1 <strncmp+0x43>
  80179a:	8d 43 01             	lea    0x1(%ebx),%eax
  80179d:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  80179f:	89 c3                	mov    %eax,%ebx
  8017a1:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017a2:	39 c6                	cmp    %eax,%esi
  8017a4:	74 14                	je     8017ba <strncmp+0x3c>
  8017a6:	8a 08                	mov    (%eax),%cl
  8017a8:	84 c9                	test   %cl,%cl
  8017aa:	74 15                	je     8017c1 <strncmp+0x43>
  8017ac:	40                   	inc    %eax
  8017ad:	3a 0a                	cmp    (%edx),%cl
  8017af:	74 ee                	je     80179f <strncmp+0x21>
  8017b1:	eb 0e                	jmp    8017c1 <strncmp+0x43>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8017b8:	eb 0f                	jmp    8017c9 <strncmp+0x4b>
  8017ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8017bf:	eb 08                	jmp    8017c9 <strncmp+0x4b>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017c1:	0f b6 03             	movzbl (%ebx),%eax
  8017c4:	0f b6 12             	movzbl (%edx),%edx
  8017c7:	29 d0                	sub    %edx,%eax
}
  8017c9:	5b                   	pop    %ebx
  8017ca:	5e                   	pop    %esi
  8017cb:	5d                   	pop    %ebp
  8017cc:	c3                   	ret    

008017cd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017cd:	55                   	push   %ebp
  8017ce:	89 e5                	mov    %esp,%ebp
  8017d0:	53                   	push   %ebx
  8017d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  8017d7:	8a 10                	mov    (%eax),%dl
  8017d9:	84 d2                	test   %dl,%dl
  8017db:	74 1a                	je     8017f7 <strchr+0x2a>
  8017dd:	88 d9                	mov    %bl,%cl
		if (*s == c)
  8017df:	38 d3                	cmp    %dl,%bl
  8017e1:	75 06                	jne    8017e9 <strchr+0x1c>
  8017e3:	eb 17                	jmp    8017fc <strchr+0x2f>
  8017e5:	38 ca                	cmp    %cl,%dl
  8017e7:	74 13                	je     8017fc <strchr+0x2f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017e9:	40                   	inc    %eax
  8017ea:	8a 10                	mov    (%eax),%dl
  8017ec:	84 d2                	test   %dl,%dl
  8017ee:	75 f5                	jne    8017e5 <strchr+0x18>
		if (*s == c)
			return (char *) s;
	return 0;
  8017f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8017f5:	eb 05                	jmp    8017fc <strchr+0x2f>
  8017f7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017fc:	5b                   	pop    %ebx
  8017fd:	5d                   	pop    %ebp
  8017fe:	c3                   	ret    

008017ff <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017ff:	55                   	push   %ebp
  801800:	89 e5                	mov    %esp,%ebp
  801802:	53                   	push   %ebx
  801803:	8b 45 08             	mov    0x8(%ebp),%eax
  801806:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  801809:	8a 10                	mov    (%eax),%dl
  80180b:	84 d2                	test   %dl,%dl
  80180d:	74 13                	je     801822 <strfind+0x23>
  80180f:	88 d9                	mov    %bl,%cl
		if (*s == c)
  801811:	38 d3                	cmp    %dl,%bl
  801813:	75 06                	jne    80181b <strfind+0x1c>
  801815:	eb 0b                	jmp    801822 <strfind+0x23>
  801817:	38 ca                	cmp    %cl,%dl
  801819:	74 07                	je     801822 <strfind+0x23>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80181b:	40                   	inc    %eax
  80181c:	8a 10                	mov    (%eax),%dl
  80181e:	84 d2                	test   %dl,%dl
  801820:	75 f5                	jne    801817 <strfind+0x18>
		if (*s == c)
			break;
	return (char *) s;
}
  801822:	5b                   	pop    %ebx
  801823:	5d                   	pop    %ebp
  801824:	c3                   	ret    

00801825 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801825:	55                   	push   %ebp
  801826:	89 e5                	mov    %esp,%ebp
  801828:	57                   	push   %edi
  801829:	56                   	push   %esi
  80182a:	53                   	push   %ebx
  80182b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80182e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801831:	85 c9                	test   %ecx,%ecx
  801833:	74 36                	je     80186b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801835:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80183b:	75 28                	jne    801865 <memset+0x40>
  80183d:	f6 c1 03             	test   $0x3,%cl
  801840:	75 23                	jne    801865 <memset+0x40>
		c &= 0xFF;
  801842:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801846:	89 d3                	mov    %edx,%ebx
  801848:	c1 e3 08             	shl    $0x8,%ebx
  80184b:	89 d6                	mov    %edx,%esi
  80184d:	c1 e6 18             	shl    $0x18,%esi
  801850:	89 d0                	mov    %edx,%eax
  801852:	c1 e0 10             	shl    $0x10,%eax
  801855:	09 f0                	or     %esi,%eax
  801857:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801859:	89 d8                	mov    %ebx,%eax
  80185b:	09 d0                	or     %edx,%eax
  80185d:	c1 e9 02             	shr    $0x2,%ecx
  801860:	fc                   	cld    
  801861:	f3 ab                	rep stos %eax,%es:(%edi)
  801863:	eb 06                	jmp    80186b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801865:	8b 45 0c             	mov    0xc(%ebp),%eax
  801868:	fc                   	cld    
  801869:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80186b:	89 f8                	mov    %edi,%eax
  80186d:	5b                   	pop    %ebx
  80186e:	5e                   	pop    %esi
  80186f:	5f                   	pop    %edi
  801870:	5d                   	pop    %ebp
  801871:	c3                   	ret    

00801872 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801872:	55                   	push   %ebp
  801873:	89 e5                	mov    %esp,%ebp
  801875:	57                   	push   %edi
  801876:	56                   	push   %esi
  801877:	8b 45 08             	mov    0x8(%ebp),%eax
  80187a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80187d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801880:	39 c6                	cmp    %eax,%esi
  801882:	73 33                	jae    8018b7 <memmove+0x45>
  801884:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801887:	39 d0                	cmp    %edx,%eax
  801889:	73 2c                	jae    8018b7 <memmove+0x45>
		s += n;
		d += n;
  80188b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80188e:	89 d6                	mov    %edx,%esi
  801890:	09 fe                	or     %edi,%esi
  801892:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801898:	75 13                	jne    8018ad <memmove+0x3b>
  80189a:	f6 c1 03             	test   $0x3,%cl
  80189d:	75 0e                	jne    8018ad <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80189f:	83 ef 04             	sub    $0x4,%edi
  8018a2:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018a5:	c1 e9 02             	shr    $0x2,%ecx
  8018a8:	fd                   	std    
  8018a9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018ab:	eb 07                	jmp    8018b4 <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8018ad:	4f                   	dec    %edi
  8018ae:	8d 72 ff             	lea    -0x1(%edx),%esi
  8018b1:	fd                   	std    
  8018b2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018b4:	fc                   	cld    
  8018b5:	eb 1d                	jmp    8018d4 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018b7:	89 f2                	mov    %esi,%edx
  8018b9:	09 c2                	or     %eax,%edx
  8018bb:	f6 c2 03             	test   $0x3,%dl
  8018be:	75 0f                	jne    8018cf <memmove+0x5d>
  8018c0:	f6 c1 03             	test   $0x3,%cl
  8018c3:	75 0a                	jne    8018cf <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
  8018c5:	c1 e9 02             	shr    $0x2,%ecx
  8018c8:	89 c7                	mov    %eax,%edi
  8018ca:	fc                   	cld    
  8018cb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018cd:	eb 05                	jmp    8018d4 <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018cf:	89 c7                	mov    %eax,%edi
  8018d1:	fc                   	cld    
  8018d2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018d4:	5e                   	pop    %esi
  8018d5:	5f                   	pop    %edi
  8018d6:	5d                   	pop    %ebp
  8018d7:	c3                   	ret    

008018d8 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018d8:	55                   	push   %ebp
  8018d9:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018db:	ff 75 10             	pushl  0x10(%ebp)
  8018de:	ff 75 0c             	pushl  0xc(%ebp)
  8018e1:	ff 75 08             	pushl  0x8(%ebp)
  8018e4:	e8 89 ff ff ff       	call   801872 <memmove>
}
  8018e9:	c9                   	leave  
  8018ea:	c3                   	ret    

008018eb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018eb:	55                   	push   %ebp
  8018ec:	89 e5                	mov    %esp,%ebp
  8018ee:	57                   	push   %edi
  8018ef:	56                   	push   %esi
  8018f0:	53                   	push   %ebx
  8018f1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8018f4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018f7:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018fa:	85 c0                	test   %eax,%eax
  8018fc:	74 33                	je     801931 <memcmp+0x46>
  8018fe:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  801901:	8a 13                	mov    (%ebx),%dl
  801903:	8a 0e                	mov    (%esi),%cl
  801905:	38 ca                	cmp    %cl,%dl
  801907:	75 13                	jne    80191c <memcmp+0x31>
  801909:	b8 00 00 00 00       	mov    $0x0,%eax
  80190e:	eb 16                	jmp    801926 <memcmp+0x3b>
  801910:	8a 54 03 01          	mov    0x1(%ebx,%eax,1),%dl
  801914:	40                   	inc    %eax
  801915:	8a 0c 06             	mov    (%esi,%eax,1),%cl
  801918:	38 ca                	cmp    %cl,%dl
  80191a:	74 0a                	je     801926 <memcmp+0x3b>
			return (int) *s1 - (int) *s2;
  80191c:	0f b6 c2             	movzbl %dl,%eax
  80191f:	0f b6 c9             	movzbl %cl,%ecx
  801922:	29 c8                	sub    %ecx,%eax
  801924:	eb 10                	jmp    801936 <memcmp+0x4b>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801926:	39 f8                	cmp    %edi,%eax
  801928:	75 e6                	jne    801910 <memcmp+0x25>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80192a:	b8 00 00 00 00       	mov    $0x0,%eax
  80192f:	eb 05                	jmp    801936 <memcmp+0x4b>
  801931:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801936:	5b                   	pop    %ebx
  801937:	5e                   	pop    %esi
  801938:	5f                   	pop    %edi
  801939:	5d                   	pop    %ebp
  80193a:	c3                   	ret    

0080193b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80193b:	55                   	push   %ebp
  80193c:	89 e5                	mov    %esp,%ebp
  80193e:	53                   	push   %ebx
  80193f:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  801942:	89 d0                	mov    %edx,%eax
  801944:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  801947:	39 c2                	cmp    %eax,%edx
  801949:	73 1b                	jae    801966 <memfind+0x2b>
		if (*(const unsigned char *) s == (unsigned char) c)
  80194b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  80194f:	0f b6 0a             	movzbl (%edx),%ecx
  801952:	39 d9                	cmp    %ebx,%ecx
  801954:	75 09                	jne    80195f <memfind+0x24>
  801956:	eb 12                	jmp    80196a <memfind+0x2f>
  801958:	0f b6 0a             	movzbl (%edx),%ecx
  80195b:	39 d9                	cmp    %ebx,%ecx
  80195d:	74 0f                	je     80196e <memfind+0x33>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80195f:	42                   	inc    %edx
  801960:	39 d0                	cmp    %edx,%eax
  801962:	75 f4                	jne    801958 <memfind+0x1d>
  801964:	eb 0a                	jmp    801970 <memfind+0x35>
  801966:	89 d0                	mov    %edx,%eax
  801968:	eb 06                	jmp    801970 <memfind+0x35>
		if (*(const unsigned char *) s == (unsigned char) c)
  80196a:	89 d0                	mov    %edx,%eax
  80196c:	eb 02                	jmp    801970 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80196e:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801970:	5b                   	pop    %ebx
  801971:	5d                   	pop    %ebp
  801972:	c3                   	ret    

00801973 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801973:	55                   	push   %ebp
  801974:	89 e5                	mov    %esp,%ebp
  801976:	57                   	push   %edi
  801977:	56                   	push   %esi
  801978:	53                   	push   %ebx
  801979:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80197c:	eb 01                	jmp    80197f <strtol+0xc>
		s++;
  80197e:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80197f:	8a 01                	mov    (%ecx),%al
  801981:	3c 20                	cmp    $0x20,%al
  801983:	74 f9                	je     80197e <strtol+0xb>
  801985:	3c 09                	cmp    $0x9,%al
  801987:	74 f5                	je     80197e <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  801989:	3c 2b                	cmp    $0x2b,%al
  80198b:	75 08                	jne    801995 <strtol+0x22>
		s++;
  80198d:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80198e:	bf 00 00 00 00       	mov    $0x0,%edi
  801993:	eb 11                	jmp    8019a6 <strtol+0x33>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801995:	3c 2d                	cmp    $0x2d,%al
  801997:	75 08                	jne    8019a1 <strtol+0x2e>
		s++, neg = 1;
  801999:	41                   	inc    %ecx
  80199a:	bf 01 00 00 00       	mov    $0x1,%edi
  80199f:	eb 05                	jmp    8019a6 <strtol+0x33>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8019a1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019a6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019aa:	0f 84 87 00 00 00    	je     801a37 <strtol+0xc4>
  8019b0:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  8019b4:	75 27                	jne    8019dd <strtol+0x6a>
  8019b6:	80 39 30             	cmpb   $0x30,(%ecx)
  8019b9:	75 22                	jne    8019dd <strtol+0x6a>
  8019bb:	e9 88 00 00 00       	jmp    801a48 <strtol+0xd5>
		s += 2, base = 16;
  8019c0:	83 c1 02             	add    $0x2,%ecx
  8019c3:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  8019ca:	eb 11                	jmp    8019dd <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
  8019cc:	41                   	inc    %ecx
  8019cd:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  8019d4:	eb 07                	jmp    8019dd <strtol+0x6a>
	else if (base == 0)
		base = 10;
  8019d6:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  8019dd:	b8 00 00 00 00       	mov    $0x0,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019e2:	8a 11                	mov    (%ecx),%dl
  8019e4:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8019e7:	80 fb 09             	cmp    $0x9,%bl
  8019ea:	77 08                	ja     8019f4 <strtol+0x81>
			dig = *s - '0';
  8019ec:	0f be d2             	movsbl %dl,%edx
  8019ef:	83 ea 30             	sub    $0x30,%edx
  8019f2:	eb 22                	jmp    801a16 <strtol+0xa3>
		else if (*s >= 'a' && *s <= 'z')
  8019f4:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019f7:	89 f3                	mov    %esi,%ebx
  8019f9:	80 fb 19             	cmp    $0x19,%bl
  8019fc:	77 08                	ja     801a06 <strtol+0x93>
			dig = *s - 'a' + 10;
  8019fe:	0f be d2             	movsbl %dl,%edx
  801a01:	83 ea 57             	sub    $0x57,%edx
  801a04:	eb 10                	jmp    801a16 <strtol+0xa3>
		else if (*s >= 'A' && *s <= 'Z')
  801a06:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a09:	89 f3                	mov    %esi,%ebx
  801a0b:	80 fb 19             	cmp    $0x19,%bl
  801a0e:	77 14                	ja     801a24 <strtol+0xb1>
			dig = *s - 'A' + 10;
  801a10:	0f be d2             	movsbl %dl,%edx
  801a13:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801a16:	3b 55 10             	cmp    0x10(%ebp),%edx
  801a19:	7d 09                	jge    801a24 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  801a1b:	41                   	inc    %ecx
  801a1c:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a20:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801a22:	eb be                	jmp    8019e2 <strtol+0x6f>

	if (endptr)
  801a24:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a28:	74 05                	je     801a2f <strtol+0xbc>
		*endptr = (char *) s;
  801a2a:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a2d:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801a2f:	85 ff                	test   %edi,%edi
  801a31:	74 21                	je     801a54 <strtol+0xe1>
  801a33:	f7 d8                	neg    %eax
  801a35:	eb 1d                	jmp    801a54 <strtol+0xe1>
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801a37:	80 39 30             	cmpb   $0x30,(%ecx)
  801a3a:	75 9a                	jne    8019d6 <strtol+0x63>
  801a3c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801a40:	0f 84 7a ff ff ff    	je     8019c0 <strtol+0x4d>
  801a46:	eb 84                	jmp    8019cc <strtol+0x59>
  801a48:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801a4c:	0f 84 6e ff ff ff    	je     8019c0 <strtol+0x4d>
  801a52:	eb 89                	jmp    8019dd <strtol+0x6a>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  801a54:	5b                   	pop    %ebx
  801a55:	5e                   	pop    %esi
  801a56:	5f                   	pop    %edi
  801a57:	5d                   	pop    %ebp
  801a58:	c3                   	ret    

00801a59 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a59:	55                   	push   %ebp
  801a5a:	89 e5                	mov    %esp,%ebp
  801a5c:	56                   	push   %esi
  801a5d:	53                   	push   %ebx
  801a5e:	8b 75 08             	mov    0x8(%ebp),%esi
  801a61:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a64:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");
	int r;
    if (pg != NULL) {
  801a67:	85 c0                	test   %eax,%eax
  801a69:	74 0e                	je     801a79 <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  801a6b:	83 ec 0c             	sub    $0xc,%esp
  801a6e:	50                   	push   %eax
  801a6f:	e8 9b e8 ff ff       	call   80030f <sys_ipc_recv>
  801a74:	83 c4 10             	add    $0x10,%esp
  801a77:	eb 10                	jmp    801a89 <ipc_recv+0x30>
    } else {
        r = sys_ipc_recv((void *) UTOP);
  801a79:	83 ec 0c             	sub    $0xc,%esp
  801a7c:	68 00 00 c0 ee       	push   $0xeec00000
  801a81:	e8 89 e8 ff ff       	call   80030f <sys_ipc_recv>
  801a86:	83 c4 10             	add    $0x10,%esp
    }
    if (r < 0) {
  801a89:	85 c0                	test   %eax,%eax
  801a8b:	79 16                	jns    801aa3 <ipc_recv+0x4a>
        // failed
        if (from_env_store != NULL) *from_env_store = 0;
  801a8d:	85 f6                	test   %esi,%esi
  801a8f:	74 06                	je     801a97 <ipc_recv+0x3e>
  801a91:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL) *perm_store = 0;
  801a97:	85 db                	test   %ebx,%ebx
  801a99:	74 2c                	je     801ac7 <ipc_recv+0x6e>
  801a9b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801aa1:	eb 24                	jmp    801ac7 <ipc_recv+0x6e>
        return r;
    } else {
        if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801aa3:	85 f6                	test   %esi,%esi
  801aa5:	74 0a                	je     801ab1 <ipc_recv+0x58>
  801aa7:	a1 04 40 80 00       	mov    0x804004,%eax
  801aac:	8b 40 74             	mov    0x74(%eax),%eax
  801aaf:	89 06                	mov    %eax,(%esi)
        if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801ab1:	85 db                	test   %ebx,%ebx
  801ab3:	74 0a                	je     801abf <ipc_recv+0x66>
  801ab5:	a1 04 40 80 00       	mov    0x804004,%eax
  801aba:	8b 40 78             	mov    0x78(%eax),%eax
  801abd:	89 03                	mov    %eax,(%ebx)
        return thisenv->env_ipc_value;
  801abf:	a1 04 40 80 00       	mov    0x804004,%eax
  801ac4:	8b 40 70             	mov    0x70(%eax),%eax
    }
 
	return 0;
}
  801ac7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aca:	5b                   	pop    %ebx
  801acb:	5e                   	pop    %esi
  801acc:	5d                   	pop    %ebp
  801acd:	c3                   	ret    

00801ace <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ace:	55                   	push   %ebp
  801acf:	89 e5                	mov    %esp,%ebp
  801ad1:	57                   	push   %edi
  801ad2:	56                   	push   %esi
  801ad3:	53                   	push   %ebx
  801ad4:	83 ec 0c             	sub    $0xc,%esp
  801ad7:	8b 75 10             	mov    0x10(%ebp),%esi
  801ada:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;
    if (pg == NULL) pg = (void *)UTOP;
  801add:	85 f6                	test   %esi,%esi
  801adf:	75 05                	jne    801ae6 <ipc_send+0x18>
  801ae1:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
  801ae6:	57                   	push   %edi
  801ae7:	56                   	push   %esi
  801ae8:	ff 75 0c             	pushl  0xc(%ebp)
  801aeb:	ff 75 08             	pushl  0x8(%ebp)
  801aee:	e8 f9 e7 ff ff       	call   8002ec <sys_ipc_try_send>
  801af3:	89 c3                	mov    %eax,%ebx
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
  801af5:	83 c4 10             	add    $0x10,%esp
  801af8:	85 c0                	test   %eax,%eax
  801afa:	79 17                	jns    801b13 <ipc_send+0x45>
  801afc:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801aff:	74 1d                	je     801b1e <ipc_send+0x50>
  801b01:	50                   	push   %eax
  801b02:	68 80 22 80 00       	push   $0x802280
  801b07:	6a 40                	push   $0x40
  801b09:	68 94 22 80 00       	push   $0x802294
  801b0e:	e8 d5 f4 ff ff       	call   800fe8 <_panic>
        sys_yield();
  801b13:	e8 28 e6 ff ff       	call   800140 <sys_yield>
    } while (r != 0);
  801b18:	85 db                	test   %ebx,%ebx
  801b1a:	75 ca                	jne    801ae6 <ipc_send+0x18>
  801b1c:	eb 07                	jmp    801b25 <ipc_send+0x57>
	int r;
    if (pg == NULL) pg = (void *)UTOP;
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
        sys_yield();
  801b1e:	e8 1d e6 ff ff       	call   800140 <sys_yield>
  801b23:	eb c1                	jmp    801ae6 <ipc_send+0x18>
    } while (r != 0);
}
  801b25:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b28:	5b                   	pop    %ebx
  801b29:	5e                   	pop    %esi
  801b2a:	5f                   	pop    %edi
  801b2b:	5d                   	pop    %ebp
  801b2c:	c3                   	ret    

00801b2d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b2d:	55                   	push   %ebp
  801b2e:	89 e5                	mov    %esp,%ebp
  801b30:	53                   	push   %ebx
  801b31:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801b34:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801b39:	39 c1                	cmp    %eax,%ecx
  801b3b:	74 21                	je     801b5e <ipc_find_env+0x31>
  801b3d:	ba 01 00 00 00       	mov    $0x1,%edx
  801b42:	8d 1c 95 00 00 00 00 	lea    0x0(,%edx,4),%ebx
  801b49:	89 d0                	mov    %edx,%eax
  801b4b:	c1 e0 07             	shl    $0x7,%eax
  801b4e:	29 d8                	sub    %ebx,%eax
  801b50:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b55:	8b 40 50             	mov    0x50(%eax),%eax
  801b58:	39 c8                	cmp    %ecx,%eax
  801b5a:	75 1b                	jne    801b77 <ipc_find_env+0x4a>
  801b5c:	eb 05                	jmp    801b63 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b5e:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801b63:	8d 04 95 00 00 00 00 	lea    0x0(,%edx,4),%eax
  801b6a:	c1 e2 07             	shl    $0x7,%edx
  801b6d:	29 c2                	sub    %eax,%edx
  801b6f:	8b 82 48 00 c0 ee    	mov    -0x113fffb8(%edx),%eax
  801b75:	eb 0e                	jmp    801b85 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b77:	42                   	inc    %edx
  801b78:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  801b7e:	75 c2                	jne    801b42 <ipc_find_env+0x15>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b80:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b85:	5b                   	pop    %ebx
  801b86:	5d                   	pop    %ebp
  801b87:	c3                   	ret    

00801b88 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b88:	55                   	push   %ebp
  801b89:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b8b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b8e:	c1 e8 16             	shr    $0x16,%eax
  801b91:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801b98:	a8 01                	test   $0x1,%al
  801b9a:	74 21                	je     801bbd <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b9c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b9f:	c1 e8 0c             	shr    $0xc,%eax
  801ba2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801ba9:	a8 01                	test   $0x1,%al
  801bab:	74 17                	je     801bc4 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bad:	c1 e8 0c             	shr    $0xc,%eax
  801bb0:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801bb7:	ef 
  801bb8:	0f b7 c0             	movzwl %ax,%eax
  801bbb:	eb 0c                	jmp    801bc9 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801bbd:	b8 00 00 00 00       	mov    $0x0,%eax
  801bc2:	eb 05                	jmp    801bc9 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801bc4:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801bc9:	5d                   	pop    %ebp
  801bca:	c3                   	ret    
  801bcb:	90                   	nop

00801bcc <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801bcc:	55                   	push   %ebp
  801bcd:	57                   	push   %edi
  801bce:	56                   	push   %esi
  801bcf:	53                   	push   %ebx
  801bd0:	83 ec 1c             	sub    $0x1c,%esp
  801bd3:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801bd7:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801bdb:	8b 7c 24 38          	mov    0x38(%esp),%edi
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801bdf:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801be3:	89 ca                	mov    %ecx,%edx
  const DWunion dd = {.ll = d};
  801be5:	89 f8                	mov    %edi,%eax
  801be7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801beb:	85 f6                	test   %esi,%esi
  801bed:	75 2d                	jne    801c1c <__udivdi3+0x50>
    {
      if (d0 > n1)
  801bef:	39 cf                	cmp    %ecx,%edi
  801bf1:	77 65                	ja     801c58 <__udivdi3+0x8c>
  801bf3:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801bf5:	85 ff                	test   %edi,%edi
  801bf7:	75 0b                	jne    801c04 <__udivdi3+0x38>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801bf9:	b8 01 00 00 00       	mov    $0x1,%eax
  801bfe:	31 d2                	xor    %edx,%edx
  801c00:	f7 f7                	div    %edi
  801c02:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801c04:	31 d2                	xor    %edx,%edx
  801c06:	89 c8                	mov    %ecx,%eax
  801c08:	f7 f5                	div    %ebp
  801c0a:	89 c1                	mov    %eax,%ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c0c:	89 d8                	mov    %ebx,%eax
  801c0e:	f7 f5                	div    %ebp
  801c10:	89 cf                	mov    %ecx,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c12:	89 fa                	mov    %edi,%edx
  801c14:	83 c4 1c             	add    $0x1c,%esp
  801c17:	5b                   	pop    %ebx
  801c18:	5e                   	pop    %esi
  801c19:	5f                   	pop    %edi
  801c1a:	5d                   	pop    %ebp
  801c1b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801c1c:	39 ce                	cmp    %ecx,%esi
  801c1e:	77 28                	ja     801c48 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801c20:	0f bd fe             	bsr    %esi,%edi
	  if (bm == 0)
  801c23:	83 f7 1f             	xor    $0x1f,%edi
  801c26:	75 40                	jne    801c68 <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801c28:	39 ce                	cmp    %ecx,%esi
  801c2a:	72 0a                	jb     801c36 <__udivdi3+0x6a>
  801c2c:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801c30:	0f 87 9e 00 00 00    	ja     801cd4 <__udivdi3+0x108>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801c36:	b8 01 00 00 00       	mov    $0x1,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c3b:	89 fa                	mov    %edi,%edx
  801c3d:	83 c4 1c             	add    $0x1c,%esp
  801c40:	5b                   	pop    %ebx
  801c41:	5e                   	pop    %esi
  801c42:	5f                   	pop    %edi
  801c43:	5d                   	pop    %ebp
  801c44:	c3                   	ret    
  801c45:	8d 76 00             	lea    0x0(%esi),%esi
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801c48:	31 ff                	xor    %edi,%edi
  801c4a:	31 c0                	xor    %eax,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c4c:	89 fa                	mov    %edi,%edx
  801c4e:	83 c4 1c             	add    $0x1c,%esp
  801c51:	5b                   	pop    %ebx
  801c52:	5e                   	pop    %esi
  801c53:	5f                   	pop    %edi
  801c54:	5d                   	pop    %ebp
  801c55:	c3                   	ret    
  801c56:	66 90                	xchg   %ax,%ax
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c58:	89 d8                	mov    %ebx,%eax
  801c5a:	f7 f7                	div    %edi
  801c5c:	31 ff                	xor    %edi,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c5e:	89 fa                	mov    %edi,%edx
  801c60:	83 c4 1c             	add    $0x1c,%esp
  801c63:	5b                   	pop    %ebx
  801c64:	5e                   	pop    %esi
  801c65:	5f                   	pop    %edi
  801c66:	5d                   	pop    %ebp
  801c67:	c3                   	ret    
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801c68:	bd 20 00 00 00       	mov    $0x20,%ebp
  801c6d:	89 eb                	mov    %ebp,%ebx
  801c6f:	29 fb                	sub    %edi,%ebx

	      d1 = (d1 << bm) | (d0 >> b);
  801c71:	89 f9                	mov    %edi,%ecx
  801c73:	d3 e6                	shl    %cl,%esi
  801c75:	89 c5                	mov    %eax,%ebp
  801c77:	88 d9                	mov    %bl,%cl
  801c79:	d3 ed                	shr    %cl,%ebp
  801c7b:	89 e9                	mov    %ebp,%ecx
  801c7d:	09 f1                	or     %esi,%ecx
  801c7f:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
	      d0 = d0 << bm;
  801c83:	89 f9                	mov    %edi,%ecx
  801c85:	d3 e0                	shl    %cl,%eax
  801c87:	89 c5                	mov    %eax,%ebp
	      n2 = n1 >> b;
  801c89:	89 d6                	mov    %edx,%esi
  801c8b:	88 d9                	mov    %bl,%cl
  801c8d:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
  801c8f:	89 f9                	mov    %edi,%ecx
  801c91:	d3 e2                	shl    %cl,%edx
  801c93:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c97:	88 d9                	mov    %bl,%cl
  801c99:	d3 e8                	shr    %cl,%eax
  801c9b:	09 c2                	or     %eax,%edx
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801c9d:	89 d0                	mov    %edx,%eax
  801c9f:	89 f2                	mov    %esi,%edx
  801ca1:	f7 74 24 0c          	divl   0xc(%esp)
  801ca5:	89 d6                	mov    %edx,%esi
  801ca7:	89 c3                	mov    %eax,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  801ca9:	f7 e5                	mul    %ebp

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801cab:	39 d6                	cmp    %edx,%esi
  801cad:	72 19                	jb     801cc8 <__udivdi3+0xfc>
  801caf:	74 0b                	je     801cbc <__udivdi3+0xf0>
  801cb1:	89 d8                	mov    %ebx,%eax
  801cb3:	31 ff                	xor    %edi,%edi
  801cb5:	e9 58 ff ff ff       	jmp    801c12 <__udivdi3+0x46>
  801cba:	66 90                	xchg   %ax,%ax
  801cbc:	8b 54 24 08          	mov    0x8(%esp),%edx
  801cc0:	89 f9                	mov    %edi,%ecx
  801cc2:	d3 e2                	shl    %cl,%edx
  801cc4:	39 c2                	cmp    %eax,%edx
  801cc6:	73 e9                	jae    801cb1 <__udivdi3+0xe5>
  801cc8:	8d 43 ff             	lea    -0x1(%ebx),%eax
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801ccb:	31 ff                	xor    %edi,%edi
  801ccd:	e9 40 ff ff ff       	jmp    801c12 <__udivdi3+0x46>
  801cd2:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801cd4:	31 c0                	xor    %eax,%eax
  801cd6:	e9 37 ff ff ff       	jmp    801c12 <__udivdi3+0x46>
  801cdb:	90                   	nop

00801cdc <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801cdc:	55                   	push   %ebp
  801cdd:	57                   	push   %edi
  801cde:	56                   	push   %esi
  801cdf:	53                   	push   %ebx
  801ce0:	83 ec 1c             	sub    $0x1c,%esp
  801ce3:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801ce7:	8b 74 24 34          	mov    0x34(%esp),%esi
  801ceb:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801cef:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801cf3:	89 44 24 0c          	mov    %eax,0xc(%esp)
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801cf7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801cfb:	89 f3                	mov    %esi,%ebx
  const DWunion dd = {.ll = d};
  801cfd:	89 fa                	mov    %edi,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801cff:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  n1 = nn.s.high;
  801d03:	89 34 24             	mov    %esi,(%esp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801d06:	85 c0                	test   %eax,%eax
  801d08:	75 1a                	jne    801d24 <__umoddi3+0x48>
    {
      if (d0 > n1)
  801d0a:	39 f7                	cmp    %esi,%edi
  801d0c:	0f 86 a2 00 00 00    	jbe    801db4 <__umoddi3+0xd8>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d12:	89 c8                	mov    %ecx,%eax
  801d14:	89 f2                	mov    %esi,%edx
  801d16:	f7 f7                	div    %edi
  801d18:	89 d0                	mov    %edx,%eax

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801d1a:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d1c:	83 c4 1c             	add    $0x1c,%esp
  801d1f:	5b                   	pop    %ebx
  801d20:	5e                   	pop    %esi
  801d21:	5f                   	pop    %edi
  801d22:	5d                   	pop    %ebp
  801d23:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801d24:	39 f0                	cmp    %esi,%eax
  801d26:	0f 87 ac 00 00 00    	ja     801dd8 <__umoddi3+0xfc>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801d2c:	0f bd e8             	bsr    %eax,%ebp
	  if (bm == 0)
  801d2f:	83 f5 1f             	xor    $0x1f,%ebp
  801d32:	0f 84 ac 00 00 00    	je     801de4 <__umoddi3+0x108>
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801d38:	bf 20 00 00 00       	mov    $0x20,%edi
  801d3d:	29 ef                	sub    %ebp,%edi
  801d3f:	89 fe                	mov    %edi,%esi
  801d41:	89 7c 24 0c          	mov    %edi,0xc(%esp)

	      d1 = (d1 << bm) | (d0 >> b);
  801d45:	89 e9                	mov    %ebp,%ecx
  801d47:	d3 e0                	shl    %cl,%eax
  801d49:	89 d7                	mov    %edx,%edi
  801d4b:	89 f1                	mov    %esi,%ecx
  801d4d:	d3 ef                	shr    %cl,%edi
  801d4f:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  801d51:	89 e9                	mov    %ebp,%ecx
  801d53:	d3 e2                	shl    %cl,%edx
  801d55:	89 14 24             	mov    %edx,(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801d58:	89 d8                	mov    %ebx,%eax
  801d5a:	d3 e0                	shl    %cl,%eax
  801d5c:	89 c2                	mov    %eax,%edx
	      n0 = n0 << bm;
  801d5e:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d62:	d3 e0                	shl    %cl,%eax
  801d64:	89 44 24 04          	mov    %eax,0x4(%esp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801d68:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d6c:	89 f1                	mov    %esi,%ecx
  801d6e:	d3 e8                	shr    %cl,%eax
  801d70:	09 d0                	or     %edx,%eax
  801d72:	d3 eb                	shr    %cl,%ebx
  801d74:	89 da                	mov    %ebx,%edx
  801d76:	f7 f7                	div    %edi
  801d78:	89 d3                	mov    %edx,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  801d7a:	f7 24 24             	mull   (%esp)
  801d7d:	89 c6                	mov    %eax,%esi
  801d7f:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d81:	39 d3                	cmp    %edx,%ebx
  801d83:	0f 82 87 00 00 00    	jb     801e10 <__umoddi3+0x134>
  801d89:	0f 84 91 00 00 00    	je     801e20 <__umoddi3+0x144>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801d8f:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d93:	29 f2                	sub    %esi,%edx
  801d95:	19 cb                	sbb    %ecx,%ebx
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801d97:	89 d8                	mov    %ebx,%eax
  801d99:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  801d9d:	d3 e0                	shl    %cl,%eax
  801d9f:	89 e9                	mov    %ebp,%ecx
  801da1:	d3 ea                	shr    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801da3:	09 d0                	or     %edx,%eax
  801da5:	89 e9                	mov    %ebp,%ecx
  801da7:	d3 eb                	shr    %cl,%ebx
  801da9:	89 da                	mov    %ebx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801dab:	83 c4 1c             	add    $0x1c,%esp
  801dae:	5b                   	pop    %ebx
  801daf:	5e                   	pop    %esi
  801db0:	5f                   	pop    %edi
  801db1:	5d                   	pop    %ebp
  801db2:	c3                   	ret    
  801db3:	90                   	nop
  801db4:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801db6:	85 ff                	test   %edi,%edi
  801db8:	75 0b                	jne    801dc5 <__umoddi3+0xe9>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801dba:	b8 01 00 00 00       	mov    $0x1,%eax
  801dbf:	31 d2                	xor    %edx,%edx
  801dc1:	f7 f7                	div    %edi
  801dc3:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801dc5:	89 f0                	mov    %esi,%eax
  801dc7:	31 d2                	xor    %edx,%edx
  801dc9:	f7 f5                	div    %ebp
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801dcb:	89 c8                	mov    %ecx,%eax
  801dcd:	f7 f5                	div    %ebp
  801dcf:	89 d0                	mov    %edx,%eax
  801dd1:	e9 44 ff ff ff       	jmp    801d1a <__umoddi3+0x3e>
  801dd6:	66 90                	xchg   %ax,%ax
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801dd8:	89 c8                	mov    %ecx,%eax
  801dda:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801ddc:	83 c4 1c             	add    $0x1c,%esp
  801ddf:	5b                   	pop    %ebx
  801de0:	5e                   	pop    %esi
  801de1:	5f                   	pop    %edi
  801de2:	5d                   	pop    %ebp
  801de3:	c3                   	ret    

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801de4:	3b 04 24             	cmp    (%esp),%eax
  801de7:	72 06                	jb     801def <__umoddi3+0x113>
  801de9:	3b 7c 24 04          	cmp    0x4(%esp),%edi
  801ded:	77 0f                	ja     801dfe <__umoddi3+0x122>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801def:	89 f2                	mov    %esi,%edx
  801df1:	29 f9                	sub    %edi,%ecx
  801df3:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  801df7:	89 14 24             	mov    %edx,(%esp)
  801dfa:	89 4c 24 04          	mov    %ecx,0x4(%esp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801dfe:	8b 44 24 04          	mov    0x4(%esp),%eax
  801e02:	8b 14 24             	mov    (%esp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e05:	83 c4 1c             	add    $0x1c,%esp
  801e08:	5b                   	pop    %ebx
  801e09:	5e                   	pop    %esi
  801e0a:	5f                   	pop    %edi
  801e0b:	5d                   	pop    %ebp
  801e0c:	c3                   	ret    
  801e0d:	8d 76 00             	lea    0x0(%esi),%esi
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801e10:	2b 04 24             	sub    (%esp),%eax
  801e13:	19 fa                	sbb    %edi,%edx
  801e15:	89 d1                	mov    %edx,%ecx
  801e17:	89 c6                	mov    %eax,%esi
  801e19:	e9 71 ff ff ff       	jmp    801d8f <__umoddi3+0xb3>
  801e1e:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e20:	39 44 24 04          	cmp    %eax,0x4(%esp)
  801e24:	72 ea                	jb     801e10 <__umoddi3+0x134>
  801e26:	89 d9                	mov    %ebx,%ecx
  801e28:	e9 62 ff ff ff       	jmp    801d8f <__umoddi3+0xb3>
