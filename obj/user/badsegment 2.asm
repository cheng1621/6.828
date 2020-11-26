
obj/user/badsegment.debug:     file format elf32-i386


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
  80002c:	e8 0d 00 00 00       	call   80003e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800036:	66 b8 28 00          	mov    $0x28,%ax
  80003a:	8e d8                	mov    %eax,%ds
}
  80003c:	5d                   	pop    %ebp
  80003d:	c3                   	ret    

0080003e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003e:	55                   	push   %ebp
  80003f:	89 e5                	mov    %esp,%ebp
  800041:	56                   	push   %esi
  800042:	53                   	push   %ebx
  800043:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800046:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800049:	e8 d7 00 00 00       	call   800125 <sys_getenvid>
  80004e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800053:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80005a:	c1 e0 07             	shl    $0x7,%eax
  80005d:	29 d0                	sub    %edx,%eax
  80005f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800064:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800069:	85 db                	test   %ebx,%ebx
  80006b:	7e 07                	jle    800074 <libmain+0x36>
		binaryname = argv[0];
  80006d:	8b 06                	mov    (%esi),%eax
  80006f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800074:	83 ec 08             	sub    $0x8,%esp
  800077:	56                   	push   %esi
  800078:	53                   	push   %ebx
  800079:	e8 b5 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80007e:	e8 0a 00 00 00       	call   80008d <exit>
}
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800089:	5b                   	pop    %ebx
  80008a:	5e                   	pop    %esi
  80008b:	5d                   	pop    %ebp
  80008c:	c3                   	ret    

0080008d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008d:	55                   	push   %ebp
  80008e:	89 e5                	mov    %esp,%ebp
  800090:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800093:	e8 cb 04 00 00       	call   800563 <close_all>
	sys_env_destroy(0);
  800098:	83 ec 0c             	sub    $0xc,%esp
  80009b:	6a 00                	push   $0x0
  80009d:	e8 42 00 00 00       	call   8000e4 <sys_env_destroy>
}
  8000a2:	83 c4 10             	add    $0x10,%esp
  8000a5:	c9                   	leave  
  8000a6:	c3                   	ret    

008000a7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a7:	55                   	push   %ebp
  8000a8:	89 e5                	mov    %esp,%ebp
  8000aa:	57                   	push   %edi
  8000ab:	56                   	push   %esi
  8000ac:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b8:	89 c3                	mov    %eax,%ebx
  8000ba:	89 c7                	mov    %eax,%edi
  8000bc:	89 c6                	mov    %eax,%esi
  8000be:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c0:	5b                   	pop    %ebx
  8000c1:	5e                   	pop    %esi
  8000c2:	5f                   	pop    %edi
  8000c3:	5d                   	pop    %ebp
  8000c4:	c3                   	ret    

008000c5 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c5:	55                   	push   %ebp
  8000c6:	89 e5                	mov    %esp,%ebp
  8000c8:	57                   	push   %edi
  8000c9:	56                   	push   %esi
  8000ca:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d0:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d5:	89 d1                	mov    %edx,%ecx
  8000d7:	89 d3                	mov    %edx,%ebx
  8000d9:	89 d7                	mov    %edx,%edi
  8000db:	89 d6                	mov    %edx,%esi
  8000dd:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000df:	5b                   	pop    %ebx
  8000e0:	5e                   	pop    %esi
  8000e1:	5f                   	pop    %edi
  8000e2:	5d                   	pop    %ebp
  8000e3:	c3                   	ret    

008000e4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	57                   	push   %edi
  8000e8:	56                   	push   %esi
  8000e9:	53                   	push   %ebx
  8000ea:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f2:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fa:	89 cb                	mov    %ecx,%ebx
  8000fc:	89 cf                	mov    %ecx,%edi
  8000fe:	89 ce                	mov    %ecx,%esi
  800100:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800102:	85 c0                	test   %eax,%eax
  800104:	7e 17                	jle    80011d <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800106:	83 ec 0c             	sub    $0xc,%esp
  800109:	50                   	push   %eax
  80010a:	6a 03                	push   $0x3
  80010c:	68 4a 1e 80 00       	push   $0x801e4a
  800111:	6a 23                	push   $0x23
  800113:	68 67 1e 80 00       	push   $0x801e67
  800118:	e8 cf 0e 00 00       	call   800fec <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80011d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800120:	5b                   	pop    %ebx
  800121:	5e                   	pop    %esi
  800122:	5f                   	pop    %edi
  800123:	5d                   	pop    %ebp
  800124:	c3                   	ret    

00800125 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800125:	55                   	push   %ebp
  800126:	89 e5                	mov    %esp,%ebp
  800128:	57                   	push   %edi
  800129:	56                   	push   %esi
  80012a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80012b:	ba 00 00 00 00       	mov    $0x0,%edx
  800130:	b8 02 00 00 00       	mov    $0x2,%eax
  800135:	89 d1                	mov    %edx,%ecx
  800137:	89 d3                	mov    %edx,%ebx
  800139:	89 d7                	mov    %edx,%edi
  80013b:	89 d6                	mov    %edx,%esi
  80013d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013f:	5b                   	pop    %ebx
  800140:	5e                   	pop    %esi
  800141:	5f                   	pop    %edi
  800142:	5d                   	pop    %ebp
  800143:	c3                   	ret    

00800144 <sys_yield>:

void
sys_yield(void)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	57                   	push   %edi
  800148:	56                   	push   %esi
  800149:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014a:	ba 00 00 00 00       	mov    $0x0,%edx
  80014f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800154:	89 d1                	mov    %edx,%ecx
  800156:	89 d3                	mov    %edx,%ebx
  800158:	89 d7                	mov    %edx,%edi
  80015a:	89 d6                	mov    %edx,%esi
  80015c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80015e:	5b                   	pop    %ebx
  80015f:	5e                   	pop    %esi
  800160:	5f                   	pop    %edi
  800161:	5d                   	pop    %ebp
  800162:	c3                   	ret    

00800163 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	57                   	push   %edi
  800167:	56                   	push   %esi
  800168:	53                   	push   %ebx
  800169:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016c:	be 00 00 00 00       	mov    $0x0,%esi
  800171:	b8 04 00 00 00       	mov    $0x4,%eax
  800176:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800179:	8b 55 08             	mov    0x8(%ebp),%edx
  80017c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017f:	89 f7                	mov    %esi,%edi
  800181:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800183:	85 c0                	test   %eax,%eax
  800185:	7e 17                	jle    80019e <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800187:	83 ec 0c             	sub    $0xc,%esp
  80018a:	50                   	push   %eax
  80018b:	6a 04                	push   $0x4
  80018d:	68 4a 1e 80 00       	push   $0x801e4a
  800192:	6a 23                	push   $0x23
  800194:	68 67 1e 80 00       	push   $0x801e67
  800199:	e8 4e 0e 00 00       	call   800fec <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80019e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a1:	5b                   	pop    %ebx
  8001a2:	5e                   	pop    %esi
  8001a3:	5f                   	pop    %edi
  8001a4:	5d                   	pop    %ebp
  8001a5:	c3                   	ret    

008001a6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a6:	55                   	push   %ebp
  8001a7:	89 e5                	mov    %esp,%ebp
  8001a9:	57                   	push   %edi
  8001aa:	56                   	push   %esi
  8001ab:	53                   	push   %ebx
  8001ac:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001af:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ba:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001bd:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c0:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001c5:	85 c0                	test   %eax,%eax
  8001c7:	7e 17                	jle    8001e0 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c9:	83 ec 0c             	sub    $0xc,%esp
  8001cc:	50                   	push   %eax
  8001cd:	6a 05                	push   $0x5
  8001cf:	68 4a 1e 80 00       	push   $0x801e4a
  8001d4:	6a 23                	push   $0x23
  8001d6:	68 67 1e 80 00       	push   $0x801e67
  8001db:	e8 0c 0e 00 00       	call   800fec <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e3:	5b                   	pop    %ebx
  8001e4:	5e                   	pop    %esi
  8001e5:	5f                   	pop    %edi
  8001e6:	5d                   	pop    %ebp
  8001e7:	c3                   	ret    

008001e8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	57                   	push   %edi
  8001ec:	56                   	push   %esi
  8001ed:	53                   	push   %ebx
  8001ee:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f6:	b8 06 00 00 00       	mov    $0x6,%eax
  8001fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800201:	89 df                	mov    %ebx,%edi
  800203:	89 de                	mov    %ebx,%esi
  800205:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800207:	85 c0                	test   %eax,%eax
  800209:	7e 17                	jle    800222 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80020b:	83 ec 0c             	sub    $0xc,%esp
  80020e:	50                   	push   %eax
  80020f:	6a 06                	push   $0x6
  800211:	68 4a 1e 80 00       	push   $0x801e4a
  800216:	6a 23                	push   $0x23
  800218:	68 67 1e 80 00       	push   $0x801e67
  80021d:	e8 ca 0d 00 00       	call   800fec <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800222:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800225:	5b                   	pop    %ebx
  800226:	5e                   	pop    %esi
  800227:	5f                   	pop    %edi
  800228:	5d                   	pop    %ebp
  800229:	c3                   	ret    

0080022a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022a:	55                   	push   %ebp
  80022b:	89 e5                	mov    %esp,%ebp
  80022d:	57                   	push   %edi
  80022e:	56                   	push   %esi
  80022f:	53                   	push   %ebx
  800230:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800233:	bb 00 00 00 00       	mov    $0x0,%ebx
  800238:	b8 08 00 00 00       	mov    $0x8,%eax
  80023d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800240:	8b 55 08             	mov    0x8(%ebp),%edx
  800243:	89 df                	mov    %ebx,%edi
  800245:	89 de                	mov    %ebx,%esi
  800247:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800249:	85 c0                	test   %eax,%eax
  80024b:	7e 17                	jle    800264 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80024d:	83 ec 0c             	sub    $0xc,%esp
  800250:	50                   	push   %eax
  800251:	6a 08                	push   $0x8
  800253:	68 4a 1e 80 00       	push   $0x801e4a
  800258:	6a 23                	push   $0x23
  80025a:	68 67 1e 80 00       	push   $0x801e67
  80025f:	e8 88 0d 00 00       	call   800fec <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800264:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800267:	5b                   	pop    %ebx
  800268:	5e                   	pop    %esi
  800269:	5f                   	pop    %edi
  80026a:	5d                   	pop    %ebp
  80026b:	c3                   	ret    

0080026c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	57                   	push   %edi
  800270:	56                   	push   %esi
  800271:	53                   	push   %ebx
  800272:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800275:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027a:	b8 09 00 00 00       	mov    $0x9,%eax
  80027f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800282:	8b 55 08             	mov    0x8(%ebp),%edx
  800285:	89 df                	mov    %ebx,%edi
  800287:	89 de                	mov    %ebx,%esi
  800289:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80028b:	85 c0                	test   %eax,%eax
  80028d:	7e 17                	jle    8002a6 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028f:	83 ec 0c             	sub    $0xc,%esp
  800292:	50                   	push   %eax
  800293:	6a 09                	push   $0x9
  800295:	68 4a 1e 80 00       	push   $0x801e4a
  80029a:	6a 23                	push   $0x23
  80029c:	68 67 1e 80 00       	push   $0x801e67
  8002a1:	e8 46 0d 00 00       	call   800fec <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a9:	5b                   	pop    %ebx
  8002aa:	5e                   	pop    %esi
  8002ab:	5f                   	pop    %edi
  8002ac:	5d                   	pop    %ebp
  8002ad:	c3                   	ret    

008002ae <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
  8002b1:	57                   	push   %edi
  8002b2:	56                   	push   %esi
  8002b3:	53                   	push   %ebx
  8002b4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002bc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c7:	89 df                	mov    %ebx,%edi
  8002c9:	89 de                	mov    %ebx,%esi
  8002cb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002cd:	85 c0                	test   %eax,%eax
  8002cf:	7e 17                	jle    8002e8 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d1:	83 ec 0c             	sub    $0xc,%esp
  8002d4:	50                   	push   %eax
  8002d5:	6a 0a                	push   $0xa
  8002d7:	68 4a 1e 80 00       	push   $0x801e4a
  8002dc:	6a 23                	push   $0x23
  8002de:	68 67 1e 80 00       	push   $0x801e67
  8002e3:	e8 04 0d 00 00       	call   800fec <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002eb:	5b                   	pop    %ebx
  8002ec:	5e                   	pop    %esi
  8002ed:	5f                   	pop    %edi
  8002ee:	5d                   	pop    %ebp
  8002ef:	c3                   	ret    

008002f0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f0:	55                   	push   %ebp
  8002f1:	89 e5                	mov    %esp,%ebp
  8002f3:	57                   	push   %edi
  8002f4:	56                   	push   %esi
  8002f5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f6:	be 00 00 00 00       	mov    $0x0,%esi
  8002fb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800300:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800303:	8b 55 08             	mov    0x8(%ebp),%edx
  800306:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800309:	8b 7d 14             	mov    0x14(%ebp),%edi
  80030c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80030e:	5b                   	pop    %ebx
  80030f:	5e                   	pop    %esi
  800310:	5f                   	pop    %edi
  800311:	5d                   	pop    %ebp
  800312:	c3                   	ret    

00800313 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800313:	55                   	push   %ebp
  800314:	89 e5                	mov    %esp,%ebp
  800316:	57                   	push   %edi
  800317:	56                   	push   %esi
  800318:	53                   	push   %ebx
  800319:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80031c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800321:	b8 0d 00 00 00       	mov    $0xd,%eax
  800326:	8b 55 08             	mov    0x8(%ebp),%edx
  800329:	89 cb                	mov    %ecx,%ebx
  80032b:	89 cf                	mov    %ecx,%edi
  80032d:	89 ce                	mov    %ecx,%esi
  80032f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800331:	85 c0                	test   %eax,%eax
  800333:	7e 17                	jle    80034c <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800335:	83 ec 0c             	sub    $0xc,%esp
  800338:	50                   	push   %eax
  800339:	6a 0d                	push   $0xd
  80033b:	68 4a 1e 80 00       	push   $0x801e4a
  800340:	6a 23                	push   $0x23
  800342:	68 67 1e 80 00       	push   $0x801e67
  800347:	e8 a0 0c 00 00       	call   800fec <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80034c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034f:	5b                   	pop    %ebx
  800350:	5e                   	pop    %esi
  800351:	5f                   	pop    %edi
  800352:	5d                   	pop    %ebp
  800353:	c3                   	ret    

00800354 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800354:	55                   	push   %ebp
  800355:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800357:	8b 45 08             	mov    0x8(%ebp),%eax
  80035a:	05 00 00 00 30       	add    $0x30000000,%eax
  80035f:	c1 e8 0c             	shr    $0xc,%eax
}
  800362:	5d                   	pop    %ebp
  800363:	c3                   	ret    

00800364 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800364:	55                   	push   %ebp
  800365:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800367:	8b 45 08             	mov    0x8(%ebp),%eax
  80036a:	05 00 00 00 30       	add    $0x30000000,%eax
  80036f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800374:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800379:	5d                   	pop    %ebp
  80037a:	c3                   	ret    

0080037b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80037b:	55                   	push   %ebp
  80037c:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80037e:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800383:	a8 01                	test   $0x1,%al
  800385:	74 34                	je     8003bb <fd_alloc+0x40>
  800387:	a1 00 00 74 ef       	mov    0xef740000,%eax
  80038c:	a8 01                	test   $0x1,%al
  80038e:	74 32                	je     8003c2 <fd_alloc+0x47>
  800390:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800395:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800397:	89 c2                	mov    %eax,%edx
  800399:	c1 ea 16             	shr    $0x16,%edx
  80039c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003a3:	f6 c2 01             	test   $0x1,%dl
  8003a6:	74 1f                	je     8003c7 <fd_alloc+0x4c>
  8003a8:	89 c2                	mov    %eax,%edx
  8003aa:	c1 ea 0c             	shr    $0xc,%edx
  8003ad:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003b4:	f6 c2 01             	test   $0x1,%dl
  8003b7:	75 1a                	jne    8003d3 <fd_alloc+0x58>
  8003b9:	eb 0c                	jmp    8003c7 <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8003bb:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8003c0:	eb 05                	jmp    8003c7 <fd_alloc+0x4c>
  8003c2:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8003c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ca:	89 08                	mov    %ecx,(%eax)
			return 0;
  8003cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8003d1:	eb 1a                	jmp    8003ed <fd_alloc+0x72>
  8003d3:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003d8:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003dd:	75 b6                	jne    800395 <fd_alloc+0x1a>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003df:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  8003e8:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003ed:	5d                   	pop    %ebp
  8003ee:	c3                   	ret    

008003ef <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003ef:	55                   	push   %ebp
  8003f0:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003f2:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  8003f6:	77 39                	ja     800431 <fd_lookup+0x42>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8003fb:	c1 e0 0c             	shl    $0xc,%eax
  8003fe:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800403:	89 c2                	mov    %eax,%edx
  800405:	c1 ea 16             	shr    $0x16,%edx
  800408:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80040f:	f6 c2 01             	test   $0x1,%dl
  800412:	74 24                	je     800438 <fd_lookup+0x49>
  800414:	89 c2                	mov    %eax,%edx
  800416:	c1 ea 0c             	shr    $0xc,%edx
  800419:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800420:	f6 c2 01             	test   $0x1,%dl
  800423:	74 1a                	je     80043f <fd_lookup+0x50>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800425:	8b 55 0c             	mov    0xc(%ebp),%edx
  800428:	89 02                	mov    %eax,(%edx)
	return 0;
  80042a:	b8 00 00 00 00       	mov    $0x0,%eax
  80042f:	eb 13                	jmp    800444 <fd_lookup+0x55>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800431:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800436:	eb 0c                	jmp    800444 <fd_lookup+0x55>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800438:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80043d:	eb 05                	jmp    800444 <fd_lookup+0x55>
  80043f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800444:	5d                   	pop    %ebp
  800445:	c3                   	ret    

00800446 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800446:	55                   	push   %ebp
  800447:	89 e5                	mov    %esp,%ebp
  800449:	53                   	push   %ebx
  80044a:	83 ec 04             	sub    $0x4,%esp
  80044d:	8b 45 08             	mov    0x8(%ebp),%eax
  800450:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800453:	3b 05 04 30 80 00    	cmp    0x803004,%eax
  800459:	75 1e                	jne    800479 <dev_lookup+0x33>
  80045b:	eb 0e                	jmp    80046b <dev_lookup+0x25>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80045d:	b8 20 30 80 00       	mov    $0x803020,%eax
  800462:	eb 0c                	jmp    800470 <dev_lookup+0x2a>
  800464:	b8 3c 30 80 00       	mov    $0x80303c,%eax
  800469:	eb 05                	jmp    800470 <dev_lookup+0x2a>
  80046b:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800470:	89 03                	mov    %eax,(%ebx)
			return 0;
  800472:	b8 00 00 00 00       	mov    $0x0,%eax
  800477:	eb 36                	jmp    8004af <dev_lookup+0x69>
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800479:	3b 05 20 30 80 00    	cmp    0x803020,%eax
  80047f:	74 dc                	je     80045d <dev_lookup+0x17>
  800481:	3b 05 3c 30 80 00    	cmp    0x80303c,%eax
  800487:	74 db                	je     800464 <dev_lookup+0x1e>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800489:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80048f:	8b 52 48             	mov    0x48(%edx),%edx
  800492:	83 ec 04             	sub    $0x4,%esp
  800495:	50                   	push   %eax
  800496:	52                   	push   %edx
  800497:	68 78 1e 80 00       	push   $0x801e78
  80049c:	e8 23 0c 00 00       	call   8010c4 <cprintf>
	*dev = 0;
  8004a1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8004a7:	83 c4 10             	add    $0x10,%esp
  8004aa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004b2:	c9                   	leave  
  8004b3:	c3                   	ret    

