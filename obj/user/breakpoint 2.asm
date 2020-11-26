
obj/user/breakpoint.debug:     file format elf32-i386


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
  80002c:	e8 08 00 00 00       	call   800039 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $3");
  800036:	cc                   	int3   
}
  800037:	5d                   	pop    %ebp
  800038:	c3                   	ret    

00800039 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800039:	55                   	push   %ebp
  80003a:	89 e5                	mov    %esp,%ebp
  80003c:	56                   	push   %esi
  80003d:	53                   	push   %ebx
  80003e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800041:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800044:	e8 d7 00 00 00       	call   800120 <sys_getenvid>
  800049:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800055:	c1 e0 07             	shl    $0x7,%eax
  800058:	29 d0                	sub    %edx,%eax
  80005a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005f:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800064:	85 db                	test   %ebx,%ebx
  800066:	7e 07                	jle    80006f <libmain+0x36>
		binaryname = argv[0];
  800068:	8b 06                	mov    (%esi),%eax
  80006a:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80006f:	83 ec 08             	sub    $0x8,%esp
  800072:	56                   	push   %esi
  800073:	53                   	push   %ebx
  800074:	e8 ba ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800079:	e8 0a 00 00 00       	call   800088 <exit>
}
  80007e:	83 c4 10             	add    $0x10,%esp
  800081:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800084:	5b                   	pop    %ebx
  800085:	5e                   	pop    %esi
  800086:	5d                   	pop    %ebp
  800087:	c3                   	ret    

00800088 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800088:	55                   	push   %ebp
  800089:	89 e5                	mov    %esp,%ebp
  80008b:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80008e:	e8 cb 04 00 00       	call   80055e <close_all>
	sys_env_destroy(0);
  800093:	83 ec 0c             	sub    $0xc,%esp
  800096:	6a 00                	push   $0x0
  800098:	e8 42 00 00 00       	call   8000df <sys_env_destroy>
}
  80009d:	83 c4 10             	add    $0x10,%esp
  8000a0:	c9                   	leave  
  8000a1:	c3                   	ret    

008000a2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a2:	55                   	push   %ebp
  8000a3:	89 e5                	mov    %esp,%ebp
  8000a5:	57                   	push   %edi
  8000a6:	56                   	push   %esi
  8000a7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b3:	89 c3                	mov    %eax,%ebx
  8000b5:	89 c7                	mov    %eax,%edi
  8000b7:	89 c6                	mov    %eax,%esi
  8000b9:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000bb:	5b                   	pop    %ebx
  8000bc:	5e                   	pop    %esi
  8000bd:	5f                   	pop    %edi
  8000be:	5d                   	pop    %ebp
  8000bf:	c3                   	ret    

008000c0 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	57                   	push   %edi
  8000c4:	56                   	push   %esi
  8000c5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cb:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d0:	89 d1                	mov    %edx,%ecx
  8000d2:	89 d3                	mov    %edx,%ebx
  8000d4:	89 d7                	mov    %edx,%edi
  8000d6:	89 d6                	mov    %edx,%esi
  8000d8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000da:	5b                   	pop    %ebx
  8000db:	5e                   	pop    %esi
  8000dc:	5f                   	pop    %edi
  8000dd:	5d                   	pop    %ebp
  8000de:	c3                   	ret    

008000df <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000df:	55                   	push   %ebp
  8000e0:	89 e5                	mov    %esp,%ebp
  8000e2:	57                   	push   %edi
  8000e3:	56                   	push   %esi
  8000e4:	53                   	push   %ebx
  8000e5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ed:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f5:	89 cb                	mov    %ecx,%ebx
  8000f7:	89 cf                	mov    %ecx,%edi
  8000f9:	89 ce                	mov    %ecx,%esi
  8000fb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000fd:	85 c0                	test   %eax,%eax
  8000ff:	7e 17                	jle    800118 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800101:	83 ec 0c             	sub    $0xc,%esp
  800104:	50                   	push   %eax
  800105:	6a 03                	push   $0x3
  800107:	68 4a 1e 80 00       	push   $0x801e4a
  80010c:	6a 23                	push   $0x23
  80010e:	68 67 1e 80 00       	push   $0x801e67
  800113:	e8 cf 0e 00 00       	call   800fe7 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800118:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80011b:	5b                   	pop    %ebx
  80011c:	5e                   	pop    %esi
  80011d:	5f                   	pop    %edi
  80011e:	5d                   	pop    %ebp
  80011f:	c3                   	ret    

00800120 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
  800123:	57                   	push   %edi
  800124:	56                   	push   %esi
  800125:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800126:	ba 00 00 00 00       	mov    $0x0,%edx
  80012b:	b8 02 00 00 00       	mov    $0x2,%eax
  800130:	89 d1                	mov    %edx,%ecx
  800132:	89 d3                	mov    %edx,%ebx
  800134:	89 d7                	mov    %edx,%edi
  800136:	89 d6                	mov    %edx,%esi
  800138:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013a:	5b                   	pop    %ebx
  80013b:	5e                   	pop    %esi
  80013c:	5f                   	pop    %edi
  80013d:	5d                   	pop    %ebp
  80013e:	c3                   	ret    

0080013f <sys_yield>:

void
sys_yield(void)
{
  80013f:	55                   	push   %ebp
  800140:	89 e5                	mov    %esp,%ebp
  800142:	57                   	push   %edi
  800143:	56                   	push   %esi
  800144:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800145:	ba 00 00 00 00       	mov    $0x0,%edx
  80014a:	b8 0b 00 00 00       	mov    $0xb,%eax
  80014f:	89 d1                	mov    %edx,%ecx
  800151:	89 d3                	mov    %edx,%ebx
  800153:	89 d7                	mov    %edx,%edi
  800155:	89 d6                	mov    %edx,%esi
  800157:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800159:	5b                   	pop    %ebx
  80015a:	5e                   	pop    %esi
  80015b:	5f                   	pop    %edi
  80015c:	5d                   	pop    %ebp
  80015d:	c3                   	ret    

0080015e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80015e:	55                   	push   %ebp
  80015f:	89 e5                	mov    %esp,%ebp
  800161:	57                   	push   %edi
  800162:	56                   	push   %esi
  800163:	53                   	push   %ebx
  800164:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800167:	be 00 00 00 00       	mov    $0x0,%esi
  80016c:	b8 04 00 00 00       	mov    $0x4,%eax
  800171:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800174:	8b 55 08             	mov    0x8(%ebp),%edx
  800177:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017a:	89 f7                	mov    %esi,%edi
  80017c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80017e:	85 c0                	test   %eax,%eax
  800180:	7e 17                	jle    800199 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800182:	83 ec 0c             	sub    $0xc,%esp
  800185:	50                   	push   %eax
  800186:	6a 04                	push   $0x4
  800188:	68 4a 1e 80 00       	push   $0x801e4a
  80018d:	6a 23                	push   $0x23
  80018f:	68 67 1e 80 00       	push   $0x801e67
  800194:	e8 4e 0e 00 00       	call   800fe7 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800199:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80019c:	5b                   	pop    %ebx
  80019d:	5e                   	pop    %esi
  80019e:	5f                   	pop    %edi
  80019f:	5d                   	pop    %ebp
  8001a0:	c3                   	ret    

008001a1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a1:	55                   	push   %ebp
  8001a2:	89 e5                	mov    %esp,%ebp
  8001a4:	57                   	push   %edi
  8001a5:	56                   	push   %esi
  8001a6:	53                   	push   %ebx
  8001a7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001aa:	b8 05 00 00 00       	mov    $0x5,%eax
  8001af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b8:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001bb:	8b 75 18             	mov    0x18(%ebp),%esi
  8001be:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001c0:	85 c0                	test   %eax,%eax
  8001c2:	7e 17                	jle    8001db <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c4:	83 ec 0c             	sub    $0xc,%esp
  8001c7:	50                   	push   %eax
  8001c8:	6a 05                	push   $0x5
  8001ca:	68 4a 1e 80 00       	push   $0x801e4a
  8001cf:	6a 23                	push   $0x23
  8001d1:	68 67 1e 80 00       	push   $0x801e67
  8001d6:	e8 0c 0e 00 00       	call   800fe7 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001de:	5b                   	pop    %ebx
  8001df:	5e                   	pop    %esi
  8001e0:	5f                   	pop    %edi
  8001e1:	5d                   	pop    %ebp
  8001e2:	c3                   	ret    

008001e3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e3:	55                   	push   %ebp
  8001e4:	89 e5                	mov    %esp,%ebp
  8001e6:	57                   	push   %edi
  8001e7:	56                   	push   %esi
  8001e8:	53                   	push   %ebx
  8001e9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ec:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f1:	b8 06 00 00 00       	mov    $0x6,%eax
  8001f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fc:	89 df                	mov    %ebx,%edi
  8001fe:	89 de                	mov    %ebx,%esi
  800200:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800202:	85 c0                	test   %eax,%eax
  800204:	7e 17                	jle    80021d <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800206:	83 ec 0c             	sub    $0xc,%esp
  800209:	50                   	push   %eax
  80020a:	6a 06                	push   $0x6
  80020c:	68 4a 1e 80 00       	push   $0x801e4a
  800211:	6a 23                	push   $0x23
  800213:	68 67 1e 80 00       	push   $0x801e67
  800218:	e8 ca 0d 00 00       	call   800fe7 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80021d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800220:	5b                   	pop    %ebx
  800221:	5e                   	pop    %esi
  800222:	5f                   	pop    %edi
  800223:	5d                   	pop    %ebp
  800224:	c3                   	ret    

00800225 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800225:	55                   	push   %ebp
  800226:	89 e5                	mov    %esp,%ebp
  800228:	57                   	push   %edi
  800229:	56                   	push   %esi
  80022a:	53                   	push   %ebx
  80022b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80022e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800233:	b8 08 00 00 00       	mov    $0x8,%eax
  800238:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023b:	8b 55 08             	mov    0x8(%ebp),%edx
  80023e:	89 df                	mov    %ebx,%edi
  800240:	89 de                	mov    %ebx,%esi
  800242:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800244:	85 c0                	test   %eax,%eax
  800246:	7e 17                	jle    80025f <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800248:	83 ec 0c             	sub    $0xc,%esp
  80024b:	50                   	push   %eax
  80024c:	6a 08                	push   $0x8
  80024e:	68 4a 1e 80 00       	push   $0x801e4a
  800253:	6a 23                	push   $0x23
  800255:	68 67 1e 80 00       	push   $0x801e67
  80025a:	e8 88 0d 00 00       	call   800fe7 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80025f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800262:	5b                   	pop    %ebx
  800263:	5e                   	pop    %esi
  800264:	5f                   	pop    %edi
  800265:	5d                   	pop    %ebp
  800266:	c3                   	ret    

00800267 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800267:	55                   	push   %ebp
  800268:	89 e5                	mov    %esp,%ebp
  80026a:	57                   	push   %edi
  80026b:	56                   	push   %esi
  80026c:	53                   	push   %ebx
  80026d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800270:	bb 00 00 00 00       	mov    $0x0,%ebx
  800275:	b8 09 00 00 00       	mov    $0x9,%eax
  80027a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80027d:	8b 55 08             	mov    0x8(%ebp),%edx
  800280:	89 df                	mov    %ebx,%edi
  800282:	89 de                	mov    %ebx,%esi
  800284:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800286:	85 c0                	test   %eax,%eax
  800288:	7e 17                	jle    8002a1 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028a:	83 ec 0c             	sub    $0xc,%esp
  80028d:	50                   	push   %eax
  80028e:	6a 09                	push   $0x9
  800290:	68 4a 1e 80 00       	push   $0x801e4a
  800295:	6a 23                	push   $0x23
  800297:	68 67 1e 80 00       	push   $0x801e67
  80029c:	e8 46 0d 00 00       	call   800fe7 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a4:	5b                   	pop    %ebx
  8002a5:	5e                   	pop    %esi
  8002a6:	5f                   	pop    %edi
  8002a7:	5d                   	pop    %ebp
  8002a8:	c3                   	ret    

008002a9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a9:	55                   	push   %ebp
  8002aa:	89 e5                	mov    %esp,%ebp
  8002ac:	57                   	push   %edi
  8002ad:	56                   	push   %esi
  8002ae:	53                   	push   %ebx
  8002af:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c2:	89 df                	mov    %ebx,%edi
  8002c4:	89 de                	mov    %ebx,%esi
  8002c6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002c8:	85 c0                	test   %eax,%eax
  8002ca:	7e 17                	jle    8002e3 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002cc:	83 ec 0c             	sub    $0xc,%esp
  8002cf:	50                   	push   %eax
  8002d0:	6a 0a                	push   $0xa
  8002d2:	68 4a 1e 80 00       	push   $0x801e4a
  8002d7:	6a 23                	push   $0x23
  8002d9:	68 67 1e 80 00       	push   $0x801e67
  8002de:	e8 04 0d 00 00       	call   800fe7 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e6:	5b                   	pop    %ebx
  8002e7:	5e                   	pop    %esi
  8002e8:	5f                   	pop    %edi
  8002e9:	5d                   	pop    %ebp
  8002ea:	c3                   	ret    

008002eb <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002eb:	55                   	push   %ebp
  8002ec:	89 e5                	mov    %esp,%ebp
  8002ee:	57                   	push   %edi
  8002ef:	56                   	push   %esi
  8002f0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f1:	be 00 00 00 00       	mov    $0x0,%esi
  8002f6:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800301:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800304:	8b 7d 14             	mov    0x14(%ebp),%edi
  800307:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800309:	5b                   	pop    %ebx
  80030a:	5e                   	pop    %esi
  80030b:	5f                   	pop    %edi
  80030c:	5d                   	pop    %ebp
  80030d:	c3                   	ret    

0080030e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80030e:	55                   	push   %ebp
  80030f:	89 e5                	mov    %esp,%ebp
  800311:	57                   	push   %edi
  800312:	56                   	push   %esi
  800313:	53                   	push   %ebx
  800314:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800317:	b9 00 00 00 00       	mov    $0x0,%ecx
  80031c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800321:	8b 55 08             	mov    0x8(%ebp),%edx
  800324:	89 cb                	mov    %ecx,%ebx
  800326:	89 cf                	mov    %ecx,%edi
  800328:	89 ce                	mov    %ecx,%esi
  80032a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80032c:	85 c0                	test   %eax,%eax
  80032e:	7e 17                	jle    800347 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800330:	83 ec 0c             	sub    $0xc,%esp
  800333:	50                   	push   %eax
  800334:	6a 0d                	push   $0xd
  800336:	68 4a 1e 80 00       	push   $0x801e4a
  80033b:	6a 23                	push   $0x23
  80033d:	68 67 1e 80 00       	push   $0x801e67
  800342:	e8 a0 0c 00 00       	call   800fe7 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800347:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034a:	5b                   	pop    %ebx
  80034b:	5e                   	pop    %esi
  80034c:	5f                   	pop    %edi
  80034d:	5d                   	pop    %ebp
  80034e:	c3                   	ret    

0080034f <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80034f:	55                   	push   %ebp
  800350:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800352:	8b 45 08             	mov    0x8(%ebp),%eax
  800355:	05 00 00 00 30       	add    $0x30000000,%eax
  80035a:	c1 e8 0c             	shr    $0xc,%eax
}
  80035d:	5d                   	pop    %ebp
  80035e:	c3                   	ret    

0080035f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80035f:	55                   	push   %ebp
  800360:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800362:	8b 45 08             	mov    0x8(%ebp),%eax
  800365:	05 00 00 00 30       	add    $0x30000000,%eax
  80036a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80036f:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800374:	5d                   	pop    %ebp
  800375:	c3                   	ret    

00800376 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800376:	55                   	push   %ebp
  800377:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800379:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  80037e:	a8 01                	test   $0x1,%al
  800380:	74 34                	je     8003b6 <fd_alloc+0x40>
  800382:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800387:	a8 01                	test   $0x1,%al
  800389:	74 32                	je     8003bd <fd_alloc+0x47>
  80038b:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800390:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800392:	89 c2                	mov    %eax,%edx
  800394:	c1 ea 16             	shr    $0x16,%edx
  800397:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80039e:	f6 c2 01             	test   $0x1,%dl
  8003a1:	74 1f                	je     8003c2 <fd_alloc+0x4c>
  8003a3:	89 c2                	mov    %eax,%edx
  8003a5:	c1 ea 0c             	shr    $0xc,%edx
  8003a8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003af:	f6 c2 01             	test   $0x1,%dl
  8003b2:	75 1a                	jne    8003ce <fd_alloc+0x58>
  8003b4:	eb 0c                	jmp    8003c2 <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8003b6:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8003bb:	eb 05                	jmp    8003c2 <fd_alloc+0x4c>
  8003bd:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8003c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c5:	89 08                	mov    %ecx,(%eax)
			return 0;
  8003c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8003cc:	eb 1a                	jmp    8003e8 <fd_alloc+0x72>
  8003ce:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003d3:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003d8:	75 b6                	jne    800390 <fd_alloc+0x1a>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003da:	8b 45 08             	mov    0x8(%ebp),%eax
  8003dd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  8003e3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003e8:	5d                   	pop    %ebp
  8003e9:	c3                   	ret    

