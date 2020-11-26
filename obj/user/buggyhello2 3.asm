
obj/user/buggyhello2.debug:     file format elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_cputs(hello, 1024*1024);
  800039:	68 00 00 10 00       	push   $0x100000
  80003e:	ff 35 00 30 80 00    	pushl  0x803000
  800044:	e8 6e 00 00 00       	call   8000b7 <sys_cputs>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800056:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800059:	e8 d7 00 00 00       	call   800135 <sys_getenvid>
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80006a:	c1 e0 07             	shl    $0x7,%eax
  80006d:	29 d0                	sub    %edx,%eax
  80006f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800074:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800079:	85 db                	test   %ebx,%ebx
  80007b:	7e 07                	jle    800084 <libmain+0x36>
		binaryname = argv[0];
  80007d:	8b 06                	mov    (%esi),%eax
  80007f:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  800084:	83 ec 08             	sub    $0x8,%esp
  800087:	56                   	push   %esi
  800088:	53                   	push   %ebx
  800089:	e8 a5 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008e:	e8 0a 00 00 00       	call   80009d <exit>
}
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800099:	5b                   	pop    %ebx
  80009a:	5e                   	pop    %esi
  80009b:	5d                   	pop    %ebp
  80009c:	c3                   	ret    

0080009d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009d:	55                   	push   %ebp
  80009e:	89 e5                	mov    %esp,%ebp
  8000a0:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000a3:	e8 cb 04 00 00       	call   800573 <close_all>
	sys_env_destroy(0);
  8000a8:	83 ec 0c             	sub    $0xc,%esp
  8000ab:	6a 00                	push   $0x0
  8000ad:	e8 42 00 00 00       	call   8000f4 <sys_env_destroy>
}
  8000b2:	83 c4 10             	add    $0x10,%esp
  8000b5:	c9                   	leave  
  8000b6:	c3                   	ret    

008000b7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b7:	55                   	push   %ebp
  8000b8:	89 e5                	mov    %esp,%ebp
  8000ba:	57                   	push   %edi
  8000bb:	56                   	push   %esi
  8000bc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c5:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c8:	89 c3                	mov    %eax,%ebx
  8000ca:	89 c7                	mov    %eax,%edi
  8000cc:	89 c6                	mov    %eax,%esi
  8000ce:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d0:	5b                   	pop    %ebx
  8000d1:	5e                   	pop    %esi
  8000d2:	5f                   	pop    %edi
  8000d3:	5d                   	pop    %ebp
  8000d4:	c3                   	ret    

008000d5 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d5:	55                   	push   %ebp
  8000d6:	89 e5                	mov    %esp,%ebp
  8000d8:	57                   	push   %edi
  8000d9:	56                   	push   %esi
  8000da:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000db:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e0:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e5:	89 d1                	mov    %edx,%ecx
  8000e7:	89 d3                	mov    %edx,%ebx
  8000e9:	89 d7                	mov    %edx,%edi
  8000eb:	89 d6                	mov    %edx,%esi
  8000ed:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ef:	5b                   	pop    %ebx
  8000f0:	5e                   	pop    %esi
  8000f1:	5f                   	pop    %edi
  8000f2:	5d                   	pop    %ebp
  8000f3:	c3                   	ret    

008000f4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f4:	55                   	push   %ebp
  8000f5:	89 e5                	mov    %esp,%ebp
  8000f7:	57                   	push   %edi
  8000f8:	56                   	push   %esi
  8000f9:	53                   	push   %ebx
  8000fa:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000fd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800102:	b8 03 00 00 00       	mov    $0x3,%eax
  800107:	8b 55 08             	mov    0x8(%ebp),%edx
  80010a:	89 cb                	mov    %ecx,%ebx
  80010c:	89 cf                	mov    %ecx,%edi
  80010e:	89 ce                	mov    %ecx,%esi
  800110:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800112:	85 c0                	test   %eax,%eax
  800114:	7e 17                	jle    80012d <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800116:	83 ec 0c             	sub    $0xc,%esp
  800119:	50                   	push   %eax
  80011a:	6a 03                	push   $0x3
  80011c:	68 78 1e 80 00       	push   $0x801e78
  800121:	6a 23                	push   $0x23
  800123:	68 95 1e 80 00       	push   $0x801e95
  800128:	e8 cf 0e 00 00       	call   800ffc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80012d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800130:	5b                   	pop    %ebx
  800131:	5e                   	pop    %esi
  800132:	5f                   	pop    %edi
  800133:	5d                   	pop    %ebp
  800134:	c3                   	ret    

00800135 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800135:	55                   	push   %ebp
  800136:	89 e5                	mov    %esp,%ebp
  800138:	57                   	push   %edi
  800139:	56                   	push   %esi
  80013a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80013b:	ba 00 00 00 00       	mov    $0x0,%edx
  800140:	b8 02 00 00 00       	mov    $0x2,%eax
  800145:	89 d1                	mov    %edx,%ecx
  800147:	89 d3                	mov    %edx,%ebx
  800149:	89 d7                	mov    %edx,%edi
  80014b:	89 d6                	mov    %edx,%esi
  80014d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80014f:	5b                   	pop    %ebx
  800150:	5e                   	pop    %esi
  800151:	5f                   	pop    %edi
  800152:	5d                   	pop    %ebp
  800153:	c3                   	ret    

00800154 <sys_yield>:

void
sys_yield(void)
{
  800154:	55                   	push   %ebp
  800155:	89 e5                	mov    %esp,%ebp
  800157:	57                   	push   %edi
  800158:	56                   	push   %esi
  800159:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80015a:	ba 00 00 00 00       	mov    $0x0,%edx
  80015f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800164:	89 d1                	mov    %edx,%ecx
  800166:	89 d3                	mov    %edx,%ebx
  800168:	89 d7                	mov    %edx,%edi
  80016a:	89 d6                	mov    %edx,%esi
  80016c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80016e:	5b                   	pop    %ebx
  80016f:	5e                   	pop    %esi
  800170:	5f                   	pop    %edi
  800171:	5d                   	pop    %ebp
  800172:	c3                   	ret    

00800173 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800173:	55                   	push   %ebp
  800174:	89 e5                	mov    %esp,%ebp
  800176:	57                   	push   %edi
  800177:	56                   	push   %esi
  800178:	53                   	push   %ebx
  800179:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80017c:	be 00 00 00 00       	mov    $0x0,%esi
  800181:	b8 04 00 00 00       	mov    $0x4,%eax
  800186:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800189:	8b 55 08             	mov    0x8(%ebp),%edx
  80018c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80018f:	89 f7                	mov    %esi,%edi
  800191:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800193:	85 c0                	test   %eax,%eax
  800195:	7e 17                	jle    8001ae <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800197:	83 ec 0c             	sub    $0xc,%esp
  80019a:	50                   	push   %eax
  80019b:	6a 04                	push   $0x4
  80019d:	68 78 1e 80 00       	push   $0x801e78
  8001a2:	6a 23                	push   $0x23
  8001a4:	68 95 1e 80 00       	push   $0x801e95
  8001a9:	e8 4e 0e 00 00       	call   800ffc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001b1:	5b                   	pop    %ebx
  8001b2:	5e                   	pop    %esi
  8001b3:	5f                   	pop    %edi
  8001b4:	5d                   	pop    %ebp
  8001b5:	c3                   	ret    

008001b6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001b6:	55                   	push   %ebp
  8001b7:	89 e5                	mov    %esp,%ebp
  8001b9:	57                   	push   %edi
  8001ba:	56                   	push   %esi
  8001bb:	53                   	push   %ebx
  8001bc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001bf:	b8 05 00 00 00       	mov    $0x5,%eax
  8001c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ca:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001cd:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001d0:	8b 75 18             	mov    0x18(%ebp),%esi
  8001d3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001d5:	85 c0                	test   %eax,%eax
  8001d7:	7e 17                	jle    8001f0 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d9:	83 ec 0c             	sub    $0xc,%esp
  8001dc:	50                   	push   %eax
  8001dd:	6a 05                	push   $0x5
  8001df:	68 78 1e 80 00       	push   $0x801e78
  8001e4:	6a 23                	push   $0x23
  8001e6:	68 95 1e 80 00       	push   $0x801e95
  8001eb:	e8 0c 0e 00 00       	call   800ffc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001f3:	5b                   	pop    %ebx
  8001f4:	5e                   	pop    %esi
  8001f5:	5f                   	pop    %edi
  8001f6:	5d                   	pop    %ebp
  8001f7:	c3                   	ret    

008001f8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001f8:	55                   	push   %ebp
  8001f9:	89 e5                	mov    %esp,%ebp
  8001fb:	57                   	push   %edi
  8001fc:	56                   	push   %esi
  8001fd:	53                   	push   %ebx
  8001fe:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800201:	bb 00 00 00 00       	mov    $0x0,%ebx
  800206:	b8 06 00 00 00       	mov    $0x6,%eax
  80020b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80020e:	8b 55 08             	mov    0x8(%ebp),%edx
  800211:	89 df                	mov    %ebx,%edi
  800213:	89 de                	mov    %ebx,%esi
  800215:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800217:	85 c0                	test   %eax,%eax
  800219:	7e 17                	jle    800232 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80021b:	83 ec 0c             	sub    $0xc,%esp
  80021e:	50                   	push   %eax
  80021f:	6a 06                	push   $0x6
  800221:	68 78 1e 80 00       	push   $0x801e78
  800226:	6a 23                	push   $0x23
  800228:	68 95 1e 80 00       	push   $0x801e95
  80022d:	e8 ca 0d 00 00       	call   800ffc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800232:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800235:	5b                   	pop    %ebx
  800236:	5e                   	pop    %esi
  800237:	5f                   	pop    %edi
  800238:	5d                   	pop    %ebp
  800239:	c3                   	ret    

0080023a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80023a:	55                   	push   %ebp
  80023b:	89 e5                	mov    %esp,%ebp
  80023d:	57                   	push   %edi
  80023e:	56                   	push   %esi
  80023f:	53                   	push   %ebx
  800240:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800243:	bb 00 00 00 00       	mov    $0x0,%ebx
  800248:	b8 08 00 00 00       	mov    $0x8,%eax
  80024d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800250:	8b 55 08             	mov    0x8(%ebp),%edx
  800253:	89 df                	mov    %ebx,%edi
  800255:	89 de                	mov    %ebx,%esi
  800257:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800259:	85 c0                	test   %eax,%eax
  80025b:	7e 17                	jle    800274 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80025d:	83 ec 0c             	sub    $0xc,%esp
  800260:	50                   	push   %eax
  800261:	6a 08                	push   $0x8
  800263:	68 78 1e 80 00       	push   $0x801e78
  800268:	6a 23                	push   $0x23
  80026a:	68 95 1e 80 00       	push   $0x801e95
  80026f:	e8 88 0d 00 00       	call   800ffc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800274:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800277:	5b                   	pop    %ebx
  800278:	5e                   	pop    %esi
  800279:	5f                   	pop    %edi
  80027a:	5d                   	pop    %ebp
  80027b:	c3                   	ret    

0080027c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80027c:	55                   	push   %ebp
  80027d:	89 e5                	mov    %esp,%ebp
  80027f:	57                   	push   %edi
  800280:	56                   	push   %esi
  800281:	53                   	push   %ebx
  800282:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800285:	bb 00 00 00 00       	mov    $0x0,%ebx
  80028a:	b8 09 00 00 00       	mov    $0x9,%eax
  80028f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800292:	8b 55 08             	mov    0x8(%ebp),%edx
  800295:	89 df                	mov    %ebx,%edi
  800297:	89 de                	mov    %ebx,%esi
  800299:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80029b:	85 c0                	test   %eax,%eax
  80029d:	7e 17                	jle    8002b6 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80029f:	83 ec 0c             	sub    $0xc,%esp
  8002a2:	50                   	push   %eax
  8002a3:	6a 09                	push   $0x9
  8002a5:	68 78 1e 80 00       	push   $0x801e78
  8002aa:	6a 23                	push   $0x23
  8002ac:	68 95 1e 80 00       	push   $0x801e95
  8002b1:	e8 46 0d 00 00       	call   800ffc <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b9:	5b                   	pop    %ebx
  8002ba:	5e                   	pop    %esi
  8002bb:	5f                   	pop    %edi
  8002bc:	5d                   	pop    %ebp
  8002bd:	c3                   	ret    

008002be <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002be:	55                   	push   %ebp
  8002bf:	89 e5                	mov    %esp,%ebp
  8002c1:	57                   	push   %edi
  8002c2:	56                   	push   %esi
  8002c3:	53                   	push   %ebx
  8002c4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002c7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002cc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d7:	89 df                	mov    %ebx,%edi
  8002d9:	89 de                	mov    %ebx,%esi
  8002db:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002dd:	85 c0                	test   %eax,%eax
  8002df:	7e 17                	jle    8002f8 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e1:	83 ec 0c             	sub    $0xc,%esp
  8002e4:	50                   	push   %eax
  8002e5:	6a 0a                	push   $0xa
  8002e7:	68 78 1e 80 00       	push   $0x801e78
  8002ec:	6a 23                	push   $0x23
  8002ee:	68 95 1e 80 00       	push   $0x801e95
  8002f3:	e8 04 0d 00 00       	call   800ffc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002fb:	5b                   	pop    %ebx
  8002fc:	5e                   	pop    %esi
  8002fd:	5f                   	pop    %edi
  8002fe:	5d                   	pop    %ebp
  8002ff:	c3                   	ret    

00800300 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800300:	55                   	push   %ebp
  800301:	89 e5                	mov    %esp,%ebp
  800303:	57                   	push   %edi
  800304:	56                   	push   %esi
  800305:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800306:	be 00 00 00 00       	mov    $0x0,%esi
  80030b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800310:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800313:	8b 55 08             	mov    0x8(%ebp),%edx
  800316:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800319:	8b 7d 14             	mov    0x14(%ebp),%edi
  80031c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80031e:	5b                   	pop    %ebx
  80031f:	5e                   	pop    %esi
  800320:	5f                   	pop    %edi
  800321:	5d                   	pop    %ebp
  800322:	c3                   	ret    

00800323 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800323:	55                   	push   %ebp
  800324:	89 e5                	mov    %esp,%ebp
  800326:	57                   	push   %edi
  800327:	56                   	push   %esi
  800328:	53                   	push   %ebx
  800329:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80032c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800331:	b8 0d 00 00 00       	mov    $0xd,%eax
  800336:	8b 55 08             	mov    0x8(%ebp),%edx
  800339:	89 cb                	mov    %ecx,%ebx
  80033b:	89 cf                	mov    %ecx,%edi
  80033d:	89 ce                	mov    %ecx,%esi
  80033f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800341:	85 c0                	test   %eax,%eax
  800343:	7e 17                	jle    80035c <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800345:	83 ec 0c             	sub    $0xc,%esp
  800348:	50                   	push   %eax
  800349:	6a 0d                	push   $0xd
  80034b:	68 78 1e 80 00       	push   $0x801e78
  800350:	6a 23                	push   $0x23
  800352:	68 95 1e 80 00       	push   $0x801e95
  800357:	e8 a0 0c 00 00       	call   800ffc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80035c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80035f:	5b                   	pop    %ebx
  800360:	5e                   	pop    %esi
  800361:	5f                   	pop    %edi
  800362:	5d                   	pop    %ebp
  800363:	c3                   	ret    

00800364 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800364:	55                   	push   %ebp
  800365:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800367:	8b 45 08             	mov    0x8(%ebp),%eax
  80036a:	05 00 00 00 30       	add    $0x30000000,%eax
  80036f:	c1 e8 0c             	shr    $0xc,%eax
}
  800372:	5d                   	pop    %ebp
  800373:	c3                   	ret    

00800374 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800374:	55                   	push   %ebp
  800375:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800377:	8b 45 08             	mov    0x8(%ebp),%eax
  80037a:	05 00 00 00 30       	add    $0x30000000,%eax
  80037f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800384:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800389:	5d                   	pop    %ebp
  80038a:	c3                   	ret    

0080038b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80038b:	55                   	push   %ebp
  80038c:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80038e:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800393:	a8 01                	test   $0x1,%al
  800395:	74 34                	je     8003cb <fd_alloc+0x40>
  800397:	a1 00 00 74 ef       	mov    0xef740000,%eax
  80039c:	a8 01                	test   $0x1,%al
  80039e:	74 32                	je     8003d2 <fd_alloc+0x47>
  8003a0:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8003a5:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003a7:	89 c2                	mov    %eax,%edx
  8003a9:	c1 ea 16             	shr    $0x16,%edx
  8003ac:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003b3:	f6 c2 01             	test   $0x1,%dl
  8003b6:	74 1f                	je     8003d7 <fd_alloc+0x4c>
  8003b8:	89 c2                	mov    %eax,%edx
  8003ba:	c1 ea 0c             	shr    $0xc,%edx
  8003bd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003c4:	f6 c2 01             	test   $0x1,%dl
  8003c7:	75 1a                	jne    8003e3 <fd_alloc+0x58>
  8003c9:	eb 0c                	jmp    8003d7 <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8003cb:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8003d0:	eb 05                	jmp    8003d7 <fd_alloc+0x4c>
  8003d2:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8003d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003da:	89 08                	mov    %ecx,(%eax)
			return 0;
  8003dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8003e1:	eb 1a                	jmp    8003fd <fd_alloc+0x72>
  8003e3:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003e8:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003ed:	75 b6                	jne    8003a5 <fd_alloc+0x1a>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  8003f8:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003fd:	5d                   	pop    %ebp
  8003fe:	c3                   	ret    

008003ff <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003ff:	55                   	push   %ebp
  800400:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800402:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  800406:	77 39                	ja     800441 <fd_lookup+0x42>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800408:	8b 45 08             	mov    0x8(%ebp),%eax
  80040b:	c1 e0 0c             	shl    $0xc,%eax
  80040e:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800413:	89 c2                	mov    %eax,%edx
  800415:	c1 ea 16             	shr    $0x16,%edx
  800418:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80041f:	f6 c2 01             	test   $0x1,%dl
  800422:	74 24                	je     800448 <fd_lookup+0x49>
  800424:	89 c2                	mov    %eax,%edx
  800426:	c1 ea 0c             	shr    $0xc,%edx
  800429:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800430:	f6 c2 01             	test   $0x1,%dl
  800433:	74 1a                	je     80044f <fd_lookup+0x50>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800435:	8b 55 0c             	mov    0xc(%ebp),%edx
  800438:	89 02                	mov    %eax,(%edx)
	return 0;
  80043a:	b8 00 00 00 00       	mov    $0x0,%eax
  80043f:	eb 13                	jmp    800454 <fd_lookup+0x55>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800441:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800446:	eb 0c                	jmp    800454 <fd_lookup+0x55>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800448:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80044d:	eb 05                	jmp    800454 <fd_lookup+0x55>
  80044f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800454:	5d                   	pop    %ebp
  800455:	c3                   	ret    

