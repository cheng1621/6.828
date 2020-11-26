
obj/user/faultregs.debug:     file format elf32-i386


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
  80002c:	e8 2b 05 00 00       	call   80055c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <check_regs>:
static struct regs before, during, after;

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 0c             	sub    $0xc,%esp
  80003c:	89 c6                	mov    %eax,%esi
  80003e:	89 cb                	mov    %ecx,%ebx
	int mismatch = 0;

	cprintf("%-6s %-8s %-8s\n", "", an, bn);
  800040:	ff 75 08             	pushl  0x8(%ebp)
  800043:	52                   	push   %edx
  800044:	68 31 24 80 00       	push   $0x802431
  800049:	68 00 24 80 00       	push   $0x802400
  80004e:	e8 4a 06 00 00       	call   80069d <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800053:	ff 33                	pushl  (%ebx)
  800055:	ff 36                	pushl  (%esi)
  800057:	68 10 24 80 00       	push   $0x802410
  80005c:	68 14 24 80 00       	push   $0x802414
  800061:	e8 37 06 00 00       	call   80069d <cprintf>
  800066:	83 c4 20             	add    $0x20,%esp
  800069:	8b 03                	mov    (%ebx),%eax
  80006b:	39 06                	cmp    %eax,(%esi)
  80006d:	75 17                	jne    800086 <check_regs+0x53>
  80006f:	83 ec 0c             	sub    $0xc,%esp
  800072:	68 24 24 80 00       	push   $0x802424
  800077:	e8 21 06 00 00       	call   80069d <cprintf>
  80007c:	83 c4 10             	add    $0x10,%esp

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
	int mismatch = 0;
  80007f:	bf 00 00 00 00       	mov    $0x0,%edi
  800084:	eb 15                	jmp    80009b <check_regs+0x68>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800086:	83 ec 0c             	sub    $0xc,%esp
  800089:	68 28 24 80 00       	push   $0x802428
  80008e:	e8 0a 06 00 00       	call   80069d <cprintf>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  80009b:	ff 73 04             	pushl  0x4(%ebx)
  80009e:	ff 76 04             	pushl  0x4(%esi)
  8000a1:	68 32 24 80 00       	push   $0x802432
  8000a6:	68 14 24 80 00       	push   $0x802414
  8000ab:	e8 ed 05 00 00       	call   80069d <cprintf>
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	8b 43 04             	mov    0x4(%ebx),%eax
  8000b6:	39 46 04             	cmp    %eax,0x4(%esi)
  8000b9:	75 12                	jne    8000cd <check_regs+0x9a>
  8000bb:	83 ec 0c             	sub    $0xc,%esp
  8000be:	68 24 24 80 00       	push   $0x802424
  8000c3:	e8 d5 05 00 00       	call   80069d <cprintf>
  8000c8:	83 c4 10             	add    $0x10,%esp
  8000cb:	eb 15                	jmp    8000e2 <check_regs+0xaf>
  8000cd:	83 ec 0c             	sub    $0xc,%esp
  8000d0:	68 28 24 80 00       	push   $0x802428
  8000d5:	e8 c3 05 00 00       	call   80069d <cprintf>
  8000da:	83 c4 10             	add    $0x10,%esp
  8000dd:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000e2:	ff 73 08             	pushl  0x8(%ebx)
  8000e5:	ff 76 08             	pushl  0x8(%esi)
  8000e8:	68 36 24 80 00       	push   $0x802436
  8000ed:	68 14 24 80 00       	push   $0x802414
  8000f2:	e8 a6 05 00 00       	call   80069d <cprintf>
  8000f7:	83 c4 10             	add    $0x10,%esp
  8000fa:	8b 43 08             	mov    0x8(%ebx),%eax
  8000fd:	39 46 08             	cmp    %eax,0x8(%esi)
  800100:	75 12                	jne    800114 <check_regs+0xe1>
  800102:	83 ec 0c             	sub    $0xc,%esp
  800105:	68 24 24 80 00       	push   $0x802424
  80010a:	e8 8e 05 00 00       	call   80069d <cprintf>
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	eb 15                	jmp    800129 <check_regs+0xf6>
  800114:	83 ec 0c             	sub    $0xc,%esp
  800117:	68 28 24 80 00       	push   $0x802428
  80011c:	e8 7c 05 00 00       	call   80069d <cprintf>
  800121:	83 c4 10             	add    $0x10,%esp
  800124:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  800129:	ff 73 10             	pushl  0x10(%ebx)
  80012c:	ff 76 10             	pushl  0x10(%esi)
  80012f:	68 3a 24 80 00       	push   $0x80243a
  800134:	68 14 24 80 00       	push   $0x802414
  800139:	e8 5f 05 00 00       	call   80069d <cprintf>
  80013e:	83 c4 10             	add    $0x10,%esp
  800141:	8b 43 10             	mov    0x10(%ebx),%eax
  800144:	39 46 10             	cmp    %eax,0x10(%esi)
  800147:	75 12                	jne    80015b <check_regs+0x128>
  800149:	83 ec 0c             	sub    $0xc,%esp
  80014c:	68 24 24 80 00       	push   $0x802424
  800151:	e8 47 05 00 00       	call   80069d <cprintf>
  800156:	83 c4 10             	add    $0x10,%esp
  800159:	eb 15                	jmp    800170 <check_regs+0x13d>
  80015b:	83 ec 0c             	sub    $0xc,%esp
  80015e:	68 28 24 80 00       	push   $0x802428
  800163:	e8 35 05 00 00       	call   80069d <cprintf>
  800168:	83 c4 10             	add    $0x10,%esp
  80016b:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800170:	ff 73 14             	pushl  0x14(%ebx)
  800173:	ff 76 14             	pushl  0x14(%esi)
  800176:	68 3e 24 80 00       	push   $0x80243e
  80017b:	68 14 24 80 00       	push   $0x802414
  800180:	e8 18 05 00 00       	call   80069d <cprintf>
  800185:	83 c4 10             	add    $0x10,%esp
  800188:	8b 43 14             	mov    0x14(%ebx),%eax
  80018b:	39 46 14             	cmp    %eax,0x14(%esi)
  80018e:	75 12                	jne    8001a2 <check_regs+0x16f>
  800190:	83 ec 0c             	sub    $0xc,%esp
  800193:	68 24 24 80 00       	push   $0x802424
  800198:	e8 00 05 00 00       	call   80069d <cprintf>
  80019d:	83 c4 10             	add    $0x10,%esp
  8001a0:	eb 15                	jmp    8001b7 <check_regs+0x184>
  8001a2:	83 ec 0c             	sub    $0xc,%esp
  8001a5:	68 28 24 80 00       	push   $0x802428
  8001aa:	e8 ee 04 00 00       	call   80069d <cprintf>
  8001af:	83 c4 10             	add    $0x10,%esp
  8001b2:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  8001b7:	ff 73 18             	pushl  0x18(%ebx)
  8001ba:	ff 76 18             	pushl  0x18(%esi)
  8001bd:	68 42 24 80 00       	push   $0x802442
  8001c2:	68 14 24 80 00       	push   $0x802414
  8001c7:	e8 d1 04 00 00       	call   80069d <cprintf>
  8001cc:	83 c4 10             	add    $0x10,%esp
  8001cf:	8b 43 18             	mov    0x18(%ebx),%eax
  8001d2:	39 46 18             	cmp    %eax,0x18(%esi)
  8001d5:	75 12                	jne    8001e9 <check_regs+0x1b6>
  8001d7:	83 ec 0c             	sub    $0xc,%esp
  8001da:	68 24 24 80 00       	push   $0x802424
  8001df:	e8 b9 04 00 00       	call   80069d <cprintf>
  8001e4:	83 c4 10             	add    $0x10,%esp
  8001e7:	eb 15                	jmp    8001fe <check_regs+0x1cb>
  8001e9:	83 ec 0c             	sub    $0xc,%esp
  8001ec:	68 28 24 80 00       	push   $0x802428
  8001f1:	e8 a7 04 00 00       	call   80069d <cprintf>
  8001f6:	83 c4 10             	add    $0x10,%esp
  8001f9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  8001fe:	ff 73 1c             	pushl  0x1c(%ebx)
  800201:	ff 76 1c             	pushl  0x1c(%esi)
  800204:	68 46 24 80 00       	push   $0x802446
  800209:	68 14 24 80 00       	push   $0x802414
  80020e:	e8 8a 04 00 00       	call   80069d <cprintf>
  800213:	83 c4 10             	add    $0x10,%esp
  800216:	8b 43 1c             	mov    0x1c(%ebx),%eax
  800219:	39 46 1c             	cmp    %eax,0x1c(%esi)
  80021c:	75 12                	jne    800230 <check_regs+0x1fd>
  80021e:	83 ec 0c             	sub    $0xc,%esp
  800221:	68 24 24 80 00       	push   $0x802424
  800226:	e8 72 04 00 00       	call   80069d <cprintf>
  80022b:	83 c4 10             	add    $0x10,%esp
  80022e:	eb 15                	jmp    800245 <check_regs+0x212>
  800230:	83 ec 0c             	sub    $0xc,%esp
  800233:	68 28 24 80 00       	push   $0x802428
  800238:	e8 60 04 00 00       	call   80069d <cprintf>
  80023d:	83 c4 10             	add    $0x10,%esp
  800240:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  800245:	ff 73 20             	pushl  0x20(%ebx)
  800248:	ff 76 20             	pushl  0x20(%esi)
  80024b:	68 4a 24 80 00       	push   $0x80244a
  800250:	68 14 24 80 00       	push   $0x802414
  800255:	e8 43 04 00 00       	call   80069d <cprintf>
  80025a:	83 c4 10             	add    $0x10,%esp
  80025d:	8b 43 20             	mov    0x20(%ebx),%eax
  800260:	39 46 20             	cmp    %eax,0x20(%esi)
  800263:	75 12                	jne    800277 <check_regs+0x244>
  800265:	83 ec 0c             	sub    $0xc,%esp
  800268:	68 24 24 80 00       	push   $0x802424
  80026d:	e8 2b 04 00 00       	call   80069d <cprintf>
  800272:	83 c4 10             	add    $0x10,%esp
  800275:	eb 15                	jmp    80028c <check_regs+0x259>
  800277:	83 ec 0c             	sub    $0xc,%esp
  80027a:	68 28 24 80 00       	push   $0x802428
  80027f:	e8 19 04 00 00       	call   80069d <cprintf>
  800284:	83 c4 10             	add    $0x10,%esp
  800287:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  80028c:	ff 73 24             	pushl  0x24(%ebx)
  80028f:	ff 76 24             	pushl  0x24(%esi)
  800292:	68 4e 24 80 00       	push   $0x80244e
  800297:	68 14 24 80 00       	push   $0x802414
  80029c:	e8 fc 03 00 00       	call   80069d <cprintf>
  8002a1:	83 c4 10             	add    $0x10,%esp
  8002a4:	8b 43 24             	mov    0x24(%ebx),%eax
  8002a7:	39 46 24             	cmp    %eax,0x24(%esi)
  8002aa:	75 2f                	jne    8002db <check_regs+0x2a8>
  8002ac:	83 ec 0c             	sub    $0xc,%esp
  8002af:	68 24 24 80 00       	push   $0x802424
  8002b4:	e8 e4 03 00 00       	call   80069d <cprintf>
	CHECK(esp, esp);
  8002b9:	ff 73 28             	pushl  0x28(%ebx)
  8002bc:	ff 76 28             	pushl  0x28(%esi)
  8002bf:	68 55 24 80 00       	push   $0x802455
  8002c4:	68 14 24 80 00       	push   $0x802414
  8002c9:	e8 cf 03 00 00       	call   80069d <cprintf>
  8002ce:	83 c4 20             	add    $0x20,%esp
  8002d1:	8b 43 28             	mov    0x28(%ebx),%eax
  8002d4:	39 46 28             	cmp    %eax,0x28(%esi)
  8002d7:	74 31                	je     80030a <check_regs+0x2d7>
  8002d9:	eb 55                	jmp    800330 <check_regs+0x2fd>
	CHECK(ebx, regs.reg_ebx);
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
  8002db:	83 ec 0c             	sub    $0xc,%esp
  8002de:	68 28 24 80 00       	push   $0x802428
  8002e3:	e8 b5 03 00 00       	call   80069d <cprintf>
	CHECK(esp, esp);
  8002e8:	ff 73 28             	pushl  0x28(%ebx)
  8002eb:	ff 76 28             	pushl  0x28(%esi)
  8002ee:	68 55 24 80 00       	push   $0x802455
  8002f3:	68 14 24 80 00       	push   $0x802414
  8002f8:	e8 a0 03 00 00       	call   80069d <cprintf>
  8002fd:	83 c4 20             	add    $0x20,%esp
  800300:	8b 43 28             	mov    0x28(%ebx),%eax
  800303:	39 46 28             	cmp    %eax,0x28(%esi)
  800306:	75 28                	jne    800330 <check_regs+0x2fd>
  800308:	eb 6c                	jmp    800376 <check_regs+0x343>
  80030a:	83 ec 0c             	sub    $0xc,%esp
  80030d:	68 24 24 80 00       	push   $0x802424
  800312:	e8 86 03 00 00       	call   80069d <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800317:	83 c4 08             	add    $0x8,%esp
  80031a:	ff 75 0c             	pushl  0xc(%ebp)
  80031d:	68 59 24 80 00       	push   $0x802459
  800322:	e8 76 03 00 00       	call   80069d <cprintf>
	if (!mismatch)
  800327:	83 c4 10             	add    $0x10,%esp
  80032a:	85 ff                	test   %edi,%edi
  80032c:	74 24                	je     800352 <check_regs+0x31f>
  80032e:	eb 34                	jmp    800364 <check_regs+0x331>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  800330:	83 ec 0c             	sub    $0xc,%esp
  800333:	68 28 24 80 00       	push   $0x802428
  800338:	e8 60 03 00 00       	call   80069d <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  80033d:	83 c4 08             	add    $0x8,%esp
  800340:	ff 75 0c             	pushl  0xc(%ebp)
  800343:	68 59 24 80 00       	push   $0x802459
  800348:	e8 50 03 00 00       	call   80069d <cprintf>
  80034d:	83 c4 10             	add    $0x10,%esp
  800350:	eb 12                	jmp    800364 <check_regs+0x331>
	if (!mismatch)
		cprintf("OK\n");
  800352:	83 ec 0c             	sub    $0xc,%esp
  800355:	68 24 24 80 00       	push   $0x802424
  80035a:	e8 3e 03 00 00       	call   80069d <cprintf>
  80035f:	83 c4 10             	add    $0x10,%esp
  800362:	eb 34                	jmp    800398 <check_regs+0x365>
	else
		cprintf("MISMATCH\n");
  800364:	83 ec 0c             	sub    $0xc,%esp
  800367:	68 28 24 80 00       	push   $0x802428
  80036c:	e8 2c 03 00 00       	call   80069d <cprintf>
  800371:	83 c4 10             	add    $0x10,%esp
}
  800374:	eb 22                	jmp    800398 <check_regs+0x365>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  800376:	83 ec 0c             	sub    $0xc,%esp
  800379:	68 24 24 80 00       	push   $0x802424
  80037e:	e8 1a 03 00 00       	call   80069d <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800383:	83 c4 08             	add    $0x8,%esp
  800386:	ff 75 0c             	pushl  0xc(%ebp)
  800389:	68 59 24 80 00       	push   $0x802459
  80038e:	e8 0a 03 00 00       	call   80069d <cprintf>
  800393:	83 c4 10             	add    $0x10,%esp
  800396:	eb cc                	jmp    800364 <check_regs+0x331>
	if (!mismatch)
		cprintf("OK\n");
	else
		cprintf("MISMATCH\n");
}
  800398:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80039b:	5b                   	pop    %ebx
  80039c:	5e                   	pop    %esi
  80039d:	5f                   	pop    %edi
  80039e:	5d                   	pop    %ebp
  80039f:	c3                   	ret    

008003a0 <pgfault>:

static void
pgfault(struct UTrapframe *utf)
{
  8003a0:	55                   	push   %ebp
  8003a1:	89 e5                	mov    %esp,%ebp
  8003a3:	57                   	push   %edi
  8003a4:	56                   	push   %esi
  8003a5:	8b 45 08             	mov    0x8(%ebp),%eax
	int r;

	if (utf->utf_fault_va != (uint32_t)UTEMP)
  8003a8:	8b 10                	mov    (%eax),%edx
  8003aa:	81 fa 00 00 40 00    	cmp    $0x400000,%edx
  8003b0:	74 18                	je     8003ca <pgfault+0x2a>
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
  8003b2:	83 ec 0c             	sub    $0xc,%esp
  8003b5:	ff 70 28             	pushl  0x28(%eax)
  8003b8:	52                   	push   %edx
  8003b9:	68 c0 24 80 00       	push   $0x8024c0
  8003be:	6a 51                	push   $0x51
  8003c0:	68 67 24 80 00       	push   $0x802467
  8003c5:	e8 fb 01 00 00       	call   8005c5 <_panic>
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8003ca:	bf 40 40 80 00       	mov    $0x804040,%edi
  8003cf:	8d 70 08             	lea    0x8(%eax),%esi
  8003d2:	b9 08 00 00 00       	mov    $0x8,%ecx
  8003d7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	during.eip = utf->utf_eip;
  8003d9:	8b 50 28             	mov    0x28(%eax),%edx
  8003dc:	89 15 60 40 80 00    	mov    %edx,0x804060
	during.eflags = utf->utf_eflags;
  8003e2:	8b 50 2c             	mov    0x2c(%eax),%edx
  8003e5:	89 15 64 40 80 00    	mov    %edx,0x804064
	during.esp = utf->utf_esp;
  8003eb:	8b 40 30             	mov    0x30(%eax),%eax
  8003ee:	a3 68 40 80 00       	mov    %eax,0x804068
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  8003f3:	83 ec 08             	sub    $0x8,%esp
  8003f6:	68 7f 24 80 00       	push   $0x80247f
  8003fb:	68 8d 24 80 00       	push   $0x80248d
  800400:	b9 40 40 80 00       	mov    $0x804040,%ecx
  800405:	ba 78 24 80 00       	mov    $0x802478,%edx
  80040a:	b8 80 40 80 00       	mov    $0x804080,%eax
  80040f:	e8 1f fc ff ff       	call   800033 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  800414:	83 c4 0c             	add    $0xc,%esp
  800417:	6a 07                	push   $0x7
  800419:	68 00 00 40 00       	push   $0x400000
  80041e:	6a 00                	push   $0x0
  800420:	e8 cd 0c 00 00       	call   8010f2 <sys_page_alloc>
  800425:	83 c4 10             	add    $0x10,%esp
  800428:	85 c0                	test   %eax,%eax
  80042a:	79 12                	jns    80043e <pgfault+0x9e>
		panic("sys_page_alloc: %e", r);
  80042c:	50                   	push   %eax
  80042d:	68 94 24 80 00       	push   $0x802494
  800432:	6a 5c                	push   $0x5c
  800434:	68 67 24 80 00       	push   $0x802467
  800439:	e8 87 01 00 00       	call   8005c5 <_panic>
}
  80043e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800441:	5e                   	pop    %esi
  800442:	5f                   	pop    %edi
  800443:	5d                   	pop    %ebp
  800444:	c3                   	ret    

00800445 <umain>:

void
umain(int argc, char **argv)
{
  800445:	55                   	push   %ebp
  800446:	89 e5                	mov    %esp,%ebp
  800448:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(pgfault);
  80044b:	68 a0 03 80 00       	push   $0x8003a0
  800450:	e8 8e 0e 00 00       	call   8012e3 <set_pgfault_handler>

	__asm __volatile(
  800455:	50                   	push   %eax
  800456:	9c                   	pushf  
  800457:	58                   	pop    %eax
  800458:	0d d5 08 00 00       	or     $0x8d5,%eax
  80045d:	50                   	push   %eax
  80045e:	9d                   	popf   
  80045f:	a3 a4 40 80 00       	mov    %eax,0x8040a4
  800464:	8d 05 9f 04 80 00    	lea    0x80049f,%eax
  80046a:	a3 a0 40 80 00       	mov    %eax,0x8040a0
  80046f:	58                   	pop    %eax
  800470:	89 3d 80 40 80 00    	mov    %edi,0x804080
  800476:	89 35 84 40 80 00    	mov    %esi,0x804084
  80047c:	89 2d 88 40 80 00    	mov    %ebp,0x804088
  800482:	89 1d 90 40 80 00    	mov    %ebx,0x804090
  800488:	89 15 94 40 80 00    	mov    %edx,0x804094
  80048e:	89 0d 98 40 80 00    	mov    %ecx,0x804098
  800494:	a3 9c 40 80 00       	mov    %eax,0x80409c
  800499:	89 25 a8 40 80 00    	mov    %esp,0x8040a8
  80049f:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  8004a6:	00 00 00 
  8004a9:	89 3d 00 40 80 00    	mov    %edi,0x804000
  8004af:	89 35 04 40 80 00    	mov    %esi,0x804004
  8004b5:	89 2d 08 40 80 00    	mov    %ebp,0x804008
  8004bb:	89 1d 10 40 80 00    	mov    %ebx,0x804010
  8004c1:	89 15 14 40 80 00    	mov    %edx,0x804014
  8004c7:	89 0d 18 40 80 00    	mov    %ecx,0x804018
  8004cd:	a3 1c 40 80 00       	mov    %eax,0x80401c
  8004d2:	89 25 28 40 80 00    	mov    %esp,0x804028
  8004d8:	8b 3d 80 40 80 00    	mov    0x804080,%edi
  8004de:	8b 35 84 40 80 00    	mov    0x804084,%esi
  8004e4:	8b 2d 88 40 80 00    	mov    0x804088,%ebp
  8004ea:	8b 1d 90 40 80 00    	mov    0x804090,%ebx
  8004f0:	8b 15 94 40 80 00    	mov    0x804094,%edx
  8004f6:	8b 0d 98 40 80 00    	mov    0x804098,%ecx
  8004fc:	a1 9c 40 80 00       	mov    0x80409c,%eax
  800501:	8b 25 a8 40 80 00    	mov    0x8040a8,%esp
  800507:	50                   	push   %eax
  800508:	9c                   	pushf  
  800509:	58                   	pop    %eax
  80050a:	a3 24 40 80 00       	mov    %eax,0x804024
  80050f:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  800510:	83 c4 10             	add    $0x10,%esp
  800513:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  80051a:	74 10                	je     80052c <umain+0xe7>
		cprintf("EIP after page-fault MISMATCH\n");
  80051c:	83 ec 0c             	sub    $0xc,%esp
  80051f:	68 f4 24 80 00       	push   $0x8024f4
  800524:	e8 74 01 00 00       	call   80069d <cprintf>
  800529:	83 c4 10             	add    $0x10,%esp
	after.eip = before.eip;
  80052c:	a1 a0 40 80 00       	mov    0x8040a0,%eax
  800531:	a3 20 40 80 00       	mov    %eax,0x804020

	check_regs(&before, "before", &after, "after", "after page-fault");
  800536:	83 ec 08             	sub    $0x8,%esp
  800539:	68 a7 24 80 00       	push   $0x8024a7
  80053e:	68 b8 24 80 00       	push   $0x8024b8
  800543:	b9 00 40 80 00       	mov    $0x804000,%ecx
  800548:	ba 78 24 80 00       	mov    $0x802478,%edx
  80054d:	b8 80 40 80 00       	mov    $0x804080,%eax
  800552:	e8 dc fa ff ff       	call   800033 <check_regs>
}
  800557:	83 c4 10             	add    $0x10,%esp
  80055a:	c9                   	leave  
  80055b:	c3                   	ret    

0080055c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80055c:	55                   	push   %ebp
  80055d:	89 e5                	mov    %esp,%ebp
  80055f:	56                   	push   %esi
  800560:	53                   	push   %ebx
  800561:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800564:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800567:	e8 48 0b 00 00       	call   8010b4 <sys_getenvid>
  80056c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800571:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800578:	c1 e0 07             	shl    $0x7,%eax
  80057b:	29 d0                	sub    %edx,%eax
  80057d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800582:	a3 b0 40 80 00       	mov    %eax,0x8040b0

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800587:	85 db                	test   %ebx,%ebx
  800589:	7e 07                	jle    800592 <libmain+0x36>
		binaryname = argv[0];
  80058b:	8b 06                	mov    (%esi),%eax
  80058d:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800592:	83 ec 08             	sub    $0x8,%esp
  800595:	56                   	push   %esi
  800596:	53                   	push   %ebx
  800597:	e8 a9 fe ff ff       	call   800445 <umain>

	// exit gracefully
	exit();
  80059c:	e8 0a 00 00 00       	call   8005ab <exit>
}
  8005a1:	83 c4 10             	add    $0x10,%esp
  8005a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8005a7:	5b                   	pop    %ebx
  8005a8:	5e                   	pop    %esi
  8005a9:	5d                   	pop    %ebp
  8005aa:	c3                   	ret    