008003ea <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003ea:	55                   	push   %ebp
  8003eb:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003ed:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  8003f1:	77 39                	ja     80042c <fd_lookup+0x42>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f6:	c1 e0 0c             	shl    $0xc,%eax
  8003f9:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003fe:	89 c2                	mov    %eax,%edx
  800400:	c1 ea 16             	shr    $0x16,%edx
  800403:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80040a:	f6 c2 01             	test   $0x1,%dl
  80040d:	74 24                	je     800433 <fd_lookup+0x49>
  80040f:	89 c2                	mov    %eax,%edx
  800411:	c1 ea 0c             	shr    $0xc,%edx
  800414:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80041b:	f6 c2 01             	test   $0x1,%dl
  80041e:	74 1a                	je     80043a <fd_lookup+0x50>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800420:	8b 55 0c             	mov    0xc(%ebp),%edx
  800423:	89 02                	mov    %eax,(%edx)
	return 0;
  800425:	b8 00 00 00 00       	mov    $0x0,%eax
  80042a:	eb 13                	jmp    80043f <fd_lookup+0x55>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80042c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800431:	eb 0c                	jmp    80043f <fd_lookup+0x55>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800433:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800438:	eb 05                	jmp    80043f <fd_lookup+0x55>
  80043a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80043f:	5d                   	pop    %ebp
  800440:	c3                   	ret    

00800441 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800441:	55                   	push   %ebp
  800442:	89 e5                	mov    %esp,%ebp
  800444:	53                   	push   %ebx
  800445:	83 ec 04             	sub    $0x4,%esp
  800448:	8b 45 08             	mov    0x8(%ebp),%eax
  80044b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80044e:	3b 05 04 30 80 00    	cmp    0x803004,%eax
  800454:	75 1e                	jne    800474 <dev_lookup+0x33>
  800456:	eb 0e                	jmp    800466 <dev_lookup+0x25>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800458:	b8 20 30 80 00       	mov    $0x803020,%eax
  80045d:	eb 0c                	jmp    80046b <dev_lookup+0x2a>
  80045f:	b8 3c 30 80 00       	mov    $0x80303c,%eax
  800464:	eb 05                	jmp    80046b <dev_lookup+0x2a>
  800466:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  80046b:	89 03                	mov    %eax,(%ebx)
			return 0;
  80046d:	b8 00 00 00 00       	mov    $0x0,%eax
  800472:	eb 36                	jmp    8004aa <dev_lookup+0x69>
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800474:	3b 05 20 30 80 00    	cmp    0x803020,%eax
  80047a:	74 dc                	je     800458 <dev_lookup+0x17>
  80047c:	3b 05 3c 30 80 00    	cmp    0x80303c,%eax
  800482:	74 db                	je     80045f <dev_lookup+0x1e>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800484:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80048a:	8b 52 48             	mov    0x48(%edx),%edx
  80048d:	83 ec 04             	sub    $0x4,%esp
  800490:	50                   	push   %eax
  800491:	52                   	push   %edx
  800492:	68 78 1e 80 00       	push   $0x801e78
  800497:	e8 23 0c 00 00       	call   8010bf <cprintf>
	*dev = 0;
  80049c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8004a2:	83 c4 10             	add    $0x10,%esp
  8004a5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004ad:	c9                   	leave  
  8004ae:	c3                   	ret    

008004af <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004af:	55                   	push   %ebp
  8004b0:	89 e5                	mov    %esp,%ebp
  8004b2:	56                   	push   %esi
  8004b3:	53                   	push   %ebx
  8004b4:	83 ec 10             	sub    $0x10,%esp
  8004b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8004ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004c0:	50                   	push   %eax
  8004c1:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004c7:	c1 e8 0c             	shr    $0xc,%eax
  8004ca:	50                   	push   %eax
  8004cb:	e8 1a ff ff ff       	call   8003ea <fd_lookup>
  8004d0:	83 c4 08             	add    $0x8,%esp
  8004d3:	85 c0                	test   %eax,%eax
  8004d5:	78 05                	js     8004dc <fd_close+0x2d>
	    || fd != fd2)
  8004d7:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004da:	74 06                	je     8004e2 <fd_close+0x33>
		return (must_exist ? r : 0);
  8004dc:	84 db                	test   %bl,%bl
  8004de:	74 47                	je     800527 <fd_close+0x78>
  8004e0:	eb 4a                	jmp    80052c <fd_close+0x7d>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004e2:	83 ec 08             	sub    $0x8,%esp
  8004e5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004e8:	50                   	push   %eax
  8004e9:	ff 36                	pushl  (%esi)
  8004eb:	e8 51 ff ff ff       	call   800441 <dev_lookup>
  8004f0:	89 c3                	mov    %eax,%ebx
  8004f2:	83 c4 10             	add    $0x10,%esp
  8004f5:	85 c0                	test   %eax,%eax
  8004f7:	78 1c                	js     800515 <fd_close+0x66>
		if (dev->dev_close)
  8004f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004fc:	8b 40 10             	mov    0x10(%eax),%eax
  8004ff:	85 c0                	test   %eax,%eax
  800501:	74 0d                	je     800510 <fd_close+0x61>
			r = (*dev->dev_close)(fd);
  800503:	83 ec 0c             	sub    $0xc,%esp
  800506:	56                   	push   %esi
  800507:	ff d0                	call   *%eax
  800509:	89 c3                	mov    %eax,%ebx
  80050b:	83 c4 10             	add    $0x10,%esp
  80050e:	eb 05                	jmp    800515 <fd_close+0x66>
		else
			r = 0;
  800510:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800515:	83 ec 08             	sub    $0x8,%esp
  800518:	56                   	push   %esi
  800519:	6a 00                	push   $0x0
  80051b:	e8 c3 fc ff ff       	call   8001e3 <sys_page_unmap>
	return r;
  800520:	83 c4 10             	add    $0x10,%esp
  800523:	89 d8                	mov    %ebx,%eax
  800525:	eb 05                	jmp    80052c <fd_close+0x7d>
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
  800527:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
	return r;
}
  80052c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80052f:	5b                   	pop    %ebx
  800530:	5e                   	pop    %esi
  800531:	5d                   	pop    %ebp
  800532:	c3                   	ret    

00800533 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800533:	55                   	push   %ebp
  800534:	89 e5                	mov    %esp,%ebp
  800536:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800539:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80053c:	50                   	push   %eax
  80053d:	ff 75 08             	pushl  0x8(%ebp)
  800540:	e8 a5 fe ff ff       	call   8003ea <fd_lookup>
  800545:	83 c4 08             	add    $0x8,%esp
  800548:	85 c0                	test   %eax,%eax
  80054a:	78 10                	js     80055c <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80054c:	83 ec 08             	sub    $0x8,%esp
  80054f:	6a 01                	push   $0x1
  800551:	ff 75 f4             	pushl  -0xc(%ebp)
  800554:	e8 56 ff ff ff       	call   8004af <fd_close>
  800559:	83 c4 10             	add    $0x10,%esp
}
  80055c:	c9                   	leave  
  80055d:	c3                   	ret    

0080055e <close_all>:

void
close_all(void)
{
  80055e:	55                   	push   %ebp
  80055f:	89 e5                	mov    %esp,%ebp
  800561:	53                   	push   %ebx
  800562:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800565:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80056a:	83 ec 0c             	sub    $0xc,%esp
  80056d:	53                   	push   %ebx
  80056e:	e8 c0 ff ff ff       	call   800533 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800573:	43                   	inc    %ebx
  800574:	83 c4 10             	add    $0x10,%esp
  800577:	83 fb 20             	cmp    $0x20,%ebx
  80057a:	75 ee                	jne    80056a <close_all+0xc>
		close(i);
}
  80057c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80057f:	c9                   	leave  
  800580:	c3                   	ret    

00800581 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800581:	55                   	push   %ebp
  800582:	89 e5                	mov    %esp,%ebp
  800584:	57                   	push   %edi
  800585:	56                   	push   %esi
  800586:	53                   	push   %ebx
  800587:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80058a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80058d:	50                   	push   %eax
  80058e:	ff 75 08             	pushl  0x8(%ebp)
  800591:	e8 54 fe ff ff       	call   8003ea <fd_lookup>
  800596:	83 c4 08             	add    $0x8,%esp
  800599:	85 c0                	test   %eax,%eax
  80059b:	0f 88 c2 00 00 00    	js     800663 <dup+0xe2>
		return r;
	close(newfdnum);
  8005a1:	83 ec 0c             	sub    $0xc,%esp
  8005a4:	ff 75 0c             	pushl  0xc(%ebp)
  8005a7:	e8 87 ff ff ff       	call   800533 <close>

	newfd = INDEX2FD(newfdnum);
  8005ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005af:	c1 e3 0c             	shl    $0xc,%ebx
  8005b2:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8005b8:	83 c4 04             	add    $0x4,%esp
  8005bb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005be:	e8 9c fd ff ff       	call   80035f <fd2data>
  8005c3:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  8005c5:	89 1c 24             	mov    %ebx,(%esp)
  8005c8:	e8 92 fd ff ff       	call   80035f <fd2data>
  8005cd:	83 c4 10             	add    $0x10,%esp
  8005d0:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005d2:	89 f0                	mov    %esi,%eax
  8005d4:	c1 e8 16             	shr    $0x16,%eax
  8005d7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005de:	a8 01                	test   $0x1,%al
  8005e0:	74 35                	je     800617 <dup+0x96>
  8005e2:	89 f0                	mov    %esi,%eax
  8005e4:	c1 e8 0c             	shr    $0xc,%eax
  8005e7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005ee:	f6 c2 01             	test   $0x1,%dl
  8005f1:	74 24                	je     800617 <dup+0x96>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005f3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005fa:	83 ec 0c             	sub    $0xc,%esp
  8005fd:	25 07 0e 00 00       	and    $0xe07,%eax
  800602:	50                   	push   %eax
  800603:	57                   	push   %edi
  800604:	6a 00                	push   $0x0
  800606:	56                   	push   %esi
  800607:	6a 00                	push   $0x0
  800609:	e8 93 fb ff ff       	call   8001a1 <sys_page_map>
  80060e:	89 c6                	mov    %eax,%esi
  800610:	83 c4 20             	add    $0x20,%esp
  800613:	85 c0                	test   %eax,%eax
  800615:	78 2c                	js     800643 <dup+0xc2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800617:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80061a:	89 d0                	mov    %edx,%eax
  80061c:	c1 e8 0c             	shr    $0xc,%eax
  80061f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800626:	83 ec 0c             	sub    $0xc,%esp
  800629:	25 07 0e 00 00       	and    $0xe07,%eax
  80062e:	50                   	push   %eax
  80062f:	53                   	push   %ebx
  800630:	6a 00                	push   $0x0
  800632:	52                   	push   %edx
  800633:	6a 00                	push   $0x0
  800635:	e8 67 fb ff ff       	call   8001a1 <sys_page_map>
  80063a:	89 c6                	mov    %eax,%esi
  80063c:	83 c4 20             	add    $0x20,%esp
  80063f:	85 c0                	test   %eax,%eax
  800641:	79 1d                	jns    800660 <dup+0xdf>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800643:	83 ec 08             	sub    $0x8,%esp
  800646:	53                   	push   %ebx
  800647:	6a 00                	push   $0x0
  800649:	e8 95 fb ff ff       	call   8001e3 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80064e:	83 c4 08             	add    $0x8,%esp
  800651:	57                   	push   %edi
  800652:	6a 00                	push   $0x0
  800654:	e8 8a fb ff ff       	call   8001e3 <sys_page_unmap>
	return r;
  800659:	83 c4 10             	add    $0x10,%esp
  80065c:	89 f0                	mov    %esi,%eax
  80065e:	eb 03                	jmp    800663 <dup+0xe2>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  800660:	8b 45 0c             	mov    0xc(%ebp),%eax

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800663:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800666:	5b                   	pop    %ebx
  800667:	5e                   	pop    %esi
  800668:	5f                   	pop    %edi
  800669:	5d                   	pop    %ebp
  80066a:	c3                   	ret    

0080066b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80066b:	55                   	push   %ebp
  80066c:	89 e5                	mov    %esp,%ebp
  80066e:	53                   	push   %ebx
  80066f:	83 ec 14             	sub    $0x14,%esp
  800672:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800675:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800678:	50                   	push   %eax
  800679:	53                   	push   %ebx
  80067a:	e8 6b fd ff ff       	call   8003ea <fd_lookup>
  80067f:	83 c4 08             	add    $0x8,%esp
  800682:	85 c0                	test   %eax,%eax
  800684:	78 67                	js     8006ed <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800686:	83 ec 08             	sub    $0x8,%esp
  800689:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80068c:	50                   	push   %eax
  80068d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800690:	ff 30                	pushl  (%eax)
  800692:	e8 aa fd ff ff       	call   800441 <dev_lookup>
  800697:	83 c4 10             	add    $0x10,%esp
  80069a:	85 c0                	test   %eax,%eax
  80069c:	78 4f                	js     8006ed <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80069e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006a1:	8b 42 08             	mov    0x8(%edx),%eax
  8006a4:	83 e0 03             	and    $0x3,%eax
  8006a7:	83 f8 01             	cmp    $0x1,%eax
  8006aa:	75 21                	jne    8006cd <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006ac:	a1 04 40 80 00       	mov    0x804004,%eax
  8006b1:	8b 40 48             	mov    0x48(%eax),%eax
  8006b4:	83 ec 04             	sub    $0x4,%esp
  8006b7:	53                   	push   %ebx
  8006b8:	50                   	push   %eax
  8006b9:	68 b9 1e 80 00       	push   $0x801eb9
  8006be:	e8 fc 09 00 00       	call   8010bf <cprintf>
		return -E_INVAL;
  8006c3:	83 c4 10             	add    $0x10,%esp
  8006c6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006cb:	eb 20                	jmp    8006ed <read+0x82>
	}
	if (!dev->dev_read)
  8006cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006d0:	8b 40 08             	mov    0x8(%eax),%eax
  8006d3:	85 c0                	test   %eax,%eax
  8006d5:	74 11                	je     8006e8 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006d7:	83 ec 04             	sub    $0x4,%esp
  8006da:	ff 75 10             	pushl  0x10(%ebp)
  8006dd:	ff 75 0c             	pushl  0xc(%ebp)
  8006e0:	52                   	push   %edx
  8006e1:	ff d0                	call   *%eax
  8006e3:	83 c4 10             	add    $0x10,%esp
  8006e6:	eb 05                	jmp    8006ed <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006e8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8006ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006f0:	c9                   	leave  
  8006f1:	c3                   	ret    

008006f2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006f2:	55                   	push   %ebp
  8006f3:	89 e5                	mov    %esp,%ebp
  8006f5:	57                   	push   %edi
  8006f6:	56                   	push   %esi
  8006f7:	53                   	push   %ebx
  8006f8:	83 ec 0c             	sub    $0xc,%esp
  8006fb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006fe:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800701:	85 f6                	test   %esi,%esi
  800703:	74 31                	je     800736 <readn+0x44>
  800705:	b8 00 00 00 00       	mov    $0x0,%eax
  80070a:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  80070f:	83 ec 04             	sub    $0x4,%esp
  800712:	89 f2                	mov    %esi,%edx
  800714:	29 c2                	sub    %eax,%edx
  800716:	52                   	push   %edx
  800717:	03 45 0c             	add    0xc(%ebp),%eax
  80071a:	50                   	push   %eax
  80071b:	57                   	push   %edi
  80071c:	e8 4a ff ff ff       	call   80066b <read>
		if (m < 0)
  800721:	83 c4 10             	add    $0x10,%esp
  800724:	85 c0                	test   %eax,%eax
  800726:	78 17                	js     80073f <readn+0x4d>
			return m;
		if (m == 0)
  800728:	85 c0                	test   %eax,%eax
  80072a:	74 11                	je     80073d <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80072c:	01 c3                	add    %eax,%ebx
  80072e:	89 d8                	mov    %ebx,%eax
  800730:	39 f3                	cmp    %esi,%ebx
  800732:	72 db                	jb     80070f <readn+0x1d>
  800734:	eb 09                	jmp    80073f <readn+0x4d>
  800736:	b8 00 00 00 00       	mov    $0x0,%eax
  80073b:	eb 02                	jmp    80073f <readn+0x4d>
  80073d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80073f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800742:	5b                   	pop    %ebx
  800743:	5e                   	pop    %esi
  800744:	5f                   	pop    %edi
  800745:	5d                   	pop    %ebp
  800746:	c3                   	ret    

