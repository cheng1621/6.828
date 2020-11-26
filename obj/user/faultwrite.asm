
obj/user/faultwrite.debug:     file format elf32-i386


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
  80002c:	e8 11 00 00 00       	call   800042 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	*(unsigned*)0 = 0;
  800036:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80003d:	00 00 00 
}
  800040:	5d                   	pop    %ebp
  800041:	c3                   	ret    

00800042 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800042:	55                   	push   %ebp
  800043:	89 e5                	mov    %esp,%ebp
  800045:	56                   	push   %esi
  800046:	53                   	push   %ebx
  800047:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004a:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80004d:	e8 d7 00 00 00       	call   800129 <sys_getenvid>
  800052:	25 ff 03 00 00       	and    $0x3ff,%eax
  800057:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80005e:	c1 e0 07             	shl    $0x7,%eax
  800061:	29 d0                	sub    %edx,%eax
  800063:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800068:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006d:	85 db                	test   %ebx,%ebx
  80006f:	7e 07                	jle    800078 <libmain+0x36>
		binaryname = argv[0];
  800071:	8b 06                	mov    (%esi),%eax
  800073:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800078:	83 ec 08             	sub    $0x8,%esp
  80007b:	56                   	push   %esi
  80007c:	53                   	push   %ebx
  80007d:	e8 b1 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800082:	e8 0a 00 00 00       	call   800091 <exit>
}
  800087:	83 c4 10             	add    $0x10,%esp
  80008a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008d:	5b                   	pop    %ebx
  80008e:	5e                   	pop    %esi
  80008f:	5d                   	pop    %ebp
  800090:	c3                   	ret    

00800091 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800091:	55                   	push   %ebp
  800092:	89 e5                	mov    %esp,%ebp
  800094:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800097:	e8 cb 04 00 00       	call   800567 <close_all>
	sys_env_destroy(0);
  80009c:	83 ec 0c             	sub    $0xc,%esp
  80009f:	6a 00                	push   $0x0
  8000a1:	e8 42 00 00 00       	call   8000e8 <sys_env_destroy>
}
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	c9                   	leave  
  8000aa:	c3                   	ret    

008000ab <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ab:	55                   	push   %ebp
  8000ac:	89 e5                	mov    %esp,%ebp
  8000ae:	57                   	push   %edi
  8000af:	56                   	push   %esi
  8000b0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bc:	89 c3                	mov    %eax,%ebx
  8000be:	89 c7                	mov    %eax,%edi
  8000c0:	89 c6                	mov    %eax,%esi
  8000c2:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c4:	5b                   	pop    %ebx
  8000c5:	5e                   	pop    %esi
  8000c6:	5f                   	pop    %edi
  8000c7:	5d                   	pop    %ebp
  8000c8:	c3                   	ret    

008000c9 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c9:	55                   	push   %ebp
  8000ca:	89 e5                	mov    %esp,%ebp
  8000cc:	57                   	push   %edi
  8000cd:	56                   	push   %esi
  8000ce:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d4:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d9:	89 d1                	mov    %edx,%ecx
  8000db:	89 d3                	mov    %edx,%ebx
  8000dd:	89 d7                	mov    %edx,%edi
  8000df:	89 d6                	mov    %edx,%esi
  8000e1:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e3:	5b                   	pop    %ebx
  8000e4:	5e                   	pop    %esi
  8000e5:	5f                   	pop    %edi
  8000e6:	5d                   	pop    %ebp
  8000e7:	c3                   	ret    

008000e8 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e8:	55                   	push   %ebp
  8000e9:	89 e5                	mov    %esp,%ebp
  8000eb:	57                   	push   %edi
  8000ec:	56                   	push   %esi
  8000ed:	53                   	push   %ebx
  8000ee:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f6:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fe:	89 cb                	mov    %ecx,%ebx
  800100:	89 cf                	mov    %ecx,%edi
  800102:	89 ce                	mov    %ecx,%esi
  800104:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800106:	85 c0                	test   %eax,%eax
  800108:	7e 17                	jle    800121 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80010a:	83 ec 0c             	sub    $0xc,%esp
  80010d:	50                   	push   %eax
  80010e:	6a 03                	push   $0x3
  800110:	68 4a 1e 80 00       	push   $0x801e4a
  800115:	6a 23                	push   $0x23
  800117:	68 67 1e 80 00       	push   $0x801e67
  80011c:	e8 cf 0e 00 00       	call   800ff0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800121:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800124:	5b                   	pop    %ebx
  800125:	5e                   	pop    %esi
  800126:	5f                   	pop    %edi
  800127:	5d                   	pop    %ebp
  800128:	c3                   	ret    

00800129 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800129:	55                   	push   %ebp
  80012a:	89 e5                	mov    %esp,%ebp
  80012c:	57                   	push   %edi
  80012d:	56                   	push   %esi
  80012e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80012f:	ba 00 00 00 00       	mov    $0x0,%edx
  800134:	b8 02 00 00 00       	mov    $0x2,%eax
  800139:	89 d1                	mov    %edx,%ecx
  80013b:	89 d3                	mov    %edx,%ebx
  80013d:	89 d7                	mov    %edx,%edi
  80013f:	89 d6                	mov    %edx,%esi
  800141:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800143:	5b                   	pop    %ebx
  800144:	5e                   	pop    %esi
  800145:	5f                   	pop    %edi
  800146:	5d                   	pop    %ebp
  800147:	c3                   	ret    

00800148 <sys_yield>:

void
sys_yield(void)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	57                   	push   %edi
  80014c:	56                   	push   %esi
  80014d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014e:	ba 00 00 00 00       	mov    $0x0,%edx
  800153:	b8 0b 00 00 00       	mov    $0xb,%eax
  800158:	89 d1                	mov    %edx,%ecx
  80015a:	89 d3                	mov    %edx,%ebx
  80015c:	89 d7                	mov    %edx,%edi
  80015e:	89 d6                	mov    %edx,%esi
  800160:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800162:	5b                   	pop    %ebx
  800163:	5e                   	pop    %esi
  800164:	5f                   	pop    %edi
  800165:	5d                   	pop    %ebp
  800166:	c3                   	ret    

00800167 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800167:	55                   	push   %ebp
  800168:	89 e5                	mov    %esp,%ebp
  80016a:	57                   	push   %edi
  80016b:	56                   	push   %esi
  80016c:	53                   	push   %ebx
  80016d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800170:	be 00 00 00 00       	mov    $0x0,%esi
  800175:	b8 04 00 00 00       	mov    $0x4,%eax
  80017a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80017d:	8b 55 08             	mov    0x8(%ebp),%edx
  800180:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800183:	89 f7                	mov    %esi,%edi
  800185:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800187:	85 c0                	test   %eax,%eax
  800189:	7e 17                	jle    8001a2 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80018b:	83 ec 0c             	sub    $0xc,%esp
  80018e:	50                   	push   %eax
  80018f:	6a 04                	push   $0x4
  800191:	68 4a 1e 80 00       	push   $0x801e4a
  800196:	6a 23                	push   $0x23
  800198:	68 67 1e 80 00       	push   $0x801e67
  80019d:	e8 4e 0e 00 00       	call   800ff0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a5:	5b                   	pop    %ebx
  8001a6:	5e                   	pop    %esi
  8001a7:	5f                   	pop    %edi
  8001a8:	5d                   	pop    %ebp
  8001a9:	c3                   	ret    

008001aa <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001aa:	55                   	push   %ebp
  8001ab:	89 e5                	mov    %esp,%ebp
  8001ad:	57                   	push   %edi
  8001ae:	56                   	push   %esi
  8001af:	53                   	push   %ebx
  8001b0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001b3:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8001be:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c1:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c4:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001c9:	85 c0                	test   %eax,%eax
  8001cb:	7e 17                	jle    8001e4 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001cd:	83 ec 0c             	sub    $0xc,%esp
  8001d0:	50                   	push   %eax
  8001d1:	6a 05                	push   $0x5
  8001d3:	68 4a 1e 80 00       	push   $0x801e4a
  8001d8:	6a 23                	push   $0x23
  8001da:	68 67 1e 80 00       	push   $0x801e67
  8001df:	e8 0c 0e 00 00       	call   800ff0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e7:	5b                   	pop    %ebx
  8001e8:	5e                   	pop    %esi
  8001e9:	5f                   	pop    %edi
  8001ea:	5d                   	pop    %ebp
  8001eb:	c3                   	ret    

008001ec <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001ec:	55                   	push   %ebp
  8001ed:	89 e5                	mov    %esp,%ebp
  8001ef:	57                   	push   %edi
  8001f0:	56                   	push   %esi
  8001f1:	53                   	push   %ebx
  8001f2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001fa:	b8 06 00 00 00       	mov    $0x6,%eax
  8001ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800202:	8b 55 08             	mov    0x8(%ebp),%edx
  800205:	89 df                	mov    %ebx,%edi
  800207:	89 de                	mov    %ebx,%esi
  800209:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80020b:	85 c0                	test   %eax,%eax
  80020d:	7e 17                	jle    800226 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80020f:	83 ec 0c             	sub    $0xc,%esp
  800212:	50                   	push   %eax
  800213:	6a 06                	push   $0x6
  800215:	68 4a 1e 80 00       	push   $0x801e4a
  80021a:	6a 23                	push   $0x23
  80021c:	68 67 1e 80 00       	push   $0x801e67
  800221:	e8 ca 0d 00 00       	call   800ff0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800226:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800229:	5b                   	pop    %ebx
  80022a:	5e                   	pop    %esi
  80022b:	5f                   	pop    %edi
  80022c:	5d                   	pop    %ebp
  80022d:	c3                   	ret    

0080022e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022e:	55                   	push   %ebp
  80022f:	89 e5                	mov    %esp,%ebp
  800231:	57                   	push   %edi
  800232:	56                   	push   %esi
  800233:	53                   	push   %ebx
  800234:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800237:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023c:	b8 08 00 00 00       	mov    $0x8,%eax
  800241:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800244:	8b 55 08             	mov    0x8(%ebp),%edx
  800247:	89 df                	mov    %ebx,%edi
  800249:	89 de                	mov    %ebx,%esi
  80024b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80024d:	85 c0                	test   %eax,%eax
  80024f:	7e 17                	jle    800268 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800251:	83 ec 0c             	sub    $0xc,%esp
  800254:	50                   	push   %eax
  800255:	6a 08                	push   $0x8
  800257:	68 4a 1e 80 00       	push   $0x801e4a
  80025c:	6a 23                	push   $0x23
  80025e:	68 67 1e 80 00       	push   $0x801e67
  800263:	e8 88 0d 00 00       	call   800ff0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800268:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026b:	5b                   	pop    %ebx
  80026c:	5e                   	pop    %esi
  80026d:	5f                   	pop    %edi
  80026e:	5d                   	pop    %ebp
  80026f:	c3                   	ret    

00800270 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	57                   	push   %edi
  800274:	56                   	push   %esi
  800275:	53                   	push   %ebx
  800276:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800279:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027e:	b8 09 00 00 00       	mov    $0x9,%eax
  800283:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800286:	8b 55 08             	mov    0x8(%ebp),%edx
  800289:	89 df                	mov    %ebx,%edi
  80028b:	89 de                	mov    %ebx,%esi
  80028d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80028f:	85 c0                	test   %eax,%eax
  800291:	7e 17                	jle    8002aa <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800293:	83 ec 0c             	sub    $0xc,%esp
  800296:	50                   	push   %eax
  800297:	6a 09                	push   $0x9
  800299:	68 4a 1e 80 00       	push   $0x801e4a
  80029e:	6a 23                	push   $0x23
  8002a0:	68 67 1e 80 00       	push   $0x801e67
  8002a5:	e8 46 0d 00 00       	call   800ff0 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ad:	5b                   	pop    %ebx
  8002ae:	5e                   	pop    %esi
  8002af:	5f                   	pop    %edi
  8002b0:	5d                   	pop    %ebp
  8002b1:	c3                   	ret    

008002b2 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002b2:	55                   	push   %ebp
  8002b3:	89 e5                	mov    %esp,%ebp
  8002b5:	57                   	push   %edi
  8002b6:	56                   	push   %esi
  8002b7:	53                   	push   %ebx
  8002b8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002bb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c8:	8b 55 08             	mov    0x8(%ebp),%edx
  8002cb:	89 df                	mov    %ebx,%edi
  8002cd:	89 de                	mov    %ebx,%esi
  8002cf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002d1:	85 c0                	test   %eax,%eax
  8002d3:	7e 17                	jle    8002ec <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d5:	83 ec 0c             	sub    $0xc,%esp
  8002d8:	50                   	push   %eax
  8002d9:	6a 0a                	push   $0xa
  8002db:	68 4a 1e 80 00       	push   $0x801e4a
  8002e0:	6a 23                	push   $0x23
  8002e2:	68 67 1e 80 00       	push   $0x801e67
  8002e7:	e8 04 0d 00 00       	call   800ff0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ef:	5b                   	pop    %ebx
  8002f0:	5e                   	pop    %esi
  8002f1:	5f                   	pop    %edi
  8002f2:	5d                   	pop    %ebp
  8002f3:	c3                   	ret    

008002f4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f4:	55                   	push   %ebp
  8002f5:	89 e5                	mov    %esp,%ebp
  8002f7:	57                   	push   %edi
  8002f8:	56                   	push   %esi
  8002f9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002fa:	be 00 00 00 00       	mov    $0x0,%esi
  8002ff:	b8 0c 00 00 00       	mov    $0xc,%eax
  800304:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800307:	8b 55 08             	mov    0x8(%ebp),%edx
  80030a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80030d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800310:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800312:	5b                   	pop    %ebx
  800313:	5e                   	pop    %esi
  800314:	5f                   	pop    %edi
  800315:	5d                   	pop    %ebp
  800316:	c3                   	ret    

00800317 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800317:	55                   	push   %ebp
  800318:	89 e5                	mov    %esp,%ebp
  80031a:	57                   	push   %edi
  80031b:	56                   	push   %esi
  80031c:	53                   	push   %ebx
  80031d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800320:	b9 00 00 00 00       	mov    $0x0,%ecx
  800325:	b8 0d 00 00 00       	mov    $0xd,%eax
  80032a:	8b 55 08             	mov    0x8(%ebp),%edx
  80032d:	89 cb                	mov    %ecx,%ebx
  80032f:	89 cf                	mov    %ecx,%edi
  800331:	89 ce                	mov    %ecx,%esi
  800333:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800335:	85 c0                	test   %eax,%eax
  800337:	7e 17                	jle    800350 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800339:	83 ec 0c             	sub    $0xc,%esp
  80033c:	50                   	push   %eax
  80033d:	6a 0d                	push   $0xd
  80033f:	68 4a 1e 80 00       	push   $0x801e4a
  800344:	6a 23                	push   $0x23
  800346:	68 67 1e 80 00       	push   $0x801e67
  80034b:	e8 a0 0c 00 00       	call   800ff0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800350:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800353:	5b                   	pop    %ebx
  800354:	5e                   	pop    %esi
  800355:	5f                   	pop    %edi
  800356:	5d                   	pop    %ebp
  800357:	c3                   	ret    

00800358 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800358:	55                   	push   %ebp
  800359:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80035b:	8b 45 08             	mov    0x8(%ebp),%eax
  80035e:	05 00 00 00 30       	add    $0x30000000,%eax
  800363:	c1 e8 0c             	shr    $0xc,%eax
}
  800366:	5d                   	pop    %ebp
  800367:	c3                   	ret    

00800368 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800368:	55                   	push   %ebp
  800369:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80036b:	8b 45 08             	mov    0x8(%ebp),%eax
  80036e:	05 00 00 00 30       	add    $0x30000000,%eax
  800373:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800378:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80037d:	5d                   	pop    %ebp
  80037e:	c3                   	ret    

0080037f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80037f:	55                   	push   %ebp
  800380:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800382:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800387:	a8 01                	test   $0x1,%al
  800389:	74 34                	je     8003bf <fd_alloc+0x40>
  80038b:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800390:	a8 01                	test   $0x1,%al
  800392:	74 32                	je     8003c6 <fd_alloc+0x47>
  800394:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800399:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80039b:	89 c2                	mov    %eax,%edx
  80039d:	c1 ea 16             	shr    $0x16,%edx
  8003a0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003a7:	f6 c2 01             	test   $0x1,%dl
  8003aa:	74 1f                	je     8003cb <fd_alloc+0x4c>
  8003ac:	89 c2                	mov    %eax,%edx
  8003ae:	c1 ea 0c             	shr    $0xc,%edx
  8003b1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003b8:	f6 c2 01             	test   $0x1,%dl
  8003bb:	75 1a                	jne    8003d7 <fd_alloc+0x58>
  8003bd:	eb 0c                	jmp    8003cb <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8003bf:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8003c4:	eb 05                	jmp    8003cb <fd_alloc+0x4c>
  8003c6:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8003cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ce:	89 08                	mov    %ecx,(%eax)
			return 0;
  8003d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8003d5:	eb 1a                	jmp    8003f1 <fd_alloc+0x72>
  8003d7:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003dc:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003e1:	75 b6                	jne    800399 <fd_alloc+0x1a>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  8003ec:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003f1:	5d                   	pop    %ebp
  8003f2:	c3                   	ret    

008003f3 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003f3:	55                   	push   %ebp
  8003f4:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003f6:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  8003fa:	77 39                	ja     800435 <fd_lookup+0x42>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ff:	c1 e0 0c             	shl    $0xc,%eax
  800402:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800407:	89 c2                	mov    %eax,%edx
  800409:	c1 ea 16             	shr    $0x16,%edx
  80040c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800413:	f6 c2 01             	test   $0x1,%dl
  800416:	74 24                	je     80043c <fd_lookup+0x49>
  800418:	89 c2                	mov    %eax,%edx
  80041a:	c1 ea 0c             	shr    $0xc,%edx
  80041d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800424:	f6 c2 01             	test   $0x1,%dl
  800427:	74 1a                	je     800443 <fd_lookup+0x50>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800429:	8b 55 0c             	mov    0xc(%ebp),%edx
  80042c:	89 02                	mov    %eax,(%edx)
	return 0;
  80042e:	b8 00 00 00 00       	mov    $0x0,%eax
  800433:	eb 13                	jmp    800448 <fd_lookup+0x55>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800435:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80043a:	eb 0c                	jmp    800448 <fd_lookup+0x55>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80043c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800441:	eb 05                	jmp    800448 <fd_lookup+0x55>
  800443:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800448:	5d                   	pop    %ebp
  800449:	c3                   	ret    