008004b4 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004b4:	55                   	push   %ebp
  8004b5:	89 e5                	mov    %esp,%ebp
  8004b7:	56                   	push   %esi
  8004b8:	53                   	push   %ebx
  8004b9:	83 ec 10             	sub    $0x10,%esp
  8004bc:	8b 75 08             	mov    0x8(%ebp),%esi
  8004bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004c5:	50                   	push   %eax
  8004c6:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004cc:	c1 e8 0c             	shr    $0xc,%eax
  8004cf:	50                   	push   %eax
  8004d0:	e8 1a ff ff ff       	call   8003ef <fd_lookup>
  8004d5:	83 c4 08             	add    $0x8,%esp
  8004d8:	85 c0                	test   %eax,%eax
  8004da:	78 05                	js     8004e1 <fd_close+0x2d>
	    || fd != fd2)
  8004dc:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004df:	74 06                	je     8004e7 <fd_close+0x33>
		return (must_exist ? r : 0);
  8004e1:	84 db                	test   %bl,%bl
  8004e3:	74 47                	je     80052c <fd_close+0x78>
  8004e5:	eb 4a                	jmp    800531 <fd_close+0x7d>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004e7:	83 ec 08             	sub    $0x8,%esp
  8004ea:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004ed:	50                   	push   %eax
  8004ee:	ff 36                	pushl  (%esi)
  8004f0:	e8 51 ff ff ff       	call   800446 <dev_lookup>
  8004f5:	89 c3                	mov    %eax,%ebx
  8004f7:	83 c4 10             	add    $0x10,%esp
  8004fa:	85 c0                	test   %eax,%eax
  8004fc:	78 1c                	js     80051a <fd_close+0x66>
		if (dev->dev_close)
  8004fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800501:	8b 40 10             	mov    0x10(%eax),%eax
  800504:	85 c0                	test   %eax,%eax
  800506:	74 0d                	je     800515 <fd_close+0x61>
			r = (*dev->dev_close)(fd);
  800508:	83 ec 0c             	sub    $0xc,%esp
  80050b:	56                   	push   %esi
  80050c:	ff d0                	call   *%eax
  80050e:	89 c3                	mov    %eax,%ebx
  800510:	83 c4 10             	add    $0x10,%esp
  800513:	eb 05                	jmp    80051a <fd_close+0x66>
		else
			r = 0;
  800515:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80051a:	83 ec 08             	sub    $0x8,%esp
  80051d:	56                   	push   %esi
  80051e:	6a 00                	push   $0x0
  800520:	e8 c3 fc ff ff       	call   8001e8 <sys_page_unmap>
	return r;
  800525:	83 c4 10             	add    $0x10,%esp
  800528:	89 d8                	mov    %ebx,%eax
  80052a:	eb 05                	jmp    800531 <fd_close+0x7d>
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
  80052c:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
	return r;
}
  800531:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800534:	5b                   	pop    %ebx
  800535:	5e                   	pop    %esi
  800536:	5d                   	pop    %ebp
  800537:	c3                   	ret    

00800538 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800538:	55                   	push   %ebp
  800539:	89 e5                	mov    %esp,%ebp
  80053b:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80053e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800541:	50                   	push   %eax
  800542:	ff 75 08             	pushl  0x8(%ebp)
  800545:	e8 a5 fe ff ff       	call   8003ef <fd_lookup>
  80054a:	83 c4 08             	add    $0x8,%esp
  80054d:	85 c0                	test   %eax,%eax
  80054f:	78 10                	js     800561 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800551:	83 ec 08             	sub    $0x8,%esp
  800554:	6a 01                	push   $0x1
  800556:	ff 75 f4             	pushl  -0xc(%ebp)
  800559:	e8 56 ff ff ff       	call   8004b4 <fd_close>
  80055e:	83 c4 10             	add    $0x10,%esp
}
  800561:	c9                   	leave  
  800562:	c3                   	ret    

00800563 <close_all>:

void
close_all(void)
{
  800563:	55                   	push   %ebp
  800564:	89 e5                	mov    %esp,%ebp
  800566:	53                   	push   %ebx
  800567:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80056a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80056f:	83 ec 0c             	sub    $0xc,%esp
  800572:	53                   	push   %ebx
  800573:	e8 c0 ff ff ff       	call   800538 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800578:	43                   	inc    %ebx
  800579:	83 c4 10             	add    $0x10,%esp
  80057c:	83 fb 20             	cmp    $0x20,%ebx
  80057f:	75 ee                	jne    80056f <close_all+0xc>
		close(i);
}
  800581:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800584:	c9                   	leave  
  800585:	c3                   	ret    

00800586 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800586:	55                   	push   %ebp
  800587:	89 e5                	mov    %esp,%ebp
  800589:	57                   	push   %edi
  80058a:	56                   	push   %esi
  80058b:	53                   	push   %ebx
  80058c:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80058f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800592:	50                   	push   %eax
  800593:	ff 75 08             	pushl  0x8(%ebp)
  800596:	e8 54 fe ff ff       	call   8003ef <fd_lookup>
  80059b:	83 c4 08             	add    $0x8,%esp
  80059e:	85 c0                	test   %eax,%eax
  8005a0:	0f 88 c2 00 00 00    	js     800668 <dup+0xe2>
		return r;
	close(newfdnum);
  8005a6:	83 ec 0c             	sub    $0xc,%esp
  8005a9:	ff 75 0c             	pushl  0xc(%ebp)
  8005ac:	e8 87 ff ff ff       	call   800538 <close>

	newfd = INDEX2FD(newfdnum);
  8005b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005b4:	c1 e3 0c             	shl    $0xc,%ebx
  8005b7:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8005bd:	83 c4 04             	add    $0x4,%esp
  8005c0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005c3:	e8 9c fd ff ff       	call   800364 <fd2data>
  8005c8:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  8005ca:	89 1c 24             	mov    %ebx,(%esp)
  8005cd:	e8 92 fd ff ff       	call   800364 <fd2data>
  8005d2:	83 c4 10             	add    $0x10,%esp
  8005d5:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005d7:	89 f0                	mov    %esi,%eax
  8005d9:	c1 e8 16             	shr    $0x16,%eax
  8005dc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005e3:	a8 01                	test   $0x1,%al
  8005e5:	74 35                	je     80061c <dup+0x96>
  8005e7:	89 f0                	mov    %esi,%eax
  8005e9:	c1 e8 0c             	shr    $0xc,%eax
  8005ec:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005f3:	f6 c2 01             	test   $0x1,%dl
  8005f6:	74 24                	je     80061c <dup+0x96>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005f8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005ff:	83 ec 0c             	sub    $0xc,%esp
  800602:	25 07 0e 00 00       	and    $0xe07,%eax
  800607:	50                   	push   %eax
  800608:	57                   	push   %edi
  800609:	6a 00                	push   $0x0
  80060b:	56                   	push   %esi
  80060c:	6a 00                	push   $0x0
  80060e:	e8 93 fb ff ff       	call   8001a6 <sys_page_map>
  800613:	89 c6                	mov    %eax,%esi
  800615:	83 c4 20             	add    $0x20,%esp
  800618:	85 c0                	test   %eax,%eax
  80061a:	78 2c                	js     800648 <dup+0xc2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80061c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80061f:	89 d0                	mov    %edx,%eax
  800621:	c1 e8 0c             	shr    $0xc,%eax
  800624:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80062b:	83 ec 0c             	sub    $0xc,%esp
  80062e:	25 07 0e 00 00       	and    $0xe07,%eax
  800633:	50                   	push   %eax
  800634:	53                   	push   %ebx
  800635:	6a 00                	push   $0x0
  800637:	52                   	push   %edx
  800638:	6a 00                	push   $0x0
  80063a:	e8 67 fb ff ff       	call   8001a6 <sys_page_map>
  80063f:	89 c6                	mov    %eax,%esi
  800641:	83 c4 20             	add    $0x20,%esp
  800644:	85 c0                	test   %eax,%eax
  800646:	79 1d                	jns    800665 <dup+0xdf>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800648:	83 ec 08             	sub    $0x8,%esp
  80064b:	53                   	push   %ebx
  80064c:	6a 00                	push   $0x0
  80064e:	e8 95 fb ff ff       	call   8001e8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800653:	83 c4 08             	add    $0x8,%esp
  800656:	57                   	push   %edi
  800657:	6a 00                	push   $0x0
  800659:	e8 8a fb ff ff       	call   8001e8 <sys_page_unmap>
	return r;
  80065e:	83 c4 10             	add    $0x10,%esp
  800661:	89 f0                	mov    %esi,%eax
  800663:	eb 03                	jmp    800668 <dup+0xe2>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  800665:	8b 45 0c             	mov    0xc(%ebp),%eax

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800668:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80066b:	5b                   	pop    %ebx
  80066c:	5e                   	pop    %esi
  80066d:	5f                   	pop    %edi
  80066e:	5d                   	pop    %ebp
  80066f:	c3                   	ret    

00800670 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800670:	55                   	push   %ebp
  800671:	89 e5                	mov    %esp,%ebp
  800673:	53                   	push   %ebx
  800674:	83 ec 14             	sub    $0x14,%esp
  800677:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80067a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80067d:	50                   	push   %eax
  80067e:	53                   	push   %ebx
  80067f:	e8 6b fd ff ff       	call   8003ef <fd_lookup>
  800684:	83 c4 08             	add    $0x8,%esp
  800687:	85 c0                	test   %eax,%eax
  800689:	78 67                	js     8006f2 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80068b:	83 ec 08             	sub    $0x8,%esp
  80068e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800691:	50                   	push   %eax
  800692:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800695:	ff 30                	pushl  (%eax)
  800697:	e8 aa fd ff ff       	call   800446 <dev_lookup>
  80069c:	83 c4 10             	add    $0x10,%esp
  80069f:	85 c0                	test   %eax,%eax
  8006a1:	78 4f                	js     8006f2 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006a3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006a6:	8b 42 08             	mov    0x8(%edx),%eax
  8006a9:	83 e0 03             	and    $0x3,%eax
  8006ac:	83 f8 01             	cmp    $0x1,%eax
  8006af:	75 21                	jne    8006d2 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006b1:	a1 04 40 80 00       	mov    0x804004,%eax
  8006b6:	8b 40 48             	mov    0x48(%eax),%eax
  8006b9:	83 ec 04             	sub    $0x4,%esp
  8006bc:	53                   	push   %ebx
  8006bd:	50                   	push   %eax
  8006be:	68 b9 1e 80 00       	push   $0x801eb9
  8006c3:	e8 fc 09 00 00       	call   8010c4 <cprintf>
		return -E_INVAL;
  8006c8:	83 c4 10             	add    $0x10,%esp
  8006cb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006d0:	eb 20                	jmp    8006f2 <read+0x82>
	}
	if (!dev->dev_read)
  8006d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006d5:	8b 40 08             	mov    0x8(%eax),%eax
  8006d8:	85 c0                	test   %eax,%eax
  8006da:	74 11                	je     8006ed <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006dc:	83 ec 04             	sub    $0x4,%esp
  8006df:	ff 75 10             	pushl  0x10(%ebp)
  8006e2:	ff 75 0c             	pushl  0xc(%ebp)
  8006e5:	52                   	push   %edx
  8006e6:	ff d0                	call   *%eax
  8006e8:	83 c4 10             	add    $0x10,%esp
  8006eb:	eb 05                	jmp    8006f2 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006ed:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8006f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006f5:	c9                   	leave  
  8006f6:	c3                   	ret    

008006f7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006f7:	55                   	push   %ebp
  8006f8:	89 e5                	mov    %esp,%ebp
  8006fa:	57                   	push   %edi
  8006fb:	56                   	push   %esi
  8006fc:	53                   	push   %ebx
  8006fd:	83 ec 0c             	sub    $0xc,%esp
  800700:	8b 7d 08             	mov    0x8(%ebp),%edi
  800703:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800706:	85 f6                	test   %esi,%esi
  800708:	74 31                	je     80073b <readn+0x44>
  80070a:	b8 00 00 00 00       	mov    $0x0,%eax
  80070f:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  800714:	83 ec 04             	sub    $0x4,%esp
  800717:	89 f2                	mov    %esi,%edx
  800719:	29 c2                	sub    %eax,%edx
  80071b:	52                   	push   %edx
  80071c:	03 45 0c             	add    0xc(%ebp),%eax
  80071f:	50                   	push   %eax
  800720:	57                   	push   %edi
  800721:	e8 4a ff ff ff       	call   800670 <read>
		if (m < 0)
  800726:	83 c4 10             	add    $0x10,%esp
  800729:	85 c0                	test   %eax,%eax
  80072b:	78 17                	js     800744 <readn+0x4d>
			return m;
		if (m == 0)
  80072d:	85 c0                	test   %eax,%eax
  80072f:	74 11                	je     800742 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800731:	01 c3                	add    %eax,%ebx
  800733:	89 d8                	mov    %ebx,%eax
  800735:	39 f3                	cmp    %esi,%ebx
  800737:	72 db                	jb     800714 <readn+0x1d>
  800739:	eb 09                	jmp    800744 <readn+0x4d>
  80073b:	b8 00 00 00 00       	mov    $0x0,%eax
  800740:	eb 02                	jmp    800744 <readn+0x4d>
  800742:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800744:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800747:	5b                   	pop    %ebx
  800748:	5e                   	pop    %esi
  800749:	5f                   	pop    %edi
  80074a:	5d                   	pop    %ebp
  80074b:	c3                   	ret    

0080074c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80074c:	55                   	push   %ebp
  80074d:	89 e5                	mov    %esp,%ebp
  80074f:	53                   	push   %ebx
  800750:	83 ec 14             	sub    $0x14,%esp
  800753:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800756:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800759:	50                   	push   %eax
  80075a:	53                   	push   %ebx
  80075b:	e8 8f fc ff ff       	call   8003ef <fd_lookup>
  800760:	83 c4 08             	add    $0x8,%esp
  800763:	85 c0                	test   %eax,%eax
  800765:	78 62                	js     8007c9 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800767:	83 ec 08             	sub    $0x8,%esp
  80076a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80076d:	50                   	push   %eax
  80076e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800771:	ff 30                	pushl  (%eax)
  800773:	e8 ce fc ff ff       	call   800446 <dev_lookup>
  800778:	83 c4 10             	add    $0x10,%esp
  80077b:	85 c0                	test   %eax,%eax
  80077d:	78 4a                	js     8007c9 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80077f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800782:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800786:	75 21                	jne    8007a9 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800788:	a1 04 40 80 00       	mov    0x804004,%eax
  80078d:	8b 40 48             	mov    0x48(%eax),%eax
  800790:	83 ec 04             	sub    $0x4,%esp
  800793:	53                   	push   %ebx
  800794:	50                   	push   %eax
  800795:	68 d5 1e 80 00       	push   $0x801ed5
  80079a:	e8 25 09 00 00       	call   8010c4 <cprintf>
		return -E_INVAL;
  80079f:	83 c4 10             	add    $0x10,%esp
  8007a2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007a7:	eb 20                	jmp    8007c9 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007a9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007ac:	8b 52 0c             	mov    0xc(%edx),%edx
  8007af:	85 d2                	test   %edx,%edx
  8007b1:	74 11                	je     8007c4 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007b3:	83 ec 04             	sub    $0x4,%esp
  8007b6:	ff 75 10             	pushl  0x10(%ebp)
  8007b9:	ff 75 0c             	pushl  0xc(%ebp)
  8007bc:	50                   	push   %eax
  8007bd:	ff d2                	call   *%edx
  8007bf:	83 c4 10             	add    $0x10,%esp
  8007c2:	eb 05                	jmp    8007c9 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007c4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8007c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007cc:	c9                   	leave  
  8007cd:	c3                   	ret    

008007ce <seek>:

int
seek(int fdnum, off_t offset)
{
  8007ce:	55                   	push   %ebp
  8007cf:	89 e5                	mov    %esp,%ebp
  8007d1:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007d4:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007d7:	50                   	push   %eax
  8007d8:	ff 75 08             	pushl  0x8(%ebp)
  8007db:	e8 0f fc ff ff       	call   8003ef <fd_lookup>
  8007e0:	83 c4 08             	add    $0x8,%esp
  8007e3:	85 c0                	test   %eax,%eax
  8007e5:	78 0e                	js     8007f5 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ed:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007f5:	c9                   	leave  
  8007f6:	c3                   	ret    

008007f7 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007f7:	55                   	push   %ebp
  8007f8:	89 e5                	mov    %esp,%ebp
  8007fa:	53                   	push   %ebx
  8007fb:	83 ec 14             	sub    $0x14,%esp
  8007fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800801:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800804:	50                   	push   %eax
  800805:	53                   	push   %ebx
  800806:	e8 e4 fb ff ff       	call   8003ef <fd_lookup>
  80080b:	83 c4 08             	add    $0x8,%esp
  80080e:	85 c0                	test   %eax,%eax
  800810:	78 5f                	js     800871 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800812:	83 ec 08             	sub    $0x8,%esp
  800815:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800818:	50                   	push   %eax
  800819:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80081c:	ff 30                	pushl  (%eax)
  80081e:	e8 23 fc ff ff       	call   800446 <dev_lookup>
  800823:	83 c4 10             	add    $0x10,%esp
  800826:	85 c0                	test   %eax,%eax
  800828:	78 47                	js     800871 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80082a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80082d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800831:	75 21                	jne    800854 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800833:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800838:	8b 40 48             	mov    0x48(%eax),%eax
  80083b:	83 ec 04             	sub    $0x4,%esp
  80083e:	53                   	push   %ebx
  80083f:	50                   	push   %eax
  800840:	68 98 1e 80 00       	push   $0x801e98
  800845:	e8 7a 08 00 00       	call   8010c4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80084a:	83 c4 10             	add    $0x10,%esp
  80084d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800852:	eb 1d                	jmp    800871 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  800854:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800857:	8b 52 18             	mov    0x18(%edx),%edx
  80085a:	85 d2                	test   %edx,%edx
  80085c:	74 0e                	je     80086c <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80085e:	83 ec 08             	sub    $0x8,%esp
  800861:	ff 75 0c             	pushl  0xc(%ebp)
  800864:	50                   	push   %eax
  800865:	ff d2                	call   *%edx
  800867:	83 c4 10             	add    $0x10,%esp
  80086a:	eb 05                	jmp    800871 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80086c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  800871:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800874:	c9                   	leave  
  800875:	c3                   	ret    

00800876 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800876:	55                   	push   %ebp
  800877:	89 e5                	mov    %esp,%ebp
  800879:	53                   	push   %ebx
  80087a:	83 ec 14             	sub    $0x14,%esp
  80087d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800880:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800883:	50                   	push   %eax
  800884:	ff 75 08             	pushl  0x8(%ebp)
  800887:	e8 63 fb ff ff       	call   8003ef <fd_lookup>
  80088c:	83 c4 08             	add    $0x8,%esp
  80088f:	85 c0                	test   %eax,%eax
  800891:	78 52                	js     8008e5 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800893:	83 ec 08             	sub    $0x8,%esp
  800896:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800899:	50                   	push   %eax
  80089a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80089d:	ff 30                	pushl  (%eax)
  80089f:	e8 a2 fb ff ff       	call   800446 <dev_lookup>
  8008a4:	83 c4 10             	add    $0x10,%esp
  8008a7:	85 c0                	test   %eax,%eax
  8008a9:	78 3a                	js     8008e5 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  8008ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008ae:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008b2:	74 2c                	je     8008e0 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008b4:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008b7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008be:	00 00 00 
	stat->st_isdir = 0;
  8008c1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008c8:	00 00 00 
	stat->st_dev = dev;
  8008cb:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008d1:	83 ec 08             	sub    $0x8,%esp
  8008d4:	53                   	push   %ebx
  8008d5:	ff 75 f0             	pushl  -0x10(%ebp)
  8008d8:	ff 50 14             	call   *0x14(%eax)
  8008db:	83 c4 10             	add    $0x10,%esp
  8008de:	eb 05                	jmp    8008e5 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008e0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008e8:	c9                   	leave  
  8008e9:	c3                   	ret    

008008ea <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008ea:	55                   	push   %ebp
  8008eb:	89 e5                	mov    %esp,%ebp
  8008ed:	56                   	push   %esi
  8008ee:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008ef:	83 ec 08             	sub    $0x8,%esp
  8008f2:	6a 00                	push   $0x0
  8008f4:	ff 75 08             	pushl  0x8(%ebp)
  8008f7:	e8 75 01 00 00       	call   800a71 <open>
  8008fc:	89 c3                	mov    %eax,%ebx
  8008fe:	83 c4 10             	add    $0x10,%esp
  800901:	85 c0                	test   %eax,%eax
  800903:	78 1d                	js     800922 <stat+0x38>
		return fd;
	r = fstat(fd, stat);
  800905:	83 ec 08             	sub    $0x8,%esp
  800908:	ff 75 0c             	pushl  0xc(%ebp)
  80090b:	50                   	push   %eax
  80090c:	e8 65 ff ff ff       	call   800876 <fstat>
  800911:	89 c6                	mov    %eax,%esi
	close(fd);
  800913:	89 1c 24             	mov    %ebx,(%esp)
  800916:	e8 1d fc ff ff       	call   800538 <close>
	return r;
  80091b:	83 c4 10             	add    $0x10,%esp
  80091e:	89 f0                	mov    %esi,%eax
  800920:	eb 00                	jmp    800922 <stat+0x38>
}
  800922:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800925:	5b                   	pop    %ebx
  800926:	5e                   	pop    %esi
  800927:	5d                   	pop    %ebp
  800928:	c3                   	ret    

00800929 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800929:	55                   	push   %ebp
  80092a:	89 e5                	mov    %esp,%ebp
  80092c:	56                   	push   %esi
  80092d:	53                   	push   %ebx
  80092e:	89 c6                	mov    %eax,%esi
  800930:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800932:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800939:	75 12                	jne    80094d <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80093b:	83 ec 0c             	sub    $0xc,%esp
  80093e:	6a 01                	push   $0x1
  800940:	e8 ec 11 00 00       	call   801b31 <ipc_find_env>
  800945:	a3 00 40 80 00       	mov    %eax,0x804000
  80094a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80094d:	6a 07                	push   $0x7
  80094f:	68 00 50 80 00       	push   $0x805000
  800954:	56                   	push   %esi
  800955:	ff 35 00 40 80 00    	pushl  0x804000
  80095b:	e8 72 11 00 00       	call   801ad2 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800960:	83 c4 0c             	add    $0xc,%esp
  800963:	6a 00                	push   $0x0
  800965:	53                   	push   %ebx
  800966:	6a 00                	push   $0x0
  800968:	e8 f0 10 00 00       	call   801a5d <ipc_recv>
}
  80096d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800970:	5b                   	pop    %ebx
  800971:	5e                   	pop    %esi
  800972:	5d                   	pop    %ebp
  800973:	c3                   	ret    

00800974 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800974:	55                   	push   %ebp
  800975:	89 e5                	mov    %esp,%ebp
  800977:	53                   	push   %ebx
  800978:	83 ec 04             	sub    $0x4,%esp
  80097b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80097e:	8b 45 08             	mov    0x8(%ebp),%eax
  800981:	8b 40 0c             	mov    0xc(%eax),%eax
  800984:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800989:	ba 00 00 00 00       	mov    $0x0,%edx
  80098e:	b8 05 00 00 00       	mov    $0x5,%eax
  800993:	e8 91 ff ff ff       	call   800929 <fsipc>
  800998:	85 c0                	test   %eax,%eax
  80099a:	78 2c                	js     8009c8 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80099c:	83 ec 08             	sub    $0x8,%esp
  80099f:	68 00 50 80 00       	push   $0x805000
  8009a4:	53                   	push   %ebx
  8009a5:	e8 ff 0c 00 00       	call   8016a9 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009aa:	a1 80 50 80 00       	mov    0x805080,%eax
  8009af:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009b5:	a1 84 50 80 00       	mov    0x805084,%eax
  8009ba:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009c0:	83 c4 10             	add    $0x10,%esp
  8009c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009cb:	c9                   	leave  
  8009cc:	c3                   	ret    

008009cd <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009cd:	55                   	push   %ebp
  8009ce:	89 e5                	mov    %esp,%ebp
  8009d0:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d6:	8b 40 0c             	mov    0xc(%eax),%eax
  8009d9:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009de:	ba 00 00 00 00       	mov    $0x0,%edx
  8009e3:	b8 06 00 00 00       	mov    $0x6,%eax
  8009e8:	e8 3c ff ff ff       	call   800929 <fsipc>
}
  8009ed:	c9                   	leave  
  8009ee:	c3                   	ret    

008009ef <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8009ef:	55                   	push   %ebp
  8009f0:	89 e5                	mov    %esp,%ebp
  8009f2:	56                   	push   %esi
  8009f3:	53                   	push   %ebx
  8009f4:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8009f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fa:	8b 40 0c             	mov    0xc(%eax),%eax
  8009fd:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a02:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a08:	ba 00 00 00 00       	mov    $0x0,%edx
  800a0d:	b8 03 00 00 00       	mov    $0x3,%eax
  800a12:	e8 12 ff ff ff       	call   800929 <fsipc>
  800a17:	89 c3                	mov    %eax,%ebx
  800a19:	85 c0                	test   %eax,%eax
  800a1b:	78 4b                	js     800a68 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a1d:	39 c6                	cmp    %eax,%esi
  800a1f:	73 16                	jae    800a37 <devfile_read+0x48>
  800a21:	68 f2 1e 80 00       	push   $0x801ef2
  800a26:	68 f9 1e 80 00       	push   $0x801ef9
  800a2b:	6a 7a                	push   $0x7a
  800a2d:	68 0e 1f 80 00       	push   $0x801f0e
  800a32:	e8 b5 05 00 00       	call   800fec <_panic>
	assert(r <= PGSIZE);
  800a37:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a3c:	7e 16                	jle    800a54 <devfile_read+0x65>
  800a3e:	68 19 1f 80 00       	push   $0x801f19
  800a43:	68 f9 1e 80 00       	push   $0x801ef9
  800a48:	6a 7b                	push   $0x7b
  800a4a:	68 0e 1f 80 00       	push   $0x801f0e
  800a4f:	e8 98 05 00 00       	call   800fec <_panic>
	memmove(buf, &fsipcbuf, r);
  800a54:	83 ec 04             	sub    $0x4,%esp
  800a57:	50                   	push   %eax
  800a58:	68 00 50 80 00       	push   $0x805000
  800a5d:	ff 75 0c             	pushl  0xc(%ebp)
  800a60:	e8 11 0e 00 00       	call   801876 <memmove>
	return r;
  800a65:	83 c4 10             	add    $0x10,%esp
}
  800a68:	89 d8                	mov    %ebx,%eax
  800a6a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a6d:	5b                   	pop    %ebx
  800a6e:	5e                   	pop    %esi
  800a6f:	5d                   	pop    %ebp
  800a70:	c3                   	ret    

00800a71 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800a71:	55                   	push   %ebp
  800a72:	89 e5                	mov    %esp,%ebp
  800a74:	53                   	push   %ebx
  800a75:	83 ec 20             	sub    $0x20,%esp
  800a78:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800a7b:	53                   	push   %ebx
  800a7c:	e8 d1 0b 00 00       	call   801652 <strlen>
  800a81:	83 c4 10             	add    $0x10,%esp
  800a84:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800a89:	7f 63                	jg     800aee <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800a8b:	83 ec 0c             	sub    $0xc,%esp
  800a8e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a91:	50                   	push   %eax
  800a92:	e8 e4 f8 ff ff       	call   80037b <fd_alloc>
  800a97:	83 c4 10             	add    $0x10,%esp
  800a9a:	85 c0                	test   %eax,%eax
  800a9c:	78 55                	js     800af3 <open+0x82>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800a9e:	83 ec 08             	sub    $0x8,%esp
  800aa1:	53                   	push   %ebx
  800aa2:	68 00 50 80 00       	push   $0x805000
  800aa7:	e8 fd 0b 00 00       	call   8016a9 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800aac:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aaf:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800ab4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ab7:	b8 01 00 00 00       	mov    $0x1,%eax
  800abc:	e8 68 fe ff ff       	call   800929 <fsipc>
  800ac1:	89 c3                	mov    %eax,%ebx
  800ac3:	83 c4 10             	add    $0x10,%esp
  800ac6:	85 c0                	test   %eax,%eax
  800ac8:	79 14                	jns    800ade <open+0x6d>
		fd_close(fd, 0);
  800aca:	83 ec 08             	sub    $0x8,%esp
  800acd:	6a 00                	push   $0x0
  800acf:	ff 75 f4             	pushl  -0xc(%ebp)
  800ad2:	e8 dd f9 ff ff       	call   8004b4 <fd_close>
		return r;
  800ad7:	83 c4 10             	add    $0x10,%esp
  800ada:	89 d8                	mov    %ebx,%eax
  800adc:	eb 15                	jmp    800af3 <open+0x82>
	}

	return fd2num(fd);
  800ade:	83 ec 0c             	sub    $0xc,%esp
  800ae1:	ff 75 f4             	pushl  -0xc(%ebp)
  800ae4:	e8 6b f8 ff ff       	call   800354 <fd2num>
  800ae9:	83 c4 10             	add    $0x10,%esp
  800aec:	eb 05                	jmp    800af3 <open+0x82>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800aee:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800af3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800af6:	c9                   	leave  
  800af7:	c3                   	ret    

00800af8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800af8:	55                   	push   %ebp
  800af9:	89 e5                	mov    %esp,%ebp
  800afb:	56                   	push   %esi
  800afc:	53                   	push   %ebx
  800afd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b00:	83 ec 0c             	sub    $0xc,%esp
  800b03:	ff 75 08             	pushl  0x8(%ebp)
  800b06:	e8 59 f8 ff ff       	call   800364 <fd2data>
  800b0b:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b0d:	83 c4 08             	add    $0x8,%esp
  800b10:	68 25 1f 80 00       	push   $0x801f25
  800b15:	53                   	push   %ebx
  800b16:	e8 8e 0b 00 00       	call   8016a9 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b1b:	8b 46 04             	mov    0x4(%esi),%eax
  800b1e:	2b 06                	sub    (%esi),%eax
  800b20:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b26:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b2d:	00 00 00 
	stat->st_dev = &devpipe;
  800b30:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800b37:	30 80 00 
	return 0;
}
  800b3a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b3f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b42:	5b                   	pop    %ebx
  800b43:	5e                   	pop    %esi
  800b44:	5d                   	pop    %ebp
  800b45:	c3                   	ret    

00800b46 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b46:	55                   	push   %ebp
  800b47:	89 e5                	mov    %esp,%ebp
  800b49:	53                   	push   %ebx
  800b4a:	83 ec 0c             	sub    $0xc,%esp
  800b4d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800b50:	53                   	push   %ebx
  800b51:	6a 00                	push   $0x0
  800b53:	e8 90 f6 ff ff       	call   8001e8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800b58:	89 1c 24             	mov    %ebx,(%esp)
  800b5b:	e8 04 f8 ff ff       	call   800364 <fd2data>
  800b60:	83 c4 08             	add    $0x8,%esp
  800b63:	50                   	push   %eax
  800b64:	6a 00                	push   $0x0
  800b66:	e8 7d f6 ff ff       	call   8001e8 <sys_page_unmap>
}
  800b6b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b6e:	c9                   	leave  
  800b6f:	c3                   	ret    

00800b70 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800b70:	55                   	push   %ebp
  800b71:	89 e5                	mov    %esp,%ebp
  800b73:	57                   	push   %edi
  800b74:	56                   	push   %esi
  800b75:	53                   	push   %ebx
  800b76:	83 ec 1c             	sub    $0x1c,%esp
  800b79:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b7c:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800b7e:	a1 04 40 80 00       	mov    0x804004,%eax
  800b83:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800b86:	83 ec 0c             	sub    $0xc,%esp
  800b89:	ff 75 e0             	pushl  -0x20(%ebp)
  800b8c:	e8 fb 0f 00 00       	call   801b8c <pageref>
  800b91:	89 c3                	mov    %eax,%ebx
  800b93:	89 3c 24             	mov    %edi,(%esp)
  800b96:	e8 f1 0f 00 00       	call   801b8c <pageref>
  800b9b:	83 c4 10             	add    $0x10,%esp
  800b9e:	39 c3                	cmp    %eax,%ebx
  800ba0:	0f 94 c1             	sete   %cl
  800ba3:	0f b6 c9             	movzbl %cl,%ecx
  800ba6:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800ba9:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800baf:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800bb2:	39 ce                	cmp    %ecx,%esi
  800bb4:	74 1b                	je     800bd1 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800bb6:	39 c3                	cmp    %eax,%ebx
  800bb8:	75 c4                	jne    800b7e <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800bba:	8b 42 58             	mov    0x58(%edx),%eax
  800bbd:	ff 75 e4             	pushl  -0x1c(%ebp)
  800bc0:	50                   	push   %eax
  800bc1:	56                   	push   %esi
  800bc2:	68 2c 1f 80 00       	push   $0x801f2c
  800bc7:	e8 f8 04 00 00       	call   8010c4 <cprintf>
  800bcc:	83 c4 10             	add    $0x10,%esp
  800bcf:	eb ad                	jmp    800b7e <_pipeisclosed+0xe>
	}
}
  800bd1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800bd4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd7:	5b                   	pop    %ebx
  800bd8:	5e                   	pop    %esi
  800bd9:	5f                   	pop    %edi
  800bda:	5d                   	pop    %ebp
  800bdb:	c3                   	ret    

00800bdc <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800bdc:	55                   	push   %ebp
  800bdd:	89 e5                	mov    %esp,%ebp
  800bdf:	57                   	push   %edi
  800be0:	56                   	push   %esi
  800be1:	53                   	push   %ebx
  800be2:	83 ec 18             	sub    $0x18,%esp
  800be5:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800be8:	56                   	push   %esi
  800be9:	e8 76 f7 ff ff       	call   800364 <fd2data>
  800bee:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800bf0:	83 c4 10             	add    $0x10,%esp
  800bf3:	bf 00 00 00 00       	mov    $0x0,%edi
  800bf8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800bfc:	75 42                	jne    800c40 <devpipe_write+0x64>
  800bfe:	eb 4e                	jmp    800c4e <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c00:	89 da                	mov    %ebx,%edx
  800c02:	89 f0                	mov    %esi,%eax
  800c04:	e8 67 ff ff ff       	call   800b70 <_pipeisclosed>
  800c09:	85 c0                	test   %eax,%eax
  800c0b:	75 46                	jne    800c53 <devpipe_write+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c0d:	e8 32 f5 ff ff       	call   800144 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c12:	8b 53 04             	mov    0x4(%ebx),%edx
  800c15:	8b 03                	mov    (%ebx),%eax
  800c17:	83 c0 20             	add    $0x20,%eax
  800c1a:	39 c2                	cmp    %eax,%edx
  800c1c:	73 e2                	jae    800c00 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c1e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c21:	8a 0c 38             	mov    (%eax,%edi,1),%cl
  800c24:	89 d0                	mov    %edx,%eax
  800c26:	25 1f 00 00 80       	and    $0x8000001f,%eax
  800c2b:	79 05                	jns    800c32 <devpipe_write+0x56>
  800c2d:	48                   	dec    %eax
  800c2e:	83 c8 e0             	or     $0xffffffe0,%eax
  800c31:	40                   	inc    %eax
  800c32:	88 4c 03 08          	mov    %cl,0x8(%ebx,%eax,1)
		p->p_wpos++;
  800c36:	42                   	inc    %edx
  800c37:	89 53 04             	mov    %edx,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c3a:	47                   	inc    %edi
  800c3b:	39 7d 10             	cmp    %edi,0x10(%ebp)
  800c3e:	74 0e                	je     800c4e <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c40:	8b 53 04             	mov    0x4(%ebx),%edx
  800c43:	8b 03                	mov    (%ebx),%eax
  800c45:	83 c0 20             	add    $0x20,%eax
  800c48:	39 c2                	cmp    %eax,%edx
  800c4a:	73 b4                	jae    800c00 <devpipe_write+0x24>
  800c4c:	eb d0                	jmp    800c1e <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800c4e:	8b 45 10             	mov    0x10(%ebp),%eax
  800c51:	eb 05                	jmp    800c58 <devpipe_write+0x7c>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800c53:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800c58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5b:	5b                   	pop    %ebx
  800c5c:	5e                   	pop    %esi
  800c5d:	5f                   	pop    %edi
  800c5e:	5d                   	pop    %ebp
  800c5f:	c3                   	ret    