00800747 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800747:	55                   	push   %ebp
  800748:	89 e5                	mov    %esp,%ebp
  80074a:	53                   	push   %ebx
  80074b:	83 ec 14             	sub    $0x14,%esp
  80074e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800751:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800754:	50                   	push   %eax
  800755:	53                   	push   %ebx
  800756:	e8 8f fc ff ff       	call   8003ea <fd_lookup>
  80075b:	83 c4 08             	add    $0x8,%esp
  80075e:	85 c0                	test   %eax,%eax
  800760:	78 62                	js     8007c4 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800762:	83 ec 08             	sub    $0x8,%esp
  800765:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800768:	50                   	push   %eax
  800769:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80076c:	ff 30                	pushl  (%eax)
  80076e:	e8 ce fc ff ff       	call   800441 <dev_lookup>
  800773:	83 c4 10             	add    $0x10,%esp
  800776:	85 c0                	test   %eax,%eax
  800778:	78 4a                	js     8007c4 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80077a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80077d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800781:	75 21                	jne    8007a4 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800783:	a1 04 40 80 00       	mov    0x804004,%eax
  800788:	8b 40 48             	mov    0x48(%eax),%eax
  80078b:	83 ec 04             	sub    $0x4,%esp
  80078e:	53                   	push   %ebx
  80078f:	50                   	push   %eax
  800790:	68 d5 1e 80 00       	push   $0x801ed5
  800795:	e8 25 09 00 00       	call   8010bf <cprintf>
		return -E_INVAL;
  80079a:	83 c4 10             	add    $0x10,%esp
  80079d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007a2:	eb 20                	jmp    8007c4 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007a4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007a7:	8b 52 0c             	mov    0xc(%edx),%edx
  8007aa:	85 d2                	test   %edx,%edx
  8007ac:	74 11                	je     8007bf <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007ae:	83 ec 04             	sub    $0x4,%esp
  8007b1:	ff 75 10             	pushl  0x10(%ebp)
  8007b4:	ff 75 0c             	pushl  0xc(%ebp)
  8007b7:	50                   	push   %eax
  8007b8:	ff d2                	call   *%edx
  8007ba:	83 c4 10             	add    $0x10,%esp
  8007bd:	eb 05                	jmp    8007c4 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007bf:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8007c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007c7:	c9                   	leave  
  8007c8:	c3                   	ret    

008007c9 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007c9:	55                   	push   %ebp
  8007ca:	89 e5                	mov    %esp,%ebp
  8007cc:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007cf:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007d2:	50                   	push   %eax
  8007d3:	ff 75 08             	pushl  0x8(%ebp)
  8007d6:	e8 0f fc ff ff       	call   8003ea <fd_lookup>
  8007db:	83 c4 08             	add    $0x8,%esp
  8007de:	85 c0                	test   %eax,%eax
  8007e0:	78 0e                	js     8007f0 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007e5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007e8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007eb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007f0:	c9                   	leave  
  8007f1:	c3                   	ret    

008007f2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007f2:	55                   	push   %ebp
  8007f3:	89 e5                	mov    %esp,%ebp
  8007f5:	53                   	push   %ebx
  8007f6:	83 ec 14             	sub    $0x14,%esp
  8007f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007fc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007ff:	50                   	push   %eax
  800800:	53                   	push   %ebx
  800801:	e8 e4 fb ff ff       	call   8003ea <fd_lookup>
  800806:	83 c4 08             	add    $0x8,%esp
  800809:	85 c0                	test   %eax,%eax
  80080b:	78 5f                	js     80086c <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80080d:	83 ec 08             	sub    $0x8,%esp
  800810:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800813:	50                   	push   %eax
  800814:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800817:	ff 30                	pushl  (%eax)
  800819:	e8 23 fc ff ff       	call   800441 <dev_lookup>
  80081e:	83 c4 10             	add    $0x10,%esp
  800821:	85 c0                	test   %eax,%eax
  800823:	78 47                	js     80086c <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800825:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800828:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80082c:	75 21                	jne    80084f <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80082e:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800833:	8b 40 48             	mov    0x48(%eax),%eax
  800836:	83 ec 04             	sub    $0x4,%esp
  800839:	53                   	push   %ebx
  80083a:	50                   	push   %eax
  80083b:	68 98 1e 80 00       	push   $0x801e98
  800840:	e8 7a 08 00 00       	call   8010bf <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800845:	83 c4 10             	add    $0x10,%esp
  800848:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80084d:	eb 1d                	jmp    80086c <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  80084f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800852:	8b 52 18             	mov    0x18(%edx),%edx
  800855:	85 d2                	test   %edx,%edx
  800857:	74 0e                	je     800867 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800859:	83 ec 08             	sub    $0x8,%esp
  80085c:	ff 75 0c             	pushl  0xc(%ebp)
  80085f:	50                   	push   %eax
  800860:	ff d2                	call   *%edx
  800862:	83 c4 10             	add    $0x10,%esp
  800865:	eb 05                	jmp    80086c <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800867:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80086c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80086f:	c9                   	leave  
  800870:	c3                   	ret    

00800871 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800871:	55                   	push   %ebp
  800872:	89 e5                	mov    %esp,%ebp
  800874:	53                   	push   %ebx
  800875:	83 ec 14             	sub    $0x14,%esp
  800878:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80087b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80087e:	50                   	push   %eax
  80087f:	ff 75 08             	pushl  0x8(%ebp)
  800882:	e8 63 fb ff ff       	call   8003ea <fd_lookup>
  800887:	83 c4 08             	add    $0x8,%esp
  80088a:	85 c0                	test   %eax,%eax
  80088c:	78 52                	js     8008e0 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80088e:	83 ec 08             	sub    $0x8,%esp
  800891:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800894:	50                   	push   %eax
  800895:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800898:	ff 30                	pushl  (%eax)
  80089a:	e8 a2 fb ff ff       	call   800441 <dev_lookup>
  80089f:	83 c4 10             	add    $0x10,%esp
  8008a2:	85 c0                	test   %eax,%eax
  8008a4:	78 3a                	js     8008e0 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  8008a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008a9:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008ad:	74 2c                	je     8008db <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008af:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008b2:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008b9:	00 00 00 
	stat->st_isdir = 0;
  8008bc:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008c3:	00 00 00 
	stat->st_dev = dev;
  8008c6:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008cc:	83 ec 08             	sub    $0x8,%esp
  8008cf:	53                   	push   %ebx
  8008d0:	ff 75 f0             	pushl  -0x10(%ebp)
  8008d3:	ff 50 14             	call   *0x14(%eax)
  8008d6:	83 c4 10             	add    $0x10,%esp
  8008d9:	eb 05                	jmp    8008e0 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008db:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008e3:	c9                   	leave  
  8008e4:	c3                   	ret    

008008e5 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008e5:	55                   	push   %ebp
  8008e6:	89 e5                	mov    %esp,%ebp
  8008e8:	56                   	push   %esi
  8008e9:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008ea:	83 ec 08             	sub    $0x8,%esp
  8008ed:	6a 00                	push   $0x0
  8008ef:	ff 75 08             	pushl  0x8(%ebp)
  8008f2:	e8 75 01 00 00       	call   800a6c <open>
  8008f7:	89 c3                	mov    %eax,%ebx
  8008f9:	83 c4 10             	add    $0x10,%esp
  8008fc:	85 c0                	test   %eax,%eax
  8008fe:	78 1d                	js     80091d <stat+0x38>
		return fd;
	r = fstat(fd, stat);
  800900:	83 ec 08             	sub    $0x8,%esp
  800903:	ff 75 0c             	pushl  0xc(%ebp)
  800906:	50                   	push   %eax
  800907:	e8 65 ff ff ff       	call   800871 <fstat>
  80090c:	89 c6                	mov    %eax,%esi
	close(fd);
  80090e:	89 1c 24             	mov    %ebx,(%esp)
  800911:	e8 1d fc ff ff       	call   800533 <close>
	return r;
  800916:	83 c4 10             	add    $0x10,%esp
  800919:	89 f0                	mov    %esi,%eax
  80091b:	eb 00                	jmp    80091d <stat+0x38>
}
  80091d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800920:	5b                   	pop    %ebx
  800921:	5e                   	pop    %esi
  800922:	5d                   	pop    %ebp
  800923:	c3                   	ret    

00800924 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800924:	55                   	push   %ebp
  800925:	89 e5                	mov    %esp,%ebp
  800927:	56                   	push   %esi
  800928:	53                   	push   %ebx
  800929:	89 c6                	mov    %eax,%esi
  80092b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80092d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800934:	75 12                	jne    800948 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800936:	83 ec 0c             	sub    $0xc,%esp
  800939:	6a 01                	push   $0x1
  80093b:	e8 ec 11 00 00       	call   801b2c <ipc_find_env>
  800940:	a3 00 40 80 00       	mov    %eax,0x804000
  800945:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800948:	6a 07                	push   $0x7
  80094a:	68 00 50 80 00       	push   $0x805000
  80094f:	56                   	push   %esi
  800950:	ff 35 00 40 80 00    	pushl  0x804000
  800956:	e8 72 11 00 00       	call   801acd <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80095b:	83 c4 0c             	add    $0xc,%esp
  80095e:	6a 00                	push   $0x0
  800960:	53                   	push   %ebx
  800961:	6a 00                	push   $0x0
  800963:	e8 f0 10 00 00       	call   801a58 <ipc_recv>
}
  800968:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80096b:	5b                   	pop    %ebx
  80096c:	5e                   	pop    %esi
  80096d:	5d                   	pop    %ebp
  80096e:	c3                   	ret    

0080096f <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80096f:	55                   	push   %ebp
  800970:	89 e5                	mov    %esp,%ebp
  800972:	53                   	push   %ebx
  800973:	83 ec 04             	sub    $0x4,%esp
  800976:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800979:	8b 45 08             	mov    0x8(%ebp),%eax
  80097c:	8b 40 0c             	mov    0xc(%eax),%eax
  80097f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800984:	ba 00 00 00 00       	mov    $0x0,%edx
  800989:	b8 05 00 00 00       	mov    $0x5,%eax
  80098e:	e8 91 ff ff ff       	call   800924 <fsipc>
  800993:	85 c0                	test   %eax,%eax
  800995:	78 2c                	js     8009c3 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800997:	83 ec 08             	sub    $0x8,%esp
  80099a:	68 00 50 80 00       	push   $0x805000
  80099f:	53                   	push   %ebx
  8009a0:	e8 ff 0c 00 00       	call   8016a4 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009a5:	a1 80 50 80 00       	mov    0x805080,%eax
  8009aa:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009b0:	a1 84 50 80 00       	mov    0x805084,%eax
  8009b5:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009bb:	83 c4 10             	add    $0x10,%esp
  8009be:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009c6:	c9                   	leave  
  8009c7:	c3                   	ret    

008009c8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009c8:	55                   	push   %ebp
  8009c9:	89 e5                	mov    %esp,%ebp
  8009cb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d1:	8b 40 0c             	mov    0xc(%eax),%eax
  8009d4:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8009de:	b8 06 00 00 00       	mov    $0x6,%eax
  8009e3:	e8 3c ff ff ff       	call   800924 <fsipc>
}
  8009e8:	c9                   	leave  
  8009e9:	c3                   	ret    

008009ea <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8009ea:	55                   	push   %ebp
  8009eb:	89 e5                	mov    %esp,%ebp
  8009ed:	56                   	push   %esi
  8009ee:	53                   	push   %ebx
  8009ef:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8009f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f5:	8b 40 0c             	mov    0xc(%eax),%eax
  8009f8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8009fd:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a03:	ba 00 00 00 00       	mov    $0x0,%edx
  800a08:	b8 03 00 00 00       	mov    $0x3,%eax
  800a0d:	e8 12 ff ff ff       	call   800924 <fsipc>
  800a12:	89 c3                	mov    %eax,%ebx
  800a14:	85 c0                	test   %eax,%eax
  800a16:	78 4b                	js     800a63 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a18:	39 c6                	cmp    %eax,%esi
  800a1a:	73 16                	jae    800a32 <devfile_read+0x48>
  800a1c:	68 f2 1e 80 00       	push   $0x801ef2
  800a21:	68 f9 1e 80 00       	push   $0x801ef9
  800a26:	6a 7a                	push   $0x7a
  800a28:	68 0e 1f 80 00       	push   $0x801f0e
  800a2d:	e8 b5 05 00 00       	call   800fe7 <_panic>
	assert(r <= PGSIZE);
  800a32:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a37:	7e 16                	jle    800a4f <devfile_read+0x65>
  800a39:	68 19 1f 80 00       	push   $0x801f19
  800a3e:	68 f9 1e 80 00       	push   $0x801ef9
  800a43:	6a 7b                	push   $0x7b
  800a45:	68 0e 1f 80 00       	push   $0x801f0e
  800a4a:	e8 98 05 00 00       	call   800fe7 <_panic>
	memmove(buf, &fsipcbuf, r);
  800a4f:	83 ec 04             	sub    $0x4,%esp
  800a52:	50                   	push   %eax
  800a53:	68 00 50 80 00       	push   $0x805000
  800a58:	ff 75 0c             	pushl  0xc(%ebp)
  800a5b:	e8 11 0e 00 00       	call   801871 <memmove>
	return r;
  800a60:	83 c4 10             	add    $0x10,%esp
}
  800a63:	89 d8                	mov    %ebx,%eax
  800a65:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a68:	5b                   	pop    %ebx
  800a69:	5e                   	pop    %esi
  800a6a:	5d                   	pop    %ebp
  800a6b:	c3                   	ret    

00800a6c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800a6c:	55                   	push   %ebp
  800a6d:	89 e5                	mov    %esp,%ebp
  800a6f:	53                   	push   %ebx
  800a70:	83 ec 20             	sub    $0x20,%esp
  800a73:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800a76:	53                   	push   %ebx
  800a77:	e8 d1 0b 00 00       	call   80164d <strlen>
  800a7c:	83 c4 10             	add    $0x10,%esp
  800a7f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800a84:	7f 63                	jg     800ae9 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800a86:	83 ec 0c             	sub    $0xc,%esp
  800a89:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a8c:	50                   	push   %eax
  800a8d:	e8 e4 f8 ff ff       	call   800376 <fd_alloc>
  800a92:	83 c4 10             	add    $0x10,%esp
  800a95:	85 c0                	test   %eax,%eax
  800a97:	78 55                	js     800aee <open+0x82>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800a99:	83 ec 08             	sub    $0x8,%esp
  800a9c:	53                   	push   %ebx
  800a9d:	68 00 50 80 00       	push   $0x805000
  800aa2:	e8 fd 0b 00 00       	call   8016a4 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800aa7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aaa:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800aaf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ab2:	b8 01 00 00 00       	mov    $0x1,%eax
  800ab7:	e8 68 fe ff ff       	call   800924 <fsipc>
  800abc:	89 c3                	mov    %eax,%ebx
  800abe:	83 c4 10             	add    $0x10,%esp
  800ac1:	85 c0                	test   %eax,%eax
  800ac3:	79 14                	jns    800ad9 <open+0x6d>
		fd_close(fd, 0);
  800ac5:	83 ec 08             	sub    $0x8,%esp
  800ac8:	6a 00                	push   $0x0
  800aca:	ff 75 f4             	pushl  -0xc(%ebp)
  800acd:	e8 dd f9 ff ff       	call   8004af <fd_close>
		return r;
  800ad2:	83 c4 10             	add    $0x10,%esp
  800ad5:	89 d8                	mov    %ebx,%eax
  800ad7:	eb 15                	jmp    800aee <open+0x82>
	}

	return fd2num(fd);
  800ad9:	83 ec 0c             	sub    $0xc,%esp
  800adc:	ff 75 f4             	pushl  -0xc(%ebp)
  800adf:	e8 6b f8 ff ff       	call   80034f <fd2num>
  800ae4:	83 c4 10             	add    $0x10,%esp
  800ae7:	eb 05                	jmp    800aee <open+0x82>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800ae9:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800aee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800af1:	c9                   	leave  
  800af2:	c3                   	ret    

00800af3 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800af3:	55                   	push   %ebp
  800af4:	89 e5                	mov    %esp,%ebp
  800af6:	56                   	push   %esi
  800af7:	53                   	push   %ebx
  800af8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800afb:	83 ec 0c             	sub    $0xc,%esp
  800afe:	ff 75 08             	pushl  0x8(%ebp)
  800b01:	e8 59 f8 ff ff       	call   80035f <fd2data>
  800b06:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b08:	83 c4 08             	add    $0x8,%esp
  800b0b:	68 25 1f 80 00       	push   $0x801f25
  800b10:	53                   	push   %ebx
  800b11:	e8 8e 0b 00 00       	call   8016a4 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b16:	8b 46 04             	mov    0x4(%esi),%eax
  800b19:	2b 06                	sub    (%esi),%eax
  800b1b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b21:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b28:	00 00 00 
	stat->st_dev = &devpipe;
  800b2b:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800b32:	30 80 00 
	return 0;
}
  800b35:	b8 00 00 00 00       	mov    $0x0,%eax
  800b3a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b3d:	5b                   	pop    %ebx
  800b3e:	5e                   	pop    %esi
  800b3f:	5d                   	pop    %ebp
  800b40:	c3                   	ret    

00800b41 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b41:	55                   	push   %ebp
  800b42:	89 e5                	mov    %esp,%ebp
  800b44:	53                   	push   %ebx
  800b45:	83 ec 0c             	sub    $0xc,%esp
  800b48:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800b4b:	53                   	push   %ebx
  800b4c:	6a 00                	push   $0x0
  800b4e:	e8 90 f6 ff ff       	call   8001e3 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800b53:	89 1c 24             	mov    %ebx,(%esp)
  800b56:	e8 04 f8 ff ff       	call   80035f <fd2data>
  800b5b:	83 c4 08             	add    $0x8,%esp
  800b5e:	50                   	push   %eax
  800b5f:	6a 00                	push   $0x0
  800b61:	e8 7d f6 ff ff       	call   8001e3 <sys_page_unmap>
}
  800b66:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b69:	c9                   	leave  
  800b6a:	c3                   	ret    