0080044a <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80044a:	55                   	push   %ebp
  80044b:	89 e5                	mov    %esp,%ebp
  80044d:	53                   	push   %ebx
  80044e:	83 ec 04             	sub    $0x4,%esp
  800451:	8b 45 08             	mov    0x8(%ebp),%eax
  800454:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800457:	3b 05 04 30 80 00    	cmp    0x803004,%eax
  80045d:	75 1e                	jne    80047d <dev_lookup+0x33>
  80045f:	eb 0e                	jmp    80046f <dev_lookup+0x25>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800461:	b8 20 30 80 00       	mov    $0x803020,%eax
  800466:	eb 0c                	jmp    800474 <dev_lookup+0x2a>
  800468:	b8 3c 30 80 00       	mov    $0x80303c,%eax
  80046d:	eb 05                	jmp    800474 <dev_lookup+0x2a>
  80046f:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800474:	89 03                	mov    %eax,(%ebx)
			return 0;
  800476:	b8 00 00 00 00       	mov    $0x0,%eax
  80047b:	eb 36                	jmp    8004b3 <dev_lookup+0x69>
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80047d:	3b 05 20 30 80 00    	cmp    0x803020,%eax
  800483:	74 dc                	je     800461 <dev_lookup+0x17>
  800485:	3b 05 3c 30 80 00    	cmp    0x80303c,%eax
  80048b:	74 db                	je     800468 <dev_lookup+0x1e>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80048d:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800493:	8b 52 48             	mov    0x48(%edx),%edx
  800496:	83 ec 04             	sub    $0x4,%esp
  800499:	50                   	push   %eax
  80049a:	52                   	push   %edx
  80049b:	68 78 1e 80 00       	push   $0x801e78
  8004a0:	e8 23 0c 00 00       	call   8010c8 <cprintf>
	*dev = 0;
  8004a5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8004ab:	83 c4 10             	add    $0x10,%esp
  8004ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004b6:	c9                   	leave  
  8004b7:	c3                   	ret    

008004b8 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004b8:	55                   	push   %ebp
  8004b9:	89 e5                	mov    %esp,%ebp
  8004bb:	56                   	push   %esi
  8004bc:	53                   	push   %ebx
  8004bd:	83 ec 10             	sub    $0x10,%esp
  8004c0:	8b 75 08             	mov    0x8(%ebp),%esi
  8004c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004c9:	50                   	push   %eax
  8004ca:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004d0:	c1 e8 0c             	shr    $0xc,%eax
  8004d3:	50                   	push   %eax
  8004d4:	e8 1a ff ff ff       	call   8003f3 <fd_lookup>
  8004d9:	83 c4 08             	add    $0x8,%esp
  8004dc:	85 c0                	test   %eax,%eax
  8004de:	78 05                	js     8004e5 <fd_close+0x2d>
	    || fd != fd2)
  8004e0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004e3:	74 06                	je     8004eb <fd_close+0x33>
		return (must_exist ? r : 0);
  8004e5:	84 db                	test   %bl,%bl
  8004e7:	74 47                	je     800530 <fd_close+0x78>
  8004e9:	eb 4a                	jmp    800535 <fd_close+0x7d>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004eb:	83 ec 08             	sub    $0x8,%esp
  8004ee:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004f1:	50                   	push   %eax
  8004f2:	ff 36                	pushl  (%esi)
  8004f4:	e8 51 ff ff ff       	call   80044a <dev_lookup>
  8004f9:	89 c3                	mov    %eax,%ebx
  8004fb:	83 c4 10             	add    $0x10,%esp
  8004fe:	85 c0                	test   %eax,%eax
  800500:	78 1c                	js     80051e <fd_close+0x66>
		if (dev->dev_close)
  800502:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800505:	8b 40 10             	mov    0x10(%eax),%eax
  800508:	85 c0                	test   %eax,%eax
  80050a:	74 0d                	je     800519 <fd_close+0x61>
			r = (*dev->dev_close)(fd);
  80050c:	83 ec 0c             	sub    $0xc,%esp
  80050f:	56                   	push   %esi
  800510:	ff d0                	call   *%eax
  800512:	89 c3                	mov    %eax,%ebx
  800514:	83 c4 10             	add    $0x10,%esp
  800517:	eb 05                	jmp    80051e <fd_close+0x66>
		else
			r = 0;
  800519:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80051e:	83 ec 08             	sub    $0x8,%esp
  800521:	56                   	push   %esi
  800522:	6a 00                	push   $0x0
  800524:	e8 c3 fc ff ff       	call   8001ec <sys_page_unmap>
	return r;
  800529:	83 c4 10             	add    $0x10,%esp
  80052c:	89 d8                	mov    %ebx,%eax
  80052e:	eb 05                	jmp    800535 <fd_close+0x7d>
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
  800530:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
	return r;
}
  800535:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800538:	5b                   	pop    %ebx
  800539:	5e                   	pop    %esi
  80053a:	5d                   	pop    %ebp
  80053b:	c3                   	ret    

0080053c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80053c:	55                   	push   %ebp
  80053d:	89 e5                	mov    %esp,%ebp
  80053f:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800542:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800545:	50                   	push   %eax
  800546:	ff 75 08             	pushl  0x8(%ebp)
  800549:	e8 a5 fe ff ff       	call   8003f3 <fd_lookup>
  80054e:	83 c4 08             	add    $0x8,%esp
  800551:	85 c0                	test   %eax,%eax
  800553:	78 10                	js     800565 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800555:	83 ec 08             	sub    $0x8,%esp
  800558:	6a 01                	push   $0x1
  80055a:	ff 75 f4             	pushl  -0xc(%ebp)
  80055d:	e8 56 ff ff ff       	call   8004b8 <fd_close>
  800562:	83 c4 10             	add    $0x10,%esp
}
  800565:	c9                   	leave  
  800566:	c3                   	ret    

00800567 <close_all>:

void
close_all(void)
{
  800567:	55                   	push   %ebp
  800568:	89 e5                	mov    %esp,%ebp
  80056a:	53                   	push   %ebx
  80056b:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80056e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800573:	83 ec 0c             	sub    $0xc,%esp
  800576:	53                   	push   %ebx
  800577:	e8 c0 ff ff ff       	call   80053c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80057c:	43                   	inc    %ebx
  80057d:	83 c4 10             	add    $0x10,%esp
  800580:	83 fb 20             	cmp    $0x20,%ebx
  800583:	75 ee                	jne    800573 <close_all+0xc>
		close(i);
}
  800585:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800588:	c9                   	leave  
  800589:	c3                   	ret    

0080058a <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80058a:	55                   	push   %ebp
  80058b:	89 e5                	mov    %esp,%ebp
  80058d:	57                   	push   %edi
  80058e:	56                   	push   %esi
  80058f:	53                   	push   %ebx
  800590:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800593:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800596:	50                   	push   %eax
  800597:	ff 75 08             	pushl  0x8(%ebp)
  80059a:	e8 54 fe ff ff       	call   8003f3 <fd_lookup>
  80059f:	83 c4 08             	add    $0x8,%esp
  8005a2:	85 c0                	test   %eax,%eax
  8005a4:	0f 88 c2 00 00 00    	js     80066c <dup+0xe2>
		return r;
	close(newfdnum);
  8005aa:	83 ec 0c             	sub    $0xc,%esp
  8005ad:	ff 75 0c             	pushl  0xc(%ebp)
  8005b0:	e8 87 ff ff ff       	call   80053c <close>

	newfd = INDEX2FD(newfdnum);
  8005b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005b8:	c1 e3 0c             	shl    $0xc,%ebx
  8005bb:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8005c1:	83 c4 04             	add    $0x4,%esp
  8005c4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005c7:	e8 9c fd ff ff       	call   800368 <fd2data>
  8005cc:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  8005ce:	89 1c 24             	mov    %ebx,(%esp)
  8005d1:	e8 92 fd ff ff       	call   800368 <fd2data>
  8005d6:	83 c4 10             	add    $0x10,%esp
  8005d9:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005db:	89 f0                	mov    %esi,%eax
  8005dd:	c1 e8 16             	shr    $0x16,%eax
  8005e0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005e7:	a8 01                	test   $0x1,%al
  8005e9:	74 35                	je     800620 <dup+0x96>
  8005eb:	89 f0                	mov    %esi,%eax
  8005ed:	c1 e8 0c             	shr    $0xc,%eax
  8005f0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005f7:	f6 c2 01             	test   $0x1,%dl
  8005fa:	74 24                	je     800620 <dup+0x96>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005fc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800603:	83 ec 0c             	sub    $0xc,%esp
  800606:	25 07 0e 00 00       	and    $0xe07,%eax
  80060b:	50                   	push   %eax
  80060c:	57                   	push   %edi
  80060d:	6a 00                	push   $0x0
  80060f:	56                   	push   %esi
  800610:	6a 00                	push   $0x0
  800612:	e8 93 fb ff ff       	call   8001aa <sys_page_map>
  800617:	89 c6                	mov    %eax,%esi
  800619:	83 c4 20             	add    $0x20,%esp
  80061c:	85 c0                	test   %eax,%eax
  80061e:	78 2c                	js     80064c <dup+0xc2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800620:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800623:	89 d0                	mov    %edx,%eax
  800625:	c1 e8 0c             	shr    $0xc,%eax
  800628:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80062f:	83 ec 0c             	sub    $0xc,%esp
  800632:	25 07 0e 00 00       	and    $0xe07,%eax
  800637:	50                   	push   %eax
  800638:	53                   	push   %ebx
  800639:	6a 00                	push   $0x0
  80063b:	52                   	push   %edx
  80063c:	6a 00                	push   $0x0
  80063e:	e8 67 fb ff ff       	call   8001aa <sys_page_map>
  800643:	89 c6                	mov    %eax,%esi
  800645:	83 c4 20             	add    $0x20,%esp
  800648:	85 c0                	test   %eax,%eax
  80064a:	79 1d                	jns    800669 <dup+0xdf>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80064c:	83 ec 08             	sub    $0x8,%esp
  80064f:	53                   	push   %ebx
  800650:	6a 00                	push   $0x0
  800652:	e8 95 fb ff ff       	call   8001ec <sys_page_unmap>
	sys_page_unmap(0, nva);
  800657:	83 c4 08             	add    $0x8,%esp
  80065a:	57                   	push   %edi
  80065b:	6a 00                	push   $0x0
  80065d:	e8 8a fb ff ff       	call   8001ec <sys_page_unmap>
	return r;
  800662:	83 c4 10             	add    $0x10,%esp
  800665:	89 f0                	mov    %esi,%eax
  800667:	eb 03                	jmp    80066c <dup+0xe2>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  800669:	8b 45 0c             	mov    0xc(%ebp),%eax

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80066c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80066f:	5b                   	pop    %ebx
  800670:	5e                   	pop    %esi
  800671:	5f                   	pop    %edi
  800672:	5d                   	pop    %ebp
  800673:	c3                   	ret    

00800674 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800674:	55                   	push   %ebp
  800675:	89 e5                	mov    %esp,%ebp
  800677:	53                   	push   %ebx
  800678:	83 ec 14             	sub    $0x14,%esp
  80067b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80067e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800681:	50                   	push   %eax
  800682:	53                   	push   %ebx
  800683:	e8 6b fd ff ff       	call   8003f3 <fd_lookup>
  800688:	83 c4 08             	add    $0x8,%esp
  80068b:	85 c0                	test   %eax,%eax
  80068d:	78 67                	js     8006f6 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80068f:	83 ec 08             	sub    $0x8,%esp
  800692:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800695:	50                   	push   %eax
  800696:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800699:	ff 30                	pushl  (%eax)
  80069b:	e8 aa fd ff ff       	call   80044a <dev_lookup>
  8006a0:	83 c4 10             	add    $0x10,%esp
  8006a3:	85 c0                	test   %eax,%eax
  8006a5:	78 4f                	js     8006f6 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006a7:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006aa:	8b 42 08             	mov    0x8(%edx),%eax
  8006ad:	83 e0 03             	and    $0x3,%eax
  8006b0:	83 f8 01             	cmp    $0x1,%eax
  8006b3:	75 21                	jne    8006d6 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006b5:	a1 04 40 80 00       	mov    0x804004,%eax
  8006ba:	8b 40 48             	mov    0x48(%eax),%eax
  8006bd:	83 ec 04             	sub    $0x4,%esp
  8006c0:	53                   	push   %ebx
  8006c1:	50                   	push   %eax
  8006c2:	68 b9 1e 80 00       	push   $0x801eb9
  8006c7:	e8 fc 09 00 00       	call   8010c8 <cprintf>
		return -E_INVAL;
  8006cc:	83 c4 10             	add    $0x10,%esp
  8006cf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006d4:	eb 20                	jmp    8006f6 <read+0x82>
	}
	if (!dev->dev_read)
  8006d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006d9:	8b 40 08             	mov    0x8(%eax),%eax
  8006dc:	85 c0                	test   %eax,%eax
  8006de:	74 11                	je     8006f1 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006e0:	83 ec 04             	sub    $0x4,%esp
  8006e3:	ff 75 10             	pushl  0x10(%ebp)
  8006e6:	ff 75 0c             	pushl  0xc(%ebp)
  8006e9:	52                   	push   %edx
  8006ea:	ff d0                	call   *%eax
  8006ec:	83 c4 10             	add    $0x10,%esp
  8006ef:	eb 05                	jmp    8006f6 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006f1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8006f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006f9:	c9                   	leave  
  8006fa:	c3                   	ret    

008006fb <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006fb:	55                   	push   %ebp
  8006fc:	89 e5                	mov    %esp,%ebp
  8006fe:	57                   	push   %edi
  8006ff:	56                   	push   %esi
  800700:	53                   	push   %ebx
  800701:	83 ec 0c             	sub    $0xc,%esp
  800704:	8b 7d 08             	mov    0x8(%ebp),%edi
  800707:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80070a:	85 f6                	test   %esi,%esi
  80070c:	74 31                	je     80073f <readn+0x44>
  80070e:	b8 00 00 00 00       	mov    $0x0,%eax
  800713:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  800718:	83 ec 04             	sub    $0x4,%esp
  80071b:	89 f2                	mov    %esi,%edx
  80071d:	29 c2                	sub    %eax,%edx
  80071f:	52                   	push   %edx
  800720:	03 45 0c             	add    0xc(%ebp),%eax
  800723:	50                   	push   %eax
  800724:	57                   	push   %edi
  800725:	e8 4a ff ff ff       	call   800674 <read>
		if (m < 0)
  80072a:	83 c4 10             	add    $0x10,%esp
  80072d:	85 c0                	test   %eax,%eax
  80072f:	78 17                	js     800748 <readn+0x4d>
			return m;
		if (m == 0)
  800731:	85 c0                	test   %eax,%eax
  800733:	74 11                	je     800746 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800735:	01 c3                	add    %eax,%ebx
  800737:	89 d8                	mov    %ebx,%eax
  800739:	39 f3                	cmp    %esi,%ebx
  80073b:	72 db                	jb     800718 <readn+0x1d>
  80073d:	eb 09                	jmp    800748 <readn+0x4d>
  80073f:	b8 00 00 00 00       	mov    $0x0,%eax
  800744:	eb 02                	jmp    800748 <readn+0x4d>
  800746:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800748:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80074b:	5b                   	pop    %ebx
  80074c:	5e                   	pop    %esi
  80074d:	5f                   	pop    %edi
  80074e:	5d                   	pop    %ebp
  80074f:	c3                   	ret    

00800750 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800750:	55                   	push   %ebp
  800751:	89 e5                	mov    %esp,%ebp
  800753:	53                   	push   %ebx
  800754:	83 ec 14             	sub    $0x14,%esp
  800757:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80075a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80075d:	50                   	push   %eax
  80075e:	53                   	push   %ebx
  80075f:	e8 8f fc ff ff       	call   8003f3 <fd_lookup>
  800764:	83 c4 08             	add    $0x8,%esp
  800767:	85 c0                	test   %eax,%eax
  800769:	78 62                	js     8007cd <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80076b:	83 ec 08             	sub    $0x8,%esp
  80076e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800771:	50                   	push   %eax
  800772:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800775:	ff 30                	pushl  (%eax)
  800777:	e8 ce fc ff ff       	call   80044a <dev_lookup>
  80077c:	83 c4 10             	add    $0x10,%esp
  80077f:	85 c0                	test   %eax,%eax
  800781:	78 4a                	js     8007cd <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800783:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800786:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80078a:	75 21                	jne    8007ad <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80078c:	a1 04 40 80 00       	mov    0x804004,%eax
  800791:	8b 40 48             	mov    0x48(%eax),%eax
  800794:	83 ec 04             	sub    $0x4,%esp
  800797:	53                   	push   %ebx
  800798:	50                   	push   %eax
  800799:	68 d5 1e 80 00       	push   $0x801ed5
  80079e:	e8 25 09 00 00       	call   8010c8 <cprintf>
		return -E_INVAL;
  8007a3:	83 c4 10             	add    $0x10,%esp
  8007a6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007ab:	eb 20                	jmp    8007cd <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007b0:	8b 52 0c             	mov    0xc(%edx),%edx
  8007b3:	85 d2                	test   %edx,%edx
  8007b5:	74 11                	je     8007c8 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007b7:	83 ec 04             	sub    $0x4,%esp
  8007ba:	ff 75 10             	pushl  0x10(%ebp)
  8007bd:	ff 75 0c             	pushl  0xc(%ebp)
  8007c0:	50                   	push   %eax
  8007c1:	ff d2                	call   *%edx
  8007c3:	83 c4 10             	add    $0x10,%esp
  8007c6:	eb 05                	jmp    8007cd <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007c8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8007cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d0:	c9                   	leave  
  8007d1:	c3                   	ret    

008007d2 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007d2:	55                   	push   %ebp
  8007d3:	89 e5                	mov    %esp,%ebp
  8007d5:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007d8:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007db:	50                   	push   %eax
  8007dc:	ff 75 08             	pushl  0x8(%ebp)
  8007df:	e8 0f fc ff ff       	call   8003f3 <fd_lookup>
  8007e4:	83 c4 08             	add    $0x8,%esp
  8007e7:	85 c0                	test   %eax,%eax
  8007e9:	78 0e                	js     8007f9 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007f9:	c9                   	leave  
  8007fa:	c3                   	ret    

008007fb <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	53                   	push   %ebx
  8007ff:	83 ec 14             	sub    $0x14,%esp
  800802:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800805:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800808:	50                   	push   %eax
  800809:	53                   	push   %ebx
  80080a:	e8 e4 fb ff ff       	call   8003f3 <fd_lookup>
  80080f:	83 c4 08             	add    $0x8,%esp
  800812:	85 c0                	test   %eax,%eax
  800814:	78 5f                	js     800875 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800816:	83 ec 08             	sub    $0x8,%esp
  800819:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80081c:	50                   	push   %eax
  80081d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800820:	ff 30                	pushl  (%eax)
  800822:	e8 23 fc ff ff       	call   80044a <dev_lookup>
  800827:	83 c4 10             	add    $0x10,%esp
  80082a:	85 c0                	test   %eax,%eax
  80082c:	78 47                	js     800875 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80082e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800831:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800835:	75 21                	jne    800858 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800837:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80083c:	8b 40 48             	mov    0x48(%eax),%eax
  80083f:	83 ec 04             	sub    $0x4,%esp
  800842:	53                   	push   %ebx
  800843:	50                   	push   %eax
  800844:	68 98 1e 80 00       	push   $0x801e98
  800849:	e8 7a 08 00 00       	call   8010c8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80084e:	83 c4 10             	add    $0x10,%esp
  800851:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800856:	eb 1d                	jmp    800875 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  800858:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80085b:	8b 52 18             	mov    0x18(%edx),%edx
  80085e:	85 d2                	test   %edx,%edx
  800860:	74 0e                	je     800870 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800862:	83 ec 08             	sub    $0x8,%esp
  800865:	ff 75 0c             	pushl  0xc(%ebp)
  800868:	50                   	push   %eax
  800869:	ff d2                	call   *%edx
  80086b:	83 c4 10             	add    $0x10,%esp
  80086e:	eb 05                	jmp    800875 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800870:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  800875:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800878:	c9                   	leave  
  800879:	c3                   	ret    