00800456 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800456:	55                   	push   %ebp
  800457:	89 e5                	mov    %esp,%ebp
  800459:	53                   	push   %ebx
  80045a:	83 ec 04             	sub    $0x4,%esp
  80045d:	8b 45 08             	mov    0x8(%ebp),%eax
  800460:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800463:	3b 05 08 30 80 00    	cmp    0x803008,%eax
  800469:	75 1e                	jne    800489 <dev_lookup+0x33>
  80046b:	eb 0e                	jmp    80047b <dev_lookup+0x25>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80046d:	b8 24 30 80 00       	mov    $0x803024,%eax
  800472:	eb 0c                	jmp    800480 <dev_lookup+0x2a>
  800474:	b8 40 30 80 00       	mov    $0x803040,%eax
  800479:	eb 05                	jmp    800480 <dev_lookup+0x2a>
  80047b:	b8 08 30 80 00       	mov    $0x803008,%eax
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800480:	89 03                	mov    %eax,(%ebx)
			return 0;
  800482:	b8 00 00 00 00       	mov    $0x0,%eax
  800487:	eb 36                	jmp    8004bf <dev_lookup+0x69>
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800489:	3b 05 24 30 80 00    	cmp    0x803024,%eax
  80048f:	74 dc                	je     80046d <dev_lookup+0x17>
  800491:	3b 05 40 30 80 00    	cmp    0x803040,%eax
  800497:	74 db                	je     800474 <dev_lookup+0x1e>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800499:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80049f:	8b 52 48             	mov    0x48(%edx),%edx
  8004a2:	83 ec 04             	sub    $0x4,%esp
  8004a5:	50                   	push   %eax
  8004a6:	52                   	push   %edx
  8004a7:	68 a4 1e 80 00       	push   $0x801ea4
  8004ac:	e8 23 0c 00 00       	call   8010d4 <cprintf>
	*dev = 0;
  8004b1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8004b7:	83 c4 10             	add    $0x10,%esp
  8004ba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004c2:	c9                   	leave  
  8004c3:	c3                   	ret    

008004c4 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004c4:	55                   	push   %ebp
  8004c5:	89 e5                	mov    %esp,%ebp
  8004c7:	56                   	push   %esi
  8004c8:	53                   	push   %ebx
  8004c9:	83 ec 10             	sub    $0x10,%esp
  8004cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8004cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004d5:	50                   	push   %eax
  8004d6:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004dc:	c1 e8 0c             	shr    $0xc,%eax
  8004df:	50                   	push   %eax
  8004e0:	e8 1a ff ff ff       	call   8003ff <fd_lookup>
  8004e5:	83 c4 08             	add    $0x8,%esp
  8004e8:	85 c0                	test   %eax,%eax
  8004ea:	78 05                	js     8004f1 <fd_close+0x2d>
	    || fd != fd2)
  8004ec:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004ef:	74 06                	je     8004f7 <fd_close+0x33>
		return (must_exist ? r : 0);
  8004f1:	84 db                	test   %bl,%bl
  8004f3:	74 47                	je     80053c <fd_close+0x78>
  8004f5:	eb 4a                	jmp    800541 <fd_close+0x7d>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004f7:	83 ec 08             	sub    $0x8,%esp
  8004fa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004fd:	50                   	push   %eax
  8004fe:	ff 36                	pushl  (%esi)
  800500:	e8 51 ff ff ff       	call   800456 <dev_lookup>
  800505:	89 c3                	mov    %eax,%ebx
  800507:	83 c4 10             	add    $0x10,%esp
  80050a:	85 c0                	test   %eax,%eax
  80050c:	78 1c                	js     80052a <fd_close+0x66>
		if (dev->dev_close)
  80050e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800511:	8b 40 10             	mov    0x10(%eax),%eax
  800514:	85 c0                	test   %eax,%eax
  800516:	74 0d                	je     800525 <fd_close+0x61>
			r = (*dev->dev_close)(fd);
  800518:	83 ec 0c             	sub    $0xc,%esp
  80051b:	56                   	push   %esi
  80051c:	ff d0                	call   *%eax
  80051e:	89 c3                	mov    %eax,%ebx
  800520:	83 c4 10             	add    $0x10,%esp
  800523:	eb 05                	jmp    80052a <fd_close+0x66>
		else
			r = 0;
  800525:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80052a:	83 ec 08             	sub    $0x8,%esp
  80052d:	56                   	push   %esi
  80052e:	6a 00                	push   $0x0
  800530:	e8 c3 fc ff ff       	call   8001f8 <sys_page_unmap>
	return r;
  800535:	83 c4 10             	add    $0x10,%esp
  800538:	89 d8                	mov    %ebx,%eax
  80053a:	eb 05                	jmp    800541 <fd_close+0x7d>
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
  80053c:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
	return r;
}
  800541:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800544:	5b                   	pop    %ebx
  800545:	5e                   	pop    %esi
  800546:	5d                   	pop    %ebp
  800547:	c3                   	ret    

00800548 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800548:	55                   	push   %ebp
  800549:	89 e5                	mov    %esp,%ebp
  80054b:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80054e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800551:	50                   	push   %eax
  800552:	ff 75 08             	pushl  0x8(%ebp)
  800555:	e8 a5 fe ff ff       	call   8003ff <fd_lookup>
  80055a:	83 c4 08             	add    $0x8,%esp
  80055d:	85 c0                	test   %eax,%eax
  80055f:	78 10                	js     800571 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800561:	83 ec 08             	sub    $0x8,%esp
  800564:	6a 01                	push   $0x1
  800566:	ff 75 f4             	pushl  -0xc(%ebp)
  800569:	e8 56 ff ff ff       	call   8004c4 <fd_close>
  80056e:	83 c4 10             	add    $0x10,%esp
}
  800571:	c9                   	leave  
  800572:	c3                   	ret    

00800573 <close_all>:

void
close_all(void)
{
  800573:	55                   	push   %ebp
  800574:	89 e5                	mov    %esp,%ebp
  800576:	53                   	push   %ebx
  800577:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80057a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80057f:	83 ec 0c             	sub    $0xc,%esp
  800582:	53                   	push   %ebx
  800583:	e8 c0 ff ff ff       	call   800548 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800588:	43                   	inc    %ebx
  800589:	83 c4 10             	add    $0x10,%esp
  80058c:	83 fb 20             	cmp    $0x20,%ebx
  80058f:	75 ee                	jne    80057f <close_all+0xc>
		close(i);
}
  800591:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800594:	c9                   	leave  
  800595:	c3                   	ret    

00800596 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800596:	55                   	push   %ebp
  800597:	89 e5                	mov    %esp,%ebp
  800599:	57                   	push   %edi
  80059a:	56                   	push   %esi
  80059b:	53                   	push   %ebx
  80059c:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80059f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005a2:	50                   	push   %eax
  8005a3:	ff 75 08             	pushl  0x8(%ebp)
  8005a6:	e8 54 fe ff ff       	call   8003ff <fd_lookup>
  8005ab:	83 c4 08             	add    $0x8,%esp
  8005ae:	85 c0                	test   %eax,%eax
  8005b0:	0f 88 c2 00 00 00    	js     800678 <dup+0xe2>
		return r;
	close(newfdnum);
  8005b6:	83 ec 0c             	sub    $0xc,%esp
  8005b9:	ff 75 0c             	pushl  0xc(%ebp)
  8005bc:	e8 87 ff ff ff       	call   800548 <close>

	newfd = INDEX2FD(newfdnum);
  8005c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005c4:	c1 e3 0c             	shl    $0xc,%ebx
  8005c7:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8005cd:	83 c4 04             	add    $0x4,%esp
  8005d0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005d3:	e8 9c fd ff ff       	call   800374 <fd2data>
  8005d8:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  8005da:	89 1c 24             	mov    %ebx,(%esp)
  8005dd:	e8 92 fd ff ff       	call   800374 <fd2data>
  8005e2:	83 c4 10             	add    $0x10,%esp
  8005e5:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005e7:	89 f0                	mov    %esi,%eax
  8005e9:	c1 e8 16             	shr    $0x16,%eax
  8005ec:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005f3:	a8 01                	test   $0x1,%al
  8005f5:	74 35                	je     80062c <dup+0x96>
  8005f7:	89 f0                	mov    %esi,%eax
  8005f9:	c1 e8 0c             	shr    $0xc,%eax
  8005fc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800603:	f6 c2 01             	test   $0x1,%dl
  800606:	74 24                	je     80062c <dup+0x96>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800608:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80060f:	83 ec 0c             	sub    $0xc,%esp
  800612:	25 07 0e 00 00       	and    $0xe07,%eax
  800617:	50                   	push   %eax
  800618:	57                   	push   %edi
  800619:	6a 00                	push   $0x0
  80061b:	56                   	push   %esi
  80061c:	6a 00                	push   $0x0
  80061e:	e8 93 fb ff ff       	call   8001b6 <sys_page_map>
  800623:	89 c6                	mov    %eax,%esi
  800625:	83 c4 20             	add    $0x20,%esp
  800628:	85 c0                	test   %eax,%eax
  80062a:	78 2c                	js     800658 <dup+0xc2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80062c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80062f:	89 d0                	mov    %edx,%eax
  800631:	c1 e8 0c             	shr    $0xc,%eax
  800634:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80063b:	83 ec 0c             	sub    $0xc,%esp
  80063e:	25 07 0e 00 00       	and    $0xe07,%eax
  800643:	50                   	push   %eax
  800644:	53                   	push   %ebx
  800645:	6a 00                	push   $0x0
  800647:	52                   	push   %edx
  800648:	6a 00                	push   $0x0
  80064a:	e8 67 fb ff ff       	call   8001b6 <sys_page_map>
  80064f:	89 c6                	mov    %eax,%esi
  800651:	83 c4 20             	add    $0x20,%esp
  800654:	85 c0                	test   %eax,%eax
  800656:	79 1d                	jns    800675 <dup+0xdf>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800658:	83 ec 08             	sub    $0x8,%esp
  80065b:	53                   	push   %ebx
  80065c:	6a 00                	push   $0x0
  80065e:	e8 95 fb ff ff       	call   8001f8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800663:	83 c4 08             	add    $0x8,%esp
  800666:	57                   	push   %edi
  800667:	6a 00                	push   $0x0
  800669:	e8 8a fb ff ff       	call   8001f8 <sys_page_unmap>
	return r;
  80066e:	83 c4 10             	add    $0x10,%esp
  800671:	89 f0                	mov    %esi,%eax
  800673:	eb 03                	jmp    800678 <dup+0xe2>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  800675:	8b 45 0c             	mov    0xc(%ebp),%eax

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800678:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80067b:	5b                   	pop    %ebx
  80067c:	5e                   	pop    %esi
  80067d:	5f                   	pop    %edi
  80067e:	5d                   	pop    %ebp
  80067f:	c3                   	ret    

00800680 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800680:	55                   	push   %ebp
  800681:	89 e5                	mov    %esp,%ebp
  800683:	53                   	push   %ebx
  800684:	83 ec 14             	sub    $0x14,%esp
  800687:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80068a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80068d:	50                   	push   %eax
  80068e:	53                   	push   %ebx
  80068f:	e8 6b fd ff ff       	call   8003ff <fd_lookup>
  800694:	83 c4 08             	add    $0x8,%esp
  800697:	85 c0                	test   %eax,%eax
  800699:	78 67                	js     800702 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80069b:	83 ec 08             	sub    $0x8,%esp
  80069e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006a1:	50                   	push   %eax
  8006a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006a5:	ff 30                	pushl  (%eax)
  8006a7:	e8 aa fd ff ff       	call   800456 <dev_lookup>
  8006ac:	83 c4 10             	add    $0x10,%esp
  8006af:	85 c0                	test   %eax,%eax
  8006b1:	78 4f                	js     800702 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006b3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006b6:	8b 42 08             	mov    0x8(%edx),%eax
  8006b9:	83 e0 03             	and    $0x3,%eax
  8006bc:	83 f8 01             	cmp    $0x1,%eax
  8006bf:	75 21                	jne    8006e2 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006c1:	a1 04 40 80 00       	mov    0x804004,%eax
  8006c6:	8b 40 48             	mov    0x48(%eax),%eax
  8006c9:	83 ec 04             	sub    $0x4,%esp
  8006cc:	53                   	push   %ebx
  8006cd:	50                   	push   %eax
  8006ce:	68 e5 1e 80 00       	push   $0x801ee5
  8006d3:	e8 fc 09 00 00       	call   8010d4 <cprintf>
		return -E_INVAL;
  8006d8:	83 c4 10             	add    $0x10,%esp
  8006db:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006e0:	eb 20                	jmp    800702 <read+0x82>
	}
	if (!dev->dev_read)
  8006e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006e5:	8b 40 08             	mov    0x8(%eax),%eax
  8006e8:	85 c0                	test   %eax,%eax
  8006ea:	74 11                	je     8006fd <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006ec:	83 ec 04             	sub    $0x4,%esp
  8006ef:	ff 75 10             	pushl  0x10(%ebp)
  8006f2:	ff 75 0c             	pushl  0xc(%ebp)
  8006f5:	52                   	push   %edx
  8006f6:	ff d0                	call   *%eax
  8006f8:	83 c4 10             	add    $0x10,%esp
  8006fb:	eb 05                	jmp    800702 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006fd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  800702:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800705:	c9                   	leave  
  800706:	c3                   	ret    

00800707 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800707:	55                   	push   %ebp
  800708:	89 e5                	mov    %esp,%ebp
  80070a:	57                   	push   %edi
  80070b:	56                   	push   %esi
  80070c:	53                   	push   %ebx
  80070d:	83 ec 0c             	sub    $0xc,%esp
  800710:	8b 7d 08             	mov    0x8(%ebp),%edi
  800713:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800716:	85 f6                	test   %esi,%esi
  800718:	74 31                	je     80074b <readn+0x44>
  80071a:	b8 00 00 00 00       	mov    $0x0,%eax
  80071f:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  800724:	83 ec 04             	sub    $0x4,%esp
  800727:	89 f2                	mov    %esi,%edx
  800729:	29 c2                	sub    %eax,%edx
  80072b:	52                   	push   %edx
  80072c:	03 45 0c             	add    0xc(%ebp),%eax
  80072f:	50                   	push   %eax
  800730:	57                   	push   %edi
  800731:	e8 4a ff ff ff       	call   800680 <read>
		if (m < 0)
  800736:	83 c4 10             	add    $0x10,%esp
  800739:	85 c0                	test   %eax,%eax
  80073b:	78 17                	js     800754 <readn+0x4d>
			return m;
		if (m == 0)
  80073d:	85 c0                	test   %eax,%eax
  80073f:	74 11                	je     800752 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800741:	01 c3                	add    %eax,%ebx
  800743:	89 d8                	mov    %ebx,%eax
  800745:	39 f3                	cmp    %esi,%ebx
  800747:	72 db                	jb     800724 <readn+0x1d>
  800749:	eb 09                	jmp    800754 <readn+0x4d>
  80074b:	b8 00 00 00 00       	mov    $0x0,%eax
  800750:	eb 02                	jmp    800754 <readn+0x4d>
  800752:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800754:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800757:	5b                   	pop    %ebx
  800758:	5e                   	pop    %esi
  800759:	5f                   	pop    %edi
  80075a:	5d                   	pop    %ebp
  80075b:	c3                   	ret    

0080075c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80075c:	55                   	push   %ebp
  80075d:	89 e5                	mov    %esp,%ebp
  80075f:	53                   	push   %ebx
  800760:	83 ec 14             	sub    $0x14,%esp
  800763:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800766:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800769:	50                   	push   %eax
  80076a:	53                   	push   %ebx
  80076b:	e8 8f fc ff ff       	call   8003ff <fd_lookup>
  800770:	83 c4 08             	add    $0x8,%esp
  800773:	85 c0                	test   %eax,%eax
  800775:	78 62                	js     8007d9 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800777:	83 ec 08             	sub    $0x8,%esp
  80077a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80077d:	50                   	push   %eax
  80077e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800781:	ff 30                	pushl  (%eax)
  800783:	e8 ce fc ff ff       	call   800456 <dev_lookup>
  800788:	83 c4 10             	add    $0x10,%esp
  80078b:	85 c0                	test   %eax,%eax
  80078d:	78 4a                	js     8007d9 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80078f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800792:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800796:	75 21                	jne    8007b9 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800798:	a1 04 40 80 00       	mov    0x804004,%eax
  80079d:	8b 40 48             	mov    0x48(%eax),%eax
  8007a0:	83 ec 04             	sub    $0x4,%esp
  8007a3:	53                   	push   %ebx
  8007a4:	50                   	push   %eax
  8007a5:	68 01 1f 80 00       	push   $0x801f01
  8007aa:	e8 25 09 00 00       	call   8010d4 <cprintf>
		return -E_INVAL;
  8007af:	83 c4 10             	add    $0x10,%esp
  8007b2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007b7:	eb 20                	jmp    8007d9 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007b9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007bc:	8b 52 0c             	mov    0xc(%edx),%edx
  8007bf:	85 d2                	test   %edx,%edx
  8007c1:	74 11                	je     8007d4 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007c3:	83 ec 04             	sub    $0x4,%esp
  8007c6:	ff 75 10             	pushl  0x10(%ebp)
  8007c9:	ff 75 0c             	pushl  0xc(%ebp)
  8007cc:	50                   	push   %eax
  8007cd:	ff d2                	call   *%edx
  8007cf:	83 c4 10             	add    $0x10,%esp
  8007d2:	eb 05                	jmp    8007d9 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007d4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8007d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007dc:	c9                   	leave  
  8007dd:	c3                   	ret    

008007de <seek>:

int
seek(int fdnum, off_t offset)
{
  8007de:	55                   	push   %ebp
  8007df:	89 e5                	mov    %esp,%ebp
  8007e1:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007e4:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007e7:	50                   	push   %eax
  8007e8:	ff 75 08             	pushl  0x8(%ebp)
  8007eb:	e8 0f fc ff ff       	call   8003ff <fd_lookup>
  8007f0:	83 c4 08             	add    $0x8,%esp
  8007f3:	85 c0                	test   %eax,%eax
  8007f5:	78 0e                	js     800805 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007fd:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800800:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800805:	c9                   	leave  
  800806:	c3                   	ret    

00800807 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800807:	55                   	push   %ebp
  800808:	89 e5                	mov    %esp,%ebp
  80080a:	53                   	push   %ebx
  80080b:	83 ec 14             	sub    $0x14,%esp
  80080e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800811:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800814:	50                   	push   %eax
  800815:	53                   	push   %ebx
  800816:	e8 e4 fb ff ff       	call   8003ff <fd_lookup>
  80081b:	83 c4 08             	add    $0x8,%esp
  80081e:	85 c0                	test   %eax,%eax
  800820:	78 5f                	js     800881 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800822:	83 ec 08             	sub    $0x8,%esp
  800825:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800828:	50                   	push   %eax
  800829:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80082c:	ff 30                	pushl  (%eax)
  80082e:	e8 23 fc ff ff       	call   800456 <dev_lookup>
  800833:	83 c4 10             	add    $0x10,%esp
  800836:	85 c0                	test   %eax,%eax
  800838:	78 47                	js     800881 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80083a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80083d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800841:	75 21                	jne    800864 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800843:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800848:	8b 40 48             	mov    0x48(%eax),%eax
  80084b:	83 ec 04             	sub    $0x4,%esp
  80084e:	53                   	push   %ebx
  80084f:	50                   	push   %eax
  800850:	68 c4 1e 80 00       	push   $0x801ec4
  800855:	e8 7a 08 00 00       	call   8010d4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80085a:	83 c4 10             	add    $0x10,%esp
  80085d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800862:	eb 1d                	jmp    800881 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  800864:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800867:	8b 52 18             	mov    0x18(%edx),%edx
  80086a:	85 d2                	test   %edx,%edx
  80086c:	74 0e                	je     80087c <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80086e:	83 ec 08             	sub    $0x8,%esp
  800871:	ff 75 0c             	pushl  0xc(%ebp)
  800874:	50                   	push   %eax
  800875:	ff d2                	call   *%edx
  800877:	83 c4 10             	add    $0x10,%esp
  80087a:	eb 05                	jmp    800881 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80087c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  800881:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800884:	c9                   	leave  
  800885:	c3                   	ret    

00800886 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800886:	55                   	push   %ebp
  800887:	89 e5                	mov    %esp,%ebp
  800889:	53                   	push   %ebx
  80088a:	83 ec 14             	sub    $0x14,%esp
  80088d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800890:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800893:	50                   	push   %eax
  800894:	ff 75 08             	pushl  0x8(%ebp)
  800897:	e8 63 fb ff ff       	call   8003ff <fd_lookup>
  80089c:	83 c4 08             	add    $0x8,%esp
  80089f:	85 c0                	test   %eax,%eax
  8008a1:	78 52                	js     8008f5 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008a3:	83 ec 08             	sub    $0x8,%esp
  8008a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008a9:	50                   	push   %eax
  8008aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008ad:	ff 30                	pushl  (%eax)
  8008af:	e8 a2 fb ff ff       	call   800456 <dev_lookup>
  8008b4:	83 c4 10             	add    $0x10,%esp
  8008b7:	85 c0                	test   %eax,%eax
  8008b9:	78 3a                	js     8008f5 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  8008bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008be:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008c2:	74 2c                	je     8008f0 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008c4:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008c7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008ce:	00 00 00 
	stat->st_isdir = 0;
  8008d1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008d8:	00 00 00 
	stat->st_dev = dev;
  8008db:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008e1:	83 ec 08             	sub    $0x8,%esp
  8008e4:	53                   	push   %ebx
  8008e5:	ff 75 f0             	pushl  -0x10(%ebp)
  8008e8:	ff 50 14             	call   *0x14(%eax)
  8008eb:	83 c4 10             	add    $0x10,%esp
  8008ee:	eb 05                	jmp    8008f5 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008f0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008f8:	c9                   	leave  
  8008f9:	c3                   	ret    

008008fa <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	56                   	push   %esi
  8008fe:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008ff:	83 ec 08             	sub    $0x8,%esp
  800902:	6a 00                	push   $0x0
  800904:	ff 75 08             	pushl  0x8(%ebp)
  800907:	e8 75 01 00 00       	call   800a81 <open>
  80090c:	89 c3                	mov    %eax,%ebx
  80090e:	83 c4 10             	add    $0x10,%esp
  800911:	85 c0                	test   %eax,%eax
  800913:	78 1d                	js     800932 <stat+0x38>
		return fd;
	r = fstat(fd, stat);
  800915:	83 ec 08             	sub    $0x8,%esp
  800918:	ff 75 0c             	pushl  0xc(%ebp)
  80091b:	50                   	push   %eax
  80091c:	e8 65 ff ff ff       	call   800886 <fstat>
  800921:	89 c6                	mov    %eax,%esi
	close(fd);
  800923:	89 1c 24             	mov    %ebx,(%esp)
  800926:	e8 1d fc ff ff       	call   800548 <close>
	return r;
  80092b:	83 c4 10             	add    $0x10,%esp
  80092e:	89 f0                	mov    %esi,%eax
  800930:	eb 00                	jmp    800932 <stat+0x38>
}
  800932:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800935:	5b                   	pop    %ebx
  800936:	5e                   	pop    %esi
  800937:	5d                   	pop    %ebp
  800938:	c3                   	ret    

00800939 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800939:	55                   	push   %ebp
  80093a:	89 e5                	mov    %esp,%ebp
  80093c:	56                   	push   %esi
  80093d:	53                   	push   %ebx
  80093e:	89 c6                	mov    %eax,%esi
  800940:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800942:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800949:	75 12                	jne    80095d <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80094b:	83 ec 0c             	sub    $0xc,%esp
  80094e:	6a 01                	push   $0x1
  800950:	e8 ec 11 00 00       	call   801b41 <ipc_find_env>
  800955:	a3 00 40 80 00       	mov    %eax,0x804000
  80095a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80095d:	6a 07                	push   $0x7
  80095f:	68 00 50 80 00       	push   $0x805000
  800964:	56                   	push   %esi
  800965:	ff 35 00 40 80 00    	pushl  0x804000
  80096b:	e8 72 11 00 00       	call   801ae2 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800970:	83 c4 0c             	add    $0xc,%esp
  800973:	6a 00                	push   $0x0
  800975:	53                   	push   %ebx
  800976:	6a 00                	push   $0x0
  800978:	e8 f0 10 00 00       	call   801a6d <ipc_recv>
}
  80097d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800980:	5b                   	pop    %ebx
  800981:	5e                   	pop    %esi
  800982:	5d                   	pop    %ebp
  800983:	c3                   	ret    

00800984 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800984:	55                   	push   %ebp
  800985:	89 e5                	mov    %esp,%ebp
  800987:	53                   	push   %ebx
  800988:	83 ec 04             	sub    $0x4,%esp
  80098b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80098e:	8b 45 08             	mov    0x8(%ebp),%eax
  800991:	8b 40 0c             	mov    0xc(%eax),%eax
  800994:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800999:	ba 00 00 00 00       	mov    $0x0,%edx
  80099e:	b8 05 00 00 00       	mov    $0x5,%eax
  8009a3:	e8 91 ff ff ff       	call   800939 <fsipc>
  8009a8:	85 c0                	test   %eax,%eax
  8009aa:	78 2c                	js     8009d8 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009ac:	83 ec 08             	sub    $0x8,%esp
  8009af:	68 00 50 80 00       	push   $0x805000
  8009b4:	53                   	push   %ebx
  8009b5:	e8 ff 0c 00 00       	call   8016b9 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009ba:	a1 80 50 80 00       	mov    0x805080,%eax
  8009bf:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009c5:	a1 84 50 80 00       	mov    0x805084,%eax
  8009ca:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009d0:	83 c4 10             	add    $0x10,%esp
  8009d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009db:	c9                   	leave  
  8009dc:	c3                   	ret    

008009dd <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009dd:	55                   	push   %ebp
  8009de:	89 e5                	mov    %esp,%ebp
  8009e0:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e6:	8b 40 0c             	mov    0xc(%eax),%eax
  8009e9:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8009f3:	b8 06 00 00 00       	mov    $0x6,%eax
  8009f8:	e8 3c ff ff ff       	call   800939 <fsipc>
}
  8009fd:	c9                   	leave  
  8009fe:	c3                   	ret    

008009ff <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8009ff:	55                   	push   %ebp
  800a00:	89 e5                	mov    %esp,%ebp
  800a02:	56                   	push   %esi
  800a03:	53                   	push   %ebx
  800a04:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a07:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0a:	8b 40 0c             	mov    0xc(%eax),%eax
  800a0d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a12:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a18:	ba 00 00 00 00       	mov    $0x0,%edx
  800a1d:	b8 03 00 00 00       	mov    $0x3,%eax
  800a22:	e8 12 ff ff ff       	call   800939 <fsipc>
  800a27:	89 c3                	mov    %eax,%ebx
  800a29:	85 c0                	test   %eax,%eax
  800a2b:	78 4b                	js     800a78 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a2d:	39 c6                	cmp    %eax,%esi
  800a2f:	73 16                	jae    800a47 <devfile_read+0x48>
  800a31:	68 1e 1f 80 00       	push   $0x801f1e
  800a36:	68 25 1f 80 00       	push   $0x801f25
  800a3b:	6a 7a                	push   $0x7a
  800a3d:	68 3a 1f 80 00       	push   $0x801f3a
  800a42:	e8 b5 05 00 00       	call   800ffc <_panic>
	assert(r <= PGSIZE);
  800a47:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a4c:	7e 16                	jle    800a64 <devfile_read+0x65>
  800a4e:	68 45 1f 80 00       	push   $0x801f45
  800a53:	68 25 1f 80 00       	push   $0x801f25
  800a58:	6a 7b                	push   $0x7b
  800a5a:	68 3a 1f 80 00       	push   $0x801f3a
  800a5f:	e8 98 05 00 00       	call   800ffc <_panic>
	memmove(buf, &fsipcbuf, r);
  800a64:	83 ec 04             	sub    $0x4,%esp
  800a67:	50                   	push   %eax
  800a68:	68 00 50 80 00       	push   $0x805000
  800a6d:	ff 75 0c             	pushl  0xc(%ebp)
  800a70:	e8 11 0e 00 00       	call   801886 <memmove>
	return r;
  800a75:	83 c4 10             	add    $0x10,%esp
}
  800a78:	89 d8                	mov    %ebx,%eax
  800a7a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a7d:	5b                   	pop    %ebx
  800a7e:	5e                   	pop    %esi
  800a7f:	5d                   	pop    %ebp
  800a80:	c3                   	ret    

00800a81 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800a81:	55                   	push   %ebp
  800a82:	89 e5                	mov    %esp,%ebp
  800a84:	53                   	push   %ebx
  800a85:	83 ec 20             	sub    $0x20,%esp
  800a88:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800a8b:	53                   	push   %ebx
  800a8c:	e8 d1 0b 00 00       	call   801662 <strlen>
  800a91:	83 c4 10             	add    $0x10,%esp
  800a94:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800a99:	7f 63                	jg     800afe <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800a9b:	83 ec 0c             	sub    $0xc,%esp
  800a9e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800aa1:	50                   	push   %eax
  800aa2:	e8 e4 f8 ff ff       	call   80038b <fd_alloc>
  800aa7:	83 c4 10             	add    $0x10,%esp
  800aaa:	85 c0                	test   %eax,%eax
  800aac:	78 55                	js     800b03 <open+0x82>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800aae:	83 ec 08             	sub    $0x8,%esp
  800ab1:	53                   	push   %ebx
  800ab2:	68 00 50 80 00       	push   $0x805000
  800ab7:	e8 fd 0b 00 00       	call   8016b9 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800abc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800abf:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800ac4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ac7:	b8 01 00 00 00       	mov    $0x1,%eax
  800acc:	e8 68 fe ff ff       	call   800939 <fsipc>
  800ad1:	89 c3                	mov    %eax,%ebx
  800ad3:	83 c4 10             	add    $0x10,%esp
  800ad6:	85 c0                	test   %eax,%eax
  800ad8:	79 14                	jns    800aee <open+0x6d>
		fd_close(fd, 0);
  800ada:	83 ec 08             	sub    $0x8,%esp
  800add:	6a 00                	push   $0x0
  800adf:	ff 75 f4             	pushl  -0xc(%ebp)
  800ae2:	e8 dd f9 ff ff       	call   8004c4 <fd_close>
		return r;
  800ae7:	83 c4 10             	add    $0x10,%esp
  800aea:	89 d8                	mov    %ebx,%eax
  800aec:	eb 15                	jmp    800b03 <open+0x82>
	}

	return fd2num(fd);
  800aee:	83 ec 0c             	sub    $0xc,%esp
  800af1:	ff 75 f4             	pushl  -0xc(%ebp)
  800af4:	e8 6b f8 ff ff       	call   800364 <fd2num>
  800af9:	83 c4 10             	add    $0x10,%esp
  800afc:	eb 05                	jmp    800b03 <open+0x82>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800afe:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b03:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b06:	c9                   	leave  
  800b07:	c3                   	ret    

00800b08 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b08:	55                   	push   %ebp
  800b09:	89 e5                	mov    %esp,%ebp
  800b0b:	56                   	push   %esi
  800b0c:	53                   	push   %ebx
  800b0d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b10:	83 ec 0c             	sub    $0xc,%esp
  800b13:	ff 75 08             	pushl  0x8(%ebp)
  800b16:	e8 59 f8 ff ff       	call   800374 <fd2data>
  800b1b:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b1d:	83 c4 08             	add    $0x8,%esp
  800b20:	68 51 1f 80 00       	push   $0x801f51
  800b25:	53                   	push   %ebx
  800b26:	e8 8e 0b 00 00       	call   8016b9 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b2b:	8b 46 04             	mov    0x4(%esi),%eax
  800b2e:	2b 06                	sub    (%esi),%eax
  800b30:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b36:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b3d:	00 00 00 
	stat->st_dev = &devpipe;
  800b40:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  800b47:	30 80 00 
	return 0;
}
  800b4a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b4f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b52:	5b                   	pop    %ebx
  800b53:	5e                   	pop    %esi
  800b54:	5d                   	pop    %ebp
  800b55:	c3                   	ret    

00800b56 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b56:	55                   	push   %ebp
  800b57:	89 e5                	mov    %esp,%ebp
  800b59:	53                   	push   %ebx
  800b5a:	83 ec 0c             	sub    $0xc,%esp
  800b5d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800b60:	53                   	push   %ebx
  800b61:	6a 00                	push   $0x0
  800b63:	e8 90 f6 ff ff       	call   8001f8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800b68:	89 1c 24             	mov    %ebx,(%esp)
  800b6b:	e8 04 f8 ff ff       	call   800374 <fd2data>
  800b70:	83 c4 08             	add    $0x8,%esp
  800b73:	50                   	push   %eax
  800b74:	6a 00                	push   $0x0
  800b76:	e8 7d f6 ff ff       	call   8001f8 <sys_page_unmap>
}
  800b7b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b7e:	c9                   	leave  
  800b7f:	c3                   	ret    

00800b80 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800b80:	55                   	push   %ebp
  800b81:	89 e5                	mov    %esp,%ebp
  800b83:	57                   	push   %edi
  800b84:	56                   	push   %esi
  800b85:	53                   	push   %ebx
  800b86:	83 ec 1c             	sub    $0x1c,%esp
  800b89:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b8c:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800b8e:	a1 04 40 80 00       	mov    0x804004,%eax
  800b93:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800b96:	83 ec 0c             	sub    $0xc,%esp
  800b99:	ff 75 e0             	pushl  -0x20(%ebp)
  800b9c:	e8 fb 0f 00 00       	call   801b9c <pageref>
  800ba1:	89 c3                	mov    %eax,%ebx
  800ba3:	89 3c 24             	mov    %edi,(%esp)
  800ba6:	e8 f1 0f 00 00       	call   801b9c <pageref>
  800bab:	83 c4 10             	add    $0x10,%esp
  800bae:	39 c3                	cmp    %eax,%ebx
  800bb0:	0f 94 c1             	sete   %cl
  800bb3:	0f b6 c9             	movzbl %cl,%ecx
  800bb6:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800bb9:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800bbf:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800bc2:	39 ce                	cmp    %ecx,%esi
  800bc4:	74 1b                	je     800be1 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800bc6:	39 c3                	cmp    %eax,%ebx
  800bc8:	75 c4                	jne    800b8e <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800bca:	8b 42 58             	mov    0x58(%edx),%eax
  800bcd:	ff 75 e4             	pushl  -0x1c(%ebp)
  800bd0:	50                   	push   %eax
  800bd1:	56                   	push   %esi
  800bd2:	68 58 1f 80 00       	push   $0x801f58
  800bd7:	e8 f8 04 00 00       	call   8010d4 <cprintf>
  800bdc:	83 c4 10             	add    $0x10,%esp
  800bdf:	eb ad                	jmp    800b8e <_pipeisclosed+0xe>
	}
}
  800be1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800be4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be7:	5b                   	pop    %ebx
  800be8:	5e                   	pop    %esi
  800be9:	5f                   	pop    %edi
  800bea:	5d                   	pop    %ebp
  800beb:	c3                   	ret    

00800bec <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800bec:	55                   	push   %ebp
  800bed:	89 e5                	mov    %esp,%ebp
  800bef:	57                   	push   %edi
  800bf0:	56                   	push   %esi
  800bf1:	53                   	push   %ebx
  800bf2:	83 ec 18             	sub    $0x18,%esp
  800bf5:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800bf8:	56                   	push   %esi
  800bf9:	e8 76 f7 ff ff       	call   800374 <fd2data>
  800bfe:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c00:	83 c4 10             	add    $0x10,%esp
  800c03:	bf 00 00 00 00       	mov    $0x0,%edi
  800c08:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c0c:	75 42                	jne    800c50 <devpipe_write+0x64>
  800c0e:	eb 4e                	jmp    800c5e <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c10:	89 da                	mov    %ebx,%edx
  800c12:	89 f0                	mov    %esi,%eax
  800c14:	e8 67 ff ff ff       	call   800b80 <_pipeisclosed>
  800c19:	85 c0                	test   %eax,%eax
  800c1b:	75 46                	jne    800c63 <devpipe_write+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c1d:	e8 32 f5 ff ff       	call   800154 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c22:	8b 53 04             	mov    0x4(%ebx),%edx
  800c25:	8b 03                	mov    (%ebx),%eax
  800c27:	83 c0 20             	add    $0x20,%eax
  800c2a:	39 c2                	cmp    %eax,%edx
  800c2c:	73 e2                	jae    800c10 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c31:	8a 0c 38             	mov    (%eax,%edi,1),%cl
  800c34:	89 d0                	mov    %edx,%eax
  800c36:	25 1f 00 00 80       	and    $0x8000001f,%eax
  800c3b:	79 05                	jns    800c42 <devpipe_write+0x56>
  800c3d:	48                   	dec    %eax
  800c3e:	83 c8 e0             	or     $0xffffffe0,%eax
  800c41:	40                   	inc    %eax
  800c42:	88 4c 03 08          	mov    %cl,0x8(%ebx,%eax,1)
		p->p_wpos++;
  800c46:	42                   	inc    %edx
  800c47:	89 53 04             	mov    %edx,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c4a:	47                   	inc    %edi
  800c4b:	39 7d 10             	cmp    %edi,0x10(%ebp)
  800c4e:	74 0e                	je     800c5e <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c50:	8b 53 04             	mov    0x4(%ebx),%edx
  800c53:	8b 03                	mov    (%ebx),%eax
  800c55:	83 c0 20             	add    $0x20,%eax
  800c58:	39 c2                	cmp    %eax,%edx
  800c5a:	73 b4                	jae    800c10 <devpipe_write+0x24>
  800c5c:	eb d0                	jmp    800c2e <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800c5e:	8b 45 10             	mov    0x10(%ebp),%eax
  800c61:	eb 05                	jmp    800c68 <devpipe_write+0x7c>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800c63:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800c68:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6b:	5b                   	pop    %ebx
  800c6c:	5e                   	pop    %esi
  800c6d:	5f                   	pop    %edi
  800c6e:	5d                   	pop    %ebp
  800c6f:	c3                   	ret    