00800b6b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800b6b:	55                   	push   %ebp
  800b6c:	89 e5                	mov    %esp,%ebp
  800b6e:	57                   	push   %edi
  800b6f:	56                   	push   %esi
  800b70:	53                   	push   %ebx
  800b71:	83 ec 1c             	sub    $0x1c,%esp
  800b74:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b77:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800b79:	a1 04 40 80 00       	mov    0x804004,%eax
  800b7e:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800b81:	83 ec 0c             	sub    $0xc,%esp
  800b84:	ff 75 e0             	pushl  -0x20(%ebp)
  800b87:	e8 fb 0f 00 00       	call   801b87 <pageref>
  800b8c:	89 c3                	mov    %eax,%ebx
  800b8e:	89 3c 24             	mov    %edi,(%esp)
  800b91:	e8 f1 0f 00 00       	call   801b87 <pageref>
  800b96:	83 c4 10             	add    $0x10,%esp
  800b99:	39 c3                	cmp    %eax,%ebx
  800b9b:	0f 94 c1             	sete   %cl
  800b9e:	0f b6 c9             	movzbl %cl,%ecx
  800ba1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800ba4:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800baa:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800bad:	39 ce                	cmp    %ecx,%esi
  800baf:	74 1b                	je     800bcc <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800bb1:	39 c3                	cmp    %eax,%ebx
  800bb3:	75 c4                	jne    800b79 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800bb5:	8b 42 58             	mov    0x58(%edx),%eax
  800bb8:	ff 75 e4             	pushl  -0x1c(%ebp)
  800bbb:	50                   	push   %eax
  800bbc:	56                   	push   %esi
  800bbd:	68 2c 1f 80 00       	push   $0x801f2c
  800bc2:	e8 f8 04 00 00       	call   8010bf <cprintf>
  800bc7:	83 c4 10             	add    $0x10,%esp
  800bca:	eb ad                	jmp    800b79 <_pipeisclosed+0xe>
	}
}
  800bcc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800bcf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd2:	5b                   	pop    %ebx
  800bd3:	5e                   	pop    %esi
  800bd4:	5f                   	pop    %edi
  800bd5:	5d                   	pop    %ebp
  800bd6:	c3                   	ret    

00800bd7 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800bd7:	55                   	push   %ebp
  800bd8:	89 e5                	mov    %esp,%ebp
  800bda:	57                   	push   %edi
  800bdb:	56                   	push   %esi
  800bdc:	53                   	push   %ebx
  800bdd:	83 ec 18             	sub    $0x18,%esp
  800be0:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800be3:	56                   	push   %esi
  800be4:	e8 76 f7 ff ff       	call   80035f <fd2data>
  800be9:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800beb:	83 c4 10             	add    $0x10,%esp
  800bee:	bf 00 00 00 00       	mov    $0x0,%edi
  800bf3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800bf7:	75 42                	jne    800c3b <devpipe_write+0x64>
  800bf9:	eb 4e                	jmp    800c49 <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800bfb:	89 da                	mov    %ebx,%edx
  800bfd:	89 f0                	mov    %esi,%eax
  800bff:	e8 67 ff ff ff       	call   800b6b <_pipeisclosed>
  800c04:	85 c0                	test   %eax,%eax
  800c06:	75 46                	jne    800c4e <devpipe_write+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c08:	e8 32 f5 ff ff       	call   80013f <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c0d:	8b 53 04             	mov    0x4(%ebx),%edx
  800c10:	8b 03                	mov    (%ebx),%eax
  800c12:	83 c0 20             	add    $0x20,%eax
  800c15:	39 c2                	cmp    %eax,%edx
  800c17:	73 e2                	jae    800bfb <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c19:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c1c:	8a 0c 38             	mov    (%eax,%edi,1),%cl
  800c1f:	89 d0                	mov    %edx,%eax
  800c21:	25 1f 00 00 80       	and    $0x8000001f,%eax
  800c26:	79 05                	jns    800c2d <devpipe_write+0x56>
  800c28:	48                   	dec    %eax
  800c29:	83 c8 e0             	or     $0xffffffe0,%eax
  800c2c:	40                   	inc    %eax
  800c2d:	88 4c 03 08          	mov    %cl,0x8(%ebx,%eax,1)
		p->p_wpos++;
  800c31:	42                   	inc    %edx
  800c32:	89 53 04             	mov    %edx,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c35:	47                   	inc    %edi
  800c36:	39 7d 10             	cmp    %edi,0x10(%ebp)
  800c39:	74 0e                	je     800c49 <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c3b:	8b 53 04             	mov    0x4(%ebx),%edx
  800c3e:	8b 03                	mov    (%ebx),%eax
  800c40:	83 c0 20             	add    $0x20,%eax
  800c43:	39 c2                	cmp    %eax,%edx
  800c45:	73 b4                	jae    800bfb <devpipe_write+0x24>
  800c47:	eb d0                	jmp    800c19 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800c49:	8b 45 10             	mov    0x10(%ebp),%eax
  800c4c:	eb 05                	jmp    800c53 <devpipe_write+0x7c>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800c4e:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800c53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c56:	5b                   	pop    %ebx
  800c57:	5e                   	pop    %esi
  800c58:	5f                   	pop    %edi
  800c59:	5d                   	pop    %ebp
  800c5a:	c3                   	ret    

00800c5b <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800c5b:	55                   	push   %ebp
  800c5c:	89 e5                	mov    %esp,%ebp
  800c5e:	57                   	push   %edi
  800c5f:	56                   	push   %esi
  800c60:	53                   	push   %ebx
  800c61:	83 ec 18             	sub    $0x18,%esp
  800c64:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800c67:	57                   	push   %edi
  800c68:	e8 f2 f6 ff ff       	call   80035f <fd2data>
  800c6d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c6f:	83 c4 10             	add    $0x10,%esp
  800c72:	be 00 00 00 00       	mov    $0x0,%esi
  800c77:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c7b:	75 3d                	jne    800cba <devpipe_read+0x5f>
  800c7d:	eb 48                	jmp    800cc7 <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  800c7f:	89 f0                	mov    %esi,%eax
  800c81:	eb 4e                	jmp    800cd1 <devpipe_read+0x76>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800c83:	89 da                	mov    %ebx,%edx
  800c85:	89 f8                	mov    %edi,%eax
  800c87:	e8 df fe ff ff       	call   800b6b <_pipeisclosed>
  800c8c:	85 c0                	test   %eax,%eax
  800c8e:	75 3c                	jne    800ccc <devpipe_read+0x71>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800c90:	e8 aa f4 ff ff       	call   80013f <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800c95:	8b 03                	mov    (%ebx),%eax
  800c97:	3b 43 04             	cmp    0x4(%ebx),%eax
  800c9a:	74 e7                	je     800c83 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800c9c:	25 1f 00 00 80       	and    $0x8000001f,%eax
  800ca1:	79 05                	jns    800ca8 <devpipe_read+0x4d>
  800ca3:	48                   	dec    %eax
  800ca4:	83 c8 e0             	or     $0xffffffe0,%eax
  800ca7:	40                   	inc    %eax
  800ca8:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  800cac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800caf:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800cb2:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cb4:	46                   	inc    %esi
  800cb5:	39 75 10             	cmp    %esi,0x10(%ebp)
  800cb8:	74 0d                	je     800cc7 <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
  800cba:	8b 03                	mov    (%ebx),%eax
  800cbc:	3b 43 04             	cmp    0x4(%ebx),%eax
  800cbf:	75 db                	jne    800c9c <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800cc1:	85 f6                	test   %esi,%esi
  800cc3:	75 ba                	jne    800c7f <devpipe_read+0x24>
  800cc5:	eb bc                	jmp    800c83 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800cc7:	8b 45 10             	mov    0x10(%ebp),%eax
  800cca:	eb 05                	jmp    800cd1 <devpipe_read+0x76>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800ccc:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800cd1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd4:	5b                   	pop    %ebx
  800cd5:	5e                   	pop    %esi
  800cd6:	5f                   	pop    %edi
  800cd7:	5d                   	pop    %ebp
  800cd8:	c3                   	ret    

00800cd9 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800cd9:	55                   	push   %ebp
  800cda:	89 e5                	mov    %esp,%ebp
  800cdc:	56                   	push   %esi
  800cdd:	53                   	push   %ebx
  800cde:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800ce1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ce4:	50                   	push   %eax
  800ce5:	e8 8c f6 ff ff       	call   800376 <fd_alloc>
  800cea:	83 c4 10             	add    $0x10,%esp
  800ced:	85 c0                	test   %eax,%eax
  800cef:	0f 88 2a 01 00 00    	js     800e1f <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800cf5:	83 ec 04             	sub    $0x4,%esp
  800cf8:	68 07 04 00 00       	push   $0x407
  800cfd:	ff 75 f4             	pushl  -0xc(%ebp)
  800d00:	6a 00                	push   $0x0
  800d02:	e8 57 f4 ff ff       	call   80015e <sys_page_alloc>
  800d07:	83 c4 10             	add    $0x10,%esp
  800d0a:	85 c0                	test   %eax,%eax
  800d0c:	0f 88 0d 01 00 00    	js     800e1f <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d12:	83 ec 0c             	sub    $0xc,%esp
  800d15:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d18:	50                   	push   %eax
  800d19:	e8 58 f6 ff ff       	call   800376 <fd_alloc>
  800d1e:	89 c3                	mov    %eax,%ebx
  800d20:	83 c4 10             	add    $0x10,%esp
  800d23:	85 c0                	test   %eax,%eax
  800d25:	0f 88 e2 00 00 00    	js     800e0d <pipe+0x134>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d2b:	83 ec 04             	sub    $0x4,%esp
  800d2e:	68 07 04 00 00       	push   $0x407
  800d33:	ff 75 f0             	pushl  -0x10(%ebp)
  800d36:	6a 00                	push   $0x0
  800d38:	e8 21 f4 ff ff       	call   80015e <sys_page_alloc>
  800d3d:	89 c3                	mov    %eax,%ebx
  800d3f:	83 c4 10             	add    $0x10,%esp
  800d42:	85 c0                	test   %eax,%eax
  800d44:	0f 88 c3 00 00 00    	js     800e0d <pipe+0x134>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800d4a:	83 ec 0c             	sub    $0xc,%esp
  800d4d:	ff 75 f4             	pushl  -0xc(%ebp)
  800d50:	e8 0a f6 ff ff       	call   80035f <fd2data>
  800d55:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d57:	83 c4 0c             	add    $0xc,%esp
  800d5a:	68 07 04 00 00       	push   $0x407
  800d5f:	50                   	push   %eax
  800d60:	6a 00                	push   $0x0
  800d62:	e8 f7 f3 ff ff       	call   80015e <sys_page_alloc>
  800d67:	89 c3                	mov    %eax,%ebx
  800d69:	83 c4 10             	add    $0x10,%esp
  800d6c:	85 c0                	test   %eax,%eax
  800d6e:	0f 88 89 00 00 00    	js     800dfd <pipe+0x124>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d74:	83 ec 0c             	sub    $0xc,%esp
  800d77:	ff 75 f0             	pushl  -0x10(%ebp)
  800d7a:	e8 e0 f5 ff ff       	call   80035f <fd2data>
  800d7f:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800d86:	50                   	push   %eax
  800d87:	6a 00                	push   $0x0
  800d89:	56                   	push   %esi
  800d8a:	6a 00                	push   $0x0
  800d8c:	e8 10 f4 ff ff       	call   8001a1 <sys_page_map>
  800d91:	89 c3                	mov    %eax,%ebx
  800d93:	83 c4 20             	add    $0x20,%esp
  800d96:	85 c0                	test   %eax,%eax
  800d98:	78 55                	js     800def <pipe+0x116>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800d9a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800da0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800da3:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800da5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800da8:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800daf:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800db5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800db8:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800dba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dbd:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800dc4:	83 ec 0c             	sub    $0xc,%esp
  800dc7:	ff 75 f4             	pushl  -0xc(%ebp)
  800dca:	e8 80 f5 ff ff       	call   80034f <fd2num>
  800dcf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dd2:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800dd4:	83 c4 04             	add    $0x4,%esp
  800dd7:	ff 75 f0             	pushl  -0x10(%ebp)
  800dda:	e8 70 f5 ff ff       	call   80034f <fd2num>
  800ddf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800de2:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800de5:	83 c4 10             	add    $0x10,%esp
  800de8:	b8 00 00 00 00       	mov    $0x0,%eax
  800ded:	eb 30                	jmp    800e1f <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  800def:	83 ec 08             	sub    $0x8,%esp
  800df2:	56                   	push   %esi
  800df3:	6a 00                	push   $0x0
  800df5:	e8 e9 f3 ff ff       	call   8001e3 <sys_page_unmap>
  800dfa:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800dfd:	83 ec 08             	sub    $0x8,%esp
  800e00:	ff 75 f0             	pushl  -0x10(%ebp)
  800e03:	6a 00                	push   $0x0
  800e05:	e8 d9 f3 ff ff       	call   8001e3 <sys_page_unmap>
  800e0a:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e0d:	83 ec 08             	sub    $0x8,%esp
  800e10:	ff 75 f4             	pushl  -0xc(%ebp)
  800e13:	6a 00                	push   $0x0
  800e15:	e8 c9 f3 ff ff       	call   8001e3 <sys_page_unmap>
  800e1a:	83 c4 10             	add    $0x10,%esp
  800e1d:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  800e1f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e22:	5b                   	pop    %ebx
  800e23:	5e                   	pop    %esi
  800e24:	5d                   	pop    %ebp
  800e25:	c3                   	ret    

00800e26 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e26:	55                   	push   %ebp
  800e27:	89 e5                	mov    %esp,%ebp
  800e29:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e2c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e2f:	50                   	push   %eax
  800e30:	ff 75 08             	pushl  0x8(%ebp)
  800e33:	e8 b2 f5 ff ff       	call   8003ea <fd_lookup>
  800e38:	83 c4 10             	add    $0x10,%esp
  800e3b:	85 c0                	test   %eax,%eax
  800e3d:	78 18                	js     800e57 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800e3f:	83 ec 0c             	sub    $0xc,%esp
  800e42:	ff 75 f4             	pushl  -0xc(%ebp)
  800e45:	e8 15 f5 ff ff       	call   80035f <fd2data>
	return _pipeisclosed(fd, p);
  800e4a:	89 c2                	mov    %eax,%edx
  800e4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e4f:	e8 17 fd ff ff       	call   800b6b <_pipeisclosed>
  800e54:	83 c4 10             	add    $0x10,%esp
}
  800e57:	c9                   	leave  
  800e58:	c3                   	ret    

00800e59 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800e59:	55                   	push   %ebp
  800e5a:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800e5c:	b8 00 00 00 00       	mov    $0x0,%eax
  800e61:	5d                   	pop    %ebp
  800e62:	c3                   	ret    

00800e63 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800e63:	55                   	push   %ebp
  800e64:	89 e5                	mov    %esp,%ebp
  800e66:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800e69:	68 44 1f 80 00       	push   $0x801f44
  800e6e:	ff 75 0c             	pushl  0xc(%ebp)
  800e71:	e8 2e 08 00 00       	call   8016a4 <strcpy>
	return 0;
}
  800e76:	b8 00 00 00 00       	mov    $0x0,%eax
  800e7b:	c9                   	leave  
  800e7c:	c3                   	ret    

00800e7d <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800e7d:	55                   	push   %ebp
  800e7e:	89 e5                	mov    %esp,%ebp
  800e80:	57                   	push   %edi
  800e81:	56                   	push   %esi
  800e82:	53                   	push   %ebx
  800e83:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800e89:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e8d:	74 45                	je     800ed4 <devcons_write+0x57>
  800e8f:	b8 00 00 00 00       	mov    $0x0,%eax
  800e94:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800e99:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800e9f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ea2:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  800ea4:	83 fb 7f             	cmp    $0x7f,%ebx
  800ea7:	76 05                	jbe    800eae <devcons_write+0x31>
			m = sizeof(buf) - 1;
  800ea9:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800eae:	83 ec 04             	sub    $0x4,%esp
  800eb1:	53                   	push   %ebx
  800eb2:	03 45 0c             	add    0xc(%ebp),%eax
  800eb5:	50                   	push   %eax
  800eb6:	57                   	push   %edi
  800eb7:	e8 b5 09 00 00       	call   801871 <memmove>
		sys_cputs(buf, m);
  800ebc:	83 c4 08             	add    $0x8,%esp
  800ebf:	53                   	push   %ebx
  800ec0:	57                   	push   %edi
  800ec1:	e8 dc f1 ff ff       	call   8000a2 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ec6:	01 de                	add    %ebx,%esi
  800ec8:	89 f0                	mov    %esi,%eax
  800eca:	83 c4 10             	add    $0x10,%esp
  800ecd:	3b 75 10             	cmp    0x10(%ebp),%esi
  800ed0:	72 cd                	jb     800e9f <devcons_write+0x22>
  800ed2:	eb 05                	jmp    800ed9 <devcons_write+0x5c>
  800ed4:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800ed9:	89 f0                	mov    %esi,%eax
  800edb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ede:	5b                   	pop    %ebx
  800edf:	5e                   	pop    %esi
  800ee0:	5f                   	pop    %edi
  800ee1:	5d                   	pop    %ebp
  800ee2:	c3                   	ret    