0080087a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80087a:	55                   	push   %ebp
  80087b:	89 e5                	mov    %esp,%ebp
  80087d:	53                   	push   %ebx
  80087e:	83 ec 14             	sub    $0x14,%esp
  800881:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800884:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800887:	50                   	push   %eax
  800888:	ff 75 08             	pushl  0x8(%ebp)
  80088b:	e8 63 fb ff ff       	call   8003f3 <fd_lookup>
  800890:	83 c4 08             	add    $0x8,%esp
  800893:	85 c0                	test   %eax,%eax
  800895:	78 52                	js     8008e9 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800897:	83 ec 08             	sub    $0x8,%esp
  80089a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80089d:	50                   	push   %eax
  80089e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008a1:	ff 30                	pushl  (%eax)
  8008a3:	e8 a2 fb ff ff       	call   80044a <dev_lookup>
  8008a8:	83 c4 10             	add    $0x10,%esp
  8008ab:	85 c0                	test   %eax,%eax
  8008ad:	78 3a                	js     8008e9 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  8008af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008b2:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008b6:	74 2c                	je     8008e4 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008b8:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008bb:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008c2:	00 00 00 
	stat->st_isdir = 0;
  8008c5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008cc:	00 00 00 
	stat->st_dev = dev;
  8008cf:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008d5:	83 ec 08             	sub    $0x8,%esp
  8008d8:	53                   	push   %ebx
  8008d9:	ff 75 f0             	pushl  -0x10(%ebp)
  8008dc:	ff 50 14             	call   *0x14(%eax)
  8008df:	83 c4 10             	add    $0x10,%esp
  8008e2:	eb 05                	jmp    8008e9 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008e4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008ec:	c9                   	leave  
  8008ed:	c3                   	ret    

008008ee <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008ee:	55                   	push   %ebp
  8008ef:	89 e5                	mov    %esp,%ebp
  8008f1:	56                   	push   %esi
  8008f2:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008f3:	83 ec 08             	sub    $0x8,%esp
  8008f6:	6a 00                	push   $0x0
  8008f8:	ff 75 08             	pushl  0x8(%ebp)
  8008fb:	e8 75 01 00 00       	call   800a75 <open>
  800900:	89 c3                	mov    %eax,%ebx
  800902:	83 c4 10             	add    $0x10,%esp
  800905:	85 c0                	test   %eax,%eax
  800907:	78 1d                	js     800926 <stat+0x38>
		return fd;
	r = fstat(fd, stat);
  800909:	83 ec 08             	sub    $0x8,%esp
  80090c:	ff 75 0c             	pushl  0xc(%ebp)
  80090f:	50                   	push   %eax
  800910:	e8 65 ff ff ff       	call   80087a <fstat>
  800915:	89 c6                	mov    %eax,%esi
	close(fd);
  800917:	89 1c 24             	mov    %ebx,(%esp)
  80091a:	e8 1d fc ff ff       	call   80053c <close>
	return r;
  80091f:	83 c4 10             	add    $0x10,%esp
  800922:	89 f0                	mov    %esi,%eax
  800924:	eb 00                	jmp    800926 <stat+0x38>
}
  800926:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800929:	5b                   	pop    %ebx
  80092a:	5e                   	pop    %esi
  80092b:	5d                   	pop    %ebp
  80092c:	c3                   	ret    

0080092d <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80092d:	55                   	push   %ebp
  80092e:	89 e5                	mov    %esp,%ebp
  800930:	56                   	push   %esi
  800931:	53                   	push   %ebx
  800932:	89 c6                	mov    %eax,%esi
  800934:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800936:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80093d:	75 12                	jne    800951 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80093f:	83 ec 0c             	sub    $0xc,%esp
  800942:	6a 01                	push   $0x1
  800944:	e8 ec 11 00 00       	call   801b35 <ipc_find_env>
  800949:	a3 00 40 80 00       	mov    %eax,0x804000
  80094e:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800951:	6a 07                	push   $0x7
  800953:	68 00 50 80 00       	push   $0x805000
  800958:	56                   	push   %esi
  800959:	ff 35 00 40 80 00    	pushl  0x804000
  80095f:	e8 72 11 00 00       	call   801ad6 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800964:	83 c4 0c             	add    $0xc,%esp
  800967:	6a 00                	push   $0x0
  800969:	53                   	push   %ebx
  80096a:	6a 00                	push   $0x0
  80096c:	e8 f0 10 00 00       	call   801a61 <ipc_recv>
}
  800971:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800974:	5b                   	pop    %ebx
  800975:	5e                   	pop    %esi
  800976:	5d                   	pop    %ebp
  800977:	c3                   	ret    

00800978 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800978:	55                   	push   %ebp
  800979:	89 e5                	mov    %esp,%ebp
  80097b:	53                   	push   %ebx
  80097c:	83 ec 04             	sub    $0x4,%esp
  80097f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800982:	8b 45 08             	mov    0x8(%ebp),%eax
  800985:	8b 40 0c             	mov    0xc(%eax),%eax
  800988:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80098d:	ba 00 00 00 00       	mov    $0x0,%edx
  800992:	b8 05 00 00 00       	mov    $0x5,%eax
  800997:	e8 91 ff ff ff       	call   80092d <fsipc>
  80099c:	85 c0                	test   %eax,%eax
  80099e:	78 2c                	js     8009cc <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009a0:	83 ec 08             	sub    $0x8,%esp
  8009a3:	68 00 50 80 00       	push   $0x805000
  8009a8:	53                   	push   %ebx
  8009a9:	e8 ff 0c 00 00       	call   8016ad <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009ae:	a1 80 50 80 00       	mov    0x805080,%eax
  8009b3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009b9:	a1 84 50 80 00       	mov    0x805084,%eax
  8009be:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009c4:	83 c4 10             	add    $0x10,%esp
  8009c7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009cf:	c9                   	leave  
  8009d0:	c3                   	ret    

008009d1 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009d1:	55                   	push   %ebp
  8009d2:	89 e5                	mov    %esp,%ebp
  8009d4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009da:	8b 40 0c             	mov    0xc(%eax),%eax
  8009dd:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8009e7:	b8 06 00 00 00       	mov    $0x6,%eax
  8009ec:	e8 3c ff ff ff       	call   80092d <fsipc>
}
  8009f1:	c9                   	leave  
  8009f2:	c3                   	ret    

008009f3 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8009f3:	55                   	push   %ebp
  8009f4:	89 e5                	mov    %esp,%ebp
  8009f6:	56                   	push   %esi
  8009f7:	53                   	push   %ebx
  8009f8:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8009fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fe:	8b 40 0c             	mov    0xc(%eax),%eax
  800a01:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a06:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a0c:	ba 00 00 00 00       	mov    $0x0,%edx
  800a11:	b8 03 00 00 00       	mov    $0x3,%eax
  800a16:	e8 12 ff ff ff       	call   80092d <fsipc>
  800a1b:	89 c3                	mov    %eax,%ebx
  800a1d:	85 c0                	test   %eax,%eax
  800a1f:	78 4b                	js     800a6c <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a21:	39 c6                	cmp    %eax,%esi
  800a23:	73 16                	jae    800a3b <devfile_read+0x48>
  800a25:	68 f2 1e 80 00       	push   $0x801ef2
  800a2a:	68 f9 1e 80 00       	push   $0x801ef9
  800a2f:	6a 7a                	push   $0x7a
  800a31:	68 0e 1f 80 00       	push   $0x801f0e
  800a36:	e8 b5 05 00 00       	call   800ff0 <_panic>
	assert(r <= PGSIZE);
  800a3b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a40:	7e 16                	jle    800a58 <devfile_read+0x65>
  800a42:	68 19 1f 80 00       	push   $0x801f19
  800a47:	68 f9 1e 80 00       	push   $0x801ef9
  800a4c:	6a 7b                	push   $0x7b
  800a4e:	68 0e 1f 80 00       	push   $0x801f0e
  800a53:	e8 98 05 00 00       	call   800ff0 <_panic>
	memmove(buf, &fsipcbuf, r);
  800a58:	83 ec 04             	sub    $0x4,%esp
  800a5b:	50                   	push   %eax
  800a5c:	68 00 50 80 00       	push   $0x805000
  800a61:	ff 75 0c             	pushl  0xc(%ebp)
  800a64:	e8 11 0e 00 00       	call   80187a <memmove>
	return r;
  800a69:	83 c4 10             	add    $0x10,%esp
}
  800a6c:	89 d8                	mov    %ebx,%eax
  800a6e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a71:	5b                   	pop    %ebx
  800a72:	5e                   	pop    %esi
  800a73:	5d                   	pop    %ebp
  800a74:	c3                   	ret    

00800a75 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800a75:	55                   	push   %ebp
  800a76:	89 e5                	mov    %esp,%ebp
  800a78:	53                   	push   %ebx
  800a79:	83 ec 20             	sub    $0x20,%esp
  800a7c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800a7f:	53                   	push   %ebx
  800a80:	e8 d1 0b 00 00       	call   801656 <strlen>
  800a85:	83 c4 10             	add    $0x10,%esp
  800a88:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800a8d:	7f 63                	jg     800af2 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800a8f:	83 ec 0c             	sub    $0xc,%esp
  800a92:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a95:	50                   	push   %eax
  800a96:	e8 e4 f8 ff ff       	call   80037f <fd_alloc>
  800a9b:	83 c4 10             	add    $0x10,%esp
  800a9e:	85 c0                	test   %eax,%eax
  800aa0:	78 55                	js     800af7 <open+0x82>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800aa2:	83 ec 08             	sub    $0x8,%esp
  800aa5:	53                   	push   %ebx
  800aa6:	68 00 50 80 00       	push   $0x805000
  800aab:	e8 fd 0b 00 00       	call   8016ad <strcpy>
	fsipcbuf.open.req_omode = mode;
  800ab0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab3:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800ab8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800abb:	b8 01 00 00 00       	mov    $0x1,%eax
  800ac0:	e8 68 fe ff ff       	call   80092d <fsipc>
  800ac5:	89 c3                	mov    %eax,%ebx
  800ac7:	83 c4 10             	add    $0x10,%esp
  800aca:	85 c0                	test   %eax,%eax
  800acc:	79 14                	jns    800ae2 <open+0x6d>
		fd_close(fd, 0);
  800ace:	83 ec 08             	sub    $0x8,%esp
  800ad1:	6a 00                	push   $0x0
  800ad3:	ff 75 f4             	pushl  -0xc(%ebp)
  800ad6:	e8 dd f9 ff ff       	call   8004b8 <fd_close>
		return r;
  800adb:	83 c4 10             	add    $0x10,%esp
  800ade:	89 d8                	mov    %ebx,%eax
  800ae0:	eb 15                	jmp    800af7 <open+0x82>
	}

	return fd2num(fd);
  800ae2:	83 ec 0c             	sub    $0xc,%esp
  800ae5:	ff 75 f4             	pushl  -0xc(%ebp)
  800ae8:	e8 6b f8 ff ff       	call   800358 <fd2num>
  800aed:	83 c4 10             	add    $0x10,%esp
  800af0:	eb 05                	jmp    800af7 <open+0x82>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800af2:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800af7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800afa:	c9                   	leave  
  800afb:	c3                   	ret    

00800afc <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800afc:	55                   	push   %ebp
  800afd:	89 e5                	mov    %esp,%ebp
  800aff:	56                   	push   %esi
  800b00:	53                   	push   %ebx
  800b01:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b04:	83 ec 0c             	sub    $0xc,%esp
  800b07:	ff 75 08             	pushl  0x8(%ebp)
  800b0a:	e8 59 f8 ff ff       	call   800368 <fd2data>
  800b0f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b11:	83 c4 08             	add    $0x8,%esp
  800b14:	68 25 1f 80 00       	push   $0x801f25
  800b19:	53                   	push   %ebx
  800b1a:	e8 8e 0b 00 00       	call   8016ad <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b1f:	8b 46 04             	mov    0x4(%esi),%eax
  800b22:	2b 06                	sub    (%esi),%eax
  800b24:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b2a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b31:	00 00 00 
	stat->st_dev = &devpipe;
  800b34:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800b3b:	30 80 00 
	return 0;
}
  800b3e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b43:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b46:	5b                   	pop    %ebx
  800b47:	5e                   	pop    %esi
  800b48:	5d                   	pop    %ebp
  800b49:	c3                   	ret    

00800b4a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b4a:	55                   	push   %ebp
  800b4b:	89 e5                	mov    %esp,%ebp
  800b4d:	53                   	push   %ebx
  800b4e:	83 ec 0c             	sub    $0xc,%esp
  800b51:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800b54:	53                   	push   %ebx
  800b55:	6a 00                	push   $0x0
  800b57:	e8 90 f6 ff ff       	call   8001ec <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800b5c:	89 1c 24             	mov    %ebx,(%esp)
  800b5f:	e8 04 f8 ff ff       	call   800368 <fd2data>
  800b64:	83 c4 08             	add    $0x8,%esp
  800b67:	50                   	push   %eax
  800b68:	6a 00                	push   $0x0
  800b6a:	e8 7d f6 ff ff       	call   8001ec <sys_page_unmap>
}
  800b6f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b72:	c9                   	leave  
  800b73:	c3                   	ret    

00800b74 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800b74:	55                   	push   %ebp
  800b75:	89 e5                	mov    %esp,%ebp
  800b77:	57                   	push   %edi
  800b78:	56                   	push   %esi
  800b79:	53                   	push   %ebx
  800b7a:	83 ec 1c             	sub    $0x1c,%esp
  800b7d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b80:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800b82:	a1 04 40 80 00       	mov    0x804004,%eax
  800b87:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800b8a:	83 ec 0c             	sub    $0xc,%esp
  800b8d:	ff 75 e0             	pushl  -0x20(%ebp)
  800b90:	e8 fb 0f 00 00       	call   801b90 <pageref>
  800b95:	89 c3                	mov    %eax,%ebx
  800b97:	89 3c 24             	mov    %edi,(%esp)
  800b9a:	e8 f1 0f 00 00       	call   801b90 <pageref>
  800b9f:	83 c4 10             	add    $0x10,%esp
  800ba2:	39 c3                	cmp    %eax,%ebx
  800ba4:	0f 94 c1             	sete   %cl
  800ba7:	0f b6 c9             	movzbl %cl,%ecx
  800baa:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800bad:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800bb3:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800bb6:	39 ce                	cmp    %ecx,%esi
  800bb8:	74 1b                	je     800bd5 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800bba:	39 c3                	cmp    %eax,%ebx
  800bbc:	75 c4                	jne    800b82 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800bbe:	8b 42 58             	mov    0x58(%edx),%eax
  800bc1:	ff 75 e4             	pushl  -0x1c(%ebp)
  800bc4:	50                   	push   %eax
  800bc5:	56                   	push   %esi
  800bc6:	68 2c 1f 80 00       	push   $0x801f2c
  800bcb:	e8 f8 04 00 00       	call   8010c8 <cprintf>
  800bd0:	83 c4 10             	add    $0x10,%esp
  800bd3:	eb ad                	jmp    800b82 <_pipeisclosed+0xe>
	}
}
  800bd5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800bd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bdb:	5b                   	pop    %ebx
  800bdc:	5e                   	pop    %esi
  800bdd:	5f                   	pop    %edi
  800bde:	5d                   	pop    %ebp
  800bdf:	c3                   	ret    

00800be0 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800be0:	55                   	push   %ebp
  800be1:	89 e5                	mov    %esp,%ebp
  800be3:	57                   	push   %edi
  800be4:	56                   	push   %esi
  800be5:	53                   	push   %ebx
  800be6:	83 ec 18             	sub    $0x18,%esp
  800be9:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800bec:	56                   	push   %esi
  800bed:	e8 76 f7 ff ff       	call   800368 <fd2data>
  800bf2:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800bf4:	83 c4 10             	add    $0x10,%esp
  800bf7:	bf 00 00 00 00       	mov    $0x0,%edi
  800bfc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c00:	75 42                	jne    800c44 <devpipe_write+0x64>
  800c02:	eb 4e                	jmp    800c52 <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c04:	89 da                	mov    %ebx,%edx
  800c06:	89 f0                	mov    %esi,%eax
  800c08:	e8 67 ff ff ff       	call   800b74 <_pipeisclosed>
  800c0d:	85 c0                	test   %eax,%eax
  800c0f:	75 46                	jne    800c57 <devpipe_write+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c11:	e8 32 f5 ff ff       	call   800148 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c16:	8b 53 04             	mov    0x4(%ebx),%edx
  800c19:	8b 03                	mov    (%ebx),%eax
  800c1b:	83 c0 20             	add    $0x20,%eax
  800c1e:	39 c2                	cmp    %eax,%edx
  800c20:	73 e2                	jae    800c04 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c22:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c25:	8a 0c 38             	mov    (%eax,%edi,1),%cl
  800c28:	89 d0                	mov    %edx,%eax
  800c2a:	25 1f 00 00 80       	and    $0x8000001f,%eax
  800c2f:	79 05                	jns    800c36 <devpipe_write+0x56>
  800c31:	48                   	dec    %eax
  800c32:	83 c8 e0             	or     $0xffffffe0,%eax
  800c35:	40                   	inc    %eax
  800c36:	88 4c 03 08          	mov    %cl,0x8(%ebx,%eax,1)
		p->p_wpos++;
  800c3a:	42                   	inc    %edx
  800c3b:	89 53 04             	mov    %edx,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c3e:	47                   	inc    %edi
  800c3f:	39 7d 10             	cmp    %edi,0x10(%ebp)
  800c42:	74 0e                	je     800c52 <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c44:	8b 53 04             	mov    0x4(%ebx),%edx
  800c47:	8b 03                	mov    (%ebx),%eax
  800c49:	83 c0 20             	add    $0x20,%eax
  800c4c:	39 c2                	cmp    %eax,%edx
  800c4e:	73 b4                	jae    800c04 <devpipe_write+0x24>
  800c50:	eb d0                	jmp    800c22 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800c52:	8b 45 10             	mov    0x10(%ebp),%eax
  800c55:	eb 05                	jmp    800c5c <devpipe_write+0x7c>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800c57:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800c5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5f:	5b                   	pop    %ebx
  800c60:	5e                   	pop    %esi
  800c61:	5f                   	pop    %edi
  800c62:	5d                   	pop    %ebp
  800c63:	c3                   	ret    