008005ab <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8005ab:	55                   	push   %ebp
  8005ac:	89 e5                	mov    %esp,%ebp
  8005ae:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8005b1:	e8 da 0f 00 00       	call   801590 <close_all>
	sys_env_destroy(0);
  8005b6:	83 ec 0c             	sub    $0xc,%esp
  8005b9:	6a 00                	push   $0x0
  8005bb:	e8 b3 0a 00 00       	call   801073 <sys_env_destroy>
}
  8005c0:	83 c4 10             	add    $0x10,%esp
  8005c3:	c9                   	leave  
  8005c4:	c3                   	ret    

008005c5 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8005c5:	55                   	push   %ebp
  8005c6:	89 e5                	mov    %esp,%ebp
  8005c8:	56                   	push   %esi
  8005c9:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8005ca:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8005cd:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8005d3:	e8 dc 0a 00 00       	call   8010b4 <sys_getenvid>
  8005d8:	83 ec 0c             	sub    $0xc,%esp
  8005db:	ff 75 0c             	pushl  0xc(%ebp)
  8005de:	ff 75 08             	pushl  0x8(%ebp)
  8005e1:	56                   	push   %esi
  8005e2:	50                   	push   %eax
  8005e3:	68 20 25 80 00       	push   $0x802520
  8005e8:	e8 b0 00 00 00       	call   80069d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8005ed:	83 c4 18             	add    $0x18,%esp
  8005f0:	53                   	push   %ebx
  8005f1:	ff 75 10             	pushl  0x10(%ebp)
  8005f4:	e8 53 00 00 00       	call   80064c <vcprintf>
	cprintf("\n");
  8005f9:	c7 04 24 30 24 80 00 	movl   $0x802430,(%esp)
  800600:	e8 98 00 00 00       	call   80069d <cprintf>
  800605:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800608:	cc                   	int3   
  800609:	eb fd                	jmp    800608 <_panic+0x43>

0080060b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80060b:	55                   	push   %ebp
  80060c:	89 e5                	mov    %esp,%ebp
  80060e:	53                   	push   %ebx
  80060f:	83 ec 04             	sub    $0x4,%esp
  800612:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800615:	8b 13                	mov    (%ebx),%edx
  800617:	8d 42 01             	lea    0x1(%edx),%eax
  80061a:	89 03                	mov    %eax,(%ebx)
  80061c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80061f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800623:	3d ff 00 00 00       	cmp    $0xff,%eax
  800628:	75 1a                	jne    800644 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80062a:	83 ec 08             	sub    $0x8,%esp
  80062d:	68 ff 00 00 00       	push   $0xff
  800632:	8d 43 08             	lea    0x8(%ebx),%eax
  800635:	50                   	push   %eax
  800636:	e8 fb 09 00 00       	call   801036 <sys_cputs>
		b->idx = 0;
  80063b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800641:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800644:	ff 43 04             	incl   0x4(%ebx)
}
  800647:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80064a:	c9                   	leave  
  80064b:	c3                   	ret    

0080064c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80064c:	55                   	push   %ebp
  80064d:	89 e5                	mov    %esp,%ebp
  80064f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800655:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80065c:	00 00 00 
	b.cnt = 0;
  80065f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800666:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800669:	ff 75 0c             	pushl  0xc(%ebp)
  80066c:	ff 75 08             	pushl  0x8(%ebp)
  80066f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800675:	50                   	push   %eax
  800676:	68 0b 06 80 00       	push   $0x80060b
  80067b:	e8 54 01 00 00       	call   8007d4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800680:	83 c4 08             	add    $0x8,%esp
  800683:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800689:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80068f:	50                   	push   %eax
  800690:	e8 a1 09 00 00       	call   801036 <sys_cputs>

	return b.cnt;
}
  800695:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80069b:	c9                   	leave  
  80069c:	c3                   	ret    

0080069d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80069d:	55                   	push   %ebp
  80069e:	89 e5                	mov    %esp,%ebp
  8006a0:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8006a3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8006a6:	50                   	push   %eax
  8006a7:	ff 75 08             	pushl  0x8(%ebp)
  8006aa:	e8 9d ff ff ff       	call   80064c <vcprintf>
	va_end(ap);

	return cnt;
}
  8006af:	c9                   	leave  
  8006b0:	c3                   	ret    

008006b1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8006b1:	55                   	push   %ebp
  8006b2:	89 e5                	mov    %esp,%ebp
  8006b4:	57                   	push   %edi
  8006b5:	56                   	push   %esi
  8006b6:	53                   	push   %ebx
  8006b7:	83 ec 1c             	sub    $0x1c,%esp
  8006ba:	89 c6                	mov    %eax,%esi
  8006bc:	89 d7                	mov    %edx,%edi
  8006be:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006c4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006c7:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8006ca:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8006cd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006d2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8006d5:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8006d8:	39 d3                	cmp    %edx,%ebx
  8006da:	72 11                	jb     8006ed <printnum+0x3c>
  8006dc:	39 45 10             	cmp    %eax,0x10(%ebp)
  8006df:	76 0c                	jbe    8006ed <printnum+0x3c>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8006e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e4:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8006e7:	85 db                	test   %ebx,%ebx
  8006e9:	7f 37                	jg     800722 <printnum+0x71>
  8006eb:	eb 44                	jmp    800731 <printnum+0x80>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8006ed:	83 ec 0c             	sub    $0xc,%esp
  8006f0:	ff 75 18             	pushl  0x18(%ebp)
  8006f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f6:	48                   	dec    %eax
  8006f7:	50                   	push   %eax
  8006f8:	ff 75 10             	pushl  0x10(%ebp)
  8006fb:	83 ec 08             	sub    $0x8,%esp
  8006fe:	ff 75 e4             	pushl  -0x1c(%ebp)
  800701:	ff 75 e0             	pushl  -0x20(%ebp)
  800704:	ff 75 dc             	pushl  -0x24(%ebp)
  800707:	ff 75 d8             	pushl  -0x28(%ebp)
  80070a:	e8 7d 1a 00 00       	call   80218c <__udivdi3>
  80070f:	83 c4 18             	add    $0x18,%esp
  800712:	52                   	push   %edx
  800713:	50                   	push   %eax
  800714:	89 fa                	mov    %edi,%edx
  800716:	89 f0                	mov    %esi,%eax
  800718:	e8 94 ff ff ff       	call   8006b1 <printnum>
  80071d:	83 c4 20             	add    $0x20,%esp
  800720:	eb 0f                	jmp    800731 <printnum+0x80>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800722:	83 ec 08             	sub    $0x8,%esp
  800725:	57                   	push   %edi
  800726:	ff 75 18             	pushl  0x18(%ebp)
  800729:	ff d6                	call   *%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80072b:	83 c4 10             	add    $0x10,%esp
  80072e:	4b                   	dec    %ebx
  80072f:	75 f1                	jne    800722 <printnum+0x71>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800731:	83 ec 08             	sub    $0x8,%esp
  800734:	57                   	push   %edi
  800735:	83 ec 04             	sub    $0x4,%esp
  800738:	ff 75 e4             	pushl  -0x1c(%ebp)
  80073b:	ff 75 e0             	pushl  -0x20(%ebp)
  80073e:	ff 75 dc             	pushl  -0x24(%ebp)
  800741:	ff 75 d8             	pushl  -0x28(%ebp)
  800744:	e8 53 1b 00 00       	call   80229c <__umoddi3>
  800749:	83 c4 14             	add    $0x14,%esp
  80074c:	0f be 80 43 25 80 00 	movsbl 0x802543(%eax),%eax
  800753:	50                   	push   %eax
  800754:	ff d6                	call   *%esi
}
  800756:	83 c4 10             	add    $0x10,%esp
  800759:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80075c:	5b                   	pop    %ebx
  80075d:	5e                   	pop    %esi
  80075e:	5f                   	pop    %edi
  80075f:	5d                   	pop    %ebp
  800760:	c3                   	ret    

00800761 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800761:	55                   	push   %ebp
  800762:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800764:	83 fa 01             	cmp    $0x1,%edx
  800767:	7e 0e                	jle    800777 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800769:	8b 10                	mov    (%eax),%edx
  80076b:	8d 4a 08             	lea    0x8(%edx),%ecx
  80076e:	89 08                	mov    %ecx,(%eax)
  800770:	8b 02                	mov    (%edx),%eax
  800772:	8b 52 04             	mov    0x4(%edx),%edx
  800775:	eb 22                	jmp    800799 <getuint+0x38>
	else if (lflag)
  800777:	85 d2                	test   %edx,%edx
  800779:	74 10                	je     80078b <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80077b:	8b 10                	mov    (%eax),%edx
  80077d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800780:	89 08                	mov    %ecx,(%eax)
  800782:	8b 02                	mov    (%edx),%eax
  800784:	ba 00 00 00 00       	mov    $0x0,%edx
  800789:	eb 0e                	jmp    800799 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80078b:	8b 10                	mov    (%eax),%edx
  80078d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800790:	89 08                	mov    %ecx,(%eax)
  800792:	8b 02                	mov    (%edx),%eax
  800794:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800799:	5d                   	pop    %ebp
  80079a:	c3                   	ret    

0080079b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80079b:	55                   	push   %ebp
  80079c:	89 e5                	mov    %esp,%ebp
  80079e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8007a1:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8007a4:	8b 10                	mov    (%eax),%edx
  8007a6:	3b 50 04             	cmp    0x4(%eax),%edx
  8007a9:	73 0a                	jae    8007b5 <sprintputch+0x1a>
		*b->buf++ = ch;
  8007ab:	8d 4a 01             	lea    0x1(%edx),%ecx
  8007ae:	89 08                	mov    %ecx,(%eax)
  8007b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b3:	88 02                	mov    %al,(%edx)
}
  8007b5:	5d                   	pop    %ebp
  8007b6:	c3                   	ret    

008007b7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007b7:	55                   	push   %ebp
  8007b8:	89 e5                	mov    %esp,%ebp
  8007ba:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8007bd:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8007c0:	50                   	push   %eax
  8007c1:	ff 75 10             	pushl  0x10(%ebp)
  8007c4:	ff 75 0c             	pushl  0xc(%ebp)
  8007c7:	ff 75 08             	pushl  0x8(%ebp)
  8007ca:	e8 05 00 00 00       	call   8007d4 <vprintfmt>
	va_end(ap);
}
  8007cf:	83 c4 10             	add    $0x10,%esp
  8007d2:	c9                   	leave  
  8007d3:	c3                   	ret    