00800c60 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800c60:	55                   	push   %ebp
  800c61:	89 e5                	mov    %esp,%ebp
  800c63:	57                   	push   %edi
  800c64:	56                   	push   %esi
  800c65:	53                   	push   %ebx
  800c66:	83 ec 18             	sub    $0x18,%esp
  800c69:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800c6c:	57                   	push   %edi
  800c6d:	e8 f2 f6 ff ff       	call   800364 <fd2data>
  800c72:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c74:	83 c4 10             	add    $0x10,%esp
  800c77:	be 00 00 00 00       	mov    $0x0,%esi
  800c7c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c80:	75 3d                	jne    800cbf <devpipe_read+0x5f>
  800c82:	eb 48                	jmp    800ccc <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  800c84:	89 f0                	mov    %esi,%eax
  800c86:	eb 4e                	jmp    800cd6 <devpipe_read+0x76>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800c88:	89 da                	mov    %ebx,%edx
  800c8a:	89 f8                	mov    %edi,%eax
  800c8c:	e8 df fe ff ff       	call   800b70 <_pipeisclosed>
  800c91:	85 c0                	test   %eax,%eax
  800c93:	75 3c                	jne    800cd1 <devpipe_read+0x71>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800c95:	e8 aa f4 ff ff       	call   800144 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800c9a:	8b 03                	mov    (%ebx),%eax
  800c9c:	3b 43 04             	cmp    0x4(%ebx),%eax
  800c9f:	74 e7                	je     800c88 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800ca1:	25 1f 00 00 80       	and    $0x8000001f,%eax
  800ca6:	79 05                	jns    800cad <devpipe_read+0x4d>
  800ca8:	48                   	dec    %eax
  800ca9:	83 c8 e0             	or     $0xffffffe0,%eax
  800cac:	40                   	inc    %eax
  800cad:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  800cb1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb4:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800cb7:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cb9:	46                   	inc    %esi
  800cba:	39 75 10             	cmp    %esi,0x10(%ebp)
  800cbd:	74 0d                	je     800ccc <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
  800cbf:	8b 03                	mov    (%ebx),%eax
  800cc1:	3b 43 04             	cmp    0x4(%ebx),%eax
  800cc4:	75 db                	jne    800ca1 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800cc6:	85 f6                	test   %esi,%esi
  800cc8:	75 ba                	jne    800c84 <devpipe_read+0x24>
  800cca:	eb bc                	jmp    800c88 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800ccc:	8b 45 10             	mov    0x10(%ebp),%eax
  800ccf:	eb 05                	jmp    800cd6 <devpipe_read+0x76>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cd1:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800cd6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd9:	5b                   	pop    %ebx
  800cda:	5e                   	pop    %esi
  800cdb:	5f                   	pop    %edi
  800cdc:	5d                   	pop    %ebp
  800cdd:	c3                   	ret    

00800cde <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800cde:	55                   	push   %ebp
  800cdf:	89 e5                	mov    %esp,%ebp
  800ce1:	56                   	push   %esi
  800ce2:	53                   	push   %ebx
  800ce3:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800ce6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ce9:	50                   	push   %eax
  800cea:	e8 8c f6 ff ff       	call   80037b <fd_alloc>
  800cef:	83 c4 10             	add    $0x10,%esp
  800cf2:	85 c0                	test   %eax,%eax
  800cf4:	0f 88 2a 01 00 00    	js     800e24 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800cfa:	83 ec 04             	sub    $0x4,%esp
  800cfd:	68 07 04 00 00       	push   $0x407
  800d02:	ff 75 f4             	pushl  -0xc(%ebp)
  800d05:	6a 00                	push   $0x0
  800d07:	e8 57 f4 ff ff       	call   800163 <sys_page_alloc>
  800d0c:	83 c4 10             	add    $0x10,%esp
  800d0f:	85 c0                	test   %eax,%eax
  800d11:	0f 88 0d 01 00 00    	js     800e24 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d17:	83 ec 0c             	sub    $0xc,%esp
  800d1a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d1d:	50                   	push   %eax
  800d1e:	e8 58 f6 ff ff       	call   80037b <fd_alloc>
  800d23:	89 c3                	mov    %eax,%ebx
  800d25:	83 c4 10             	add    $0x10,%esp
  800d28:	85 c0                	test   %eax,%eax
  800d2a:	0f 88 e2 00 00 00    	js     800e12 <pipe+0x134>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d30:	83 ec 04             	sub    $0x4,%esp
  800d33:	68 07 04 00 00       	push   $0x407
  800d38:	ff 75 f0             	pushl  -0x10(%ebp)
  800d3b:	6a 00                	push   $0x0
  800d3d:	e8 21 f4 ff ff       	call   800163 <sys_page_alloc>
  800d42:	89 c3                	mov    %eax,%ebx
  800d44:	83 c4 10             	add    $0x10,%esp
  800d47:	85 c0                	test   %eax,%eax
  800d49:	0f 88 c3 00 00 00    	js     800e12 <pipe+0x134>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800d4f:	83 ec 0c             	sub    $0xc,%esp
  800d52:	ff 75 f4             	pushl  -0xc(%ebp)
  800d55:	e8 0a f6 ff ff       	call   800364 <fd2data>
  800d5a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d5c:	83 c4 0c             	add    $0xc,%esp
  800d5f:	68 07 04 00 00       	push   $0x407
  800d64:	50                   	push   %eax
  800d65:	6a 00                	push   $0x0
  800d67:	e8 f7 f3 ff ff       	call   800163 <sys_page_alloc>
  800d6c:	89 c3                	mov    %eax,%ebx
  800d6e:	83 c4 10             	add    $0x10,%esp
  800d71:	85 c0                	test   %eax,%eax
  800d73:	0f 88 89 00 00 00    	js     800e02 <pipe+0x124>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d79:	83 ec 0c             	sub    $0xc,%esp
  800d7c:	ff 75 f0             	pushl  -0x10(%ebp)
  800d7f:	e8 e0 f5 ff ff       	call   800364 <fd2data>
  800d84:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800d8b:	50                   	push   %eax
  800d8c:	6a 00                	push   $0x0
  800d8e:	56                   	push   %esi
  800d8f:	6a 00                	push   $0x0
  800d91:	e8 10 f4 ff ff       	call   8001a6 <sys_page_map>
  800d96:	89 c3                	mov    %eax,%ebx
  800d98:	83 c4 20             	add    $0x20,%esp
  800d9b:	85 c0                	test   %eax,%eax
  800d9d:	78 55                	js     800df4 <pipe+0x116>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800d9f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800da5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800da8:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800daa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dad:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800db4:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800dba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dbd:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800dbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dc2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800dc9:	83 ec 0c             	sub    $0xc,%esp
  800dcc:	ff 75 f4             	pushl  -0xc(%ebp)
  800dcf:	e8 80 f5 ff ff       	call   800354 <fd2num>
  800dd4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dd7:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800dd9:	83 c4 04             	add    $0x4,%esp
  800ddc:	ff 75 f0             	pushl  -0x10(%ebp)
  800ddf:	e8 70 f5 ff ff       	call   800354 <fd2num>
  800de4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800de7:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800dea:	83 c4 10             	add    $0x10,%esp
  800ded:	b8 00 00 00 00       	mov    $0x0,%eax
  800df2:	eb 30                	jmp    800e24 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  800df4:	83 ec 08             	sub    $0x8,%esp
  800df7:	56                   	push   %esi
  800df8:	6a 00                	push   $0x0
  800dfa:	e8 e9 f3 ff ff       	call   8001e8 <sys_page_unmap>
  800dff:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e02:	83 ec 08             	sub    $0x8,%esp
  800e05:	ff 75 f0             	pushl  -0x10(%ebp)
  800e08:	6a 00                	push   $0x0
  800e0a:	e8 d9 f3 ff ff       	call   8001e8 <sys_page_unmap>
  800e0f:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e12:	83 ec 08             	sub    $0x8,%esp
  800e15:	ff 75 f4             	pushl  -0xc(%ebp)
  800e18:	6a 00                	push   $0x0
  800e1a:	e8 c9 f3 ff ff       	call   8001e8 <sys_page_unmap>
  800e1f:	83 c4 10             	add    $0x10,%esp
  800e22:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  800e24:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e27:	5b                   	pop    %ebx
  800e28:	5e                   	pop    %esi
  800e29:	5d                   	pop    %ebp
  800e2a:	c3                   	ret    

00800e2b <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e2b:	55                   	push   %ebp
  800e2c:	89 e5                	mov    %esp,%ebp
  800e2e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e31:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e34:	50                   	push   %eax
  800e35:	ff 75 08             	pushl  0x8(%ebp)
  800e38:	e8 b2 f5 ff ff       	call   8003ef <fd_lookup>
  800e3d:	83 c4 10             	add    $0x10,%esp
  800e40:	85 c0                	test   %eax,%eax
  800e42:	78 18                	js     800e5c <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800e44:	83 ec 0c             	sub    $0xc,%esp
  800e47:	ff 75 f4             	pushl  -0xc(%ebp)
  800e4a:	e8 15 f5 ff ff       	call   800364 <fd2data>
	return _pipeisclosed(fd, p);
  800e4f:	89 c2                	mov    %eax,%edx
  800e51:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e54:	e8 17 fd ff ff       	call   800b70 <_pipeisclosed>
  800e59:	83 c4 10             	add    $0x10,%esp
}
  800e5c:	c9                   	leave  
  800e5d:	c3                   	ret    

00800e5e <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800e5e:	55                   	push   %ebp
  800e5f:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800e61:	b8 00 00 00 00       	mov    $0x0,%eax
  800e66:	5d                   	pop    %ebp
  800e67:	c3                   	ret    

00800e68 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800e68:	55                   	push   %ebp
  800e69:	89 e5                	mov    %esp,%ebp
  800e6b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800e6e:	68 44 1f 80 00       	push   $0x801f44
  800e73:	ff 75 0c             	pushl  0xc(%ebp)
  800e76:	e8 2e 08 00 00       	call   8016a9 <strcpy>
	return 0;
}
  800e7b:	b8 00 00 00 00       	mov    $0x0,%eax
  800e80:	c9                   	leave  
  800e81:	c3                   	ret    

00800e82 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800e82:	55                   	push   %ebp
  800e83:	89 e5                	mov    %esp,%ebp
  800e85:	57                   	push   %edi
  800e86:	56                   	push   %esi
  800e87:	53                   	push   %ebx
  800e88:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800e8e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e92:	74 45                	je     800ed9 <devcons_write+0x57>
  800e94:	b8 00 00 00 00       	mov    $0x0,%eax
  800e99:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800e9e:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800ea4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ea7:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  800ea9:	83 fb 7f             	cmp    $0x7f,%ebx
  800eac:	76 05                	jbe    800eb3 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  800eae:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800eb3:	83 ec 04             	sub    $0x4,%esp
  800eb6:	53                   	push   %ebx
  800eb7:	03 45 0c             	add    0xc(%ebp),%eax
  800eba:	50                   	push   %eax
  800ebb:	57                   	push   %edi
  800ebc:	e8 b5 09 00 00       	call   801876 <memmove>
		sys_cputs(buf, m);
  800ec1:	83 c4 08             	add    $0x8,%esp
  800ec4:	53                   	push   %ebx
  800ec5:	57                   	push   %edi
  800ec6:	e8 dc f1 ff ff       	call   8000a7 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ecb:	01 de                	add    %ebx,%esi
  800ecd:	89 f0                	mov    %esi,%eax
  800ecf:	83 c4 10             	add    $0x10,%esp
  800ed2:	3b 75 10             	cmp    0x10(%ebp),%esi
  800ed5:	72 cd                	jb     800ea4 <devcons_write+0x22>
  800ed7:	eb 05                	jmp    800ede <devcons_write+0x5c>
  800ed9:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800ede:	89 f0                	mov    %esi,%eax
  800ee0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ee3:	5b                   	pop    %ebx
  800ee4:	5e                   	pop    %esi
  800ee5:	5f                   	pop    %edi
  800ee6:	5d                   	pop    %ebp
  800ee7:	c3                   	ret    

00800ee8 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800ee8:	55                   	push   %ebp
  800ee9:	89 e5                	mov    %esp,%ebp
  800eeb:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  800eee:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ef2:	75 07                	jne    800efb <devcons_read+0x13>
  800ef4:	eb 23                	jmp    800f19 <devcons_read+0x31>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800ef6:	e8 49 f2 ff ff       	call   800144 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800efb:	e8 c5 f1 ff ff       	call   8000c5 <sys_cgetc>
  800f00:	85 c0                	test   %eax,%eax
  800f02:	74 f2                	je     800ef6 <devcons_read+0xe>
		sys_yield();
	if (c < 0)
  800f04:	85 c0                	test   %eax,%eax
  800f06:	78 1d                	js     800f25 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f08:	83 f8 04             	cmp    $0x4,%eax
  800f0b:	74 13                	je     800f20 <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  800f0d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f10:	88 02                	mov    %al,(%edx)
	return 1;
  800f12:	b8 01 00 00 00       	mov    $0x1,%eax
  800f17:	eb 0c                	jmp    800f25 <devcons_read+0x3d>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  800f19:	b8 00 00 00 00       	mov    $0x0,%eax
  800f1e:	eb 05                	jmp    800f25 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f20:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f25:	c9                   	leave  
  800f26:	c3                   	ret    

00800f27 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f27:	55                   	push   %ebp
  800f28:	89 e5                	mov    %esp,%ebp
  800f2a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800f30:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f33:	6a 01                	push   $0x1
  800f35:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f38:	50                   	push   %eax
  800f39:	e8 69 f1 ff ff       	call   8000a7 <sys_cputs>
}
  800f3e:	83 c4 10             	add    $0x10,%esp
  800f41:	c9                   	leave  
  800f42:	c3                   	ret    

00800f43 <getchar>:

int
getchar(void)
{
  800f43:	55                   	push   %ebp
  800f44:	89 e5                	mov    %esp,%ebp
  800f46:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f49:	6a 01                	push   $0x1
  800f4b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f4e:	50                   	push   %eax
  800f4f:	6a 00                	push   $0x0
  800f51:	e8 1a f7 ff ff       	call   800670 <read>
	if (r < 0)
  800f56:	83 c4 10             	add    $0x10,%esp
  800f59:	85 c0                	test   %eax,%eax
  800f5b:	78 0f                	js     800f6c <getchar+0x29>
		return r;
	if (r < 1)
  800f5d:	85 c0                	test   %eax,%eax
  800f5f:	7e 06                	jle    800f67 <getchar+0x24>
		return -E_EOF;
	return c;
  800f61:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800f65:	eb 05                	jmp    800f6c <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800f67:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800f6c:	c9                   	leave  
  800f6d:	c3                   	ret    

00800f6e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800f6e:	55                   	push   %ebp
  800f6f:	89 e5                	mov    %esp,%ebp
  800f71:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f74:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f77:	50                   	push   %eax
  800f78:	ff 75 08             	pushl  0x8(%ebp)
  800f7b:	e8 6f f4 ff ff       	call   8003ef <fd_lookup>
  800f80:	83 c4 10             	add    $0x10,%esp
  800f83:	85 c0                	test   %eax,%eax
  800f85:	78 11                	js     800f98 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800f87:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f8a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800f90:	39 10                	cmp    %edx,(%eax)
  800f92:	0f 94 c0             	sete   %al
  800f95:	0f b6 c0             	movzbl %al,%eax
}
  800f98:	c9                   	leave  
  800f99:	c3                   	ret    

00800f9a <opencons>:

int
opencons(void)
{
  800f9a:	55                   	push   %ebp
  800f9b:	89 e5                	mov    %esp,%ebp
  800f9d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fa0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fa3:	50                   	push   %eax
  800fa4:	e8 d2 f3 ff ff       	call   80037b <fd_alloc>
  800fa9:	83 c4 10             	add    $0x10,%esp
  800fac:	85 c0                	test   %eax,%eax
  800fae:	78 3a                	js     800fea <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fb0:	83 ec 04             	sub    $0x4,%esp
  800fb3:	68 07 04 00 00       	push   $0x407
  800fb8:	ff 75 f4             	pushl  -0xc(%ebp)
  800fbb:	6a 00                	push   $0x0
  800fbd:	e8 a1 f1 ff ff       	call   800163 <sys_page_alloc>
  800fc2:	83 c4 10             	add    $0x10,%esp
  800fc5:	85 c0                	test   %eax,%eax
  800fc7:	78 21                	js     800fea <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800fc9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fd2:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800fd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fd7:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800fde:	83 ec 0c             	sub    $0xc,%esp
  800fe1:	50                   	push   %eax
  800fe2:	e8 6d f3 ff ff       	call   800354 <fd2num>
  800fe7:	83 c4 10             	add    $0x10,%esp
}
  800fea:	c9                   	leave  
  800feb:	c3                   	ret    

00800fec <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800fec:	55                   	push   %ebp
  800fed:	89 e5                	mov    %esp,%ebp
  800fef:	56                   	push   %esi
  800ff0:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800ff1:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800ff4:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800ffa:	e8 26 f1 ff ff       	call   800125 <sys_getenvid>
  800fff:	83 ec 0c             	sub    $0xc,%esp
  801002:	ff 75 0c             	pushl  0xc(%ebp)
  801005:	ff 75 08             	pushl  0x8(%ebp)
  801008:	56                   	push   %esi
  801009:	50                   	push   %eax
  80100a:	68 50 1f 80 00       	push   $0x801f50
  80100f:	e8 b0 00 00 00       	call   8010c4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801014:	83 c4 18             	add    $0x18,%esp
  801017:	53                   	push   %ebx
  801018:	ff 75 10             	pushl  0x10(%ebp)
  80101b:	e8 53 00 00 00       	call   801073 <vcprintf>
	cprintf("\n");
  801020:	c7 04 24 3d 1f 80 00 	movl   $0x801f3d,(%esp)
  801027:	e8 98 00 00 00       	call   8010c4 <cprintf>
  80102c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80102f:	cc                   	int3   
  801030:	eb fd                	jmp    80102f <_panic+0x43>

00801032 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801032:	55                   	push   %ebp
  801033:	89 e5                	mov    %esp,%ebp
  801035:	53                   	push   %ebx
  801036:	83 ec 04             	sub    $0x4,%esp
  801039:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80103c:	8b 13                	mov    (%ebx),%edx
  80103e:	8d 42 01             	lea    0x1(%edx),%eax
  801041:	89 03                	mov    %eax,(%ebx)
  801043:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801046:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80104a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80104f:	75 1a                	jne    80106b <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801051:	83 ec 08             	sub    $0x8,%esp
  801054:	68 ff 00 00 00       	push   $0xff
  801059:	8d 43 08             	lea    0x8(%ebx),%eax
  80105c:	50                   	push   %eax
  80105d:	e8 45 f0 ff ff       	call   8000a7 <sys_cputs>
		b->idx = 0;
  801062:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801068:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80106b:	ff 43 04             	incl   0x4(%ebx)
}
  80106e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801071:	c9                   	leave  
  801072:	c3                   	ret    