00800c64 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800c64:	55                   	push   %ebp
  800c65:	89 e5                	mov    %esp,%ebp
  800c67:	57                   	push   %edi
  800c68:	56                   	push   %esi
  800c69:	53                   	push   %ebx
  800c6a:	83 ec 18             	sub    $0x18,%esp
  800c6d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800c70:	57                   	push   %edi
  800c71:	e8 f2 f6 ff ff       	call   800368 <fd2data>
  800c76:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c78:	83 c4 10             	add    $0x10,%esp
  800c7b:	be 00 00 00 00       	mov    $0x0,%esi
  800c80:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c84:	75 3d                	jne    800cc3 <devpipe_read+0x5f>
  800c86:	eb 48                	jmp    800cd0 <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  800c88:	89 f0                	mov    %esi,%eax
  800c8a:	eb 4e                	jmp    800cda <devpipe_read+0x76>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800c8c:	89 da                	mov    %ebx,%edx
  800c8e:	89 f8                	mov    %edi,%eax
  800c90:	e8 df fe ff ff       	call   800b74 <_pipeisclosed>
  800c95:	85 c0                	test   %eax,%eax
  800c97:	75 3c                	jne    800cd5 <devpipe_read+0x71>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800c99:	e8 aa f4 ff ff       	call   800148 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800c9e:	8b 03                	mov    (%ebx),%eax
  800ca0:	3b 43 04             	cmp    0x4(%ebx),%eax
  800ca3:	74 e7                	je     800c8c <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800ca5:	25 1f 00 00 80       	and    $0x8000001f,%eax
  800caa:	79 05                	jns    800cb1 <devpipe_read+0x4d>
  800cac:	48                   	dec    %eax
  800cad:	83 c8 e0             	or     $0xffffffe0,%eax
  800cb0:	40                   	inc    %eax
  800cb1:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  800cb5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb8:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800cbb:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cbd:	46                   	inc    %esi
  800cbe:	39 75 10             	cmp    %esi,0x10(%ebp)
  800cc1:	74 0d                	je     800cd0 <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
  800cc3:	8b 03                	mov    (%ebx),%eax
  800cc5:	3b 43 04             	cmp    0x4(%ebx),%eax
  800cc8:	75 db                	jne    800ca5 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800cca:	85 f6                	test   %esi,%esi
  800ccc:	75 ba                	jne    800c88 <devpipe_read+0x24>
  800cce:	eb bc                	jmp    800c8c <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800cd0:	8b 45 10             	mov    0x10(%ebp),%eax
  800cd3:	eb 05                	jmp    800cda <devpipe_read+0x76>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cd5:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800cda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cdd:	5b                   	pop    %ebx
  800cde:	5e                   	pop    %esi
  800cdf:	5f                   	pop    %edi
  800ce0:	5d                   	pop    %ebp
  800ce1:	c3                   	ret    

00800ce2 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800ce2:	55                   	push   %ebp
  800ce3:	89 e5                	mov    %esp,%ebp
  800ce5:	56                   	push   %esi
  800ce6:	53                   	push   %ebx
  800ce7:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800cea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ced:	50                   	push   %eax
  800cee:	e8 8c f6 ff ff       	call   80037f <fd_alloc>
  800cf3:	83 c4 10             	add    $0x10,%esp
  800cf6:	85 c0                	test   %eax,%eax
  800cf8:	0f 88 2a 01 00 00    	js     800e28 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800cfe:	83 ec 04             	sub    $0x4,%esp
  800d01:	68 07 04 00 00       	push   $0x407
  800d06:	ff 75 f4             	pushl  -0xc(%ebp)
  800d09:	6a 00                	push   $0x0
  800d0b:	e8 57 f4 ff ff       	call   800167 <sys_page_alloc>
  800d10:	83 c4 10             	add    $0x10,%esp
  800d13:	85 c0                	test   %eax,%eax
  800d15:	0f 88 0d 01 00 00    	js     800e28 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d1b:	83 ec 0c             	sub    $0xc,%esp
  800d1e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d21:	50                   	push   %eax
  800d22:	e8 58 f6 ff ff       	call   80037f <fd_alloc>
  800d27:	89 c3                	mov    %eax,%ebx
  800d29:	83 c4 10             	add    $0x10,%esp
  800d2c:	85 c0                	test   %eax,%eax
  800d2e:	0f 88 e2 00 00 00    	js     800e16 <pipe+0x134>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d34:	83 ec 04             	sub    $0x4,%esp
  800d37:	68 07 04 00 00       	push   $0x407
  800d3c:	ff 75 f0             	pushl  -0x10(%ebp)
  800d3f:	6a 00                	push   $0x0
  800d41:	e8 21 f4 ff ff       	call   800167 <sys_page_alloc>
  800d46:	89 c3                	mov    %eax,%ebx
  800d48:	83 c4 10             	add    $0x10,%esp
  800d4b:	85 c0                	test   %eax,%eax
  800d4d:	0f 88 c3 00 00 00    	js     800e16 <pipe+0x134>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800d53:	83 ec 0c             	sub    $0xc,%esp
  800d56:	ff 75 f4             	pushl  -0xc(%ebp)
  800d59:	e8 0a f6 ff ff       	call   800368 <fd2data>
  800d5e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d60:	83 c4 0c             	add    $0xc,%esp
  800d63:	68 07 04 00 00       	push   $0x407
  800d68:	50                   	push   %eax
  800d69:	6a 00                	push   $0x0
  800d6b:	e8 f7 f3 ff ff       	call   800167 <sys_page_alloc>
  800d70:	89 c3                	mov    %eax,%ebx
  800d72:	83 c4 10             	add    $0x10,%esp
  800d75:	85 c0                	test   %eax,%eax
  800d77:	0f 88 89 00 00 00    	js     800e06 <pipe+0x124>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d7d:	83 ec 0c             	sub    $0xc,%esp
  800d80:	ff 75 f0             	pushl  -0x10(%ebp)
  800d83:	e8 e0 f5 ff ff       	call   800368 <fd2data>
  800d88:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800d8f:	50                   	push   %eax
  800d90:	6a 00                	push   $0x0
  800d92:	56                   	push   %esi
  800d93:	6a 00                	push   $0x0
  800d95:	e8 10 f4 ff ff       	call   8001aa <sys_page_map>
  800d9a:	89 c3                	mov    %eax,%ebx
  800d9c:	83 c4 20             	add    $0x20,%esp
  800d9f:	85 c0                	test   %eax,%eax
  800da1:	78 55                	js     800df8 <pipe+0x116>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800da3:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800da9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dac:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800dae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800db1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800db8:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800dbe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dc1:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800dc3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dc6:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800dcd:	83 ec 0c             	sub    $0xc,%esp
  800dd0:	ff 75 f4             	pushl  -0xc(%ebp)
  800dd3:	e8 80 f5 ff ff       	call   800358 <fd2num>
  800dd8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ddb:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800ddd:	83 c4 04             	add    $0x4,%esp
  800de0:	ff 75 f0             	pushl  -0x10(%ebp)
  800de3:	e8 70 f5 ff ff       	call   800358 <fd2num>
  800de8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800deb:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800dee:	83 c4 10             	add    $0x10,%esp
  800df1:	b8 00 00 00 00       	mov    $0x0,%eax
  800df6:	eb 30                	jmp    800e28 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  800df8:	83 ec 08             	sub    $0x8,%esp
  800dfb:	56                   	push   %esi
  800dfc:	6a 00                	push   $0x0
  800dfe:	e8 e9 f3 ff ff       	call   8001ec <sys_page_unmap>
  800e03:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e06:	83 ec 08             	sub    $0x8,%esp
  800e09:	ff 75 f0             	pushl  -0x10(%ebp)
  800e0c:	6a 00                	push   $0x0
  800e0e:	e8 d9 f3 ff ff       	call   8001ec <sys_page_unmap>
  800e13:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e16:	83 ec 08             	sub    $0x8,%esp
  800e19:	ff 75 f4             	pushl  -0xc(%ebp)
  800e1c:	6a 00                	push   $0x0
  800e1e:	e8 c9 f3 ff ff       	call   8001ec <sys_page_unmap>
  800e23:	83 c4 10             	add    $0x10,%esp
  800e26:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  800e28:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e2b:	5b                   	pop    %ebx
  800e2c:	5e                   	pop    %esi
  800e2d:	5d                   	pop    %ebp
  800e2e:	c3                   	ret    

00800e2f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e2f:	55                   	push   %ebp
  800e30:	89 e5                	mov    %esp,%ebp
  800e32:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e35:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e38:	50                   	push   %eax
  800e39:	ff 75 08             	pushl  0x8(%ebp)
  800e3c:	e8 b2 f5 ff ff       	call   8003f3 <fd_lookup>
  800e41:	83 c4 10             	add    $0x10,%esp
  800e44:	85 c0                	test   %eax,%eax
  800e46:	78 18                	js     800e60 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800e48:	83 ec 0c             	sub    $0xc,%esp
  800e4b:	ff 75 f4             	pushl  -0xc(%ebp)
  800e4e:	e8 15 f5 ff ff       	call   800368 <fd2data>
	return _pipeisclosed(fd, p);
  800e53:	89 c2                	mov    %eax,%edx
  800e55:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e58:	e8 17 fd ff ff       	call   800b74 <_pipeisclosed>
  800e5d:	83 c4 10             	add    $0x10,%esp
}
  800e60:	c9                   	leave  
  800e61:	c3                   	ret    

00800e62 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800e62:	55                   	push   %ebp
  800e63:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800e65:	b8 00 00 00 00       	mov    $0x0,%eax
  800e6a:	5d                   	pop    %ebp
  800e6b:	c3                   	ret    

00800e6c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800e6c:	55                   	push   %ebp
  800e6d:	89 e5                	mov    %esp,%ebp
  800e6f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800e72:	68 44 1f 80 00       	push   $0x801f44
  800e77:	ff 75 0c             	pushl  0xc(%ebp)
  800e7a:	e8 2e 08 00 00       	call   8016ad <strcpy>
	return 0;
}
  800e7f:	b8 00 00 00 00       	mov    $0x0,%eax
  800e84:	c9                   	leave  
  800e85:	c3                   	ret    

00800e86 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800e86:	55                   	push   %ebp
  800e87:	89 e5                	mov    %esp,%ebp
  800e89:	57                   	push   %edi
  800e8a:	56                   	push   %esi
  800e8b:	53                   	push   %ebx
  800e8c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800e92:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e96:	74 45                	je     800edd <devcons_write+0x57>
  800e98:	b8 00 00 00 00       	mov    $0x0,%eax
  800e9d:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800ea2:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800ea8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eab:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  800ead:	83 fb 7f             	cmp    $0x7f,%ebx
  800eb0:	76 05                	jbe    800eb7 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  800eb2:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800eb7:	83 ec 04             	sub    $0x4,%esp
  800eba:	53                   	push   %ebx
  800ebb:	03 45 0c             	add    0xc(%ebp),%eax
  800ebe:	50                   	push   %eax
  800ebf:	57                   	push   %edi
  800ec0:	e8 b5 09 00 00       	call   80187a <memmove>
		sys_cputs(buf, m);
  800ec5:	83 c4 08             	add    $0x8,%esp
  800ec8:	53                   	push   %ebx
  800ec9:	57                   	push   %edi
  800eca:	e8 dc f1 ff ff       	call   8000ab <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ecf:	01 de                	add    %ebx,%esi
  800ed1:	89 f0                	mov    %esi,%eax
  800ed3:	83 c4 10             	add    $0x10,%esp
  800ed6:	3b 75 10             	cmp    0x10(%ebp),%esi
  800ed9:	72 cd                	jb     800ea8 <devcons_write+0x22>
  800edb:	eb 05                	jmp    800ee2 <devcons_write+0x5c>
  800edd:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800ee2:	89 f0                	mov    %esi,%eax
  800ee4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ee7:	5b                   	pop    %ebx
  800ee8:	5e                   	pop    %esi
  800ee9:	5f                   	pop    %edi
  800eea:	5d                   	pop    %ebp
  800eeb:	c3                   	ret    

00800eec <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800eec:	55                   	push   %ebp
  800eed:	89 e5                	mov    %esp,%ebp
  800eef:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  800ef2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ef6:	75 07                	jne    800eff <devcons_read+0x13>
  800ef8:	eb 23                	jmp    800f1d <devcons_read+0x31>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800efa:	e8 49 f2 ff ff       	call   800148 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800eff:	e8 c5 f1 ff ff       	call   8000c9 <sys_cgetc>
  800f04:	85 c0                	test   %eax,%eax
  800f06:	74 f2                	je     800efa <devcons_read+0xe>
		sys_yield();
	if (c < 0)
  800f08:	85 c0                	test   %eax,%eax
  800f0a:	78 1d                	js     800f29 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f0c:	83 f8 04             	cmp    $0x4,%eax
  800f0f:	74 13                	je     800f24 <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  800f11:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f14:	88 02                	mov    %al,(%edx)
	return 1;
  800f16:	b8 01 00 00 00       	mov    $0x1,%eax
  800f1b:	eb 0c                	jmp    800f29 <devcons_read+0x3d>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  800f1d:	b8 00 00 00 00       	mov    $0x0,%eax
  800f22:	eb 05                	jmp    800f29 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f24:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f29:	c9                   	leave  
  800f2a:	c3                   	ret    

00800f2b <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f2b:	55                   	push   %ebp
  800f2c:	89 e5                	mov    %esp,%ebp
  800f2e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f31:	8b 45 08             	mov    0x8(%ebp),%eax
  800f34:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f37:	6a 01                	push   $0x1
  800f39:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f3c:	50                   	push   %eax
  800f3d:	e8 69 f1 ff ff       	call   8000ab <sys_cputs>
}
  800f42:	83 c4 10             	add    $0x10,%esp
  800f45:	c9                   	leave  
  800f46:	c3                   	ret    

00800f47 <getchar>:

int
getchar(void)
{
  800f47:	55                   	push   %ebp
  800f48:	89 e5                	mov    %esp,%ebp
  800f4a:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f4d:	6a 01                	push   $0x1
  800f4f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f52:	50                   	push   %eax
  800f53:	6a 00                	push   $0x0
  800f55:	e8 1a f7 ff ff       	call   800674 <read>
	if (r < 0)
  800f5a:	83 c4 10             	add    $0x10,%esp
  800f5d:	85 c0                	test   %eax,%eax
  800f5f:	78 0f                	js     800f70 <getchar+0x29>
		return r;
	if (r < 1)
  800f61:	85 c0                	test   %eax,%eax
  800f63:	7e 06                	jle    800f6b <getchar+0x24>
		return -E_EOF;
	return c;
  800f65:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800f69:	eb 05                	jmp    800f70 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800f6b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800f70:	c9                   	leave  
  800f71:	c3                   	ret    

00800f72 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800f72:	55                   	push   %ebp
  800f73:	89 e5                	mov    %esp,%ebp
  800f75:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f78:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f7b:	50                   	push   %eax
  800f7c:	ff 75 08             	pushl  0x8(%ebp)
  800f7f:	e8 6f f4 ff ff       	call   8003f3 <fd_lookup>
  800f84:	83 c4 10             	add    $0x10,%esp
  800f87:	85 c0                	test   %eax,%eax
  800f89:	78 11                	js     800f9c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800f8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f8e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800f94:	39 10                	cmp    %edx,(%eax)
  800f96:	0f 94 c0             	sete   %al
  800f99:	0f b6 c0             	movzbl %al,%eax
}
  800f9c:	c9                   	leave  
  800f9d:	c3                   	ret    

00800f9e <opencons>:

int
opencons(void)
{
  800f9e:	55                   	push   %ebp
  800f9f:	89 e5                	mov    %esp,%ebp
  800fa1:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fa4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fa7:	50                   	push   %eax
  800fa8:	e8 d2 f3 ff ff       	call   80037f <fd_alloc>
  800fad:	83 c4 10             	add    $0x10,%esp
  800fb0:	85 c0                	test   %eax,%eax
  800fb2:	78 3a                	js     800fee <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fb4:	83 ec 04             	sub    $0x4,%esp
  800fb7:	68 07 04 00 00       	push   $0x407
  800fbc:	ff 75 f4             	pushl  -0xc(%ebp)
  800fbf:	6a 00                	push   $0x0
  800fc1:	e8 a1 f1 ff ff       	call   800167 <sys_page_alloc>
  800fc6:	83 c4 10             	add    $0x10,%esp
  800fc9:	85 c0                	test   %eax,%eax
  800fcb:	78 21                	js     800fee <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800fcd:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fd6:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800fd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fdb:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800fe2:	83 ec 0c             	sub    $0xc,%esp
  800fe5:	50                   	push   %eax
  800fe6:	e8 6d f3 ff ff       	call   800358 <fd2num>
  800feb:	83 c4 10             	add    $0x10,%esp
}
  800fee:	c9                   	leave  
  800fef:	c3                   	ret    

00800ff0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800ff0:	55                   	push   %ebp
  800ff1:	89 e5                	mov    %esp,%ebp
  800ff3:	56                   	push   %esi
  800ff4:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800ff5:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800ff8:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800ffe:	e8 26 f1 ff ff       	call   800129 <sys_getenvid>
  801003:	83 ec 0c             	sub    $0xc,%esp
  801006:	ff 75 0c             	pushl  0xc(%ebp)
  801009:	ff 75 08             	pushl  0x8(%ebp)
  80100c:	56                   	push   %esi
  80100d:	50                   	push   %eax
  80100e:	68 50 1f 80 00       	push   $0x801f50
  801013:	e8 b0 00 00 00       	call   8010c8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801018:	83 c4 18             	add    $0x18,%esp
  80101b:	53                   	push   %ebx
  80101c:	ff 75 10             	pushl  0x10(%ebp)
  80101f:	e8 53 00 00 00       	call   801077 <vcprintf>
	cprintf("\n");
  801024:	c7 04 24 3d 1f 80 00 	movl   $0x801f3d,(%esp)
  80102b:	e8 98 00 00 00       	call   8010c8 <cprintf>
  801030:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801033:	cc                   	int3   
  801034:	eb fd                	jmp    801033 <_panic+0x43>

00801036 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801036:	55                   	push   %ebp
  801037:	89 e5                	mov    %esp,%ebp
  801039:	53                   	push   %ebx
  80103a:	83 ec 04             	sub    $0x4,%esp
  80103d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801040:	8b 13                	mov    (%ebx),%edx
  801042:	8d 42 01             	lea    0x1(%edx),%eax
  801045:	89 03                	mov    %eax,(%ebx)
  801047:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80104a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80104e:	3d ff 00 00 00       	cmp    $0xff,%eax
  801053:	75 1a                	jne    80106f <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801055:	83 ec 08             	sub    $0x8,%esp
  801058:	68 ff 00 00 00       	push   $0xff
  80105d:	8d 43 08             	lea    0x8(%ebx),%eax
  801060:	50                   	push   %eax
  801061:	e8 45 f0 ff ff       	call   8000ab <sys_cputs>
		b->idx = 0;
  801066:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80106c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80106f:	ff 43 04             	incl   0x4(%ebx)
}
  801072:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801075:	c9                   	leave  
  801076:	c3                   	ret    