00800c70 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800c70:	55                   	push   %ebp
  800c71:	89 e5                	mov    %esp,%ebp
  800c73:	57                   	push   %edi
  800c74:	56                   	push   %esi
  800c75:	53                   	push   %ebx
  800c76:	83 ec 18             	sub    $0x18,%esp
  800c79:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800c7c:	57                   	push   %edi
  800c7d:	e8 f2 f6 ff ff       	call   800374 <fd2data>
  800c82:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c84:	83 c4 10             	add    $0x10,%esp
  800c87:	be 00 00 00 00       	mov    $0x0,%esi
  800c8c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c90:	75 3d                	jne    800ccf <devpipe_read+0x5f>
  800c92:	eb 48                	jmp    800cdc <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  800c94:	89 f0                	mov    %esi,%eax
  800c96:	eb 4e                	jmp    800ce6 <devpipe_read+0x76>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800c98:	89 da                	mov    %ebx,%edx
  800c9a:	89 f8                	mov    %edi,%eax
  800c9c:	e8 df fe ff ff       	call   800b80 <_pipeisclosed>
  800ca1:	85 c0                	test   %eax,%eax
  800ca3:	75 3c                	jne    800ce1 <devpipe_read+0x71>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800ca5:	e8 aa f4 ff ff       	call   800154 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800caa:	8b 03                	mov    (%ebx),%eax
  800cac:	3b 43 04             	cmp    0x4(%ebx),%eax
  800caf:	74 e7                	je     800c98 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800cb1:	25 1f 00 00 80       	and    $0x8000001f,%eax
  800cb6:	79 05                	jns    800cbd <devpipe_read+0x4d>
  800cb8:	48                   	dec    %eax
  800cb9:	83 c8 e0             	or     $0xffffffe0,%eax
  800cbc:	40                   	inc    %eax
  800cbd:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  800cc1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc4:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800cc7:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cc9:	46                   	inc    %esi
  800cca:	39 75 10             	cmp    %esi,0x10(%ebp)
  800ccd:	74 0d                	je     800cdc <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
  800ccf:	8b 03                	mov    (%ebx),%eax
  800cd1:	3b 43 04             	cmp    0x4(%ebx),%eax
  800cd4:	75 db                	jne    800cb1 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800cd6:	85 f6                	test   %esi,%esi
  800cd8:	75 ba                	jne    800c94 <devpipe_read+0x24>
  800cda:	eb bc                	jmp    800c98 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800cdc:	8b 45 10             	mov    0x10(%ebp),%eax
  800cdf:	eb 05                	jmp    800ce6 <devpipe_read+0x76>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800ce1:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800ce6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce9:	5b                   	pop    %ebx
  800cea:	5e                   	pop    %esi
  800ceb:	5f                   	pop    %edi
  800cec:	5d                   	pop    %ebp
  800ced:	c3                   	ret    

00800cee <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800cee:	55                   	push   %ebp
  800cef:	89 e5                	mov    %esp,%ebp
  800cf1:	56                   	push   %esi
  800cf2:	53                   	push   %ebx
  800cf3:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800cf6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800cf9:	50                   	push   %eax
  800cfa:	e8 8c f6 ff ff       	call   80038b <fd_alloc>
  800cff:	83 c4 10             	add    $0x10,%esp
  800d02:	85 c0                	test   %eax,%eax
  800d04:	0f 88 2a 01 00 00    	js     800e34 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d0a:	83 ec 04             	sub    $0x4,%esp
  800d0d:	68 07 04 00 00       	push   $0x407
  800d12:	ff 75 f4             	pushl  -0xc(%ebp)
  800d15:	6a 00                	push   $0x0
  800d17:	e8 57 f4 ff ff       	call   800173 <sys_page_alloc>
  800d1c:	83 c4 10             	add    $0x10,%esp
  800d1f:	85 c0                	test   %eax,%eax
  800d21:	0f 88 0d 01 00 00    	js     800e34 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d27:	83 ec 0c             	sub    $0xc,%esp
  800d2a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d2d:	50                   	push   %eax
  800d2e:	e8 58 f6 ff ff       	call   80038b <fd_alloc>
  800d33:	89 c3                	mov    %eax,%ebx
  800d35:	83 c4 10             	add    $0x10,%esp
  800d38:	85 c0                	test   %eax,%eax
  800d3a:	0f 88 e2 00 00 00    	js     800e22 <pipe+0x134>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d40:	83 ec 04             	sub    $0x4,%esp
  800d43:	68 07 04 00 00       	push   $0x407
  800d48:	ff 75 f0             	pushl  -0x10(%ebp)
  800d4b:	6a 00                	push   $0x0
  800d4d:	e8 21 f4 ff ff       	call   800173 <sys_page_alloc>
  800d52:	89 c3                	mov    %eax,%ebx
  800d54:	83 c4 10             	add    $0x10,%esp
  800d57:	85 c0                	test   %eax,%eax
  800d59:	0f 88 c3 00 00 00    	js     800e22 <pipe+0x134>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800d5f:	83 ec 0c             	sub    $0xc,%esp
  800d62:	ff 75 f4             	pushl  -0xc(%ebp)
  800d65:	e8 0a f6 ff ff       	call   800374 <fd2data>
  800d6a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d6c:	83 c4 0c             	add    $0xc,%esp
  800d6f:	68 07 04 00 00       	push   $0x407
  800d74:	50                   	push   %eax
  800d75:	6a 00                	push   $0x0
  800d77:	e8 f7 f3 ff ff       	call   800173 <sys_page_alloc>
  800d7c:	89 c3                	mov    %eax,%ebx
  800d7e:	83 c4 10             	add    $0x10,%esp
  800d81:	85 c0                	test   %eax,%eax
  800d83:	0f 88 89 00 00 00    	js     800e12 <pipe+0x124>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d89:	83 ec 0c             	sub    $0xc,%esp
  800d8c:	ff 75 f0             	pushl  -0x10(%ebp)
  800d8f:	e8 e0 f5 ff ff       	call   800374 <fd2data>
  800d94:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800d9b:	50                   	push   %eax
  800d9c:	6a 00                	push   $0x0
  800d9e:	56                   	push   %esi
  800d9f:	6a 00                	push   $0x0
  800da1:	e8 10 f4 ff ff       	call   8001b6 <sys_page_map>
  800da6:	89 c3                	mov    %eax,%ebx
  800da8:	83 c4 20             	add    $0x20,%esp
  800dab:	85 c0                	test   %eax,%eax
  800dad:	78 55                	js     800e04 <pipe+0x116>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800daf:	8b 15 24 30 80 00    	mov    0x803024,%edx
  800db5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800db8:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800dba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dbd:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800dc4:	8b 15 24 30 80 00    	mov    0x803024,%edx
  800dca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dcd:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800dcf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dd2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800dd9:	83 ec 0c             	sub    $0xc,%esp
  800ddc:	ff 75 f4             	pushl  -0xc(%ebp)
  800ddf:	e8 80 f5 ff ff       	call   800364 <fd2num>
  800de4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800de7:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800de9:	83 c4 04             	add    $0x4,%esp
  800dec:	ff 75 f0             	pushl  -0x10(%ebp)
  800def:	e8 70 f5 ff ff       	call   800364 <fd2num>
  800df4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800df7:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800dfa:	83 c4 10             	add    $0x10,%esp
  800dfd:	b8 00 00 00 00       	mov    $0x0,%eax
  800e02:	eb 30                	jmp    800e34 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  800e04:	83 ec 08             	sub    $0x8,%esp
  800e07:	56                   	push   %esi
  800e08:	6a 00                	push   $0x0
  800e0a:	e8 e9 f3 ff ff       	call   8001f8 <sys_page_unmap>
  800e0f:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e12:	83 ec 08             	sub    $0x8,%esp
  800e15:	ff 75 f0             	pushl  -0x10(%ebp)
  800e18:	6a 00                	push   $0x0
  800e1a:	e8 d9 f3 ff ff       	call   8001f8 <sys_page_unmap>
  800e1f:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e22:	83 ec 08             	sub    $0x8,%esp
  800e25:	ff 75 f4             	pushl  -0xc(%ebp)
  800e28:	6a 00                	push   $0x0
  800e2a:	e8 c9 f3 ff ff       	call   8001f8 <sys_page_unmap>
  800e2f:	83 c4 10             	add    $0x10,%esp
  800e32:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  800e34:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e37:	5b                   	pop    %ebx
  800e38:	5e                   	pop    %esi
  800e39:	5d                   	pop    %ebp
  800e3a:	c3                   	ret    

00800e3b <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e3b:	55                   	push   %ebp
  800e3c:	89 e5                	mov    %esp,%ebp
  800e3e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e41:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e44:	50                   	push   %eax
  800e45:	ff 75 08             	pushl  0x8(%ebp)
  800e48:	e8 b2 f5 ff ff       	call   8003ff <fd_lookup>
  800e4d:	83 c4 10             	add    $0x10,%esp
  800e50:	85 c0                	test   %eax,%eax
  800e52:	78 18                	js     800e6c <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800e54:	83 ec 0c             	sub    $0xc,%esp
  800e57:	ff 75 f4             	pushl  -0xc(%ebp)
  800e5a:	e8 15 f5 ff ff       	call   800374 <fd2data>
	return _pipeisclosed(fd, p);
  800e5f:	89 c2                	mov    %eax,%edx
  800e61:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e64:	e8 17 fd ff ff       	call   800b80 <_pipeisclosed>
  800e69:	83 c4 10             	add    $0x10,%esp
}
  800e6c:	c9                   	leave  
  800e6d:	c3                   	ret    

00800e6e <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800e6e:	55                   	push   %ebp
  800e6f:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800e71:	b8 00 00 00 00       	mov    $0x0,%eax
  800e76:	5d                   	pop    %ebp
  800e77:	c3                   	ret    

00800e78 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800e78:	55                   	push   %ebp
  800e79:	89 e5                	mov    %esp,%ebp
  800e7b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800e7e:	68 70 1f 80 00       	push   $0x801f70
  800e83:	ff 75 0c             	pushl  0xc(%ebp)
  800e86:	e8 2e 08 00 00       	call   8016b9 <strcpy>
	return 0;
}
  800e8b:	b8 00 00 00 00       	mov    $0x0,%eax
  800e90:	c9                   	leave  
  800e91:	c3                   	ret    

00800e92 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800e92:	55                   	push   %ebp
  800e93:	89 e5                	mov    %esp,%ebp
  800e95:	57                   	push   %edi
  800e96:	56                   	push   %esi
  800e97:	53                   	push   %ebx
  800e98:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800e9e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ea2:	74 45                	je     800ee9 <devcons_write+0x57>
  800ea4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea9:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800eae:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800eb4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eb7:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  800eb9:	83 fb 7f             	cmp    $0x7f,%ebx
  800ebc:	76 05                	jbe    800ec3 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  800ebe:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800ec3:	83 ec 04             	sub    $0x4,%esp
  800ec6:	53                   	push   %ebx
  800ec7:	03 45 0c             	add    0xc(%ebp),%eax
  800eca:	50                   	push   %eax
  800ecb:	57                   	push   %edi
  800ecc:	e8 b5 09 00 00       	call   801886 <memmove>
		sys_cputs(buf, m);
  800ed1:	83 c4 08             	add    $0x8,%esp
  800ed4:	53                   	push   %ebx
  800ed5:	57                   	push   %edi
  800ed6:	e8 dc f1 ff ff       	call   8000b7 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800edb:	01 de                	add    %ebx,%esi
  800edd:	89 f0                	mov    %esi,%eax
  800edf:	83 c4 10             	add    $0x10,%esp
  800ee2:	3b 75 10             	cmp    0x10(%ebp),%esi
  800ee5:	72 cd                	jb     800eb4 <devcons_write+0x22>
  800ee7:	eb 05                	jmp    800eee <devcons_write+0x5c>
  800ee9:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800eee:	89 f0                	mov    %esi,%eax
  800ef0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ef3:	5b                   	pop    %ebx
  800ef4:	5e                   	pop    %esi
  800ef5:	5f                   	pop    %edi
  800ef6:	5d                   	pop    %ebp
  800ef7:	c3                   	ret    

00800ef8 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800ef8:	55                   	push   %ebp
  800ef9:	89 e5                	mov    %esp,%ebp
  800efb:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  800efe:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f02:	75 07                	jne    800f0b <devcons_read+0x13>
  800f04:	eb 23                	jmp    800f29 <devcons_read+0x31>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f06:	e8 49 f2 ff ff       	call   800154 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f0b:	e8 c5 f1 ff ff       	call   8000d5 <sys_cgetc>
  800f10:	85 c0                	test   %eax,%eax
  800f12:	74 f2                	je     800f06 <devcons_read+0xe>
		sys_yield();
	if (c < 0)
  800f14:	85 c0                	test   %eax,%eax
  800f16:	78 1d                	js     800f35 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f18:	83 f8 04             	cmp    $0x4,%eax
  800f1b:	74 13                	je     800f30 <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  800f1d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f20:	88 02                	mov    %al,(%edx)
	return 1;
  800f22:	b8 01 00 00 00       	mov    $0x1,%eax
  800f27:	eb 0c                	jmp    800f35 <devcons_read+0x3d>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  800f29:	b8 00 00 00 00       	mov    $0x0,%eax
  800f2e:	eb 05                	jmp    800f35 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f30:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f35:	c9                   	leave  
  800f36:	c3                   	ret    

00800f37 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f37:	55                   	push   %ebp
  800f38:	89 e5                	mov    %esp,%ebp
  800f3a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800f40:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f43:	6a 01                	push   $0x1
  800f45:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f48:	50                   	push   %eax
  800f49:	e8 69 f1 ff ff       	call   8000b7 <sys_cputs>
}
  800f4e:	83 c4 10             	add    $0x10,%esp
  800f51:	c9                   	leave  
  800f52:	c3                   	ret    

00800f53 <getchar>:

int
getchar(void)
{
  800f53:	55                   	push   %ebp
  800f54:	89 e5                	mov    %esp,%ebp
  800f56:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f59:	6a 01                	push   $0x1
  800f5b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f5e:	50                   	push   %eax
  800f5f:	6a 00                	push   $0x0
  800f61:	e8 1a f7 ff ff       	call   800680 <read>
	if (r < 0)
  800f66:	83 c4 10             	add    $0x10,%esp
  800f69:	85 c0                	test   %eax,%eax
  800f6b:	78 0f                	js     800f7c <getchar+0x29>
		return r;
	if (r < 1)
  800f6d:	85 c0                	test   %eax,%eax
  800f6f:	7e 06                	jle    800f77 <getchar+0x24>
		return -E_EOF;
	return c;
  800f71:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800f75:	eb 05                	jmp    800f7c <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800f77:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800f7c:	c9                   	leave  
  800f7d:	c3                   	ret    

00800f7e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800f7e:	55                   	push   %ebp
  800f7f:	89 e5                	mov    %esp,%ebp
  800f81:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f84:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f87:	50                   	push   %eax
  800f88:	ff 75 08             	pushl  0x8(%ebp)
  800f8b:	e8 6f f4 ff ff       	call   8003ff <fd_lookup>
  800f90:	83 c4 10             	add    $0x10,%esp
  800f93:	85 c0                	test   %eax,%eax
  800f95:	78 11                	js     800fa8 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800f97:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f9a:	8b 15 40 30 80 00    	mov    0x803040,%edx
  800fa0:	39 10                	cmp    %edx,(%eax)
  800fa2:	0f 94 c0             	sete   %al
  800fa5:	0f b6 c0             	movzbl %al,%eax
}
  800fa8:	c9                   	leave  
  800fa9:	c3                   	ret    

00800faa <opencons>:

int
opencons(void)
{
  800faa:	55                   	push   %ebp
  800fab:	89 e5                	mov    %esp,%ebp
  800fad:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fb0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fb3:	50                   	push   %eax
  800fb4:	e8 d2 f3 ff ff       	call   80038b <fd_alloc>
  800fb9:	83 c4 10             	add    $0x10,%esp
  800fbc:	85 c0                	test   %eax,%eax
  800fbe:	78 3a                	js     800ffa <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fc0:	83 ec 04             	sub    $0x4,%esp
  800fc3:	68 07 04 00 00       	push   $0x407
  800fc8:	ff 75 f4             	pushl  -0xc(%ebp)
  800fcb:	6a 00                	push   $0x0
  800fcd:	e8 a1 f1 ff ff       	call   800173 <sys_page_alloc>
  800fd2:	83 c4 10             	add    $0x10,%esp
  800fd5:	85 c0                	test   %eax,%eax
  800fd7:	78 21                	js     800ffa <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800fd9:	8b 15 40 30 80 00    	mov    0x803040,%edx
  800fdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fe2:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800fe4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fe7:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800fee:	83 ec 0c             	sub    $0xc,%esp
  800ff1:	50                   	push   %eax
  800ff2:	e8 6d f3 ff ff       	call   800364 <fd2num>
  800ff7:	83 c4 10             	add    $0x10,%esp
}
  800ffa:	c9                   	leave  
  800ffb:	c3                   	ret    

00800ffc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800ffc:	55                   	push   %ebp
  800ffd:	89 e5                	mov    %esp,%ebp
  800fff:	56                   	push   %esi
  801000:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801001:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801004:	8b 35 04 30 80 00    	mov    0x803004,%esi
  80100a:	e8 26 f1 ff ff       	call   800135 <sys_getenvid>
  80100f:	83 ec 0c             	sub    $0xc,%esp
  801012:	ff 75 0c             	pushl  0xc(%ebp)
  801015:	ff 75 08             	pushl  0x8(%ebp)
  801018:	56                   	push   %esi
  801019:	50                   	push   %eax
  80101a:	68 7c 1f 80 00       	push   $0x801f7c
  80101f:	e8 b0 00 00 00       	call   8010d4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801024:	83 c4 18             	add    $0x18,%esp
  801027:	53                   	push   %ebx
  801028:	ff 75 10             	pushl  0x10(%ebp)
  80102b:	e8 53 00 00 00       	call   801083 <vcprintf>
	cprintf("\n");
  801030:	c7 04 24 69 1f 80 00 	movl   $0x801f69,(%esp)
  801037:	e8 98 00 00 00       	call   8010d4 <cprintf>
  80103c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80103f:	cc                   	int3   
  801040:	eb fd                	jmp    80103f <_panic+0x43>

00801042 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801042:	55                   	push   %ebp
  801043:	89 e5                	mov    %esp,%ebp
  801045:	53                   	push   %ebx
  801046:	83 ec 04             	sub    $0x4,%esp
  801049:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80104c:	8b 13                	mov    (%ebx),%edx
  80104e:	8d 42 01             	lea    0x1(%edx),%eax
  801051:	89 03                	mov    %eax,(%ebx)
  801053:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801056:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80105a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80105f:	75 1a                	jne    80107b <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801061:	83 ec 08             	sub    $0x8,%esp
  801064:	68 ff 00 00 00       	push   $0xff
  801069:	8d 43 08             	lea    0x8(%ebx),%eax
  80106c:	50                   	push   %eax
  80106d:	e8 45 f0 ff ff       	call   8000b7 <sys_cputs>
		b->idx = 0;
  801072:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801078:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80107b:	ff 43 04             	incl   0x4(%ebx)
}
  80107e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801081:	c9                   	leave  
  801082:	c3                   	ret    