00800ee3 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800ee3:	55                   	push   %ebp
  800ee4:	89 e5                	mov    %esp,%ebp
  800ee6:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  800ee9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800eed:	75 07                	jne    800ef6 <devcons_read+0x13>
  800eef:	eb 23                	jmp    800f14 <devcons_read+0x31>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800ef1:	e8 49 f2 ff ff       	call   80013f <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800ef6:	e8 c5 f1 ff ff       	call   8000c0 <sys_cgetc>
  800efb:	85 c0                	test   %eax,%eax
  800efd:	74 f2                	je     800ef1 <devcons_read+0xe>
		sys_yield();
	if (c < 0)
  800eff:	85 c0                	test   %eax,%eax
  800f01:	78 1d                	js     800f20 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f03:	83 f8 04             	cmp    $0x4,%eax
  800f06:	74 13                	je     800f1b <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  800f08:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f0b:	88 02                	mov    %al,(%edx)
	return 1;
  800f0d:	b8 01 00 00 00       	mov    $0x1,%eax
  800f12:	eb 0c                	jmp    800f20 <devcons_read+0x3d>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  800f14:	b8 00 00 00 00       	mov    $0x0,%eax
  800f19:	eb 05                	jmp    800f20 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f1b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f20:	c9                   	leave  
  800f21:	c3                   	ret    

00800f22 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f22:	55                   	push   %ebp
  800f23:	89 e5                	mov    %esp,%ebp
  800f25:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f28:	8b 45 08             	mov    0x8(%ebp),%eax
  800f2b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f2e:	6a 01                	push   $0x1
  800f30:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f33:	50                   	push   %eax
  800f34:	e8 69 f1 ff ff       	call   8000a2 <sys_cputs>
}
  800f39:	83 c4 10             	add    $0x10,%esp
  800f3c:	c9                   	leave  
  800f3d:	c3                   	ret    

00800f3e <getchar>:

int
getchar(void)
{
  800f3e:	55                   	push   %ebp
  800f3f:	89 e5                	mov    %esp,%ebp
  800f41:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f44:	6a 01                	push   $0x1
  800f46:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f49:	50                   	push   %eax
  800f4a:	6a 00                	push   $0x0
  800f4c:	e8 1a f7 ff ff       	call   80066b <read>
	if (r < 0)
  800f51:	83 c4 10             	add    $0x10,%esp
  800f54:	85 c0                	test   %eax,%eax
  800f56:	78 0f                	js     800f67 <getchar+0x29>
		return r;
	if (r < 1)
  800f58:	85 c0                	test   %eax,%eax
  800f5a:	7e 06                	jle    800f62 <getchar+0x24>
		return -E_EOF;
	return c;
  800f5c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800f60:	eb 05                	jmp    800f67 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800f62:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800f67:	c9                   	leave  
  800f68:	c3                   	ret    

00800f69 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800f69:	55                   	push   %ebp
  800f6a:	89 e5                	mov    %esp,%ebp
  800f6c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f6f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f72:	50                   	push   %eax
  800f73:	ff 75 08             	pushl  0x8(%ebp)
  800f76:	e8 6f f4 ff ff       	call   8003ea <fd_lookup>
  800f7b:	83 c4 10             	add    $0x10,%esp
  800f7e:	85 c0                	test   %eax,%eax
  800f80:	78 11                	js     800f93 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800f82:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f85:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800f8b:	39 10                	cmp    %edx,(%eax)
  800f8d:	0f 94 c0             	sete   %al
  800f90:	0f b6 c0             	movzbl %al,%eax
}
  800f93:	c9                   	leave  
  800f94:	c3                   	ret    

00800f95 <opencons>:

int
opencons(void)
{
  800f95:	55                   	push   %ebp
  800f96:	89 e5                	mov    %esp,%ebp
  800f98:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800f9b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f9e:	50                   	push   %eax
  800f9f:	e8 d2 f3 ff ff       	call   800376 <fd_alloc>
  800fa4:	83 c4 10             	add    $0x10,%esp
  800fa7:	85 c0                	test   %eax,%eax
  800fa9:	78 3a                	js     800fe5 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fab:	83 ec 04             	sub    $0x4,%esp
  800fae:	68 07 04 00 00       	push   $0x407
  800fb3:	ff 75 f4             	pushl  -0xc(%ebp)
  800fb6:	6a 00                	push   $0x0
  800fb8:	e8 a1 f1 ff ff       	call   80015e <sys_page_alloc>
  800fbd:	83 c4 10             	add    $0x10,%esp
  800fc0:	85 c0                	test   %eax,%eax
  800fc2:	78 21                	js     800fe5 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800fc4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fcd:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800fcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fd2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800fd9:	83 ec 0c             	sub    $0xc,%esp
  800fdc:	50                   	push   %eax
  800fdd:	e8 6d f3 ff ff       	call   80034f <fd2num>
  800fe2:	83 c4 10             	add    $0x10,%esp
}
  800fe5:	c9                   	leave  
  800fe6:	c3                   	ret    

00800fe7 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800fe7:	55                   	push   %ebp
  800fe8:	89 e5                	mov    %esp,%ebp
  800fea:	56                   	push   %esi
  800feb:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800fec:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800fef:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800ff5:	e8 26 f1 ff ff       	call   800120 <sys_getenvid>
  800ffa:	83 ec 0c             	sub    $0xc,%esp
  800ffd:	ff 75 0c             	pushl  0xc(%ebp)
  801000:	ff 75 08             	pushl  0x8(%ebp)
  801003:	56                   	push   %esi
  801004:	50                   	push   %eax
  801005:	68 50 1f 80 00       	push   $0x801f50
  80100a:	e8 b0 00 00 00       	call   8010bf <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80100f:	83 c4 18             	add    $0x18,%esp
  801012:	53                   	push   %ebx
  801013:	ff 75 10             	pushl  0x10(%ebp)
  801016:	e8 53 00 00 00       	call   80106e <vcprintf>
	cprintf("\n");
  80101b:	c7 04 24 3d 1f 80 00 	movl   $0x801f3d,(%esp)
  801022:	e8 98 00 00 00       	call   8010bf <cprintf>
  801027:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80102a:	cc                   	int3   
  80102b:	eb fd                	jmp    80102a <_panic+0x43>

0080102d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80102d:	55                   	push   %ebp
  80102e:	89 e5                	mov    %esp,%ebp
  801030:	53                   	push   %ebx
  801031:	83 ec 04             	sub    $0x4,%esp
  801034:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801037:	8b 13                	mov    (%ebx),%edx
  801039:	8d 42 01             	lea    0x1(%edx),%eax
  80103c:	89 03                	mov    %eax,(%ebx)
  80103e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801041:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801045:	3d ff 00 00 00       	cmp    $0xff,%eax
  80104a:	75 1a                	jne    801066 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80104c:	83 ec 08             	sub    $0x8,%esp
  80104f:	68 ff 00 00 00       	push   $0xff
  801054:	8d 43 08             	lea    0x8(%ebx),%eax
  801057:	50                   	push   %eax
  801058:	e8 45 f0 ff ff       	call   8000a2 <sys_cputs>
		b->idx = 0;
  80105d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801063:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801066:	ff 43 04             	incl   0x4(%ebx)
}
  801069:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80106c:	c9                   	leave  
  80106d:	c3                   	ret    

0080106e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80106e:	55                   	push   %ebp
  80106f:	89 e5                	mov    %esp,%ebp
  801071:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801077:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80107e:	00 00 00 
	b.cnt = 0;
  801081:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801088:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80108b:	ff 75 0c             	pushl  0xc(%ebp)
  80108e:	ff 75 08             	pushl  0x8(%ebp)
  801091:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801097:	50                   	push   %eax
  801098:	68 2d 10 80 00       	push   $0x80102d
  80109d:	e8 54 01 00 00       	call   8011f6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010a2:	83 c4 08             	add    $0x8,%esp
  8010a5:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010ab:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010b1:	50                   	push   %eax
  8010b2:	e8 eb ef ff ff       	call   8000a2 <sys_cputs>

	return b.cnt;
}
  8010b7:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8010bd:	c9                   	leave  
  8010be:	c3                   	ret    

008010bf <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8010bf:	55                   	push   %ebp
  8010c0:	89 e5                	mov    %esp,%ebp
  8010c2:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8010c5:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8010c8:	50                   	push   %eax
  8010c9:	ff 75 08             	pushl  0x8(%ebp)
  8010cc:	e8 9d ff ff ff       	call   80106e <vcprintf>
	va_end(ap);

	return cnt;
}
  8010d1:	c9                   	leave  
  8010d2:	c3                   	ret    

008010d3 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8010d3:	55                   	push   %ebp
  8010d4:	89 e5                	mov    %esp,%ebp
  8010d6:	57                   	push   %edi
  8010d7:	56                   	push   %esi
  8010d8:	53                   	push   %ebx
  8010d9:	83 ec 1c             	sub    $0x1c,%esp
  8010dc:	89 c6                	mov    %eax,%esi
  8010de:	89 d7                	mov    %edx,%edi
  8010e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010e6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8010e9:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8010ec:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8010ef:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010f4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8010f7:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8010fa:	39 d3                	cmp    %edx,%ebx
  8010fc:	72 11                	jb     80110f <printnum+0x3c>
  8010fe:	39 45 10             	cmp    %eax,0x10(%ebp)
  801101:	76 0c                	jbe    80110f <printnum+0x3c>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801103:	8b 45 14             	mov    0x14(%ebp),%eax
  801106:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801109:	85 db                	test   %ebx,%ebx
  80110b:	7f 37                	jg     801144 <printnum+0x71>
  80110d:	eb 44                	jmp    801153 <printnum+0x80>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80110f:	83 ec 0c             	sub    $0xc,%esp
  801112:	ff 75 18             	pushl  0x18(%ebp)
  801115:	8b 45 14             	mov    0x14(%ebp),%eax
  801118:	48                   	dec    %eax
  801119:	50                   	push   %eax
  80111a:	ff 75 10             	pushl  0x10(%ebp)
  80111d:	83 ec 08             	sub    $0x8,%esp
  801120:	ff 75 e4             	pushl  -0x1c(%ebp)
  801123:	ff 75 e0             	pushl  -0x20(%ebp)
  801126:	ff 75 dc             	pushl  -0x24(%ebp)
  801129:	ff 75 d8             	pushl  -0x28(%ebp)
  80112c:	e8 9b 0a 00 00       	call   801bcc <__udivdi3>
  801131:	83 c4 18             	add    $0x18,%esp
  801134:	52                   	push   %edx
  801135:	50                   	push   %eax
  801136:	89 fa                	mov    %edi,%edx
  801138:	89 f0                	mov    %esi,%eax
  80113a:	e8 94 ff ff ff       	call   8010d3 <printnum>
  80113f:	83 c4 20             	add    $0x20,%esp
  801142:	eb 0f                	jmp    801153 <printnum+0x80>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801144:	83 ec 08             	sub    $0x8,%esp
  801147:	57                   	push   %edi
  801148:	ff 75 18             	pushl  0x18(%ebp)
  80114b:	ff d6                	call   *%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80114d:	83 c4 10             	add    $0x10,%esp
  801150:	4b                   	dec    %ebx
  801151:	75 f1                	jne    801144 <printnum+0x71>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801153:	83 ec 08             	sub    $0x8,%esp
  801156:	57                   	push   %edi
  801157:	83 ec 04             	sub    $0x4,%esp
  80115a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80115d:	ff 75 e0             	pushl  -0x20(%ebp)
  801160:	ff 75 dc             	pushl  -0x24(%ebp)
  801163:	ff 75 d8             	pushl  -0x28(%ebp)
  801166:	e8 71 0b 00 00       	call   801cdc <__umoddi3>
  80116b:	83 c4 14             	add    $0x14,%esp
  80116e:	0f be 80 73 1f 80 00 	movsbl 0x801f73(%eax),%eax
  801175:	50                   	push   %eax
  801176:	ff d6                	call   *%esi
}
  801178:	83 c4 10             	add    $0x10,%esp
  80117b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80117e:	5b                   	pop    %ebx
  80117f:	5e                   	pop    %esi
  801180:	5f                   	pop    %edi
  801181:	5d                   	pop    %ebp
  801182:	c3                   	ret    

00801183 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801183:	55                   	push   %ebp
  801184:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801186:	83 fa 01             	cmp    $0x1,%edx
  801189:	7e 0e                	jle    801199 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80118b:	8b 10                	mov    (%eax),%edx
  80118d:	8d 4a 08             	lea    0x8(%edx),%ecx
  801190:	89 08                	mov    %ecx,(%eax)
  801192:	8b 02                	mov    (%edx),%eax
  801194:	8b 52 04             	mov    0x4(%edx),%edx
  801197:	eb 22                	jmp    8011bb <getuint+0x38>
	else if (lflag)
  801199:	85 d2                	test   %edx,%edx
  80119b:	74 10                	je     8011ad <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80119d:	8b 10                	mov    (%eax),%edx
  80119f:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011a2:	89 08                	mov    %ecx,(%eax)
  8011a4:	8b 02                	mov    (%edx),%eax
  8011a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8011ab:	eb 0e                	jmp    8011bb <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8011ad:	8b 10                	mov    (%eax),%edx
  8011af:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011b2:	89 08                	mov    %ecx,(%eax)
  8011b4:	8b 02                	mov    (%edx),%eax
  8011b6:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8011bb:	5d                   	pop    %ebp
  8011bc:	c3                   	ret    

008011bd <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011bd:	55                   	push   %ebp
  8011be:	89 e5                	mov    %esp,%ebp
  8011c0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011c3:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8011c6:	8b 10                	mov    (%eax),%edx
  8011c8:	3b 50 04             	cmp    0x4(%eax),%edx
  8011cb:	73 0a                	jae    8011d7 <sprintputch+0x1a>
		*b->buf++ = ch;
  8011cd:	8d 4a 01             	lea    0x1(%edx),%ecx
  8011d0:	89 08                	mov    %ecx,(%eax)
  8011d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d5:	88 02                	mov    %al,(%edx)
}
  8011d7:	5d                   	pop    %ebp
  8011d8:	c3                   	ret    

008011d9 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8011d9:	55                   	push   %ebp
  8011da:	89 e5                	mov    %esp,%ebp
  8011dc:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8011df:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8011e2:	50                   	push   %eax
  8011e3:	ff 75 10             	pushl  0x10(%ebp)
  8011e6:	ff 75 0c             	pushl  0xc(%ebp)
  8011e9:	ff 75 08             	pushl  0x8(%ebp)
  8011ec:	e8 05 00 00 00       	call   8011f6 <vprintfmt>
	va_end(ap);
}
  8011f1:	83 c4 10             	add    $0x10,%esp
  8011f4:	c9                   	leave  
  8011f5:	c3                   	ret    