00801073 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801073:	55                   	push   %ebp
  801074:	89 e5                	mov    %esp,%ebp
  801076:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80107c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801083:	00 00 00 
	b.cnt = 0;
  801086:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80108d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801090:	ff 75 0c             	pushl  0xc(%ebp)
  801093:	ff 75 08             	pushl  0x8(%ebp)
  801096:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80109c:	50                   	push   %eax
  80109d:	68 32 10 80 00       	push   $0x801032
  8010a2:	e8 54 01 00 00       	call   8011fb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010a7:	83 c4 08             	add    $0x8,%esp
  8010aa:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010b0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010b6:	50                   	push   %eax
  8010b7:	e8 eb ef ff ff       	call   8000a7 <sys_cputs>

	return b.cnt;
}
  8010bc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8010c2:	c9                   	leave  
  8010c3:	c3                   	ret    

008010c4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8010c4:	55                   	push   %ebp
  8010c5:	89 e5                	mov    %esp,%ebp
  8010c7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8010ca:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8010cd:	50                   	push   %eax
  8010ce:	ff 75 08             	pushl  0x8(%ebp)
  8010d1:	e8 9d ff ff ff       	call   801073 <vcprintf>
	va_end(ap);

	return cnt;
}
  8010d6:	c9                   	leave  
  8010d7:	c3                   	ret    

008010d8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8010d8:	55                   	push   %ebp
  8010d9:	89 e5                	mov    %esp,%ebp
  8010db:	57                   	push   %edi
  8010dc:	56                   	push   %esi
  8010dd:	53                   	push   %ebx
  8010de:	83 ec 1c             	sub    $0x1c,%esp
  8010e1:	89 c6                	mov    %eax,%esi
  8010e3:	89 d7                	mov    %edx,%edi
  8010e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010eb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8010ee:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8010f1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8010f4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010f9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8010fc:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8010ff:	39 d3                	cmp    %edx,%ebx
  801101:	72 11                	jb     801114 <printnum+0x3c>
  801103:	39 45 10             	cmp    %eax,0x10(%ebp)
  801106:	76 0c                	jbe    801114 <printnum+0x3c>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801108:	8b 45 14             	mov    0x14(%ebp),%eax
  80110b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80110e:	85 db                	test   %ebx,%ebx
  801110:	7f 37                	jg     801149 <printnum+0x71>
  801112:	eb 44                	jmp    801158 <printnum+0x80>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801114:	83 ec 0c             	sub    $0xc,%esp
  801117:	ff 75 18             	pushl  0x18(%ebp)
  80111a:	8b 45 14             	mov    0x14(%ebp),%eax
  80111d:	48                   	dec    %eax
  80111e:	50                   	push   %eax
  80111f:	ff 75 10             	pushl  0x10(%ebp)
  801122:	83 ec 08             	sub    $0x8,%esp
  801125:	ff 75 e4             	pushl  -0x1c(%ebp)
  801128:	ff 75 e0             	pushl  -0x20(%ebp)
  80112b:	ff 75 dc             	pushl  -0x24(%ebp)
  80112e:	ff 75 d8             	pushl  -0x28(%ebp)
  801131:	e8 9a 0a 00 00       	call   801bd0 <__udivdi3>
  801136:	83 c4 18             	add    $0x18,%esp
  801139:	52                   	push   %edx
  80113a:	50                   	push   %eax
  80113b:	89 fa                	mov    %edi,%edx
  80113d:	89 f0                	mov    %esi,%eax
  80113f:	e8 94 ff ff ff       	call   8010d8 <printnum>
  801144:	83 c4 20             	add    $0x20,%esp
  801147:	eb 0f                	jmp    801158 <printnum+0x80>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801149:	83 ec 08             	sub    $0x8,%esp
  80114c:	57                   	push   %edi
  80114d:	ff 75 18             	pushl  0x18(%ebp)
  801150:	ff d6                	call   *%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801152:	83 c4 10             	add    $0x10,%esp
  801155:	4b                   	dec    %ebx
  801156:	75 f1                	jne    801149 <printnum+0x71>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801158:	83 ec 08             	sub    $0x8,%esp
  80115b:	57                   	push   %edi
  80115c:	83 ec 04             	sub    $0x4,%esp
  80115f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801162:	ff 75 e0             	pushl  -0x20(%ebp)
  801165:	ff 75 dc             	pushl  -0x24(%ebp)
  801168:	ff 75 d8             	pushl  -0x28(%ebp)
  80116b:	e8 70 0b 00 00       	call   801ce0 <__umoddi3>
  801170:	83 c4 14             	add    $0x14,%esp
  801173:	0f be 80 73 1f 80 00 	movsbl 0x801f73(%eax),%eax
  80117a:	50                   	push   %eax
  80117b:	ff d6                	call   *%esi
}
  80117d:	83 c4 10             	add    $0x10,%esp
  801180:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801183:	5b                   	pop    %ebx
  801184:	5e                   	pop    %esi
  801185:	5f                   	pop    %edi
  801186:	5d                   	pop    %ebp
  801187:	c3                   	ret    

00801188 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801188:	55                   	push   %ebp
  801189:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80118b:	83 fa 01             	cmp    $0x1,%edx
  80118e:	7e 0e                	jle    80119e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801190:	8b 10                	mov    (%eax),%edx
  801192:	8d 4a 08             	lea    0x8(%edx),%ecx
  801195:	89 08                	mov    %ecx,(%eax)
  801197:	8b 02                	mov    (%edx),%eax
  801199:	8b 52 04             	mov    0x4(%edx),%edx
  80119c:	eb 22                	jmp    8011c0 <getuint+0x38>
	else if (lflag)
  80119e:	85 d2                	test   %edx,%edx
  8011a0:	74 10                	je     8011b2 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8011a2:	8b 10                	mov    (%eax),%edx
  8011a4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011a7:	89 08                	mov    %ecx,(%eax)
  8011a9:	8b 02                	mov    (%edx),%eax
  8011ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8011b0:	eb 0e                	jmp    8011c0 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8011b2:	8b 10                	mov    (%eax),%edx
  8011b4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011b7:	89 08                	mov    %ecx,(%eax)
  8011b9:	8b 02                	mov    (%edx),%eax
  8011bb:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8011c0:	5d                   	pop    %ebp
  8011c1:	c3                   	ret    

008011c2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011c2:	55                   	push   %ebp
  8011c3:	89 e5                	mov    %esp,%ebp
  8011c5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011c8:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8011cb:	8b 10                	mov    (%eax),%edx
  8011cd:	3b 50 04             	cmp    0x4(%eax),%edx
  8011d0:	73 0a                	jae    8011dc <sprintputch+0x1a>
		*b->buf++ = ch;
  8011d2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8011d5:	89 08                	mov    %ecx,(%eax)
  8011d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8011da:	88 02                	mov    %al,(%edx)
}
  8011dc:	5d                   	pop    %ebp
  8011dd:	c3                   	ret    

008011de <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8011de:	55                   	push   %ebp
  8011df:	89 e5                	mov    %esp,%ebp
  8011e1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8011e4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8011e7:	50                   	push   %eax
  8011e8:	ff 75 10             	pushl  0x10(%ebp)
  8011eb:	ff 75 0c             	pushl  0xc(%ebp)
  8011ee:	ff 75 08             	pushl  0x8(%ebp)
  8011f1:	e8 05 00 00 00       	call   8011fb <vprintfmt>
	va_end(ap);
}
  8011f6:	83 c4 10             	add    $0x10,%esp
  8011f9:	c9                   	leave  
  8011fa:	c3                   	ret    

008011fb <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8011fb:	55                   	push   %ebp
  8011fc:	89 e5                	mov    %esp,%ebp
  8011fe:	57                   	push   %edi
  8011ff:	56                   	push   %esi
  801200:	53                   	push   %ebx
  801201:	83 ec 2c             	sub    $0x2c,%esp
  801204:	8b 7d 08             	mov    0x8(%ebp),%edi
  801207:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80120a:	eb 03                	jmp    80120f <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  80120c:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  80120f:	8b 45 10             	mov    0x10(%ebp),%eax
  801212:	8d 70 01             	lea    0x1(%eax),%esi
  801215:	0f b6 00             	movzbl (%eax),%eax
  801218:	83 f8 25             	cmp    $0x25,%eax
  80121b:	74 25                	je     801242 <vprintfmt+0x47>
			if (ch == '\0')									//当然中间如果遇到'\0'，代表这个字符串的访问结束
  80121d:	85 c0                	test   %eax,%eax
  80121f:	75 0d                	jne    80122e <vprintfmt+0x33>
  801221:	e9 b5 03 00 00       	jmp    8015db <vprintfmt+0x3e0>
  801226:	85 c0                	test   %eax,%eax
  801228:	0f 84 ad 03 00 00    	je     8015db <vprintfmt+0x3e0>
				return;
			putch(ch, putdat);								//调用putch函数，把一个字符ch输出到putdat指针所指向的地址中所存放的值对应的地址处
  80122e:	83 ec 08             	sub    $0x8,%esp
  801231:	53                   	push   %ebx
  801232:	50                   	push   %eax
  801233:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  801235:	46                   	inc    %esi
  801236:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  80123a:	83 c4 10             	add    $0x10,%esp
  80123d:	83 f8 25             	cmp    $0x25,%eax
  801240:	75 e4                	jne    801226 <vprintfmt+0x2b>
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  801242:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  801246:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80124d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801254:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80125b:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  801262:	eb 07                	jmp    80126b <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  801264:	8b 75 10             	mov    0x10(%ebp),%esi

		// flag to pad on the right
		case '-':											//%后面的'-'代表要进行左对齐输出，右边填空格，如果省略代表右对齐
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
  801267:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80126b:	8d 46 01             	lea    0x1(%esi),%eax
  80126e:	89 45 10             	mov    %eax,0x10(%ebp)
  801271:	0f b6 16             	movzbl (%esi),%edx
  801274:	8a 06                	mov    (%esi),%al
  801276:	83 e8 23             	sub    $0x23,%eax
  801279:	3c 55                	cmp    $0x55,%al
  80127b:	0f 87 03 03 00 00    	ja     801584 <vprintfmt+0x389>
  801281:	0f b6 c0             	movzbl %al,%eax
  801284:	ff 24 85 c0 20 80 00 	jmp    *0x8020c0(,%eax,4)
  80128b:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
			goto reswitch;									//处理下一个字符

		// flag to pad with 0's instead of spaces
		case '0':											//0--有0表示进行对齐输出时填0,如省略表示填入空格，并且如果为0，则一定是右对齐
			padc = '0';										//对其方式标志位变为0
  80128e:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  801292:	eb d7                	jmp    80126b <vprintfmt+0x70>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
				precision = precision * 10 + ch - '0';
  801294:	8d 42 d0             	lea    -0x30(%edx),%eax
  801297:	89 c1                	mov    %eax,%ecx
  801299:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  80129c:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8012a0:	8d 50 d0             	lea    -0x30(%eax),%edx
  8012a3:	83 fa 09             	cmp    $0x9,%edx
  8012a6:	77 51                	ja     8012f9 <vprintfmt+0xfe>
  8012a8:	8b 75 10             	mov    0x10(%ebp),%esi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
  8012ab:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8012ac:	8d 14 89             	lea    (%ecx,%ecx,4),%edx
  8012af:	01 d2                	add    %edx,%edx
  8012b1:	8d 4c 10 d0          	lea    -0x30(%eax,%edx,1),%ecx
				ch = *fmt;
  8012b5:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8012b8:	8d 50 d0             	lea    -0x30(%eax),%edx
  8012bb:	83 fa 09             	cmp    $0x9,%edx
  8012be:	76 eb                	jbe    8012ab <vprintfmt+0xb0>
  8012c0:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8012c3:	eb 37                	jmp    8012fc <vprintfmt+0x101>
					break;
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
  8012c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8012c8:	8d 50 04             	lea    0x4(%eax),%edx
  8012cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8012ce:	8b 00                	mov    (%eax),%eax
  8012d0:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8012d3:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
			goto process_precision;
  8012d6:	eb 24                	jmp    8012fc <vprintfmt+0x101>
  8012d8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8012dc:	79 07                	jns    8012e5 <vprintfmt+0xea>
  8012de:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8012e5:	8b 75 10             	mov    0x10(%ebp),%esi
  8012e8:	eb 81                	jmp    80126b <vprintfmt+0x70>
  8012ea:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  8012ed:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8012f4:	e9 72 ff ff ff       	jmp    80126b <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8012f9:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:									//处理输出精度，把width字段赋值为刚刚计算出来的precision值，所以width应该是整数部分的有效数字位数
			if (width < 0)
  8012fc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801300:	0f 89 65 ff ff ff    	jns    80126b <vprintfmt+0x70>
				width = precision, precision = -1;
  801306:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801309:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80130c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801313:	e9 53 ff ff ff       	jmp    80126b <vprintfmt+0x70>
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
  801318:	ff 45 d4             	incl   -0x2c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80131b:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
			goto reswitch;
  80131e:	e9 48 ff ff ff       	jmp    80126b <vprintfmt+0x70>

		// character
		case 'c':											//如果是'c'代表显示一个字符
			putch(va_arg(ap, int), putdat);					//调用输出一个字符到内存的函数putch
  801323:	8b 45 14             	mov    0x14(%ebp),%eax
  801326:	8d 50 04             	lea    0x4(%eax),%edx
  801329:	89 55 14             	mov    %edx,0x14(%ebp)
  80132c:	83 ec 08             	sub    $0x8,%esp
  80132f:	53                   	push   %ebx
  801330:	ff 30                	pushl  (%eax)
  801332:	ff d7                	call   *%edi
			break;
  801334:	83 c4 10             	add    $0x10,%esp
  801337:	e9 d3 fe ff ff       	jmp    80120f <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80133c:	8b 45 14             	mov    0x14(%ebp),%eax
  80133f:	8d 50 04             	lea    0x4(%eax),%edx
  801342:	89 55 14             	mov    %edx,0x14(%ebp)
  801345:	8b 00                	mov    (%eax),%eax
  801347:	85 c0                	test   %eax,%eax
  801349:	79 02                	jns    80134d <vprintfmt+0x152>
  80134b:	f7 d8                	neg    %eax
  80134d:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80134f:	83 f8 0f             	cmp    $0xf,%eax
  801352:	7f 0b                	jg     80135f <vprintfmt+0x164>
  801354:	8b 04 85 20 22 80 00 	mov    0x802220(,%eax,4),%eax
  80135b:	85 c0                	test   %eax,%eax
  80135d:	75 15                	jne    801374 <vprintfmt+0x179>
				printfmt(putch, putdat, "error %d", err);
  80135f:	52                   	push   %edx
  801360:	68 8b 1f 80 00       	push   $0x801f8b
  801365:	53                   	push   %ebx
  801366:	57                   	push   %edi
  801367:	e8 72 fe ff ff       	call   8011de <printfmt>
  80136c:	83 c4 10             	add    $0x10,%esp
  80136f:	e9 9b fe ff ff       	jmp    80120f <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  801374:	50                   	push   %eax
  801375:	68 0b 1f 80 00       	push   $0x801f0b
  80137a:	53                   	push   %ebx
  80137b:	57                   	push   %edi
  80137c:	e8 5d fe ff ff       	call   8011de <printfmt>
  801381:	83 c4 10             	add    $0x10,%esp
  801384:	e9 86 fe ff ff       	jmp    80120f <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801389:	8b 45 14             	mov    0x14(%ebp),%eax
  80138c:	8d 50 04             	lea    0x4(%eax),%edx
  80138f:	89 55 14             	mov    %edx,0x14(%ebp)
  801392:	8b 00                	mov    (%eax),%eax
  801394:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  801397:	85 c0                	test   %eax,%eax
  801399:	75 07                	jne    8013a2 <vprintfmt+0x1a7>
				p = "(null)";
  80139b:	c7 45 d4 84 1f 80 00 	movl   $0x801f84,-0x2c(%ebp)
			if (width > 0 && padc != '-')
  8013a2:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8013a5:	85 f6                	test   %esi,%esi
  8013a7:	0f 8e fb 01 00 00    	jle    8015a8 <vprintfmt+0x3ad>
  8013ad:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  8013b1:	0f 84 09 02 00 00    	je     8015c0 <vprintfmt+0x3c5>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013b7:	83 ec 08             	sub    $0x8,%esp
  8013ba:	ff 75 d0             	pushl  -0x30(%ebp)
  8013bd:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013c0:	e8 ad 02 00 00       	call   801672 <strnlen>
  8013c5:	89 f1                	mov    %esi,%ecx
  8013c7:	29 c1                	sub    %eax,%ecx
  8013c9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8013cc:	83 c4 10             	add    $0x10,%esp
  8013cf:	85 c9                	test   %ecx,%ecx
  8013d1:	0f 8e d1 01 00 00    	jle    8015a8 <vprintfmt+0x3ad>
					putch(padc, putdat);
  8013d7:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8013db:	83 ec 08             	sub    $0x8,%esp
  8013de:	53                   	push   %ebx
  8013df:	56                   	push   %esi
  8013e0:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013e2:	83 c4 10             	add    $0x10,%esp
  8013e5:	ff 4d e4             	decl   -0x1c(%ebp)
  8013e8:	75 f1                	jne    8013db <vprintfmt+0x1e0>
  8013ea:	e9 b9 01 00 00       	jmp    8015a8 <vprintfmt+0x3ad>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8013ef:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8013f3:	74 19                	je     80140e <vprintfmt+0x213>
  8013f5:	0f be c0             	movsbl %al,%eax
  8013f8:	83 e8 20             	sub    $0x20,%eax
  8013fb:	83 f8 5e             	cmp    $0x5e,%eax
  8013fe:	76 0e                	jbe    80140e <vprintfmt+0x213>
					putch('?', putdat);
  801400:	83 ec 08             	sub    $0x8,%esp
  801403:	53                   	push   %ebx
  801404:	6a 3f                	push   $0x3f
  801406:	ff 55 08             	call   *0x8(%ebp)
  801409:	83 c4 10             	add    $0x10,%esp
  80140c:	eb 0b                	jmp    801419 <vprintfmt+0x21e>
				else
					putch(ch, putdat);
  80140e:	83 ec 08             	sub    $0x8,%esp
  801411:	53                   	push   %ebx
  801412:	52                   	push   %edx
  801413:	ff 55 08             	call   *0x8(%ebp)
  801416:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801419:	ff 4d e4             	decl   -0x1c(%ebp)
  80141c:	46                   	inc    %esi
  80141d:	8a 46 ff             	mov    -0x1(%esi),%al
  801420:	0f be d0             	movsbl %al,%edx
  801423:	85 d2                	test   %edx,%edx
  801425:	75 1c                	jne    801443 <vprintfmt+0x248>
  801427:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80142a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80142e:	7f 1f                	jg     80144f <vprintfmt+0x254>
  801430:	e9 da fd ff ff       	jmp    80120f <vprintfmt+0x14>
  801435:	89 7d 08             	mov    %edi,0x8(%ebp)
  801438:	8b 7d d0             	mov    -0x30(%ebp),%edi
  80143b:	eb 06                	jmp    801443 <vprintfmt+0x248>
  80143d:	89 7d 08             	mov    %edi,0x8(%ebp)
  801440:	8b 7d d0             	mov    -0x30(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801443:	85 ff                	test   %edi,%edi
  801445:	78 a8                	js     8013ef <vprintfmt+0x1f4>
  801447:	4f                   	dec    %edi
  801448:	79 a5                	jns    8013ef <vprintfmt+0x1f4>
  80144a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80144d:	eb db                	jmp    80142a <vprintfmt+0x22f>
  80144f:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801452:	83 ec 08             	sub    $0x8,%esp
  801455:	53                   	push   %ebx
  801456:	6a 20                	push   $0x20
  801458:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80145a:	4e                   	dec    %esi
  80145b:	83 c4 10             	add    $0x10,%esp
  80145e:	85 f6                	test   %esi,%esi
  801460:	7f f0                	jg     801452 <vprintfmt+0x257>
  801462:	e9 a8 fd ff ff       	jmp    80120f <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801467:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  80146b:	7e 16                	jle    801483 <vprintfmt+0x288>
		return va_arg(*ap, long long);
  80146d:	8b 45 14             	mov    0x14(%ebp),%eax
  801470:	8d 50 08             	lea    0x8(%eax),%edx
  801473:	89 55 14             	mov    %edx,0x14(%ebp)
  801476:	8b 50 04             	mov    0x4(%eax),%edx
  801479:	8b 00                	mov    (%eax),%eax
  80147b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80147e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801481:	eb 34                	jmp    8014b7 <vprintfmt+0x2bc>
	else if (lflag)
  801483:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  801487:	74 18                	je     8014a1 <vprintfmt+0x2a6>
		return va_arg(*ap, long);
  801489:	8b 45 14             	mov    0x14(%ebp),%eax
  80148c:	8d 50 04             	lea    0x4(%eax),%edx
  80148f:	89 55 14             	mov    %edx,0x14(%ebp)
  801492:	8b 30                	mov    (%eax),%esi
  801494:	89 75 d8             	mov    %esi,-0x28(%ebp)
  801497:	89 f0                	mov    %esi,%eax
  801499:	c1 f8 1f             	sar    $0x1f,%eax
  80149c:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80149f:	eb 16                	jmp    8014b7 <vprintfmt+0x2bc>
	else
		return va_arg(*ap, int);
  8014a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8014a4:	8d 50 04             	lea    0x4(%eax),%edx
  8014a7:	89 55 14             	mov    %edx,0x14(%ebp)
  8014aa:	8b 30                	mov    (%eax),%esi
  8014ac:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8014af:	89 f0                	mov    %esi,%eax
  8014b1:	c1 f8 1f             	sar    $0x1f,%eax
  8014b4:	89 45 dc             	mov    %eax,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8014b7:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8014ba:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
  8014bd:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8014c1:	0f 89 8a 00 00 00    	jns    801551 <vprintfmt+0x356>
				putch('-', putdat);
  8014c7:	83 ec 08             	sub    $0x8,%esp
  8014ca:	53                   	push   %ebx
  8014cb:	6a 2d                	push   $0x2d
  8014cd:	ff d7                	call   *%edi
				num = -(long long) num;
  8014cf:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8014d2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8014d5:	f7 d8                	neg    %eax
  8014d7:	83 d2 00             	adc    $0x0,%edx
  8014da:	f7 da                	neg    %edx
  8014dc:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8014df:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8014e4:	eb 70                	jmp    801556 <vprintfmt+0x35b>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8014e6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8014e9:	8d 45 14             	lea    0x14(%ebp),%eax
  8014ec:	e8 97 fc ff ff       	call   801188 <getuint>
			base = 10;
  8014f1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8014f6:	eb 5e                	jmp    801556 <vprintfmt+0x35b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  8014f8:	83 ec 08             	sub    $0x8,%esp
  8014fb:	53                   	push   %ebx
  8014fc:	6a 30                	push   $0x30
  8014fe:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  801500:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  801503:	8d 45 14             	lea    0x14(%ebp),%eax
  801506:	e8 7d fc ff ff       	call   801188 <getuint>
			base = 8;
			goto number;
  80150b:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  80150e:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801513:	eb 41                	jmp    801556 <vprintfmt+0x35b>
		// pointer
		case 'p':
			putch('0', putdat);
  801515:	83 ec 08             	sub    $0x8,%esp
  801518:	53                   	push   %ebx
  801519:	6a 30                	push   $0x30
  80151b:	ff d7                	call   *%edi
			putch('x', putdat);
  80151d:	83 c4 08             	add    $0x8,%esp
  801520:	53                   	push   %ebx
  801521:	6a 78                	push   $0x78
  801523:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801525:	8b 45 14             	mov    0x14(%ebp),%eax
  801528:	8d 50 04             	lea    0x4(%eax),%edx
  80152b:	89 55 14             	mov    %edx,0x14(%ebp)
			goto number;
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80152e:	8b 00                	mov    (%eax),%eax
  801530:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801535:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801538:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80153d:	eb 17                	jmp    801556 <vprintfmt+0x35b>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80153f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  801542:	8d 45 14             	lea    0x14(%ebp),%eax
  801545:	e8 3e fc ff ff       	call   801188 <getuint>
			base = 16;
  80154a:	b9 10 00 00 00       	mov    $0x10,%ecx
  80154f:	eb 05                	jmp    801556 <vprintfmt+0x35b>
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801551:	b9 0a 00 00 00       	mov    $0xa,%ecx
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  801556:	83 ec 0c             	sub    $0xc,%esp
  801559:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  80155d:	56                   	push   %esi
  80155e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801561:	51                   	push   %ecx
  801562:	52                   	push   %edx
  801563:	50                   	push   %eax
  801564:	89 da                	mov    %ebx,%edx
  801566:	89 f8                	mov    %edi,%eax
  801568:	e8 6b fb ff ff       	call   8010d8 <printnum>
			break;
  80156d:	83 c4 20             	add    $0x20,%esp
  801570:	e9 9a fc ff ff       	jmp    80120f <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801575:	83 ec 08             	sub    $0x8,%esp
  801578:	53                   	push   %ebx
  801579:	52                   	push   %edx
  80157a:	ff d7                	call   *%edi
			break;
  80157c:	83 c4 10             	add    $0x10,%esp
  80157f:	e9 8b fc ff ff       	jmp    80120f <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801584:	83 ec 08             	sub    $0x8,%esp
  801587:	53                   	push   %ebx
  801588:	6a 25                	push   $0x25
  80158a:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80158c:	83 c4 10             	add    $0x10,%esp
  80158f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  801593:	0f 84 73 fc ff ff    	je     80120c <vprintfmt+0x11>
  801599:	4e                   	dec    %esi
  80159a:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80159e:	75 f9                	jne    801599 <vprintfmt+0x39e>
  8015a0:	89 75 10             	mov    %esi,0x10(%ebp)
  8015a3:	e9 67 fc ff ff       	jmp    80120f <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8015a8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8015ab:	8d 70 01             	lea    0x1(%eax),%esi
  8015ae:	8a 00                	mov    (%eax),%al
  8015b0:	0f be d0             	movsbl %al,%edx
  8015b3:	85 d2                	test   %edx,%edx
  8015b5:	0f 85 7a fe ff ff    	jne    801435 <vprintfmt+0x23a>
  8015bb:	e9 4f fc ff ff       	jmp    80120f <vprintfmt+0x14>
  8015c0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8015c3:	8d 70 01             	lea    0x1(%eax),%esi
  8015c6:	8a 00                	mov    (%eax),%al
  8015c8:	0f be d0             	movsbl %al,%edx
  8015cb:	85 d2                	test   %edx,%edx
  8015cd:	0f 85 6a fe ff ff    	jne    80143d <vprintfmt+0x242>
  8015d3:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8015d6:	e9 77 fe ff ff       	jmp    801452 <vprintfmt+0x257>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  8015db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015de:	5b                   	pop    %ebx
  8015df:	5e                   	pop    %esi
  8015e0:	5f                   	pop    %edi
  8015e1:	5d                   	pop    %ebp
  8015e2:	c3                   	ret    

008015e3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8015e3:	55                   	push   %ebp
  8015e4:	89 e5                	mov    %esp,%ebp
  8015e6:	83 ec 18             	sub    $0x18,%esp
  8015e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ec:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8015ef:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8015f2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8015f6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8015f9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801600:	85 c0                	test   %eax,%eax
  801602:	74 26                	je     80162a <vsnprintf+0x47>
  801604:	85 d2                	test   %edx,%edx
  801606:	7e 29                	jle    801631 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801608:	ff 75 14             	pushl  0x14(%ebp)
  80160b:	ff 75 10             	pushl  0x10(%ebp)
  80160e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801611:	50                   	push   %eax
  801612:	68 c2 11 80 00       	push   $0x8011c2
  801617:	e8 df fb ff ff       	call   8011fb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80161c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80161f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801622:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801625:	83 c4 10             	add    $0x10,%esp
  801628:	eb 0c                	jmp    801636 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80162a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80162f:	eb 05                	jmp    801636 <vsnprintf+0x53>
  801631:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801636:	c9                   	leave  
  801637:	c3                   	ret    

00801638 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801638:	55                   	push   %ebp
  801639:	89 e5                	mov    %esp,%ebp
  80163b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80163e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801641:	50                   	push   %eax
  801642:	ff 75 10             	pushl  0x10(%ebp)
  801645:	ff 75 0c             	pushl  0xc(%ebp)
  801648:	ff 75 08             	pushl  0x8(%ebp)
  80164b:	e8 93 ff ff ff       	call   8015e3 <vsnprintf>
	va_end(ap);

	return rc;
}
  801650:	c9                   	leave  
  801651:	c3                   	ret    