00801083 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801083:	55                   	push   %ebp
  801084:	89 e5                	mov    %esp,%ebp
  801086:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80108c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801093:	00 00 00 
	b.cnt = 0;
  801096:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80109d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010a0:	ff 75 0c             	pushl  0xc(%ebp)
  8010a3:	ff 75 08             	pushl  0x8(%ebp)
  8010a6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010ac:	50                   	push   %eax
  8010ad:	68 42 10 80 00       	push   $0x801042
  8010b2:	e8 54 01 00 00       	call   80120b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010b7:	83 c4 08             	add    $0x8,%esp
  8010ba:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010c0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010c6:	50                   	push   %eax
  8010c7:	e8 eb ef ff ff       	call   8000b7 <sys_cputs>

	return b.cnt;
}
  8010cc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8010d2:	c9                   	leave  
  8010d3:	c3                   	ret    

008010d4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8010d4:	55                   	push   %ebp
  8010d5:	89 e5                	mov    %esp,%ebp
  8010d7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8010da:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8010dd:	50                   	push   %eax
  8010de:	ff 75 08             	pushl  0x8(%ebp)
  8010e1:	e8 9d ff ff ff       	call   801083 <vcprintf>
	va_end(ap);

	return cnt;
}
  8010e6:	c9                   	leave  
  8010e7:	c3                   	ret    

008010e8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8010e8:	55                   	push   %ebp
  8010e9:	89 e5                	mov    %esp,%ebp
  8010eb:	57                   	push   %edi
  8010ec:	56                   	push   %esi
  8010ed:	53                   	push   %ebx
  8010ee:	83 ec 1c             	sub    $0x1c,%esp
  8010f1:	89 c6                	mov    %eax,%esi
  8010f3:	89 d7                	mov    %edx,%edi
  8010f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010fb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8010fe:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801101:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801104:	bb 00 00 00 00       	mov    $0x0,%ebx
  801109:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80110c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80110f:	39 d3                	cmp    %edx,%ebx
  801111:	72 11                	jb     801124 <printnum+0x3c>
  801113:	39 45 10             	cmp    %eax,0x10(%ebp)
  801116:	76 0c                	jbe    801124 <printnum+0x3c>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801118:	8b 45 14             	mov    0x14(%ebp),%eax
  80111b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80111e:	85 db                	test   %ebx,%ebx
  801120:	7f 37                	jg     801159 <printnum+0x71>
  801122:	eb 44                	jmp    801168 <printnum+0x80>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801124:	83 ec 0c             	sub    $0xc,%esp
  801127:	ff 75 18             	pushl  0x18(%ebp)
  80112a:	8b 45 14             	mov    0x14(%ebp),%eax
  80112d:	48                   	dec    %eax
  80112e:	50                   	push   %eax
  80112f:	ff 75 10             	pushl  0x10(%ebp)
  801132:	83 ec 08             	sub    $0x8,%esp
  801135:	ff 75 e4             	pushl  -0x1c(%ebp)
  801138:	ff 75 e0             	pushl  -0x20(%ebp)
  80113b:	ff 75 dc             	pushl  -0x24(%ebp)
  80113e:	ff 75 d8             	pushl  -0x28(%ebp)
  801141:	e8 9a 0a 00 00       	call   801be0 <__udivdi3>
  801146:	83 c4 18             	add    $0x18,%esp
  801149:	52                   	push   %edx
  80114a:	50                   	push   %eax
  80114b:	89 fa                	mov    %edi,%edx
  80114d:	89 f0                	mov    %esi,%eax
  80114f:	e8 94 ff ff ff       	call   8010e8 <printnum>
  801154:	83 c4 20             	add    $0x20,%esp
  801157:	eb 0f                	jmp    801168 <printnum+0x80>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801159:	83 ec 08             	sub    $0x8,%esp
  80115c:	57                   	push   %edi
  80115d:	ff 75 18             	pushl  0x18(%ebp)
  801160:	ff d6                	call   *%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801162:	83 c4 10             	add    $0x10,%esp
  801165:	4b                   	dec    %ebx
  801166:	75 f1                	jne    801159 <printnum+0x71>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801168:	83 ec 08             	sub    $0x8,%esp
  80116b:	57                   	push   %edi
  80116c:	83 ec 04             	sub    $0x4,%esp
  80116f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801172:	ff 75 e0             	pushl  -0x20(%ebp)
  801175:	ff 75 dc             	pushl  -0x24(%ebp)
  801178:	ff 75 d8             	pushl  -0x28(%ebp)
  80117b:	e8 70 0b 00 00       	call   801cf0 <__umoddi3>
  801180:	83 c4 14             	add    $0x14,%esp
  801183:	0f be 80 9f 1f 80 00 	movsbl 0x801f9f(%eax),%eax
  80118a:	50                   	push   %eax
  80118b:	ff d6                	call   *%esi
}
  80118d:	83 c4 10             	add    $0x10,%esp
  801190:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801193:	5b                   	pop    %ebx
  801194:	5e                   	pop    %esi
  801195:	5f                   	pop    %edi
  801196:	5d                   	pop    %ebp
  801197:	c3                   	ret    

00801198 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801198:	55                   	push   %ebp
  801199:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80119b:	83 fa 01             	cmp    $0x1,%edx
  80119e:	7e 0e                	jle    8011ae <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8011a0:	8b 10                	mov    (%eax),%edx
  8011a2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011a5:	89 08                	mov    %ecx,(%eax)
  8011a7:	8b 02                	mov    (%edx),%eax
  8011a9:	8b 52 04             	mov    0x4(%edx),%edx
  8011ac:	eb 22                	jmp    8011d0 <getuint+0x38>
	else if (lflag)
  8011ae:	85 d2                	test   %edx,%edx
  8011b0:	74 10                	je     8011c2 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8011b2:	8b 10                	mov    (%eax),%edx
  8011b4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011b7:	89 08                	mov    %ecx,(%eax)
  8011b9:	8b 02                	mov    (%edx),%eax
  8011bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8011c0:	eb 0e                	jmp    8011d0 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8011c2:	8b 10                	mov    (%eax),%edx
  8011c4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011c7:	89 08                	mov    %ecx,(%eax)
  8011c9:	8b 02                	mov    (%edx),%eax
  8011cb:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8011d0:	5d                   	pop    %ebp
  8011d1:	c3                   	ret    

008011d2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011d2:	55                   	push   %ebp
  8011d3:	89 e5                	mov    %esp,%ebp
  8011d5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011d8:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8011db:	8b 10                	mov    (%eax),%edx
  8011dd:	3b 50 04             	cmp    0x4(%eax),%edx
  8011e0:	73 0a                	jae    8011ec <sprintputch+0x1a>
		*b->buf++ = ch;
  8011e2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8011e5:	89 08                	mov    %ecx,(%eax)
  8011e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ea:	88 02                	mov    %al,(%edx)
}
  8011ec:	5d                   	pop    %ebp
  8011ed:	c3                   	ret    

008011ee <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8011ee:	55                   	push   %ebp
  8011ef:	89 e5                	mov    %esp,%ebp
  8011f1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8011f4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8011f7:	50                   	push   %eax
  8011f8:	ff 75 10             	pushl  0x10(%ebp)
  8011fb:	ff 75 0c             	pushl  0xc(%ebp)
  8011fe:	ff 75 08             	pushl  0x8(%ebp)
  801201:	e8 05 00 00 00       	call   80120b <vprintfmt>
	va_end(ap);
}
  801206:	83 c4 10             	add    $0x10,%esp
  801209:	c9                   	leave  
  80120a:	c3                   	ret    

0080120b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80120b:	55                   	push   %ebp
  80120c:	89 e5                	mov    %esp,%ebp
  80120e:	57                   	push   %edi
  80120f:	56                   	push   %esi
  801210:	53                   	push   %ebx
  801211:	83 ec 2c             	sub    $0x2c,%esp
  801214:	8b 7d 08             	mov    0x8(%ebp),%edi
  801217:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80121a:	eb 03                	jmp    80121f <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  80121c:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  80121f:	8b 45 10             	mov    0x10(%ebp),%eax
  801222:	8d 70 01             	lea    0x1(%eax),%esi
  801225:	0f b6 00             	movzbl (%eax),%eax
  801228:	83 f8 25             	cmp    $0x25,%eax
  80122b:	74 25                	je     801252 <vprintfmt+0x47>
			if (ch == '\0')									//当然中间如果遇到'\0'，代表这个字符串的访问结束
  80122d:	85 c0                	test   %eax,%eax
  80122f:	75 0d                	jne    80123e <vprintfmt+0x33>
  801231:	e9 b5 03 00 00       	jmp    8015eb <vprintfmt+0x3e0>
  801236:	85 c0                	test   %eax,%eax
  801238:	0f 84 ad 03 00 00    	je     8015eb <vprintfmt+0x3e0>
				return;
			putch(ch, putdat);								//调用putch函数，把一个字符ch输出到putdat指针所指向的地址中所存放的值对应的地址处
  80123e:	83 ec 08             	sub    $0x8,%esp
  801241:	53                   	push   %ebx
  801242:	50                   	push   %eax
  801243:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  801245:	46                   	inc    %esi
  801246:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  80124a:	83 c4 10             	add    $0x10,%esp
  80124d:	83 f8 25             	cmp    $0x25,%eax
  801250:	75 e4                	jne    801236 <vprintfmt+0x2b>
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  801252:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  801256:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80125d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801264:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80126b:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  801272:	eb 07                	jmp    80127b <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  801274:	8b 75 10             	mov    0x10(%ebp),%esi

		// flag to pad on the right
		case '-':											//%后面的'-'代表要进行左对齐输出，右边填空格，如果省略代表右对齐
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
  801277:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80127b:	8d 46 01             	lea    0x1(%esi),%eax
  80127e:	89 45 10             	mov    %eax,0x10(%ebp)
  801281:	0f b6 16             	movzbl (%esi),%edx
  801284:	8a 06                	mov    (%esi),%al
  801286:	83 e8 23             	sub    $0x23,%eax
  801289:	3c 55                	cmp    $0x55,%al
  80128b:	0f 87 03 03 00 00    	ja     801594 <vprintfmt+0x389>
  801291:	0f b6 c0             	movzbl %al,%eax
  801294:	ff 24 85 e0 20 80 00 	jmp    *0x8020e0(,%eax,4)
  80129b:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
			goto reswitch;									//处理下一个字符

		// flag to pad with 0's instead of spaces
		case '0':											//0--有0表示进行对齐输出时填0,如省略表示填入空格，并且如果为0，则一定是右对齐
			padc = '0';										//对其方式标志位变为0
  80129e:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  8012a2:	eb d7                	jmp    80127b <vprintfmt+0x70>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
				precision = precision * 10 + ch - '0';
  8012a4:	8d 42 d0             	lea    -0x30(%edx),%eax
  8012a7:	89 c1                	mov    %eax,%ecx
  8012a9:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  8012ac:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8012b0:	8d 50 d0             	lea    -0x30(%eax),%edx
  8012b3:	83 fa 09             	cmp    $0x9,%edx
  8012b6:	77 51                	ja     801309 <vprintfmt+0xfe>
  8012b8:	8b 75 10             	mov    0x10(%ebp),%esi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
  8012bb:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8012bc:	8d 14 89             	lea    (%ecx,%ecx,4),%edx
  8012bf:	01 d2                	add    %edx,%edx
  8012c1:	8d 4c 10 d0          	lea    -0x30(%eax,%edx,1),%ecx
				ch = *fmt;
  8012c5:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8012c8:	8d 50 d0             	lea    -0x30(%eax),%edx
  8012cb:	83 fa 09             	cmp    $0x9,%edx
  8012ce:	76 eb                	jbe    8012bb <vprintfmt+0xb0>
  8012d0:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8012d3:	eb 37                	jmp    80130c <vprintfmt+0x101>
					break;
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
  8012d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8012d8:	8d 50 04             	lea    0x4(%eax),%edx
  8012db:	89 55 14             	mov    %edx,0x14(%ebp)
  8012de:	8b 00                	mov    (%eax),%eax
  8012e0:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8012e3:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
			goto process_precision;
  8012e6:	eb 24                	jmp    80130c <vprintfmt+0x101>
  8012e8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8012ec:	79 07                	jns    8012f5 <vprintfmt+0xea>
  8012ee:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8012f5:	8b 75 10             	mov    0x10(%ebp),%esi
  8012f8:	eb 81                	jmp    80127b <vprintfmt+0x70>
  8012fa:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  8012fd:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801304:	e9 72 ff ff ff       	jmp    80127b <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  801309:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:									//处理输出精度，把width字段赋值为刚刚计算出来的precision值，所以width应该是整数部分的有效数字位数
			if (width < 0)
  80130c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801310:	0f 89 65 ff ff ff    	jns    80127b <vprintfmt+0x70>
				width = precision, precision = -1;
  801316:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801319:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80131c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801323:	e9 53 ff ff ff       	jmp    80127b <vprintfmt+0x70>
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
  801328:	ff 45 d4             	incl   -0x2c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80132b:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
			goto reswitch;
  80132e:	e9 48 ff ff ff       	jmp    80127b <vprintfmt+0x70>

		// character
		case 'c':											//如果是'c'代表显示一个字符
			putch(va_arg(ap, int), putdat);					//调用输出一个字符到内存的函数putch
  801333:	8b 45 14             	mov    0x14(%ebp),%eax
  801336:	8d 50 04             	lea    0x4(%eax),%edx
  801339:	89 55 14             	mov    %edx,0x14(%ebp)
  80133c:	83 ec 08             	sub    $0x8,%esp
  80133f:	53                   	push   %ebx
  801340:	ff 30                	pushl  (%eax)
  801342:	ff d7                	call   *%edi
			break;
  801344:	83 c4 10             	add    $0x10,%esp
  801347:	e9 d3 fe ff ff       	jmp    80121f <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80134c:	8b 45 14             	mov    0x14(%ebp),%eax
  80134f:	8d 50 04             	lea    0x4(%eax),%edx
  801352:	89 55 14             	mov    %edx,0x14(%ebp)
  801355:	8b 00                	mov    (%eax),%eax
  801357:	85 c0                	test   %eax,%eax
  801359:	79 02                	jns    80135d <vprintfmt+0x152>
  80135b:	f7 d8                	neg    %eax
  80135d:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80135f:	83 f8 0f             	cmp    $0xf,%eax
  801362:	7f 0b                	jg     80136f <vprintfmt+0x164>
  801364:	8b 04 85 40 22 80 00 	mov    0x802240(,%eax,4),%eax
  80136b:	85 c0                	test   %eax,%eax
  80136d:	75 15                	jne    801384 <vprintfmt+0x179>
				printfmt(putch, putdat, "error %d", err);
  80136f:	52                   	push   %edx
  801370:	68 b7 1f 80 00       	push   $0x801fb7
  801375:	53                   	push   %ebx
  801376:	57                   	push   %edi
  801377:	e8 72 fe ff ff       	call   8011ee <printfmt>
  80137c:	83 c4 10             	add    $0x10,%esp
  80137f:	e9 9b fe ff ff       	jmp    80121f <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  801384:	50                   	push   %eax
  801385:	68 37 1f 80 00       	push   $0x801f37
  80138a:	53                   	push   %ebx
  80138b:	57                   	push   %edi
  80138c:	e8 5d fe ff ff       	call   8011ee <printfmt>
  801391:	83 c4 10             	add    $0x10,%esp
  801394:	e9 86 fe ff ff       	jmp    80121f <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801399:	8b 45 14             	mov    0x14(%ebp),%eax
  80139c:	8d 50 04             	lea    0x4(%eax),%edx
  80139f:	89 55 14             	mov    %edx,0x14(%ebp)
  8013a2:	8b 00                	mov    (%eax),%eax
  8013a4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8013a7:	85 c0                	test   %eax,%eax
  8013a9:	75 07                	jne    8013b2 <vprintfmt+0x1a7>
				p = "(null)";
  8013ab:	c7 45 d4 b0 1f 80 00 	movl   $0x801fb0,-0x2c(%ebp)
			if (width > 0 && padc != '-')
  8013b2:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8013b5:	85 f6                	test   %esi,%esi
  8013b7:	0f 8e fb 01 00 00    	jle    8015b8 <vprintfmt+0x3ad>
  8013bd:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  8013c1:	0f 84 09 02 00 00    	je     8015d0 <vprintfmt+0x3c5>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013c7:	83 ec 08             	sub    $0x8,%esp
  8013ca:	ff 75 d0             	pushl  -0x30(%ebp)
  8013cd:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013d0:	e8 ad 02 00 00       	call   801682 <strnlen>
  8013d5:	89 f1                	mov    %esi,%ecx
  8013d7:	29 c1                	sub    %eax,%ecx
  8013d9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8013dc:	83 c4 10             	add    $0x10,%esp
  8013df:	85 c9                	test   %ecx,%ecx
  8013e1:	0f 8e d1 01 00 00    	jle    8015b8 <vprintfmt+0x3ad>
					putch(padc, putdat);
  8013e7:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8013eb:	83 ec 08             	sub    $0x8,%esp
  8013ee:	53                   	push   %ebx
  8013ef:	56                   	push   %esi
  8013f0:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013f2:	83 c4 10             	add    $0x10,%esp
  8013f5:	ff 4d e4             	decl   -0x1c(%ebp)
  8013f8:	75 f1                	jne    8013eb <vprintfmt+0x1e0>
  8013fa:	e9 b9 01 00 00       	jmp    8015b8 <vprintfmt+0x3ad>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8013ff:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801403:	74 19                	je     80141e <vprintfmt+0x213>
  801405:	0f be c0             	movsbl %al,%eax
  801408:	83 e8 20             	sub    $0x20,%eax
  80140b:	83 f8 5e             	cmp    $0x5e,%eax
  80140e:	76 0e                	jbe    80141e <vprintfmt+0x213>
					putch('?', putdat);
  801410:	83 ec 08             	sub    $0x8,%esp
  801413:	53                   	push   %ebx
  801414:	6a 3f                	push   $0x3f
  801416:	ff 55 08             	call   *0x8(%ebp)
  801419:	83 c4 10             	add    $0x10,%esp
  80141c:	eb 0b                	jmp    801429 <vprintfmt+0x21e>
				else
					putch(ch, putdat);
  80141e:	83 ec 08             	sub    $0x8,%esp
  801421:	53                   	push   %ebx
  801422:	52                   	push   %edx
  801423:	ff 55 08             	call   *0x8(%ebp)
  801426:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801429:	ff 4d e4             	decl   -0x1c(%ebp)
  80142c:	46                   	inc    %esi
  80142d:	8a 46 ff             	mov    -0x1(%esi),%al
  801430:	0f be d0             	movsbl %al,%edx
  801433:	85 d2                	test   %edx,%edx
  801435:	75 1c                	jne    801453 <vprintfmt+0x248>
  801437:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80143a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80143e:	7f 1f                	jg     80145f <vprintfmt+0x254>
  801440:	e9 da fd ff ff       	jmp    80121f <vprintfmt+0x14>
  801445:	89 7d 08             	mov    %edi,0x8(%ebp)
  801448:	8b 7d d0             	mov    -0x30(%ebp),%edi
  80144b:	eb 06                	jmp    801453 <vprintfmt+0x248>
  80144d:	89 7d 08             	mov    %edi,0x8(%ebp)
  801450:	8b 7d d0             	mov    -0x30(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801453:	85 ff                	test   %edi,%edi
  801455:	78 a8                	js     8013ff <vprintfmt+0x1f4>
  801457:	4f                   	dec    %edi
  801458:	79 a5                	jns    8013ff <vprintfmt+0x1f4>
  80145a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80145d:	eb db                	jmp    80143a <vprintfmt+0x22f>
  80145f:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801462:	83 ec 08             	sub    $0x8,%esp
  801465:	53                   	push   %ebx
  801466:	6a 20                	push   $0x20
  801468:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80146a:	4e                   	dec    %esi
  80146b:	83 c4 10             	add    $0x10,%esp
  80146e:	85 f6                	test   %esi,%esi
  801470:	7f f0                	jg     801462 <vprintfmt+0x257>
  801472:	e9 a8 fd ff ff       	jmp    80121f <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801477:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  80147b:	7e 16                	jle    801493 <vprintfmt+0x288>
		return va_arg(*ap, long long);
  80147d:	8b 45 14             	mov    0x14(%ebp),%eax
  801480:	8d 50 08             	lea    0x8(%eax),%edx
  801483:	89 55 14             	mov    %edx,0x14(%ebp)
  801486:	8b 50 04             	mov    0x4(%eax),%edx
  801489:	8b 00                	mov    (%eax),%eax
  80148b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80148e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801491:	eb 34                	jmp    8014c7 <vprintfmt+0x2bc>
	else if (lflag)
  801493:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  801497:	74 18                	je     8014b1 <vprintfmt+0x2a6>
		return va_arg(*ap, long);
  801499:	8b 45 14             	mov    0x14(%ebp),%eax
  80149c:	8d 50 04             	lea    0x4(%eax),%edx
  80149f:	89 55 14             	mov    %edx,0x14(%ebp)
  8014a2:	8b 30                	mov    (%eax),%esi
  8014a4:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8014a7:	89 f0                	mov    %esi,%eax
  8014a9:	c1 f8 1f             	sar    $0x1f,%eax
  8014ac:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8014af:	eb 16                	jmp    8014c7 <vprintfmt+0x2bc>
	else
		return va_arg(*ap, int);
  8014b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8014b4:	8d 50 04             	lea    0x4(%eax),%edx
  8014b7:	89 55 14             	mov    %edx,0x14(%ebp)
  8014ba:	8b 30                	mov    (%eax),%esi
  8014bc:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8014bf:	89 f0                	mov    %esi,%eax
  8014c1:	c1 f8 1f             	sar    $0x1f,%eax
  8014c4:	89 45 dc             	mov    %eax,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8014c7:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8014ca:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
  8014cd:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8014d1:	0f 89 8a 00 00 00    	jns    801561 <vprintfmt+0x356>
				putch('-', putdat);
  8014d7:	83 ec 08             	sub    $0x8,%esp
  8014da:	53                   	push   %ebx
  8014db:	6a 2d                	push   $0x2d
  8014dd:	ff d7                	call   *%edi
				num = -(long long) num;
  8014df:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8014e2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8014e5:	f7 d8                	neg    %eax
  8014e7:	83 d2 00             	adc    $0x0,%edx
  8014ea:	f7 da                	neg    %edx
  8014ec:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8014ef:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8014f4:	eb 70                	jmp    801566 <vprintfmt+0x35b>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8014f6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8014f9:	8d 45 14             	lea    0x14(%ebp),%eax
  8014fc:	e8 97 fc ff ff       	call   801198 <getuint>
			base = 10;
  801501:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801506:	eb 5e                	jmp    801566 <vprintfmt+0x35b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  801508:	83 ec 08             	sub    $0x8,%esp
  80150b:	53                   	push   %ebx
  80150c:	6a 30                	push   $0x30
  80150e:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  801510:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  801513:	8d 45 14             	lea    0x14(%ebp),%eax
  801516:	e8 7d fc ff ff       	call   801198 <getuint>
			base = 8;
			goto number;
  80151b:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  80151e:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801523:	eb 41                	jmp    801566 <vprintfmt+0x35b>
		// pointer
		case 'p':
			putch('0', putdat);
  801525:	83 ec 08             	sub    $0x8,%esp
  801528:	53                   	push   %ebx
  801529:	6a 30                	push   $0x30
  80152b:	ff d7                	call   *%edi
			putch('x', putdat);
  80152d:	83 c4 08             	add    $0x8,%esp
  801530:	53                   	push   %ebx
  801531:	6a 78                	push   $0x78
  801533:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801535:	8b 45 14             	mov    0x14(%ebp),%eax
  801538:	8d 50 04             	lea    0x4(%eax),%edx
  80153b:	89 55 14             	mov    %edx,0x14(%ebp)
			goto number;
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80153e:	8b 00                	mov    (%eax),%eax
  801540:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801545:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801548:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80154d:	eb 17                	jmp    801566 <vprintfmt+0x35b>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80154f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  801552:	8d 45 14             	lea    0x14(%ebp),%eax
  801555:	e8 3e fc ff ff       	call   801198 <getuint>
			base = 16;
  80155a:	b9 10 00 00 00       	mov    $0x10,%ecx
  80155f:	eb 05                	jmp    801566 <vprintfmt+0x35b>
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801561:	b9 0a 00 00 00       	mov    $0xa,%ecx
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  801566:	83 ec 0c             	sub    $0xc,%esp
  801569:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  80156d:	56                   	push   %esi
  80156e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801571:	51                   	push   %ecx
  801572:	52                   	push   %edx
  801573:	50                   	push   %eax
  801574:	89 da                	mov    %ebx,%edx
  801576:	89 f8                	mov    %edi,%eax
  801578:	e8 6b fb ff ff       	call   8010e8 <printnum>
			break;
  80157d:	83 c4 20             	add    $0x20,%esp
  801580:	e9 9a fc ff ff       	jmp    80121f <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801585:	83 ec 08             	sub    $0x8,%esp
  801588:	53                   	push   %ebx
  801589:	52                   	push   %edx
  80158a:	ff d7                	call   *%edi
			break;
  80158c:	83 c4 10             	add    $0x10,%esp
  80158f:	e9 8b fc ff ff       	jmp    80121f <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801594:	83 ec 08             	sub    $0x8,%esp
  801597:	53                   	push   %ebx
  801598:	6a 25                	push   $0x25
  80159a:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80159c:	83 c4 10             	add    $0x10,%esp
  80159f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8015a3:	0f 84 73 fc ff ff    	je     80121c <vprintfmt+0x11>
  8015a9:	4e                   	dec    %esi
  8015aa:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8015ae:	75 f9                	jne    8015a9 <vprintfmt+0x39e>
  8015b0:	89 75 10             	mov    %esi,0x10(%ebp)
  8015b3:	e9 67 fc ff ff       	jmp    80121f <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8015b8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8015bb:	8d 70 01             	lea    0x1(%eax),%esi
  8015be:	8a 00                	mov    (%eax),%al
  8015c0:	0f be d0             	movsbl %al,%edx
  8015c3:	85 d2                	test   %edx,%edx
  8015c5:	0f 85 7a fe ff ff    	jne    801445 <vprintfmt+0x23a>
  8015cb:	e9 4f fc ff ff       	jmp    80121f <vprintfmt+0x14>
  8015d0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8015d3:	8d 70 01             	lea    0x1(%eax),%esi
  8015d6:	8a 00                	mov    (%eax),%al
  8015d8:	0f be d0             	movsbl %al,%edx
  8015db:	85 d2                	test   %edx,%edx
  8015dd:	0f 85 6a fe ff ff    	jne    80144d <vprintfmt+0x242>
  8015e3:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8015e6:	e9 77 fe ff ff       	jmp    801462 <vprintfmt+0x257>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  8015eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015ee:	5b                   	pop    %ebx
  8015ef:	5e                   	pop    %esi
  8015f0:	5f                   	pop    %edi
  8015f1:	5d                   	pop    %ebp
  8015f2:	c3                   	ret    

008015f3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8015f3:	55                   	push   %ebp
  8015f4:	89 e5                	mov    %esp,%ebp
  8015f6:	83 ec 18             	sub    $0x18,%esp
  8015f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8015fc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8015ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801602:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801606:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801609:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801610:	85 c0                	test   %eax,%eax
  801612:	74 26                	je     80163a <vsnprintf+0x47>
  801614:	85 d2                	test   %edx,%edx
  801616:	7e 29                	jle    801641 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801618:	ff 75 14             	pushl  0x14(%ebp)
  80161b:	ff 75 10             	pushl  0x10(%ebp)
  80161e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801621:	50                   	push   %eax
  801622:	68 d2 11 80 00       	push   $0x8011d2
  801627:	e8 df fb ff ff       	call   80120b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80162c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80162f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801632:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801635:	83 c4 10             	add    $0x10,%esp
  801638:	eb 0c                	jmp    801646 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80163a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80163f:	eb 05                	jmp    801646 <vsnprintf+0x53>
  801641:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801646:	c9                   	leave  
  801647:	c3                   	ret    

00801648 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801648:	55                   	push   %ebp
  801649:	89 e5                	mov    %esp,%ebp
  80164b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80164e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801651:	50                   	push   %eax
  801652:	ff 75 10             	pushl  0x10(%ebp)
  801655:	ff 75 0c             	pushl  0xc(%ebp)
  801658:	ff 75 08             	pushl  0x8(%ebp)
  80165b:	e8 93 ff ff ff       	call   8015f3 <vsnprintf>
	va_end(ap);

	return rc;
}
  801660:	c9                   	leave  
  801661:	c3                   	ret    