008007d4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8007d4:	55                   	push   %ebp
  8007d5:	89 e5                	mov    %esp,%ebp
  8007d7:	57                   	push   %edi
  8007d8:	56                   	push   %esi
  8007d9:	53                   	push   %ebx
  8007da:	83 ec 2c             	sub    $0x2c,%esp
  8007dd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007e3:	eb 03                	jmp    8007e8 <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007e5:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  8007e8:	8b 45 10             	mov    0x10(%ebp),%eax
  8007eb:	8d 70 01             	lea    0x1(%eax),%esi
  8007ee:	0f b6 00             	movzbl (%eax),%eax
  8007f1:	83 f8 25             	cmp    $0x25,%eax
  8007f4:	74 25                	je     80081b <vprintfmt+0x47>
			if (ch == '\0')									//当然中间如果遇到'\0'，代表这个字符串的访问结束
  8007f6:	85 c0                	test   %eax,%eax
  8007f8:	75 0d                	jne    800807 <vprintfmt+0x33>
  8007fa:	e9 b5 03 00 00       	jmp    800bb4 <vprintfmt+0x3e0>
  8007ff:	85 c0                	test   %eax,%eax
  800801:	0f 84 ad 03 00 00    	je     800bb4 <vprintfmt+0x3e0>
				return;
			putch(ch, putdat);								//调用putch函数，把一个字符ch输出到putdat指针所指向的地址中所存放的值对应的地址处
  800807:	83 ec 08             	sub    $0x8,%esp
  80080a:	53                   	push   %ebx
  80080b:	50                   	push   %eax
  80080c:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  80080e:	46                   	inc    %esi
  80080f:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800813:	83 c4 10             	add    $0x10,%esp
  800816:	83 f8 25             	cmp    $0x25,%eax
  800819:	75 e4                	jne    8007ff <vprintfmt+0x2b>
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  80081b:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  80081f:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800826:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80082d:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800834:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80083b:	eb 07                	jmp    800844 <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80083d:	8b 75 10             	mov    0x10(%ebp),%esi

		// flag to pad on the right
		case '-':											//%后面的'-'代表要进行左对齐输出，右边填空格，如果省略代表右对齐
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
  800840:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800844:	8d 46 01             	lea    0x1(%esi),%eax
  800847:	89 45 10             	mov    %eax,0x10(%ebp)
  80084a:	0f b6 16             	movzbl (%esi),%edx
  80084d:	8a 06                	mov    (%esi),%al
  80084f:	83 e8 23             	sub    $0x23,%eax
  800852:	3c 55                	cmp    $0x55,%al
  800854:	0f 87 03 03 00 00    	ja     800b5d <vprintfmt+0x389>
  80085a:	0f b6 c0             	movzbl %al,%eax
  80085d:	ff 24 85 80 26 80 00 	jmp    *0x802680(,%eax,4)
  800864:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
			goto reswitch;									//处理下一个字符

		// flag to pad with 0's instead of spaces
		case '0':											//0--有0表示进行对齐输出时填0,如省略表示填入空格，并且如果为0，则一定是右对齐
			padc = '0';										//对其方式标志位变为0
  800867:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  80086b:	eb d7                	jmp    800844 <vprintfmt+0x70>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
				precision = precision * 10 + ch - '0';
  80086d:	8d 42 d0             	lea    -0x30(%edx),%eax
  800870:	89 c1                	mov    %eax,%ecx
  800872:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  800875:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800879:	8d 50 d0             	lea    -0x30(%eax),%edx
  80087c:	83 fa 09             	cmp    $0x9,%edx
  80087f:	77 51                	ja     8008d2 <vprintfmt+0xfe>
  800881:	8b 75 10             	mov    0x10(%ebp),%esi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
  800884:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800885:	8d 14 89             	lea    (%ecx,%ecx,4),%edx
  800888:	01 d2                	add    %edx,%edx
  80088a:	8d 4c 10 d0          	lea    -0x30(%eax,%edx,1),%ecx
				ch = *fmt;
  80088e:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800891:	8d 50 d0             	lea    -0x30(%eax),%edx
  800894:	83 fa 09             	cmp    $0x9,%edx
  800897:	76 eb                	jbe    800884 <vprintfmt+0xb0>
  800899:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80089c:	eb 37                	jmp    8008d5 <vprintfmt+0x101>
					break;
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
  80089e:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a1:	8d 50 04             	lea    0x4(%eax),%edx
  8008a4:	89 55 14             	mov    %edx,0x14(%ebp)
  8008a7:	8b 00                	mov    (%eax),%eax
  8008a9:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8008ac:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
			goto process_precision;
  8008af:	eb 24                	jmp    8008d5 <vprintfmt+0x101>
  8008b1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008b5:	79 07                	jns    8008be <vprintfmt+0xea>
  8008b7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8008be:	8b 75 10             	mov    0x10(%ebp),%esi
  8008c1:	eb 81                	jmp    800844 <vprintfmt+0x70>
  8008c3:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  8008c6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8008cd:	e9 72 ff ff ff       	jmp    800844 <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8008d2:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:									//处理输出精度，把width字段赋值为刚刚计算出来的precision值，所以width应该是整数部分的有效数字位数
			if (width < 0)
  8008d5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008d9:	0f 89 65 ff ff ff    	jns    800844 <vprintfmt+0x70>
				width = precision, precision = -1;
  8008df:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8008e2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8008e5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8008ec:	e9 53 ff ff ff       	jmp    800844 <vprintfmt+0x70>
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
  8008f1:	ff 45 d4             	incl   -0x2c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8008f4:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
			goto reswitch;
  8008f7:	e9 48 ff ff ff       	jmp    800844 <vprintfmt+0x70>

		// character
		case 'c':											//如果是'c'代表显示一个字符
			putch(va_arg(ap, int), putdat);					//调用输出一个字符到内存的函数putch
  8008fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ff:	8d 50 04             	lea    0x4(%eax),%edx
  800902:	89 55 14             	mov    %edx,0x14(%ebp)
  800905:	83 ec 08             	sub    $0x8,%esp
  800908:	53                   	push   %ebx
  800909:	ff 30                	pushl  (%eax)
  80090b:	ff d7                	call   *%edi
			break;
  80090d:	83 c4 10             	add    $0x10,%esp
  800910:	e9 d3 fe ff ff       	jmp    8007e8 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800915:	8b 45 14             	mov    0x14(%ebp),%eax
  800918:	8d 50 04             	lea    0x4(%eax),%edx
  80091b:	89 55 14             	mov    %edx,0x14(%ebp)
  80091e:	8b 00                	mov    (%eax),%eax
  800920:	85 c0                	test   %eax,%eax
  800922:	79 02                	jns    800926 <vprintfmt+0x152>
  800924:	f7 d8                	neg    %eax
  800926:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800928:	83 f8 0f             	cmp    $0xf,%eax
  80092b:	7f 0b                	jg     800938 <vprintfmt+0x164>
  80092d:	8b 04 85 e0 27 80 00 	mov    0x8027e0(,%eax,4),%eax
  800934:	85 c0                	test   %eax,%eax
  800936:	75 15                	jne    80094d <vprintfmt+0x179>
				printfmt(putch, putdat, "error %d", err);
  800938:	52                   	push   %edx
  800939:	68 5b 25 80 00       	push   $0x80255b
  80093e:	53                   	push   %ebx
  80093f:	57                   	push   %edi
  800940:	e8 72 fe ff ff       	call   8007b7 <printfmt>
  800945:	83 c4 10             	add    $0x10,%esp
  800948:	e9 9b fe ff ff       	jmp    8007e8 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  80094d:	50                   	push   %eax
  80094e:	68 26 29 80 00       	push   $0x802926
  800953:	53                   	push   %ebx
  800954:	57                   	push   %edi
  800955:	e8 5d fe ff ff       	call   8007b7 <printfmt>
  80095a:	83 c4 10             	add    $0x10,%esp
  80095d:	e9 86 fe ff ff       	jmp    8007e8 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800962:	8b 45 14             	mov    0x14(%ebp),%eax
  800965:	8d 50 04             	lea    0x4(%eax),%edx
  800968:	89 55 14             	mov    %edx,0x14(%ebp)
  80096b:	8b 00                	mov    (%eax),%eax
  80096d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800970:	85 c0                	test   %eax,%eax
  800972:	75 07                	jne    80097b <vprintfmt+0x1a7>
				p = "(null)";
  800974:	c7 45 d4 54 25 80 00 	movl   $0x802554,-0x2c(%ebp)
			if (width > 0 && padc != '-')
  80097b:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80097e:	85 f6                	test   %esi,%esi
  800980:	0f 8e fb 01 00 00    	jle    800b81 <vprintfmt+0x3ad>
  800986:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  80098a:	0f 84 09 02 00 00    	je     800b99 <vprintfmt+0x3c5>
				for (width -= strnlen(p, precision); width > 0; width--)
  800990:	83 ec 08             	sub    $0x8,%esp
  800993:	ff 75 d0             	pushl  -0x30(%ebp)
  800996:	ff 75 d4             	pushl  -0x2c(%ebp)
  800999:	e8 ad 02 00 00       	call   800c4b <strnlen>
  80099e:	89 f1                	mov    %esi,%ecx
  8009a0:	29 c1                	sub    %eax,%ecx
  8009a2:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8009a5:	83 c4 10             	add    $0x10,%esp
  8009a8:	85 c9                	test   %ecx,%ecx
  8009aa:	0f 8e d1 01 00 00    	jle    800b81 <vprintfmt+0x3ad>
					putch(padc, putdat);
  8009b0:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8009b4:	83 ec 08             	sub    $0x8,%esp
  8009b7:	53                   	push   %ebx
  8009b8:	56                   	push   %esi
  8009b9:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009bb:	83 c4 10             	add    $0x10,%esp
  8009be:	ff 4d e4             	decl   -0x1c(%ebp)
  8009c1:	75 f1                	jne    8009b4 <vprintfmt+0x1e0>
  8009c3:	e9 b9 01 00 00       	jmp    800b81 <vprintfmt+0x3ad>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8009c8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8009cc:	74 19                	je     8009e7 <vprintfmt+0x213>
  8009ce:	0f be c0             	movsbl %al,%eax
  8009d1:	83 e8 20             	sub    $0x20,%eax
  8009d4:	83 f8 5e             	cmp    $0x5e,%eax
  8009d7:	76 0e                	jbe    8009e7 <vprintfmt+0x213>
					putch('?', putdat);
  8009d9:	83 ec 08             	sub    $0x8,%esp
  8009dc:	53                   	push   %ebx
  8009dd:	6a 3f                	push   $0x3f
  8009df:	ff 55 08             	call   *0x8(%ebp)
  8009e2:	83 c4 10             	add    $0x10,%esp
  8009e5:	eb 0b                	jmp    8009f2 <vprintfmt+0x21e>
				else
					putch(ch, putdat);
  8009e7:	83 ec 08             	sub    $0x8,%esp
  8009ea:	53                   	push   %ebx
  8009eb:	52                   	push   %edx
  8009ec:	ff 55 08             	call   *0x8(%ebp)
  8009ef:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009f2:	ff 4d e4             	decl   -0x1c(%ebp)
  8009f5:	46                   	inc    %esi
  8009f6:	8a 46 ff             	mov    -0x1(%esi),%al
  8009f9:	0f be d0             	movsbl %al,%edx
  8009fc:	85 d2                	test   %edx,%edx
  8009fe:	75 1c                	jne    800a1c <vprintfmt+0x248>
  800a00:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a03:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a07:	7f 1f                	jg     800a28 <vprintfmt+0x254>
  800a09:	e9 da fd ff ff       	jmp    8007e8 <vprintfmt+0x14>
  800a0e:	89 7d 08             	mov    %edi,0x8(%ebp)
  800a11:	8b 7d d0             	mov    -0x30(%ebp),%edi
  800a14:	eb 06                	jmp    800a1c <vprintfmt+0x248>
  800a16:	89 7d 08             	mov    %edi,0x8(%ebp)
  800a19:	8b 7d d0             	mov    -0x30(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a1c:	85 ff                	test   %edi,%edi
  800a1e:	78 a8                	js     8009c8 <vprintfmt+0x1f4>
  800a20:	4f                   	dec    %edi
  800a21:	79 a5                	jns    8009c8 <vprintfmt+0x1f4>
  800a23:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a26:	eb db                	jmp    800a03 <vprintfmt+0x22f>
  800a28:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a2b:	83 ec 08             	sub    $0x8,%esp
  800a2e:	53                   	push   %ebx
  800a2f:	6a 20                	push   $0x20
  800a31:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a33:	4e                   	dec    %esi
  800a34:	83 c4 10             	add    $0x10,%esp
  800a37:	85 f6                	test   %esi,%esi
  800a39:	7f f0                	jg     800a2b <vprintfmt+0x257>
  800a3b:	e9 a8 fd ff ff       	jmp    8007e8 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a40:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  800a44:	7e 16                	jle    800a5c <vprintfmt+0x288>
		return va_arg(*ap, long long);
  800a46:	8b 45 14             	mov    0x14(%ebp),%eax
  800a49:	8d 50 08             	lea    0x8(%eax),%edx
  800a4c:	89 55 14             	mov    %edx,0x14(%ebp)
  800a4f:	8b 50 04             	mov    0x4(%eax),%edx
  800a52:	8b 00                	mov    (%eax),%eax
  800a54:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800a57:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800a5a:	eb 34                	jmp    800a90 <vprintfmt+0x2bc>
	else if (lflag)
  800a5c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800a60:	74 18                	je     800a7a <vprintfmt+0x2a6>
		return va_arg(*ap, long);
  800a62:	8b 45 14             	mov    0x14(%ebp),%eax
  800a65:	8d 50 04             	lea    0x4(%eax),%edx
  800a68:	89 55 14             	mov    %edx,0x14(%ebp)
  800a6b:	8b 30                	mov    (%eax),%esi
  800a6d:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800a70:	89 f0                	mov    %esi,%eax
  800a72:	c1 f8 1f             	sar    $0x1f,%eax
  800a75:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800a78:	eb 16                	jmp    800a90 <vprintfmt+0x2bc>
	else
		return va_arg(*ap, int);
  800a7a:	8b 45 14             	mov    0x14(%ebp),%eax
  800a7d:	8d 50 04             	lea    0x4(%eax),%edx
  800a80:	89 55 14             	mov    %edx,0x14(%ebp)
  800a83:	8b 30                	mov    (%eax),%esi
  800a85:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800a88:	89 f0                	mov    %esi,%eax
  800a8a:	c1 f8 1f             	sar    $0x1f,%eax
  800a8d:	89 45 dc             	mov    %eax,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800a90:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800a93:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
  800a96:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800a9a:	0f 89 8a 00 00 00    	jns    800b2a <vprintfmt+0x356>
				putch('-', putdat);
  800aa0:	83 ec 08             	sub    $0x8,%esp
  800aa3:	53                   	push   %ebx
  800aa4:	6a 2d                	push   $0x2d
  800aa6:	ff d7                	call   *%edi
				num = -(long long) num;
  800aa8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800aab:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800aae:	f7 d8                	neg    %eax
  800ab0:	83 d2 00             	adc    $0x0,%edx
  800ab3:	f7 da                	neg    %edx
  800ab5:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800ab8:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800abd:	eb 70                	jmp    800b2f <vprintfmt+0x35b>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800abf:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800ac2:	8d 45 14             	lea    0x14(%ebp),%eax
  800ac5:	e8 97 fc ff ff       	call   800761 <getuint>
			base = 10;
  800aca:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800acf:	eb 5e                	jmp    800b2f <vprintfmt+0x35b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  800ad1:	83 ec 08             	sub    $0x8,%esp
  800ad4:	53                   	push   %ebx
  800ad5:	6a 30                	push   $0x30
  800ad7:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  800ad9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800adc:	8d 45 14             	lea    0x14(%ebp),%eax
  800adf:	e8 7d fc ff ff       	call   800761 <getuint>
			base = 8;
			goto number;
  800ae4:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800ae7:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800aec:	eb 41                	jmp    800b2f <vprintfmt+0x35b>
		// pointer
		case 'p':
			putch('0', putdat);
  800aee:	83 ec 08             	sub    $0x8,%esp
  800af1:	53                   	push   %ebx
  800af2:	6a 30                	push   $0x30
  800af4:	ff d7                	call   *%edi
			putch('x', putdat);
  800af6:	83 c4 08             	add    $0x8,%esp
  800af9:	53                   	push   %ebx
  800afa:	6a 78                	push   $0x78
  800afc:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800afe:	8b 45 14             	mov    0x14(%ebp),%eax
  800b01:	8d 50 04             	lea    0x4(%eax),%edx
  800b04:	89 55 14             	mov    %edx,0x14(%ebp)
			goto number;
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800b07:	8b 00                	mov    (%eax),%eax
  800b09:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800b0e:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800b11:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800b16:	eb 17                	jmp    800b2f <vprintfmt+0x35b>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800b18:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800b1b:	8d 45 14             	lea    0x14(%ebp),%eax
  800b1e:	e8 3e fc ff ff       	call   800761 <getuint>
			base = 16;
  800b23:	b9 10 00 00 00       	mov    $0x10,%ecx
  800b28:	eb 05                	jmp    800b2f <vprintfmt+0x35b>
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800b2a:	b9 0a 00 00 00       	mov    $0xa,%ecx
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800b2f:	83 ec 0c             	sub    $0xc,%esp
  800b32:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800b36:	56                   	push   %esi
  800b37:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b3a:	51                   	push   %ecx
  800b3b:	52                   	push   %edx
  800b3c:	50                   	push   %eax
  800b3d:	89 da                	mov    %ebx,%edx
  800b3f:	89 f8                	mov    %edi,%eax
  800b41:	e8 6b fb ff ff       	call   8006b1 <printnum>
			break;
  800b46:	83 c4 20             	add    $0x20,%esp
  800b49:	e9 9a fc ff ff       	jmp    8007e8 <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800b4e:	83 ec 08             	sub    $0x8,%esp
  800b51:	53                   	push   %ebx
  800b52:	52                   	push   %edx
  800b53:	ff d7                	call   *%edi
			break;
  800b55:	83 c4 10             	add    $0x10,%esp
  800b58:	e9 8b fc ff ff       	jmp    8007e8 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800b5d:	83 ec 08             	sub    $0x8,%esp
  800b60:	53                   	push   %ebx
  800b61:	6a 25                	push   $0x25
  800b63:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b65:	83 c4 10             	add    $0x10,%esp
  800b68:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800b6c:	0f 84 73 fc ff ff    	je     8007e5 <vprintfmt+0x11>
  800b72:	4e                   	dec    %esi
  800b73:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800b77:	75 f9                	jne    800b72 <vprintfmt+0x39e>
  800b79:	89 75 10             	mov    %esi,0x10(%ebp)
  800b7c:	e9 67 fc ff ff       	jmp    8007e8 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800b81:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800b84:	8d 70 01             	lea    0x1(%eax),%esi
  800b87:	8a 00                	mov    (%eax),%al
  800b89:	0f be d0             	movsbl %al,%edx
  800b8c:	85 d2                	test   %edx,%edx
  800b8e:	0f 85 7a fe ff ff    	jne    800a0e <vprintfmt+0x23a>
  800b94:	e9 4f fc ff ff       	jmp    8007e8 <vprintfmt+0x14>
  800b99:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800b9c:	8d 70 01             	lea    0x1(%eax),%esi
  800b9f:	8a 00                	mov    (%eax),%al
  800ba1:	0f be d0             	movsbl %al,%edx
  800ba4:	85 d2                	test   %edx,%edx
  800ba6:	0f 85 6a fe ff ff    	jne    800a16 <vprintfmt+0x242>
  800bac:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800baf:	e9 77 fe ff ff       	jmp    800a2b <vprintfmt+0x257>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800bb4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb7:	5b                   	pop    %ebx
  800bb8:	5e                   	pop    %esi
  800bb9:	5f                   	pop    %edi
  800bba:	5d                   	pop    %ebp
  800bbb:	c3                   	ret    

00800bbc <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800bbc:	55                   	push   %ebp
  800bbd:	89 e5                	mov    %esp,%ebp
  800bbf:	83 ec 18             	sub    $0x18,%esp
  800bc2:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800bc8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800bcb:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800bcf:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800bd2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800bd9:	85 c0                	test   %eax,%eax
  800bdb:	74 26                	je     800c03 <vsnprintf+0x47>
  800bdd:	85 d2                	test   %edx,%edx
  800bdf:	7e 29                	jle    800c0a <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800be1:	ff 75 14             	pushl  0x14(%ebp)
  800be4:	ff 75 10             	pushl  0x10(%ebp)
  800be7:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800bea:	50                   	push   %eax
  800beb:	68 9b 07 80 00       	push   $0x80079b
  800bf0:	e8 df fb ff ff       	call   8007d4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800bf5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bf8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800bfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bfe:	83 c4 10             	add    $0x10,%esp
  800c01:	eb 0c                	jmp    800c0f <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800c03:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c08:	eb 05                	jmp    800c0f <vsnprintf+0x53>
  800c0a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800c0f:	c9                   	leave  
  800c10:	c3                   	ret    

00800c11 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c11:	55                   	push   %ebp
  800c12:	89 e5                	mov    %esp,%ebp
  800c14:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c17:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c1a:	50                   	push   %eax
  800c1b:	ff 75 10             	pushl  0x10(%ebp)
  800c1e:	ff 75 0c             	pushl  0xc(%ebp)
  800c21:	ff 75 08             	pushl  0x8(%ebp)
  800c24:	e8 93 ff ff ff       	call   800bbc <vsnprintf>
	va_end(ap);

	return rc;
}
  800c29:	c9                   	leave  
  800c2a:	c3                   	ret    

00800c2b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c2b:	55                   	push   %ebp
  800c2c:	89 e5                	mov    %esp,%ebp
  800c2e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800c31:	80 3a 00             	cmpb   $0x0,(%edx)
  800c34:	74 0e                	je     800c44 <strlen+0x19>
  800c36:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800c3b:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c3c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800c40:	75 f9                	jne    800c3b <strlen+0x10>
  800c42:	eb 05                	jmp    800c49 <strlen+0x1e>
  800c44:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800c49:	5d                   	pop    %ebp
  800c4a:	c3                   	ret    

00800c4b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c4b:	55                   	push   %ebp
  800c4c:	89 e5                	mov    %esp,%ebp
  800c4e:	53                   	push   %ebx
  800c4f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800c52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c55:	85 c9                	test   %ecx,%ecx
  800c57:	74 1a                	je     800c73 <strnlen+0x28>
  800c59:	80 3b 00             	cmpb   $0x0,(%ebx)
  800c5c:	74 1c                	je     800c7a <strnlen+0x2f>
  800c5e:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800c63:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c65:	39 ca                	cmp    %ecx,%edx
  800c67:	74 16                	je     800c7f <strnlen+0x34>
  800c69:	42                   	inc    %edx
  800c6a:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800c6f:	75 f2                	jne    800c63 <strnlen+0x18>
  800c71:	eb 0c                	jmp    800c7f <strnlen+0x34>
  800c73:	b8 00 00 00 00       	mov    $0x0,%eax
  800c78:	eb 05                	jmp    800c7f <strnlen+0x34>
  800c7a:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800c7f:	5b                   	pop    %ebx
  800c80:	5d                   	pop    %ebp
  800c81:	c3                   	ret    

00800c82 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c82:	55                   	push   %ebp
  800c83:	89 e5                	mov    %esp,%ebp
  800c85:	53                   	push   %ebx
  800c86:	8b 45 08             	mov    0x8(%ebp),%eax
  800c89:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800c8c:	89 c2                	mov    %eax,%edx
  800c8e:	42                   	inc    %edx
  800c8f:	41                   	inc    %ecx
  800c90:	8a 59 ff             	mov    -0x1(%ecx),%bl
  800c93:	88 5a ff             	mov    %bl,-0x1(%edx)
  800c96:	84 db                	test   %bl,%bl
  800c98:	75 f4                	jne    800c8e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800c9a:	5b                   	pop    %ebx
  800c9b:	5d                   	pop    %ebp
  800c9c:	c3                   	ret    

00800c9d <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c9d:	55                   	push   %ebp
  800c9e:	89 e5                	mov    %esp,%ebp
  800ca0:	53                   	push   %ebx
  800ca1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800ca4:	53                   	push   %ebx
  800ca5:	e8 81 ff ff ff       	call   800c2b <strlen>
  800caa:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800cad:	ff 75 0c             	pushl  0xc(%ebp)
  800cb0:	01 d8                	add    %ebx,%eax
  800cb2:	50                   	push   %eax
  800cb3:	e8 ca ff ff ff       	call   800c82 <strcpy>
	return dst;
}
  800cb8:	89 d8                	mov    %ebx,%eax
  800cba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800cbd:	c9                   	leave  
  800cbe:	c3                   	ret    

00800cbf <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800cbf:	55                   	push   %ebp
  800cc0:	89 e5                	mov    %esp,%ebp
  800cc2:	56                   	push   %esi
  800cc3:	53                   	push   %ebx
  800cc4:	8b 75 08             	mov    0x8(%ebp),%esi
  800cc7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cca:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ccd:	85 db                	test   %ebx,%ebx
  800ccf:	74 14                	je     800ce5 <strncpy+0x26>
  800cd1:	01 f3                	add    %esi,%ebx
  800cd3:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800cd5:	41                   	inc    %ecx
  800cd6:	8a 02                	mov    (%edx),%al
  800cd8:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800cdb:	80 3a 01             	cmpb   $0x1,(%edx)
  800cde:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ce1:	39 cb                	cmp    %ecx,%ebx
  800ce3:	75 f0                	jne    800cd5 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800ce5:	89 f0                	mov    %esi,%eax
  800ce7:	5b                   	pop    %ebx
  800ce8:	5e                   	pop    %esi
  800ce9:	5d                   	pop    %ebp
  800cea:	c3                   	ret    

00800ceb <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ceb:	55                   	push   %ebp
  800cec:	89 e5                	mov    %esp,%ebp
  800cee:	53                   	push   %ebx
  800cef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800cf2:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800cf5:	85 c0                	test   %eax,%eax
  800cf7:	74 30                	je     800d29 <strlcpy+0x3e>
		while (--size > 0 && *src != '\0')
  800cf9:	48                   	dec    %eax
  800cfa:	74 20                	je     800d1c <strlcpy+0x31>
  800cfc:	8a 0b                	mov    (%ebx),%cl
  800cfe:	84 c9                	test   %cl,%cl
  800d00:	74 1f                	je     800d21 <strlcpy+0x36>
  800d02:	8d 53 01             	lea    0x1(%ebx),%edx
  800d05:	01 c3                	add    %eax,%ebx
  800d07:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
  800d0a:	40                   	inc    %eax
  800d0b:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d0e:	39 da                	cmp    %ebx,%edx
  800d10:	74 12                	je     800d24 <strlcpy+0x39>
  800d12:	42                   	inc    %edx
  800d13:	8a 4a ff             	mov    -0x1(%edx),%cl
  800d16:	84 c9                	test   %cl,%cl
  800d18:	75 f0                	jne    800d0a <strlcpy+0x1f>
  800d1a:	eb 08                	jmp    800d24 <strlcpy+0x39>
  800d1c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d1f:	eb 03                	jmp    800d24 <strlcpy+0x39>
  800d21:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
		*dst = '\0';
  800d24:	c6 00 00             	movb   $0x0,(%eax)
  800d27:	eb 03                	jmp    800d2c <strlcpy+0x41>
  800d29:	8b 45 08             	mov    0x8(%ebp),%eax
	}
	return dst - dst_in;
  800d2c:	2b 45 08             	sub    0x8(%ebp),%eax
}
  800d2f:	5b                   	pop    %ebx
  800d30:	5d                   	pop    %ebp
  800d31:	c3                   	ret    

00800d32 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d32:	55                   	push   %ebp
  800d33:	89 e5                	mov    %esp,%ebp
  800d35:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d38:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800d3b:	8a 01                	mov    (%ecx),%al
  800d3d:	84 c0                	test   %al,%al
  800d3f:	74 10                	je     800d51 <strcmp+0x1f>
  800d41:	3a 02                	cmp    (%edx),%al
  800d43:	75 0c                	jne    800d51 <strcmp+0x1f>
		p++, q++;
  800d45:	41                   	inc    %ecx
  800d46:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d47:	8a 01                	mov    (%ecx),%al
  800d49:	84 c0                	test   %al,%al
  800d4b:	74 04                	je     800d51 <strcmp+0x1f>
  800d4d:	3a 02                	cmp    (%edx),%al
  800d4f:	74 f4                	je     800d45 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d51:	0f b6 c0             	movzbl %al,%eax
  800d54:	0f b6 12             	movzbl (%edx),%edx
  800d57:	29 d0                	sub    %edx,%eax
}
  800d59:	5d                   	pop    %ebp
  800d5a:	c3                   	ret    

00800d5b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d5b:	55                   	push   %ebp
  800d5c:	89 e5                	mov    %esp,%ebp
  800d5e:	56                   	push   %esi
  800d5f:	53                   	push   %ebx
  800d60:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800d63:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d66:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800d69:	85 f6                	test   %esi,%esi
  800d6b:	74 23                	je     800d90 <strncmp+0x35>
  800d6d:	8a 03                	mov    (%ebx),%al
  800d6f:	84 c0                	test   %al,%al
  800d71:	74 2b                	je     800d9e <strncmp+0x43>
  800d73:	3a 02                	cmp    (%edx),%al
  800d75:	75 27                	jne    800d9e <strncmp+0x43>
  800d77:	8d 43 01             	lea    0x1(%ebx),%eax
  800d7a:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800d7c:	89 c3                	mov    %eax,%ebx
  800d7e:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d7f:	39 c6                	cmp    %eax,%esi
  800d81:	74 14                	je     800d97 <strncmp+0x3c>
  800d83:	8a 08                	mov    (%eax),%cl
  800d85:	84 c9                	test   %cl,%cl
  800d87:	74 15                	je     800d9e <strncmp+0x43>
  800d89:	40                   	inc    %eax
  800d8a:	3a 0a                	cmp    (%edx),%cl
  800d8c:	74 ee                	je     800d7c <strncmp+0x21>
  800d8e:	eb 0e                	jmp    800d9e <strncmp+0x43>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800d90:	b8 00 00 00 00       	mov    $0x0,%eax
  800d95:	eb 0f                	jmp    800da6 <strncmp+0x4b>
  800d97:	b8 00 00 00 00       	mov    $0x0,%eax
  800d9c:	eb 08                	jmp    800da6 <strncmp+0x4b>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d9e:	0f b6 03             	movzbl (%ebx),%eax
  800da1:	0f b6 12             	movzbl (%edx),%edx
  800da4:	29 d0                	sub    %edx,%eax
}
  800da6:	5b                   	pop    %ebx
  800da7:	5e                   	pop    %esi
  800da8:	5d                   	pop    %ebp
  800da9:	c3                   	ret    

00800daa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800daa:	55                   	push   %ebp
  800dab:	89 e5                	mov    %esp,%ebp
  800dad:	53                   	push   %ebx
  800dae:	8b 45 08             	mov    0x8(%ebp),%eax
  800db1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800db4:	8a 10                	mov    (%eax),%dl
  800db6:	84 d2                	test   %dl,%dl
  800db8:	74 1a                	je     800dd4 <strchr+0x2a>
  800dba:	88 d9                	mov    %bl,%cl
		if (*s == c)
  800dbc:	38 d3                	cmp    %dl,%bl
  800dbe:	75 06                	jne    800dc6 <strchr+0x1c>
  800dc0:	eb 17                	jmp    800dd9 <strchr+0x2f>
  800dc2:	38 ca                	cmp    %cl,%dl
  800dc4:	74 13                	je     800dd9 <strchr+0x2f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800dc6:	40                   	inc    %eax
  800dc7:	8a 10                	mov    (%eax),%dl
  800dc9:	84 d2                	test   %dl,%dl
  800dcb:	75 f5                	jne    800dc2 <strchr+0x18>
		if (*s == c)
			return (char *) s;
	return 0;
  800dcd:	b8 00 00 00 00       	mov    $0x0,%eax
  800dd2:	eb 05                	jmp    800dd9 <strchr+0x2f>
  800dd4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dd9:	5b                   	pop    %ebx
  800dda:	5d                   	pop    %ebp
  800ddb:	c3                   	ret    