00801077 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801077:	55                   	push   %ebp
  801078:	89 e5                	mov    %esp,%ebp
  80107a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801080:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801087:	00 00 00 
	b.cnt = 0;
  80108a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801091:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801094:	ff 75 0c             	pushl  0xc(%ebp)
  801097:	ff 75 08             	pushl  0x8(%ebp)
  80109a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010a0:	50                   	push   %eax
  8010a1:	68 36 10 80 00       	push   $0x801036
  8010a6:	e8 54 01 00 00       	call   8011ff <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010ab:	83 c4 08             	add    $0x8,%esp
  8010ae:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010b4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010ba:	50                   	push   %eax
  8010bb:	e8 eb ef ff ff       	call   8000ab <sys_cputs>

	return b.cnt;
}
  8010c0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8010c6:	c9                   	leave  
  8010c7:	c3                   	ret    

008010c8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8010c8:	55                   	push   %ebp
  8010c9:	89 e5                	mov    %esp,%ebp
  8010cb:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8010ce:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8010d1:	50                   	push   %eax
  8010d2:	ff 75 08             	pushl  0x8(%ebp)
  8010d5:	e8 9d ff ff ff       	call   801077 <vcprintf>
	va_end(ap);

	return cnt;
}
  8010da:	c9                   	leave  
  8010db:	c3                   	ret    

008010dc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8010dc:	55                   	push   %ebp
  8010dd:	89 e5                	mov    %esp,%ebp
  8010df:	57                   	push   %edi
  8010e0:	56                   	push   %esi
  8010e1:	53                   	push   %ebx
  8010e2:	83 ec 1c             	sub    $0x1c,%esp
  8010e5:	89 c6                	mov    %eax,%esi
  8010e7:	89 d7                	mov    %edx,%edi
  8010e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010ef:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8010f2:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8010f5:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8010f8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010fd:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801100:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801103:	39 d3                	cmp    %edx,%ebx
  801105:	72 11                	jb     801118 <printnum+0x3c>
  801107:	39 45 10             	cmp    %eax,0x10(%ebp)
  80110a:	76 0c                	jbe    801118 <printnum+0x3c>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80110c:	8b 45 14             	mov    0x14(%ebp),%eax
  80110f:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801112:	85 db                	test   %ebx,%ebx
  801114:	7f 37                	jg     80114d <printnum+0x71>
  801116:	eb 44                	jmp    80115c <printnum+0x80>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801118:	83 ec 0c             	sub    $0xc,%esp
  80111b:	ff 75 18             	pushl  0x18(%ebp)
  80111e:	8b 45 14             	mov    0x14(%ebp),%eax
  801121:	48                   	dec    %eax
  801122:	50                   	push   %eax
  801123:	ff 75 10             	pushl  0x10(%ebp)
  801126:	83 ec 08             	sub    $0x8,%esp
  801129:	ff 75 e4             	pushl  -0x1c(%ebp)
  80112c:	ff 75 e0             	pushl  -0x20(%ebp)
  80112f:	ff 75 dc             	pushl  -0x24(%ebp)
  801132:	ff 75 d8             	pushl  -0x28(%ebp)
  801135:	e8 9a 0a 00 00       	call   801bd4 <__udivdi3>
  80113a:	83 c4 18             	add    $0x18,%esp
  80113d:	52                   	push   %edx
  80113e:	50                   	push   %eax
  80113f:	89 fa                	mov    %edi,%edx
  801141:	89 f0                	mov    %esi,%eax
  801143:	e8 94 ff ff ff       	call   8010dc <printnum>
  801148:	83 c4 20             	add    $0x20,%esp
  80114b:	eb 0f                	jmp    80115c <printnum+0x80>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80114d:	83 ec 08             	sub    $0x8,%esp
  801150:	57                   	push   %edi
  801151:	ff 75 18             	pushl  0x18(%ebp)
  801154:	ff d6                	call   *%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801156:	83 c4 10             	add    $0x10,%esp
  801159:	4b                   	dec    %ebx
  80115a:	75 f1                	jne    80114d <printnum+0x71>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80115c:	83 ec 08             	sub    $0x8,%esp
  80115f:	57                   	push   %edi
  801160:	83 ec 04             	sub    $0x4,%esp
  801163:	ff 75 e4             	pushl  -0x1c(%ebp)
  801166:	ff 75 e0             	pushl  -0x20(%ebp)
  801169:	ff 75 dc             	pushl  -0x24(%ebp)
  80116c:	ff 75 d8             	pushl  -0x28(%ebp)
  80116f:	e8 70 0b 00 00       	call   801ce4 <__umoddi3>
  801174:	83 c4 14             	add    $0x14,%esp
  801177:	0f be 80 73 1f 80 00 	movsbl 0x801f73(%eax),%eax
  80117e:	50                   	push   %eax
  80117f:	ff d6                	call   *%esi
}
  801181:	83 c4 10             	add    $0x10,%esp
  801184:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801187:	5b                   	pop    %ebx
  801188:	5e                   	pop    %esi
  801189:	5f                   	pop    %edi
  80118a:	5d                   	pop    %ebp
  80118b:	c3                   	ret    

0080118c <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80118c:	55                   	push   %ebp
  80118d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80118f:	83 fa 01             	cmp    $0x1,%edx
  801192:	7e 0e                	jle    8011a2 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801194:	8b 10                	mov    (%eax),%edx
  801196:	8d 4a 08             	lea    0x8(%edx),%ecx
  801199:	89 08                	mov    %ecx,(%eax)
  80119b:	8b 02                	mov    (%edx),%eax
  80119d:	8b 52 04             	mov    0x4(%edx),%edx
  8011a0:	eb 22                	jmp    8011c4 <getuint+0x38>
	else if (lflag)
  8011a2:	85 d2                	test   %edx,%edx
  8011a4:	74 10                	je     8011b6 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8011a6:	8b 10                	mov    (%eax),%edx
  8011a8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011ab:	89 08                	mov    %ecx,(%eax)
  8011ad:	8b 02                	mov    (%edx),%eax
  8011af:	ba 00 00 00 00       	mov    $0x0,%edx
  8011b4:	eb 0e                	jmp    8011c4 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8011b6:	8b 10                	mov    (%eax),%edx
  8011b8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011bb:	89 08                	mov    %ecx,(%eax)
  8011bd:	8b 02                	mov    (%edx),%eax
  8011bf:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8011c4:	5d                   	pop    %ebp
  8011c5:	c3                   	ret    

008011c6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011c6:	55                   	push   %ebp
  8011c7:	89 e5                	mov    %esp,%ebp
  8011c9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011cc:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8011cf:	8b 10                	mov    (%eax),%edx
  8011d1:	3b 50 04             	cmp    0x4(%eax),%edx
  8011d4:	73 0a                	jae    8011e0 <sprintputch+0x1a>
		*b->buf++ = ch;
  8011d6:	8d 4a 01             	lea    0x1(%edx),%ecx
  8011d9:	89 08                	mov    %ecx,(%eax)
  8011db:	8b 45 08             	mov    0x8(%ebp),%eax
  8011de:	88 02                	mov    %al,(%edx)
}
  8011e0:	5d                   	pop    %ebp
  8011e1:	c3                   	ret    

008011e2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8011e2:	55                   	push   %ebp
  8011e3:	89 e5                	mov    %esp,%ebp
  8011e5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8011e8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8011eb:	50                   	push   %eax
  8011ec:	ff 75 10             	pushl  0x10(%ebp)
  8011ef:	ff 75 0c             	pushl  0xc(%ebp)
  8011f2:	ff 75 08             	pushl  0x8(%ebp)
  8011f5:	e8 05 00 00 00       	call   8011ff <vprintfmt>
	va_end(ap);
}
  8011fa:	83 c4 10             	add    $0x10,%esp
  8011fd:	c9                   	leave  
  8011fe:	c3                   	ret    

008011ff <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8011ff:	55                   	push   %ebp
  801200:	89 e5                	mov    %esp,%ebp
  801202:	57                   	push   %edi
  801203:	56                   	push   %esi
  801204:	53                   	push   %ebx
  801205:	83 ec 2c             	sub    $0x2c,%esp
  801208:	8b 7d 08             	mov    0x8(%ebp),%edi
  80120b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80120e:	eb 03                	jmp    801213 <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  801210:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  801213:	8b 45 10             	mov    0x10(%ebp),%eax
  801216:	8d 70 01             	lea    0x1(%eax),%esi
  801219:	0f b6 00             	movzbl (%eax),%eax
  80121c:	83 f8 25             	cmp    $0x25,%eax
  80121f:	74 25                	je     801246 <vprintfmt+0x47>
			if (ch == '\0')									//当然中间如果遇到'\0'，代表这个字符串的访问结束
  801221:	85 c0                	test   %eax,%eax
  801223:	75 0d                	jne    801232 <vprintfmt+0x33>
  801225:	e9 b5 03 00 00       	jmp    8015df <vprintfmt+0x3e0>
  80122a:	85 c0                	test   %eax,%eax
  80122c:	0f 84 ad 03 00 00    	je     8015df <vprintfmt+0x3e0>
				return;
			putch(ch, putdat);								//调用putch函数，把一个字符ch输出到putdat指针所指向的地址中所存放的值对应的地址处
  801232:	83 ec 08             	sub    $0x8,%esp
  801235:	53                   	push   %ebx
  801236:	50                   	push   %eax
  801237:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  801239:	46                   	inc    %esi
  80123a:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  80123e:	83 c4 10             	add    $0x10,%esp
  801241:	83 f8 25             	cmp    $0x25,%eax
  801244:	75 e4                	jne    80122a <vprintfmt+0x2b>
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  801246:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  80124a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801251:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801258:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80125f:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  801266:	eb 07                	jmp    80126f <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  801268:	8b 75 10             	mov    0x10(%ebp),%esi

		// flag to pad on the right
		case '-':											//%后面的'-'代表要进行左对齐输出，右边填空格，如果省略代表右对齐
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
  80126b:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80126f:	8d 46 01             	lea    0x1(%esi),%eax
  801272:	89 45 10             	mov    %eax,0x10(%ebp)
  801275:	0f b6 16             	movzbl (%esi),%edx
  801278:	8a 06                	mov    (%esi),%al
  80127a:	83 e8 23             	sub    $0x23,%eax
  80127d:	3c 55                	cmp    $0x55,%al
  80127f:	0f 87 03 03 00 00    	ja     801588 <vprintfmt+0x389>
  801285:	0f b6 c0             	movzbl %al,%eax
  801288:	ff 24 85 c0 20 80 00 	jmp    *0x8020c0(,%eax,4)
  80128f:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
			goto reswitch;									//处理下一个字符

		// flag to pad with 0's instead of spaces
		case '0':											//0--有0表示进行对齐输出时填0,如省略表示填入空格，并且如果为0，则一定是右对齐
			padc = '0';										//对其方式标志位变为0
  801292:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  801296:	eb d7                	jmp    80126f <vprintfmt+0x70>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
				precision = precision * 10 + ch - '0';
  801298:	8d 42 d0             	lea    -0x30(%edx),%eax
  80129b:	89 c1                	mov    %eax,%ecx
  80129d:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  8012a0:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8012a4:	8d 50 d0             	lea    -0x30(%eax),%edx
  8012a7:	83 fa 09             	cmp    $0x9,%edx
  8012aa:	77 51                	ja     8012fd <vprintfmt+0xfe>
  8012ac:	8b 75 10             	mov    0x10(%ebp),%esi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
  8012af:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8012b0:	8d 14 89             	lea    (%ecx,%ecx,4),%edx
  8012b3:	01 d2                	add    %edx,%edx
  8012b5:	8d 4c 10 d0          	lea    -0x30(%eax,%edx,1),%ecx
				ch = *fmt;
  8012b9:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8012bc:	8d 50 d0             	lea    -0x30(%eax),%edx
  8012bf:	83 fa 09             	cmp    $0x9,%edx
  8012c2:	76 eb                	jbe    8012af <vprintfmt+0xb0>
  8012c4:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8012c7:	eb 37                	jmp    801300 <vprintfmt+0x101>
					break;
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
  8012c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8012cc:	8d 50 04             	lea    0x4(%eax),%edx
  8012cf:	89 55 14             	mov    %edx,0x14(%ebp)
  8012d2:	8b 00                	mov    (%eax),%eax
  8012d4:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8012d7:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
			goto process_precision;
  8012da:	eb 24                	jmp    801300 <vprintfmt+0x101>
  8012dc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8012e0:	79 07                	jns    8012e9 <vprintfmt+0xea>
  8012e2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8012e9:	8b 75 10             	mov    0x10(%ebp),%esi
  8012ec:	eb 81                	jmp    80126f <vprintfmt+0x70>
  8012ee:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  8012f1:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8012f8:	e9 72 ff ff ff       	jmp    80126f <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8012fd:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:									//处理输出精度，把width字段赋值为刚刚计算出来的precision值，所以width应该是整数部分的有效数字位数
			if (width < 0)
  801300:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801304:	0f 89 65 ff ff ff    	jns    80126f <vprintfmt+0x70>
				width = precision, precision = -1;
  80130a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80130d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801310:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801317:	e9 53 ff ff ff       	jmp    80126f <vprintfmt+0x70>
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
  80131c:	ff 45 d4             	incl   -0x2c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80131f:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
			goto reswitch;
  801322:	e9 48 ff ff ff       	jmp    80126f <vprintfmt+0x70>

		// character
		case 'c':											//如果是'c'代表显示一个字符
			putch(va_arg(ap, int), putdat);					//调用输出一个字符到内存的函数putch
  801327:	8b 45 14             	mov    0x14(%ebp),%eax
  80132a:	8d 50 04             	lea    0x4(%eax),%edx
  80132d:	89 55 14             	mov    %edx,0x14(%ebp)
  801330:	83 ec 08             	sub    $0x8,%esp
  801333:	53                   	push   %ebx
  801334:	ff 30                	pushl  (%eax)
  801336:	ff d7                	call   *%edi
			break;
  801338:	83 c4 10             	add    $0x10,%esp
  80133b:	e9 d3 fe ff ff       	jmp    801213 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801340:	8b 45 14             	mov    0x14(%ebp),%eax
  801343:	8d 50 04             	lea    0x4(%eax),%edx
  801346:	89 55 14             	mov    %edx,0x14(%ebp)
  801349:	8b 00                	mov    (%eax),%eax
  80134b:	85 c0                	test   %eax,%eax
  80134d:	79 02                	jns    801351 <vprintfmt+0x152>
  80134f:	f7 d8                	neg    %eax
  801351:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801353:	83 f8 0f             	cmp    $0xf,%eax
  801356:	7f 0b                	jg     801363 <vprintfmt+0x164>
  801358:	8b 04 85 20 22 80 00 	mov    0x802220(,%eax,4),%eax
  80135f:	85 c0                	test   %eax,%eax
  801361:	75 15                	jne    801378 <vprintfmt+0x179>
				printfmt(putch, putdat, "error %d", err);
  801363:	52                   	push   %edx
  801364:	68 8b 1f 80 00       	push   $0x801f8b
  801369:	53                   	push   %ebx
  80136a:	57                   	push   %edi
  80136b:	e8 72 fe ff ff       	call   8011e2 <printfmt>
  801370:	83 c4 10             	add    $0x10,%esp
  801373:	e9 9b fe ff ff       	jmp    801213 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  801378:	50                   	push   %eax
  801379:	68 0b 1f 80 00       	push   $0x801f0b
  80137e:	53                   	push   %ebx
  80137f:	57                   	push   %edi
  801380:	e8 5d fe ff ff       	call   8011e2 <printfmt>
  801385:	83 c4 10             	add    $0x10,%esp
  801388:	e9 86 fe ff ff       	jmp    801213 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80138d:	8b 45 14             	mov    0x14(%ebp),%eax
  801390:	8d 50 04             	lea    0x4(%eax),%edx
  801393:	89 55 14             	mov    %edx,0x14(%ebp)
  801396:	8b 00                	mov    (%eax),%eax
  801398:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80139b:	85 c0                	test   %eax,%eax
  80139d:	75 07                	jne    8013a6 <vprintfmt+0x1a7>
				p = "(null)";
  80139f:	c7 45 d4 84 1f 80 00 	movl   $0x801f84,-0x2c(%ebp)
			if (width > 0 && padc != '-')
  8013a6:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8013a9:	85 f6                	test   %esi,%esi
  8013ab:	0f 8e fb 01 00 00    	jle    8015ac <vprintfmt+0x3ad>
  8013b1:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  8013b5:	0f 84 09 02 00 00    	je     8015c4 <vprintfmt+0x3c5>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013bb:	83 ec 08             	sub    $0x8,%esp
  8013be:	ff 75 d0             	pushl  -0x30(%ebp)
  8013c1:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013c4:	e8 ad 02 00 00       	call   801676 <strnlen>
  8013c9:	89 f1                	mov    %esi,%ecx
  8013cb:	29 c1                	sub    %eax,%ecx
  8013cd:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8013d0:	83 c4 10             	add    $0x10,%esp
  8013d3:	85 c9                	test   %ecx,%ecx
  8013d5:	0f 8e d1 01 00 00    	jle    8015ac <vprintfmt+0x3ad>
					putch(padc, putdat);
  8013db:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8013df:	83 ec 08             	sub    $0x8,%esp
  8013e2:	53                   	push   %ebx
  8013e3:	56                   	push   %esi
  8013e4:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013e6:	83 c4 10             	add    $0x10,%esp
  8013e9:	ff 4d e4             	decl   -0x1c(%ebp)
  8013ec:	75 f1                	jne    8013df <vprintfmt+0x1e0>
  8013ee:	e9 b9 01 00 00       	jmp    8015ac <vprintfmt+0x3ad>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8013f3:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8013f7:	74 19                	je     801412 <vprintfmt+0x213>
  8013f9:	0f be c0             	movsbl %al,%eax
  8013fc:	83 e8 20             	sub    $0x20,%eax
  8013ff:	83 f8 5e             	cmp    $0x5e,%eax
  801402:	76 0e                	jbe    801412 <vprintfmt+0x213>
					putch('?', putdat);
  801404:	83 ec 08             	sub    $0x8,%esp
  801407:	53                   	push   %ebx
  801408:	6a 3f                	push   $0x3f
  80140a:	ff 55 08             	call   *0x8(%ebp)
  80140d:	83 c4 10             	add    $0x10,%esp
  801410:	eb 0b                	jmp    80141d <vprintfmt+0x21e>
				else
					putch(ch, putdat);
  801412:	83 ec 08             	sub    $0x8,%esp
  801415:	53                   	push   %ebx
  801416:	52                   	push   %edx
  801417:	ff 55 08             	call   *0x8(%ebp)
  80141a:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80141d:	ff 4d e4             	decl   -0x1c(%ebp)
  801420:	46                   	inc    %esi
  801421:	8a 46 ff             	mov    -0x1(%esi),%al
  801424:	0f be d0             	movsbl %al,%edx
  801427:	85 d2                	test   %edx,%edx
  801429:	75 1c                	jne    801447 <vprintfmt+0x248>
  80142b:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80142e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801432:	7f 1f                	jg     801453 <vprintfmt+0x254>
  801434:	e9 da fd ff ff       	jmp    801213 <vprintfmt+0x14>
  801439:	89 7d 08             	mov    %edi,0x8(%ebp)
  80143c:	8b 7d d0             	mov    -0x30(%ebp),%edi
  80143f:	eb 06                	jmp    801447 <vprintfmt+0x248>
  801441:	89 7d 08             	mov    %edi,0x8(%ebp)
  801444:	8b 7d d0             	mov    -0x30(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801447:	85 ff                	test   %edi,%edi
  801449:	78 a8                	js     8013f3 <vprintfmt+0x1f4>
  80144b:	4f                   	dec    %edi
  80144c:	79 a5                	jns    8013f3 <vprintfmt+0x1f4>
  80144e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801451:	eb db                	jmp    80142e <vprintfmt+0x22f>
  801453:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801456:	83 ec 08             	sub    $0x8,%esp
  801459:	53                   	push   %ebx
  80145a:	6a 20                	push   $0x20
  80145c:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80145e:	4e                   	dec    %esi
  80145f:	83 c4 10             	add    $0x10,%esp
  801462:	85 f6                	test   %esi,%esi
  801464:	7f f0                	jg     801456 <vprintfmt+0x257>
  801466:	e9 a8 fd ff ff       	jmp    801213 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80146b:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  80146f:	7e 16                	jle    801487 <vprintfmt+0x288>
		return va_arg(*ap, long long);
  801471:	8b 45 14             	mov    0x14(%ebp),%eax
  801474:	8d 50 08             	lea    0x8(%eax),%edx
  801477:	89 55 14             	mov    %edx,0x14(%ebp)
  80147a:	8b 50 04             	mov    0x4(%eax),%edx
  80147d:	8b 00                	mov    (%eax),%eax
  80147f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801482:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801485:	eb 34                	jmp    8014bb <vprintfmt+0x2bc>
	else if (lflag)
  801487:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80148b:	74 18                	je     8014a5 <vprintfmt+0x2a6>
		return va_arg(*ap, long);
  80148d:	8b 45 14             	mov    0x14(%ebp),%eax
  801490:	8d 50 04             	lea    0x4(%eax),%edx
  801493:	89 55 14             	mov    %edx,0x14(%ebp)
  801496:	8b 30                	mov    (%eax),%esi
  801498:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80149b:	89 f0                	mov    %esi,%eax
  80149d:	c1 f8 1f             	sar    $0x1f,%eax
  8014a0:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8014a3:	eb 16                	jmp    8014bb <vprintfmt+0x2bc>
	else
		return va_arg(*ap, int);
  8014a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8014a8:	8d 50 04             	lea    0x4(%eax),%edx
  8014ab:	89 55 14             	mov    %edx,0x14(%ebp)
  8014ae:	8b 30                	mov    (%eax),%esi
  8014b0:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8014b3:	89 f0                	mov    %esi,%eax
  8014b5:	c1 f8 1f             	sar    $0x1f,%eax
  8014b8:	89 45 dc             	mov    %eax,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8014bb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8014be:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
  8014c1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8014c5:	0f 89 8a 00 00 00    	jns    801555 <vprintfmt+0x356>
				putch('-', putdat);
  8014cb:	83 ec 08             	sub    $0x8,%esp
  8014ce:	53                   	push   %ebx
  8014cf:	6a 2d                	push   $0x2d
  8014d1:	ff d7                	call   *%edi
				num = -(long long) num;
  8014d3:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8014d6:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8014d9:	f7 d8                	neg    %eax
  8014db:	83 d2 00             	adc    $0x0,%edx
  8014de:	f7 da                	neg    %edx
  8014e0:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8014e3:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8014e8:	eb 70                	jmp    80155a <vprintfmt+0x35b>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8014ea:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8014ed:	8d 45 14             	lea    0x14(%ebp),%eax
  8014f0:	e8 97 fc ff ff       	call   80118c <getuint>
			base = 10;
  8014f5:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8014fa:	eb 5e                	jmp    80155a <vprintfmt+0x35b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  8014fc:	83 ec 08             	sub    $0x8,%esp
  8014ff:	53                   	push   %ebx
  801500:	6a 30                	push   $0x30
  801502:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  801504:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  801507:	8d 45 14             	lea    0x14(%ebp),%eax
  80150a:	e8 7d fc ff ff       	call   80118c <getuint>
			base = 8;
			goto number;
  80150f:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  801512:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801517:	eb 41                	jmp    80155a <vprintfmt+0x35b>
		// pointer
		case 'p':
			putch('0', putdat);
  801519:	83 ec 08             	sub    $0x8,%esp
  80151c:	53                   	push   %ebx
  80151d:	6a 30                	push   $0x30
  80151f:	ff d7                	call   *%edi
			putch('x', putdat);
  801521:	83 c4 08             	add    $0x8,%esp
  801524:	53                   	push   %ebx
  801525:	6a 78                	push   $0x78
  801527:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801529:	8b 45 14             	mov    0x14(%ebp),%eax
  80152c:	8d 50 04             	lea    0x4(%eax),%edx
  80152f:	89 55 14             	mov    %edx,0x14(%ebp)
			goto number;
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801532:	8b 00                	mov    (%eax),%eax
  801534:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801539:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80153c:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801541:	eb 17                	jmp    80155a <vprintfmt+0x35b>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801543:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  801546:	8d 45 14             	lea    0x14(%ebp),%eax
  801549:	e8 3e fc ff ff       	call   80118c <getuint>
			base = 16;
  80154e:	b9 10 00 00 00       	mov    $0x10,%ecx
  801553:	eb 05                	jmp    80155a <vprintfmt+0x35b>
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801555:	b9 0a 00 00 00       	mov    $0xa,%ecx
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  80155a:	83 ec 0c             	sub    $0xc,%esp
  80155d:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  801561:	56                   	push   %esi
  801562:	ff 75 e4             	pushl  -0x1c(%ebp)
  801565:	51                   	push   %ecx
  801566:	52                   	push   %edx
  801567:	50                   	push   %eax
  801568:	89 da                	mov    %ebx,%edx
  80156a:	89 f8                	mov    %edi,%eax
  80156c:	e8 6b fb ff ff       	call   8010dc <printnum>
			break;
  801571:	83 c4 20             	add    $0x20,%esp
  801574:	e9 9a fc ff ff       	jmp    801213 <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801579:	83 ec 08             	sub    $0x8,%esp
  80157c:	53                   	push   %ebx
  80157d:	52                   	push   %edx
  80157e:	ff d7                	call   *%edi
			break;
  801580:	83 c4 10             	add    $0x10,%esp
  801583:	e9 8b fc ff ff       	jmp    801213 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801588:	83 ec 08             	sub    $0x8,%esp
  80158b:	53                   	push   %ebx
  80158c:	6a 25                	push   $0x25
  80158e:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801590:	83 c4 10             	add    $0x10,%esp
  801593:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  801597:	0f 84 73 fc ff ff    	je     801210 <vprintfmt+0x11>
  80159d:	4e                   	dec    %esi
  80159e:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8015a2:	75 f9                	jne    80159d <vprintfmt+0x39e>
  8015a4:	89 75 10             	mov    %esi,0x10(%ebp)
  8015a7:	e9 67 fc ff ff       	jmp    801213 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8015ac:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8015af:	8d 70 01             	lea    0x1(%eax),%esi
  8015b2:	8a 00                	mov    (%eax),%al
  8015b4:	0f be d0             	movsbl %al,%edx
  8015b7:	85 d2                	test   %edx,%edx
  8015b9:	0f 85 7a fe ff ff    	jne    801439 <vprintfmt+0x23a>
  8015bf:	e9 4f fc ff ff       	jmp    801213 <vprintfmt+0x14>
  8015c4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8015c7:	8d 70 01             	lea    0x1(%eax),%esi
  8015ca:	8a 00                	mov    (%eax),%al
  8015cc:	0f be d0             	movsbl %al,%edx
  8015cf:	85 d2                	test   %edx,%edx
  8015d1:	0f 85 6a fe ff ff    	jne    801441 <vprintfmt+0x242>
  8015d7:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8015da:	e9 77 fe ff ff       	jmp    801456 <vprintfmt+0x257>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  8015df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015e2:	5b                   	pop    %ebx
  8015e3:	5e                   	pop    %esi
  8015e4:	5f                   	pop    %edi
  8015e5:	5d                   	pop    %ebp
  8015e6:	c3                   	ret    

008015e7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8015e7:	55                   	push   %ebp
  8015e8:	89 e5                	mov    %esp,%ebp
  8015ea:	83 ec 18             	sub    $0x18,%esp
  8015ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8015f0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8015f3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8015f6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8015fa:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8015fd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801604:	85 c0                	test   %eax,%eax
  801606:	74 26                	je     80162e <vsnprintf+0x47>
  801608:	85 d2                	test   %edx,%edx
  80160a:	7e 29                	jle    801635 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80160c:	ff 75 14             	pushl  0x14(%ebp)
  80160f:	ff 75 10             	pushl  0x10(%ebp)
  801612:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801615:	50                   	push   %eax
  801616:	68 c6 11 80 00       	push   $0x8011c6
  80161b:	e8 df fb ff ff       	call   8011ff <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801620:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801623:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801626:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801629:	83 c4 10             	add    $0x10,%esp
  80162c:	eb 0c                	jmp    80163a <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80162e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801633:	eb 05                	jmp    80163a <vsnprintf+0x53>
  801635:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80163a:	c9                   	leave  
  80163b:	c3                   	ret    

0080163c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80163c:	55                   	push   %ebp
  80163d:	89 e5                	mov    %esp,%ebp
  80163f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801642:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801645:	50                   	push   %eax
  801646:	ff 75 10             	pushl  0x10(%ebp)
  801649:	ff 75 0c             	pushl  0xc(%ebp)
  80164c:	ff 75 08             	pushl  0x8(%ebp)
  80164f:	e8 93 ff ff ff       	call   8015e7 <vsnprintf>
	va_end(ap);

	return rc;
}
  801654:	c9                   	leave  
  801655:	c3                   	ret    