00801652 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801652:	55                   	push   %ebp
  801653:	89 e5                	mov    %esp,%ebp
  801655:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801658:	80 3a 00             	cmpb   $0x0,(%edx)
  80165b:	74 0e                	je     80166b <strlen+0x19>
  80165d:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801662:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801663:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801667:	75 f9                	jne    801662 <strlen+0x10>
  801669:	eb 05                	jmp    801670 <strlen+0x1e>
  80166b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801670:	5d                   	pop    %ebp
  801671:	c3                   	ret    

00801672 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801672:	55                   	push   %ebp
  801673:	89 e5                	mov    %esp,%ebp
  801675:	53                   	push   %ebx
  801676:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801679:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80167c:	85 c9                	test   %ecx,%ecx
  80167e:	74 1a                	je     80169a <strnlen+0x28>
  801680:	80 3b 00             	cmpb   $0x0,(%ebx)
  801683:	74 1c                	je     8016a1 <strnlen+0x2f>
  801685:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  80168a:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80168c:	39 ca                	cmp    %ecx,%edx
  80168e:	74 16                	je     8016a6 <strnlen+0x34>
  801690:	42                   	inc    %edx
  801691:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  801696:	75 f2                	jne    80168a <strnlen+0x18>
  801698:	eb 0c                	jmp    8016a6 <strnlen+0x34>
  80169a:	b8 00 00 00 00       	mov    $0x0,%eax
  80169f:	eb 05                	jmp    8016a6 <strnlen+0x34>
  8016a1:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8016a6:	5b                   	pop    %ebx
  8016a7:	5d                   	pop    %ebp
  8016a8:	c3                   	ret    

008016a9 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016a9:	55                   	push   %ebp
  8016aa:	89 e5                	mov    %esp,%ebp
  8016ac:	53                   	push   %ebx
  8016ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016b3:	89 c2                	mov    %eax,%edx
  8016b5:	42                   	inc    %edx
  8016b6:	41                   	inc    %ecx
  8016b7:	8a 59 ff             	mov    -0x1(%ecx),%bl
  8016ba:	88 5a ff             	mov    %bl,-0x1(%edx)
  8016bd:	84 db                	test   %bl,%bl
  8016bf:	75 f4                	jne    8016b5 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8016c1:	5b                   	pop    %ebx
  8016c2:	5d                   	pop    %ebp
  8016c3:	c3                   	ret    

008016c4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016c4:	55                   	push   %ebp
  8016c5:	89 e5                	mov    %esp,%ebp
  8016c7:	53                   	push   %ebx
  8016c8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016cb:	53                   	push   %ebx
  8016cc:	e8 81 ff ff ff       	call   801652 <strlen>
  8016d1:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8016d4:	ff 75 0c             	pushl  0xc(%ebp)
  8016d7:	01 d8                	add    %ebx,%eax
  8016d9:	50                   	push   %eax
  8016da:	e8 ca ff ff ff       	call   8016a9 <strcpy>
	return dst;
}
  8016df:	89 d8                	mov    %ebx,%eax
  8016e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016e4:	c9                   	leave  
  8016e5:	c3                   	ret    

008016e6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016e6:	55                   	push   %ebp
  8016e7:	89 e5                	mov    %esp,%ebp
  8016e9:	56                   	push   %esi
  8016ea:	53                   	push   %ebx
  8016eb:	8b 75 08             	mov    0x8(%ebp),%esi
  8016ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016f1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016f4:	85 db                	test   %ebx,%ebx
  8016f6:	74 14                	je     80170c <strncpy+0x26>
  8016f8:	01 f3                	add    %esi,%ebx
  8016fa:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  8016fc:	41                   	inc    %ecx
  8016fd:	8a 02                	mov    (%edx),%al
  8016ff:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801702:	80 3a 01             	cmpb   $0x1,(%edx)
  801705:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801708:	39 cb                	cmp    %ecx,%ebx
  80170a:	75 f0                	jne    8016fc <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80170c:	89 f0                	mov    %esi,%eax
  80170e:	5b                   	pop    %ebx
  80170f:	5e                   	pop    %esi
  801710:	5d                   	pop    %ebp
  801711:	c3                   	ret    

00801712 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801712:	55                   	push   %ebp
  801713:	89 e5                	mov    %esp,%ebp
  801715:	53                   	push   %ebx
  801716:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801719:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80171c:	85 c0                	test   %eax,%eax
  80171e:	74 30                	je     801750 <strlcpy+0x3e>
		while (--size > 0 && *src != '\0')
  801720:	48                   	dec    %eax
  801721:	74 20                	je     801743 <strlcpy+0x31>
  801723:	8a 0b                	mov    (%ebx),%cl
  801725:	84 c9                	test   %cl,%cl
  801727:	74 1f                	je     801748 <strlcpy+0x36>
  801729:	8d 53 01             	lea    0x1(%ebx),%edx
  80172c:	01 c3                	add    %eax,%ebx
  80172e:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
  801731:	40                   	inc    %eax
  801732:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801735:	39 da                	cmp    %ebx,%edx
  801737:	74 12                	je     80174b <strlcpy+0x39>
  801739:	42                   	inc    %edx
  80173a:	8a 4a ff             	mov    -0x1(%edx),%cl
  80173d:	84 c9                	test   %cl,%cl
  80173f:	75 f0                	jne    801731 <strlcpy+0x1f>
  801741:	eb 08                	jmp    80174b <strlcpy+0x39>
  801743:	8b 45 08             	mov    0x8(%ebp),%eax
  801746:	eb 03                	jmp    80174b <strlcpy+0x39>
  801748:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
		*dst = '\0';
  80174b:	c6 00 00             	movb   $0x0,(%eax)
  80174e:	eb 03                	jmp    801753 <strlcpy+0x41>
  801750:	8b 45 08             	mov    0x8(%ebp),%eax
	}
	return dst - dst_in;
  801753:	2b 45 08             	sub    0x8(%ebp),%eax
}
  801756:	5b                   	pop    %ebx
  801757:	5d                   	pop    %ebp
  801758:	c3                   	ret    

00801759 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801759:	55                   	push   %ebp
  80175a:	89 e5                	mov    %esp,%ebp
  80175c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80175f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801762:	8a 01                	mov    (%ecx),%al
  801764:	84 c0                	test   %al,%al
  801766:	74 10                	je     801778 <strcmp+0x1f>
  801768:	3a 02                	cmp    (%edx),%al
  80176a:	75 0c                	jne    801778 <strcmp+0x1f>
		p++, q++;
  80176c:	41                   	inc    %ecx
  80176d:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80176e:	8a 01                	mov    (%ecx),%al
  801770:	84 c0                	test   %al,%al
  801772:	74 04                	je     801778 <strcmp+0x1f>
  801774:	3a 02                	cmp    (%edx),%al
  801776:	74 f4                	je     80176c <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801778:	0f b6 c0             	movzbl %al,%eax
  80177b:	0f b6 12             	movzbl (%edx),%edx
  80177e:	29 d0                	sub    %edx,%eax
}
  801780:	5d                   	pop    %ebp
  801781:	c3                   	ret    

00801782 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801782:	55                   	push   %ebp
  801783:	89 e5                	mov    %esp,%ebp
  801785:	56                   	push   %esi
  801786:	53                   	push   %ebx
  801787:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80178a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80178d:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  801790:	85 f6                	test   %esi,%esi
  801792:	74 23                	je     8017b7 <strncmp+0x35>
  801794:	8a 03                	mov    (%ebx),%al
  801796:	84 c0                	test   %al,%al
  801798:	74 2b                	je     8017c5 <strncmp+0x43>
  80179a:	3a 02                	cmp    (%edx),%al
  80179c:	75 27                	jne    8017c5 <strncmp+0x43>
  80179e:	8d 43 01             	lea    0x1(%ebx),%eax
  8017a1:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  8017a3:	89 c3                	mov    %eax,%ebx
  8017a5:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017a6:	39 c6                	cmp    %eax,%esi
  8017a8:	74 14                	je     8017be <strncmp+0x3c>
  8017aa:	8a 08                	mov    (%eax),%cl
  8017ac:	84 c9                	test   %cl,%cl
  8017ae:	74 15                	je     8017c5 <strncmp+0x43>
  8017b0:	40                   	inc    %eax
  8017b1:	3a 0a                	cmp    (%edx),%cl
  8017b3:	74 ee                	je     8017a3 <strncmp+0x21>
  8017b5:	eb 0e                	jmp    8017c5 <strncmp+0x43>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8017bc:	eb 0f                	jmp    8017cd <strncmp+0x4b>
  8017be:	b8 00 00 00 00       	mov    $0x0,%eax
  8017c3:	eb 08                	jmp    8017cd <strncmp+0x4b>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017c5:	0f b6 03             	movzbl (%ebx),%eax
  8017c8:	0f b6 12             	movzbl (%edx),%edx
  8017cb:	29 d0                	sub    %edx,%eax
}
  8017cd:	5b                   	pop    %ebx
  8017ce:	5e                   	pop    %esi
  8017cf:	5d                   	pop    %ebp
  8017d0:	c3                   	ret    