00800ddc <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ddc:	55                   	push   %ebp
  800ddd:	89 e5                	mov    %esp,%ebp
  800ddf:	53                   	push   %ebx
  800de0:	8b 45 08             	mov    0x8(%ebp),%eax
  800de3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800de6:	8a 10                	mov    (%eax),%dl
  800de8:	84 d2                	test   %dl,%dl
  800dea:	74 13                	je     800dff <strfind+0x23>
  800dec:	88 d9                	mov    %bl,%cl
		if (*s == c)
  800dee:	38 d3                	cmp    %dl,%bl
  800df0:	75 06                	jne    800df8 <strfind+0x1c>
  800df2:	eb 0b                	jmp    800dff <strfind+0x23>
  800df4:	38 ca                	cmp    %cl,%dl
  800df6:	74 07                	je     800dff <strfind+0x23>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800df8:	40                   	inc    %eax
  800df9:	8a 10                	mov    (%eax),%dl
  800dfb:	84 d2                	test   %dl,%dl
  800dfd:	75 f5                	jne    800df4 <strfind+0x18>
		if (*s == c)
			break;
	return (char *) s;
}
  800dff:	5b                   	pop    %ebx
  800e00:	5d                   	pop    %ebp
  800e01:	c3                   	ret    

00800e02 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e02:	55                   	push   %ebp
  800e03:	89 e5                	mov    %esp,%ebp
  800e05:	57                   	push   %edi
  800e06:	56                   	push   %esi
  800e07:	53                   	push   %ebx
  800e08:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e0b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800e0e:	85 c9                	test   %ecx,%ecx
  800e10:	74 36                	je     800e48 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800e12:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e18:	75 28                	jne    800e42 <memset+0x40>
  800e1a:	f6 c1 03             	test   $0x3,%cl
  800e1d:	75 23                	jne    800e42 <memset+0x40>
		c &= 0xFF;
  800e1f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e23:	89 d3                	mov    %edx,%ebx
  800e25:	c1 e3 08             	shl    $0x8,%ebx
  800e28:	89 d6                	mov    %edx,%esi
  800e2a:	c1 e6 18             	shl    $0x18,%esi
  800e2d:	89 d0                	mov    %edx,%eax
  800e2f:	c1 e0 10             	shl    $0x10,%eax
  800e32:	09 f0                	or     %esi,%eax
  800e34:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800e36:	89 d8                	mov    %ebx,%eax
  800e38:	09 d0                	or     %edx,%eax
  800e3a:	c1 e9 02             	shr    $0x2,%ecx
  800e3d:	fc                   	cld    
  800e3e:	f3 ab                	rep stos %eax,%es:(%edi)
  800e40:	eb 06                	jmp    800e48 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e42:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e45:	fc                   	cld    
  800e46:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800e48:	89 f8                	mov    %edi,%eax
  800e4a:	5b                   	pop    %ebx
  800e4b:	5e                   	pop    %esi
  800e4c:	5f                   	pop    %edi
  800e4d:	5d                   	pop    %ebp
  800e4e:	c3                   	ret    

00800e4f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e4f:	55                   	push   %ebp
  800e50:	89 e5                	mov    %esp,%ebp
  800e52:	57                   	push   %edi
  800e53:	56                   	push   %esi
  800e54:	8b 45 08             	mov    0x8(%ebp),%eax
  800e57:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e5a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800e5d:	39 c6                	cmp    %eax,%esi
  800e5f:	73 33                	jae    800e94 <memmove+0x45>
  800e61:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800e64:	39 d0                	cmp    %edx,%eax
  800e66:	73 2c                	jae    800e94 <memmove+0x45>
		s += n;
		d += n;
  800e68:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e6b:	89 d6                	mov    %edx,%esi
  800e6d:	09 fe                	or     %edi,%esi
  800e6f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e75:	75 13                	jne    800e8a <memmove+0x3b>
  800e77:	f6 c1 03             	test   $0x3,%cl
  800e7a:	75 0e                	jne    800e8a <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800e7c:	83 ef 04             	sub    $0x4,%edi
  800e7f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800e82:	c1 e9 02             	shr    $0x2,%ecx
  800e85:	fd                   	std    
  800e86:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e88:	eb 07                	jmp    800e91 <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800e8a:	4f                   	dec    %edi
  800e8b:	8d 72 ff             	lea    -0x1(%edx),%esi
  800e8e:	fd                   	std    
  800e8f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800e91:	fc                   	cld    
  800e92:	eb 1d                	jmp    800eb1 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e94:	89 f2                	mov    %esi,%edx
  800e96:	09 c2                	or     %eax,%edx
  800e98:	f6 c2 03             	test   $0x3,%dl
  800e9b:	75 0f                	jne    800eac <memmove+0x5d>
  800e9d:	f6 c1 03             	test   $0x3,%cl
  800ea0:	75 0a                	jne    800eac <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
  800ea2:	c1 e9 02             	shr    $0x2,%ecx
  800ea5:	89 c7                	mov    %eax,%edi
  800ea7:	fc                   	cld    
  800ea8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800eaa:	eb 05                	jmp    800eb1 <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800eac:	89 c7                	mov    %eax,%edi
  800eae:	fc                   	cld    
  800eaf:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800eb1:	5e                   	pop    %esi
  800eb2:	5f                   	pop    %edi
  800eb3:	5d                   	pop    %ebp
  800eb4:	c3                   	ret    

00800eb5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800eb5:	55                   	push   %ebp
  800eb6:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800eb8:	ff 75 10             	pushl  0x10(%ebp)
  800ebb:	ff 75 0c             	pushl  0xc(%ebp)
  800ebe:	ff 75 08             	pushl  0x8(%ebp)
  800ec1:	e8 89 ff ff ff       	call   800e4f <memmove>
}
  800ec6:	c9                   	leave  
  800ec7:	c3                   	ret    

00800ec8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ec8:	55                   	push   %ebp
  800ec9:	89 e5                	mov    %esp,%ebp
  800ecb:	57                   	push   %edi
  800ecc:	56                   	push   %esi
  800ecd:	53                   	push   %ebx
  800ece:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ed1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ed4:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ed7:	85 c0                	test   %eax,%eax
  800ed9:	74 33                	je     800f0e <memcmp+0x46>
  800edb:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800ede:	8a 13                	mov    (%ebx),%dl
  800ee0:	8a 0e                	mov    (%esi),%cl
  800ee2:	38 ca                	cmp    %cl,%dl
  800ee4:	75 13                	jne    800ef9 <memcmp+0x31>
  800ee6:	b8 00 00 00 00       	mov    $0x0,%eax
  800eeb:	eb 16                	jmp    800f03 <memcmp+0x3b>
  800eed:	8a 54 03 01          	mov    0x1(%ebx,%eax,1),%dl
  800ef1:	40                   	inc    %eax
  800ef2:	8a 0c 06             	mov    (%esi,%eax,1),%cl
  800ef5:	38 ca                	cmp    %cl,%dl
  800ef7:	74 0a                	je     800f03 <memcmp+0x3b>
			return (int) *s1 - (int) *s2;
  800ef9:	0f b6 c2             	movzbl %dl,%eax
  800efc:	0f b6 c9             	movzbl %cl,%ecx
  800eff:	29 c8                	sub    %ecx,%eax
  800f01:	eb 10                	jmp    800f13 <memcmp+0x4b>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f03:	39 f8                	cmp    %edi,%eax
  800f05:	75 e6                	jne    800eed <memcmp+0x25>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800f07:	b8 00 00 00 00       	mov    $0x0,%eax
  800f0c:	eb 05                	jmp    800f13 <memcmp+0x4b>
  800f0e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f13:	5b                   	pop    %ebx
  800f14:	5e                   	pop    %esi
  800f15:	5f                   	pop    %edi
  800f16:	5d                   	pop    %ebp
  800f17:	c3                   	ret    

00800f18 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800f18:	55                   	push   %ebp
  800f19:	89 e5                	mov    %esp,%ebp
  800f1b:	53                   	push   %ebx
  800f1c:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800f1f:	89 d0                	mov    %edx,%eax
  800f21:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800f24:	39 c2                	cmp    %eax,%edx
  800f26:	73 1b                	jae    800f43 <memfind+0x2b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800f28:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800f2c:	0f b6 0a             	movzbl (%edx),%ecx
  800f2f:	39 d9                	cmp    %ebx,%ecx
  800f31:	75 09                	jne    800f3c <memfind+0x24>
  800f33:	eb 12                	jmp    800f47 <memfind+0x2f>
  800f35:	0f b6 0a             	movzbl (%edx),%ecx
  800f38:	39 d9                	cmp    %ebx,%ecx
  800f3a:	74 0f                	je     800f4b <memfind+0x33>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800f3c:	42                   	inc    %edx
  800f3d:	39 d0                	cmp    %edx,%eax
  800f3f:	75 f4                	jne    800f35 <memfind+0x1d>
  800f41:	eb 0a                	jmp    800f4d <memfind+0x35>
  800f43:	89 d0                	mov    %edx,%eax
  800f45:	eb 06                	jmp    800f4d <memfind+0x35>
		if (*(const unsigned char *) s == (unsigned char) c)
  800f47:	89 d0                	mov    %edx,%eax
  800f49:	eb 02                	jmp    800f4d <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800f4b:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800f4d:	5b                   	pop    %ebx
  800f4e:	5d                   	pop    %ebp
  800f4f:	c3                   	ret    

00800f50 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800f50:	55                   	push   %ebp
  800f51:	89 e5                	mov    %esp,%ebp
  800f53:	57                   	push   %edi
  800f54:	56                   	push   %esi
  800f55:	53                   	push   %ebx
  800f56:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f59:	eb 01                	jmp    800f5c <strtol+0xc>
		s++;
  800f5b:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f5c:	8a 01                	mov    (%ecx),%al
  800f5e:	3c 20                	cmp    $0x20,%al
  800f60:	74 f9                	je     800f5b <strtol+0xb>
  800f62:	3c 09                	cmp    $0x9,%al
  800f64:	74 f5                	je     800f5b <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  800f66:	3c 2b                	cmp    $0x2b,%al
  800f68:	75 08                	jne    800f72 <strtol+0x22>
		s++;
  800f6a:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800f6b:	bf 00 00 00 00       	mov    $0x0,%edi
  800f70:	eb 11                	jmp    800f83 <strtol+0x33>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800f72:	3c 2d                	cmp    $0x2d,%al
  800f74:	75 08                	jne    800f7e <strtol+0x2e>
		s++, neg = 1;
  800f76:	41                   	inc    %ecx
  800f77:	bf 01 00 00 00       	mov    $0x1,%edi
  800f7c:	eb 05                	jmp    800f83 <strtol+0x33>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800f7e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f83:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f87:	0f 84 87 00 00 00    	je     801014 <strtol+0xc4>
  800f8d:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800f91:	75 27                	jne    800fba <strtol+0x6a>
  800f93:	80 39 30             	cmpb   $0x30,(%ecx)
  800f96:	75 22                	jne    800fba <strtol+0x6a>
  800f98:	e9 88 00 00 00       	jmp    801025 <strtol+0xd5>
		s += 2, base = 16;
  800f9d:	83 c1 02             	add    $0x2,%ecx
  800fa0:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800fa7:	eb 11                	jmp    800fba <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
  800fa9:	41                   	inc    %ecx
  800faa:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800fb1:	eb 07                	jmp    800fba <strtol+0x6a>
	else if (base == 0)
		base = 10;
  800fb3:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  800fba:	b8 00 00 00 00       	mov    $0x0,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800fbf:	8a 11                	mov    (%ecx),%dl
  800fc1:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800fc4:	80 fb 09             	cmp    $0x9,%bl
  800fc7:	77 08                	ja     800fd1 <strtol+0x81>
			dig = *s - '0';
  800fc9:	0f be d2             	movsbl %dl,%edx
  800fcc:	83 ea 30             	sub    $0x30,%edx
  800fcf:	eb 22                	jmp    800ff3 <strtol+0xa3>
		else if (*s >= 'a' && *s <= 'z')
  800fd1:	8d 72 9f             	lea    -0x61(%edx),%esi
  800fd4:	89 f3                	mov    %esi,%ebx
  800fd6:	80 fb 19             	cmp    $0x19,%bl
  800fd9:	77 08                	ja     800fe3 <strtol+0x93>
			dig = *s - 'a' + 10;
  800fdb:	0f be d2             	movsbl %dl,%edx
  800fde:	83 ea 57             	sub    $0x57,%edx
  800fe1:	eb 10                	jmp    800ff3 <strtol+0xa3>
		else if (*s >= 'A' && *s <= 'Z')
  800fe3:	8d 72 bf             	lea    -0x41(%edx),%esi
  800fe6:	89 f3                	mov    %esi,%ebx
  800fe8:	80 fb 19             	cmp    $0x19,%bl
  800feb:	77 14                	ja     801001 <strtol+0xb1>
			dig = *s - 'A' + 10;
  800fed:	0f be d2             	movsbl %dl,%edx
  800ff0:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ff3:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ff6:	7d 09                	jge    801001 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800ff8:	41                   	inc    %ecx
  800ff9:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ffd:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800fff:	eb be                	jmp    800fbf <strtol+0x6f>

	if (endptr)
  801001:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801005:	74 05                	je     80100c <strtol+0xbc>
		*endptr = (char *) s;
  801007:	8b 75 0c             	mov    0xc(%ebp),%esi
  80100a:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  80100c:	85 ff                	test   %edi,%edi
  80100e:	74 21                	je     801031 <strtol+0xe1>
  801010:	f7 d8                	neg    %eax
  801012:	eb 1d                	jmp    801031 <strtol+0xe1>
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801014:	80 39 30             	cmpb   $0x30,(%ecx)
  801017:	75 9a                	jne    800fb3 <strtol+0x63>
  801019:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80101d:	0f 84 7a ff ff ff    	je     800f9d <strtol+0x4d>
  801023:	eb 84                	jmp    800fa9 <strtol+0x59>
  801025:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801029:	0f 84 6e ff ff ff    	je     800f9d <strtol+0x4d>
  80102f:	eb 89                	jmp    800fba <strtol+0x6a>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  801031:	5b                   	pop    %ebx
  801032:	5e                   	pop    %esi
  801033:	5f                   	pop    %edi
  801034:	5d                   	pop    %ebp
  801035:	c3                   	ret    

00801036 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801036:	55                   	push   %ebp
  801037:	89 e5                	mov    %esp,%ebp
  801039:	57                   	push   %edi
  80103a:	56                   	push   %esi
  80103b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80103c:	b8 00 00 00 00       	mov    $0x0,%eax
  801041:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801044:	8b 55 08             	mov    0x8(%ebp),%edx
  801047:	89 c3                	mov    %eax,%ebx
  801049:	89 c7                	mov    %eax,%edi
  80104b:	89 c6                	mov    %eax,%esi
  80104d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80104f:	5b                   	pop    %ebx
  801050:	5e                   	pop    %esi
  801051:	5f                   	pop    %edi
  801052:	5d                   	pop    %ebp
  801053:	c3                   	ret    

00801054 <sys_cgetc>:

int
sys_cgetc(void)
{
  801054:	55                   	push   %ebp
  801055:	89 e5                	mov    %esp,%ebp
  801057:	57                   	push   %edi
  801058:	56                   	push   %esi
  801059:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80105a:	ba 00 00 00 00       	mov    $0x0,%edx
  80105f:	b8 01 00 00 00       	mov    $0x1,%eax
  801064:	89 d1                	mov    %edx,%ecx
  801066:	89 d3                	mov    %edx,%ebx
  801068:	89 d7                	mov    %edx,%edi
  80106a:	89 d6                	mov    %edx,%esi
  80106c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80106e:	5b                   	pop    %ebx
  80106f:	5e                   	pop    %esi
  801070:	5f                   	pop    %edi
  801071:	5d                   	pop    %ebp
  801072:	c3                   	ret    

00801073 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801073:	55                   	push   %ebp
  801074:	89 e5                	mov    %esp,%ebp
  801076:	57                   	push   %edi
  801077:	56                   	push   %esi
  801078:	53                   	push   %ebx
  801079:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80107c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801081:	b8 03 00 00 00       	mov    $0x3,%eax
  801086:	8b 55 08             	mov    0x8(%ebp),%edx
  801089:	89 cb                	mov    %ecx,%ebx
  80108b:	89 cf                	mov    %ecx,%edi
  80108d:	89 ce                	mov    %ecx,%esi
  80108f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801091:	85 c0                	test   %eax,%eax
  801093:	7e 17                	jle    8010ac <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801095:	83 ec 0c             	sub    $0xc,%esp
  801098:	50                   	push   %eax
  801099:	6a 03                	push   $0x3
  80109b:	68 3f 28 80 00       	push   $0x80283f
  8010a0:	6a 23                	push   $0x23
  8010a2:	68 5c 28 80 00       	push   $0x80285c
  8010a7:	e8 19 f5 ff ff       	call   8005c5 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8010ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010af:	5b                   	pop    %ebx
  8010b0:	5e                   	pop    %esi
  8010b1:	5f                   	pop    %edi
  8010b2:	5d                   	pop    %ebp
  8010b3:	c3                   	ret    

008010b4 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8010b4:	55                   	push   %ebp
  8010b5:	89 e5                	mov    %esp,%ebp
  8010b7:	57                   	push   %edi
  8010b8:	56                   	push   %esi
  8010b9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8010bf:	b8 02 00 00 00       	mov    $0x2,%eax
  8010c4:	89 d1                	mov    %edx,%ecx
  8010c6:	89 d3                	mov    %edx,%ebx
  8010c8:	89 d7                	mov    %edx,%edi
  8010ca:	89 d6                	mov    %edx,%esi
  8010cc:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8010ce:	5b                   	pop    %ebx
  8010cf:	5e                   	pop    %esi
  8010d0:	5f                   	pop    %edi
  8010d1:	5d                   	pop    %ebp
  8010d2:	c3                   	ret    

008010d3 <sys_yield>:

void
sys_yield(void)
{
  8010d3:	55                   	push   %ebp
  8010d4:	89 e5                	mov    %esp,%ebp
  8010d6:	57                   	push   %edi
  8010d7:	56                   	push   %esi
  8010d8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8010de:	b8 0b 00 00 00       	mov    $0xb,%eax
  8010e3:	89 d1                	mov    %edx,%ecx
  8010e5:	89 d3                	mov    %edx,%ebx
  8010e7:	89 d7                	mov    %edx,%edi
  8010e9:	89 d6                	mov    %edx,%esi
  8010eb:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8010ed:	5b                   	pop    %ebx
  8010ee:	5e                   	pop    %esi
  8010ef:	5f                   	pop    %edi
  8010f0:	5d                   	pop    %ebp
  8010f1:	c3                   	ret    

008010f2 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8010f2:	55                   	push   %ebp
  8010f3:	89 e5                	mov    %esp,%ebp
  8010f5:	57                   	push   %edi
  8010f6:	56                   	push   %esi
  8010f7:	53                   	push   %ebx
  8010f8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010fb:	be 00 00 00 00       	mov    $0x0,%esi
  801100:	b8 04 00 00 00       	mov    $0x4,%eax
  801105:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801108:	8b 55 08             	mov    0x8(%ebp),%edx
  80110b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80110e:	89 f7                	mov    %esi,%edi
  801110:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801112:	85 c0                	test   %eax,%eax
  801114:	7e 17                	jle    80112d <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801116:	83 ec 0c             	sub    $0xc,%esp
  801119:	50                   	push   %eax
  80111a:	6a 04                	push   $0x4
  80111c:	68 3f 28 80 00       	push   $0x80283f
  801121:	6a 23                	push   $0x23
  801123:	68 5c 28 80 00       	push   $0x80285c
  801128:	e8 98 f4 ff ff       	call   8005c5 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80112d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801130:	5b                   	pop    %ebx
  801131:	5e                   	pop    %esi
  801132:	5f                   	pop    %edi
  801133:	5d                   	pop    %ebp
  801134:	c3                   	ret    

00801135 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801135:	55                   	push   %ebp
  801136:	89 e5                	mov    %esp,%ebp
  801138:	57                   	push   %edi
  801139:	56                   	push   %esi
  80113a:	53                   	push   %ebx
  80113b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80113e:	b8 05 00 00 00       	mov    $0x5,%eax
  801143:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801146:	8b 55 08             	mov    0x8(%ebp),%edx
  801149:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80114c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80114f:	8b 75 18             	mov    0x18(%ebp),%esi
  801152:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801154:	85 c0                	test   %eax,%eax
  801156:	7e 17                	jle    80116f <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801158:	83 ec 0c             	sub    $0xc,%esp
  80115b:	50                   	push   %eax
  80115c:	6a 05                	push   $0x5
  80115e:	68 3f 28 80 00       	push   $0x80283f
  801163:	6a 23                	push   $0x23
  801165:	68 5c 28 80 00       	push   $0x80285c
  80116a:	e8 56 f4 ff ff       	call   8005c5 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80116f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801172:	5b                   	pop    %ebx
  801173:	5e                   	pop    %esi
  801174:	5f                   	pop    %edi
  801175:	5d                   	pop    %ebp
  801176:	c3                   	ret    

00801177 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801177:	55                   	push   %ebp
  801178:	89 e5                	mov    %esp,%ebp
  80117a:	57                   	push   %edi
  80117b:	56                   	push   %esi
  80117c:	53                   	push   %ebx
  80117d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801180:	bb 00 00 00 00       	mov    $0x0,%ebx
  801185:	b8 06 00 00 00       	mov    $0x6,%eax
  80118a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80118d:	8b 55 08             	mov    0x8(%ebp),%edx
  801190:	89 df                	mov    %ebx,%edi
  801192:	89 de                	mov    %ebx,%esi
  801194:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801196:	85 c0                	test   %eax,%eax
  801198:	7e 17                	jle    8011b1 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80119a:	83 ec 0c             	sub    $0xc,%esp
  80119d:	50                   	push   %eax
  80119e:	6a 06                	push   $0x6
  8011a0:	68 3f 28 80 00       	push   $0x80283f
  8011a5:	6a 23                	push   $0x23
  8011a7:	68 5c 28 80 00       	push   $0x80285c
  8011ac:	e8 14 f4 ff ff       	call   8005c5 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8011b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011b4:	5b                   	pop    %ebx
  8011b5:	5e                   	pop    %esi
  8011b6:	5f                   	pop    %edi
  8011b7:	5d                   	pop    %ebp
  8011b8:	c3                   	ret    

008011b9 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8011b9:	55                   	push   %ebp
  8011ba:	89 e5                	mov    %esp,%ebp
  8011bc:	57                   	push   %edi
  8011bd:	56                   	push   %esi
  8011be:	53                   	push   %ebx
  8011bf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011c2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011c7:	b8 08 00 00 00       	mov    $0x8,%eax
  8011cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011cf:	8b 55 08             	mov    0x8(%ebp),%edx
  8011d2:	89 df                	mov    %ebx,%edi
  8011d4:	89 de                	mov    %ebx,%esi
  8011d6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011d8:	85 c0                	test   %eax,%eax
  8011da:	7e 17                	jle    8011f3 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011dc:	83 ec 0c             	sub    $0xc,%esp
  8011df:	50                   	push   %eax
  8011e0:	6a 08                	push   $0x8
  8011e2:	68 3f 28 80 00       	push   $0x80283f
  8011e7:	6a 23                	push   $0x23
  8011e9:	68 5c 28 80 00       	push   $0x80285c
  8011ee:	e8 d2 f3 ff ff       	call   8005c5 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8011f3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011f6:	5b                   	pop    %ebx
  8011f7:	5e                   	pop    %esi
  8011f8:	5f                   	pop    %edi
  8011f9:	5d                   	pop    %ebp
  8011fa:	c3                   	ret    

008011fb <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8011fb:	55                   	push   %ebp
  8011fc:	89 e5                	mov    %esp,%ebp
  8011fe:	57                   	push   %edi
  8011ff:	56                   	push   %esi
  801200:	53                   	push   %ebx
  801201:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801204:	bb 00 00 00 00       	mov    $0x0,%ebx
  801209:	b8 09 00 00 00       	mov    $0x9,%eax
  80120e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801211:	8b 55 08             	mov    0x8(%ebp),%edx
  801214:	89 df                	mov    %ebx,%edi
  801216:	89 de                	mov    %ebx,%esi
  801218:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80121a:	85 c0                	test   %eax,%eax
  80121c:	7e 17                	jle    801235 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80121e:	83 ec 0c             	sub    $0xc,%esp
  801221:	50                   	push   %eax
  801222:	6a 09                	push   $0x9
  801224:	68 3f 28 80 00       	push   $0x80283f
  801229:	6a 23                	push   $0x23
  80122b:	68 5c 28 80 00       	push   $0x80285c
  801230:	e8 90 f3 ff ff       	call   8005c5 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801235:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801238:	5b                   	pop    %ebx
  801239:	5e                   	pop    %esi
  80123a:	5f                   	pop    %edi
  80123b:	5d                   	pop    %ebp
  80123c:	c3                   	ret    

0080123d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80123d:	55                   	push   %ebp
  80123e:	89 e5                	mov    %esp,%ebp
  801240:	57                   	push   %edi
  801241:	56                   	push   %esi
  801242:	53                   	push   %ebx
  801243:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801246:	bb 00 00 00 00       	mov    $0x0,%ebx
  80124b:	b8 0a 00 00 00       	mov    $0xa,%eax
  801250:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801253:	8b 55 08             	mov    0x8(%ebp),%edx
  801256:	89 df                	mov    %ebx,%edi
  801258:	89 de                	mov    %ebx,%esi
  80125a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80125c:	85 c0                	test   %eax,%eax
  80125e:	7e 17                	jle    801277 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801260:	83 ec 0c             	sub    $0xc,%esp
  801263:	50                   	push   %eax
  801264:	6a 0a                	push   $0xa
  801266:	68 3f 28 80 00       	push   $0x80283f
  80126b:	6a 23                	push   $0x23
  80126d:	68 5c 28 80 00       	push   $0x80285c
  801272:	e8 4e f3 ff ff       	call   8005c5 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801277:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80127a:	5b                   	pop    %ebx
  80127b:	5e                   	pop    %esi
  80127c:	5f                   	pop    %edi
  80127d:	5d                   	pop    %ebp
  80127e:	c3                   	ret    

0080127f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80127f:	55                   	push   %ebp
  801280:	89 e5                	mov    %esp,%ebp
  801282:	57                   	push   %edi
  801283:	56                   	push   %esi
  801284:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801285:	be 00 00 00 00       	mov    $0x0,%esi
  80128a:	b8 0c 00 00 00       	mov    $0xc,%eax
  80128f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801292:	8b 55 08             	mov    0x8(%ebp),%edx
  801295:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801298:	8b 7d 14             	mov    0x14(%ebp),%edi
  80129b:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80129d:	5b                   	pop    %ebx
  80129e:	5e                   	pop    %esi
  80129f:	5f                   	pop    %edi
  8012a0:	5d                   	pop    %ebp
  8012a1:	c3                   	ret    

008012a2 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8012a2:	55                   	push   %ebp
  8012a3:	89 e5                	mov    %esp,%ebp
  8012a5:	57                   	push   %edi
  8012a6:	56                   	push   %esi
  8012a7:	53                   	push   %ebx
  8012a8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012ab:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012b0:	b8 0d 00 00 00       	mov    $0xd,%eax
  8012b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8012b8:	89 cb                	mov    %ecx,%ebx
  8012ba:	89 cf                	mov    %ecx,%edi
  8012bc:	89 ce                	mov    %ecx,%esi
  8012be:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8012c0:	85 c0                	test   %eax,%eax
  8012c2:	7e 17                	jle    8012db <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012c4:	83 ec 0c             	sub    $0xc,%esp
  8012c7:	50                   	push   %eax
  8012c8:	6a 0d                	push   $0xd
  8012ca:	68 3f 28 80 00       	push   $0x80283f
  8012cf:	6a 23                	push   $0x23
  8012d1:	68 5c 28 80 00       	push   $0x80285c
  8012d6:	e8 ea f2 ff ff       	call   8005c5 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8012db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012de:	5b                   	pop    %ebx
  8012df:	5e                   	pop    %esi
  8012e0:	5f                   	pop    %edi
  8012e1:	5d                   	pop    %ebp
  8012e2:	c3                   	ret    

008012e3 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8012e3:	55                   	push   %ebp
  8012e4:	89 e5                	mov    %esp,%ebp
  8012e6:	53                   	push   %ebx
  8012e7:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  8012ea:	83 3d b4 40 80 00 00 	cmpl   $0x0,0x8040b4
  8012f1:	75 5b                	jne    80134e <set_pgfault_handler+0x6b>
		// First time through!
		// LAB 4: Your code here.
		void *va = (void *)(UXSTACKTOP - PGSIZE);
		envid_t eid = sys_getenvid();
  8012f3:	e8 bc fd ff ff       	call   8010b4 <sys_getenvid>
  8012f8:	89 c3                	mov    %eax,%ebx
		r = sys_page_alloc(eid,va,PTE_P | PTE_U | PTE_W);
  8012fa:	83 ec 04             	sub    $0x4,%esp
  8012fd:	6a 07                	push   $0x7
  8012ff:	68 00 f0 bf ee       	push   $0xeebff000
  801304:	50                   	push   %eax
  801305:	e8 e8 fd ff ff       	call   8010f2 <sys_page_alloc>
		if(r<0) panic("set_pgfault_handler\n");
  80130a:	83 c4 10             	add    $0x10,%esp
  80130d:	85 c0                	test   %eax,%eax
  80130f:	79 14                	jns    801325 <set_pgfault_handler+0x42>
  801311:	83 ec 04             	sub    $0x4,%esp
  801314:	68 6a 28 80 00       	push   $0x80286a
  801319:	6a 23                	push   $0x23
  80131b:	68 7f 28 80 00       	push   $0x80287f
  801320:	e8 a0 f2 ff ff       	call   8005c5 <_panic>
		r = sys_env_set_pgfault_upcall(eid,_pgfault_upcall);
  801325:	83 ec 08             	sub    $0x8,%esp
  801328:	68 5b 13 80 00       	push   $0x80135b
  80132d:	53                   	push   %ebx
  80132e:	e8 0a ff ff ff       	call   80123d <sys_env_set_pgfault_upcall>
		if(r<0) panic("set_pgfault_handler\n");
  801333:	83 c4 10             	add    $0x10,%esp
  801336:	85 c0                	test   %eax,%eax
  801338:	79 14                	jns    80134e <set_pgfault_handler+0x6b>
  80133a:	83 ec 04             	sub    $0x4,%esp
  80133d:	68 6a 28 80 00       	push   $0x80286a
  801342:	6a 25                	push   $0x25
  801344:	68 7f 28 80 00       	push   $0x80287f
  801349:	e8 77 f2 ff ff       	call   8005c5 <_panic>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80134e:	8b 45 08             	mov    0x8(%ebp),%eax
  801351:	a3 b4 40 80 00       	mov    %eax,0x8040b4
}
  801356:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801359:	c9                   	leave  
  80135a:	c3                   	ret    

0080135b <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80135b:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80135c:	a1 b4 40 80 00       	mov    0x8040b4,%eax
	call *%eax
  801361:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801363:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp,%ebx
  801366:	89 e3                	mov    %esp,%ebx
	movl 40(%esp),%eax 	// esp from utf_fault_va to utf_regs(end)
  801368:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp),%esp 	// 
  80136c:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax
  801370:	50                   	push   %eax
 
 
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx,%esp
  801371:	89 dc                	mov    %ebx,%esp
	subl $4,48(%esp)
  801373:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	popl %eax
  801378:	58                   	pop    %eax
	popl %eax
  801379:	58                   	pop    %eax
	popal
  80137a:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4,%esp
  80137b:	83 c4 04             	add    $0x4,%esp
	popfl
  80137e:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80137f:	5c                   	pop    %esp
 
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801380:	c3                   	ret    

00801381 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801381:	55                   	push   %ebp
  801382:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801384:	8b 45 08             	mov    0x8(%ebp),%eax
  801387:	05 00 00 00 30       	add    $0x30000000,%eax
  80138c:	c1 e8 0c             	shr    $0xc,%eax
}
  80138f:	5d                   	pop    %ebp
  801390:	c3                   	ret    

00801391 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801391:	55                   	push   %ebp
  801392:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801394:	8b 45 08             	mov    0x8(%ebp),%eax
  801397:	05 00 00 00 30       	add    $0x30000000,%eax
  80139c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8013a1:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8013a6:	5d                   	pop    %ebp
  8013a7:	c3                   	ret    

008013a8 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8013a8:	55                   	push   %ebp
  8013a9:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8013ab:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8013b0:	a8 01                	test   $0x1,%al
  8013b2:	74 34                	je     8013e8 <fd_alloc+0x40>
  8013b4:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8013b9:	a8 01                	test   $0x1,%al
  8013bb:	74 32                	je     8013ef <fd_alloc+0x47>
  8013bd:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8013c2:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8013c4:	89 c2                	mov    %eax,%edx
  8013c6:	c1 ea 16             	shr    $0x16,%edx
  8013c9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013d0:	f6 c2 01             	test   $0x1,%dl
  8013d3:	74 1f                	je     8013f4 <fd_alloc+0x4c>
  8013d5:	89 c2                	mov    %eax,%edx
  8013d7:	c1 ea 0c             	shr    $0xc,%edx
  8013da:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013e1:	f6 c2 01             	test   $0x1,%dl
  8013e4:	75 1a                	jne    801400 <fd_alloc+0x58>
  8013e6:	eb 0c                	jmp    8013f4 <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8013e8:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8013ed:	eb 05                	jmp    8013f4 <fd_alloc+0x4c>
  8013ef:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8013f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f7:	89 08                	mov    %ecx,(%eax)
			return 0;
  8013f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8013fe:	eb 1a                	jmp    80141a <fd_alloc+0x72>
  801400:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801405:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80140a:	75 b6                	jne    8013c2 <fd_alloc+0x1a>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80140c:	8b 45 08             	mov    0x8(%ebp),%eax
  80140f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  801415:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80141a:	5d                   	pop    %ebp
  80141b:	c3                   	ret    

0080141c <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80141c:	55                   	push   %ebp
  80141d:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80141f:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  801423:	77 39                	ja     80145e <fd_lookup+0x42>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801425:	8b 45 08             	mov    0x8(%ebp),%eax
  801428:	c1 e0 0c             	shl    $0xc,%eax
  80142b:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801430:	89 c2                	mov    %eax,%edx
  801432:	c1 ea 16             	shr    $0x16,%edx
  801435:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80143c:	f6 c2 01             	test   $0x1,%dl
  80143f:	74 24                	je     801465 <fd_lookup+0x49>
  801441:	89 c2                	mov    %eax,%edx
  801443:	c1 ea 0c             	shr    $0xc,%edx
  801446:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80144d:	f6 c2 01             	test   $0x1,%dl
  801450:	74 1a                	je     80146c <fd_lookup+0x50>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801452:	8b 55 0c             	mov    0xc(%ebp),%edx
  801455:	89 02                	mov    %eax,(%edx)
	return 0;
  801457:	b8 00 00 00 00       	mov    $0x0,%eax
  80145c:	eb 13                	jmp    801471 <fd_lookup+0x55>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80145e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801463:	eb 0c                	jmp    801471 <fd_lookup+0x55>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801465:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80146a:	eb 05                	jmp    801471 <fd_lookup+0x55>
  80146c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801471:	5d                   	pop    %ebp
  801472:	c3                   	ret    

00801473 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801473:	55                   	push   %ebp
  801474:	89 e5                	mov    %esp,%ebp
  801476:	53                   	push   %ebx
  801477:	83 ec 04             	sub    $0x4,%esp
  80147a:	8b 45 08             	mov    0x8(%ebp),%eax
  80147d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801480:	3b 05 04 30 80 00    	cmp    0x803004,%eax
  801486:	75 1e                	jne    8014a6 <dev_lookup+0x33>
  801488:	eb 0e                	jmp    801498 <dev_lookup+0x25>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80148a:	b8 20 30 80 00       	mov    $0x803020,%eax
  80148f:	eb 0c                	jmp    80149d <dev_lookup+0x2a>
  801491:	b8 3c 30 80 00       	mov    $0x80303c,%eax
  801496:	eb 05                	jmp    80149d <dev_lookup+0x2a>
  801498:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  80149d:	89 03                	mov    %eax,(%ebx)
			return 0;
  80149f:	b8 00 00 00 00       	mov    $0x0,%eax
  8014a4:	eb 36                	jmp    8014dc <dev_lookup+0x69>
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8014a6:	3b 05 20 30 80 00    	cmp    0x803020,%eax
  8014ac:	74 dc                	je     80148a <dev_lookup+0x17>
  8014ae:	3b 05 3c 30 80 00    	cmp    0x80303c,%eax
  8014b4:	74 db                	je     801491 <dev_lookup+0x1e>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8014b6:	8b 15 b0 40 80 00    	mov    0x8040b0,%edx
  8014bc:	8b 52 48             	mov    0x48(%edx),%edx
  8014bf:	83 ec 04             	sub    $0x4,%esp
  8014c2:	50                   	push   %eax
  8014c3:	52                   	push   %edx
  8014c4:	68 90 28 80 00       	push   $0x802890
  8014c9:	e8 cf f1 ff ff       	call   80069d <cprintf>
	*dev = 0;
  8014ce:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8014d4:	83 c4 10             	add    $0x10,%esp
  8014d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8014dc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014df:	c9                   	leave  
  8014e0:	c3                   	ret    

008014e1 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8014e1:	55                   	push   %ebp
  8014e2:	89 e5                	mov    %esp,%ebp
  8014e4:	56                   	push   %esi
  8014e5:	53                   	push   %ebx
  8014e6:	83 ec 10             	sub    $0x10,%esp
  8014e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8014ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014f2:	50                   	push   %eax
  8014f3:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8014f9:	c1 e8 0c             	shr    $0xc,%eax
  8014fc:	50                   	push   %eax
  8014fd:	e8 1a ff ff ff       	call   80141c <fd_lookup>
  801502:	83 c4 08             	add    $0x8,%esp
  801505:	85 c0                	test   %eax,%eax
  801507:	78 05                	js     80150e <fd_close+0x2d>
	    || fd != fd2)
  801509:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80150c:	74 06                	je     801514 <fd_close+0x33>
		return (must_exist ? r : 0);
  80150e:	84 db                	test   %bl,%bl
  801510:	74 47                	je     801559 <fd_close+0x78>
  801512:	eb 4a                	jmp    80155e <fd_close+0x7d>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801514:	83 ec 08             	sub    $0x8,%esp
  801517:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80151a:	50                   	push   %eax
  80151b:	ff 36                	pushl  (%esi)
  80151d:	e8 51 ff ff ff       	call   801473 <dev_lookup>
  801522:	89 c3                	mov    %eax,%ebx
  801524:	83 c4 10             	add    $0x10,%esp
  801527:	85 c0                	test   %eax,%eax
  801529:	78 1c                	js     801547 <fd_close+0x66>
		if (dev->dev_close)
  80152b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80152e:	8b 40 10             	mov    0x10(%eax),%eax
  801531:	85 c0                	test   %eax,%eax
  801533:	74 0d                	je     801542 <fd_close+0x61>
			r = (*dev->dev_close)(fd);
  801535:	83 ec 0c             	sub    $0xc,%esp
  801538:	56                   	push   %esi
  801539:	ff d0                	call   *%eax
  80153b:	89 c3                	mov    %eax,%ebx
  80153d:	83 c4 10             	add    $0x10,%esp
  801540:	eb 05                	jmp    801547 <fd_close+0x66>
		else
			r = 0;
  801542:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801547:	83 ec 08             	sub    $0x8,%esp
  80154a:	56                   	push   %esi
  80154b:	6a 00                	push   $0x0
  80154d:	e8 25 fc ff ff       	call   801177 <sys_page_unmap>
	return r;
  801552:	83 c4 10             	add    $0x10,%esp
  801555:	89 d8                	mov    %ebx,%eax
  801557:	eb 05                	jmp    80155e <fd_close+0x7d>
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
  801559:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
	return r;
}
  80155e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801561:	5b                   	pop    %ebx
  801562:	5e                   	pop    %esi
  801563:	5d                   	pop    %ebp
  801564:	c3                   	ret    

00801565 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801565:	55                   	push   %ebp
  801566:	89 e5                	mov    %esp,%ebp
  801568:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80156b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80156e:	50                   	push   %eax
  80156f:	ff 75 08             	pushl  0x8(%ebp)
  801572:	e8 a5 fe ff ff       	call   80141c <fd_lookup>
  801577:	83 c4 08             	add    $0x8,%esp
  80157a:	85 c0                	test   %eax,%eax
  80157c:	78 10                	js     80158e <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80157e:	83 ec 08             	sub    $0x8,%esp
  801581:	6a 01                	push   $0x1
  801583:	ff 75 f4             	pushl  -0xc(%ebp)
  801586:	e8 56 ff ff ff       	call   8014e1 <fd_close>
  80158b:	83 c4 10             	add    $0x10,%esp
}
  80158e:	c9                   	leave  
  80158f:	c3                   	ret    

00801590 <close_all>:

void
close_all(void)
{
  801590:	55                   	push   %ebp
  801591:	89 e5                	mov    %esp,%ebp
  801593:	53                   	push   %ebx
  801594:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801597:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80159c:	83 ec 0c             	sub    $0xc,%esp
  80159f:	53                   	push   %ebx
  8015a0:	e8 c0 ff ff ff       	call   801565 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8015a5:	43                   	inc    %ebx
  8015a6:	83 c4 10             	add    $0x10,%esp
  8015a9:	83 fb 20             	cmp    $0x20,%ebx
  8015ac:	75 ee                	jne    80159c <close_all+0xc>
		close(i);
}
  8015ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015b1:	c9                   	leave  
  8015b2:	c3                   	ret    

008015b3 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8015b3:	55                   	push   %ebp
  8015b4:	89 e5                	mov    %esp,%ebp
  8015b6:	57                   	push   %edi
  8015b7:	56                   	push   %esi
  8015b8:	53                   	push   %ebx
  8015b9:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8015bc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015bf:	50                   	push   %eax
  8015c0:	ff 75 08             	pushl  0x8(%ebp)
  8015c3:	e8 54 fe ff ff       	call   80141c <fd_lookup>
  8015c8:	83 c4 08             	add    $0x8,%esp
  8015cb:	85 c0                	test   %eax,%eax
  8015cd:	0f 88 c2 00 00 00    	js     801695 <dup+0xe2>
		return r;
	close(newfdnum);
  8015d3:	83 ec 0c             	sub    $0xc,%esp
  8015d6:	ff 75 0c             	pushl  0xc(%ebp)
  8015d9:	e8 87 ff ff ff       	call   801565 <close>

	newfd = INDEX2FD(newfdnum);
  8015de:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8015e1:	c1 e3 0c             	shl    $0xc,%ebx
  8015e4:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8015ea:	83 c4 04             	add    $0x4,%esp
  8015ed:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015f0:	e8 9c fd ff ff       	call   801391 <fd2data>
  8015f5:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  8015f7:	89 1c 24             	mov    %ebx,(%esp)
  8015fa:	e8 92 fd ff ff       	call   801391 <fd2data>
  8015ff:	83 c4 10             	add    $0x10,%esp
  801602:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801604:	89 f0                	mov    %esi,%eax
  801606:	c1 e8 16             	shr    $0x16,%eax
  801609:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801610:	a8 01                	test   $0x1,%al
  801612:	74 35                	je     801649 <dup+0x96>
  801614:	89 f0                	mov    %esi,%eax
  801616:	c1 e8 0c             	shr    $0xc,%eax
  801619:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801620:	f6 c2 01             	test   $0x1,%dl
  801623:	74 24                	je     801649 <dup+0x96>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801625:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80162c:	83 ec 0c             	sub    $0xc,%esp
  80162f:	25 07 0e 00 00       	and    $0xe07,%eax
  801634:	50                   	push   %eax
  801635:	57                   	push   %edi
  801636:	6a 00                	push   $0x0
  801638:	56                   	push   %esi
  801639:	6a 00                	push   $0x0
  80163b:	e8 f5 fa ff ff       	call   801135 <sys_page_map>
  801640:	89 c6                	mov    %eax,%esi
  801642:	83 c4 20             	add    $0x20,%esp
  801645:	85 c0                	test   %eax,%eax
  801647:	78 2c                	js     801675 <dup+0xc2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801649:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80164c:	89 d0                	mov    %edx,%eax
  80164e:	c1 e8 0c             	shr    $0xc,%eax
  801651:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801658:	83 ec 0c             	sub    $0xc,%esp
  80165b:	25 07 0e 00 00       	and    $0xe07,%eax
  801660:	50                   	push   %eax
  801661:	53                   	push   %ebx
  801662:	6a 00                	push   $0x0
  801664:	52                   	push   %edx
  801665:	6a 00                	push   $0x0
  801667:	e8 c9 fa ff ff       	call   801135 <sys_page_map>
  80166c:	89 c6                	mov    %eax,%esi
  80166e:	83 c4 20             	add    $0x20,%esp
  801671:	85 c0                	test   %eax,%eax
  801673:	79 1d                	jns    801692 <dup+0xdf>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801675:	83 ec 08             	sub    $0x8,%esp
  801678:	53                   	push   %ebx
  801679:	6a 00                	push   $0x0
  80167b:	e8 f7 fa ff ff       	call   801177 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801680:	83 c4 08             	add    $0x8,%esp
  801683:	57                   	push   %edi
  801684:	6a 00                	push   $0x0
  801686:	e8 ec fa ff ff       	call   801177 <sys_page_unmap>
	return r;
  80168b:	83 c4 10             	add    $0x10,%esp
  80168e:	89 f0                	mov    %esi,%eax
  801690:	eb 03                	jmp    801695 <dup+0xe2>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801692:	8b 45 0c             	mov    0xc(%ebp),%eax

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801695:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801698:	5b                   	pop    %ebx
  801699:	5e                   	pop    %esi
  80169a:	5f                   	pop    %edi
  80169b:	5d                   	pop    %ebp
  80169c:	c3                   	ret    