00801656 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801656:	55                   	push   %ebp
  801657:	89 e5                	mov    %esp,%ebp
  801659:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80165c:	80 3a 00             	cmpb   $0x0,(%edx)
  80165f:	74 0e                	je     80166f <strlen+0x19>
  801661:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801666:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801667:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80166b:	75 f9                	jne    801666 <strlen+0x10>
  80166d:	eb 05                	jmp    801674 <strlen+0x1e>
  80166f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801674:	5d                   	pop    %ebp
  801675:	c3                   	ret    

00801676 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801676:	55                   	push   %ebp
  801677:	89 e5                	mov    %esp,%ebp
  801679:	53                   	push   %ebx
  80167a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80167d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801680:	85 c9                	test   %ecx,%ecx
  801682:	74 1a                	je     80169e <strnlen+0x28>
  801684:	80 3b 00             	cmpb   $0x0,(%ebx)
  801687:	74 1c                	je     8016a5 <strnlen+0x2f>
  801689:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  80168e:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801690:	39 ca                	cmp    %ecx,%edx
  801692:	74 16                	je     8016aa <strnlen+0x34>
  801694:	42                   	inc    %edx
  801695:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  80169a:	75 f2                	jne    80168e <strnlen+0x18>
  80169c:	eb 0c                	jmp    8016aa <strnlen+0x34>
  80169e:	b8 00 00 00 00       	mov    $0x0,%eax
  8016a3:	eb 05                	jmp    8016aa <strnlen+0x34>
  8016a5:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8016aa:	5b                   	pop    %ebx
  8016ab:	5d                   	pop    %ebp
  8016ac:	c3                   	ret    

008016ad <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016ad:	55                   	push   %ebp
  8016ae:	89 e5                	mov    %esp,%ebp
  8016b0:	53                   	push   %ebx
  8016b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016b7:	89 c2                	mov    %eax,%edx
  8016b9:	42                   	inc    %edx
  8016ba:	41                   	inc    %ecx
  8016bb:	8a 59 ff             	mov    -0x1(%ecx),%bl
  8016be:	88 5a ff             	mov    %bl,-0x1(%edx)
  8016c1:	84 db                	test   %bl,%bl
  8016c3:	75 f4                	jne    8016b9 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8016c5:	5b                   	pop    %ebx
  8016c6:	5d                   	pop    %ebp
  8016c7:	c3                   	ret    

008016c8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016c8:	55                   	push   %ebp
  8016c9:	89 e5                	mov    %esp,%ebp
  8016cb:	53                   	push   %ebx
  8016cc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016cf:	53                   	push   %ebx
  8016d0:	e8 81 ff ff ff       	call   801656 <strlen>
  8016d5:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8016d8:	ff 75 0c             	pushl  0xc(%ebp)
  8016db:	01 d8                	add    %ebx,%eax
  8016dd:	50                   	push   %eax
  8016de:	e8 ca ff ff ff       	call   8016ad <strcpy>
	return dst;
}
  8016e3:	89 d8                	mov    %ebx,%eax
  8016e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016e8:	c9                   	leave  
  8016e9:	c3                   	ret    

008016ea <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016ea:	55                   	push   %ebp
  8016eb:	89 e5                	mov    %esp,%ebp
  8016ed:	56                   	push   %esi
  8016ee:	53                   	push   %ebx
  8016ef:	8b 75 08             	mov    0x8(%ebp),%esi
  8016f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016f5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016f8:	85 db                	test   %ebx,%ebx
  8016fa:	74 14                	je     801710 <strncpy+0x26>
  8016fc:	01 f3                	add    %esi,%ebx
  8016fe:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  801700:	41                   	inc    %ecx
  801701:	8a 02                	mov    (%edx),%al
  801703:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801706:	80 3a 01             	cmpb   $0x1,(%edx)
  801709:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80170c:	39 cb                	cmp    %ecx,%ebx
  80170e:	75 f0                	jne    801700 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801710:	89 f0                	mov    %esi,%eax
  801712:	5b                   	pop    %ebx
  801713:	5e                   	pop    %esi
  801714:	5d                   	pop    %ebp
  801715:	c3                   	ret    

00801716 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801716:	55                   	push   %ebp
  801717:	89 e5                	mov    %esp,%ebp
  801719:	53                   	push   %ebx
  80171a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80171d:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801720:	85 c0                	test   %eax,%eax
  801722:	74 30                	je     801754 <strlcpy+0x3e>
		while (--size > 0 && *src != '\0')
  801724:	48                   	dec    %eax
  801725:	74 20                	je     801747 <strlcpy+0x31>
  801727:	8a 0b                	mov    (%ebx),%cl
  801729:	84 c9                	test   %cl,%cl
  80172b:	74 1f                	je     80174c <strlcpy+0x36>
  80172d:	8d 53 01             	lea    0x1(%ebx),%edx
  801730:	01 c3                	add    %eax,%ebx
  801732:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
  801735:	40                   	inc    %eax
  801736:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801739:	39 da                	cmp    %ebx,%edx
  80173b:	74 12                	je     80174f <strlcpy+0x39>
  80173d:	42                   	inc    %edx
  80173e:	8a 4a ff             	mov    -0x1(%edx),%cl
  801741:	84 c9                	test   %cl,%cl
  801743:	75 f0                	jne    801735 <strlcpy+0x1f>
  801745:	eb 08                	jmp    80174f <strlcpy+0x39>
  801747:	8b 45 08             	mov    0x8(%ebp),%eax
  80174a:	eb 03                	jmp    80174f <strlcpy+0x39>
  80174c:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
		*dst = '\0';
  80174f:	c6 00 00             	movb   $0x0,(%eax)
  801752:	eb 03                	jmp    801757 <strlcpy+0x41>
  801754:	8b 45 08             	mov    0x8(%ebp),%eax
	}
	return dst - dst_in;
  801757:	2b 45 08             	sub    0x8(%ebp),%eax
}
  80175a:	5b                   	pop    %ebx
  80175b:	5d                   	pop    %ebp
  80175c:	c3                   	ret    

0080175d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80175d:	55                   	push   %ebp
  80175e:	89 e5                	mov    %esp,%ebp
  801760:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801763:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801766:	8a 01                	mov    (%ecx),%al
  801768:	84 c0                	test   %al,%al
  80176a:	74 10                	je     80177c <strcmp+0x1f>
  80176c:	3a 02                	cmp    (%edx),%al
  80176e:	75 0c                	jne    80177c <strcmp+0x1f>
		p++, q++;
  801770:	41                   	inc    %ecx
  801771:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801772:	8a 01                	mov    (%ecx),%al
  801774:	84 c0                	test   %al,%al
  801776:	74 04                	je     80177c <strcmp+0x1f>
  801778:	3a 02                	cmp    (%edx),%al
  80177a:	74 f4                	je     801770 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80177c:	0f b6 c0             	movzbl %al,%eax
  80177f:	0f b6 12             	movzbl (%edx),%edx
  801782:	29 d0                	sub    %edx,%eax
}
  801784:	5d                   	pop    %ebp
  801785:	c3                   	ret    

00801786 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801786:	55                   	push   %ebp
  801787:	89 e5                	mov    %esp,%ebp
  801789:	56                   	push   %esi
  80178a:	53                   	push   %ebx
  80178b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80178e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801791:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  801794:	85 f6                	test   %esi,%esi
  801796:	74 23                	je     8017bb <strncmp+0x35>
  801798:	8a 03                	mov    (%ebx),%al
  80179a:	84 c0                	test   %al,%al
  80179c:	74 2b                	je     8017c9 <strncmp+0x43>
  80179e:	3a 02                	cmp    (%edx),%al
  8017a0:	75 27                	jne    8017c9 <strncmp+0x43>
  8017a2:	8d 43 01             	lea    0x1(%ebx),%eax
  8017a5:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  8017a7:	89 c3                	mov    %eax,%ebx
  8017a9:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017aa:	39 c6                	cmp    %eax,%esi
  8017ac:	74 14                	je     8017c2 <strncmp+0x3c>
  8017ae:	8a 08                	mov    (%eax),%cl
  8017b0:	84 c9                	test   %cl,%cl
  8017b2:	74 15                	je     8017c9 <strncmp+0x43>
  8017b4:	40                   	inc    %eax
  8017b5:	3a 0a                	cmp    (%edx),%cl
  8017b7:	74 ee                	je     8017a7 <strncmp+0x21>
  8017b9:	eb 0e                	jmp    8017c9 <strncmp+0x43>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8017c0:	eb 0f                	jmp    8017d1 <strncmp+0x4b>
  8017c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8017c7:	eb 08                	jmp    8017d1 <strncmp+0x4b>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017c9:	0f b6 03             	movzbl (%ebx),%eax
  8017cc:	0f b6 12             	movzbl (%edx),%edx
  8017cf:	29 d0                	sub    %edx,%eax
}
  8017d1:	5b                   	pop    %ebx
  8017d2:	5e                   	pop    %esi
  8017d3:	5d                   	pop    %ebp
  8017d4:	c3                   	ret    