008011f6 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8011f6:	55                   	push   %ebp
  8011f7:	89 e5                	mov    %esp,%ebp
  8011f9:	57                   	push   %edi
  8011fa:	56                   	push   %esi
  8011fb:	53                   	push   %ebx
  8011fc:	83 ec 2c             	sub    $0x2c,%esp
  8011ff:	8b 7d 08             	mov    0x8(%ebp),%edi
  801202:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801205:	eb 03                	jmp    80120a <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  801207:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  80120a:	8b 45 10             	mov    0x10(%ebp),%eax
  80120d:	8d 70 01             	lea    0x1(%eax),%esi
  801210:	0f b6 00             	movzbl (%eax),%eax
  801213:	83 f8 25             	cmp    $0x25,%eax
  801216:	74 25                	je     80123d <vprintfmt+0x47>
			if (ch == '\0')									//当然中间如果遇到'\0'，代表这个字符串的访问结束
  801218:	85 c0                	test   %eax,%eax
  80121a:	75 0d                	jne    801229 <vprintfmt+0x33>
  80121c:	e9 b5 03 00 00       	jmp    8015d6 <vprintfmt+0x3e0>
  801221:	85 c0                	test   %eax,%eax
  801223:	0f 84 ad 03 00 00    	je     8015d6 <vprintfmt+0x3e0>
				return;
			putch(ch, putdat);								//调用putch函数，把一个字符ch输出到putdat指针所指向的地址中所存放的值对应的地址处
  801229:	83 ec 08             	sub    $0x8,%esp
  80122c:	53                   	push   %ebx
  80122d:	50                   	push   %eax
  80122e:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  801230:	46                   	inc    %esi
  801231:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  801235:	83 c4 10             	add    $0x10,%esp
  801238:	83 f8 25             	cmp    $0x25,%eax
  80123b:	75 e4                	jne    801221 <vprintfmt+0x2b>
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  80123d:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  801241:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801248:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80124f:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  801256:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80125d:	eb 07                	jmp    801266 <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80125f:	8b 75 10             	mov    0x10(%ebp),%esi

		// flag to pad on the right
		case '-':											//%后面的'-'代表要进行左对齐输出，右边填空格，如果省略代表右对齐
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
  801262:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  801266:	8d 46 01             	lea    0x1(%esi),%eax
  801269:	89 45 10             	mov    %eax,0x10(%ebp)
  80126c:	0f b6 16             	movzbl (%esi),%edx
  80126f:	8a 06                	mov    (%esi),%al
  801271:	83 e8 23             	sub    $0x23,%eax
  801274:	3c 55                	cmp    $0x55,%al
  801276:	0f 87 03 03 00 00    	ja     80157f <vprintfmt+0x389>
  80127c:	0f b6 c0             	movzbl %al,%eax
  80127f:	ff 24 85 c0 20 80 00 	jmp    *0x8020c0(,%eax,4)
  801286:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
			goto reswitch;									//处理下一个字符

		// flag to pad with 0's instead of spaces
		case '0':											//0--有0表示进行对齐输出时填0,如省略表示填入空格，并且如果为0，则一定是右对齐
			padc = '0';										//对其方式标志位变为0
  801289:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  80128d:	eb d7                	jmp    801266 <vprintfmt+0x70>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
				precision = precision * 10 + ch - '0';
  80128f:	8d 42 d0             	lea    -0x30(%edx),%eax
  801292:	89 c1                	mov    %eax,%ecx
  801294:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  801297:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  80129b:	8d 50 d0             	lea    -0x30(%eax),%edx
  80129e:	83 fa 09             	cmp    $0x9,%edx
  8012a1:	77 51                	ja     8012f4 <vprintfmt+0xfe>
  8012a3:	8b 75 10             	mov    0x10(%ebp),%esi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
  8012a6:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8012a7:	8d 14 89             	lea    (%ecx,%ecx,4),%edx
  8012aa:	01 d2                	add    %edx,%edx
  8012ac:	8d 4c 10 d0          	lea    -0x30(%eax,%edx,1),%ecx
				ch = *fmt;
  8012b0:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8012b3:	8d 50 d0             	lea    -0x30(%eax),%edx
  8012b6:	83 fa 09             	cmp    $0x9,%edx
  8012b9:	76 eb                	jbe    8012a6 <vprintfmt+0xb0>
  8012bb:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8012be:	eb 37                	jmp    8012f7 <vprintfmt+0x101>
					break;
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
  8012c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8012c3:	8d 50 04             	lea    0x4(%eax),%edx
  8012c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8012c9:	8b 00                	mov    (%eax),%eax
  8012cb:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8012ce:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
			goto process_precision;
  8012d1:	eb 24                	jmp    8012f7 <vprintfmt+0x101>
  8012d3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8012d7:	79 07                	jns    8012e0 <vprintfmt+0xea>
  8012d9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8012e0:	8b 75 10             	mov    0x10(%ebp),%esi
  8012e3:	eb 81                	jmp    801266 <vprintfmt+0x70>
  8012e5:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  8012e8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8012ef:	e9 72 ff ff ff       	jmp    801266 <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8012f4:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:									//处理输出精度，把width字段赋值为刚刚计算出来的precision值，所以width应该是整数部分的有效数字位数
			if (width < 0)
  8012f7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8012fb:	0f 89 65 ff ff ff    	jns    801266 <vprintfmt+0x70>
				width = precision, precision = -1;
  801301:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801304:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801307:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80130e:	e9 53 ff ff ff       	jmp    801266 <vprintfmt+0x70>
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
  801313:	ff 45 d4             	incl   -0x2c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  801316:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
			goto reswitch;
  801319:	e9 48 ff ff ff       	jmp    801266 <vprintfmt+0x70>

		// character
		case 'c':											//如果是'c'代表显示一个字符
			putch(va_arg(ap, int), putdat);					//调用输出一个字符到内存的函数putch
  80131e:	8b 45 14             	mov    0x14(%ebp),%eax
  801321:	8d 50 04             	lea    0x4(%eax),%edx
  801324:	89 55 14             	mov    %edx,0x14(%ebp)
  801327:	83 ec 08             	sub    $0x8,%esp
  80132a:	53                   	push   %ebx
  80132b:	ff 30                	pushl  (%eax)
  80132d:	ff d7                	call   *%edi
			break;
  80132f:	83 c4 10             	add    $0x10,%esp
  801332:	e9 d3 fe ff ff       	jmp    80120a <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801337:	8b 45 14             	mov    0x14(%ebp),%eax
  80133a:	8d 50 04             	lea    0x4(%eax),%edx
  80133d:	89 55 14             	mov    %edx,0x14(%ebp)
  801340:	8b 00                	mov    (%eax),%eax
  801342:	85 c0                	test   %eax,%eax
  801344:	79 02                	jns    801348 <vprintfmt+0x152>
  801346:	f7 d8                	neg    %eax
  801348:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80134a:	83 f8 0f             	cmp    $0xf,%eax
  80134d:	7f 0b                	jg     80135a <vprintfmt+0x164>
  80134f:	8b 04 85 20 22 80 00 	mov    0x802220(,%eax,4),%eax
  801356:	85 c0                	test   %eax,%eax
  801358:	75 15                	jne    80136f <vprintfmt+0x179>
				printfmt(putch, putdat, "error %d", err);
  80135a:	52                   	push   %edx
  80135b:	68 8b 1f 80 00       	push   $0x801f8b
  801360:	53                   	push   %ebx
  801361:	57                   	push   %edi
  801362:	e8 72 fe ff ff       	call   8011d9 <printfmt>
  801367:	83 c4 10             	add    $0x10,%esp
  80136a:	e9 9b fe ff ff       	jmp    80120a <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  80136f:	50                   	push   %eax
  801370:	68 0b 1f 80 00       	push   $0x801f0b
  801375:	53                   	push   %ebx
  801376:	57                   	push   %edi
  801377:	e8 5d fe ff ff       	call   8011d9 <printfmt>
  80137c:	83 c4 10             	add    $0x10,%esp
  80137f:	e9 86 fe ff ff       	jmp    80120a <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801384:	8b 45 14             	mov    0x14(%ebp),%eax
  801387:	8d 50 04             	lea    0x4(%eax),%edx
  80138a:	89 55 14             	mov    %edx,0x14(%ebp)
  80138d:	8b 00                	mov    (%eax),%eax
  80138f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  801392:	85 c0                	test   %eax,%eax
  801394:	75 07                	jne    80139d <vprintfmt+0x1a7>
				p = "(null)";
  801396:	c7 45 d4 84 1f 80 00 	movl   $0x801f84,-0x2c(%ebp)
			if (width > 0 && padc != '-')
  80139d:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8013a0:	85 f6                	test   %esi,%esi
  8013a2:	0f 8e fb 01 00 00    	jle    8015a3 <vprintfmt+0x3ad>
  8013a8:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  8013ac:	0f 84 09 02 00 00    	je     8015bb <vprintfmt+0x3c5>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013b2:	83 ec 08             	sub    $0x8,%esp
  8013b5:	ff 75 d0             	pushl  -0x30(%ebp)
  8013b8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013bb:	e8 ad 02 00 00       	call   80166d <strnlen>
  8013c0:	89 f1                	mov    %esi,%ecx
  8013c2:	29 c1                	sub    %eax,%ecx
  8013c4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8013c7:	83 c4 10             	add    $0x10,%esp
  8013ca:	85 c9                	test   %ecx,%ecx
  8013cc:	0f 8e d1 01 00 00    	jle    8015a3 <vprintfmt+0x3ad>
					putch(padc, putdat);
  8013d2:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8013d6:	83 ec 08             	sub    $0x8,%esp
  8013d9:	53                   	push   %ebx
  8013da:	56                   	push   %esi
  8013db:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013dd:	83 c4 10             	add    $0x10,%esp
  8013e0:	ff 4d e4             	decl   -0x1c(%ebp)
  8013e3:	75 f1                	jne    8013d6 <vprintfmt+0x1e0>
  8013e5:	e9 b9 01 00 00       	jmp    8015a3 <vprintfmt+0x3ad>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8013ea:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8013ee:	74 19                	je     801409 <vprintfmt+0x213>
  8013f0:	0f be c0             	movsbl %al,%eax
  8013f3:	83 e8 20             	sub    $0x20,%eax
  8013f6:	83 f8 5e             	cmp    $0x5e,%eax
  8013f9:	76 0e                	jbe    801409 <vprintfmt+0x213>
					putch('?', putdat);
  8013fb:	83 ec 08             	sub    $0x8,%esp
  8013fe:	53                   	push   %ebx
  8013ff:	6a 3f                	push   $0x3f
  801401:	ff 55 08             	call   *0x8(%ebp)
  801404:	83 c4 10             	add    $0x10,%esp
  801407:	eb 0b                	jmp    801414 <vprintfmt+0x21e>
				else
					putch(ch, putdat);
  801409:	83 ec 08             	sub    $0x8,%esp
  80140c:	53                   	push   %ebx
  80140d:	52                   	push   %edx
  80140e:	ff 55 08             	call   *0x8(%ebp)
  801411:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801414:	ff 4d e4             	decl   -0x1c(%ebp)
  801417:	46                   	inc    %esi
  801418:	8a 46 ff             	mov    -0x1(%esi),%al
  80141b:	0f be d0             	movsbl %al,%edx
  80141e:	85 d2                	test   %edx,%edx
  801420:	75 1c                	jne    80143e <vprintfmt+0x248>
  801422:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801425:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801429:	7f 1f                	jg     80144a <vprintfmt+0x254>
  80142b:	e9 da fd ff ff       	jmp    80120a <vprintfmt+0x14>
  801430:	89 7d 08             	mov    %edi,0x8(%ebp)
  801433:	8b 7d d0             	mov    -0x30(%ebp),%edi
  801436:	eb 06                	jmp    80143e <vprintfmt+0x248>
  801438:	89 7d 08             	mov    %edi,0x8(%ebp)
  80143b:	8b 7d d0             	mov    -0x30(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80143e:	85 ff                	test   %edi,%edi
  801440:	78 a8                	js     8013ea <vprintfmt+0x1f4>
  801442:	4f                   	dec    %edi
  801443:	79 a5                	jns    8013ea <vprintfmt+0x1f4>
  801445:	8b 7d 08             	mov    0x8(%ebp),%edi
  801448:	eb db                	jmp    801425 <vprintfmt+0x22f>
  80144a:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80144d:	83 ec 08             	sub    $0x8,%esp
  801450:	53                   	push   %ebx
  801451:	6a 20                	push   $0x20
  801453:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801455:	4e                   	dec    %esi
  801456:	83 c4 10             	add    $0x10,%esp
  801459:	85 f6                	test   %esi,%esi
  80145b:	7f f0                	jg     80144d <vprintfmt+0x257>
  80145d:	e9 a8 fd ff ff       	jmp    80120a <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801462:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  801466:	7e 16                	jle    80147e <vprintfmt+0x288>
		return va_arg(*ap, long long);
  801468:	8b 45 14             	mov    0x14(%ebp),%eax
  80146b:	8d 50 08             	lea    0x8(%eax),%edx
  80146e:	89 55 14             	mov    %edx,0x14(%ebp)
  801471:	8b 50 04             	mov    0x4(%eax),%edx
  801474:	8b 00                	mov    (%eax),%eax
  801476:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801479:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80147c:	eb 34                	jmp    8014b2 <vprintfmt+0x2bc>
	else if (lflag)
  80147e:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  801482:	74 18                	je     80149c <vprintfmt+0x2a6>
		return va_arg(*ap, long);
  801484:	8b 45 14             	mov    0x14(%ebp),%eax
  801487:	8d 50 04             	lea    0x4(%eax),%edx
  80148a:	89 55 14             	mov    %edx,0x14(%ebp)
  80148d:	8b 30                	mov    (%eax),%esi
  80148f:	89 75 d8             	mov    %esi,-0x28(%ebp)
  801492:	89 f0                	mov    %esi,%eax
  801494:	c1 f8 1f             	sar    $0x1f,%eax
  801497:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80149a:	eb 16                	jmp    8014b2 <vprintfmt+0x2bc>
	else
		return va_arg(*ap, int);
  80149c:	8b 45 14             	mov    0x14(%ebp),%eax
  80149f:	8d 50 04             	lea    0x4(%eax),%edx
  8014a2:	89 55 14             	mov    %edx,0x14(%ebp)
  8014a5:	8b 30                	mov    (%eax),%esi
  8014a7:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8014aa:	89 f0                	mov    %esi,%eax
  8014ac:	c1 f8 1f             	sar    $0x1f,%eax
  8014af:	89 45 dc             	mov    %eax,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8014b2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8014b5:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
  8014b8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8014bc:	0f 89 8a 00 00 00    	jns    80154c <vprintfmt+0x356>
				putch('-', putdat);
  8014c2:	83 ec 08             	sub    $0x8,%esp
  8014c5:	53                   	push   %ebx
  8014c6:	6a 2d                	push   $0x2d
  8014c8:	ff d7                	call   *%edi
				num = -(long long) num;
  8014ca:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8014cd:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8014d0:	f7 d8                	neg    %eax
  8014d2:	83 d2 00             	adc    $0x0,%edx
  8014d5:	f7 da                	neg    %edx
  8014d7:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8014da:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8014df:	eb 70                	jmp    801551 <vprintfmt+0x35b>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8014e1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8014e4:	8d 45 14             	lea    0x14(%ebp),%eax
  8014e7:	e8 97 fc ff ff       	call   801183 <getuint>
			base = 10;
  8014ec:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8014f1:	eb 5e                	jmp    801551 <vprintfmt+0x35b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  8014f3:	83 ec 08             	sub    $0x8,%esp
  8014f6:	53                   	push   %ebx
  8014f7:	6a 30                	push   $0x30
  8014f9:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  8014fb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8014fe:	8d 45 14             	lea    0x14(%ebp),%eax
  801501:	e8 7d fc ff ff       	call   801183 <getuint>
			base = 8;
			goto number;
  801506:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  801509:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80150e:	eb 41                	jmp    801551 <vprintfmt+0x35b>
		// pointer
		case 'p':
			putch('0', putdat);
  801510:	83 ec 08             	sub    $0x8,%esp
  801513:	53                   	push   %ebx
  801514:	6a 30                	push   $0x30
  801516:	ff d7                	call   *%edi
			putch('x', putdat);
  801518:	83 c4 08             	add    $0x8,%esp
  80151b:	53                   	push   %ebx
  80151c:	6a 78                	push   $0x78
  80151e:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801520:	8b 45 14             	mov    0x14(%ebp),%eax
  801523:	8d 50 04             	lea    0x4(%eax),%edx
  801526:	89 55 14             	mov    %edx,0x14(%ebp)
			goto number;
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801529:	8b 00                	mov    (%eax),%eax
  80152b:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801530:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801533:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801538:	eb 17                	jmp    801551 <vprintfmt+0x35b>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80153a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80153d:	8d 45 14             	lea    0x14(%ebp),%eax
  801540:	e8 3e fc ff ff       	call   801183 <getuint>
			base = 16;
  801545:	b9 10 00 00 00       	mov    $0x10,%ecx
  80154a:	eb 05                	jmp    801551 <vprintfmt+0x35b>
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80154c:	b9 0a 00 00 00       	mov    $0xa,%ecx
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  801551:	83 ec 0c             	sub    $0xc,%esp
  801554:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  801558:	56                   	push   %esi
  801559:	ff 75 e4             	pushl  -0x1c(%ebp)
  80155c:	51                   	push   %ecx
  80155d:	52                   	push   %edx
  80155e:	50                   	push   %eax
  80155f:	89 da                	mov    %ebx,%edx
  801561:	89 f8                	mov    %edi,%eax
  801563:	e8 6b fb ff ff       	call   8010d3 <printnum>
			break;
  801568:	83 c4 20             	add    $0x20,%esp
  80156b:	e9 9a fc ff ff       	jmp    80120a <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801570:	83 ec 08             	sub    $0x8,%esp
  801573:	53                   	push   %ebx
  801574:	52                   	push   %edx
  801575:	ff d7                	call   *%edi
			break;
  801577:	83 c4 10             	add    $0x10,%esp
  80157a:	e9 8b fc ff ff       	jmp    80120a <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80157f:	83 ec 08             	sub    $0x8,%esp
  801582:	53                   	push   %ebx
  801583:	6a 25                	push   $0x25
  801585:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801587:	83 c4 10             	add    $0x10,%esp
  80158a:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80158e:	0f 84 73 fc ff ff    	je     801207 <vprintfmt+0x11>
  801594:	4e                   	dec    %esi
  801595:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  801599:	75 f9                	jne    801594 <vprintfmt+0x39e>
  80159b:	89 75 10             	mov    %esi,0x10(%ebp)
  80159e:	e9 67 fc ff ff       	jmp    80120a <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8015a3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8015a6:	8d 70 01             	lea    0x1(%eax),%esi
  8015a9:	8a 00                	mov    (%eax),%al
  8015ab:	0f be d0             	movsbl %al,%edx
  8015ae:	85 d2                	test   %edx,%edx
  8015b0:	0f 85 7a fe ff ff    	jne    801430 <vprintfmt+0x23a>
  8015b6:	e9 4f fc ff ff       	jmp    80120a <vprintfmt+0x14>
  8015bb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8015be:	8d 70 01             	lea    0x1(%eax),%esi
  8015c1:	8a 00                	mov    (%eax),%al
  8015c3:	0f be d0             	movsbl %al,%edx
  8015c6:	85 d2                	test   %edx,%edx
  8015c8:	0f 85 6a fe ff ff    	jne    801438 <vprintfmt+0x242>
  8015ce:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8015d1:	e9 77 fe ff ff       	jmp    80144d <vprintfmt+0x257>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  8015d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015d9:	5b                   	pop    %ebx
  8015da:	5e                   	pop    %esi
  8015db:	5f                   	pop    %edi
  8015dc:	5d                   	pop    %ebp
  8015dd:	c3                   	ret    

008015de <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8015de:	55                   	push   %ebp
  8015df:	89 e5                	mov    %esp,%ebp
  8015e1:	83 ec 18             	sub    $0x18,%esp
  8015e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8015ea:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8015ed:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8015f1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8015f4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8015fb:	85 c0                	test   %eax,%eax
  8015fd:	74 26                	je     801625 <vsnprintf+0x47>
  8015ff:	85 d2                	test   %edx,%edx
  801601:	7e 29                	jle    80162c <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801603:	ff 75 14             	pushl  0x14(%ebp)
  801606:	ff 75 10             	pushl  0x10(%ebp)
  801609:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80160c:	50                   	push   %eax
  80160d:	68 bd 11 80 00       	push   $0x8011bd
  801612:	e8 df fb ff ff       	call   8011f6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801617:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80161a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80161d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801620:	83 c4 10             	add    $0x10,%esp
  801623:	eb 0c                	jmp    801631 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801625:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80162a:	eb 05                	jmp    801631 <vsnprintf+0x53>
  80162c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801631:	c9                   	leave  
  801632:	c3                   	ret    

00801633 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801633:	55                   	push   %ebp
  801634:	89 e5                	mov    %esp,%ebp
  801636:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801639:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80163c:	50                   	push   %eax
  80163d:	ff 75 10             	pushl  0x10(%ebp)
  801640:	ff 75 0c             	pushl  0xc(%ebp)
  801643:	ff 75 08             	pushl  0x8(%ebp)
  801646:	e8 93 ff ff ff       	call   8015de <vsnprintf>
	va_end(ap);

	return rc;
}
  80164b:	c9                   	leave  
  80164c:	c3                   	ret    