008017d1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017d1:	55                   	push   %ebp
  8017d2:	89 e5                	mov    %esp,%ebp
  8017d4:	53                   	push   %ebx
  8017d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  8017db:	8a 10                	mov    (%eax),%dl
  8017dd:	84 d2                	test   %dl,%dl
  8017df:	74 1a                	je     8017fb <strchr+0x2a>
  8017e1:	88 d9                	mov    %bl,%cl
		if (*s == c)
  8017e3:	38 d3                	cmp    %dl,%bl
  8017e5:	75 06                	jne    8017ed <strchr+0x1c>
  8017e7:	eb 17                	jmp    801800 <strchr+0x2f>
  8017e9:	38 ca                	cmp    %cl,%dl
  8017eb:	74 13                	je     801800 <strchr+0x2f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017ed:	40                   	inc    %eax
  8017ee:	8a 10                	mov    (%eax),%dl
  8017f0:	84 d2                	test   %dl,%dl
  8017f2:	75 f5                	jne    8017e9 <strchr+0x18>
		if (*s == c)
			return (char *) s;
	return 0;
  8017f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8017f9:	eb 05                	jmp    801800 <strchr+0x2f>
  8017fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801800:	5b                   	pop    %ebx
  801801:	5d                   	pop    %ebp
  801802:	c3                   	ret    

00801803 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801803:	55                   	push   %ebp
  801804:	89 e5                	mov    %esp,%ebp
  801806:	53                   	push   %ebx
  801807:	8b 45 08             	mov    0x8(%ebp),%eax
  80180a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  80180d:	8a 10                	mov    (%eax),%dl
  80180f:	84 d2                	test   %dl,%dl
  801811:	74 13                	je     801826 <strfind+0x23>
  801813:	88 d9                	mov    %bl,%cl
		if (*s == c)
  801815:	38 d3                	cmp    %dl,%bl
  801817:	75 06                	jne    80181f <strfind+0x1c>
  801819:	eb 0b                	jmp    801826 <strfind+0x23>
  80181b:	38 ca                	cmp    %cl,%dl
  80181d:	74 07                	je     801826 <strfind+0x23>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80181f:	40                   	inc    %eax
  801820:	8a 10                	mov    (%eax),%dl
  801822:	84 d2                	test   %dl,%dl
  801824:	75 f5                	jne    80181b <strfind+0x18>
		if (*s == c)
			break;
	return (char *) s;
}
  801826:	5b                   	pop    %ebx
  801827:	5d                   	pop    %ebp
  801828:	c3                   	ret    

00801829 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801829:	55                   	push   %ebp
  80182a:	89 e5                	mov    %esp,%ebp
  80182c:	57                   	push   %edi
  80182d:	56                   	push   %esi
  80182e:	53                   	push   %ebx
  80182f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801832:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801835:	85 c9                	test   %ecx,%ecx
  801837:	74 36                	je     80186f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801839:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80183f:	75 28                	jne    801869 <memset+0x40>
  801841:	f6 c1 03             	test   $0x3,%cl
  801844:	75 23                	jne    801869 <memset+0x40>
		c &= 0xFF;
  801846:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80184a:	89 d3                	mov    %edx,%ebx
  80184c:	c1 e3 08             	shl    $0x8,%ebx
  80184f:	89 d6                	mov    %edx,%esi
  801851:	c1 e6 18             	shl    $0x18,%esi
  801854:	89 d0                	mov    %edx,%eax
  801856:	c1 e0 10             	shl    $0x10,%eax
  801859:	09 f0                	or     %esi,%eax
  80185b:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80185d:	89 d8                	mov    %ebx,%eax
  80185f:	09 d0                	or     %edx,%eax
  801861:	c1 e9 02             	shr    $0x2,%ecx
  801864:	fc                   	cld    
  801865:	f3 ab                	rep stos %eax,%es:(%edi)
  801867:	eb 06                	jmp    80186f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801869:	8b 45 0c             	mov    0xc(%ebp),%eax
  80186c:	fc                   	cld    
  80186d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80186f:	89 f8                	mov    %edi,%eax
  801871:	5b                   	pop    %ebx
  801872:	5e                   	pop    %esi
  801873:	5f                   	pop    %edi
  801874:	5d                   	pop    %ebp
  801875:	c3                   	ret    

00801876 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801876:	55                   	push   %ebp
  801877:	89 e5                	mov    %esp,%ebp
  801879:	57                   	push   %edi
  80187a:	56                   	push   %esi
  80187b:	8b 45 08             	mov    0x8(%ebp),%eax
  80187e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801881:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801884:	39 c6                	cmp    %eax,%esi
  801886:	73 33                	jae    8018bb <memmove+0x45>
  801888:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80188b:	39 d0                	cmp    %edx,%eax
  80188d:	73 2c                	jae    8018bb <memmove+0x45>
		s += n;
		d += n;
  80188f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801892:	89 d6                	mov    %edx,%esi
  801894:	09 fe                	or     %edi,%esi
  801896:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80189c:	75 13                	jne    8018b1 <memmove+0x3b>
  80189e:	f6 c1 03             	test   $0x3,%cl
  8018a1:	75 0e                	jne    8018b1 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8018a3:	83 ef 04             	sub    $0x4,%edi
  8018a6:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018a9:	c1 e9 02             	shr    $0x2,%ecx
  8018ac:	fd                   	std    
  8018ad:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018af:	eb 07                	jmp    8018b8 <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8018b1:	4f                   	dec    %edi
  8018b2:	8d 72 ff             	lea    -0x1(%edx),%esi
  8018b5:	fd                   	std    
  8018b6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018b8:	fc                   	cld    
  8018b9:	eb 1d                	jmp    8018d8 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018bb:	89 f2                	mov    %esi,%edx
  8018bd:	09 c2                	or     %eax,%edx
  8018bf:	f6 c2 03             	test   $0x3,%dl
  8018c2:	75 0f                	jne    8018d3 <memmove+0x5d>
  8018c4:	f6 c1 03             	test   $0x3,%cl
  8018c7:	75 0a                	jne    8018d3 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
  8018c9:	c1 e9 02             	shr    $0x2,%ecx
  8018cc:	89 c7                	mov    %eax,%edi
  8018ce:	fc                   	cld    
  8018cf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018d1:	eb 05                	jmp    8018d8 <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018d3:	89 c7                	mov    %eax,%edi
  8018d5:	fc                   	cld    
  8018d6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018d8:	5e                   	pop    %esi
  8018d9:	5f                   	pop    %edi
  8018da:	5d                   	pop    %ebp
  8018db:	c3                   	ret    

008018dc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018dc:	55                   	push   %ebp
  8018dd:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018df:	ff 75 10             	pushl  0x10(%ebp)
  8018e2:	ff 75 0c             	pushl  0xc(%ebp)
  8018e5:	ff 75 08             	pushl  0x8(%ebp)
  8018e8:	e8 89 ff ff ff       	call   801876 <memmove>
}
  8018ed:	c9                   	leave  
  8018ee:	c3                   	ret    

008018ef <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018ef:	55                   	push   %ebp
  8018f0:	89 e5                	mov    %esp,%ebp
  8018f2:	57                   	push   %edi
  8018f3:	56                   	push   %esi
  8018f4:	53                   	push   %ebx
  8018f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8018f8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018fb:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018fe:	85 c0                	test   %eax,%eax
  801900:	74 33                	je     801935 <memcmp+0x46>
  801902:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  801905:	8a 13                	mov    (%ebx),%dl
  801907:	8a 0e                	mov    (%esi),%cl
  801909:	38 ca                	cmp    %cl,%dl
  80190b:	75 13                	jne    801920 <memcmp+0x31>
  80190d:	b8 00 00 00 00       	mov    $0x0,%eax
  801912:	eb 16                	jmp    80192a <memcmp+0x3b>
  801914:	8a 54 03 01          	mov    0x1(%ebx,%eax,1),%dl
  801918:	40                   	inc    %eax
  801919:	8a 0c 06             	mov    (%esi,%eax,1),%cl
  80191c:	38 ca                	cmp    %cl,%dl
  80191e:	74 0a                	je     80192a <memcmp+0x3b>
			return (int) *s1 - (int) *s2;
  801920:	0f b6 c2             	movzbl %dl,%eax
  801923:	0f b6 c9             	movzbl %cl,%ecx
  801926:	29 c8                	sub    %ecx,%eax
  801928:	eb 10                	jmp    80193a <memcmp+0x4b>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80192a:	39 f8                	cmp    %edi,%eax
  80192c:	75 e6                	jne    801914 <memcmp+0x25>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80192e:	b8 00 00 00 00       	mov    $0x0,%eax
  801933:	eb 05                	jmp    80193a <memcmp+0x4b>
  801935:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80193a:	5b                   	pop    %ebx
  80193b:	5e                   	pop    %esi
  80193c:	5f                   	pop    %edi
  80193d:	5d                   	pop    %ebp
  80193e:	c3                   	ret    

0080193f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80193f:	55                   	push   %ebp
  801940:	89 e5                	mov    %esp,%ebp
  801942:	53                   	push   %ebx
  801943:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  801946:	89 d0                	mov    %edx,%eax
  801948:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  80194b:	39 c2                	cmp    %eax,%edx
  80194d:	73 1b                	jae    80196a <memfind+0x2b>
		if (*(const unsigned char *) s == (unsigned char) c)
  80194f:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  801953:	0f b6 0a             	movzbl (%edx),%ecx
  801956:	39 d9                	cmp    %ebx,%ecx
  801958:	75 09                	jne    801963 <memfind+0x24>
  80195a:	eb 12                	jmp    80196e <memfind+0x2f>
  80195c:	0f b6 0a             	movzbl (%edx),%ecx
  80195f:	39 d9                	cmp    %ebx,%ecx
  801961:	74 0f                	je     801972 <memfind+0x33>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801963:	42                   	inc    %edx
  801964:	39 d0                	cmp    %edx,%eax
  801966:	75 f4                	jne    80195c <memfind+0x1d>
  801968:	eb 0a                	jmp    801974 <memfind+0x35>
  80196a:	89 d0                	mov    %edx,%eax
  80196c:	eb 06                	jmp    801974 <memfind+0x35>
		if (*(const unsigned char *) s == (unsigned char) c)
  80196e:	89 d0                	mov    %edx,%eax
  801970:	eb 02                	jmp    801974 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801972:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801974:	5b                   	pop    %ebx
  801975:	5d                   	pop    %ebp
  801976:	c3                   	ret    

00801977 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801977:	55                   	push   %ebp
  801978:	89 e5                	mov    %esp,%ebp
  80197a:	57                   	push   %edi
  80197b:	56                   	push   %esi
  80197c:	53                   	push   %ebx
  80197d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801980:	eb 01                	jmp    801983 <strtol+0xc>
		s++;
  801982:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801983:	8a 01                	mov    (%ecx),%al
  801985:	3c 20                	cmp    $0x20,%al
  801987:	74 f9                	je     801982 <strtol+0xb>
  801989:	3c 09                	cmp    $0x9,%al
  80198b:	74 f5                	je     801982 <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  80198d:	3c 2b                	cmp    $0x2b,%al
  80198f:	75 08                	jne    801999 <strtol+0x22>
		s++;
  801991:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801992:	bf 00 00 00 00       	mov    $0x0,%edi
  801997:	eb 11                	jmp    8019aa <strtol+0x33>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801999:	3c 2d                	cmp    $0x2d,%al
  80199b:	75 08                	jne    8019a5 <strtol+0x2e>
		s++, neg = 1;
  80199d:	41                   	inc    %ecx
  80199e:	bf 01 00 00 00       	mov    $0x1,%edi
  8019a3:	eb 05                	jmp    8019aa <strtol+0x33>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8019a5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019aa:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019ae:	0f 84 87 00 00 00    	je     801a3b <strtol+0xc4>
  8019b4:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  8019b8:	75 27                	jne    8019e1 <strtol+0x6a>
  8019ba:	80 39 30             	cmpb   $0x30,(%ecx)
  8019bd:	75 22                	jne    8019e1 <strtol+0x6a>
  8019bf:	e9 88 00 00 00       	jmp    801a4c <strtol+0xd5>
		s += 2, base = 16;
  8019c4:	83 c1 02             	add    $0x2,%ecx
  8019c7:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  8019ce:	eb 11                	jmp    8019e1 <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
  8019d0:	41                   	inc    %ecx
  8019d1:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  8019d8:	eb 07                	jmp    8019e1 <strtol+0x6a>
	else if (base == 0)
		base = 10;
  8019da:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  8019e1:	b8 00 00 00 00       	mov    $0x0,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019e6:	8a 11                	mov    (%ecx),%dl
  8019e8:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8019eb:	80 fb 09             	cmp    $0x9,%bl
  8019ee:	77 08                	ja     8019f8 <strtol+0x81>
			dig = *s - '0';
  8019f0:	0f be d2             	movsbl %dl,%edx
  8019f3:	83 ea 30             	sub    $0x30,%edx
  8019f6:	eb 22                	jmp    801a1a <strtol+0xa3>
		else if (*s >= 'a' && *s <= 'z')
  8019f8:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019fb:	89 f3                	mov    %esi,%ebx
  8019fd:	80 fb 19             	cmp    $0x19,%bl
  801a00:	77 08                	ja     801a0a <strtol+0x93>
			dig = *s - 'a' + 10;
  801a02:	0f be d2             	movsbl %dl,%edx
  801a05:	83 ea 57             	sub    $0x57,%edx
  801a08:	eb 10                	jmp    801a1a <strtol+0xa3>
		else if (*s >= 'A' && *s <= 'Z')
  801a0a:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a0d:	89 f3                	mov    %esi,%ebx
  801a0f:	80 fb 19             	cmp    $0x19,%bl
  801a12:	77 14                	ja     801a28 <strtol+0xb1>
			dig = *s - 'A' + 10;
  801a14:	0f be d2             	movsbl %dl,%edx
  801a17:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801a1a:	3b 55 10             	cmp    0x10(%ebp),%edx
  801a1d:	7d 09                	jge    801a28 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  801a1f:	41                   	inc    %ecx
  801a20:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a24:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801a26:	eb be                	jmp    8019e6 <strtol+0x6f>

	if (endptr)
  801a28:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a2c:	74 05                	je     801a33 <strtol+0xbc>
		*endptr = (char *) s;
  801a2e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a31:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801a33:	85 ff                	test   %edi,%edi
  801a35:	74 21                	je     801a58 <strtol+0xe1>
  801a37:	f7 d8                	neg    %eax
  801a39:	eb 1d                	jmp    801a58 <strtol+0xe1>
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801a3b:	80 39 30             	cmpb   $0x30,(%ecx)
  801a3e:	75 9a                	jne    8019da <strtol+0x63>
  801a40:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801a44:	0f 84 7a ff ff ff    	je     8019c4 <strtol+0x4d>
  801a4a:	eb 84                	jmp    8019d0 <strtol+0x59>
  801a4c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801a50:	0f 84 6e ff ff ff    	je     8019c4 <strtol+0x4d>
  801a56:	eb 89                	jmp    8019e1 <strtol+0x6a>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  801a58:	5b                   	pop    %ebx
  801a59:	5e                   	pop    %esi
  801a5a:	5f                   	pop    %edi
  801a5b:	5d                   	pop    %ebp
  801a5c:	c3                   	ret    

00801a5d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a5d:	55                   	push   %ebp
  801a5e:	89 e5                	mov    %esp,%ebp
  801a60:	56                   	push   %esi
  801a61:	53                   	push   %ebx
  801a62:	8b 75 08             	mov    0x8(%ebp),%esi
  801a65:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a68:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");
	int r;
    if (pg != NULL) {
  801a6b:	85 c0                	test   %eax,%eax
  801a6d:	74 0e                	je     801a7d <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  801a6f:	83 ec 0c             	sub    $0xc,%esp
  801a72:	50                   	push   %eax
  801a73:	e8 9b e8 ff ff       	call   800313 <sys_ipc_recv>
  801a78:	83 c4 10             	add    $0x10,%esp
  801a7b:	eb 10                	jmp    801a8d <ipc_recv+0x30>
    } else {
        r = sys_ipc_recv((void *) UTOP);
  801a7d:	83 ec 0c             	sub    $0xc,%esp
  801a80:	68 00 00 c0 ee       	push   $0xeec00000
  801a85:	e8 89 e8 ff ff       	call   800313 <sys_ipc_recv>
  801a8a:	83 c4 10             	add    $0x10,%esp
    }
    if (r < 0) {
  801a8d:	85 c0                	test   %eax,%eax
  801a8f:	79 16                	jns    801aa7 <ipc_recv+0x4a>
        // failed
        if (from_env_store != NULL) *from_env_store = 0;
  801a91:	85 f6                	test   %esi,%esi
  801a93:	74 06                	je     801a9b <ipc_recv+0x3e>
  801a95:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL) *perm_store = 0;
  801a9b:	85 db                	test   %ebx,%ebx
  801a9d:	74 2c                	je     801acb <ipc_recv+0x6e>
  801a9f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801aa5:	eb 24                	jmp    801acb <ipc_recv+0x6e>
        return r;
    } else {
        if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801aa7:	85 f6                	test   %esi,%esi
  801aa9:	74 0a                	je     801ab5 <ipc_recv+0x58>
  801aab:	a1 04 40 80 00       	mov    0x804004,%eax
  801ab0:	8b 40 74             	mov    0x74(%eax),%eax
  801ab3:	89 06                	mov    %eax,(%esi)
        if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801ab5:	85 db                	test   %ebx,%ebx
  801ab7:	74 0a                	je     801ac3 <ipc_recv+0x66>
  801ab9:	a1 04 40 80 00       	mov    0x804004,%eax
  801abe:	8b 40 78             	mov    0x78(%eax),%eax
  801ac1:	89 03                	mov    %eax,(%ebx)
        return thisenv->env_ipc_value;
  801ac3:	a1 04 40 80 00       	mov    0x804004,%eax
  801ac8:	8b 40 70             	mov    0x70(%eax),%eax
    }
 
	return 0;
}
  801acb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ace:	5b                   	pop    %ebx
  801acf:	5e                   	pop    %esi
  801ad0:	5d                   	pop    %ebp
  801ad1:	c3                   	ret    