008017d5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017d5:	55                   	push   %ebp
  8017d6:	89 e5                	mov    %esp,%ebp
  8017d8:	53                   	push   %ebx
  8017d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8017dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  8017df:	8a 10                	mov    (%eax),%dl
  8017e1:	84 d2                	test   %dl,%dl
  8017e3:	74 1a                	je     8017ff <strchr+0x2a>
  8017e5:	88 d9                	mov    %bl,%cl
		if (*s == c)
  8017e7:	38 d3                	cmp    %dl,%bl
  8017e9:	75 06                	jne    8017f1 <strchr+0x1c>
  8017eb:	eb 17                	jmp    801804 <strchr+0x2f>
  8017ed:	38 ca                	cmp    %cl,%dl
  8017ef:	74 13                	je     801804 <strchr+0x2f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017f1:	40                   	inc    %eax
  8017f2:	8a 10                	mov    (%eax),%dl
  8017f4:	84 d2                	test   %dl,%dl
  8017f6:	75 f5                	jne    8017ed <strchr+0x18>
		if (*s == c)
			return (char *) s;
	return 0;
  8017f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8017fd:	eb 05                	jmp    801804 <strchr+0x2f>
  8017ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801804:	5b                   	pop    %ebx
  801805:	5d                   	pop    %ebp
  801806:	c3                   	ret    

00801807 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801807:	55                   	push   %ebp
  801808:	89 e5                	mov    %esp,%ebp
  80180a:	53                   	push   %ebx
  80180b:	8b 45 08             	mov    0x8(%ebp),%eax
  80180e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  801811:	8a 10                	mov    (%eax),%dl
  801813:	84 d2                	test   %dl,%dl
  801815:	74 13                	je     80182a <strfind+0x23>
  801817:	88 d9                	mov    %bl,%cl
		if (*s == c)
  801819:	38 d3                	cmp    %dl,%bl
  80181b:	75 06                	jne    801823 <strfind+0x1c>
  80181d:	eb 0b                	jmp    80182a <strfind+0x23>
  80181f:	38 ca                	cmp    %cl,%dl
  801821:	74 07                	je     80182a <strfind+0x23>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801823:	40                   	inc    %eax
  801824:	8a 10                	mov    (%eax),%dl
  801826:	84 d2                	test   %dl,%dl
  801828:	75 f5                	jne    80181f <strfind+0x18>
		if (*s == c)
			break;
	return (char *) s;
}
  80182a:	5b                   	pop    %ebx
  80182b:	5d                   	pop    %ebp
  80182c:	c3                   	ret    

0080182d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80182d:	55                   	push   %ebp
  80182e:	89 e5                	mov    %esp,%ebp
  801830:	57                   	push   %edi
  801831:	56                   	push   %esi
  801832:	53                   	push   %ebx
  801833:	8b 7d 08             	mov    0x8(%ebp),%edi
  801836:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801839:	85 c9                	test   %ecx,%ecx
  80183b:	74 36                	je     801873 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80183d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801843:	75 28                	jne    80186d <memset+0x40>
  801845:	f6 c1 03             	test   $0x3,%cl
  801848:	75 23                	jne    80186d <memset+0x40>
		c &= 0xFF;
  80184a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80184e:	89 d3                	mov    %edx,%ebx
  801850:	c1 e3 08             	shl    $0x8,%ebx
  801853:	89 d6                	mov    %edx,%esi
  801855:	c1 e6 18             	shl    $0x18,%esi
  801858:	89 d0                	mov    %edx,%eax
  80185a:	c1 e0 10             	shl    $0x10,%eax
  80185d:	09 f0                	or     %esi,%eax
  80185f:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801861:	89 d8                	mov    %ebx,%eax
  801863:	09 d0                	or     %edx,%eax
  801865:	c1 e9 02             	shr    $0x2,%ecx
  801868:	fc                   	cld    
  801869:	f3 ab                	rep stos %eax,%es:(%edi)
  80186b:	eb 06                	jmp    801873 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80186d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801870:	fc                   	cld    
  801871:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801873:	89 f8                	mov    %edi,%eax
  801875:	5b                   	pop    %ebx
  801876:	5e                   	pop    %esi
  801877:	5f                   	pop    %edi
  801878:	5d                   	pop    %ebp
  801879:	c3                   	ret    

0080187a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80187a:	55                   	push   %ebp
  80187b:	89 e5                	mov    %esp,%ebp
  80187d:	57                   	push   %edi
  80187e:	56                   	push   %esi
  80187f:	8b 45 08             	mov    0x8(%ebp),%eax
  801882:	8b 75 0c             	mov    0xc(%ebp),%esi
  801885:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801888:	39 c6                	cmp    %eax,%esi
  80188a:	73 33                	jae    8018bf <memmove+0x45>
  80188c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80188f:	39 d0                	cmp    %edx,%eax
  801891:	73 2c                	jae    8018bf <memmove+0x45>
		s += n;
		d += n;
  801893:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801896:	89 d6                	mov    %edx,%esi
  801898:	09 fe                	or     %edi,%esi
  80189a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018a0:	75 13                	jne    8018b5 <memmove+0x3b>
  8018a2:	f6 c1 03             	test   $0x3,%cl
  8018a5:	75 0e                	jne    8018b5 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8018a7:	83 ef 04             	sub    $0x4,%edi
  8018aa:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018ad:	c1 e9 02             	shr    $0x2,%ecx
  8018b0:	fd                   	std    
  8018b1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018b3:	eb 07                	jmp    8018bc <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8018b5:	4f                   	dec    %edi
  8018b6:	8d 72 ff             	lea    -0x1(%edx),%esi
  8018b9:	fd                   	std    
  8018ba:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018bc:	fc                   	cld    
  8018bd:	eb 1d                	jmp    8018dc <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018bf:	89 f2                	mov    %esi,%edx
  8018c1:	09 c2                	or     %eax,%edx
  8018c3:	f6 c2 03             	test   $0x3,%dl
  8018c6:	75 0f                	jne    8018d7 <memmove+0x5d>
  8018c8:	f6 c1 03             	test   $0x3,%cl
  8018cb:	75 0a                	jne    8018d7 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
  8018cd:	c1 e9 02             	shr    $0x2,%ecx
  8018d0:	89 c7                	mov    %eax,%edi
  8018d2:	fc                   	cld    
  8018d3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018d5:	eb 05                	jmp    8018dc <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018d7:	89 c7                	mov    %eax,%edi
  8018d9:	fc                   	cld    
  8018da:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018dc:	5e                   	pop    %esi
  8018dd:	5f                   	pop    %edi
  8018de:	5d                   	pop    %ebp
  8018df:	c3                   	ret    

008018e0 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018e0:	55                   	push   %ebp
  8018e1:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018e3:	ff 75 10             	pushl  0x10(%ebp)
  8018e6:	ff 75 0c             	pushl  0xc(%ebp)
  8018e9:	ff 75 08             	pushl  0x8(%ebp)
  8018ec:	e8 89 ff ff ff       	call   80187a <memmove>
}
  8018f1:	c9                   	leave  
  8018f2:	c3                   	ret    

008018f3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018f3:	55                   	push   %ebp
  8018f4:	89 e5                	mov    %esp,%ebp
  8018f6:	57                   	push   %edi
  8018f7:	56                   	push   %esi
  8018f8:	53                   	push   %ebx
  8018f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8018fc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018ff:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801902:	85 c0                	test   %eax,%eax
  801904:	74 33                	je     801939 <memcmp+0x46>
  801906:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  801909:	8a 13                	mov    (%ebx),%dl
  80190b:	8a 0e                	mov    (%esi),%cl
  80190d:	38 ca                	cmp    %cl,%dl
  80190f:	75 13                	jne    801924 <memcmp+0x31>
  801911:	b8 00 00 00 00       	mov    $0x0,%eax
  801916:	eb 16                	jmp    80192e <memcmp+0x3b>
  801918:	8a 54 03 01          	mov    0x1(%ebx,%eax,1),%dl
  80191c:	40                   	inc    %eax
  80191d:	8a 0c 06             	mov    (%esi,%eax,1),%cl
  801920:	38 ca                	cmp    %cl,%dl
  801922:	74 0a                	je     80192e <memcmp+0x3b>
			return (int) *s1 - (int) *s2;
  801924:	0f b6 c2             	movzbl %dl,%eax
  801927:	0f b6 c9             	movzbl %cl,%ecx
  80192a:	29 c8                	sub    %ecx,%eax
  80192c:	eb 10                	jmp    80193e <memcmp+0x4b>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80192e:	39 f8                	cmp    %edi,%eax
  801930:	75 e6                	jne    801918 <memcmp+0x25>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801932:	b8 00 00 00 00       	mov    $0x0,%eax
  801937:	eb 05                	jmp    80193e <memcmp+0x4b>
  801939:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80193e:	5b                   	pop    %ebx
  80193f:	5e                   	pop    %esi
  801940:	5f                   	pop    %edi
  801941:	5d                   	pop    %ebp
  801942:	c3                   	ret    

00801943 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801943:	55                   	push   %ebp
  801944:	89 e5                	mov    %esp,%ebp
  801946:	53                   	push   %ebx
  801947:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  80194a:	89 d0                	mov    %edx,%eax
  80194c:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  80194f:	39 c2                	cmp    %eax,%edx
  801951:	73 1b                	jae    80196e <memfind+0x2b>
		if (*(const unsigned char *) s == (unsigned char) c)
  801953:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  801957:	0f b6 0a             	movzbl (%edx),%ecx
  80195a:	39 d9                	cmp    %ebx,%ecx
  80195c:	75 09                	jne    801967 <memfind+0x24>
  80195e:	eb 12                	jmp    801972 <memfind+0x2f>
  801960:	0f b6 0a             	movzbl (%edx),%ecx
  801963:	39 d9                	cmp    %ebx,%ecx
  801965:	74 0f                	je     801976 <memfind+0x33>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801967:	42                   	inc    %edx
  801968:	39 d0                	cmp    %edx,%eax
  80196a:	75 f4                	jne    801960 <memfind+0x1d>
  80196c:	eb 0a                	jmp    801978 <memfind+0x35>
  80196e:	89 d0                	mov    %edx,%eax
  801970:	eb 06                	jmp    801978 <memfind+0x35>
		if (*(const unsigned char *) s == (unsigned char) c)
  801972:	89 d0                	mov    %edx,%eax
  801974:	eb 02                	jmp    801978 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801976:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801978:	5b                   	pop    %ebx
  801979:	5d                   	pop    %ebp
  80197a:	c3                   	ret    

0080197b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80197b:	55                   	push   %ebp
  80197c:	89 e5                	mov    %esp,%ebp
  80197e:	57                   	push   %edi
  80197f:	56                   	push   %esi
  801980:	53                   	push   %ebx
  801981:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801984:	eb 01                	jmp    801987 <strtol+0xc>
		s++;
  801986:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801987:	8a 01                	mov    (%ecx),%al
  801989:	3c 20                	cmp    $0x20,%al
  80198b:	74 f9                	je     801986 <strtol+0xb>
  80198d:	3c 09                	cmp    $0x9,%al
  80198f:	74 f5                	je     801986 <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  801991:	3c 2b                	cmp    $0x2b,%al
  801993:	75 08                	jne    80199d <strtol+0x22>
		s++;
  801995:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801996:	bf 00 00 00 00       	mov    $0x0,%edi
  80199b:	eb 11                	jmp    8019ae <strtol+0x33>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80199d:	3c 2d                	cmp    $0x2d,%al
  80199f:	75 08                	jne    8019a9 <strtol+0x2e>
		s++, neg = 1;
  8019a1:	41                   	inc    %ecx
  8019a2:	bf 01 00 00 00       	mov    $0x1,%edi
  8019a7:	eb 05                	jmp    8019ae <strtol+0x33>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8019a9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019ae:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019b2:	0f 84 87 00 00 00    	je     801a3f <strtol+0xc4>
  8019b8:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  8019bc:	75 27                	jne    8019e5 <strtol+0x6a>
  8019be:	80 39 30             	cmpb   $0x30,(%ecx)
  8019c1:	75 22                	jne    8019e5 <strtol+0x6a>
  8019c3:	e9 88 00 00 00       	jmp    801a50 <strtol+0xd5>
		s += 2, base = 16;
  8019c8:	83 c1 02             	add    $0x2,%ecx
  8019cb:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  8019d2:	eb 11                	jmp    8019e5 <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
  8019d4:	41                   	inc    %ecx
  8019d5:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  8019dc:	eb 07                	jmp    8019e5 <strtol+0x6a>
	else if (base == 0)
		base = 10;
  8019de:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  8019e5:	b8 00 00 00 00       	mov    $0x0,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019ea:	8a 11                	mov    (%ecx),%dl
  8019ec:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8019ef:	80 fb 09             	cmp    $0x9,%bl
  8019f2:	77 08                	ja     8019fc <strtol+0x81>
			dig = *s - '0';
  8019f4:	0f be d2             	movsbl %dl,%edx
  8019f7:	83 ea 30             	sub    $0x30,%edx
  8019fa:	eb 22                	jmp    801a1e <strtol+0xa3>
		else if (*s >= 'a' && *s <= 'z')
  8019fc:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019ff:	89 f3                	mov    %esi,%ebx
  801a01:	80 fb 19             	cmp    $0x19,%bl
  801a04:	77 08                	ja     801a0e <strtol+0x93>
			dig = *s - 'a' + 10;
  801a06:	0f be d2             	movsbl %dl,%edx
  801a09:	83 ea 57             	sub    $0x57,%edx
  801a0c:	eb 10                	jmp    801a1e <strtol+0xa3>
		else if (*s >= 'A' && *s <= 'Z')
  801a0e:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a11:	89 f3                	mov    %esi,%ebx
  801a13:	80 fb 19             	cmp    $0x19,%bl
  801a16:	77 14                	ja     801a2c <strtol+0xb1>
			dig = *s - 'A' + 10;
  801a18:	0f be d2             	movsbl %dl,%edx
  801a1b:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801a1e:	3b 55 10             	cmp    0x10(%ebp),%edx
  801a21:	7d 09                	jge    801a2c <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  801a23:	41                   	inc    %ecx
  801a24:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a28:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801a2a:	eb be                	jmp    8019ea <strtol+0x6f>

	if (endptr)
  801a2c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a30:	74 05                	je     801a37 <strtol+0xbc>
		*endptr = (char *) s;
  801a32:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a35:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801a37:	85 ff                	test   %edi,%edi
  801a39:	74 21                	je     801a5c <strtol+0xe1>
  801a3b:	f7 d8                	neg    %eax
  801a3d:	eb 1d                	jmp    801a5c <strtol+0xe1>
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801a3f:	80 39 30             	cmpb   $0x30,(%ecx)
  801a42:	75 9a                	jne    8019de <strtol+0x63>
  801a44:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801a48:	0f 84 7a ff ff ff    	je     8019c8 <strtol+0x4d>
  801a4e:	eb 84                	jmp    8019d4 <strtol+0x59>
  801a50:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801a54:	0f 84 6e ff ff ff    	je     8019c8 <strtol+0x4d>
  801a5a:	eb 89                	jmp    8019e5 <strtol+0x6a>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  801a5c:	5b                   	pop    %ebx
  801a5d:	5e                   	pop    %esi
  801a5e:	5f                   	pop    %edi
  801a5f:	5d                   	pop    %ebp
  801a60:	c3                   	ret    

00801a61 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a61:	55                   	push   %ebp
  801a62:	89 e5                	mov    %esp,%ebp
  801a64:	56                   	push   %esi
  801a65:	53                   	push   %ebx
  801a66:	8b 75 08             	mov    0x8(%ebp),%esi
  801a69:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a6c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");
	int r;
    if (pg != NULL) {
  801a6f:	85 c0                	test   %eax,%eax
  801a71:	74 0e                	je     801a81 <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  801a73:	83 ec 0c             	sub    $0xc,%esp
  801a76:	50                   	push   %eax
  801a77:	e8 9b e8 ff ff       	call   800317 <sys_ipc_recv>
  801a7c:	83 c4 10             	add    $0x10,%esp
  801a7f:	eb 10                	jmp    801a91 <ipc_recv+0x30>
    } else {
        r = sys_ipc_recv((void *) UTOP);
  801a81:	83 ec 0c             	sub    $0xc,%esp
  801a84:	68 00 00 c0 ee       	push   $0xeec00000
  801a89:	e8 89 e8 ff ff       	call   800317 <sys_ipc_recv>
  801a8e:	83 c4 10             	add    $0x10,%esp
    }
    if (r < 0) {
  801a91:	85 c0                	test   %eax,%eax
  801a93:	79 16                	jns    801aab <ipc_recv+0x4a>
        // failed
        if (from_env_store != NULL) *from_env_store = 0;
  801a95:	85 f6                	test   %esi,%esi
  801a97:	74 06                	je     801a9f <ipc_recv+0x3e>
  801a99:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL) *perm_store = 0;
  801a9f:	85 db                	test   %ebx,%ebx
  801aa1:	74 2c                	je     801acf <ipc_recv+0x6e>
  801aa3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801aa9:	eb 24                	jmp    801acf <ipc_recv+0x6e>
        return r;
    } else {
        if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801aab:	85 f6                	test   %esi,%esi
  801aad:	74 0a                	je     801ab9 <ipc_recv+0x58>
  801aaf:	a1 04 40 80 00       	mov    0x804004,%eax
  801ab4:	8b 40 74             	mov    0x74(%eax),%eax
  801ab7:	89 06                	mov    %eax,(%esi)
        if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801ab9:	85 db                	test   %ebx,%ebx
  801abb:	74 0a                	je     801ac7 <ipc_recv+0x66>
  801abd:	a1 04 40 80 00       	mov    0x804004,%eax
  801ac2:	8b 40 78             	mov    0x78(%eax),%eax
  801ac5:	89 03                	mov    %eax,(%ebx)
        return thisenv->env_ipc_value;
  801ac7:	a1 04 40 80 00       	mov    0x804004,%eax
  801acc:	8b 40 70             	mov    0x70(%eax),%eax
    }
 
	return 0;
}
  801acf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ad2:	5b                   	pop    %ebx
  801ad3:	5e                   	pop    %esi
  801ad4:	5d                   	pop    %ebp
  801ad5:	c3                   	ret    