00801662 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801662:	55                   	push   %ebp
  801663:	89 e5                	mov    %esp,%ebp
  801665:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801668:	80 3a 00             	cmpb   $0x0,(%edx)
  80166b:	74 0e                	je     80167b <strlen+0x19>
  80166d:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801672:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801673:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801677:	75 f9                	jne    801672 <strlen+0x10>
  801679:	eb 05                	jmp    801680 <strlen+0x1e>
  80167b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801680:	5d                   	pop    %ebp
  801681:	c3                   	ret    

00801682 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801682:	55                   	push   %ebp
  801683:	89 e5                	mov    %esp,%ebp
  801685:	53                   	push   %ebx
  801686:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801689:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80168c:	85 c9                	test   %ecx,%ecx
  80168e:	74 1a                	je     8016aa <strnlen+0x28>
  801690:	80 3b 00             	cmpb   $0x0,(%ebx)
  801693:	74 1c                	je     8016b1 <strnlen+0x2f>
  801695:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  80169a:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80169c:	39 ca                	cmp    %ecx,%edx
  80169e:	74 16                	je     8016b6 <strnlen+0x34>
  8016a0:	42                   	inc    %edx
  8016a1:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8016a6:	75 f2                	jne    80169a <strnlen+0x18>
  8016a8:	eb 0c                	jmp    8016b6 <strnlen+0x34>
  8016aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8016af:	eb 05                	jmp    8016b6 <strnlen+0x34>
  8016b1:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8016b6:	5b                   	pop    %ebx
  8016b7:	5d                   	pop    %ebp
  8016b8:	c3                   	ret    

008016b9 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016b9:	55                   	push   %ebp
  8016ba:	89 e5                	mov    %esp,%ebp
  8016bc:	53                   	push   %ebx
  8016bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016c3:	89 c2                	mov    %eax,%edx
  8016c5:	42                   	inc    %edx
  8016c6:	41                   	inc    %ecx
  8016c7:	8a 59 ff             	mov    -0x1(%ecx),%bl
  8016ca:	88 5a ff             	mov    %bl,-0x1(%edx)
  8016cd:	84 db                	test   %bl,%bl
  8016cf:	75 f4                	jne    8016c5 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8016d1:	5b                   	pop    %ebx
  8016d2:	5d                   	pop    %ebp
  8016d3:	c3                   	ret    

008016d4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016d4:	55                   	push   %ebp
  8016d5:	89 e5                	mov    %esp,%ebp
  8016d7:	53                   	push   %ebx
  8016d8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016db:	53                   	push   %ebx
  8016dc:	e8 81 ff ff ff       	call   801662 <strlen>
  8016e1:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8016e4:	ff 75 0c             	pushl  0xc(%ebp)
  8016e7:	01 d8                	add    %ebx,%eax
  8016e9:	50                   	push   %eax
  8016ea:	e8 ca ff ff ff       	call   8016b9 <strcpy>
	return dst;
}
  8016ef:	89 d8                	mov    %ebx,%eax
  8016f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016f4:	c9                   	leave  
  8016f5:	c3                   	ret    

008016f6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016f6:	55                   	push   %ebp
  8016f7:	89 e5                	mov    %esp,%ebp
  8016f9:	56                   	push   %esi
  8016fa:	53                   	push   %ebx
  8016fb:	8b 75 08             	mov    0x8(%ebp),%esi
  8016fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  801701:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801704:	85 db                	test   %ebx,%ebx
  801706:	74 14                	je     80171c <strncpy+0x26>
  801708:	01 f3                	add    %esi,%ebx
  80170a:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  80170c:	41                   	inc    %ecx
  80170d:	8a 02                	mov    (%edx),%al
  80170f:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801712:	80 3a 01             	cmpb   $0x1,(%edx)
  801715:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801718:	39 cb                	cmp    %ecx,%ebx
  80171a:	75 f0                	jne    80170c <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80171c:	89 f0                	mov    %esi,%eax
  80171e:	5b                   	pop    %ebx
  80171f:	5e                   	pop    %esi
  801720:	5d                   	pop    %ebp
  801721:	c3                   	ret    

00801722 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801722:	55                   	push   %ebp
  801723:	89 e5                	mov    %esp,%ebp
  801725:	53                   	push   %ebx
  801726:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801729:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80172c:	85 c0                	test   %eax,%eax
  80172e:	74 30                	je     801760 <strlcpy+0x3e>
		while (--size > 0 && *src != '\0')
  801730:	48                   	dec    %eax
  801731:	74 20                	je     801753 <strlcpy+0x31>
  801733:	8a 0b                	mov    (%ebx),%cl
  801735:	84 c9                	test   %cl,%cl
  801737:	74 1f                	je     801758 <strlcpy+0x36>
  801739:	8d 53 01             	lea    0x1(%ebx),%edx
  80173c:	01 c3                	add    %eax,%ebx
  80173e:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
  801741:	40                   	inc    %eax
  801742:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801745:	39 da                	cmp    %ebx,%edx
  801747:	74 12                	je     80175b <strlcpy+0x39>
  801749:	42                   	inc    %edx
  80174a:	8a 4a ff             	mov    -0x1(%edx),%cl
  80174d:	84 c9                	test   %cl,%cl
  80174f:	75 f0                	jne    801741 <strlcpy+0x1f>
  801751:	eb 08                	jmp    80175b <strlcpy+0x39>
  801753:	8b 45 08             	mov    0x8(%ebp),%eax
  801756:	eb 03                	jmp    80175b <strlcpy+0x39>
  801758:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
		*dst = '\0';
  80175b:	c6 00 00             	movb   $0x0,(%eax)
  80175e:	eb 03                	jmp    801763 <strlcpy+0x41>
  801760:	8b 45 08             	mov    0x8(%ebp),%eax
	}
	return dst - dst_in;
  801763:	2b 45 08             	sub    0x8(%ebp),%eax
}
  801766:	5b                   	pop    %ebx
  801767:	5d                   	pop    %ebp
  801768:	c3                   	ret    

00801769 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801769:	55                   	push   %ebp
  80176a:	89 e5                	mov    %esp,%ebp
  80176c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80176f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801772:	8a 01                	mov    (%ecx),%al
  801774:	84 c0                	test   %al,%al
  801776:	74 10                	je     801788 <strcmp+0x1f>
  801778:	3a 02                	cmp    (%edx),%al
  80177a:	75 0c                	jne    801788 <strcmp+0x1f>
		p++, q++;
  80177c:	41                   	inc    %ecx
  80177d:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80177e:	8a 01                	mov    (%ecx),%al
  801780:	84 c0                	test   %al,%al
  801782:	74 04                	je     801788 <strcmp+0x1f>
  801784:	3a 02                	cmp    (%edx),%al
  801786:	74 f4                	je     80177c <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801788:	0f b6 c0             	movzbl %al,%eax
  80178b:	0f b6 12             	movzbl (%edx),%edx
  80178e:	29 d0                	sub    %edx,%eax
}
  801790:	5d                   	pop    %ebp
  801791:	c3                   	ret    

00801792 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801792:	55                   	push   %ebp
  801793:	89 e5                	mov    %esp,%ebp
  801795:	56                   	push   %esi
  801796:	53                   	push   %ebx
  801797:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80179a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80179d:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  8017a0:	85 f6                	test   %esi,%esi
  8017a2:	74 23                	je     8017c7 <strncmp+0x35>
  8017a4:	8a 03                	mov    (%ebx),%al
  8017a6:	84 c0                	test   %al,%al
  8017a8:	74 2b                	je     8017d5 <strncmp+0x43>
  8017aa:	3a 02                	cmp    (%edx),%al
  8017ac:	75 27                	jne    8017d5 <strncmp+0x43>
  8017ae:	8d 43 01             	lea    0x1(%ebx),%eax
  8017b1:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  8017b3:	89 c3                	mov    %eax,%ebx
  8017b5:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017b6:	39 c6                	cmp    %eax,%esi
  8017b8:	74 14                	je     8017ce <strncmp+0x3c>
  8017ba:	8a 08                	mov    (%eax),%cl
  8017bc:	84 c9                	test   %cl,%cl
  8017be:	74 15                	je     8017d5 <strncmp+0x43>
  8017c0:	40                   	inc    %eax
  8017c1:	3a 0a                	cmp    (%edx),%cl
  8017c3:	74 ee                	je     8017b3 <strncmp+0x21>
  8017c5:	eb 0e                	jmp    8017d5 <strncmp+0x43>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8017cc:	eb 0f                	jmp    8017dd <strncmp+0x4b>
  8017ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8017d3:	eb 08                	jmp    8017dd <strncmp+0x4b>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017d5:	0f b6 03             	movzbl (%ebx),%eax
  8017d8:	0f b6 12             	movzbl (%edx),%edx
  8017db:	29 d0                	sub    %edx,%eax
}
  8017dd:	5b                   	pop    %ebx
  8017de:	5e                   	pop    %esi
  8017df:	5d                   	pop    %ebp
  8017e0:	c3                   	ret    