00801ad2 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ad2:	55                   	push   %ebp
  801ad3:	89 e5                	mov    %esp,%ebp
  801ad5:	57                   	push   %edi
  801ad6:	56                   	push   %esi
  801ad7:	53                   	push   %ebx
  801ad8:	83 ec 0c             	sub    $0xc,%esp
  801adb:	8b 75 10             	mov    0x10(%ebp),%esi
  801ade:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;
    if (pg == NULL) pg = (void *)UTOP;
  801ae1:	85 f6                	test   %esi,%esi
  801ae3:	75 05                	jne    801aea <ipc_send+0x18>
  801ae5:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
  801aea:	57                   	push   %edi
  801aeb:	56                   	push   %esi
  801aec:	ff 75 0c             	pushl  0xc(%ebp)
  801aef:	ff 75 08             	pushl  0x8(%ebp)
  801af2:	e8 f9 e7 ff ff       	call   8002f0 <sys_ipc_try_send>
  801af7:	89 c3                	mov    %eax,%ebx
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
  801af9:	83 c4 10             	add    $0x10,%esp
  801afc:	85 c0                	test   %eax,%eax
  801afe:	79 17                	jns    801b17 <ipc_send+0x45>
  801b00:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b03:	74 1d                	je     801b22 <ipc_send+0x50>
  801b05:	50                   	push   %eax
  801b06:	68 80 22 80 00       	push   $0x802280
  801b0b:	6a 40                	push   $0x40
  801b0d:	68 94 22 80 00       	push   $0x802294
  801b12:	e8 d5 f4 ff ff       	call   800fec <_panic>
        sys_yield();
  801b17:	e8 28 e6 ff ff       	call   800144 <sys_yield>
    } while (r != 0);
  801b1c:	85 db                	test   %ebx,%ebx
  801b1e:	75 ca                	jne    801aea <ipc_send+0x18>
  801b20:	eb 07                	jmp    801b29 <ipc_send+0x57>
	int r;
    if (pg == NULL) pg = (void *)UTOP;
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
        sys_yield();
  801b22:	e8 1d e6 ff ff       	call   800144 <sys_yield>
  801b27:	eb c1                	jmp    801aea <ipc_send+0x18>
    } while (r != 0);
}
  801b29:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b2c:	5b                   	pop    %ebx
  801b2d:	5e                   	pop    %esi
  801b2e:	5f                   	pop    %edi
  801b2f:	5d                   	pop    %ebp
  801b30:	c3                   	ret    

00801b31 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b31:	55                   	push   %ebp
  801b32:	89 e5                	mov    %esp,%ebp
  801b34:	53                   	push   %ebx
  801b35:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801b38:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801b3d:	39 c1                	cmp    %eax,%ecx
  801b3f:	74 21                	je     801b62 <ipc_find_env+0x31>
  801b41:	ba 01 00 00 00       	mov    $0x1,%edx
  801b46:	8d 1c 95 00 00 00 00 	lea    0x0(,%edx,4),%ebx
  801b4d:	89 d0                	mov    %edx,%eax
  801b4f:	c1 e0 07             	shl    $0x7,%eax
  801b52:	29 d8                	sub    %ebx,%eax
  801b54:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b59:	8b 40 50             	mov    0x50(%eax),%eax
  801b5c:	39 c8                	cmp    %ecx,%eax
  801b5e:	75 1b                	jne    801b7b <ipc_find_env+0x4a>
  801b60:	eb 05                	jmp    801b67 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b62:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801b67:	8d 04 95 00 00 00 00 	lea    0x0(,%edx,4),%eax
  801b6e:	c1 e2 07             	shl    $0x7,%edx
  801b71:	29 c2                	sub    %eax,%edx
  801b73:	8b 82 48 00 c0 ee    	mov    -0x113fffb8(%edx),%eax
  801b79:	eb 0e                	jmp    801b89 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b7b:	42                   	inc    %edx
  801b7c:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  801b82:	75 c2                	jne    801b46 <ipc_find_env+0x15>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b84:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b89:	5b                   	pop    %ebx
  801b8a:	5d                   	pop    %ebp
  801b8b:	c3                   	ret    

00801b8c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b8c:	55                   	push   %ebp
  801b8d:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b8f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b92:	c1 e8 16             	shr    $0x16,%eax
  801b95:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801b9c:	a8 01                	test   $0x1,%al
  801b9e:	74 21                	je     801bc1 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801ba0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba3:	c1 e8 0c             	shr    $0xc,%eax
  801ba6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801bad:	a8 01                	test   $0x1,%al
  801baf:	74 17                	je     801bc8 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bb1:	c1 e8 0c             	shr    $0xc,%eax
  801bb4:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801bbb:	ef 
  801bbc:	0f b7 c0             	movzwl %ax,%eax
  801bbf:	eb 0c                	jmp    801bcd <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801bc1:	b8 00 00 00 00       	mov    $0x0,%eax
  801bc6:	eb 05                	jmp    801bcd <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801bc8:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801bcd:	5d                   	pop    %ebp
  801bce:	c3                   	ret    
  801bcf:	90                   	nop

00801bd0 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801bd0:	55                   	push   %ebp
  801bd1:	57                   	push   %edi
  801bd2:	56                   	push   %esi
  801bd3:	53                   	push   %ebx
  801bd4:	83 ec 1c             	sub    $0x1c,%esp
  801bd7:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801bdb:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801bdf:	8b 7c 24 38          	mov    0x38(%esp),%edi
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801be3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801be7:	89 ca                	mov    %ecx,%edx
  const DWunion dd = {.ll = d};
  801be9:	89 f8                	mov    %edi,%eax
  801beb:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801bef:	85 f6                	test   %esi,%esi
  801bf1:	75 2d                	jne    801c20 <__udivdi3+0x50>
    {
      if (d0 > n1)
  801bf3:	39 cf                	cmp    %ecx,%edi
  801bf5:	77 65                	ja     801c5c <__udivdi3+0x8c>
  801bf7:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801bf9:	85 ff                	test   %edi,%edi
  801bfb:	75 0b                	jne    801c08 <__udivdi3+0x38>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801bfd:	b8 01 00 00 00       	mov    $0x1,%eax
  801c02:	31 d2                	xor    %edx,%edx
  801c04:	f7 f7                	div    %edi
  801c06:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801c08:	31 d2                	xor    %edx,%edx
  801c0a:	89 c8                	mov    %ecx,%eax
  801c0c:	f7 f5                	div    %ebp
  801c0e:	89 c1                	mov    %eax,%ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c10:	89 d8                	mov    %ebx,%eax
  801c12:	f7 f5                	div    %ebp
  801c14:	89 cf                	mov    %ecx,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c16:	89 fa                	mov    %edi,%edx
  801c18:	83 c4 1c             	add    $0x1c,%esp
  801c1b:	5b                   	pop    %ebx
  801c1c:	5e                   	pop    %esi
  801c1d:	5f                   	pop    %edi
  801c1e:	5d                   	pop    %ebp
  801c1f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801c20:	39 ce                	cmp    %ecx,%esi
  801c22:	77 28                	ja     801c4c <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801c24:	0f bd fe             	bsr    %esi,%edi
	  if (bm == 0)
  801c27:	83 f7 1f             	xor    $0x1f,%edi
  801c2a:	75 40                	jne    801c6c <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801c2c:	39 ce                	cmp    %ecx,%esi
  801c2e:	72 0a                	jb     801c3a <__udivdi3+0x6a>
  801c30:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801c34:	0f 87 9e 00 00 00    	ja     801cd8 <__udivdi3+0x108>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801c3a:	b8 01 00 00 00       	mov    $0x1,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c3f:	89 fa                	mov    %edi,%edx
  801c41:	83 c4 1c             	add    $0x1c,%esp
  801c44:	5b                   	pop    %ebx
  801c45:	5e                   	pop    %esi
  801c46:	5f                   	pop    %edi
  801c47:	5d                   	pop    %ebp
  801c48:	c3                   	ret    
  801c49:	8d 76 00             	lea    0x0(%esi),%esi
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801c4c:	31 ff                	xor    %edi,%edi
  801c4e:	31 c0                	xor    %eax,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c50:	89 fa                	mov    %edi,%edx
  801c52:	83 c4 1c             	add    $0x1c,%esp
  801c55:	5b                   	pop    %ebx
  801c56:	5e                   	pop    %esi
  801c57:	5f                   	pop    %edi
  801c58:	5d                   	pop    %ebp
  801c59:	c3                   	ret    
  801c5a:	66 90                	xchg   %ax,%ax
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c5c:	89 d8                	mov    %ebx,%eax
  801c5e:	f7 f7                	div    %edi
  801c60:	31 ff                	xor    %edi,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c62:	89 fa                	mov    %edi,%edx
  801c64:	83 c4 1c             	add    $0x1c,%esp
  801c67:	5b                   	pop    %ebx
  801c68:	5e                   	pop    %esi
  801c69:	5f                   	pop    %edi
  801c6a:	5d                   	pop    %ebp
  801c6b:	c3                   	ret    
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801c6c:	bd 20 00 00 00       	mov    $0x20,%ebp
  801c71:	89 eb                	mov    %ebp,%ebx
  801c73:	29 fb                	sub    %edi,%ebx

	      d1 = (d1 << bm) | (d0 >> b);
  801c75:	89 f9                	mov    %edi,%ecx
  801c77:	d3 e6                	shl    %cl,%esi
  801c79:	89 c5                	mov    %eax,%ebp
  801c7b:	88 d9                	mov    %bl,%cl
  801c7d:	d3 ed                	shr    %cl,%ebp
  801c7f:	89 e9                	mov    %ebp,%ecx
  801c81:	09 f1                	or     %esi,%ecx
  801c83:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
	      d0 = d0 << bm;
  801c87:	89 f9                	mov    %edi,%ecx
  801c89:	d3 e0                	shl    %cl,%eax
  801c8b:	89 c5                	mov    %eax,%ebp
	      n2 = n1 >> b;
  801c8d:	89 d6                	mov    %edx,%esi
  801c8f:	88 d9                	mov    %bl,%cl
  801c91:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
  801c93:	89 f9                	mov    %edi,%ecx
  801c95:	d3 e2                	shl    %cl,%edx
  801c97:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c9b:	88 d9                	mov    %bl,%cl
  801c9d:	d3 e8                	shr    %cl,%eax
  801c9f:	09 c2                	or     %eax,%edx
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801ca1:	89 d0                	mov    %edx,%eax
  801ca3:	89 f2                	mov    %esi,%edx
  801ca5:	f7 74 24 0c          	divl   0xc(%esp)
  801ca9:	89 d6                	mov    %edx,%esi
  801cab:	89 c3                	mov    %eax,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  801cad:	f7 e5                	mul    %ebp

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801caf:	39 d6                	cmp    %edx,%esi
  801cb1:	72 19                	jb     801ccc <__udivdi3+0xfc>
  801cb3:	74 0b                	je     801cc0 <__udivdi3+0xf0>
  801cb5:	89 d8                	mov    %ebx,%eax
  801cb7:	31 ff                	xor    %edi,%edi
  801cb9:	e9 58 ff ff ff       	jmp    801c16 <__udivdi3+0x46>
  801cbe:	66 90                	xchg   %ax,%ax
  801cc0:	8b 54 24 08          	mov    0x8(%esp),%edx
  801cc4:	89 f9                	mov    %edi,%ecx
  801cc6:	d3 e2                	shl    %cl,%edx
  801cc8:	39 c2                	cmp    %eax,%edx
  801cca:	73 e9                	jae    801cb5 <__udivdi3+0xe5>
  801ccc:	8d 43 ff             	lea    -0x1(%ebx),%eax
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801ccf:	31 ff                	xor    %edi,%edi
  801cd1:	e9 40 ff ff ff       	jmp    801c16 <__udivdi3+0x46>
  801cd6:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801cd8:	31 c0                	xor    %eax,%eax
  801cda:	e9 37 ff ff ff       	jmp    801c16 <__udivdi3+0x46>
  801cdf:	90                   	nop

00801ce0 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801ce0:	55                   	push   %ebp
  801ce1:	57                   	push   %edi
  801ce2:	56                   	push   %esi
  801ce3:	53                   	push   %ebx
  801ce4:	83 ec 1c             	sub    $0x1c,%esp
  801ce7:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801ceb:	8b 74 24 34          	mov    0x34(%esp),%esi
  801cef:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801cf3:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801cf7:	89 44 24 0c          	mov    %eax,0xc(%esp)
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801cfb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801cff:	89 f3                	mov    %esi,%ebx
  const DWunion dd = {.ll = d};
  801d01:	89 fa                	mov    %edi,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801d03:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  n1 = nn.s.high;
  801d07:	89 34 24             	mov    %esi,(%esp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801d0a:	85 c0                	test   %eax,%eax
  801d0c:	75 1a                	jne    801d28 <__umoddi3+0x48>
    {
      if (d0 > n1)
  801d0e:	39 f7                	cmp    %esi,%edi
  801d10:	0f 86 a2 00 00 00    	jbe    801db8 <__umoddi3+0xd8>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d16:	89 c8                	mov    %ecx,%eax
  801d18:	89 f2                	mov    %esi,%edx
  801d1a:	f7 f7                	div    %edi
  801d1c:	89 d0                	mov    %edx,%eax

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801d1e:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d20:	83 c4 1c             	add    $0x1c,%esp
  801d23:	5b                   	pop    %ebx
  801d24:	5e                   	pop    %esi
  801d25:	5f                   	pop    %edi
  801d26:	5d                   	pop    %ebp
  801d27:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801d28:	39 f0                	cmp    %esi,%eax
  801d2a:	0f 87 ac 00 00 00    	ja     801ddc <__umoddi3+0xfc>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801d30:	0f bd e8             	bsr    %eax,%ebp
	  if (bm == 0)
  801d33:	83 f5 1f             	xor    $0x1f,%ebp
  801d36:	0f 84 ac 00 00 00    	je     801de8 <__umoddi3+0x108>
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801d3c:	bf 20 00 00 00       	mov    $0x20,%edi
  801d41:	29 ef                	sub    %ebp,%edi
  801d43:	89 fe                	mov    %edi,%esi
  801d45:	89 7c 24 0c          	mov    %edi,0xc(%esp)

	      d1 = (d1 << bm) | (d0 >> b);
  801d49:	89 e9                	mov    %ebp,%ecx
  801d4b:	d3 e0                	shl    %cl,%eax
  801d4d:	89 d7                	mov    %edx,%edi
  801d4f:	89 f1                	mov    %esi,%ecx
  801d51:	d3 ef                	shr    %cl,%edi
  801d53:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  801d55:	89 e9                	mov    %ebp,%ecx
  801d57:	d3 e2                	shl    %cl,%edx
  801d59:	89 14 24             	mov    %edx,(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801d5c:	89 d8                	mov    %ebx,%eax
  801d5e:	d3 e0                	shl    %cl,%eax
  801d60:	89 c2                	mov    %eax,%edx
	      n0 = n0 << bm;
  801d62:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d66:	d3 e0                	shl    %cl,%eax
  801d68:	89 44 24 04          	mov    %eax,0x4(%esp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801d6c:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d70:	89 f1                	mov    %esi,%ecx
  801d72:	d3 e8                	shr    %cl,%eax
  801d74:	09 d0                	or     %edx,%eax
  801d76:	d3 eb                	shr    %cl,%ebx
  801d78:	89 da                	mov    %ebx,%edx
  801d7a:	f7 f7                	div    %edi
  801d7c:	89 d3                	mov    %edx,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  801d7e:	f7 24 24             	mull   (%esp)
  801d81:	89 c6                	mov    %eax,%esi
  801d83:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d85:	39 d3                	cmp    %edx,%ebx
  801d87:	0f 82 87 00 00 00    	jb     801e14 <__umoddi3+0x134>
  801d8d:	0f 84 91 00 00 00    	je     801e24 <__umoddi3+0x144>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801d93:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d97:	29 f2                	sub    %esi,%edx
  801d99:	19 cb                	sbb    %ecx,%ebx
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801d9b:	89 d8                	mov    %ebx,%eax
  801d9d:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  801da1:	d3 e0                	shl    %cl,%eax
  801da3:	89 e9                	mov    %ebp,%ecx
  801da5:	d3 ea                	shr    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801da7:	09 d0                	or     %edx,%eax
  801da9:	89 e9                	mov    %ebp,%ecx
  801dab:	d3 eb                	shr    %cl,%ebx
  801dad:	89 da                	mov    %ebx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801daf:	83 c4 1c             	add    $0x1c,%esp
  801db2:	5b                   	pop    %ebx
  801db3:	5e                   	pop    %esi
  801db4:	5f                   	pop    %edi
  801db5:	5d                   	pop    %ebp
  801db6:	c3                   	ret    
  801db7:	90                   	nop
  801db8:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801dba:	85 ff                	test   %edi,%edi
  801dbc:	75 0b                	jne    801dc9 <__umoddi3+0xe9>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801dbe:	b8 01 00 00 00       	mov    $0x1,%eax
  801dc3:	31 d2                	xor    %edx,%edx
  801dc5:	f7 f7                	div    %edi
  801dc7:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801dc9:	89 f0                	mov    %esi,%eax
  801dcb:	31 d2                	xor    %edx,%edx
  801dcd:	f7 f5                	div    %ebp
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801dcf:	89 c8                	mov    %ecx,%eax
  801dd1:	f7 f5                	div    %ebp
  801dd3:	89 d0                	mov    %edx,%eax
  801dd5:	e9 44 ff ff ff       	jmp    801d1e <__umoddi3+0x3e>
  801dda:	66 90                	xchg   %ax,%ax
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801ddc:	89 c8                	mov    %ecx,%eax
  801dde:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801de0:	83 c4 1c             	add    $0x1c,%esp
  801de3:	5b                   	pop    %ebx
  801de4:	5e                   	pop    %esi
  801de5:	5f                   	pop    %edi
  801de6:	5d                   	pop    %ebp
  801de7:	c3                   	ret    

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801de8:	3b 04 24             	cmp    (%esp),%eax
  801deb:	72 06                	jb     801df3 <__umoddi3+0x113>
  801ded:	3b 7c 24 04          	cmp    0x4(%esp),%edi
  801df1:	77 0f                	ja     801e02 <__umoddi3+0x122>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801df3:	89 f2                	mov    %esi,%edx
  801df5:	29 f9                	sub    %edi,%ecx
  801df7:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  801dfb:	89 14 24             	mov    %edx,(%esp)
  801dfe:	89 4c 24 04          	mov    %ecx,0x4(%esp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801e02:	8b 44 24 04          	mov    0x4(%esp),%eax
  801e06:	8b 14 24             	mov    (%esp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e09:	83 c4 1c             	add    $0x1c,%esp
  801e0c:	5b                   	pop    %ebx
  801e0d:	5e                   	pop    %esi
  801e0e:	5f                   	pop    %edi
  801e0f:	5d                   	pop    %ebp
  801e10:	c3                   	ret    
  801e11:	8d 76 00             	lea    0x0(%esi),%esi
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801e14:	2b 04 24             	sub    (%esp),%eax
  801e17:	19 fa                	sbb    %edi,%edx
  801e19:	89 d1                	mov    %edx,%ecx
  801e1b:	89 c6                	mov    %eax,%esi
  801e1d:	e9 71 ff ff ff       	jmp    801d93 <__umoddi3+0xb3>
  801e22:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e24:	39 44 24 04          	cmp    %eax,0x4(%esp)
  801e28:	72 ea                	jb     801e14 <__umoddi3+0x134>
  801e2a:	89 d9                	mov    %ebx,%ecx
  801e2c:	e9 62 ff ff ff       	jmp    801d93 <__umoddi3+0xb3>