0080169d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80169d:	55                   	push   %ebp
  80169e:	89 e5                	mov    %esp,%ebp
  8016a0:	53                   	push   %ebx
  8016a1:	83 ec 14             	sub    $0x14,%esp
  8016a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016a7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016aa:	50                   	push   %eax
  8016ab:	53                   	push   %ebx
  8016ac:	e8 6b fd ff ff       	call   80141c <fd_lookup>
  8016b1:	83 c4 08             	add    $0x8,%esp
  8016b4:	85 c0                	test   %eax,%eax
  8016b6:	78 67                	js     80171f <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016b8:	83 ec 08             	sub    $0x8,%esp
  8016bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016be:	50                   	push   %eax
  8016bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016c2:	ff 30                	pushl  (%eax)
  8016c4:	e8 aa fd ff ff       	call   801473 <dev_lookup>
  8016c9:	83 c4 10             	add    $0x10,%esp
  8016cc:	85 c0                	test   %eax,%eax
  8016ce:	78 4f                	js     80171f <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8016d0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016d3:	8b 42 08             	mov    0x8(%edx),%eax
  8016d6:	83 e0 03             	and    $0x3,%eax
  8016d9:	83 f8 01             	cmp    $0x1,%eax
  8016dc:	75 21                	jne    8016ff <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8016de:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  8016e3:	8b 40 48             	mov    0x48(%eax),%eax
  8016e6:	83 ec 04             	sub    $0x4,%esp
  8016e9:	53                   	push   %ebx
  8016ea:	50                   	push   %eax
  8016eb:	68 d4 28 80 00       	push   $0x8028d4
  8016f0:	e8 a8 ef ff ff       	call   80069d <cprintf>
		return -E_INVAL;
  8016f5:	83 c4 10             	add    $0x10,%esp
  8016f8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016fd:	eb 20                	jmp    80171f <read+0x82>
	}
	if (!dev->dev_read)
  8016ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801702:	8b 40 08             	mov    0x8(%eax),%eax
  801705:	85 c0                	test   %eax,%eax
  801707:	74 11                	je     80171a <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801709:	83 ec 04             	sub    $0x4,%esp
  80170c:	ff 75 10             	pushl  0x10(%ebp)
  80170f:	ff 75 0c             	pushl  0xc(%ebp)
  801712:	52                   	push   %edx
  801713:	ff d0                	call   *%eax
  801715:	83 c4 10             	add    $0x10,%esp
  801718:	eb 05                	jmp    80171f <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80171a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80171f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801722:	c9                   	leave  
  801723:	c3                   	ret    

00801724 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801724:	55                   	push   %ebp
  801725:	89 e5                	mov    %esp,%ebp
  801727:	57                   	push   %edi
  801728:	56                   	push   %esi
  801729:	53                   	push   %ebx
  80172a:	83 ec 0c             	sub    $0xc,%esp
  80172d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801730:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801733:	85 f6                	test   %esi,%esi
  801735:	74 31                	je     801768 <readn+0x44>
  801737:	b8 00 00 00 00       	mov    $0x0,%eax
  80173c:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801741:	83 ec 04             	sub    $0x4,%esp
  801744:	89 f2                	mov    %esi,%edx
  801746:	29 c2                	sub    %eax,%edx
  801748:	52                   	push   %edx
  801749:	03 45 0c             	add    0xc(%ebp),%eax
  80174c:	50                   	push   %eax
  80174d:	57                   	push   %edi
  80174e:	e8 4a ff ff ff       	call   80169d <read>
		if (m < 0)
  801753:	83 c4 10             	add    $0x10,%esp
  801756:	85 c0                	test   %eax,%eax
  801758:	78 17                	js     801771 <readn+0x4d>
			return m;
		if (m == 0)
  80175a:	85 c0                	test   %eax,%eax
  80175c:	74 11                	je     80176f <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80175e:	01 c3                	add    %eax,%ebx
  801760:	89 d8                	mov    %ebx,%eax
  801762:	39 f3                	cmp    %esi,%ebx
  801764:	72 db                	jb     801741 <readn+0x1d>
  801766:	eb 09                	jmp    801771 <readn+0x4d>
  801768:	b8 00 00 00 00       	mov    $0x0,%eax
  80176d:	eb 02                	jmp    801771 <readn+0x4d>
  80176f:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801771:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801774:	5b                   	pop    %ebx
  801775:	5e                   	pop    %esi
  801776:	5f                   	pop    %edi
  801777:	5d                   	pop    %ebp
  801778:	c3                   	ret    

00801779 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801779:	55                   	push   %ebp
  80177a:	89 e5                	mov    %esp,%ebp
  80177c:	53                   	push   %ebx
  80177d:	83 ec 14             	sub    $0x14,%esp
  801780:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801783:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801786:	50                   	push   %eax
  801787:	53                   	push   %ebx
  801788:	e8 8f fc ff ff       	call   80141c <fd_lookup>
  80178d:	83 c4 08             	add    $0x8,%esp
  801790:	85 c0                	test   %eax,%eax
  801792:	78 62                	js     8017f6 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801794:	83 ec 08             	sub    $0x8,%esp
  801797:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80179a:	50                   	push   %eax
  80179b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80179e:	ff 30                	pushl  (%eax)
  8017a0:	e8 ce fc ff ff       	call   801473 <dev_lookup>
  8017a5:	83 c4 10             	add    $0x10,%esp
  8017a8:	85 c0                	test   %eax,%eax
  8017aa:	78 4a                	js     8017f6 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017af:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017b3:	75 21                	jne    8017d6 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8017b5:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  8017ba:	8b 40 48             	mov    0x48(%eax),%eax
  8017bd:	83 ec 04             	sub    $0x4,%esp
  8017c0:	53                   	push   %ebx
  8017c1:	50                   	push   %eax
  8017c2:	68 f0 28 80 00       	push   $0x8028f0
  8017c7:	e8 d1 ee ff ff       	call   80069d <cprintf>
		return -E_INVAL;
  8017cc:	83 c4 10             	add    $0x10,%esp
  8017cf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017d4:	eb 20                	jmp    8017f6 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8017d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017d9:	8b 52 0c             	mov    0xc(%edx),%edx
  8017dc:	85 d2                	test   %edx,%edx
  8017de:	74 11                	je     8017f1 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8017e0:	83 ec 04             	sub    $0x4,%esp
  8017e3:	ff 75 10             	pushl  0x10(%ebp)
  8017e6:	ff 75 0c             	pushl  0xc(%ebp)
  8017e9:	50                   	push   %eax
  8017ea:	ff d2                	call   *%edx
  8017ec:	83 c4 10             	add    $0x10,%esp
  8017ef:	eb 05                	jmp    8017f6 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8017f1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8017f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017f9:	c9                   	leave  
  8017fa:	c3                   	ret    

008017fb <seek>:

int
seek(int fdnum, off_t offset)
{
  8017fb:	55                   	push   %ebp
  8017fc:	89 e5                	mov    %esp,%ebp
  8017fe:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801801:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801804:	50                   	push   %eax
  801805:	ff 75 08             	pushl  0x8(%ebp)
  801808:	e8 0f fc ff ff       	call   80141c <fd_lookup>
  80180d:	83 c4 08             	add    $0x8,%esp
  801810:	85 c0                	test   %eax,%eax
  801812:	78 0e                	js     801822 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801814:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801817:	8b 55 0c             	mov    0xc(%ebp),%edx
  80181a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80181d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801822:	c9                   	leave  
  801823:	c3                   	ret    

00801824 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801824:	55                   	push   %ebp
  801825:	89 e5                	mov    %esp,%ebp
  801827:	53                   	push   %ebx
  801828:	83 ec 14             	sub    $0x14,%esp
  80182b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80182e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801831:	50                   	push   %eax
  801832:	53                   	push   %ebx
  801833:	e8 e4 fb ff ff       	call   80141c <fd_lookup>
  801838:	83 c4 08             	add    $0x8,%esp
  80183b:	85 c0                	test   %eax,%eax
  80183d:	78 5f                	js     80189e <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80183f:	83 ec 08             	sub    $0x8,%esp
  801842:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801845:	50                   	push   %eax
  801846:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801849:	ff 30                	pushl  (%eax)
  80184b:	e8 23 fc ff ff       	call   801473 <dev_lookup>
  801850:	83 c4 10             	add    $0x10,%esp
  801853:	85 c0                	test   %eax,%eax
  801855:	78 47                	js     80189e <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801857:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80185a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80185e:	75 21                	jne    801881 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801860:	a1 b0 40 80 00       	mov    0x8040b0,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801865:	8b 40 48             	mov    0x48(%eax),%eax
  801868:	83 ec 04             	sub    $0x4,%esp
  80186b:	53                   	push   %ebx
  80186c:	50                   	push   %eax
  80186d:	68 b0 28 80 00       	push   $0x8028b0
  801872:	e8 26 ee ff ff       	call   80069d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801877:	83 c4 10             	add    $0x10,%esp
  80187a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80187f:	eb 1d                	jmp    80189e <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  801881:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801884:	8b 52 18             	mov    0x18(%edx),%edx
  801887:	85 d2                	test   %edx,%edx
  801889:	74 0e                	je     801899 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80188b:	83 ec 08             	sub    $0x8,%esp
  80188e:	ff 75 0c             	pushl  0xc(%ebp)
  801891:	50                   	push   %eax
  801892:	ff d2                	call   *%edx
  801894:	83 c4 10             	add    $0x10,%esp
  801897:	eb 05                	jmp    80189e <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801899:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80189e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018a1:	c9                   	leave  
  8018a2:	c3                   	ret    

008018a3 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8018a3:	55                   	push   %ebp
  8018a4:	89 e5                	mov    %esp,%ebp
  8018a6:	53                   	push   %ebx
  8018a7:	83 ec 14             	sub    $0x14,%esp
  8018aa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018ad:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018b0:	50                   	push   %eax
  8018b1:	ff 75 08             	pushl  0x8(%ebp)
  8018b4:	e8 63 fb ff ff       	call   80141c <fd_lookup>
  8018b9:	83 c4 08             	add    $0x8,%esp
  8018bc:	85 c0                	test   %eax,%eax
  8018be:	78 52                	js     801912 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018c0:	83 ec 08             	sub    $0x8,%esp
  8018c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018c6:	50                   	push   %eax
  8018c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018ca:	ff 30                	pushl  (%eax)
  8018cc:	e8 a2 fb ff ff       	call   801473 <dev_lookup>
  8018d1:	83 c4 10             	add    $0x10,%esp
  8018d4:	85 c0                	test   %eax,%eax
  8018d6:	78 3a                	js     801912 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  8018d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018db:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8018df:	74 2c                	je     80190d <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8018e1:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8018e4:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8018eb:	00 00 00 
	stat->st_isdir = 0;
  8018ee:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018f5:	00 00 00 
	stat->st_dev = dev;
  8018f8:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8018fe:	83 ec 08             	sub    $0x8,%esp
  801901:	53                   	push   %ebx
  801902:	ff 75 f0             	pushl  -0x10(%ebp)
  801905:	ff 50 14             	call   *0x14(%eax)
  801908:	83 c4 10             	add    $0x10,%esp
  80190b:	eb 05                	jmp    801912 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80190d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801912:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801915:	c9                   	leave  
  801916:	c3                   	ret    

00801917 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801917:	55                   	push   %ebp
  801918:	89 e5                	mov    %esp,%ebp
  80191a:	56                   	push   %esi
  80191b:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80191c:	83 ec 08             	sub    $0x8,%esp
  80191f:	6a 00                	push   $0x0
  801921:	ff 75 08             	pushl  0x8(%ebp)
  801924:	e8 75 01 00 00       	call   801a9e <open>
  801929:	89 c3                	mov    %eax,%ebx
  80192b:	83 c4 10             	add    $0x10,%esp
  80192e:	85 c0                	test   %eax,%eax
  801930:	78 1d                	js     80194f <stat+0x38>
		return fd;
	r = fstat(fd, stat);
  801932:	83 ec 08             	sub    $0x8,%esp
  801935:	ff 75 0c             	pushl  0xc(%ebp)
  801938:	50                   	push   %eax
  801939:	e8 65 ff ff ff       	call   8018a3 <fstat>
  80193e:	89 c6                	mov    %eax,%esi
	close(fd);
  801940:	89 1c 24             	mov    %ebx,(%esp)
  801943:	e8 1d fc ff ff       	call   801565 <close>
	return r;
  801948:	83 c4 10             	add    $0x10,%esp
  80194b:	89 f0                	mov    %esi,%eax
  80194d:	eb 00                	jmp    80194f <stat+0x38>
}
  80194f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801952:	5b                   	pop    %ebx
  801953:	5e                   	pop    %esi
  801954:	5d                   	pop    %ebp
  801955:	c3                   	ret    

00801956 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801956:	55                   	push   %ebp
  801957:	89 e5                	mov    %esp,%ebp
  801959:	56                   	push   %esi
  80195a:	53                   	push   %ebx
  80195b:	89 c6                	mov    %eax,%esi
  80195d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80195f:	83 3d ac 40 80 00 00 	cmpl   $0x0,0x8040ac
  801966:	75 12                	jne    80197a <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801968:	83 ec 0c             	sub    $0xc,%esp
  80196b:	6a 01                	push   $0x1
  80196d:	e8 7b 07 00 00       	call   8020ed <ipc_find_env>
  801972:	a3 ac 40 80 00       	mov    %eax,0x8040ac
  801977:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80197a:	6a 07                	push   $0x7
  80197c:	68 00 50 80 00       	push   $0x805000
  801981:	56                   	push   %esi
  801982:	ff 35 ac 40 80 00    	pushl  0x8040ac
  801988:	e8 01 07 00 00       	call   80208e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80198d:	83 c4 0c             	add    $0xc,%esp
  801990:	6a 00                	push   $0x0
  801992:	53                   	push   %ebx
  801993:	6a 00                	push   $0x0
  801995:	e8 7f 06 00 00       	call   802019 <ipc_recv>
}
  80199a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80199d:	5b                   	pop    %ebx
  80199e:	5e                   	pop    %esi
  80199f:	5d                   	pop    %ebp
  8019a0:	c3                   	ret    

008019a1 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8019a1:	55                   	push   %ebp
  8019a2:	89 e5                	mov    %esp,%ebp
  8019a4:	53                   	push   %ebx
  8019a5:	83 ec 04             	sub    $0x4,%esp
  8019a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8019ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ae:	8b 40 0c             	mov    0xc(%eax),%eax
  8019b1:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8019b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8019bb:	b8 05 00 00 00       	mov    $0x5,%eax
  8019c0:	e8 91 ff ff ff       	call   801956 <fsipc>
  8019c5:	85 c0                	test   %eax,%eax
  8019c7:	78 2c                	js     8019f5 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8019c9:	83 ec 08             	sub    $0x8,%esp
  8019cc:	68 00 50 80 00       	push   $0x805000
  8019d1:	53                   	push   %ebx
  8019d2:	e8 ab f2 ff ff       	call   800c82 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8019d7:	a1 80 50 80 00       	mov    0x805080,%eax
  8019dc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8019e2:	a1 84 50 80 00       	mov    0x805084,%eax
  8019e7:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8019ed:	83 c4 10             	add    $0x10,%esp
  8019f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019f8:	c9                   	leave  
  8019f9:	c3                   	ret    

008019fa <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8019fa:	55                   	push   %ebp
  8019fb:	89 e5                	mov    %esp,%ebp
  8019fd:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a00:	8b 45 08             	mov    0x8(%ebp),%eax
  801a03:	8b 40 0c             	mov    0xc(%eax),%eax
  801a06:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801a0b:	ba 00 00 00 00       	mov    $0x0,%edx
  801a10:	b8 06 00 00 00       	mov    $0x6,%eax
  801a15:	e8 3c ff ff ff       	call   801956 <fsipc>
}
  801a1a:	c9                   	leave  
  801a1b:	c3                   	ret    

00801a1c <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801a1c:	55                   	push   %ebp
  801a1d:	89 e5                	mov    %esp,%ebp
  801a1f:	56                   	push   %esi
  801a20:	53                   	push   %ebx
  801a21:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a24:	8b 45 08             	mov    0x8(%ebp),%eax
  801a27:	8b 40 0c             	mov    0xc(%eax),%eax
  801a2a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a2f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a35:	ba 00 00 00 00       	mov    $0x0,%edx
  801a3a:	b8 03 00 00 00       	mov    $0x3,%eax
  801a3f:	e8 12 ff ff ff       	call   801956 <fsipc>
  801a44:	89 c3                	mov    %eax,%ebx
  801a46:	85 c0                	test   %eax,%eax
  801a48:	78 4b                	js     801a95 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801a4a:	39 c6                	cmp    %eax,%esi
  801a4c:	73 16                	jae    801a64 <devfile_read+0x48>
  801a4e:	68 0d 29 80 00       	push   $0x80290d
  801a53:	68 14 29 80 00       	push   $0x802914
  801a58:	6a 7a                	push   $0x7a
  801a5a:	68 29 29 80 00       	push   $0x802929
  801a5f:	e8 61 eb ff ff       	call   8005c5 <_panic>
	assert(r <= PGSIZE);
  801a64:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a69:	7e 16                	jle    801a81 <devfile_read+0x65>
  801a6b:	68 34 29 80 00       	push   $0x802934
  801a70:	68 14 29 80 00       	push   $0x802914
  801a75:	6a 7b                	push   $0x7b
  801a77:	68 29 29 80 00       	push   $0x802929
  801a7c:	e8 44 eb ff ff       	call   8005c5 <_panic>
	memmove(buf, &fsipcbuf, r);
  801a81:	83 ec 04             	sub    $0x4,%esp
  801a84:	50                   	push   %eax
  801a85:	68 00 50 80 00       	push   $0x805000
  801a8a:	ff 75 0c             	pushl  0xc(%ebp)
  801a8d:	e8 bd f3 ff ff       	call   800e4f <memmove>
	return r;
  801a92:	83 c4 10             	add    $0x10,%esp
}
  801a95:	89 d8                	mov    %ebx,%eax
  801a97:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a9a:	5b                   	pop    %ebx
  801a9b:	5e                   	pop    %esi
  801a9c:	5d                   	pop    %ebp
  801a9d:	c3                   	ret    

00801a9e <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a9e:	55                   	push   %ebp
  801a9f:	89 e5                	mov    %esp,%ebp
  801aa1:	53                   	push   %ebx
  801aa2:	83 ec 20             	sub    $0x20,%esp
  801aa5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801aa8:	53                   	push   %ebx
  801aa9:	e8 7d f1 ff ff       	call   800c2b <strlen>
  801aae:	83 c4 10             	add    $0x10,%esp
  801ab1:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801ab6:	7f 63                	jg     801b1b <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801ab8:	83 ec 0c             	sub    $0xc,%esp
  801abb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801abe:	50                   	push   %eax
  801abf:	e8 e4 f8 ff ff       	call   8013a8 <fd_alloc>
  801ac4:	83 c4 10             	add    $0x10,%esp
  801ac7:	85 c0                	test   %eax,%eax
  801ac9:	78 55                	js     801b20 <open+0x82>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801acb:	83 ec 08             	sub    $0x8,%esp
  801ace:	53                   	push   %ebx
  801acf:	68 00 50 80 00       	push   $0x805000
  801ad4:	e8 a9 f1 ff ff       	call   800c82 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801ad9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801adc:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801ae1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ae4:	b8 01 00 00 00       	mov    $0x1,%eax
  801ae9:	e8 68 fe ff ff       	call   801956 <fsipc>
  801aee:	89 c3                	mov    %eax,%ebx
  801af0:	83 c4 10             	add    $0x10,%esp
  801af3:	85 c0                	test   %eax,%eax
  801af5:	79 14                	jns    801b0b <open+0x6d>
		fd_close(fd, 0);
  801af7:	83 ec 08             	sub    $0x8,%esp
  801afa:	6a 00                	push   $0x0
  801afc:	ff 75 f4             	pushl  -0xc(%ebp)
  801aff:	e8 dd f9 ff ff       	call   8014e1 <fd_close>
		return r;
  801b04:	83 c4 10             	add    $0x10,%esp
  801b07:	89 d8                	mov    %ebx,%eax
  801b09:	eb 15                	jmp    801b20 <open+0x82>
	}

	return fd2num(fd);
  801b0b:	83 ec 0c             	sub    $0xc,%esp
  801b0e:	ff 75 f4             	pushl  -0xc(%ebp)
  801b11:	e8 6b f8 ff ff       	call   801381 <fd2num>
  801b16:	83 c4 10             	add    $0x10,%esp
  801b19:	eb 05                	jmp    801b20 <open+0x82>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801b1b:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801b20:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b23:	c9                   	leave  
  801b24:	c3                   	ret    

00801b25 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b25:	55                   	push   %ebp
  801b26:	89 e5                	mov    %esp,%ebp
  801b28:	56                   	push   %esi
  801b29:	53                   	push   %ebx
  801b2a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b2d:	83 ec 0c             	sub    $0xc,%esp
  801b30:	ff 75 08             	pushl  0x8(%ebp)
  801b33:	e8 59 f8 ff ff       	call   801391 <fd2data>
  801b38:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b3a:	83 c4 08             	add    $0x8,%esp
  801b3d:	68 40 29 80 00       	push   $0x802940
  801b42:	53                   	push   %ebx
  801b43:	e8 3a f1 ff ff       	call   800c82 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b48:	8b 46 04             	mov    0x4(%esi),%eax
  801b4b:	2b 06                	sub    (%esi),%eax
  801b4d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b53:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b5a:	00 00 00 
	stat->st_dev = &devpipe;
  801b5d:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801b64:	30 80 00 
	return 0;
}
  801b67:	b8 00 00 00 00       	mov    $0x0,%eax
  801b6c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b6f:	5b                   	pop    %ebx
  801b70:	5e                   	pop    %esi
  801b71:	5d                   	pop    %ebp
  801b72:	c3                   	ret    