008017e1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017e1:	55                   	push   %ebp
  8017e2:	89 e5                	mov    %esp,%ebp
  8017e4:	53                   	push   %ebx
  8017e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  8017eb:	8a 10                	mov    (%eax),%dl
  8017ed:	84 d2                	test   %dl,%dl
  8017ef:	74 1a                	je     80180b <strchr+0x2a>
  8017f1:	88 d9                	mov    %bl,%cl
		if (*s == c)
  8017f3:	38 d3                	cmp    %dl,%bl
  8017f5:	75 06                	jne    8017fd <strchr+0x1c>
  8017f7:	eb 17                	jmp    801810 <strchr+0x2f>
  8017f9:	38 ca                	cmp    %cl,%dl
  8017fb:	74 13                	je     801810 <strchr+0x2f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017fd:	40                   	inc    %eax
  8017fe:	8a 10                	mov    (%eax),%dl
  801800:	84 d2                	test   %dl,%dl
  801802:	75 f5                	jne    8017f9 <strchr+0x18>
		if (*s == c)
			return (char *) s;
	return 0;
  801804:	b8 00 00 00 00       	mov    $0x0,%eax
  801809:	eb 05                	jmp    801810 <strchr+0x2f>
  80180b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801810:	5b                   	pop    %ebx
  801811:	5d                   	pop    %ebp
  801812:	c3                   	ret    

00801813 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801813:	55                   	push   %ebp
  801814:	89 e5                	mov    %esp,%ebp
  801816:	53                   	push   %ebx
  801817:	8b 45 08             	mov    0x8(%ebp),%eax
  80181a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  80181d:	8a 10                	mov    (%eax),%dl
  80181f:	84 d2                	test   %dl,%dl
  801821:	74 13                	je     801836 <strfind+0x23>
  801823:	88 d9                	mov    %bl,%cl
		if (*s == c)
  801825:	38 d3                	cmp    %dl,%bl
  801827:	75 06                	jne    80182f <strfind+0x1c>
  801829:	eb 0b                	jmp    801836 <strfind+0x23>
  80182b:	38 ca                	cmp    %cl,%dl
  80182d:	74 07                	je     801836 <strfind+0x23>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80182f:	40                   	inc    %eax
  801830:	8a 10                	mov    (%eax),%dl
  801832:	84 d2                	test   %dl,%dl
  801834:	75 f5                	jne    80182b <strfind+0x18>
		if (*s == c)
			break;
	return (char *) s;
}
  801836:	5b                   	pop    %ebx
  801837:	5d                   	pop    %ebp
  801838:	c3                   	ret    

00801839 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801839:	55                   	push   %ebp
  80183a:	89 e5                	mov    %esp,%ebp
  80183c:	57                   	push   %edi
  80183d:	56                   	push   %esi
  80183e:	53                   	push   %ebx
  80183f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801842:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801845:	85 c9                	test   %ecx,%ecx
  801847:	74 36                	je     80187f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801849:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80184f:	75 28                	jne    801879 <memset+0x40>
  801851:	f6 c1 03             	test   $0x3,%cl
  801854:	75 23                	jne    801879 <memset+0x40>
		c &= 0xFF;
  801856:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80185a:	89 d3                	mov    %edx,%ebx
  80185c:	c1 e3 08             	shl    $0x8,%ebx
  80185f:	89 d6                	mov    %edx,%esi
  801861:	c1 e6 18             	shl    $0x18,%esi
  801864:	89 d0                	mov    %edx,%eax
  801866:	c1 e0 10             	shl    $0x10,%eax
  801869:	09 f0                	or     %esi,%eax
  80186b:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80186d:	89 d8                	mov    %ebx,%eax
  80186f:	09 d0                	or     %edx,%eax
  801871:	c1 e9 02             	shr    $0x2,%ecx
  801874:	fc                   	cld    
  801875:	f3 ab                	rep stos %eax,%es:(%edi)
  801877:	eb 06                	jmp    80187f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801879:	8b 45 0c             	mov    0xc(%ebp),%eax
  80187c:	fc                   	cld    
  80187d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80187f:	89 f8                	mov    %edi,%eax
  801881:	5b                   	pop    %ebx
  801882:	5e                   	pop    %esi
  801883:	5f                   	pop    %edi
  801884:	5d                   	pop    %ebp
  801885:	c3                   	ret    

00801886 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801886:	55                   	push   %ebp
  801887:	89 e5                	mov    %esp,%ebp
  801889:	57                   	push   %edi
  80188a:	56                   	push   %esi
  80188b:	8b 45 08             	mov    0x8(%ebp),%eax
  80188e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801891:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801894:	39 c6                	cmp    %eax,%esi
  801896:	73 33                	jae    8018cb <memmove+0x45>
  801898:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80189b:	39 d0                	cmp    %edx,%eax
  80189d:	73 2c                	jae    8018cb <memmove+0x45>
		s += n;
		d += n;
  80189f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018a2:	89 d6                	mov    %edx,%esi
  8018a4:	09 fe                	or     %edi,%esi
  8018a6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018ac:	75 13                	jne    8018c1 <memmove+0x3b>
  8018ae:	f6 c1 03             	test   $0x3,%cl
  8018b1:	75 0e                	jne    8018c1 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8018b3:	83 ef 04             	sub    $0x4,%edi
  8018b6:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018b9:	c1 e9 02             	shr    $0x2,%ecx
  8018bc:	fd                   	std    
  8018bd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018bf:	eb 07                	jmp    8018c8 <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8018c1:	4f                   	dec    %edi
  8018c2:	8d 72 ff             	lea    -0x1(%edx),%esi
  8018c5:	fd                   	std    
  8018c6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018c8:	fc                   	cld    
  8018c9:	eb 1d                	jmp    8018e8 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018cb:	89 f2                	mov    %esi,%edx
  8018cd:	09 c2                	or     %eax,%edx
  8018cf:	f6 c2 03             	test   $0x3,%dl
  8018d2:	75 0f                	jne    8018e3 <memmove+0x5d>
  8018d4:	f6 c1 03             	test   $0x3,%cl
  8018d7:	75 0a                	jne    8018e3 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
  8018d9:	c1 e9 02             	shr    $0x2,%ecx
  8018dc:	89 c7                	mov    %eax,%edi
  8018de:	fc                   	cld    
  8018df:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018e1:	eb 05                	jmp    8018e8 <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018e3:	89 c7                	mov    %eax,%edi
  8018e5:	fc                   	cld    
  8018e6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018e8:	5e                   	pop    %esi
  8018e9:	5f                   	pop    %edi
  8018ea:	5d                   	pop    %ebp
  8018eb:	c3                   	ret    

008018ec <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018ec:	55                   	push   %ebp
  8018ed:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018ef:	ff 75 10             	pushl  0x10(%ebp)
  8018f2:	ff 75 0c             	pushl  0xc(%ebp)
  8018f5:	ff 75 08             	pushl  0x8(%ebp)
  8018f8:	e8 89 ff ff ff       	call   801886 <memmove>
}
  8018fd:	c9                   	leave  
  8018fe:	c3                   	ret    

008018ff <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018ff:	55                   	push   %ebp
  801900:	89 e5                	mov    %esp,%ebp
  801902:	57                   	push   %edi
  801903:	56                   	push   %esi
  801904:	53                   	push   %ebx
  801905:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801908:	8b 75 0c             	mov    0xc(%ebp),%esi
  80190b:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80190e:	85 c0                	test   %eax,%eax
  801910:	74 33                	je     801945 <memcmp+0x46>
  801912:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  801915:	8a 13                	mov    (%ebx),%dl
  801917:	8a 0e                	mov    (%esi),%cl
  801919:	38 ca                	cmp    %cl,%dl
  80191b:	75 13                	jne    801930 <memcmp+0x31>
  80191d:	b8 00 00 00 00       	mov    $0x0,%eax
  801922:	eb 16                	jmp    80193a <memcmp+0x3b>
  801924:	8a 54 03 01          	mov    0x1(%ebx,%eax,1),%dl
  801928:	40                   	inc    %eax
  801929:	8a 0c 06             	mov    (%esi,%eax,1),%cl
  80192c:	38 ca                	cmp    %cl,%dl
  80192e:	74 0a                	je     80193a <memcmp+0x3b>
			return (int) *s1 - (int) *s2;
  801930:	0f b6 c2             	movzbl %dl,%eax
  801933:	0f b6 c9             	movzbl %cl,%ecx
  801936:	29 c8                	sub    %ecx,%eax
  801938:	eb 10                	jmp    80194a <memcmp+0x4b>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80193a:	39 f8                	cmp    %edi,%eax
  80193c:	75 e6                	jne    801924 <memcmp+0x25>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80193e:	b8 00 00 00 00       	mov    $0x0,%eax
  801943:	eb 05                	jmp    80194a <memcmp+0x4b>
  801945:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80194a:	5b                   	pop    %ebx
  80194b:	5e                   	pop    %esi
  80194c:	5f                   	pop    %edi
  80194d:	5d                   	pop    %ebp
  80194e:	c3                   	ret    

0080194f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80194f:	55                   	push   %ebp
  801950:	89 e5                	mov    %esp,%ebp
  801952:	53                   	push   %ebx
  801953:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  801956:	89 d0                	mov    %edx,%eax
  801958:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  80195b:	39 c2                	cmp    %eax,%edx
  80195d:	73 1b                	jae    80197a <memfind+0x2b>
		if (*(const unsigned char *) s == (unsigned char) c)
  80195f:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  801963:	0f b6 0a             	movzbl (%edx),%ecx
  801966:	39 d9                	cmp    %ebx,%ecx
  801968:	75 09                	jne    801973 <memfind+0x24>
  80196a:	eb 12                	jmp    80197e <memfind+0x2f>
  80196c:	0f b6 0a             	movzbl (%edx),%ecx
  80196f:	39 d9                	cmp    %ebx,%ecx
  801971:	74 0f                	je     801982 <memfind+0x33>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801973:	42                   	inc    %edx
  801974:	39 d0                	cmp    %edx,%eax
  801976:	75 f4                	jne    80196c <memfind+0x1d>
  801978:	eb 0a                	jmp    801984 <memfind+0x35>
  80197a:	89 d0                	mov    %edx,%eax
  80197c:	eb 06                	jmp    801984 <memfind+0x35>
		if (*(const unsigned char *) s == (unsigned char) c)
  80197e:	89 d0                	mov    %edx,%eax
  801980:	eb 02                	jmp    801984 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801982:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801984:	5b                   	pop    %ebx
  801985:	5d                   	pop    %ebp
  801986:	c3                   	ret    

00801987 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801987:	55                   	push   %ebp
  801988:	89 e5                	mov    %esp,%ebp
  80198a:	57                   	push   %edi
  80198b:	56                   	push   %esi
  80198c:	53                   	push   %ebx
  80198d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801990:	eb 01                	jmp    801993 <strtol+0xc>
		s++;
  801992:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801993:	8a 01                	mov    (%ecx),%al
  801995:	3c 20                	cmp    $0x20,%al
  801997:	74 f9                	je     801992 <strtol+0xb>
  801999:	3c 09                	cmp    $0x9,%al
  80199b:	74 f5                	je     801992 <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  80199d:	3c 2b                	cmp    $0x2b,%al
  80199f:	75 08                	jne    8019a9 <strtol+0x22>
		s++;
  8019a1:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8019a2:	bf 00 00 00 00       	mov    $0x0,%edi
  8019a7:	eb 11                	jmp    8019ba <strtol+0x33>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8019a9:	3c 2d                	cmp    $0x2d,%al
  8019ab:	75 08                	jne    8019b5 <strtol+0x2e>
		s++, neg = 1;
  8019ad:	41                   	inc    %ecx
  8019ae:	bf 01 00 00 00       	mov    $0x1,%edi
  8019b3:	eb 05                	jmp    8019ba <strtol+0x33>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8019b5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019ba:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019be:	0f 84 87 00 00 00    	je     801a4b <strtol+0xc4>
  8019c4:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  8019c8:	75 27                	jne    8019f1 <strtol+0x6a>
  8019ca:	80 39 30             	cmpb   $0x30,(%ecx)
  8019cd:	75 22                	jne    8019f1 <strtol+0x6a>
  8019cf:	e9 88 00 00 00       	jmp    801a5c <strtol+0xd5>
		s += 2, base = 16;
  8019d4:	83 c1 02             	add    $0x2,%ecx
  8019d7:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  8019de:	eb 11                	jmp    8019f1 <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
  8019e0:	41                   	inc    %ecx
  8019e1:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  8019e8:	eb 07                	jmp    8019f1 <strtol+0x6a>
	else if (base == 0)
		base = 10;
  8019ea:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  8019f1:	b8 00 00 00 00       	mov    $0x0,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019f6:	8a 11                	mov    (%ecx),%dl
  8019f8:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8019fb:	80 fb 09             	cmp    $0x9,%bl
  8019fe:	77 08                	ja     801a08 <strtol+0x81>
			dig = *s - '0';
  801a00:	0f be d2             	movsbl %dl,%edx
  801a03:	83 ea 30             	sub    $0x30,%edx
  801a06:	eb 22                	jmp    801a2a <strtol+0xa3>
		else if (*s >= 'a' && *s <= 'z')
  801a08:	8d 72 9f             	lea    -0x61(%edx),%esi
  801a0b:	89 f3                	mov    %esi,%ebx
  801a0d:	80 fb 19             	cmp    $0x19,%bl
  801a10:	77 08                	ja     801a1a <strtol+0x93>
			dig = *s - 'a' + 10;
  801a12:	0f be d2             	movsbl %dl,%edx
  801a15:	83 ea 57             	sub    $0x57,%edx
  801a18:	eb 10                	jmp    801a2a <strtol+0xa3>
		else if (*s >= 'A' && *s <= 'Z')
  801a1a:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a1d:	89 f3                	mov    %esi,%ebx
  801a1f:	80 fb 19             	cmp    $0x19,%bl
  801a22:	77 14                	ja     801a38 <strtol+0xb1>
			dig = *s - 'A' + 10;
  801a24:	0f be d2             	movsbl %dl,%edx
  801a27:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801a2a:	3b 55 10             	cmp    0x10(%ebp),%edx
  801a2d:	7d 09                	jge    801a38 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  801a2f:	41                   	inc    %ecx
  801a30:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a34:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801a36:	eb be                	jmp    8019f6 <strtol+0x6f>

	if (endptr)
  801a38:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a3c:	74 05                	je     801a43 <strtol+0xbc>
		*endptr = (char *) s;
  801a3e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a41:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801a43:	85 ff                	test   %edi,%edi
  801a45:	74 21                	je     801a68 <strtol+0xe1>
  801a47:	f7 d8                	neg    %eax
  801a49:	eb 1d                	jmp    801a68 <strtol+0xe1>
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801a4b:	80 39 30             	cmpb   $0x30,(%ecx)
  801a4e:	75 9a                	jne    8019ea <strtol+0x63>
  801a50:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801a54:	0f 84 7a ff ff ff    	je     8019d4 <strtol+0x4d>
  801a5a:	eb 84                	jmp    8019e0 <strtol+0x59>
  801a5c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801a60:	0f 84 6e ff ff ff    	je     8019d4 <strtol+0x4d>
  801a66:	eb 89                	jmp    8019f1 <strtol+0x6a>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  801a68:	5b                   	pop    %ebx
  801a69:	5e                   	pop    %esi
  801a6a:	5f                   	pop    %edi
  801a6b:	5d                   	pop    %ebp
  801a6c:	c3                   	ret    

00801a6d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a6d:	55                   	push   %ebp
  801a6e:	89 e5                	mov    %esp,%ebp
  801a70:	56                   	push   %esi
  801a71:	53                   	push   %ebx
  801a72:	8b 75 08             	mov    0x8(%ebp),%esi
  801a75:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a78:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");
	int r;
    if (pg != NULL) {
  801a7b:	85 c0                	test   %eax,%eax
  801a7d:	74 0e                	je     801a8d <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  801a7f:	83 ec 0c             	sub    $0xc,%esp
  801a82:	50                   	push   %eax
  801a83:	e8 9b e8 ff ff       	call   800323 <sys_ipc_recv>
  801a88:	83 c4 10             	add    $0x10,%esp
  801a8b:	eb 10                	jmp    801a9d <ipc_recv+0x30>
    } else {
        r = sys_ipc_recv((void *) UTOP);
  801a8d:	83 ec 0c             	sub    $0xc,%esp
  801a90:	68 00 00 c0 ee       	push   $0xeec00000
  801a95:	e8 89 e8 ff ff       	call   800323 <sys_ipc_recv>
  801a9a:	83 c4 10             	add    $0x10,%esp
    }
    if (r < 0) {
  801a9d:	85 c0                	test   %eax,%eax
  801a9f:	79 16                	jns    801ab7 <ipc_recv+0x4a>
        // failed
        if (from_env_store != NULL) *from_env_store = 0;
  801aa1:	85 f6                	test   %esi,%esi
  801aa3:	74 06                	je     801aab <ipc_recv+0x3e>
  801aa5:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL) *perm_store = 0;
  801aab:	85 db                	test   %ebx,%ebx
  801aad:	74 2c                	je     801adb <ipc_recv+0x6e>
  801aaf:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801ab5:	eb 24                	jmp    801adb <ipc_recv+0x6e>
        return r;
    } else {
        if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801ab7:	85 f6                	test   %esi,%esi
  801ab9:	74 0a                	je     801ac5 <ipc_recv+0x58>
  801abb:	a1 04 40 80 00       	mov    0x804004,%eax
  801ac0:	8b 40 74             	mov    0x74(%eax),%eax
  801ac3:	89 06                	mov    %eax,(%esi)
        if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801ac5:	85 db                	test   %ebx,%ebx
  801ac7:	74 0a                	je     801ad3 <ipc_recv+0x66>
  801ac9:	a1 04 40 80 00       	mov    0x804004,%eax
  801ace:	8b 40 78             	mov    0x78(%eax),%eax
  801ad1:	89 03                	mov    %eax,(%ebx)
        return thisenv->env_ipc_value;
  801ad3:	a1 04 40 80 00       	mov    0x804004,%eax
  801ad8:	8b 40 70             	mov    0x70(%eax),%eax
    }
 
	return 0;
}
  801adb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ade:	5b                   	pop    %ebx
  801adf:	5e                   	pop    %esi
  801ae0:	5d                   	pop    %ebp
  801ae1:	c3                   	ret    