0080164d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80164d:	55                   	push   %ebp
  80164e:	89 e5                	mov    %esp,%ebp
  801650:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801653:	80 3a 00             	cmpb   $0x0,(%edx)
  801656:	74 0e                	je     801666 <strlen+0x19>
  801658:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80165d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80165e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801662:	75 f9                	jne    80165d <strlen+0x10>
  801664:	eb 05                	jmp    80166b <strlen+0x1e>
  801666:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80166b:	5d                   	pop    %ebp
  80166c:	c3                   	ret    

0080166d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80166d:	55                   	push   %ebp
  80166e:	89 e5                	mov    %esp,%ebp
  801670:	53                   	push   %ebx
  801671:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801674:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801677:	85 c9                	test   %ecx,%ecx
  801679:	74 1a                	je     801695 <strnlen+0x28>
  80167b:	80 3b 00             	cmpb   $0x0,(%ebx)
  80167e:	74 1c                	je     80169c <strnlen+0x2f>
  801680:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  801685:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801687:	39 ca                	cmp    %ecx,%edx
  801689:	74 16                	je     8016a1 <strnlen+0x34>
  80168b:	42                   	inc    %edx
  80168c:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  801691:	75 f2                	jne    801685 <strnlen+0x18>
  801693:	eb 0c                	jmp    8016a1 <strnlen+0x34>
  801695:	b8 00 00 00 00       	mov    $0x0,%eax
  80169a:	eb 05                	jmp    8016a1 <strnlen+0x34>
  80169c:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8016a1:	5b                   	pop    %ebx
  8016a2:	5d                   	pop    %ebp
  8016a3:	c3                   	ret    

008016a4 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016a4:	55                   	push   %ebp
  8016a5:	89 e5                	mov    %esp,%ebp
  8016a7:	53                   	push   %ebx
  8016a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016ae:	89 c2                	mov    %eax,%edx
  8016b0:	42                   	inc    %edx
  8016b1:	41                   	inc    %ecx
  8016b2:	8a 59 ff             	mov    -0x1(%ecx),%bl
  8016b5:	88 5a ff             	mov    %bl,-0x1(%edx)
  8016b8:	84 db                	test   %bl,%bl
  8016ba:	75 f4                	jne    8016b0 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8016bc:	5b                   	pop    %ebx
  8016bd:	5d                   	pop    %ebp
  8016be:	c3                   	ret    

008016bf <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016bf:	55                   	push   %ebp
  8016c0:	89 e5                	mov    %esp,%ebp
  8016c2:	53                   	push   %ebx
  8016c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016c6:	53                   	push   %ebx
  8016c7:	e8 81 ff ff ff       	call   80164d <strlen>
  8016cc:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8016cf:	ff 75 0c             	pushl  0xc(%ebp)
  8016d2:	01 d8                	add    %ebx,%eax
  8016d4:	50                   	push   %eax
  8016d5:	e8 ca ff ff ff       	call   8016a4 <strcpy>
	return dst;
}
  8016da:	89 d8                	mov    %ebx,%eax
  8016dc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016df:	c9                   	leave  
  8016e0:	c3                   	ret    

008016e1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016e1:	55                   	push   %ebp
  8016e2:	89 e5                	mov    %esp,%ebp
  8016e4:	56                   	push   %esi
  8016e5:	53                   	push   %ebx
  8016e6:	8b 75 08             	mov    0x8(%ebp),%esi
  8016e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016ec:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016ef:	85 db                	test   %ebx,%ebx
  8016f1:	74 14                	je     801707 <strncpy+0x26>
  8016f3:	01 f3                	add    %esi,%ebx
  8016f5:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  8016f7:	41                   	inc    %ecx
  8016f8:	8a 02                	mov    (%edx),%al
  8016fa:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8016fd:	80 3a 01             	cmpb   $0x1,(%edx)
  801700:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801703:	39 cb                	cmp    %ecx,%ebx
  801705:	75 f0                	jne    8016f7 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801707:	89 f0                	mov    %esi,%eax
  801709:	5b                   	pop    %ebx
  80170a:	5e                   	pop    %esi
  80170b:	5d                   	pop    %ebp
  80170c:	c3                   	ret    

0080170d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80170d:	55                   	push   %ebp
  80170e:	89 e5                	mov    %esp,%ebp
  801710:	53                   	push   %ebx
  801711:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801714:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801717:	85 c0                	test   %eax,%eax
  801719:	74 30                	je     80174b <strlcpy+0x3e>
		while (--size > 0 && *src != '\0')
  80171b:	48                   	dec    %eax
  80171c:	74 20                	je     80173e <strlcpy+0x31>
  80171e:	8a 0b                	mov    (%ebx),%cl
  801720:	84 c9                	test   %cl,%cl
  801722:	74 1f                	je     801743 <strlcpy+0x36>
  801724:	8d 53 01             	lea    0x1(%ebx),%edx
  801727:	01 c3                	add    %eax,%ebx
  801729:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
  80172c:	40                   	inc    %eax
  80172d:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801730:	39 da                	cmp    %ebx,%edx
  801732:	74 12                	je     801746 <strlcpy+0x39>
  801734:	42                   	inc    %edx
  801735:	8a 4a ff             	mov    -0x1(%edx),%cl
  801738:	84 c9                	test   %cl,%cl
  80173a:	75 f0                	jne    80172c <strlcpy+0x1f>
  80173c:	eb 08                	jmp    801746 <strlcpy+0x39>
  80173e:	8b 45 08             	mov    0x8(%ebp),%eax
  801741:	eb 03                	jmp    801746 <strlcpy+0x39>
  801743:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
		*dst = '\0';
  801746:	c6 00 00             	movb   $0x0,(%eax)
  801749:	eb 03                	jmp    80174e <strlcpy+0x41>
  80174b:	8b 45 08             	mov    0x8(%ebp),%eax
	}
	return dst - dst_in;
  80174e:	2b 45 08             	sub    0x8(%ebp),%eax
}
  801751:	5b                   	pop    %ebx
  801752:	5d                   	pop    %ebp
  801753:	c3                   	ret    

00801754 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801754:	55                   	push   %ebp
  801755:	89 e5                	mov    %esp,%ebp
  801757:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80175a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80175d:	8a 01                	mov    (%ecx),%al
  80175f:	84 c0                	test   %al,%al
  801761:	74 10                	je     801773 <strcmp+0x1f>
  801763:	3a 02                	cmp    (%edx),%al
  801765:	75 0c                	jne    801773 <strcmp+0x1f>
		p++, q++;
  801767:	41                   	inc    %ecx
  801768:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801769:	8a 01                	mov    (%ecx),%al
  80176b:	84 c0                	test   %al,%al
  80176d:	74 04                	je     801773 <strcmp+0x1f>
  80176f:	3a 02                	cmp    (%edx),%al
  801771:	74 f4                	je     801767 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801773:	0f b6 c0             	movzbl %al,%eax
  801776:	0f b6 12             	movzbl (%edx),%edx
  801779:	29 d0                	sub    %edx,%eax
}
  80177b:	5d                   	pop    %ebp
  80177c:	c3                   	ret    

0080177d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80177d:	55                   	push   %ebp
  80177e:	89 e5                	mov    %esp,%ebp
  801780:	56                   	push   %esi
  801781:	53                   	push   %ebx
  801782:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801785:	8b 55 0c             	mov    0xc(%ebp),%edx
  801788:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  80178b:	85 f6                	test   %esi,%esi
  80178d:	74 23                	je     8017b2 <strncmp+0x35>
  80178f:	8a 03                	mov    (%ebx),%al
  801791:	84 c0                	test   %al,%al
  801793:	74 2b                	je     8017c0 <strncmp+0x43>
  801795:	3a 02                	cmp    (%edx),%al
  801797:	75 27                	jne    8017c0 <strncmp+0x43>
  801799:	8d 43 01             	lea    0x1(%ebx),%eax
  80179c:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  80179e:	89 c3                	mov    %eax,%ebx
  8017a0:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017a1:	39 c6                	cmp    %eax,%esi
  8017a3:	74 14                	je     8017b9 <strncmp+0x3c>
  8017a5:	8a 08                	mov    (%eax),%cl
  8017a7:	84 c9                	test   %cl,%cl
  8017a9:	74 15                	je     8017c0 <strncmp+0x43>
  8017ab:	40                   	inc    %eax
  8017ac:	3a 0a                	cmp    (%edx),%cl
  8017ae:	74 ee                	je     80179e <strncmp+0x21>
  8017b0:	eb 0e                	jmp    8017c0 <strncmp+0x43>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8017b7:	eb 0f                	jmp    8017c8 <strncmp+0x4b>
  8017b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8017be:	eb 08                	jmp    8017c8 <strncmp+0x4b>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017c0:	0f b6 03             	movzbl (%ebx),%eax
  8017c3:	0f b6 12             	movzbl (%edx),%edx
  8017c6:	29 d0                	sub    %edx,%eax
}
  8017c8:	5b                   	pop    %ebx
  8017c9:	5e                   	pop    %esi
  8017ca:	5d                   	pop    %ebp
  8017cb:	c3                   	ret    

008017cc <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017cc:	55                   	push   %ebp
  8017cd:	89 e5                	mov    %esp,%ebp
  8017cf:	53                   	push   %ebx
  8017d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  8017d6:	8a 10                	mov    (%eax),%dl
  8017d8:	84 d2                	test   %dl,%dl
  8017da:	74 1a                	je     8017f6 <strchr+0x2a>
  8017dc:	88 d9                	mov    %bl,%cl
		if (*s == c)
  8017de:	38 d3                	cmp    %dl,%bl
  8017e0:	75 06                	jne    8017e8 <strchr+0x1c>
  8017e2:	eb 17                	jmp    8017fb <strchr+0x2f>
  8017e4:	38 ca                	cmp    %cl,%dl
  8017e6:	74 13                	je     8017fb <strchr+0x2f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017e8:	40                   	inc    %eax
  8017e9:	8a 10                	mov    (%eax),%dl
  8017eb:	84 d2                	test   %dl,%dl
  8017ed:	75 f5                	jne    8017e4 <strchr+0x18>
		if (*s == c)
			return (char *) s;
	return 0;
  8017ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8017f4:	eb 05                	jmp    8017fb <strchr+0x2f>
  8017f6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017fb:	5b                   	pop    %ebx
  8017fc:	5d                   	pop    %ebp
  8017fd:	c3                   	ret    

008017fe <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017fe:	55                   	push   %ebp
  8017ff:	89 e5                	mov    %esp,%ebp
  801801:	53                   	push   %ebx
  801802:	8b 45 08             	mov    0x8(%ebp),%eax
  801805:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  801808:	8a 10                	mov    (%eax),%dl
  80180a:	84 d2                	test   %dl,%dl
  80180c:	74 13                	je     801821 <strfind+0x23>
  80180e:	88 d9                	mov    %bl,%cl
		if (*s == c)
  801810:	38 d3                	cmp    %dl,%bl
  801812:	75 06                	jne    80181a <strfind+0x1c>
  801814:	eb 0b                	jmp    801821 <strfind+0x23>
  801816:	38 ca                	cmp    %cl,%dl
  801818:	74 07                	je     801821 <strfind+0x23>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80181a:	40                   	inc    %eax
  80181b:	8a 10                	mov    (%eax),%dl
  80181d:	84 d2                	test   %dl,%dl
  80181f:	75 f5                	jne    801816 <strfind+0x18>
		if (*s == c)
			break;
	return (char *) s;
}
  801821:	5b                   	pop    %ebx
  801822:	5d                   	pop    %ebp
  801823:	c3                   	ret    

00801824 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801824:	55                   	push   %ebp
  801825:	89 e5                	mov    %esp,%ebp
  801827:	57                   	push   %edi
  801828:	56                   	push   %esi
  801829:	53                   	push   %ebx
  80182a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80182d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801830:	85 c9                	test   %ecx,%ecx
  801832:	74 36                	je     80186a <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801834:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80183a:	75 28                	jne    801864 <memset+0x40>
  80183c:	f6 c1 03             	test   $0x3,%cl
  80183f:	75 23                	jne    801864 <memset+0x40>
		c &= 0xFF;
  801841:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801845:	89 d3                	mov    %edx,%ebx
  801847:	c1 e3 08             	shl    $0x8,%ebx
  80184a:	89 d6                	mov    %edx,%esi
  80184c:	c1 e6 18             	shl    $0x18,%esi
  80184f:	89 d0                	mov    %edx,%eax
  801851:	c1 e0 10             	shl    $0x10,%eax
  801854:	09 f0                	or     %esi,%eax
  801856:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801858:	89 d8                	mov    %ebx,%eax
  80185a:	09 d0                	or     %edx,%eax
  80185c:	c1 e9 02             	shr    $0x2,%ecx
  80185f:	fc                   	cld    
  801860:	f3 ab                	rep stos %eax,%es:(%edi)
  801862:	eb 06                	jmp    80186a <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801864:	8b 45 0c             	mov    0xc(%ebp),%eax
  801867:	fc                   	cld    
  801868:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80186a:	89 f8                	mov    %edi,%eax
  80186c:	5b                   	pop    %ebx
  80186d:	5e                   	pop    %esi
  80186e:	5f                   	pop    %edi
  80186f:	5d                   	pop    %ebp
  801870:	c3                   	ret    

00801871 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801871:	55                   	push   %ebp
  801872:	89 e5                	mov    %esp,%ebp
  801874:	57                   	push   %edi
  801875:	56                   	push   %esi
  801876:	8b 45 08             	mov    0x8(%ebp),%eax
  801879:	8b 75 0c             	mov    0xc(%ebp),%esi
  80187c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80187f:	39 c6                	cmp    %eax,%esi
  801881:	73 33                	jae    8018b6 <memmove+0x45>
  801883:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801886:	39 d0                	cmp    %edx,%eax
  801888:	73 2c                	jae    8018b6 <memmove+0x45>
		s += n;
		d += n;
  80188a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80188d:	89 d6                	mov    %edx,%esi
  80188f:	09 fe                	or     %edi,%esi
  801891:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801897:	75 13                	jne    8018ac <memmove+0x3b>
  801899:	f6 c1 03             	test   $0x3,%cl
  80189c:	75 0e                	jne    8018ac <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80189e:	83 ef 04             	sub    $0x4,%edi
  8018a1:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018a4:	c1 e9 02             	shr    $0x2,%ecx
  8018a7:	fd                   	std    
  8018a8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018aa:	eb 07                	jmp    8018b3 <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8018ac:	4f                   	dec    %edi
  8018ad:	8d 72 ff             	lea    -0x1(%edx),%esi
  8018b0:	fd                   	std    
  8018b1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018b3:	fc                   	cld    
  8018b4:	eb 1d                	jmp    8018d3 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018b6:	89 f2                	mov    %esi,%edx
  8018b8:	09 c2                	or     %eax,%edx
  8018ba:	f6 c2 03             	test   $0x3,%dl
  8018bd:	75 0f                	jne    8018ce <memmove+0x5d>
  8018bf:	f6 c1 03             	test   $0x3,%cl
  8018c2:	75 0a                	jne    8018ce <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
  8018c4:	c1 e9 02             	shr    $0x2,%ecx
  8018c7:	89 c7                	mov    %eax,%edi
  8018c9:	fc                   	cld    
  8018ca:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018cc:	eb 05                	jmp    8018d3 <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018ce:	89 c7                	mov    %eax,%edi
  8018d0:	fc                   	cld    
  8018d1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018d3:	5e                   	pop    %esi
  8018d4:	5f                   	pop    %edi
  8018d5:	5d                   	pop    %ebp
  8018d6:	c3                   	ret    