00801b73 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b73:	55                   	push   %ebp
  801b74:	89 e5                	mov    %esp,%ebp
  801b76:	53                   	push   %ebx
  801b77:	83 ec 0c             	sub    $0xc,%esp
  801b7a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b7d:	53                   	push   %ebx
  801b7e:	6a 00                	push   $0x0
  801b80:	e8 f2 f5 ff ff       	call   801177 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b85:	89 1c 24             	mov    %ebx,(%esp)
  801b88:	e8 04 f8 ff ff       	call   801391 <fd2data>
  801b8d:	83 c4 08             	add    $0x8,%esp
  801b90:	50                   	push   %eax
  801b91:	6a 00                	push   $0x0
  801b93:	e8 df f5 ff ff       	call   801177 <sys_page_unmap>
}
  801b98:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b9b:	c9                   	leave  
  801b9c:	c3                   	ret    

00801b9d <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b9d:	55                   	push   %ebp
  801b9e:	89 e5                	mov    %esp,%ebp
  801ba0:	57                   	push   %edi
  801ba1:	56                   	push   %esi
  801ba2:	53                   	push   %ebx
  801ba3:	83 ec 1c             	sub    $0x1c,%esp
  801ba6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ba9:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801bab:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801bb0:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801bb3:	83 ec 0c             	sub    $0xc,%esp
  801bb6:	ff 75 e0             	pushl  -0x20(%ebp)
  801bb9:	e8 8a 05 00 00       	call   802148 <pageref>
  801bbe:	89 c3                	mov    %eax,%ebx
  801bc0:	89 3c 24             	mov    %edi,(%esp)
  801bc3:	e8 80 05 00 00       	call   802148 <pageref>
  801bc8:	83 c4 10             	add    $0x10,%esp
  801bcb:	39 c3                	cmp    %eax,%ebx
  801bcd:	0f 94 c1             	sete   %cl
  801bd0:	0f b6 c9             	movzbl %cl,%ecx
  801bd3:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801bd6:	8b 15 b0 40 80 00    	mov    0x8040b0,%edx
  801bdc:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801bdf:	39 ce                	cmp    %ecx,%esi
  801be1:	74 1b                	je     801bfe <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801be3:	39 c3                	cmp    %eax,%ebx
  801be5:	75 c4                	jne    801bab <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801be7:	8b 42 58             	mov    0x58(%edx),%eax
  801bea:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bed:	50                   	push   %eax
  801bee:	56                   	push   %esi
  801bef:	68 47 29 80 00       	push   $0x802947
  801bf4:	e8 a4 ea ff ff       	call   80069d <cprintf>
  801bf9:	83 c4 10             	add    $0x10,%esp
  801bfc:	eb ad                	jmp    801bab <_pipeisclosed+0xe>
	}
}
  801bfe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c01:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c04:	5b                   	pop    %ebx
  801c05:	5e                   	pop    %esi
  801c06:	5f                   	pop    %edi
  801c07:	5d                   	pop    %ebp
  801c08:	c3                   	ret    

00801c09 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c09:	55                   	push   %ebp
  801c0a:	89 e5                	mov    %esp,%ebp
  801c0c:	57                   	push   %edi
  801c0d:	56                   	push   %esi
  801c0e:	53                   	push   %ebx
  801c0f:	83 ec 18             	sub    $0x18,%esp
  801c12:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c15:	56                   	push   %esi
  801c16:	e8 76 f7 ff ff       	call   801391 <fd2data>
  801c1b:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c1d:	83 c4 10             	add    $0x10,%esp
  801c20:	bf 00 00 00 00       	mov    $0x0,%edi
  801c25:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c29:	75 42                	jne    801c6d <devpipe_write+0x64>
  801c2b:	eb 4e                	jmp    801c7b <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c2d:	89 da                	mov    %ebx,%edx
  801c2f:	89 f0                	mov    %esi,%eax
  801c31:	e8 67 ff ff ff       	call   801b9d <_pipeisclosed>
  801c36:	85 c0                	test   %eax,%eax
  801c38:	75 46                	jne    801c80 <devpipe_write+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c3a:	e8 94 f4 ff ff       	call   8010d3 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c3f:	8b 53 04             	mov    0x4(%ebx),%edx
  801c42:	8b 03                	mov    (%ebx),%eax
  801c44:	83 c0 20             	add    $0x20,%eax
  801c47:	39 c2                	cmp    %eax,%edx
  801c49:	73 e2                	jae    801c2d <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c4b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c4e:	8a 0c 38             	mov    (%eax,%edi,1),%cl
  801c51:	89 d0                	mov    %edx,%eax
  801c53:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801c58:	79 05                	jns    801c5f <devpipe_write+0x56>
  801c5a:	48                   	dec    %eax
  801c5b:	83 c8 e0             	or     $0xffffffe0,%eax
  801c5e:	40                   	inc    %eax
  801c5f:	88 4c 03 08          	mov    %cl,0x8(%ebx,%eax,1)
		p->p_wpos++;
  801c63:	42                   	inc    %edx
  801c64:	89 53 04             	mov    %edx,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c67:	47                   	inc    %edi
  801c68:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801c6b:	74 0e                	je     801c7b <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c6d:	8b 53 04             	mov    0x4(%ebx),%edx
  801c70:	8b 03                	mov    (%ebx),%eax
  801c72:	83 c0 20             	add    $0x20,%eax
  801c75:	39 c2                	cmp    %eax,%edx
  801c77:	73 b4                	jae    801c2d <devpipe_write+0x24>
  801c79:	eb d0                	jmp    801c4b <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c7b:	8b 45 10             	mov    0x10(%ebp),%eax
  801c7e:	eb 05                	jmp    801c85 <devpipe_write+0x7c>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c80:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c85:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c88:	5b                   	pop    %ebx
  801c89:	5e                   	pop    %esi
  801c8a:	5f                   	pop    %edi
  801c8b:	5d                   	pop    %ebp
  801c8c:	c3                   	ret    

00801c8d <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c8d:	55                   	push   %ebp
  801c8e:	89 e5                	mov    %esp,%ebp
  801c90:	57                   	push   %edi
  801c91:	56                   	push   %esi
  801c92:	53                   	push   %ebx
  801c93:	83 ec 18             	sub    $0x18,%esp
  801c96:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c99:	57                   	push   %edi
  801c9a:	e8 f2 f6 ff ff       	call   801391 <fd2data>
  801c9f:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ca1:	83 c4 10             	add    $0x10,%esp
  801ca4:	be 00 00 00 00       	mov    $0x0,%esi
  801ca9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801cad:	75 3d                	jne    801cec <devpipe_read+0x5f>
  801caf:	eb 48                	jmp    801cf9 <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801cb1:	89 f0                	mov    %esi,%eax
  801cb3:	eb 4e                	jmp    801d03 <devpipe_read+0x76>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801cb5:	89 da                	mov    %ebx,%edx
  801cb7:	89 f8                	mov    %edi,%eax
  801cb9:	e8 df fe ff ff       	call   801b9d <_pipeisclosed>
  801cbe:	85 c0                	test   %eax,%eax
  801cc0:	75 3c                	jne    801cfe <devpipe_read+0x71>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801cc2:	e8 0c f4 ff ff       	call   8010d3 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801cc7:	8b 03                	mov    (%ebx),%eax
  801cc9:	3b 43 04             	cmp    0x4(%ebx),%eax
  801ccc:	74 e7                	je     801cb5 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801cce:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801cd3:	79 05                	jns    801cda <devpipe_read+0x4d>
  801cd5:	48                   	dec    %eax
  801cd6:	83 c8 e0             	or     $0xffffffe0,%eax
  801cd9:	40                   	inc    %eax
  801cda:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801cde:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ce1:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801ce4:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ce6:	46                   	inc    %esi
  801ce7:	39 75 10             	cmp    %esi,0x10(%ebp)
  801cea:	74 0d                	je     801cf9 <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
  801cec:	8b 03                	mov    (%ebx),%eax
  801cee:	3b 43 04             	cmp    0x4(%ebx),%eax
  801cf1:	75 db                	jne    801cce <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801cf3:	85 f6                	test   %esi,%esi
  801cf5:	75 ba                	jne    801cb1 <devpipe_read+0x24>
  801cf7:	eb bc                	jmp    801cb5 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801cf9:	8b 45 10             	mov    0x10(%ebp),%eax
  801cfc:	eb 05                	jmp    801d03 <devpipe_read+0x76>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cfe:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d03:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d06:	5b                   	pop    %ebx
  801d07:	5e                   	pop    %esi
  801d08:	5f                   	pop    %edi
  801d09:	5d                   	pop    %ebp
  801d0a:	c3                   	ret    

00801d0b <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d0b:	55                   	push   %ebp
  801d0c:	89 e5                	mov    %esp,%ebp
  801d0e:	56                   	push   %esi
  801d0f:	53                   	push   %ebx
  801d10:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d13:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d16:	50                   	push   %eax
  801d17:	e8 8c f6 ff ff       	call   8013a8 <fd_alloc>
  801d1c:	83 c4 10             	add    $0x10,%esp
  801d1f:	85 c0                	test   %eax,%eax
  801d21:	0f 88 2a 01 00 00    	js     801e51 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d27:	83 ec 04             	sub    $0x4,%esp
  801d2a:	68 07 04 00 00       	push   $0x407
  801d2f:	ff 75 f4             	pushl  -0xc(%ebp)
  801d32:	6a 00                	push   $0x0
  801d34:	e8 b9 f3 ff ff       	call   8010f2 <sys_page_alloc>
  801d39:	83 c4 10             	add    $0x10,%esp
  801d3c:	85 c0                	test   %eax,%eax
  801d3e:	0f 88 0d 01 00 00    	js     801e51 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d44:	83 ec 0c             	sub    $0xc,%esp
  801d47:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d4a:	50                   	push   %eax
  801d4b:	e8 58 f6 ff ff       	call   8013a8 <fd_alloc>
  801d50:	89 c3                	mov    %eax,%ebx
  801d52:	83 c4 10             	add    $0x10,%esp
  801d55:	85 c0                	test   %eax,%eax
  801d57:	0f 88 e2 00 00 00    	js     801e3f <pipe+0x134>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d5d:	83 ec 04             	sub    $0x4,%esp
  801d60:	68 07 04 00 00       	push   $0x407
  801d65:	ff 75 f0             	pushl  -0x10(%ebp)
  801d68:	6a 00                	push   $0x0
  801d6a:	e8 83 f3 ff ff       	call   8010f2 <sys_page_alloc>
  801d6f:	89 c3                	mov    %eax,%ebx
  801d71:	83 c4 10             	add    $0x10,%esp
  801d74:	85 c0                	test   %eax,%eax
  801d76:	0f 88 c3 00 00 00    	js     801e3f <pipe+0x134>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d7c:	83 ec 0c             	sub    $0xc,%esp
  801d7f:	ff 75 f4             	pushl  -0xc(%ebp)
  801d82:	e8 0a f6 ff ff       	call   801391 <fd2data>
  801d87:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d89:	83 c4 0c             	add    $0xc,%esp
  801d8c:	68 07 04 00 00       	push   $0x407
  801d91:	50                   	push   %eax
  801d92:	6a 00                	push   $0x0
  801d94:	e8 59 f3 ff ff       	call   8010f2 <sys_page_alloc>
  801d99:	89 c3                	mov    %eax,%ebx
  801d9b:	83 c4 10             	add    $0x10,%esp
  801d9e:	85 c0                	test   %eax,%eax
  801da0:	0f 88 89 00 00 00    	js     801e2f <pipe+0x124>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801da6:	83 ec 0c             	sub    $0xc,%esp
  801da9:	ff 75 f0             	pushl  -0x10(%ebp)
  801dac:	e8 e0 f5 ff ff       	call   801391 <fd2data>
  801db1:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801db8:	50                   	push   %eax
  801db9:	6a 00                	push   $0x0
  801dbb:	56                   	push   %esi
  801dbc:	6a 00                	push   $0x0
  801dbe:	e8 72 f3 ff ff       	call   801135 <sys_page_map>
  801dc3:	89 c3                	mov    %eax,%ebx
  801dc5:	83 c4 20             	add    $0x20,%esp
  801dc8:	85 c0                	test   %eax,%eax
  801dca:	78 55                	js     801e21 <pipe+0x116>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801dcc:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801dd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dd5:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801dd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dda:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801de1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801de7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dea:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801dec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801def:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801df6:	83 ec 0c             	sub    $0xc,%esp
  801df9:	ff 75 f4             	pushl  -0xc(%ebp)
  801dfc:	e8 80 f5 ff ff       	call   801381 <fd2num>
  801e01:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e04:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e06:	83 c4 04             	add    $0x4,%esp
  801e09:	ff 75 f0             	pushl  -0x10(%ebp)
  801e0c:	e8 70 f5 ff ff       	call   801381 <fd2num>
  801e11:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e14:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801e17:	83 c4 10             	add    $0x10,%esp
  801e1a:	b8 00 00 00 00       	mov    $0x0,%eax
  801e1f:	eb 30                	jmp    801e51 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801e21:	83 ec 08             	sub    $0x8,%esp
  801e24:	56                   	push   %esi
  801e25:	6a 00                	push   $0x0
  801e27:	e8 4b f3 ff ff       	call   801177 <sys_page_unmap>
  801e2c:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801e2f:	83 ec 08             	sub    $0x8,%esp
  801e32:	ff 75 f0             	pushl  -0x10(%ebp)
  801e35:	6a 00                	push   $0x0
  801e37:	e8 3b f3 ff ff       	call   801177 <sys_page_unmap>
  801e3c:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e3f:	83 ec 08             	sub    $0x8,%esp
  801e42:	ff 75 f4             	pushl  -0xc(%ebp)
  801e45:	6a 00                	push   $0x0
  801e47:	e8 2b f3 ff ff       	call   801177 <sys_page_unmap>
  801e4c:	83 c4 10             	add    $0x10,%esp
  801e4f:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  801e51:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e54:	5b                   	pop    %ebx
  801e55:	5e                   	pop    %esi
  801e56:	5d                   	pop    %ebp
  801e57:	c3                   	ret    

00801e58 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e58:	55                   	push   %ebp
  801e59:	89 e5                	mov    %esp,%ebp
  801e5b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e5e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e61:	50                   	push   %eax
  801e62:	ff 75 08             	pushl  0x8(%ebp)
  801e65:	e8 b2 f5 ff ff       	call   80141c <fd_lookup>
  801e6a:	83 c4 10             	add    $0x10,%esp
  801e6d:	85 c0                	test   %eax,%eax
  801e6f:	78 18                	js     801e89 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e71:	83 ec 0c             	sub    $0xc,%esp
  801e74:	ff 75 f4             	pushl  -0xc(%ebp)
  801e77:	e8 15 f5 ff ff       	call   801391 <fd2data>
	return _pipeisclosed(fd, p);
  801e7c:	89 c2                	mov    %eax,%edx
  801e7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e81:	e8 17 fd ff ff       	call   801b9d <_pipeisclosed>
  801e86:	83 c4 10             	add    $0x10,%esp
}
  801e89:	c9                   	leave  
  801e8a:	c3                   	ret    

00801e8b <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e8b:	55                   	push   %ebp
  801e8c:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e8e:	b8 00 00 00 00       	mov    $0x0,%eax
  801e93:	5d                   	pop    %ebp
  801e94:	c3                   	ret    

00801e95 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e95:	55                   	push   %ebp
  801e96:	89 e5                	mov    %esp,%ebp
  801e98:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e9b:	68 5f 29 80 00       	push   $0x80295f
  801ea0:	ff 75 0c             	pushl  0xc(%ebp)
  801ea3:	e8 da ed ff ff       	call   800c82 <strcpy>
	return 0;
}
  801ea8:	b8 00 00 00 00       	mov    $0x0,%eax
  801ead:	c9                   	leave  
  801eae:	c3                   	ret    

00801eaf <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801eaf:	55                   	push   %ebp
  801eb0:	89 e5                	mov    %esp,%ebp
  801eb2:	57                   	push   %edi
  801eb3:	56                   	push   %esi
  801eb4:	53                   	push   %ebx
  801eb5:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ebb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ebf:	74 45                	je     801f06 <devcons_write+0x57>
  801ec1:	b8 00 00 00 00       	mov    $0x0,%eax
  801ec6:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ecb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801ed1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ed4:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801ed6:	83 fb 7f             	cmp    $0x7f,%ebx
  801ed9:	76 05                	jbe    801ee0 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801edb:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801ee0:	83 ec 04             	sub    $0x4,%esp
  801ee3:	53                   	push   %ebx
  801ee4:	03 45 0c             	add    0xc(%ebp),%eax
  801ee7:	50                   	push   %eax
  801ee8:	57                   	push   %edi
  801ee9:	e8 61 ef ff ff       	call   800e4f <memmove>
		sys_cputs(buf, m);
  801eee:	83 c4 08             	add    $0x8,%esp
  801ef1:	53                   	push   %ebx
  801ef2:	57                   	push   %edi
  801ef3:	e8 3e f1 ff ff       	call   801036 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ef8:	01 de                	add    %ebx,%esi
  801efa:	89 f0                	mov    %esi,%eax
  801efc:	83 c4 10             	add    $0x10,%esp
  801eff:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f02:	72 cd                	jb     801ed1 <devcons_write+0x22>
  801f04:	eb 05                	jmp    801f0b <devcons_write+0x5c>
  801f06:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f0b:	89 f0                	mov    %esi,%eax
  801f0d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f10:	5b                   	pop    %ebx
  801f11:	5e                   	pop    %esi
  801f12:	5f                   	pop    %edi
  801f13:	5d                   	pop    %ebp
  801f14:	c3                   	ret    

00801f15 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f15:	55                   	push   %ebp
  801f16:	89 e5                	mov    %esp,%ebp
  801f18:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801f1b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f1f:	75 07                	jne    801f28 <devcons_read+0x13>
  801f21:	eb 23                	jmp    801f46 <devcons_read+0x31>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f23:	e8 ab f1 ff ff       	call   8010d3 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f28:	e8 27 f1 ff ff       	call   801054 <sys_cgetc>
  801f2d:	85 c0                	test   %eax,%eax
  801f2f:	74 f2                	je     801f23 <devcons_read+0xe>
		sys_yield();
	if (c < 0)
  801f31:	85 c0                	test   %eax,%eax
  801f33:	78 1d                	js     801f52 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f35:	83 f8 04             	cmp    $0x4,%eax
  801f38:	74 13                	je     801f4d <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  801f3a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f3d:	88 02                	mov    %al,(%edx)
	return 1;
  801f3f:	b8 01 00 00 00       	mov    $0x1,%eax
  801f44:	eb 0c                	jmp    801f52 <devcons_read+0x3d>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801f46:	b8 00 00 00 00       	mov    $0x0,%eax
  801f4b:	eb 05                	jmp    801f52 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f4d:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f52:	c9                   	leave  
  801f53:	c3                   	ret    

00801f54 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f54:	55                   	push   %ebp
  801f55:	89 e5                	mov    %esp,%ebp
  801f57:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f5a:	8b 45 08             	mov    0x8(%ebp),%eax
  801f5d:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f60:	6a 01                	push   $0x1
  801f62:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f65:	50                   	push   %eax
  801f66:	e8 cb f0 ff ff       	call   801036 <sys_cputs>
}
  801f6b:	83 c4 10             	add    $0x10,%esp
  801f6e:	c9                   	leave  
  801f6f:	c3                   	ret    

00801f70 <getchar>:

int
getchar(void)
{
  801f70:	55                   	push   %ebp
  801f71:	89 e5                	mov    %esp,%ebp
  801f73:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f76:	6a 01                	push   $0x1
  801f78:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f7b:	50                   	push   %eax
  801f7c:	6a 00                	push   $0x0
  801f7e:	e8 1a f7 ff ff       	call   80169d <read>
	if (r < 0)
  801f83:	83 c4 10             	add    $0x10,%esp
  801f86:	85 c0                	test   %eax,%eax
  801f88:	78 0f                	js     801f99 <getchar+0x29>
		return r;
	if (r < 1)
  801f8a:	85 c0                	test   %eax,%eax
  801f8c:	7e 06                	jle    801f94 <getchar+0x24>
		return -E_EOF;
	return c;
  801f8e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f92:	eb 05                	jmp    801f99 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f94:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f99:	c9                   	leave  
  801f9a:	c3                   	ret    

00801f9b <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f9b:	55                   	push   %ebp
  801f9c:	89 e5                	mov    %esp,%ebp
  801f9e:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fa1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fa4:	50                   	push   %eax
  801fa5:	ff 75 08             	pushl  0x8(%ebp)
  801fa8:	e8 6f f4 ff ff       	call   80141c <fd_lookup>
  801fad:	83 c4 10             	add    $0x10,%esp
  801fb0:	85 c0                	test   %eax,%eax
  801fb2:	78 11                	js     801fc5 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801fb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fb7:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fbd:	39 10                	cmp    %edx,(%eax)
  801fbf:	0f 94 c0             	sete   %al
  801fc2:	0f b6 c0             	movzbl %al,%eax
}
  801fc5:	c9                   	leave  
  801fc6:	c3                   	ret    

00801fc7 <opencons>:

int
opencons(void)
{
  801fc7:	55                   	push   %ebp
  801fc8:	89 e5                	mov    %esp,%ebp
  801fca:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fcd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fd0:	50                   	push   %eax
  801fd1:	e8 d2 f3 ff ff       	call   8013a8 <fd_alloc>
  801fd6:	83 c4 10             	add    $0x10,%esp
  801fd9:	85 c0                	test   %eax,%eax
  801fdb:	78 3a                	js     802017 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fdd:	83 ec 04             	sub    $0x4,%esp
  801fe0:	68 07 04 00 00       	push   $0x407
  801fe5:	ff 75 f4             	pushl  -0xc(%ebp)
  801fe8:	6a 00                	push   $0x0
  801fea:	e8 03 f1 ff ff       	call   8010f2 <sys_page_alloc>
  801fef:	83 c4 10             	add    $0x10,%esp
  801ff2:	85 c0                	test   %eax,%eax
  801ff4:	78 21                	js     802017 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ff6:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ffc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fff:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802001:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802004:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80200b:	83 ec 0c             	sub    $0xc,%esp
  80200e:	50                   	push   %eax
  80200f:	e8 6d f3 ff ff       	call   801381 <fd2num>
  802014:	83 c4 10             	add    $0x10,%esp
}
  802017:	c9                   	leave  
  802018:	c3                   	ret    