00801ae2 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ae2:	55                   	push   %ebp
  801ae3:	89 e5                	mov    %esp,%ebp
  801ae5:	57                   	push   %edi
  801ae6:	56                   	push   %esi
  801ae7:	53                   	push   %ebx
  801ae8:	83 ec 0c             	sub    $0xc,%esp
  801aeb:	8b 75 10             	mov    0x10(%ebp),%esi
  801aee:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;
    if (pg == NULL) pg = (void *)UTOP;
  801af1:	85 f6                	test   %esi,%esi
  801af3:	75 05                	jne    801afa <ipc_send+0x18>
  801af5:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
  801afa:	57                   	push   %edi
  801afb:	56                   	push   %esi
  801afc:	ff 75 0c             	pushl  0xc(%ebp)
  801aff:	ff 75 08             	pushl  0x8(%ebp)
  801b02:	e8 f9 e7 ff ff       	call   800300 <sys_ipc_try_send>
  801b07:	89 c3                	mov    %eax,%ebx
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
  801b09:	83 c4 10             	add    $0x10,%esp
  801b0c:	85 c0                	test   %eax,%eax
  801b0e:	79 17                	jns    801b27 <ipc_send+0x45>
  801b10:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b13:	74 1d                	je     801b32 <ipc_send+0x50>
  801b15:	50                   	push   %eax
  801b16:	68 a0 22 80 00       	push   $0x8022a0
  801b1b:	6a 40                	push   $0x40
  801b1d:	68 b4 22 80 00       	push   $0x8022b4
  801b22:	e8 d5 f4 ff ff       	call   800ffc <_panic>
        sys_yield();
  801b27:	e8 28 e6 ff ff       	call   800154 <sys_yield>
    } while (r != 0);
  801b2c:	85 db                	test   %ebx,%ebx
  801b2e:	75 ca                	jne    801afa <ipc_send+0x18>
  801b30:	eb 07                	jmp    801b39 <ipc_send+0x57>
	int r;
    if (pg == NULL) pg = (void *)UTOP;
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
        sys_yield();
  801b32:	e8 1d e6 ff ff       	call   800154 <sys_yield>
  801b37:	eb c1                	jmp    801afa <ipc_send+0x18>
    } while (r != 0);
}
  801b39:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b3c:	5b                   	pop    %ebx
  801b3d:	5e                   	pop    %esi
  801b3e:	5f                   	pop    %edi
  801b3f:	5d                   	pop    %ebp
  801b40:	c3                   	ret    

00801b41 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b41:	55                   	push   %ebp
  801b42:	89 e5                	mov    %esp,%ebp
  801b44:	53                   	push   %ebx
  801b45:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801b48:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  801b4d:	39 c1                	cmp    %eax,%ecx
  801b4f:	74 21                	je     801b72 <ipc_find_env+0x31>
  801b51:	ba 01 00 00 00       	mov    $0x1,%edx
  801b56:	8d 1c 95 00 00 00 00 	lea    0x0(,%edx,4),%ebx
  801b5d:	89 d0                	mov    %edx,%eax
  801b5f:	c1 e0 07             	shl    $0x7,%eax
  801b62:	29 d8                	sub    %ebx,%eax
  801b64:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b69:	8b 40 50             	mov    0x50(%eax),%eax
  801b6c:	39 c8                	cmp    %ecx,%eax
  801b6e:	75 1b                	jne    801b8b <ipc_find_env+0x4a>
  801b70:	eb 05                	jmp    801b77 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b72:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801b77:	8d 04 95 00 00 00 00 	lea    0x0(,%edx,4),%eax
  801b7e:	c1 e2 07             	shl    $0x7,%edx
  801b81:	29 c2                	sub    %eax,%edx
  801b83:	8b 82 48 00 c0 ee    	mov    -0x113fffb8(%edx),%eax
  801b89:	eb 0e                	jmp    801b99 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b8b:	42                   	inc    %edx
  801b8c:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  801b92:	75 c2                	jne    801b56 <ipc_find_env+0x15>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b94:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b99:	5b                   	pop    %ebx
  801b9a:	5d                   	pop    %ebp
  801b9b:	c3                   	ret    

00801b9c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b9c:	55                   	push   %ebp
  801b9d:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b9f:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba2:	c1 e8 16             	shr    $0x16,%eax
  801ba5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801bac:	a8 01                	test   $0x1,%al
  801bae:	74 21                	je     801bd1 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801bb0:	8b 45 08             	mov    0x8(%ebp),%eax
  801bb3:	c1 e8 0c             	shr    $0xc,%eax
  801bb6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801bbd:	a8 01                	test   $0x1,%al
  801bbf:	74 17                	je     801bd8 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bc1:	c1 e8 0c             	shr    $0xc,%eax
  801bc4:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801bcb:	ef 
  801bcc:	0f b7 c0             	movzwl %ax,%eax
  801bcf:	eb 0c                	jmp    801bdd <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801bd1:	b8 00 00 00 00       	mov    $0x0,%eax
  801bd6:	eb 05                	jmp    801bdd <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801bd8:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801bdd:	5d                   	pop    %ebp
  801bde:	c3                   	ret    
  801bdf:	90                   	nop

00801be0 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801be0:	55                   	push   %ebp
  801be1:	57                   	push   %edi
  801be2:	56                   	push   %esi
  801be3:	53                   	push   %ebx
  801be4:	83 ec 1c             	sub    $0x1c,%esp
  801be7:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801beb:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801bef:	8b 7c 24 38          	mov    0x38(%esp),%edi
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801bf3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bf7:	89 ca                	mov    %ecx,%edx
  const DWunion dd = {.ll = d};
  801bf9:	89 f8                	mov    %edi,%eax
  801bfb:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801bff:	85 f6                	test   %esi,%esi
  801c01:	75 2d                	jne    801c30 <__udivdi3+0x50>
    {
      if (d0 > n1)
  801c03:	39 cf                	cmp    %ecx,%edi
  801c05:	77 65                	ja     801c6c <__udivdi3+0x8c>
  801c07:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801c09:	85 ff                	test   %edi,%edi
  801c0b:	75 0b                	jne    801c18 <__udivdi3+0x38>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801c0d:	b8 01 00 00 00       	mov    $0x1,%eax
  801c12:	31 d2                	xor    %edx,%edx
  801c14:	f7 f7                	div    %edi
  801c16:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801c18:	31 d2                	xor    %edx,%edx
  801c1a:	89 c8                	mov    %ecx,%eax
  801c1c:	f7 f5                	div    %ebp
  801c1e:	89 c1                	mov    %eax,%ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c20:	89 d8                	mov    %ebx,%eax
  801c22:	f7 f5                	div    %ebp
  801c24:	89 cf                	mov    %ecx,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c26:	89 fa                	mov    %edi,%edx
  801c28:	83 c4 1c             	add    $0x1c,%esp
  801c2b:	5b                   	pop    %ebx
  801c2c:	5e                   	pop    %esi
  801c2d:	5f                   	pop    %edi
  801c2e:	5d                   	pop    %ebp
  801c2f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801c30:	39 ce                	cmp    %ecx,%esi
  801c32:	77 28                	ja     801c5c <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801c34:	0f bd fe             	bsr    %esi,%edi
	  if (bm == 0)
  801c37:	83 f7 1f             	xor    $0x1f,%edi
  801c3a:	75 40                	jne    801c7c <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801c3c:	39 ce                	cmp    %ecx,%esi
  801c3e:	72 0a                	jb     801c4a <__udivdi3+0x6a>
  801c40:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801c44:	0f 87 9e 00 00 00    	ja     801ce8 <__udivdi3+0x108>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801c4a:	b8 01 00 00 00       	mov    $0x1,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c4f:	89 fa                	mov    %edi,%edx
  801c51:	83 c4 1c             	add    $0x1c,%esp
  801c54:	5b                   	pop    %ebx
  801c55:	5e                   	pop    %esi
  801c56:	5f                   	pop    %edi
  801c57:	5d                   	pop    %ebp
  801c58:	c3                   	ret    
  801c59:	8d 76 00             	lea    0x0(%esi),%esi
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801c5c:	31 ff                	xor    %edi,%edi
  801c5e:	31 c0                	xor    %eax,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c60:	89 fa                	mov    %edi,%edx
  801c62:	83 c4 1c             	add    $0x1c,%esp
  801c65:	5b                   	pop    %ebx
  801c66:	5e                   	pop    %esi
  801c67:	5f                   	pop    %edi
  801c68:	5d                   	pop    %ebp
  801c69:	c3                   	ret    
  801c6a:	66 90                	xchg   %ax,%ax
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c6c:	89 d8                	mov    %ebx,%eax
  801c6e:	f7 f7                	div    %edi
  801c70:	31 ff                	xor    %edi,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c72:	89 fa                	mov    %edi,%edx
  801c74:	83 c4 1c             	add    $0x1c,%esp
  801c77:	5b                   	pop    %ebx
  801c78:	5e                   	pop    %esi
  801c79:	5f                   	pop    %edi
  801c7a:	5d                   	pop    %ebp
  801c7b:	c3                   	ret    
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801c7c:	bd 20 00 00 00       	mov    $0x20,%ebp
  801c81:	89 eb                	mov    %ebp,%ebx
  801c83:	29 fb                	sub    %edi,%ebx

	      d1 = (d1 << bm) | (d0 >> b);
  801c85:	89 f9                	mov    %edi,%ecx
  801c87:	d3 e6                	shl    %cl,%esi
  801c89:	89 c5                	mov    %eax,%ebp
  801c8b:	88 d9                	mov    %bl,%cl
  801c8d:	d3 ed                	shr    %cl,%ebp
  801c8f:	89 e9                	mov    %ebp,%ecx
  801c91:	09 f1                	or     %esi,%ecx
  801c93:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
	      d0 = d0 << bm;
  801c97:	89 f9                	mov    %edi,%ecx
  801c99:	d3 e0                	shl    %cl,%eax
  801c9b:	89 c5                	mov    %eax,%ebp
	      n2 = n1 >> b;
  801c9d:	89 d6                	mov    %edx,%esi
  801c9f:	88 d9                	mov    %bl,%cl
  801ca1:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
  801ca3:	89 f9                	mov    %edi,%ecx
  801ca5:	d3 e2                	shl    %cl,%edx
  801ca7:	8b 44 24 08          	mov    0x8(%esp),%eax
  801cab:	88 d9                	mov    %bl,%cl
  801cad:	d3 e8                	shr    %cl,%eax
  801caf:	09 c2                	or     %eax,%edx
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801cb1:	89 d0                	mov    %edx,%eax
  801cb3:	89 f2                	mov    %esi,%edx
  801cb5:	f7 74 24 0c          	divl   0xc(%esp)
  801cb9:	89 d6                	mov    %edx,%esi
  801cbb:	89 c3                	mov    %eax,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  801cbd:	f7 e5                	mul    %ebp

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801cbf:	39 d6                	cmp    %edx,%esi
  801cc1:	72 19                	jb     801cdc <__udivdi3+0xfc>
  801cc3:	74 0b                	je     801cd0 <__udivdi3+0xf0>
  801cc5:	89 d8                	mov    %ebx,%eax
  801cc7:	31 ff                	xor    %edi,%edi
  801cc9:	e9 58 ff ff ff       	jmp    801c26 <__udivdi3+0x46>
  801cce:	66 90                	xchg   %ax,%ax
  801cd0:	8b 54 24 08          	mov    0x8(%esp),%edx
  801cd4:	89 f9                	mov    %edi,%ecx
  801cd6:	d3 e2                	shl    %cl,%edx
  801cd8:	39 c2                	cmp    %eax,%edx
  801cda:	73 e9                	jae    801cc5 <__udivdi3+0xe5>
  801cdc:	8d 43 ff             	lea    -0x1(%ebx),%eax
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801cdf:	31 ff                	xor    %edi,%edi
  801ce1:	e9 40 ff ff ff       	jmp    801c26 <__udivdi3+0x46>
  801ce6:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801ce8:	31 c0                	xor    %eax,%eax
  801cea:	e9 37 ff ff ff       	jmp    801c26 <__udivdi3+0x46>
  801cef:	90                   	nop

00801cf0 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801cf0:	55                   	push   %ebp
  801cf1:	57                   	push   %edi
  801cf2:	56                   	push   %esi
  801cf3:	53                   	push   %ebx
  801cf4:	83 ec 1c             	sub    $0x1c,%esp
  801cf7:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801cfb:	8b 74 24 34          	mov    0x34(%esp),%esi
  801cff:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d03:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801d07:	89 44 24 0c          	mov    %eax,0xc(%esp)
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801d0b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d0f:	89 f3                	mov    %esi,%ebx
  const DWunion dd = {.ll = d};
  801d11:	89 fa                	mov    %edi,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801d13:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  n1 = nn.s.high;
  801d17:	89 34 24             	mov    %esi,(%esp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801d1a:	85 c0                	test   %eax,%eax
  801d1c:	75 1a                	jne    801d38 <__umoddi3+0x48>
    {
      if (d0 > n1)
  801d1e:	39 f7                	cmp    %esi,%edi
  801d20:	0f 86 a2 00 00 00    	jbe    801dc8 <__umoddi3+0xd8>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d26:	89 c8                	mov    %ecx,%eax
  801d28:	89 f2                	mov    %esi,%edx
  801d2a:	f7 f7                	div    %edi
  801d2c:	89 d0                	mov    %edx,%eax

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801d2e:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d30:	83 c4 1c             	add    $0x1c,%esp
  801d33:	5b                   	pop    %ebx
  801d34:	5e                   	pop    %esi
  801d35:	5f                   	pop    %edi
  801d36:	5d                   	pop    %ebp
  801d37:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801d38:	39 f0                	cmp    %esi,%eax
  801d3a:	0f 87 ac 00 00 00    	ja     801dec <__umoddi3+0xfc>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801d40:	0f bd e8             	bsr    %eax,%ebp
	  if (bm == 0)
  801d43:	83 f5 1f             	xor    $0x1f,%ebp
  801d46:	0f 84 ac 00 00 00    	je     801df8 <__umoddi3+0x108>
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801d4c:	bf 20 00 00 00       	mov    $0x20,%edi
  801d51:	29 ef                	sub    %ebp,%edi
  801d53:	89 fe                	mov    %edi,%esi
  801d55:	89 7c 24 0c          	mov    %edi,0xc(%esp)

	      d1 = (d1 << bm) | (d0 >> b);
  801d59:	89 e9                	mov    %ebp,%ecx
  801d5b:	d3 e0                	shl    %cl,%eax
  801d5d:	89 d7                	mov    %edx,%edi
  801d5f:	89 f1                	mov    %esi,%ecx
  801d61:	d3 ef                	shr    %cl,%edi
  801d63:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  801d65:	89 e9                	mov    %ebp,%ecx
  801d67:	d3 e2                	shl    %cl,%edx
  801d69:	89 14 24             	mov    %edx,(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801d6c:	89 d8                	mov    %ebx,%eax
  801d6e:	d3 e0                	shl    %cl,%eax
  801d70:	89 c2                	mov    %eax,%edx
	      n0 = n0 << bm;
  801d72:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d76:	d3 e0                	shl    %cl,%eax
  801d78:	89 44 24 04          	mov    %eax,0x4(%esp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801d7c:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d80:	89 f1                	mov    %esi,%ecx
  801d82:	d3 e8                	shr    %cl,%eax
  801d84:	09 d0                	or     %edx,%eax
  801d86:	d3 eb                	shr    %cl,%ebx
  801d88:	89 da                	mov    %ebx,%edx
  801d8a:	f7 f7                	div    %edi
  801d8c:	89 d3                	mov    %edx,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  801d8e:	f7 24 24             	mull   (%esp)
  801d91:	89 c6                	mov    %eax,%esi
  801d93:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d95:	39 d3                	cmp    %edx,%ebx
  801d97:	0f 82 87 00 00 00    	jb     801e24 <__umoddi3+0x134>
  801d9d:	0f 84 91 00 00 00    	je     801e34 <__umoddi3+0x144>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801da3:	8b 54 24 04          	mov    0x4(%esp),%edx
  801da7:	29 f2                	sub    %esi,%edx
  801da9:	19 cb                	sbb    %ecx,%ebx
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801dab:	89 d8                	mov    %ebx,%eax
  801dad:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  801db1:	d3 e0                	shl    %cl,%eax
  801db3:	89 e9                	mov    %ebp,%ecx
  801db5:	d3 ea                	shr    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801db7:	09 d0                	or     %edx,%eax
  801db9:	89 e9                	mov    %ebp,%ecx
  801dbb:	d3 eb                	shr    %cl,%ebx
  801dbd:	89 da                	mov    %ebx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801dbf:	83 c4 1c             	add    $0x1c,%esp
  801dc2:	5b                   	pop    %ebx
  801dc3:	5e                   	pop    %esi
  801dc4:	5f                   	pop    %edi
  801dc5:	5d                   	pop    %ebp
  801dc6:	c3                   	ret    
  801dc7:	90                   	nop
  801dc8:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801dca:	85 ff                	test   %edi,%edi
  801dcc:	75 0b                	jne    801dd9 <__umoddi3+0xe9>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801dce:	b8 01 00 00 00       	mov    $0x1,%eax
  801dd3:	31 d2                	xor    %edx,%edx
  801dd5:	f7 f7                	div    %edi
  801dd7:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801dd9:	89 f0                	mov    %esi,%eax
  801ddb:	31 d2                	xor    %edx,%edx
  801ddd:	f7 f5                	div    %ebp
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801ddf:	89 c8                	mov    %ecx,%eax
  801de1:	f7 f5                	div    %ebp
  801de3:	89 d0                	mov    %edx,%eax
  801de5:	e9 44 ff ff ff       	jmp    801d2e <__umoddi3+0x3e>
  801dea:	66 90                	xchg   %ax,%ax
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801dec:	89 c8                	mov    %ecx,%eax
  801dee:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801df0:	83 c4 1c             	add    $0x1c,%esp
  801df3:	5b                   	pop    %ebx
  801df4:	5e                   	pop    %esi
  801df5:	5f                   	pop    %edi
  801df6:	5d                   	pop    %ebp
  801df7:	c3                   	ret    

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801df8:	3b 04 24             	cmp    (%esp),%eax
  801dfb:	72 06                	jb     801e03 <__umoddi3+0x113>
  801dfd:	3b 7c 24 04          	cmp    0x4(%esp),%edi
  801e01:	77 0f                	ja     801e12 <__umoddi3+0x122>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801e03:	89 f2                	mov    %esi,%edx
  801e05:	29 f9                	sub    %edi,%ecx
  801e07:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  801e0b:	89 14 24             	mov    %edx,(%esp)
  801e0e:	89 4c 24 04          	mov    %ecx,0x4(%esp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801e12:	8b 44 24 04          	mov    0x4(%esp),%eax
  801e16:	8b 14 24             	mov    (%esp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e19:	83 c4 1c             	add    $0x1c,%esp
  801e1c:	5b                   	pop    %ebx
  801e1d:	5e                   	pop    %esi
  801e1e:	5f                   	pop    %edi
  801e1f:	5d                   	pop    %ebp
  801e20:	c3                   	ret    
  801e21:	8d 76 00             	lea    0x0(%esi),%esi
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801e24:	2b 04 24             	sub    (%esp),%eax
  801e27:	19 fa                	sbb    %edi,%edx
  801e29:	89 d1                	mov    %edx,%ecx
  801e2b:	89 c6                	mov    %eax,%esi
  801e2d:	e9 71 ff ff ff       	jmp    801da3 <__umoddi3+0xb3>
  801e32:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e34:	39 44 24 04          	cmp    %eax,0x4(%esp)
  801e38:	72 ea                	jb     801e24 <__umoddi3+0x134>
  801e3a:	89 d9                	mov    %ebx,%ecx
  801e3c:	e9 62 ff ff ff       	jmp    801da3 <__umoddi3+0xb3>