008018d7 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018d7:	55                   	push   %ebp
  8018d8:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018da:	ff 75 10             	pushl  0x10(%ebp)
  8018dd:	ff 75 0c             	pushl  0xc(%ebp)
  8018e0:	ff 75 08             	pushl  0x8(%ebp)
  8018e3:	e8 89 ff ff ff       	call   801871 <memmove>
}
  8018e8:	c9                   	leave  
  8018e9:	c3                   	ret    

008018ea <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018ea:	55                   	push   %ebp
  8018eb:	89 e5                	mov    %esp,%ebp
  8018ed:	57                   	push   %edi
  8018ee:	56                   	push   %esi
  8018ef:	53                   	push   %ebx
  8018f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8018f3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018f6:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018f9:	85 c0                	test   %eax,%eax
  8018fb:	74 33                	je     801930 <memcmp+0x46>
  8018fd:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  801900:	8a 13                	mov    (%ebx),%dl
  801902:	8a 0e                	mov    (%esi),%cl
  801904:	38 ca                	cmp    %cl,%dl
  801906:	75 13                	jne    80191b <memcmp+0x31>
  801908:	b8 00 00 00 00       	mov    $0x0,%eax
  80190d:	eb 16                	jmp    801925 <memcmp+0x3b>
  80190f:	8a 54 03 01          	mov    0x1(%ebx,%eax,1),%dl
  801913:	40                   	inc    %eax
  801914:	8a 0c 06             	mov    (%esi,%eax,1),%cl
  801917:	38 ca                	cmp    %cl,%dl
  801919:	74 0a                	je     801925 <memcmp+0x3b>
			return (int) *s1 - (int) *s2;
  80191b:	0f b6 c2             	movzbl %dl,%eax
  80191e:	0f b6 c9             	movzbl %cl,%ecx
  801921:	29 c8                	sub    %ecx,%eax
  801923:	eb 10                	jmp    801935 <memcmp+0x4b>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801925:	39 f8                	cmp    %edi,%eax
  801927:	75 e6                	jne    80190f <memcmp+0x25>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801929:	b8 00 00 00 00       	mov    $0x0,%eax
  80192e:	eb 05                	jmp    801935 <memcmp+0x4b>
  801930:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801935:	5b                   	pop    %ebx
  801936:	5e                   	pop    %esi
  801937:	5f                   	pop    %edi
  801938:	5d                   	pop    %ebp
  801939:	c3                   	ret    

0080193a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80193a:	55                   	push   %ebp
  80193b:	89 e5                	mov    %esp,%ebp
  80193d:	53                   	push   %ebx
  80193e:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  801941:	89 d0                	mov    %edx,%eax
  801943:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  801946:	39 c2                	cmp    %eax,%edx
  801948:	73 1b                	jae    801965 <memfind+0x2b>
		if (*(const unsigned char *) s == (unsigned char) c)
  80194a:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  80194e:	0f b6 0a             	movzbl (%edx),%ecx
  801951:	39 d9                	cmp    %ebx,%ecx
  801953:	75 09                	jne    80195e <memfind+0x24>
  801955:	eb 12                	jmp    801969 <memfind+0x2f>
  801957:	0f b6 0a             	movzbl (%edx),%ecx
  80195a:	39 d9                	cmp    %ebx,%ecx
  80195c:	74 0f                	je     80196d <memfind+0x33>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80195e:	42                   	inc    %edx
  80195f:	39 d0                	cmp    %edx,%eax
  801961:	75 f4                	jne    801957 <memfind+0x1d>
  801963:	eb 0a                	jmp    80196f <memfind+0x35>
  801965:	89 d0                	mov    %edx,%eax
  801967:	eb 06                	jmp    80196f <memfind+0x35>
		if (*(const unsigned char *) s == (unsigned char) c)
  801969:	89 d0                	mov    %edx,%eax
  80196b:	eb 02                	jmp    80196f <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80196d:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80196f:	5b                   	pop    %ebx
  801970:	5d                   	pop    %ebp
  801971:	c3                   	ret    

00801972 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801972:	55                   	push   %ebp
  801973:	89 e5                	mov    %esp,%ebp
  801975:	57                   	push   %edi
  801976:	56                   	push   %esi
  801977:	53                   	push   %ebx
  801978:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80197b:	eb 01                	jmp    80197e <strtol+0xc>
		s++;
  80197d:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80197e:	8a 01                	mov    (%ecx),%al
  801980:	3c 20                	cmp    $0x20,%al
  801982:	74 f9                	je     80197d <strtol+0xb>
  801984:	3c 09                	cmp    $0x9,%al
  801986:	74 f5                	je     80197d <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  801988:	3c 2b                	cmp    $0x2b,%al
  80198a:	75 08                	jne    801994 <strtol+0x22>
		s++;
  80198c:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80198d:	bf 00 00 00 00       	mov    $0x0,%edi
  801992:	eb 11                	jmp    8019a5 <strtol+0x33>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801994:	3c 2d                	cmp    $0x2d,%al
  801996:	75 08                	jne    8019a0 <strtol+0x2e>
		s++, neg = 1;
  801998:	41                   	inc    %ecx
  801999:	bf 01 00 00 00       	mov    $0x1,%edi
  80199e:	eb 05                	jmp    8019a5 <strtol+0x33>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8019a0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019a5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019a9:	0f 84 87 00 00 00    	je     801a36 <strtol+0xc4>
  8019af:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  8019b3:	75 27                	jne    8019dc <strtol+0x6a>
  8019b5:	80 39 30             	cmpb   $0x30,(%ecx)
  8019b8:	75 22                	jne    8019dc <strtol+0x6a>
  8019ba:	e9 88 00 00 00       	jmp    801a47 <strtol+0xd5>
		s += 2, base = 16;
  8019bf:	83 c1 02             	add    $0x2,%ecx
  8019c2:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  8019c9:	eb 11                	jmp    8019dc <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
  8019cb:	41                   	inc    %ecx
  8019cc:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  8019d3:	eb 07                	jmp    8019dc <strtol+0x6a>
	else if (base == 0)
		base = 10;
  8019d5:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  8019dc:	b8 00 00 00 00       	mov    $0x0,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019e1:	8a 11                	mov    (%ecx),%dl
  8019e3:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8019e6:	80 fb 09             	cmp    $0x9,%bl
  8019e9:	77 08                	ja     8019f3 <strtol+0x81>
			dig = *s - '0';
  8019eb:	0f be d2             	movsbl %dl,%edx
  8019ee:	83 ea 30             	sub    $0x30,%edx
  8019f1:	eb 22                	jmp    801a15 <strtol+0xa3>
		else if (*s >= 'a' && *s <= 'z')
  8019f3:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019f6:	89 f3                	mov    %esi,%ebx
  8019f8:	80 fb 19             	cmp    $0x19,%bl
  8019fb:	77 08                	ja     801a05 <strtol+0x93>
			dig = *s - 'a' + 10;
  8019fd:	0f be d2             	movsbl %dl,%edx
  801a00:	83 ea 57             	sub    $0x57,%edx
  801a03:	eb 10                	jmp    801a15 <strtol+0xa3>
		else if (*s >= 'A' && *s <= 'Z')
  801a05:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a08:	89 f3                	mov    %esi,%ebx
  801a0a:	80 fb 19             	cmp    $0x19,%bl
  801a0d:	77 14                	ja     801a23 <strtol+0xb1>
			dig = *s - 'A' + 10;
  801a0f:	0f be d2             	movsbl %dl,%edx
  801a12:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801a15:	3b 55 10             	cmp    0x10(%ebp),%edx
  801a18:	7d 09                	jge    801a23 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  801a1a:	41                   	inc    %ecx
  801a1b:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a1f:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801a21:	eb be                	jmp    8019e1 <strtol+0x6f>

	if (endptr)
  801a23:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a27:	74 05                	je     801a2e <strtol+0xbc>
		*endptr = (char *) s;
  801a29:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a2c:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801a2e:	85 ff                	test   %edi,%edi
  801a30:	74 21                	je     801a53 <strtol+0xe1>
  801a32:	f7 d8                	neg    %eax
  801a34:	eb 1d                	jmp    801a53 <strtol+0xe1>
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801a36:	80 39 30             	cmpb   $0x30,(%ecx)
  801a39:	75 9a                	jne    8019d5 <strtol+0x63>
  801a3b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801a3f:	0f 84 7a ff ff ff    	je     8019bf <strtol+0x4d>
  801a45:	eb 84                	jmp    8019cb <strtol+0x59>
  801a47:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801a4b:	0f 84 6e ff ff ff    	je     8019bf <strtol+0x4d>
  801a51:	eb 89                	jmp    8019dc <strtol+0x6a>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  801a53:	5b                   	pop    %ebx
  801a54:	5e                   	pop    %esi
  801a55:	5f                   	pop    %edi
  801a56:	5d                   	pop    %ebp
  801a57:	c3                   	ret    

00801a58 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a58:	55                   	push   %ebp
  801a59:	89 e5                	mov    %esp,%ebp
  801a5b:	56                   	push   %esi
  801a5c:	53                   	push   %ebx
  801a5d:	8b 75 08             	mov    0x8(%ebp),%esi
  801a60:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a63:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");
	int r;
    if (pg != NULL) {
  801a66:	85 c0                	test   %eax,%eax
  801a68:	74 0e                	je     801a78 <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  801a6a:	83 ec 0c             	sub    $0xc,%esp
  801a6d:	50                   	push   %eax
  801a6e:	e8 9b e8 ff ff       	call   80030e <sys_ipc_recv>
  801a73:	83 c4 10             	add    $0x10,%esp
  801a76:	eb 10                	jmp    801a88 <ipc_recv+0x30>
    } else {
        r = sys_ipc_recv((void *) UTOP);
  801a78:	83 ec 0c             	sub    $0xc,%esp
  801a7b:	68 00 00 c0 ee       	push   $0xeec00000
  801a80:	e8 89 e8 ff ff       	call   80030e <sys_ipc_recv>
  801a85:	83 c4 10             	add    $0x10,%esp
    }
    if (r < 0) {
  801a88:	85 c0                	test   %eax,%eax
  801a8a:	79 16                	jns    801aa2 <ipc_recv+0x4a>
        // failed
        if (from_env_store != NULL) *from_env_store = 0;
  801a8c:	85 f6                	test   %esi,%esi
  801a8e:	74 06                	je     801a96 <ipc_recv+0x3e>
  801a90:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL) *perm_store = 0;
  801a96:	85 db                	test   %ebx,%ebx
  801a98:	74 2c                	je     801ac6 <ipc_recv+0x6e>
  801a9a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801aa0:	eb 24                	jmp    801ac6 <ipc_recv+0x6e>
        return r;
    } else {
        if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801aa2:	85 f6                	test   %esi,%esi
  801aa4:	74 0a                	je     801ab0 <ipc_recv+0x58>
  801aa6:	a1 04 40 80 00       	mov    0x804004,%eax
  801aab:	8b 40 74             	mov    0x74(%eax),%eax
  801aae:	89 06                	mov    %eax,(%esi)
        if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801ab0:	85 db                	test   %ebx,%ebx
  801ab2:	74 0a                	je     801abe <ipc_recv+0x66>
  801ab4:	a1 04 40 80 00       	mov    0x804004,%eax
  801ab9:	8b 40 78             	mov    0x78(%eax),%eax
  801abc:	89 03                	mov    %eax,(%ebx)
        return thisenv->env_ipc_value;
  801abe:	a1 04 40 80 00       	mov    0x804004,%eax
  801ac3:	8b 40 70             	mov    0x70(%eax),%eax
    }
 
	return 0;
}
  801ac6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ac9:	5b                   	pop    %ebx
  801aca:	5e                   	pop    %esi
  801acb:	5d                   	pop    %ebp
  801acc:	c3                   	ret    

00801acd <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801acd:	55                   	push   %ebp
  801ace:	89 e5                	mov    %esp,%ebp
  801ad0:	57                   	push   %edi
  801ad1:	56                   	push   %esi
  801ad2:	53                   	push   %ebx
  801ad3:	83 ec 0c             	sub    $0xc,%esp
  801ad6:	8b 75 10             	mov    0x10(%ebp),%esi
  801ad9:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;
    if (pg == NULL) pg = (void *)UTOP;
  801adc:	85 f6                	test   %esi,%esi
  801ade:	75 05                	jne    801ae5 <ipc_send+0x18>
  801ae0:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
  801ae5:	57                   	push   %edi
  801ae6:	56                   	push   %esi
  801ae7:	ff 75 0c             	pushl  0xc(%ebp)
  801aea:	ff 75 08             	pushl  0x8(%ebp)
  801aed:	e8 f9 e7 ff ff       	call   8002eb <sys_ipc_try_send>
  801af2:	89 c3                	mov    %eax,%ebx
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
  801af4:	83 c4 10             	add    $0x10,%esp
  801af7:	85 c0                	test   %eax,%eax
  801af9:	79 17                	jns    801b12 <ipc_send+0x45>
  801afb:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801afe:	74 1d                	je     801b1d <ipc_send+0x50>
  801b00:	50                   	push   %eax
  801b01:	68 80 22 80 00       	push   $0x802280
  801b06:	6a 40                	push   $0x40
  801b08:	68 94 22 80 00       	push   $0x802294
  801b0d:	e8 d5 f4 ff ff       	call   800fe7 <_panic>
        sys_yield();
  801b12:	e8 28 e6 ff ff       	call   80013f <sys_yield>
    } while (r != 0);
  801b17:	85 db                	test   %ebx,%ebx
  801b19:	75 ca                	jne    801ae5 <ipc_send+0x18>
  801b1b:	eb 07                	jmp    801b24 <ipc_send+0x57>
	int r;
    if (pg == NULL) pg = (void *)UTOP;
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
        sys_yield();
  801b1d:	e8 1d e6 ff ff       	call   80013f <sys_yield>
  801b22:	eb c1                	jmp    801ae5 <ipc_send+0x18>
    } while (r != 0);
}
  801b24:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b27:	5b                   	pop    %ebx
  801b28:	5e                   	pop    %esi
  801b29:	5f                   	pop    %edi
  801b2a:	5d                   	pop    %ebp
  801b2b:	c3                   	ret    

00801b2c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b2c:	55                   	push   %ebp
  801b2d:	89 e5                	mov    %esp,%ebp
  801b2f:	53                   	push   %ebx
  801b30:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801b33:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801b38:	39 c1                	cmp    %eax,%ecx
  801b3a:	74 21                	je     801b5d <ipc_find_env+0x31>
  801b3c:	ba 01 00 00 00       	mov    $0x1,%edx
  801b41:	8d 1c 95 00 00 00 00 	lea    0x0(,%edx,4),%ebx
  801b48:	89 d0                	mov    %edx,%eax
  801b4a:	c1 e0 07             	shl    $0x7,%eax
  801b4d:	29 d8                	sub    %ebx,%eax
  801b4f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b54:	8b 40 50             	mov    0x50(%eax),%eax
  801b57:	39 c8                	cmp    %ecx,%eax
  801b59:	75 1b                	jne    801b76 <ipc_find_env+0x4a>
  801b5b:	eb 05                	jmp    801b62 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b5d:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801b62:	8d 04 95 00 00 00 00 	lea    0x0(,%edx,4),%eax
  801b69:	c1 e2 07             	shl    $0x7,%edx
  801b6c:	29 c2                	sub    %eax,%edx
  801b6e:	8b 82 48 00 c0 ee    	mov    -0x113fffb8(%edx),%eax
  801b74:	eb 0e                	jmp    801b84 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b76:	42                   	inc    %edx
  801b77:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  801b7d:	75 c2                	jne    801b41 <ipc_find_env+0x15>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b7f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b84:	5b                   	pop    %ebx
  801b85:	5d                   	pop    %ebp
  801b86:	c3                   	ret    

00801b87 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b87:	55                   	push   %ebp
  801b88:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b8a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b8d:	c1 e8 16             	shr    $0x16,%eax
  801b90:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801b97:	a8 01                	test   $0x1,%al
  801b99:	74 21                	je     801bbc <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b9b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b9e:	c1 e8 0c             	shr    $0xc,%eax
  801ba1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801ba8:	a8 01                	test   $0x1,%al
  801baa:	74 17                	je     801bc3 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bac:	c1 e8 0c             	shr    $0xc,%eax
  801baf:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801bb6:	ef 
  801bb7:	0f b7 c0             	movzwl %ax,%eax
  801bba:	eb 0c                	jmp    801bc8 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801bbc:	b8 00 00 00 00       	mov    $0x0,%eax
  801bc1:	eb 05                	jmp    801bc8 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801bc3:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801bc8:	5d                   	pop    %ebp
  801bc9:	c3                   	ret    
  801bca:	66 90                	xchg   %ax,%ax

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