00802019 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802019:	55                   	push   %ebp
  80201a:	89 e5                	mov    %esp,%ebp
  80201c:	56                   	push   %esi
  80201d:	53                   	push   %ebx
  80201e:	8b 75 08             	mov    0x8(%ebp),%esi
  802021:	8b 45 0c             	mov    0xc(%ebp),%eax
  802024:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");
	int r;
    if (pg != NULL) {
  802027:	85 c0                	test   %eax,%eax
  802029:	74 0e                	je     802039 <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  80202b:	83 ec 0c             	sub    $0xc,%esp
  80202e:	50                   	push   %eax
  80202f:	e8 6e f2 ff ff       	call   8012a2 <sys_ipc_recv>
  802034:	83 c4 10             	add    $0x10,%esp
  802037:	eb 10                	jmp    802049 <ipc_recv+0x30>
    } else {
        r = sys_ipc_recv((void *) UTOP);
  802039:	83 ec 0c             	sub    $0xc,%esp
  80203c:	68 00 00 c0 ee       	push   $0xeec00000
  802041:	e8 5c f2 ff ff       	call   8012a2 <sys_ipc_recv>
  802046:	83 c4 10             	add    $0x10,%esp
    }
    if (r < 0) {
  802049:	85 c0                	test   %eax,%eax
  80204b:	79 16                	jns    802063 <ipc_recv+0x4a>
        // failed
        if (from_env_store != NULL) *from_env_store = 0;
  80204d:	85 f6                	test   %esi,%esi
  80204f:	74 06                	je     802057 <ipc_recv+0x3e>
  802051:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL) *perm_store = 0;
  802057:	85 db                	test   %ebx,%ebx
  802059:	74 2c                	je     802087 <ipc_recv+0x6e>
  80205b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802061:	eb 24                	jmp    802087 <ipc_recv+0x6e>
        return r;
    } else {
        if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  802063:	85 f6                	test   %esi,%esi
  802065:	74 0a                	je     802071 <ipc_recv+0x58>
  802067:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  80206c:	8b 40 74             	mov    0x74(%eax),%eax
  80206f:	89 06                	mov    %eax,(%esi)
        if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  802071:	85 db                	test   %ebx,%ebx
  802073:	74 0a                	je     80207f <ipc_recv+0x66>
  802075:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  80207a:	8b 40 78             	mov    0x78(%eax),%eax
  80207d:	89 03                	mov    %eax,(%ebx)
        return thisenv->env_ipc_value;
  80207f:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  802084:	8b 40 70             	mov    0x70(%eax),%eax
    }
 
	return 0;
}
  802087:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80208a:	5b                   	pop    %ebx
  80208b:	5e                   	pop    %esi
  80208c:	5d                   	pop    %ebp
  80208d:	c3                   	ret    

0080208e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80208e:	55                   	push   %ebp
  80208f:	89 e5                	mov    %esp,%ebp
  802091:	57                   	push   %edi
  802092:	56                   	push   %esi
  802093:	53                   	push   %ebx
  802094:	83 ec 0c             	sub    $0xc,%esp
  802097:	8b 75 10             	mov    0x10(%ebp),%esi
  80209a:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;
    if (pg == NULL) pg = (void *)UTOP;
  80209d:	85 f6                	test   %esi,%esi
  80209f:	75 05                	jne    8020a6 <ipc_send+0x18>
  8020a1:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
  8020a6:	57                   	push   %edi
  8020a7:	56                   	push   %esi
  8020a8:	ff 75 0c             	pushl  0xc(%ebp)
  8020ab:	ff 75 08             	pushl  0x8(%ebp)
  8020ae:	e8 cc f1 ff ff       	call   80127f <sys_ipc_try_send>
  8020b3:	89 c3                	mov    %eax,%ebx
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
  8020b5:	83 c4 10             	add    $0x10,%esp
  8020b8:	85 c0                	test   %eax,%eax
  8020ba:	79 17                	jns    8020d3 <ipc_send+0x45>
  8020bc:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020bf:	74 1d                	je     8020de <ipc_send+0x50>
  8020c1:	50                   	push   %eax
  8020c2:	68 6b 29 80 00       	push   $0x80296b
  8020c7:	6a 40                	push   $0x40
  8020c9:	68 7f 29 80 00       	push   $0x80297f
  8020ce:	e8 f2 e4 ff ff       	call   8005c5 <_panic>
        sys_yield();
  8020d3:	e8 fb ef ff ff       	call   8010d3 <sys_yield>
    } while (r != 0);
  8020d8:	85 db                	test   %ebx,%ebx
  8020da:	75 ca                	jne    8020a6 <ipc_send+0x18>
  8020dc:	eb 07                	jmp    8020e5 <ipc_send+0x57>
	int r;
    if (pg == NULL) pg = (void *)UTOP;
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
        sys_yield();
  8020de:	e8 f0 ef ff ff       	call   8010d3 <sys_yield>
  8020e3:	eb c1                	jmp    8020a6 <ipc_send+0x18>
    } while (r != 0);
}
  8020e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020e8:	5b                   	pop    %ebx
  8020e9:	5e                   	pop    %esi
  8020ea:	5f                   	pop    %edi
  8020eb:	5d                   	pop    %ebp
  8020ec:	c3                   	ret    

008020ed <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8020ed:	55                   	push   %ebp
  8020ee:	89 e5                	mov    %esp,%ebp
  8020f0:	53                   	push   %ebx
  8020f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8020f4:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  8020f9:	39 c1                	cmp    %eax,%ecx
  8020fb:	74 21                	je     80211e <ipc_find_env+0x31>
  8020fd:	ba 01 00 00 00       	mov    $0x1,%edx
  802102:	8d 1c 95 00 00 00 00 	lea    0x0(,%edx,4),%ebx
  802109:	89 d0                	mov    %edx,%eax
  80210b:	c1 e0 07             	shl    $0x7,%eax
  80210e:	29 d8                	sub    %ebx,%eax
  802110:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802115:	8b 40 50             	mov    0x50(%eax),%eax
  802118:	39 c8                	cmp    %ecx,%eax
  80211a:	75 1b                	jne    802137 <ipc_find_env+0x4a>
  80211c:	eb 05                	jmp    802123 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80211e:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_type == type)
			return envs[i].env_id;
  802123:	8d 04 95 00 00 00 00 	lea    0x0(,%edx,4),%eax
  80212a:	c1 e2 07             	shl    $0x7,%edx
  80212d:	29 c2                	sub    %eax,%edx
  80212f:	8b 82 48 00 c0 ee    	mov    -0x113fffb8(%edx),%eax
  802135:	eb 0e                	jmp    802145 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802137:	42                   	inc    %edx
  802138:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  80213e:	75 c2                	jne    802102 <ipc_find_env+0x15>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802140:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802145:	5b                   	pop    %ebx
  802146:	5d                   	pop    %ebp
  802147:	c3                   	ret    

00802148 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802148:	55                   	push   %ebp
  802149:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80214b:	8b 45 08             	mov    0x8(%ebp),%eax
  80214e:	c1 e8 16             	shr    $0x16,%eax
  802151:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802158:	a8 01                	test   $0x1,%al
  80215a:	74 21                	je     80217d <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  80215c:	8b 45 08             	mov    0x8(%ebp),%eax
  80215f:	c1 e8 0c             	shr    $0xc,%eax
  802162:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802169:	a8 01                	test   $0x1,%al
  80216b:	74 17                	je     802184 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80216d:	c1 e8 0c             	shr    $0xc,%eax
  802170:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802177:	ef 
  802178:	0f b7 c0             	movzwl %ax,%eax
  80217b:	eb 0c                	jmp    802189 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  80217d:	b8 00 00 00 00       	mov    $0x0,%eax
  802182:	eb 05                	jmp    802189 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802184:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802189:	5d                   	pop    %ebp
  80218a:	c3                   	ret    
  80218b:	90                   	nop

0080218c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  80218c:	55                   	push   %ebp
  80218d:	57                   	push   %edi
  80218e:	56                   	push   %esi
  80218f:	53                   	push   %ebx
  802190:	83 ec 1c             	sub    $0x1c,%esp
  802193:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  802197:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  80219b:	8b 7c 24 38          	mov    0x38(%esp),%edi
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80219f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021a3:	89 ca                	mov    %ecx,%edx
  const DWunion dd = {.ll = d};
  8021a5:	89 f8                	mov    %edi,%eax
  8021a7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8021ab:	85 f6                	test   %esi,%esi
  8021ad:	75 2d                	jne    8021dc <__udivdi3+0x50>
    {
      if (d0 > n1)
  8021af:	39 cf                	cmp    %ecx,%edi
  8021b1:	77 65                	ja     802218 <__udivdi3+0x8c>
  8021b3:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8021b5:	85 ff                	test   %edi,%edi
  8021b7:	75 0b                	jne    8021c4 <__udivdi3+0x38>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8021b9:	b8 01 00 00 00       	mov    $0x1,%eax
  8021be:	31 d2                	xor    %edx,%edx
  8021c0:	f7 f7                	div    %edi
  8021c2:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8021c4:	31 d2                	xor    %edx,%edx
  8021c6:	89 c8                	mov    %ecx,%eax
  8021c8:	f7 f5                	div    %ebp
  8021ca:	89 c1                	mov    %eax,%ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8021cc:	89 d8                	mov    %ebx,%eax
  8021ce:	f7 f5                	div    %ebp
  8021d0:	89 cf                	mov    %ecx,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8021d2:	89 fa                	mov    %edi,%edx
  8021d4:	83 c4 1c             	add    $0x1c,%esp
  8021d7:	5b                   	pop    %ebx
  8021d8:	5e                   	pop    %esi
  8021d9:	5f                   	pop    %edi
  8021da:	5d                   	pop    %ebp
  8021db:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8021dc:	39 ce                	cmp    %ecx,%esi
  8021de:	77 28                	ja     802208 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8021e0:	0f bd fe             	bsr    %esi,%edi
	  if (bm == 0)
  8021e3:	83 f7 1f             	xor    $0x1f,%edi
  8021e6:	75 40                	jne    802228 <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8021e8:	39 ce                	cmp    %ecx,%esi
  8021ea:	72 0a                	jb     8021f6 <__udivdi3+0x6a>
  8021ec:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8021f0:	0f 87 9e 00 00 00    	ja     802294 <__udivdi3+0x108>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8021f6:	b8 01 00 00 00       	mov    $0x1,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8021fb:	89 fa                	mov    %edi,%edx
  8021fd:	83 c4 1c             	add    $0x1c,%esp
  802200:	5b                   	pop    %ebx
  802201:	5e                   	pop    %esi
  802202:	5f                   	pop    %edi
  802203:	5d                   	pop    %ebp
  802204:	c3                   	ret    
  802205:	8d 76 00             	lea    0x0(%esi),%esi
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802208:	31 ff                	xor    %edi,%edi
  80220a:	31 c0                	xor    %eax,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80220c:	89 fa                	mov    %edi,%edx
  80220e:	83 c4 1c             	add    $0x1c,%esp
  802211:	5b                   	pop    %ebx
  802212:	5e                   	pop    %esi
  802213:	5f                   	pop    %edi
  802214:	5d                   	pop    %ebp
  802215:	c3                   	ret    
  802216:	66 90                	xchg   %ax,%ax
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802218:	89 d8                	mov    %ebx,%eax
  80221a:	f7 f7                	div    %edi
  80221c:	31 ff                	xor    %edi,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80221e:	89 fa                	mov    %edi,%edx
  802220:	83 c4 1c             	add    $0x1c,%esp
  802223:	5b                   	pop    %ebx
  802224:	5e                   	pop    %esi
  802225:	5f                   	pop    %edi
  802226:	5d                   	pop    %ebp
  802227:	c3                   	ret    
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802228:	bd 20 00 00 00       	mov    $0x20,%ebp
  80222d:	89 eb                	mov    %ebp,%ebx
  80222f:	29 fb                	sub    %edi,%ebx

	      d1 = (d1 << bm) | (d0 >> b);
  802231:	89 f9                	mov    %edi,%ecx
  802233:	d3 e6                	shl    %cl,%esi
  802235:	89 c5                	mov    %eax,%ebp
  802237:	88 d9                	mov    %bl,%cl
  802239:	d3 ed                	shr    %cl,%ebp
  80223b:	89 e9                	mov    %ebp,%ecx
  80223d:	09 f1                	or     %esi,%ecx
  80223f:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
	      d0 = d0 << bm;
  802243:	89 f9                	mov    %edi,%ecx
  802245:	d3 e0                	shl    %cl,%eax
  802247:	89 c5                	mov    %eax,%ebp
	      n2 = n1 >> b;
  802249:	89 d6                	mov    %edx,%esi
  80224b:	88 d9                	mov    %bl,%cl
  80224d:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
  80224f:	89 f9                	mov    %edi,%ecx
  802251:	d3 e2                	shl    %cl,%edx
  802253:	8b 44 24 08          	mov    0x8(%esp),%eax
  802257:	88 d9                	mov    %bl,%cl
  802259:	d3 e8                	shr    %cl,%eax
  80225b:	09 c2                	or     %eax,%edx
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80225d:	89 d0                	mov    %edx,%eax
  80225f:	89 f2                	mov    %esi,%edx
  802261:	f7 74 24 0c          	divl   0xc(%esp)
  802265:	89 d6                	mov    %edx,%esi
  802267:	89 c3                	mov    %eax,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  802269:	f7 e5                	mul    %ebp

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80226b:	39 d6                	cmp    %edx,%esi
  80226d:	72 19                	jb     802288 <__udivdi3+0xfc>
  80226f:	74 0b                	je     80227c <__udivdi3+0xf0>
  802271:	89 d8                	mov    %ebx,%eax
  802273:	31 ff                	xor    %edi,%edi
  802275:	e9 58 ff ff ff       	jmp    8021d2 <__udivdi3+0x46>
  80227a:	66 90                	xchg   %ax,%ax
  80227c:	8b 54 24 08          	mov    0x8(%esp),%edx
  802280:	89 f9                	mov    %edi,%ecx
  802282:	d3 e2                	shl    %cl,%edx
  802284:	39 c2                	cmp    %eax,%edx
  802286:	73 e9                	jae    802271 <__udivdi3+0xe5>
  802288:	8d 43 ff             	lea    -0x1(%ebx),%eax
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80228b:	31 ff                	xor    %edi,%edi
  80228d:	e9 40 ff ff ff       	jmp    8021d2 <__udivdi3+0x46>
  802292:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802294:	31 c0                	xor    %eax,%eax
  802296:	e9 37 ff ff ff       	jmp    8021d2 <__udivdi3+0x46>
  80229b:	90                   	nop

0080229c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  80229c:	55                   	push   %ebp
  80229d:	57                   	push   %edi
  80229e:	56                   	push   %esi
  80229f:	53                   	push   %ebx
  8022a0:	83 ec 1c             	sub    $0x1c,%esp
  8022a3:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8022a7:	8b 74 24 34          	mov    0x34(%esp),%esi
  8022ab:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022af:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8022b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8022b7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022bb:	89 f3                	mov    %esi,%ebx
  const DWunion dd = {.ll = d};
  8022bd:	89 fa                	mov    %edi,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8022bf:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  n1 = nn.s.high;
  8022c3:	89 34 24             	mov    %esi,(%esp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8022c6:	85 c0                	test   %eax,%eax
  8022c8:	75 1a                	jne    8022e4 <__umoddi3+0x48>
    {
      if (d0 > n1)
  8022ca:	39 f7                	cmp    %esi,%edi
  8022cc:	0f 86 a2 00 00 00    	jbe    802374 <__umoddi3+0xd8>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8022d2:	89 c8                	mov    %ecx,%eax
  8022d4:	89 f2                	mov    %esi,%edx
  8022d6:	f7 f7                	div    %edi
  8022d8:	89 d0                	mov    %edx,%eax

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8022da:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8022dc:	83 c4 1c             	add    $0x1c,%esp
  8022df:	5b                   	pop    %ebx
  8022e0:	5e                   	pop    %esi
  8022e1:	5f                   	pop    %edi
  8022e2:	5d                   	pop    %ebp
  8022e3:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8022e4:	39 f0                	cmp    %esi,%eax
  8022e6:	0f 87 ac 00 00 00    	ja     802398 <__umoddi3+0xfc>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8022ec:	0f bd e8             	bsr    %eax,%ebp
	  if (bm == 0)
  8022ef:	83 f5 1f             	xor    $0x1f,%ebp
  8022f2:	0f 84 ac 00 00 00    	je     8023a4 <__umoddi3+0x108>
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8022f8:	bf 20 00 00 00       	mov    $0x20,%edi
  8022fd:	29 ef                	sub    %ebp,%edi
  8022ff:	89 fe                	mov    %edi,%esi
  802301:	89 7c 24 0c          	mov    %edi,0xc(%esp)

	      d1 = (d1 << bm) | (d0 >> b);
  802305:	89 e9                	mov    %ebp,%ecx
  802307:	d3 e0                	shl    %cl,%eax
  802309:	89 d7                	mov    %edx,%edi
  80230b:	89 f1                	mov    %esi,%ecx
  80230d:	d3 ef                	shr    %cl,%edi
  80230f:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  802311:	89 e9                	mov    %ebp,%ecx
  802313:	d3 e2                	shl    %cl,%edx
  802315:	89 14 24             	mov    %edx,(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802318:	89 d8                	mov    %ebx,%eax
  80231a:	d3 e0                	shl    %cl,%eax
  80231c:	89 c2                	mov    %eax,%edx
	      n0 = n0 << bm;
  80231e:	8b 44 24 08          	mov    0x8(%esp),%eax
  802322:	d3 e0                	shl    %cl,%eax
  802324:	89 44 24 04          	mov    %eax,0x4(%esp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802328:	8b 44 24 08          	mov    0x8(%esp),%eax
  80232c:	89 f1                	mov    %esi,%ecx
  80232e:	d3 e8                	shr    %cl,%eax
  802330:	09 d0                	or     %edx,%eax
  802332:	d3 eb                	shr    %cl,%ebx
  802334:	89 da                	mov    %ebx,%edx
  802336:	f7 f7                	div    %edi
  802338:	89 d3                	mov    %edx,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  80233a:	f7 24 24             	mull   (%esp)
  80233d:	89 c6                	mov    %eax,%esi
  80233f:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802341:	39 d3                	cmp    %edx,%ebx
  802343:	0f 82 87 00 00 00    	jb     8023d0 <__umoddi3+0x134>
  802349:	0f 84 91 00 00 00    	je     8023e0 <__umoddi3+0x144>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80234f:	8b 54 24 04          	mov    0x4(%esp),%edx
  802353:	29 f2                	sub    %esi,%edx
  802355:	19 cb                	sbb    %ecx,%ebx
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802357:	89 d8                	mov    %ebx,%eax
  802359:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  80235d:	d3 e0                	shl    %cl,%eax
  80235f:	89 e9                	mov    %ebp,%ecx
  802361:	d3 ea                	shr    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802363:	09 d0                	or     %edx,%eax
  802365:	89 e9                	mov    %ebp,%ecx
  802367:	d3 eb                	shr    %cl,%ebx
  802369:	89 da                	mov    %ebx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80236b:	83 c4 1c             	add    $0x1c,%esp
  80236e:	5b                   	pop    %ebx
  80236f:	5e                   	pop    %esi
  802370:	5f                   	pop    %edi
  802371:	5d                   	pop    %ebp
  802372:	c3                   	ret    
  802373:	90                   	nop
  802374:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802376:	85 ff                	test   %edi,%edi
  802378:	75 0b                	jne    802385 <__umoddi3+0xe9>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80237a:	b8 01 00 00 00       	mov    $0x1,%eax
  80237f:	31 d2                	xor    %edx,%edx
  802381:	f7 f7                	div    %edi
  802383:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802385:	89 f0                	mov    %esi,%eax
  802387:	31 d2                	xor    %edx,%edx
  802389:	f7 f5                	div    %ebp
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80238b:	89 c8                	mov    %ecx,%eax
  80238d:	f7 f5                	div    %ebp
  80238f:	89 d0                	mov    %edx,%eax
  802391:	e9 44 ff ff ff       	jmp    8022da <__umoddi3+0x3e>
  802396:	66 90                	xchg   %ax,%ax
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802398:	89 c8                	mov    %ecx,%eax
  80239a:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80239c:	83 c4 1c             	add    $0x1c,%esp
  80239f:	5b                   	pop    %ebx
  8023a0:	5e                   	pop    %esi
  8023a1:	5f                   	pop    %edi
  8023a2:	5d                   	pop    %ebp
  8023a3:	c3                   	ret    

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8023a4:	3b 04 24             	cmp    (%esp),%eax
  8023a7:	72 06                	jb     8023af <__umoddi3+0x113>
  8023a9:	3b 7c 24 04          	cmp    0x4(%esp),%edi
  8023ad:	77 0f                	ja     8023be <__umoddi3+0x122>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8023af:	89 f2                	mov    %esi,%edx
  8023b1:	29 f9                	sub    %edi,%ecx
  8023b3:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  8023b7:	89 14 24             	mov    %edx,(%esp)
  8023ba:	89 4c 24 04          	mov    %ecx,0x4(%esp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8023be:	8b 44 24 04          	mov    0x4(%esp),%eax
  8023c2:	8b 14 24             	mov    (%esp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8023c5:	83 c4 1c             	add    $0x1c,%esp
  8023c8:	5b                   	pop    %ebx
  8023c9:	5e                   	pop    %esi
  8023ca:	5f                   	pop    %edi
  8023cb:	5d                   	pop    %ebp
  8023cc:	c3                   	ret    
  8023cd:	8d 76 00             	lea    0x0(%esi),%esi
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8023d0:	2b 04 24             	sub    (%esp),%eax
  8023d3:	19 fa                	sbb    %edi,%edx
  8023d5:	89 d1                	mov    %edx,%ecx
  8023d7:	89 c6                	mov    %eax,%esi
  8023d9:	e9 71 ff ff ff       	jmp    80234f <__umoddi3+0xb3>
  8023de:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8023e0:	39 44 24 04          	cmp    %eax,0x4(%esp)
  8023e4:	72 ea                	jb     8023d0 <__umoddi3+0x134>
  8023e6:	89 d9                	mov    %ebx,%ecx
  8023e8:	e9 62 ff ff ff       	jmp    80234f <__umoddi3+0xb3>