00801ad6 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ad6:	55                   	push   %ebp
  801ad7:	89 e5                	mov    %esp,%ebp
  801ad9:	57                   	push   %edi
  801ada:	56                   	push   %esi
  801adb:	53                   	push   %ebx
  801adc:	83 ec 0c             	sub    $0xc,%esp
  801adf:	8b 75 10             	mov    0x10(%ebp),%esi
  801ae2:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;
    if (pg == NULL) pg = (void *)UTOP;
  801ae5:	85 f6                	test   %esi,%esi
  801ae7:	75 05                	jne    801aee <ipc_send+0x18>
  801ae9:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
  801aee:	57                   	push   %edi
  801aef:	56                   	push   %esi
  801af0:	ff 75 0c             	pushl  0xc(%ebp)
  801af3:	ff 75 08             	pushl  0x8(%ebp)
  801af6:	e8 f9 e7 ff ff       	call   8002f4 <sys_ipc_try_send>
  801afb:	89 c3                	mov    %eax,%ebx
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
  801afd:	83 c4 10             	add    $0x10,%esp
  801b00:	85 c0                	test   %eax,%eax
  801b02:	79 17                	jns    801b1b <ipc_send+0x45>
  801b04:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b07:	74 1d                	je     801b26 <ipc_send+0x50>
  801b09:	50                   	push   %eax
  801b0a:	68 80 22 80 00       	push   $0x802280
  801b0f:	6a 40                	push   $0x40
  801b11:	68 94 22 80 00       	push   $0x802294
  801b16:	e8 d5 f4 ff ff       	call   800ff0 <_panic>
        sys_yield();
  801b1b:	e8 28 e6 ff ff       	call   800148 <sys_yield>
    } while (r != 0);
  801b20:	85 db                	test   %ebx,%ebx
  801b22:	75 ca                	jne    801aee <ipc_send+0x18>
  801b24:	eb 07                	jmp    801b2d <ipc_send+0x57>
	int r;
    if (pg == NULL) pg = (void *)UTOP;
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
        sys_yield();
  801b26:	e8 1d e6 ff ff       	call   800148 <sys_yield>
  801b2b:	eb c1                	jmp    801aee <ipc_send+0x18>
    } while (r != 0);
}
  801b2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b30:	5b                   	pop    %ebx
  801b31:	5e                   	pop    %esi
  801b32:	5f                   	pop    %edi
  801b33:	5d                   	pop    %ebp
  801b34:	c3                   	ret    

00801b35 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b35:	55                   	push   %ebp
  801b36:	89 e5                	mov    %esp,%ebp
  801b38:	53                   	push   %ebx
  801b39:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801b3c:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801b41:	39 c1                	cmp    %eax,%ecx
  801b43:	74 21                	je     801b66 <ipc_find_env+0x31>
  801b45:	ba 01 00 00 00       	mov    $0x1,%edx
  801b4a:	8d 1c 95 00 00 00 00 	lea    0x0(,%edx,4),%ebx
  801b51:	89 d0                	mov    %edx,%eax
  801b53:	c1 e0 07             	shl    $0x7,%eax
  801b56:	29 d8                	sub    %ebx,%eax
  801b58:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b5d:	8b 40 50             	mov    0x50(%eax),%eax
  801b60:	39 c8                	cmp    %ecx,%eax
  801b62:	75 1b                	jne    801b7f <ipc_find_env+0x4a>
  801b64:	eb 05                	jmp    801b6b <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b66:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801b6b:	8d 04 95 00 00 00 00 	lea    0x0(,%edx,4),%eax
  801b72:	c1 e2 07             	shl    $0x7,%edx
  801b75:	29 c2                	sub    %eax,%edx
  801b77:	8b 82 48 00 c0 ee    	mov    -0x113fffb8(%edx),%eax
  801b7d:	eb 0e                	jmp    801b8d <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b7f:	42                   	inc    %edx
  801b80:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  801b86:	75 c2                	jne    801b4a <ipc_find_env+0x15>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b88:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b8d:	5b                   	pop    %ebx
  801b8e:	5d                   	pop    %ebp
  801b8f:	c3                   	ret    

00801b90 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b90:	55                   	push   %ebp
  801b91:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b93:	8b 45 08             	mov    0x8(%ebp),%eax
  801b96:	c1 e8 16             	shr    $0x16,%eax
  801b99:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801ba0:	a8 01                	test   $0x1,%al
  801ba2:	74 21                	je     801bc5 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801ba4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba7:	c1 e8 0c             	shr    $0xc,%eax
  801baa:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801bb1:	a8 01                	test   $0x1,%al
  801bb3:	74 17                	je     801bcc <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bb5:	c1 e8 0c             	shr    $0xc,%eax
  801bb8:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801bbf:	ef 
  801bc0:	0f b7 c0             	movzwl %ax,%eax
  801bc3:	eb 0c                	jmp    801bd1 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801bc5:	b8 00 00 00 00       	mov    $0x0,%eax
  801bca:	eb 05                	jmp    801bd1 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801bcc:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801bd1:	5d                   	pop    %ebp
  801bd2:	c3                   	ret    
  801bd3:	90                   	nop

00801bd4 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801bd4:	55                   	push   %ebp
  801bd5:	57                   	push   %edi
  801bd6:	56                   	push   %esi
  801bd7:	53                   	push   %ebx
  801bd8:	83 ec 1c             	sub    $0x1c,%esp
  801bdb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801bdf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801be3:	8b 7c 24 38          	mov    0x38(%esp),%edi
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801be7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801beb:	89 ca                	mov    %ecx,%edx
  const DWunion dd = {.ll = d};
  801bed:	89 f8                	mov    %edi,%eax
  801bef:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801bf3:	85 f6                	test   %esi,%esi
  801bf5:	75 2d                	jne    801c24 <__udivdi3+0x50>
    {
      if (d0 > n1)
  801bf7:	39 cf                	cmp    %ecx,%edi
  801bf9:	77 65                	ja     801c60 <__udivdi3+0x8c>
  801bfb:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801bfd:	85 ff                	test   %edi,%edi
  801bff:	75 0b                	jne    801c0c <__udivdi3+0x38>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801c01:	b8 01 00 00 00       	mov    $0x1,%eax
  801c06:	31 d2                	xor    %edx,%edx
  801c08:	f7 f7                	div    %edi
  801c0a:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801c0c:	31 d2                	xor    %edx,%edx
  801c0e:	89 c8                	mov    %ecx,%eax
  801c10:	f7 f5                	div    %ebp
  801c12:	89 c1                	mov    %eax,%ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c14:	89 d8                	mov    %ebx,%eax
  801c16:	f7 f5                	div    %ebp
  801c18:	89 cf                	mov    %ecx,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c1a:	89 fa                	mov    %edi,%edx
  801c1c:	83 c4 1c             	add    $0x1c,%esp
  801c1f:	5b                   	pop    %ebx
  801c20:	5e                   	pop    %esi
  801c21:	5f                   	pop    %edi
  801c22:	5d                   	pop    %ebp
  801c23:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801c24:	39 ce                	cmp    %ecx,%esi
  801c26:	77 28                	ja     801c50 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801c28:	0f bd fe             	bsr    %esi,%edi
	  if (bm == 0)
  801c2b:	83 f7 1f             	xor    $0x1f,%edi
  801c2e:	75 40                	jne    801c70 <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801c30:	39 ce                	cmp    %ecx,%esi
  801c32:	72 0a                	jb     801c3e <__udivdi3+0x6a>
  801c34:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801c38:	0f 87 9e 00 00 00    	ja     801cdc <__udivdi3+0x108>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801c3e:	b8 01 00 00 00       	mov    $0x1,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c43:	89 fa                	mov    %edi,%edx
  801c45:	83 c4 1c             	add    $0x1c,%esp
  801c48:	5b                   	pop    %ebx
  801c49:	5e                   	pop    %esi
  801c4a:	5f                   	pop    %edi
  801c4b:	5d                   	pop    %ebp
  801c4c:	c3                   	ret    
  801c4d:	8d 76 00             	lea    0x0(%esi),%esi
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801c50:	31 ff                	xor    %edi,%edi
  801c52:	31 c0                	xor    %eax,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c54:	89 fa                	mov    %edi,%edx
  801c56:	83 c4 1c             	add    $0x1c,%esp
  801c59:	5b                   	pop    %ebx
  801c5a:	5e                   	pop    %esi
  801c5b:	5f                   	pop    %edi
  801c5c:	5d                   	pop    %ebp
  801c5d:	c3                   	ret    
  801c5e:	66 90                	xchg   %ax,%ax
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c60:	89 d8                	mov    %ebx,%eax
  801c62:	f7 f7                	div    %edi
  801c64:	31 ff                	xor    %edi,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c66:	89 fa                	mov    %edi,%edx
  801c68:	83 c4 1c             	add    $0x1c,%esp
  801c6b:	5b                   	pop    %ebx
  801c6c:	5e                   	pop    %esi
  801c6d:	5f                   	pop    %edi
  801c6e:	5d                   	pop    %ebp
  801c6f:	c3                   	ret    
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801c70:	bd 20 00 00 00       	mov    $0x20,%ebp
  801c75:	89 eb                	mov    %ebp,%ebx
  801c77:	29 fb                	sub    %edi,%ebx

	      d1 = (d1 << bm) | (d0 >> b);
  801c79:	89 f9                	mov    %edi,%ecx
  801c7b:	d3 e6                	shl    %cl,%esi
  801c7d:	89 c5                	mov    %eax,%ebp
  801c7f:	88 d9                	mov    %bl,%cl
  801c81:	d3 ed                	shr    %cl,%ebp
  801c83:	89 e9                	mov    %ebp,%ecx
  801c85:	09 f1                	or     %esi,%ecx
  801c87:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
	      d0 = d0 << bm;
  801c8b:	89 f9                	mov    %edi,%ecx
  801c8d:	d3 e0                	shl    %cl,%eax
  801c8f:	89 c5                	mov    %eax,%ebp
	      n2 = n1 >> b;
  801c91:	89 d6                	mov    %edx,%esi
  801c93:	88 d9                	mov    %bl,%cl
  801c95:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
  801c97:	89 f9                	mov    %edi,%ecx
  801c99:	d3 e2                	shl    %cl,%edx
  801c9b:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c9f:	88 d9                	mov    %bl,%cl
  801ca1:	d3 e8                	shr    %cl,%eax
  801ca3:	09 c2                	or     %eax,%edx
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801ca5:	89 d0                	mov    %edx,%eax
  801ca7:	89 f2                	mov    %esi,%edx
  801ca9:	f7 74 24 0c          	divl   0xc(%esp)
  801cad:	89 d6                	mov    %edx,%esi
  801caf:	89 c3                	mov    %eax,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  801cb1:	f7 e5                	mul    %ebp

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801cb3:	39 d6                	cmp    %edx,%esi
  801cb5:	72 19                	jb     801cd0 <__udivdi3+0xfc>
  801cb7:	74 0b                	je     801cc4 <__udivdi3+0xf0>
  801cb9:	89 d8                	mov    %ebx,%eax
  801cbb:	31 ff                	xor    %edi,%edi
  801cbd:	e9 58 ff ff ff       	jmp    801c1a <__udivdi3+0x46>
  801cc2:	66 90                	xchg   %ax,%ax
  801cc4:	8b 54 24 08          	mov    0x8(%esp),%edx
  801cc8:	89 f9                	mov    %edi,%ecx
  801cca:	d3 e2                	shl    %cl,%edx
  801ccc:	39 c2                	cmp    %eax,%edx
  801cce:	73 e9                	jae    801cb9 <__udivdi3+0xe5>
  801cd0:	8d 43 ff             	lea    -0x1(%ebx),%eax
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801cd3:	31 ff                	xor    %edi,%edi
  801cd5:	e9 40 ff ff ff       	jmp    801c1a <__udivdi3+0x46>
  801cda:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801cdc:	31 c0                	xor    %eax,%eax
  801cde:	e9 37 ff ff ff       	jmp    801c1a <__udivdi3+0x46>
  801ce3:	90                   	nop

00801ce4 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801ce4:	55                   	push   %ebp
  801ce5:	57                   	push   %edi
  801ce6:	56                   	push   %esi
  801ce7:	53                   	push   %ebx
  801ce8:	83 ec 1c             	sub    $0x1c,%esp
  801ceb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801cef:	8b 74 24 34          	mov    0x34(%esp),%esi
  801cf3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801cf7:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801cfb:	89 44 24 0c          	mov    %eax,0xc(%esp)
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801cff:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d03:	89 f3                	mov    %esi,%ebx
  const DWunion dd = {.ll = d};
  801d05:	89 fa                	mov    %edi,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801d07:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  n1 = nn.s.high;
  801d0b:	89 34 24             	mov    %esi,(%esp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801d0e:	85 c0                	test   %eax,%eax
  801d10:	75 1a                	jne    801d2c <__umoddi3+0x48>
    {
      if (d0 > n1)
  801d12:	39 f7                	cmp    %esi,%edi
  801d14:	0f 86 a2 00 00 00    	jbe    801dbc <__umoddi3+0xd8>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d1a:	89 c8                	mov    %ecx,%eax
  801d1c:	89 f2                	mov    %esi,%edx
  801d1e:	f7 f7                	div    %edi
  801d20:	89 d0                	mov    %edx,%eax

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801d22:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d24:	83 c4 1c             	add    $0x1c,%esp
  801d27:	5b                   	pop    %ebx
  801d28:	5e                   	pop    %esi
  801d29:	5f                   	pop    %edi
  801d2a:	5d                   	pop    %ebp
  801d2b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801d2c:	39 f0                	cmp    %esi,%eax
  801d2e:	0f 87 ac 00 00 00    	ja     801de0 <__umoddi3+0xfc>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801d34:	0f bd e8             	bsr    %eax,%ebp
	  if (bm == 0)
  801d37:	83 f5 1f             	xor    $0x1f,%ebp
  801d3a:	0f 84 ac 00 00 00    	je     801dec <__umoddi3+0x108>
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801d40:	bf 20 00 00 00       	mov    $0x20,%edi
  801d45:	29 ef                	sub    %ebp,%edi
  801d47:	89 fe                	mov    %edi,%esi
  801d49:	89 7c 24 0c          	mov    %edi,0xc(%esp)

	      d1 = (d1 << bm) | (d0 >> b);
  801d4d:	89 e9                	mov    %ebp,%ecx
  801d4f:	d3 e0                	shl    %cl,%eax
  801d51:	89 d7                	mov    %edx,%edi
  801d53:	89 f1                	mov    %esi,%ecx
  801d55:	d3 ef                	shr    %cl,%edi
  801d57:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  801d59:	89 e9                	mov    %ebp,%ecx
  801d5b:	d3 e2                	shl    %cl,%edx
  801d5d:	89 14 24             	mov    %edx,(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801d60:	89 d8                	mov    %ebx,%eax
  801d62:	d3 e0                	shl    %cl,%eax
  801d64:	89 c2                	mov    %eax,%edx
	      n0 = n0 << bm;
  801d66:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d6a:	d3 e0                	shl    %cl,%eax
  801d6c:	89 44 24 04          	mov    %eax,0x4(%esp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801d70:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d74:	89 f1                	mov    %esi,%ecx
  801d76:	d3 e8                	shr    %cl,%eax
  801d78:	09 d0                	or     %edx,%eax
  801d7a:	d3 eb                	shr    %cl,%ebx
  801d7c:	89 da                	mov    %ebx,%edx
  801d7e:	f7 f7                	div    %edi
  801d80:	89 d3                	mov    %edx,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  801d82:	f7 24 24             	mull   (%esp)
  801d85:	89 c6                	mov    %eax,%esi
  801d87:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d89:	39 d3                	cmp    %edx,%ebx
  801d8b:	0f 82 87 00 00 00    	jb     801e18 <__umoddi3+0x134>
  801d91:	0f 84 91 00 00 00    	je     801e28 <__umoddi3+0x144>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801d97:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d9b:	29 f2                	sub    %esi,%edx
  801d9d:	19 cb                	sbb    %ecx,%ebx
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801d9f:	89 d8                	mov    %ebx,%eax
  801da1:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  801da5:	d3 e0                	shl    %cl,%eax
  801da7:	89 e9                	mov    %ebp,%ecx
  801da9:	d3 ea                	shr    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801dab:	09 d0                	or     %edx,%eax
  801dad:	89 e9                	mov    %ebp,%ecx
  801daf:	d3 eb                	shr    %cl,%ebx
  801db1:	89 da                	mov    %ebx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801db3:	83 c4 1c             	add    $0x1c,%esp
  801db6:	5b                   	pop    %ebx
  801db7:	5e                   	pop    %esi
  801db8:	5f                   	pop    %edi
  801db9:	5d                   	pop    %ebp
  801dba:	c3                   	ret    
  801dbb:	90                   	nop
  801dbc:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801dbe:	85 ff                	test   %edi,%edi
  801dc0:	75 0b                	jne    801dcd <__umoddi3+0xe9>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801dc2:	b8 01 00 00 00       	mov    $0x1,%eax
  801dc7:	31 d2                	xor    %edx,%edx
  801dc9:	f7 f7                	div    %edi
  801dcb:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801dcd:	89 f0                	mov    %esi,%eax
  801dcf:	31 d2                	xor    %edx,%edx
  801dd1:	f7 f5                	div    %ebp
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801dd3:	89 c8                	mov    %ecx,%eax
  801dd5:	f7 f5                	div    %ebp
  801dd7:	89 d0                	mov    %edx,%eax
  801dd9:	e9 44 ff ff ff       	jmp    801d22 <__umoddi3+0x3e>
  801dde:	66 90                	xchg   %ax,%ax
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801de0:	89 c8                	mov    %ecx,%eax
  801de2:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801de4:	83 c4 1c             	add    $0x1c,%esp
  801de7:	5b                   	pop    %ebx
  801de8:	5e                   	pop    %esi
  801de9:	5f                   	pop    %edi
  801dea:	5d                   	pop    %ebp
  801deb:	c3                   	ret    

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801dec:	3b 04 24             	cmp    (%esp),%eax
  801def:	72 06                	jb     801df7 <__umoddi3+0x113>
  801df1:	3b 7c 24 04          	cmp    0x4(%esp),%edi
  801df5:	77 0f                	ja     801e06 <__umoddi3+0x122>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801df7:	89 f2                	mov    %esi,%edx
  801df9:	29 f9                	sub    %edi,%ecx
  801dfb:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  801dff:	89 14 24             	mov    %edx,(%esp)
  801e02:	89 4c 24 04          	mov    %ecx,0x4(%esp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801e06:	8b 44 24 04          	mov    0x4(%esp),%eax
  801e0a:	8b 14 24             	mov    (%esp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e0d:	83 c4 1c             	add    $0x1c,%esp
  801e10:	5b                   	pop    %ebx
  801e11:	5e                   	pop    %esi
  801e12:	5f                   	pop    %edi
  801e13:	5d                   	pop    %ebp
  801e14:	c3                   	ret    
  801e15:	8d 76 00             	lea    0x0(%esi),%esi
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801e18:	2b 04 24             	sub    (%esp),%eax
  801e1b:	19 fa                	sbb    %edi,%edx
  801e1d:	89 d1                	mov    %edx,%ecx
  801e1f:	89 c6                	mov    %eax,%esi
  801e21:	e9 71 ff ff ff       	jmp    801d97 <__umoddi3+0xb3>
  801e26:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e28:	39 44 24 04          	cmp    %eax,0x4(%esp)
  801e2c:	72 ea                	jb     801e18 <__umoddi3+0x134>
  801e2e:	89 d9                	mov    %ebx,%ecx
  801e30:	e9 62 ff ff ff       	jmp    801d97 <__umoddi3+0xb3>
