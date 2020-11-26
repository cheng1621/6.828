
obj/user/testfile.debug:     file format elf32-i386


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
  80002c:	e8 d4 05 00 00       	call   800605 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <xopen>:

#define FVA ((struct Fd*)0xCCCCC000)

static int
xopen(const char *path, int mode)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
  80003a:	89 d3                	mov    %edx,%ebx
	extern union Fsipc fsipcbuf;
	envid_t fsenv;
	
	strcpy(fsipcbuf.open.req_path, path);
  80003c:	50                   	push   %eax
  80003d:	68 00 50 80 00       	push   $0x805000
  800042:	e8 e4 0c 00 00       	call   800d2b <strcpy>
	fsipcbuf.open.req_omode = mode;
  800047:	89 1d 00 54 80 00    	mov    %ebx,0x805400

	fsenv = ipc_find_env(ENV_TYPE_FS);
  80004d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800054:	e8 07 14 00 00       	call   801460 <ipc_find_env>
	ipc_send(fsenv, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800059:	6a 07                	push   $0x7
  80005b:	68 00 50 80 00       	push   $0x805000
  800060:	6a 01                	push   $0x1
  800062:	50                   	push   %eax
  800063:	e8 99 13 00 00       	call   801401 <ipc_send>
	return ipc_recv(NULL, FVA, NULL);
  800068:	83 c4 1c             	add    $0x1c,%esp
  80006b:	6a 00                	push   $0x0
  80006d:	68 00 c0 cc cc       	push   $0xccccc000
  800072:	6a 00                	push   $0x0
  800074:	e8 13 13 00 00       	call   80138c <ipc_recv>
}
  800079:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80007c:	c9                   	leave  
  80007d:	c3                   	ret    

0080007e <umain>:

void
umain(int argc, char **argv)
{
  80007e:	55                   	push   %ebp
  80007f:	89 e5                	mov    %esp,%ebp
  800081:	57                   	push   %edi
  800082:	56                   	push   %esi
  800083:	53                   	push   %ebx
  800084:	81 ec ac 02 00 00    	sub    $0x2ac,%esp
	struct Fd fdcopy;
	struct Stat st;
	char buf[512];

	// We open files manually first, to avoid the FD layer
	if ((r = xopen("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  80008a:	ba 00 00 00 00       	mov    $0x0,%edx
  80008f:	b8 00 24 80 00       	mov    $0x802400,%eax
  800094:	e8 9a ff ff ff       	call   800033 <xopen>
  800099:	85 c0                	test   %eax,%eax
  80009b:	79 17                	jns    8000b4 <umain+0x36>
  80009d:	83 f8 f5             	cmp    $0xfffffff5,%eax
  8000a0:	74 26                	je     8000c8 <umain+0x4a>
		panic("serve_open /not-found: %e", r);
  8000a2:	50                   	push   %eax
  8000a3:	68 0b 24 80 00       	push   $0x80240b
  8000a8:	6a 20                	push   $0x20
  8000aa:	68 25 24 80 00       	push   $0x802425
  8000af:	e8 ba 05 00 00       	call   80066e <_panic>
	else if (r >= 0)
		panic("serve_open /not-found succeeded!");
  8000b4:	83 ec 04             	sub    $0x4,%esp
  8000b7:	68 c0 25 80 00       	push   $0x8025c0
  8000bc:	6a 22                	push   $0x22
  8000be:	68 25 24 80 00       	push   $0x802425
  8000c3:	e8 a6 05 00 00       	call   80066e <_panic>

	if ((r = xopen("/newmotd", O_RDONLY)) < 0)
  8000c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cd:	b8 35 24 80 00       	mov    $0x802435,%eax
  8000d2:	e8 5c ff ff ff       	call   800033 <xopen>
  8000d7:	85 c0                	test   %eax,%eax
  8000d9:	79 12                	jns    8000ed <umain+0x6f>
		panic("serve_open /newmotd: %e", r);
  8000db:	50                   	push   %eax
  8000dc:	68 3e 24 80 00       	push   $0x80243e
  8000e1:	6a 25                	push   $0x25
  8000e3:	68 25 24 80 00       	push   $0x802425
  8000e8:	e8 81 05 00 00       	call   80066e <_panic>
	if (FVA->fd_dev_id != 'f' || FVA->fd_offset != 0 || FVA->fd_omode != O_RDONLY)
  8000ed:	83 3d 00 c0 cc cc 66 	cmpl   $0x66,0xccccc000
  8000f4:	75 12                	jne    800108 <umain+0x8a>
  8000f6:	83 3d 04 c0 cc cc 00 	cmpl   $0x0,0xccccc004
  8000fd:	75 09                	jne    800108 <umain+0x8a>
  8000ff:	83 3d 08 c0 cc cc 00 	cmpl   $0x0,0xccccc008
  800106:	74 14                	je     80011c <umain+0x9e>
		panic("serve_open did not fill struct Fd correctly\n");
  800108:	83 ec 04             	sub    $0x4,%esp
  80010b:	68 e4 25 80 00       	push   $0x8025e4
  800110:	6a 27                	push   $0x27
  800112:	68 25 24 80 00       	push   $0x802425
  800117:	e8 52 05 00 00       	call   80066e <_panic>
	cprintf("serve_open is good\n");
  80011c:	83 ec 0c             	sub    $0xc,%esp
  80011f:	68 56 24 80 00       	push   $0x802456
  800124:	e8 1d 06 00 00       	call   800746 <cprintf>

	if ((r = devfile.dev_stat(FVA, &st)) < 0)
  800129:	83 c4 08             	add    $0x8,%esp
  80012c:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  800132:	50                   	push   %eax
  800133:	68 00 c0 cc cc       	push   $0xccccc000
  800138:	ff 15 1c 30 80 00    	call   *0x80301c
  80013e:	83 c4 10             	add    $0x10,%esp
  800141:	85 c0                	test   %eax,%eax
  800143:	79 12                	jns    800157 <umain+0xd9>
		panic("file_stat: %e", r);
  800145:	50                   	push   %eax
  800146:	68 6a 24 80 00       	push   $0x80246a
  80014b:	6a 2b                	push   $0x2b
  80014d:	68 25 24 80 00       	push   $0x802425
  800152:	e8 17 05 00 00       	call   80066e <_panic>
	if (strlen(msg) != st.st_size)
  800157:	83 ec 0c             	sub    $0xc,%esp
  80015a:	ff 35 00 30 80 00    	pushl  0x803000
  800160:	e8 6f 0b 00 00       	call   800cd4 <strlen>
  800165:	83 c4 10             	add    $0x10,%esp
  800168:	3b 45 cc             	cmp    -0x34(%ebp),%eax
  80016b:	74 25                	je     800192 <umain+0x114>
		panic("file_stat returned size %d wanted %d\n", st.st_size, strlen(msg));
  80016d:	83 ec 0c             	sub    $0xc,%esp
  800170:	ff 35 00 30 80 00    	pushl  0x803000
  800176:	e8 59 0b 00 00       	call   800cd4 <strlen>
  80017b:	89 04 24             	mov    %eax,(%esp)
  80017e:	ff 75 cc             	pushl  -0x34(%ebp)
  800181:	68 14 26 80 00       	push   $0x802614
  800186:	6a 2d                	push   $0x2d
  800188:	68 25 24 80 00       	push   $0x802425
  80018d:	e8 dc 04 00 00       	call   80066e <_panic>
	cprintf("file_stat is good\n");
  800192:	83 ec 0c             	sub    $0xc,%esp
  800195:	68 78 24 80 00       	push   $0x802478
  80019a:	e8 a7 05 00 00       	call   800746 <cprintf>

	memset(buf, 0, sizeof buf);
  80019f:	83 c4 0c             	add    $0xc,%esp
  8001a2:	68 00 02 00 00       	push   $0x200
  8001a7:	6a 00                	push   $0x0
  8001a9:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  8001af:	53                   	push   %ebx
  8001b0:	e8 f6 0c 00 00       	call   800eab <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  8001b5:	83 c4 0c             	add    $0xc,%esp
  8001b8:	68 00 02 00 00       	push   $0x200
  8001bd:	53                   	push   %ebx
  8001be:	68 00 c0 cc cc       	push   $0xccccc000
  8001c3:	ff 15 10 30 80 00    	call   *0x803010
  8001c9:	83 c4 10             	add    $0x10,%esp
  8001cc:	85 c0                	test   %eax,%eax
  8001ce:	79 12                	jns    8001e2 <umain+0x164>
		panic("file_read: %e", r);
  8001d0:	50                   	push   %eax
  8001d1:	68 8b 24 80 00       	push   $0x80248b
  8001d6:	6a 32                	push   $0x32
  8001d8:	68 25 24 80 00       	push   $0x802425
  8001dd:	e8 8c 04 00 00       	call   80066e <_panic>
	if (strcmp(buf, msg) != 0)
  8001e2:	83 ec 08             	sub    $0x8,%esp
  8001e5:	ff 35 00 30 80 00    	pushl  0x803000
  8001eb:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8001f1:	50                   	push   %eax
  8001f2:	e8 e4 0b 00 00       	call   800ddb <strcmp>
  8001f7:	83 c4 10             	add    $0x10,%esp
  8001fa:	85 c0                	test   %eax,%eax
  8001fc:	74 14                	je     800212 <umain+0x194>
		panic("file_read returned wrong data");
  8001fe:	83 ec 04             	sub    $0x4,%esp
  800201:	68 99 24 80 00       	push   $0x802499
  800206:	6a 34                	push   $0x34
  800208:	68 25 24 80 00       	push   $0x802425
  80020d:	e8 5c 04 00 00       	call   80066e <_panic>
	cprintf("file_read is good\n");
  800212:	83 ec 0c             	sub    $0xc,%esp
  800215:	68 b7 24 80 00       	push   $0x8024b7
  80021a:	e8 27 05 00 00       	call   800746 <cprintf>

	if ((r = devfile.dev_close(FVA)) < 0)
  80021f:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  800226:	ff 15 18 30 80 00    	call   *0x803018
  80022c:	83 c4 10             	add    $0x10,%esp
  80022f:	85 c0                	test   %eax,%eax
  800231:	79 12                	jns    800245 <umain+0x1c7>
		panic("file_close: %e", r);
  800233:	50                   	push   %eax
  800234:	68 ca 24 80 00       	push   $0x8024ca
  800239:	6a 38                	push   $0x38
  80023b:	68 25 24 80 00       	push   $0x802425
  800240:	e8 29 04 00 00       	call   80066e <_panic>
	cprintf("file_close is good\n");
  800245:	83 ec 0c             	sub    $0xc,%esp
  800248:	68 d9 24 80 00       	push   $0x8024d9
  80024d:	e8 f4 04 00 00       	call   800746 <cprintf>

	// We're about to unmap the FD, but still need a way to get
	// the stale filenum to serve_read, so we make a local copy.
	// The file server won't think it's stale until we unmap the
	// FD page.
	fdcopy = *FVA;
  800252:	be 00 c0 cc cc       	mov    $0xccccc000,%esi
  800257:	8d 7d d8             	lea    -0x28(%ebp),%edi
  80025a:	b9 04 00 00 00       	mov    $0x4,%ecx
  80025f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	sys_page_unmap(0, FVA);
  800261:	83 c4 08             	add    $0x8,%esp
  800264:	68 00 c0 cc cc       	push   $0xccccc000
  800269:	6a 00                	push   $0x0
  80026b:	e8 b0 0f 00 00       	call   801220 <sys_page_unmap>

	if ((r = devfile.dev_read(&fdcopy, buf, sizeof buf)) != -E_INVAL)
  800270:	83 c4 0c             	add    $0xc,%esp
  800273:	68 00 02 00 00       	push   $0x200
  800278:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  80027e:	50                   	push   %eax
  80027f:	8d 45 d8             	lea    -0x28(%ebp),%eax
  800282:	50                   	push   %eax
  800283:	ff 15 10 30 80 00    	call   *0x803010
  800289:	83 c4 10             	add    $0x10,%esp
  80028c:	83 f8 fd             	cmp    $0xfffffffd,%eax
  80028f:	74 12                	je     8002a3 <umain+0x225>
		panic("serve_read does not handle stale fileids correctly: %e", r);
  800291:	50                   	push   %eax
  800292:	68 3c 26 80 00       	push   $0x80263c
  800297:	6a 43                	push   $0x43
  800299:	68 25 24 80 00       	push   $0x802425
  80029e:	e8 cb 03 00 00       	call   80066e <_panic>
	cprintf("stale fileid is good\n");
  8002a3:	83 ec 0c             	sub    $0xc,%esp
  8002a6:	68 ed 24 80 00       	push   $0x8024ed
  8002ab:	e8 96 04 00 00       	call   800746 <cprintf>

	// Try writing
	if ((r = xopen("/new-file", O_RDWR|O_CREAT)) < 0)
  8002b0:	ba 02 01 00 00       	mov    $0x102,%edx
  8002b5:	b8 03 25 80 00       	mov    $0x802503,%eax
  8002ba:	e8 74 fd ff ff       	call   800033 <xopen>
  8002bf:	83 c4 10             	add    $0x10,%esp
  8002c2:	85 c0                	test   %eax,%eax
  8002c4:	79 12                	jns    8002d8 <umain+0x25a>
		panic("serve_open /new-file: %e", r);
  8002c6:	50                   	push   %eax
  8002c7:	68 0d 25 80 00       	push   $0x80250d
  8002cc:	6a 48                	push   $0x48
  8002ce:	68 25 24 80 00       	push   $0x802425
  8002d3:	e8 96 03 00 00       	call   80066e <_panic>

	if ((r = devfile.dev_write(FVA, msg, strlen(msg))) != strlen(msg))
  8002d8:	8b 1d 14 30 80 00    	mov    0x803014,%ebx
  8002de:	83 ec 0c             	sub    $0xc,%esp
  8002e1:	ff 35 00 30 80 00    	pushl  0x803000
  8002e7:	e8 e8 09 00 00       	call   800cd4 <strlen>
  8002ec:	83 c4 0c             	add    $0xc,%esp
  8002ef:	50                   	push   %eax
  8002f0:	ff 35 00 30 80 00    	pushl  0x803000
  8002f6:	68 00 c0 cc cc       	push   $0xccccc000
  8002fb:	ff d3                	call   *%ebx
  8002fd:	89 c3                	mov    %eax,%ebx
  8002ff:	83 c4 04             	add    $0x4,%esp
  800302:	ff 35 00 30 80 00    	pushl  0x803000
  800308:	e8 c7 09 00 00       	call   800cd4 <strlen>
  80030d:	83 c4 10             	add    $0x10,%esp
  800310:	39 c3                	cmp    %eax,%ebx
  800312:	74 12                	je     800326 <umain+0x2a8>
		panic("file_write: %e", r);
  800314:	53                   	push   %ebx
  800315:	68 26 25 80 00       	push   $0x802526
  80031a:	6a 4b                	push   $0x4b
  80031c:	68 25 24 80 00       	push   $0x802425
  800321:	e8 48 03 00 00       	call   80066e <_panic>
	cprintf("file_write is good\n");
  800326:	83 ec 0c             	sub    $0xc,%esp
  800329:	68 35 25 80 00       	push   $0x802535
  80032e:	e8 13 04 00 00       	call   800746 <cprintf>

	FVA->fd_offset = 0;
  800333:	c7 05 04 c0 cc cc 00 	movl   $0x0,0xccccc004
  80033a:	00 00 00 
	memset(buf, 0, sizeof buf);
  80033d:	83 c4 0c             	add    $0xc,%esp
  800340:	68 00 02 00 00       	push   $0x200
  800345:	6a 00                	push   $0x0
  800347:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  80034d:	53                   	push   %ebx
  80034e:	e8 58 0b 00 00       	call   800eab <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  800353:	83 c4 0c             	add    $0xc,%esp
  800356:	68 00 02 00 00       	push   $0x200
  80035b:	53                   	push   %ebx
  80035c:	68 00 c0 cc cc       	push   $0xccccc000
  800361:	ff 15 10 30 80 00    	call   *0x803010
  800367:	89 c3                	mov    %eax,%ebx
  800369:	83 c4 10             	add    $0x10,%esp
  80036c:	85 c0                	test   %eax,%eax
  80036e:	79 12                	jns    800382 <umain+0x304>
		panic("file_read after file_write: %e", r);
  800370:	50                   	push   %eax
  800371:	68 74 26 80 00       	push   $0x802674
  800376:	6a 51                	push   $0x51
  800378:	68 25 24 80 00       	push   $0x802425
  80037d:	e8 ec 02 00 00       	call   80066e <_panic>
	if (r != strlen(msg))
  800382:	83 ec 0c             	sub    $0xc,%esp
  800385:	ff 35 00 30 80 00    	pushl  0x803000
  80038b:	e8 44 09 00 00       	call   800cd4 <strlen>
  800390:	83 c4 10             	add    $0x10,%esp
  800393:	39 c3                	cmp    %eax,%ebx
  800395:	74 12                	je     8003a9 <umain+0x32b>
		panic("file_read after file_write returned wrong length: %d", r);
  800397:	53                   	push   %ebx
  800398:	68 94 26 80 00       	push   $0x802694
  80039d:	6a 53                	push   $0x53
  80039f:	68 25 24 80 00       	push   $0x802425
  8003a4:	e8 c5 02 00 00       	call   80066e <_panic>
	if (strcmp(buf, msg) != 0)
  8003a9:	83 ec 08             	sub    $0x8,%esp
  8003ac:	ff 35 00 30 80 00    	pushl  0x803000
  8003b2:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8003b8:	50                   	push   %eax
  8003b9:	e8 1d 0a 00 00       	call   800ddb <strcmp>
  8003be:	83 c4 10             	add    $0x10,%esp
  8003c1:	85 c0                	test   %eax,%eax
  8003c3:	74 14                	je     8003d9 <umain+0x35b>
		panic("file_read after file_write returned wrong data");
  8003c5:	83 ec 04             	sub    $0x4,%esp
  8003c8:	68 cc 26 80 00       	push   $0x8026cc
  8003cd:	6a 55                	push   $0x55
  8003cf:	68 25 24 80 00       	push   $0x802425
  8003d4:	e8 95 02 00 00       	call   80066e <_panic>
	cprintf("file_read after file_write is good\n");
  8003d9:	83 ec 0c             	sub    $0xc,%esp
  8003dc:	68 fc 26 80 00       	push   $0x8026fc
  8003e1:	e8 60 03 00 00       	call   800746 <cprintf>

	// Now we'll try out open
	if ((r = open("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  8003e6:	83 c4 08             	add    $0x8,%esp
  8003e9:	6a 00                	push   $0x0
  8003eb:	68 00 24 80 00       	push   $0x802400
  8003f0:	e8 e3 17 00 00       	call   801bd8 <open>
  8003f5:	83 c4 10             	add    $0x10,%esp
  8003f8:	85 c0                	test   %eax,%eax
  8003fa:	79 17                	jns    800413 <umain+0x395>
  8003fc:	83 f8 f5             	cmp    $0xfffffff5,%eax
  8003ff:	74 26                	je     800427 <umain+0x3a9>
		panic("open /not-found: %e", r);
  800401:	50                   	push   %eax
  800402:	68 11 24 80 00       	push   $0x802411
  800407:	6a 5a                	push   $0x5a
  800409:	68 25 24 80 00       	push   $0x802425
  80040e:	e8 5b 02 00 00       	call   80066e <_panic>
	else if (r >= 0)
		panic("open /not-found succeeded!");
  800413:	83 ec 04             	sub    $0x4,%esp
  800416:	68 49 25 80 00       	push   $0x802549
  80041b:	6a 5c                	push   $0x5c
  80041d:	68 25 24 80 00       	push   $0x802425
  800422:	e8 47 02 00 00       	call   80066e <_panic>

	if ((r = open("/newmotd", O_RDONLY)) < 0)
  800427:	83 ec 08             	sub    $0x8,%esp
  80042a:	6a 00                	push   $0x0
  80042c:	68 35 24 80 00       	push   $0x802435
  800431:	e8 a2 17 00 00       	call   801bd8 <open>
  800436:	83 c4 10             	add    $0x10,%esp
  800439:	85 c0                	test   %eax,%eax
  80043b:	79 12                	jns    80044f <umain+0x3d1>
		panic("open /newmotd: %e", r);
  80043d:	50                   	push   %eax
  80043e:	68 44 24 80 00       	push   $0x802444
  800443:	6a 5f                	push   $0x5f
  800445:	68 25 24 80 00       	push   $0x802425
  80044a:	e8 1f 02 00 00       	call   80066e <_panic>
	fd = (struct Fd*) (0xD0000000 + r*PGSIZE);
  80044f:	c1 e0 0c             	shl    $0xc,%eax
	if (fd->fd_dev_id != 'f' || fd->fd_offset != 0 || fd->fd_omode != O_RDONLY)
  800452:	83 b8 00 00 00 d0 66 	cmpl   $0x66,-0x30000000(%eax)
  800459:	75 12                	jne    80046d <umain+0x3ef>
  80045b:	83 b8 04 00 00 d0 00 	cmpl   $0x0,-0x2ffffffc(%eax)
  800462:	75 09                	jne    80046d <umain+0x3ef>
  800464:	83 b8 08 00 00 d0 00 	cmpl   $0x0,-0x2ffffff8(%eax)
  80046b:	74 14                	je     800481 <umain+0x403>
		panic("open did not fill struct Fd correctly\n");
  80046d:	83 ec 04             	sub    $0x4,%esp
  800470:	68 20 27 80 00       	push   $0x802720
  800475:	6a 62                	push   $0x62
  800477:	68 25 24 80 00       	push   $0x802425
  80047c:	e8 ed 01 00 00       	call   80066e <_panic>
	cprintf("open is good\n");
  800481:	83 ec 0c             	sub    $0xc,%esp
  800484:	68 5c 24 80 00       	push   $0x80245c
  800489:	e8 b8 02 00 00       	call   800746 <cprintf>

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
  80048e:	83 c4 08             	add    $0x8,%esp
  800491:	68 01 01 00 00       	push   $0x101
  800496:	68 64 25 80 00       	push   $0x802564
  80049b:	e8 38 17 00 00       	call   801bd8 <open>
  8004a0:	89 c6                	mov    %eax,%esi
  8004a2:	83 c4 10             	add    $0x10,%esp
  8004a5:	85 c0                	test   %eax,%eax
  8004a7:	79 12                	jns    8004bb <umain+0x43d>
		panic("creat /big: %e", f);
  8004a9:	50                   	push   %eax
  8004aa:	68 69 25 80 00       	push   $0x802569
  8004af:	6a 67                	push   $0x67
  8004b1:	68 25 24 80 00       	push   $0x802425
  8004b6:	e8 b3 01 00 00       	call   80066e <_panic>
	memset(buf, 0, sizeof(buf));
  8004bb:	83 ec 04             	sub    $0x4,%esp
  8004be:	68 00 02 00 00       	push   $0x200
  8004c3:	6a 00                	push   $0x0
  8004c5:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8004cb:	50                   	push   %eax
  8004cc:	e8 da 09 00 00       	call   800eab <memset>
  8004d1:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  8004d4:	bb 00 00 00 00       	mov    $0x0,%ebx
		*(int*)buf = i;
		if ((r = write(f, buf, sizeof(buf))) < 0)
  8004d9:	8d bd 4c fd ff ff    	lea    -0x2b4(%ebp),%edi
	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
		panic("creat /big: %e", f);
	memset(buf, 0, sizeof(buf));
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
  8004df:	89 9d 4c fd ff ff    	mov    %ebx,-0x2b4(%ebp)
		if ((r = write(f, buf, sizeof(buf))) < 0)
  8004e5:	83 ec 04             	sub    $0x4,%esp
  8004e8:	68 00 02 00 00       	push   $0x200
  8004ed:	57                   	push   %edi
  8004ee:	56                   	push   %esi
  8004ef:	e8 bf 13 00 00       	call   8018b3 <write>
  8004f4:	83 c4 10             	add    $0x10,%esp
  8004f7:	85 c0                	test   %eax,%eax
  8004f9:	79 16                	jns    800511 <umain+0x493>
			panic("write /big@%d: %e", i, r);
  8004fb:	83 ec 0c             	sub    $0xc,%esp
  8004fe:	50                   	push   %eax
  8004ff:	53                   	push   %ebx
  800500:	68 78 25 80 00       	push   $0x802578
  800505:	6a 6c                	push   $0x6c
  800507:	68 25 24 80 00       	push   $0x802425
  80050c:	e8 5d 01 00 00       	call   80066e <_panic>
  800511:	8d 83 00 02 00 00    	lea    0x200(%ebx),%eax
  800517:	89 c3                	mov    %eax,%ebx

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
		panic("creat /big: %e", f);
	memset(buf, 0, sizeof(buf));
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  800519:	3d 00 e0 01 00       	cmp    $0x1e000,%eax
  80051e:	75 bf                	jne    8004df <umain+0x461>
		*(int*)buf = i;
		if ((r = write(f, buf, sizeof(buf))) < 0)
			panic("write /big@%d: %e", i, r);
	}
	close(f);
  800520:	83 ec 0c             	sub    $0xc,%esp
  800523:	56                   	push   %esi
  800524:	e8 76 11 00 00       	call   80169f <close>

	if ((f = open("/big", O_RDONLY)) < 0)
  800529:	83 c4 08             	add    $0x8,%esp
  80052c:	6a 00                	push   $0x0
  80052e:	68 64 25 80 00       	push   $0x802564
  800533:	e8 a0 16 00 00       	call   801bd8 <open>
  800538:	89 c6                	mov    %eax,%esi
  80053a:	83 c4 10             	add    $0x10,%esp
  80053d:	85 c0                	test   %eax,%eax
  80053f:	79 12                	jns    800553 <umain+0x4d5>
		panic("open /big: %e", f);
  800541:	50                   	push   %eax
  800542:	68 8a 25 80 00       	push   $0x80258a
  800547:	6a 71                	push   $0x71
  800549:	68 25 24 80 00       	push   $0x802425
  80054e:	e8 1b 01 00 00       	call   80066e <_panic>
  800553:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  800558:	8d bd 4c fd ff ff    	lea    -0x2b4(%ebp),%edi
	close(f);

	if ((f = open("/big", O_RDONLY)) < 0)
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
  80055e:	89 9d 4c fd ff ff    	mov    %ebx,-0x2b4(%ebp)
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  800564:	83 ec 04             	sub    $0x4,%esp
  800567:	68 00 02 00 00       	push   $0x200
  80056c:	57                   	push   %edi
  80056d:	56                   	push   %esi
  80056e:	e8 eb 12 00 00       	call   80185e <readn>
  800573:	83 c4 10             	add    $0x10,%esp
  800576:	85 c0                	test   %eax,%eax
  800578:	79 16                	jns    800590 <umain+0x512>
			panic("read /big@%d: %e", i, r);
  80057a:	83 ec 0c             	sub    $0xc,%esp
  80057d:	50                   	push   %eax
  80057e:	53                   	push   %ebx
  80057f:	68 98 25 80 00       	push   $0x802598
  800584:	6a 75                	push   $0x75
  800586:	68 25 24 80 00       	push   $0x802425
  80058b:	e8 de 00 00 00       	call   80066e <_panic>
		if (r != sizeof(buf))
  800590:	3d 00 02 00 00       	cmp    $0x200,%eax
  800595:	74 1b                	je     8005b2 <umain+0x534>
			panic("read /big from %d returned %d < %d bytes",
  800597:	83 ec 08             	sub    $0x8,%esp
  80059a:	68 00 02 00 00       	push   $0x200
  80059f:	50                   	push   %eax
  8005a0:	53                   	push   %ebx
  8005a1:	68 48 27 80 00       	push   $0x802748
  8005a6:	6a 78                	push   $0x78
  8005a8:	68 25 24 80 00       	push   $0x802425
  8005ad:	e8 bc 00 00 00       	call   80066e <_panic>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
  8005b2:	8b 85 4c fd ff ff    	mov    -0x2b4(%ebp),%eax
  8005b8:	39 d8                	cmp    %ebx,%eax
  8005ba:	74 16                	je     8005d2 <umain+0x554>
			panic("read /big from %d returned bad data %d",
  8005bc:	83 ec 0c             	sub    $0xc,%esp
  8005bf:	50                   	push   %eax
  8005c0:	53                   	push   %ebx
  8005c1:	68 74 27 80 00       	push   $0x802774
  8005c6:	6a 7b                	push   $0x7b
  8005c8:	68 25 24 80 00       	push   $0x802425
  8005cd:	e8 9c 00 00 00       	call   80066e <_panic>
  8005d2:	8d 83 00 02 00 00    	lea    0x200(%ebx),%eax
  8005d8:	89 c3                	mov    %eax,%ebx
	}
	close(f);

	if ((f = open("/big", O_RDONLY)) < 0)
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  8005da:	3d 00 e0 01 00       	cmp    $0x1e000,%eax
  8005df:	0f 85 79 ff ff ff    	jne    80055e <umain+0x4e0>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
			panic("read /big from %d returned bad data %d",
			      i, *(int*)buf);
	}
	close(f);
  8005e5:	83 ec 0c             	sub    $0xc,%esp
  8005e8:	56                   	push   %esi
  8005e9:	e8 b1 10 00 00       	call   80169f <close>
	cprintf("large file is good\n");
  8005ee:	c7 04 24 a9 25 80 00 	movl   $0x8025a9,(%esp)
  8005f5:	e8 4c 01 00 00       	call   800746 <cprintf>
}
  8005fa:	83 c4 10             	add    $0x10,%esp
  8005fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800600:	5b                   	pop    %ebx
  800601:	5e                   	pop    %esi
  800602:	5f                   	pop    %edi
  800603:	5d                   	pop    %ebp
  800604:	c3                   	ret    

00800605 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800605:	55                   	push   %ebp
  800606:	89 e5                	mov    %esp,%ebp
  800608:	56                   	push   %esi
  800609:	53                   	push   %ebx
  80060a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80060d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800610:	e8 48 0b 00 00       	call   80115d <sys_getenvid>
  800615:	25 ff 03 00 00       	and    $0x3ff,%eax
  80061a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800621:	c1 e0 07             	shl    $0x7,%eax
  800624:	29 d0                	sub    %edx,%eax
  800626:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80062b:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800630:	85 db                	test   %ebx,%ebx
  800632:	7e 07                	jle    80063b <libmain+0x36>
		binaryname = argv[0];
  800634:	8b 06                	mov    (%esi),%eax
  800636:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  80063b:	83 ec 08             	sub    $0x8,%esp
  80063e:	56                   	push   %esi
  80063f:	53                   	push   %ebx
  800640:	e8 39 fa ff ff       	call   80007e <umain>

	// exit gracefully
	exit();
  800645:	e8 0a 00 00 00       	call   800654 <exit>
}
  80064a:	83 c4 10             	add    $0x10,%esp
  80064d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800650:	5b                   	pop    %ebx
  800651:	5e                   	pop    %esi
  800652:	5d                   	pop    %ebp
  800653:	c3                   	ret    

00800654 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800654:	55                   	push   %ebp
  800655:	89 e5                	mov    %esp,%ebp
  800657:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80065a:	e8 6b 10 00 00       	call   8016ca <close_all>
	sys_env_destroy(0);
  80065f:	83 ec 0c             	sub    $0xc,%esp
  800662:	6a 00                	push   $0x0
  800664:	e8 b3 0a 00 00       	call   80111c <sys_env_destroy>
}
  800669:	83 c4 10             	add    $0x10,%esp
  80066c:	c9                   	leave  
  80066d:	c3                   	ret    

0080066e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80066e:	55                   	push   %ebp
  80066f:	89 e5                	mov    %esp,%ebp
  800671:	56                   	push   %esi
  800672:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800673:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800676:	8b 35 04 30 80 00    	mov    0x803004,%esi
  80067c:	e8 dc 0a 00 00       	call   80115d <sys_getenvid>
  800681:	83 ec 0c             	sub    $0xc,%esp
  800684:	ff 75 0c             	pushl  0xc(%ebp)
  800687:	ff 75 08             	pushl  0x8(%ebp)
  80068a:	56                   	push   %esi
  80068b:	50                   	push   %eax
  80068c:	68 cc 27 80 00       	push   $0x8027cc
  800691:	e8 b0 00 00 00       	call   800746 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800696:	83 c4 18             	add    $0x18,%esp
  800699:	53                   	push   %ebx
  80069a:	ff 75 10             	pushl  0x10(%ebp)
  80069d:	e8 53 00 00 00       	call   8006f5 <vcprintf>
	cprintf("\n");
  8006a2:	c7 04 24 10 2c 80 00 	movl   $0x802c10,(%esp)
  8006a9:	e8 98 00 00 00       	call   800746 <cprintf>
  8006ae:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8006b1:	cc                   	int3   
  8006b2:	eb fd                	jmp    8006b1 <_panic+0x43>

008006b4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8006b4:	55                   	push   %ebp
  8006b5:	89 e5                	mov    %esp,%ebp
  8006b7:	53                   	push   %ebx
  8006b8:	83 ec 04             	sub    $0x4,%esp
  8006bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8006be:	8b 13                	mov    (%ebx),%edx
  8006c0:	8d 42 01             	lea    0x1(%edx),%eax
  8006c3:	89 03                	mov    %eax,(%ebx)
  8006c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006c8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8006cc:	3d ff 00 00 00       	cmp    $0xff,%eax
  8006d1:	75 1a                	jne    8006ed <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8006d3:	83 ec 08             	sub    $0x8,%esp
  8006d6:	68 ff 00 00 00       	push   $0xff
  8006db:	8d 43 08             	lea    0x8(%ebx),%eax
  8006de:	50                   	push   %eax
  8006df:	e8 fb 09 00 00       	call   8010df <sys_cputs>
		b->idx = 0;
  8006e4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8006ea:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8006ed:	ff 43 04             	incl   0x4(%ebx)
}
  8006f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006f3:	c9                   	leave  
  8006f4:	c3                   	ret    

008006f5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8006f5:	55                   	push   %ebp
  8006f6:	89 e5                	mov    %esp,%ebp
  8006f8:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8006fe:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800705:	00 00 00 
	b.cnt = 0;
  800708:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80070f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800712:	ff 75 0c             	pushl  0xc(%ebp)
  800715:	ff 75 08             	pushl  0x8(%ebp)
  800718:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80071e:	50                   	push   %eax
  80071f:	68 b4 06 80 00       	push   $0x8006b4
  800724:	e8 54 01 00 00       	call   80087d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800729:	83 c4 08             	add    $0x8,%esp
  80072c:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800732:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800738:	50                   	push   %eax
  800739:	e8 a1 09 00 00       	call   8010df <sys_cputs>

	return b.cnt;
}
  80073e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800744:	c9                   	leave  
  800745:	c3                   	ret    

00800746 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800746:	55                   	push   %ebp
  800747:	89 e5                	mov    %esp,%ebp
  800749:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80074c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80074f:	50                   	push   %eax
  800750:	ff 75 08             	pushl  0x8(%ebp)
  800753:	e8 9d ff ff ff       	call   8006f5 <vcprintf>
	va_end(ap);

	return cnt;
}
  800758:	c9                   	leave  
  800759:	c3                   	ret    

0080075a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80075a:	55                   	push   %ebp
  80075b:	89 e5                	mov    %esp,%ebp
  80075d:	57                   	push   %edi
  80075e:	56                   	push   %esi
  80075f:	53                   	push   %ebx
  800760:	83 ec 1c             	sub    $0x1c,%esp
  800763:	89 c6                	mov    %eax,%esi
  800765:	89 d7                	mov    %edx,%edi
  800767:	8b 45 08             	mov    0x8(%ebp),%eax
  80076a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80076d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800770:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800773:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800776:	bb 00 00 00 00       	mov    $0x0,%ebx
  80077b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80077e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800781:	39 d3                	cmp    %edx,%ebx
  800783:	72 11                	jb     800796 <printnum+0x3c>
  800785:	39 45 10             	cmp    %eax,0x10(%ebp)
  800788:	76 0c                	jbe    800796 <printnum+0x3c>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80078a:	8b 45 14             	mov    0x14(%ebp),%eax
  80078d:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800790:	85 db                	test   %ebx,%ebx
  800792:	7f 37                	jg     8007cb <printnum+0x71>
  800794:	eb 44                	jmp    8007da <printnum+0x80>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800796:	83 ec 0c             	sub    $0xc,%esp
  800799:	ff 75 18             	pushl  0x18(%ebp)
  80079c:	8b 45 14             	mov    0x14(%ebp),%eax
  80079f:	48                   	dec    %eax
  8007a0:	50                   	push   %eax
  8007a1:	ff 75 10             	pushl  0x10(%ebp)
  8007a4:	83 ec 08             	sub    $0x8,%esp
  8007a7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007aa:	ff 75 e0             	pushl  -0x20(%ebp)
  8007ad:	ff 75 dc             	pushl  -0x24(%ebp)
  8007b0:	ff 75 d8             	pushl  -0x28(%ebp)
  8007b3:	e8 e0 19 00 00       	call   802198 <__udivdi3>
  8007b8:	83 c4 18             	add    $0x18,%esp
  8007bb:	52                   	push   %edx
  8007bc:	50                   	push   %eax
  8007bd:	89 fa                	mov    %edi,%edx
  8007bf:	89 f0                	mov    %esi,%eax
  8007c1:	e8 94 ff ff ff       	call   80075a <printnum>
  8007c6:	83 c4 20             	add    $0x20,%esp
  8007c9:	eb 0f                	jmp    8007da <printnum+0x80>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8007cb:	83 ec 08             	sub    $0x8,%esp
  8007ce:	57                   	push   %edi
  8007cf:	ff 75 18             	pushl  0x18(%ebp)
  8007d2:	ff d6                	call   *%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8007d4:	83 c4 10             	add    $0x10,%esp
  8007d7:	4b                   	dec    %ebx
  8007d8:	75 f1                	jne    8007cb <printnum+0x71>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8007da:	83 ec 08             	sub    $0x8,%esp
  8007dd:	57                   	push   %edi
  8007de:	83 ec 04             	sub    $0x4,%esp
  8007e1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007e4:	ff 75 e0             	pushl  -0x20(%ebp)
  8007e7:	ff 75 dc             	pushl  -0x24(%ebp)
  8007ea:	ff 75 d8             	pushl  -0x28(%ebp)
  8007ed:	e8 b6 1a 00 00       	call   8022a8 <__umoddi3>
  8007f2:	83 c4 14             	add    $0x14,%esp
  8007f5:	0f be 80 ef 27 80 00 	movsbl 0x8027ef(%eax),%eax
  8007fc:	50                   	push   %eax
  8007fd:	ff d6                	call   *%esi
}
  8007ff:	83 c4 10             	add    $0x10,%esp
  800802:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800805:	5b                   	pop    %ebx
  800806:	5e                   	pop    %esi
  800807:	5f                   	pop    %edi
  800808:	5d                   	pop    %ebp
  800809:	c3                   	ret    

0080080a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80080a:	55                   	push   %ebp
  80080b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80080d:	83 fa 01             	cmp    $0x1,%edx
  800810:	7e 0e                	jle    800820 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800812:	8b 10                	mov    (%eax),%edx
  800814:	8d 4a 08             	lea    0x8(%edx),%ecx
  800817:	89 08                	mov    %ecx,(%eax)
  800819:	8b 02                	mov    (%edx),%eax
  80081b:	8b 52 04             	mov    0x4(%edx),%edx
  80081e:	eb 22                	jmp    800842 <getuint+0x38>
	else if (lflag)
  800820:	85 d2                	test   %edx,%edx
  800822:	74 10                	je     800834 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800824:	8b 10                	mov    (%eax),%edx
  800826:	8d 4a 04             	lea    0x4(%edx),%ecx
  800829:	89 08                	mov    %ecx,(%eax)
  80082b:	8b 02                	mov    (%edx),%eax
  80082d:	ba 00 00 00 00       	mov    $0x0,%edx
  800832:	eb 0e                	jmp    800842 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800834:	8b 10                	mov    (%eax),%edx
  800836:	8d 4a 04             	lea    0x4(%edx),%ecx
  800839:	89 08                	mov    %ecx,(%eax)
  80083b:	8b 02                	mov    (%edx),%eax
  80083d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800842:	5d                   	pop    %ebp
  800843:	c3                   	ret    

00800844 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800844:	55                   	push   %ebp
  800845:	89 e5                	mov    %esp,%ebp
  800847:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80084a:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80084d:	8b 10                	mov    (%eax),%edx
  80084f:	3b 50 04             	cmp    0x4(%eax),%edx
  800852:	73 0a                	jae    80085e <sprintputch+0x1a>
		*b->buf++ = ch;
  800854:	8d 4a 01             	lea    0x1(%edx),%ecx
  800857:	89 08                	mov    %ecx,(%eax)
  800859:	8b 45 08             	mov    0x8(%ebp),%eax
  80085c:	88 02                	mov    %al,(%edx)
}
  80085e:	5d                   	pop    %ebp
  80085f:	c3                   	ret    

00800860 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800866:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800869:	50                   	push   %eax
  80086a:	ff 75 10             	pushl  0x10(%ebp)
  80086d:	ff 75 0c             	pushl  0xc(%ebp)
  800870:	ff 75 08             	pushl  0x8(%ebp)
  800873:	e8 05 00 00 00       	call   80087d <vprintfmt>
	va_end(ap);
}
  800878:	83 c4 10             	add    $0x10,%esp
  80087b:	c9                   	leave  
  80087c:	c3                   	ret    

0080087d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80087d:	55                   	push   %ebp
  80087e:	89 e5                	mov    %esp,%ebp
  800880:	57                   	push   %edi
  800881:	56                   	push   %esi
  800882:	53                   	push   %ebx
  800883:	83 ec 2c             	sub    $0x2c,%esp
  800886:	8b 7d 08             	mov    0x8(%ebp),%edi
  800889:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80088c:	eb 03                	jmp    800891 <vprintfmt+0x14>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  80088e:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  800891:	8b 45 10             	mov    0x10(%ebp),%eax
  800894:	8d 70 01             	lea    0x1(%eax),%esi
  800897:	0f b6 00             	movzbl (%eax),%eax
  80089a:	83 f8 25             	cmp    $0x25,%eax
  80089d:	74 25                	je     8008c4 <vprintfmt+0x47>
			if (ch == '\0')									//当然中间如果遇到'\0'，代表这个字符串的访问结束
  80089f:	85 c0                	test   %eax,%eax
  8008a1:	75 0d                	jne    8008b0 <vprintfmt+0x33>
  8008a3:	e9 b5 03 00 00       	jmp    800c5d <vprintfmt+0x3e0>
  8008a8:	85 c0                	test   %eax,%eax
  8008aa:	0f 84 ad 03 00 00    	je     800c5d <vprintfmt+0x3e0>
				return;
			putch(ch, putdat);								//调用putch函数，把一个字符ch输出到putdat指针所指向的地址中所存放的值对应的地址处
  8008b0:	83 ec 08             	sub    $0x8,%esp
  8008b3:	53                   	push   %ebx
  8008b4:	50                   	push   %eax
  8008b5:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {    //遍历输入的第一个参数，即输出信息的格式，先把格式字符串中'%'之前的字符一个个输出，因为它们前面没有'%'，所以它们就是要直接显示在屏幕上的
  8008b7:	46                   	inc    %esi
  8008b8:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  8008bc:	83 c4 10             	add    $0x10,%esp
  8008bf:	83 f8 25             	cmp    $0x25,%eax
  8008c2:	75 e4                	jne    8008a8 <vprintfmt+0x2b>
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  8008c4:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  8008c8:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8008cf:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8008d6:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8008dd:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8008e4:	eb 07                	jmp    8008ed <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8008e6:	8b 75 10             	mov    0x10(%ebp),%esi

		// flag to pad on the right
		case '-':											//%后面的'-'代表要进行左对齐输出，右边填空格，如果省略代表右对齐
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
  8008e9:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  8008ed:	8d 46 01             	lea    0x1(%esi),%eax
  8008f0:	89 45 10             	mov    %eax,0x10(%ebp)
  8008f3:	0f b6 16             	movzbl (%esi),%edx
  8008f6:	8a 06                	mov    (%esi),%al
  8008f8:	83 e8 23             	sub    $0x23,%eax
  8008fb:	3c 55                	cmp    $0x55,%al
  8008fd:	0f 87 03 03 00 00    	ja     800c06 <vprintfmt+0x389>
  800903:	0f b6 c0             	movzbl %al,%eax
  800906:	ff 24 85 40 29 80 00 	jmp    *0x802940(,%eax,4)
  80090d:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';										//如果有这个字符代表左对齐，则把对齐方式标志位变为'-'
			goto reswitch;									//处理下一个字符

		// flag to pad with 0's instead of spaces
		case '0':											//0--有0表示进行对齐输出时填0,如省略表示填入空格，并且如果为0，则一定是右对齐
			padc = '0';										//对其方式标志位变为0
  800910:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
  800914:	eb d7                	jmp    8008ed <vprintfmt+0x70>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
				precision = precision * 10 + ch - '0';
  800916:	8d 42 d0             	lea    -0x30(%edx),%eax
  800919:	89 c1                	mov    %eax,%ecx
  80091b:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  80091e:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800922:	8d 50 d0             	lea    -0x30(%eax),%edx
  800925:	83 fa 09             	cmp    $0x9,%edx
  800928:	77 51                	ja     80097b <vprintfmt+0xfe>
  80092a:	8b 75 10             	mov    0x10(%ebp),%esi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {					//把遇到的位数字符串转换为真实的位数，比如输入的'%40'，代表有效位数为40位，下面的循环就是把precesion的值设置为40
  80092d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  80092e:	8d 14 89             	lea    (%ecx,%ecx,4),%edx
  800931:	01 d2                	add    %edx,%edx
  800933:	8d 4c 10 d0          	lea    -0x30(%eax,%edx,1),%ecx
				ch = *fmt;
  800937:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80093a:	8d 50 d0             	lea    -0x30(%eax),%edx
  80093d:	83 fa 09             	cmp    $0x9,%edx
  800940:	76 eb                	jbe    80092d <vprintfmt+0xb0>
  800942:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800945:	eb 37                	jmp    80097e <vprintfmt+0x101>
					break;
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
  800947:	8b 45 14             	mov    0x14(%ebp),%eax
  80094a:	8d 50 04             	lea    0x4(%eax),%edx
  80094d:	89 55 14             	mov    %edx,0x14(%ebp)
  800950:	8b 00                	mov    (%eax),%eax
  800952:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800955:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;							//跳转到process_precistion子过程

		case '*':											//*--代表有效数字的位数也是由输入参数指定的，比如printf("%*.*f", 10, 2, n)，其中10,2就是用来指定显示的有效数字位数的
			precision = va_arg(ap, int);
			goto process_precision;
  800958:	eb 24                	jmp    80097e <vprintfmt+0x101>
  80095a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80095e:	79 07                	jns    800967 <vprintfmt+0xea>
  800960:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  800967:	8b 75 10             	mov    0x10(%ebp),%esi
  80096a:	eb 81                	jmp    8008ed <vprintfmt+0x70>
  80096c:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)									//代表有小数点，但是小数点前面并没有数字，比如'%.6f'这种情况，此时代表整数部分全部显示
				width = 0;			
			goto reswitch;

		case '#':
			altflag = 1;
  80096f:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800976:	e9 72 ff ff ff       	jmp    8008ed <vprintfmt+0x70>
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80097b:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:									//处理输出精度，把width字段赋值为刚刚计算出来的precision值，所以width应该是整数部分的有效数字位数
			if (width < 0)
  80097e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800982:	0f 89 65 ff ff ff    	jns    8008ed <vprintfmt+0x70>
				width = precision, precision = -1;
  800988:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80098b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80098e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800995:	e9 53 ff ff ff       	jmp    8008ed <vprintfmt+0x70>
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
  80099a:	ff 45 d4             	incl   -0x2c(%ebp)
		width = -1;											//整数部分有效数字位数
		precision = -1;										//小数部分有效数字位数
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {			//根据位于'%'后面的第一个字符进行分情况处理
  80099d:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)				
		case 'l':											//如果遇到'l'，代表应该是输入long类型，如果有两个'l'代表long long
			lflag++;										//此时把lflag++
			goto reswitch;
  8009a0:	e9 48 ff ff ff       	jmp    8008ed <vprintfmt+0x70>

		// character
		case 'c':											//如果是'c'代表显示一个字符
			putch(va_arg(ap, int), putdat);					//调用输出一个字符到内存的函数putch
  8009a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a8:	8d 50 04             	lea    0x4(%eax),%edx
  8009ab:	89 55 14             	mov    %edx,0x14(%ebp)
  8009ae:	83 ec 08             	sub    $0x8,%esp
  8009b1:	53                   	push   %ebx
  8009b2:	ff 30                	pushl  (%eax)
  8009b4:	ff d7                	call   *%edi
			break;
  8009b6:	83 c4 10             	add    $0x10,%esp
  8009b9:	e9 d3 fe ff ff       	jmp    800891 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8009be:	8b 45 14             	mov    0x14(%ebp),%eax
  8009c1:	8d 50 04             	lea    0x4(%eax),%edx
  8009c4:	89 55 14             	mov    %edx,0x14(%ebp)
  8009c7:	8b 00                	mov    (%eax),%eax
  8009c9:	85 c0                	test   %eax,%eax
  8009cb:	79 02                	jns    8009cf <vprintfmt+0x152>
  8009cd:	f7 d8                	neg    %eax
  8009cf:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8009d1:	83 f8 0f             	cmp    $0xf,%eax
  8009d4:	7f 0b                	jg     8009e1 <vprintfmt+0x164>
  8009d6:	8b 04 85 a0 2a 80 00 	mov    0x802aa0(,%eax,4),%eax
  8009dd:	85 c0                	test   %eax,%eax
  8009df:	75 15                	jne    8009f6 <vprintfmt+0x179>
				printfmt(putch, putdat, "error %d", err);
  8009e1:	52                   	push   %edx
  8009e2:	68 07 28 80 00       	push   $0x802807
  8009e7:	53                   	push   %ebx
  8009e8:	57                   	push   %edi
  8009e9:	e8 72 fe ff ff       	call   800860 <printfmt>
  8009ee:	83 c4 10             	add    $0x10,%esp
  8009f1:	e9 9b fe ff ff       	jmp    800891 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  8009f6:	50                   	push   %eax
  8009f7:	68 de 2b 80 00       	push   $0x802bde
  8009fc:	53                   	push   %ebx
  8009fd:	57                   	push   %edi
  8009fe:	e8 5d fe ff ff       	call   800860 <printfmt>
  800a03:	83 c4 10             	add    $0x10,%esp
  800a06:	e9 86 fe ff ff       	jmp    800891 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800a0b:	8b 45 14             	mov    0x14(%ebp),%eax
  800a0e:	8d 50 04             	lea    0x4(%eax),%edx
  800a11:	89 55 14             	mov    %edx,0x14(%ebp)
  800a14:	8b 00                	mov    (%eax),%eax
  800a16:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800a19:	85 c0                	test   %eax,%eax
  800a1b:	75 07                	jne    800a24 <vprintfmt+0x1a7>
				p = "(null)";
  800a1d:	c7 45 d4 00 28 80 00 	movl   $0x802800,-0x2c(%ebp)
			if (width > 0 && padc != '-')
  800a24:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800a27:	85 f6                	test   %esi,%esi
  800a29:	0f 8e fb 01 00 00    	jle    800c2a <vprintfmt+0x3ad>
  800a2f:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  800a33:	0f 84 09 02 00 00    	je     800c42 <vprintfmt+0x3c5>
				for (width -= strnlen(p, precision); width > 0; width--)
  800a39:	83 ec 08             	sub    $0x8,%esp
  800a3c:	ff 75 d0             	pushl  -0x30(%ebp)
  800a3f:	ff 75 d4             	pushl  -0x2c(%ebp)
  800a42:	e8 ad 02 00 00       	call   800cf4 <strnlen>
  800a47:	89 f1                	mov    %esi,%ecx
  800a49:	29 c1                	sub    %eax,%ecx
  800a4b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800a4e:	83 c4 10             	add    $0x10,%esp
  800a51:	85 c9                	test   %ecx,%ecx
  800a53:	0f 8e d1 01 00 00    	jle    800c2a <vprintfmt+0x3ad>
					putch(padc, putdat);
  800a59:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800a5d:	83 ec 08             	sub    $0x8,%esp
  800a60:	53                   	push   %ebx
  800a61:	56                   	push   %esi
  800a62:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a64:	83 c4 10             	add    $0x10,%esp
  800a67:	ff 4d e4             	decl   -0x1c(%ebp)
  800a6a:	75 f1                	jne    800a5d <vprintfmt+0x1e0>
  800a6c:	e9 b9 01 00 00       	jmp    800c2a <vprintfmt+0x3ad>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a71:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800a75:	74 19                	je     800a90 <vprintfmt+0x213>
  800a77:	0f be c0             	movsbl %al,%eax
  800a7a:	83 e8 20             	sub    $0x20,%eax
  800a7d:	83 f8 5e             	cmp    $0x5e,%eax
  800a80:	76 0e                	jbe    800a90 <vprintfmt+0x213>
					putch('?', putdat);
  800a82:	83 ec 08             	sub    $0x8,%esp
  800a85:	53                   	push   %ebx
  800a86:	6a 3f                	push   $0x3f
  800a88:	ff 55 08             	call   *0x8(%ebp)
  800a8b:	83 c4 10             	add    $0x10,%esp
  800a8e:	eb 0b                	jmp    800a9b <vprintfmt+0x21e>
				else
					putch(ch, putdat);
  800a90:	83 ec 08             	sub    $0x8,%esp
  800a93:	53                   	push   %ebx
  800a94:	52                   	push   %edx
  800a95:	ff 55 08             	call   *0x8(%ebp)
  800a98:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a9b:	ff 4d e4             	decl   -0x1c(%ebp)
  800a9e:	46                   	inc    %esi
  800a9f:	8a 46 ff             	mov    -0x1(%esi),%al
  800aa2:	0f be d0             	movsbl %al,%edx
  800aa5:	85 d2                	test   %edx,%edx
  800aa7:	75 1c                	jne    800ac5 <vprintfmt+0x248>
  800aa9:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800aac:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ab0:	7f 1f                	jg     800ad1 <vprintfmt+0x254>
  800ab2:	e9 da fd ff ff       	jmp    800891 <vprintfmt+0x14>
  800ab7:	89 7d 08             	mov    %edi,0x8(%ebp)
  800aba:	8b 7d d0             	mov    -0x30(%ebp),%edi
  800abd:	eb 06                	jmp    800ac5 <vprintfmt+0x248>
  800abf:	89 7d 08             	mov    %edi,0x8(%ebp)
  800ac2:	8b 7d d0             	mov    -0x30(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800ac5:	85 ff                	test   %edi,%edi
  800ac7:	78 a8                	js     800a71 <vprintfmt+0x1f4>
  800ac9:	4f                   	dec    %edi
  800aca:	79 a5                	jns    800a71 <vprintfmt+0x1f4>
  800acc:	8b 7d 08             	mov    0x8(%ebp),%edi
  800acf:	eb db                	jmp    800aac <vprintfmt+0x22f>
  800ad1:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800ad4:	83 ec 08             	sub    $0x8,%esp
  800ad7:	53                   	push   %ebx
  800ad8:	6a 20                	push   $0x20
  800ada:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800adc:	4e                   	dec    %esi
  800add:	83 c4 10             	add    $0x10,%esp
  800ae0:	85 f6                	test   %esi,%esi
  800ae2:	7f f0                	jg     800ad4 <vprintfmt+0x257>
  800ae4:	e9 a8 fd ff ff       	jmp    800891 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800ae9:	83 7d d4 01          	cmpl   $0x1,-0x2c(%ebp)
  800aed:	7e 16                	jle    800b05 <vprintfmt+0x288>
		return va_arg(*ap, long long);
  800aef:	8b 45 14             	mov    0x14(%ebp),%eax
  800af2:	8d 50 08             	lea    0x8(%eax),%edx
  800af5:	89 55 14             	mov    %edx,0x14(%ebp)
  800af8:	8b 50 04             	mov    0x4(%eax),%edx
  800afb:	8b 00                	mov    (%eax),%eax
  800afd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b00:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800b03:	eb 34                	jmp    800b39 <vprintfmt+0x2bc>
	else if (lflag)
  800b05:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800b09:	74 18                	je     800b23 <vprintfmt+0x2a6>
		return va_arg(*ap, long);
  800b0b:	8b 45 14             	mov    0x14(%ebp),%eax
  800b0e:	8d 50 04             	lea    0x4(%eax),%edx
  800b11:	89 55 14             	mov    %edx,0x14(%ebp)
  800b14:	8b 30                	mov    (%eax),%esi
  800b16:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800b19:	89 f0                	mov    %esi,%eax
  800b1b:	c1 f8 1f             	sar    $0x1f,%eax
  800b1e:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800b21:	eb 16                	jmp    800b39 <vprintfmt+0x2bc>
	else
		return va_arg(*ap, int);
  800b23:	8b 45 14             	mov    0x14(%ebp),%eax
  800b26:	8d 50 04             	lea    0x4(%eax),%edx
  800b29:	89 55 14             	mov    %edx,0x14(%ebp)
  800b2c:	8b 30                	mov    (%eax),%esi
  800b2e:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800b31:	89 f0                	mov    %esi,%eax
  800b33:	c1 f8 1f             	sar    $0x1f,%eax
  800b36:	89 45 dc             	mov    %eax,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800b39:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800b3c:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
  800b3f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800b43:	0f 89 8a 00 00 00    	jns    800bd3 <vprintfmt+0x356>
				putch('-', putdat);
  800b49:	83 ec 08             	sub    $0x8,%esp
  800b4c:	53                   	push   %ebx
  800b4d:	6a 2d                	push   $0x2d
  800b4f:	ff d7                	call   *%edi
				num = -(long long) num;
  800b51:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800b54:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800b57:	f7 d8                	neg    %eax
  800b59:	83 d2 00             	adc    $0x0,%edx
  800b5c:	f7 da                	neg    %edx
  800b5e:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800b61:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800b66:	eb 70                	jmp    800bd8 <vprintfmt+0x35b>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800b68:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800b6b:	8d 45 14             	lea    0x14(%ebp),%eax
  800b6e:	e8 97 fc ff ff       	call   80080a <getuint>
			base = 10;
  800b73:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800b78:	eb 5e                	jmp    800bd8 <vprintfmt+0x35b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
  800b7a:	83 ec 08             	sub    $0x8,%esp
  800b7d:	53                   	push   %ebx
  800b7e:	6a 30                	push   $0x30
  800b80:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  800b82:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800b85:	8d 45 14             	lea    0x14(%ebp),%eax
  800b88:	e8 7d fc ff ff       	call   80080a <getuint>
			base = 8;
			goto number;
  800b8d:	83 c4 10             	add    $0x10,%esp
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800b90:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800b95:	eb 41                	jmp    800bd8 <vprintfmt+0x35b>
		// pointer
		case 'p':
			putch('0', putdat);
  800b97:	83 ec 08             	sub    $0x8,%esp
  800b9a:	53                   	push   %ebx
  800b9b:	6a 30                	push   $0x30
  800b9d:	ff d7                	call   *%edi
			putch('x', putdat);
  800b9f:	83 c4 08             	add    $0x8,%esp
  800ba2:	53                   	push   %ebx
  800ba3:	6a 78                	push   $0x78
  800ba5:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800ba7:	8b 45 14             	mov    0x14(%ebp),%eax
  800baa:	8d 50 04             	lea    0x4(%eax),%edx
  800bad:	89 55 14             	mov    %edx,0x14(%ebp)
			goto number;
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800bb0:	8b 00                	mov    (%eax),%eax
  800bb2:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800bb7:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800bba:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800bbf:	eb 17                	jmp    800bd8 <vprintfmt+0x35b>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800bc1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800bc4:	8d 45 14             	lea    0x14(%ebp),%eax
  800bc7:	e8 3e fc ff ff       	call   80080a <getuint>
			base = 16;
  800bcc:	b9 10 00 00 00       	mov    $0x10,%ecx
  800bd1:	eb 05                	jmp    800bd8 <vprintfmt+0x35b>
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800bd3:	b9 0a 00 00 00       	mov    $0xa,%ecx
		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800bd8:	83 ec 0c             	sub    $0xc,%esp
  800bdb:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800bdf:	56                   	push   %esi
  800be0:	ff 75 e4             	pushl  -0x1c(%ebp)
  800be3:	51                   	push   %ecx
  800be4:	52                   	push   %edx
  800be5:	50                   	push   %eax
  800be6:	89 da                	mov    %ebx,%edx
  800be8:	89 f8                	mov    %edi,%eax
  800bea:	e8 6b fb ff ff       	call   80075a <printnum>
			break;
  800bef:	83 c4 20             	add    $0x20,%esp
  800bf2:	e9 9a fc ff ff       	jmp    800891 <vprintfmt+0x14>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800bf7:	83 ec 08             	sub    $0x8,%esp
  800bfa:	53                   	push   %ebx
  800bfb:	52                   	push   %edx
  800bfc:	ff d7                	call   *%edi
			break;
  800bfe:	83 c4 10             	add    $0x10,%esp
  800c01:	e9 8b fc ff ff       	jmp    800891 <vprintfmt+0x14>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800c06:	83 ec 08             	sub    $0x8,%esp
  800c09:	53                   	push   %ebx
  800c0a:	6a 25                	push   $0x25
  800c0c:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c0e:	83 c4 10             	add    $0x10,%esp
  800c11:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800c15:	0f 84 73 fc ff ff    	je     80088e <vprintfmt+0x11>
  800c1b:	4e                   	dec    %esi
  800c1c:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800c20:	75 f9                	jne    800c1b <vprintfmt+0x39e>
  800c22:	89 75 10             	mov    %esi,0x10(%ebp)
  800c25:	e9 67 fc ff ff       	jmp    800891 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800c2a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800c2d:	8d 70 01             	lea    0x1(%eax),%esi
  800c30:	8a 00                	mov    (%eax),%al
  800c32:	0f be d0             	movsbl %al,%edx
  800c35:	85 d2                	test   %edx,%edx
  800c37:	0f 85 7a fe ff ff    	jne    800ab7 <vprintfmt+0x23a>
  800c3d:	e9 4f fc ff ff       	jmp    800891 <vprintfmt+0x14>
  800c42:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800c45:	8d 70 01             	lea    0x1(%eax),%esi
  800c48:	8a 00                	mov    (%eax),%al
  800c4a:	0f be d0             	movsbl %al,%edx
  800c4d:	85 d2                	test   %edx,%edx
  800c4f:	0f 85 6a fe ff ff    	jne    800abf <vprintfmt+0x242>
  800c55:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800c58:	e9 77 fe ff ff       	jmp    800ad4 <vprintfmt+0x257>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800c5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c60:	5b                   	pop    %ebx
  800c61:	5e                   	pop    %esi
  800c62:	5f                   	pop    %edi
  800c63:	5d                   	pop    %ebp
  800c64:	c3                   	ret    

00800c65 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c65:	55                   	push   %ebp
  800c66:	89 e5                	mov    %esp,%ebp
  800c68:	83 ec 18             	sub    $0x18,%esp
  800c6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c6e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c71:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c74:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800c78:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800c7b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800c82:	85 c0                	test   %eax,%eax
  800c84:	74 26                	je     800cac <vsnprintf+0x47>
  800c86:	85 d2                	test   %edx,%edx
  800c88:	7e 29                	jle    800cb3 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c8a:	ff 75 14             	pushl  0x14(%ebp)
  800c8d:	ff 75 10             	pushl  0x10(%ebp)
  800c90:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c93:	50                   	push   %eax
  800c94:	68 44 08 80 00       	push   $0x800844
  800c99:	e8 df fb ff ff       	call   80087d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c9e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ca1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800ca4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ca7:	83 c4 10             	add    $0x10,%esp
  800caa:	eb 0c                	jmp    800cb8 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800cac:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800cb1:	eb 05                	jmp    800cb8 <vsnprintf+0x53>
  800cb3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800cb8:	c9                   	leave  
  800cb9:	c3                   	ret    

00800cba <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800cba:	55                   	push   %ebp
  800cbb:	89 e5                	mov    %esp,%ebp
  800cbd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800cc0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800cc3:	50                   	push   %eax
  800cc4:	ff 75 10             	pushl  0x10(%ebp)
  800cc7:	ff 75 0c             	pushl  0xc(%ebp)
  800cca:	ff 75 08             	pushl  0x8(%ebp)
  800ccd:	e8 93 ff ff ff       	call   800c65 <vsnprintf>
	va_end(ap);

	return rc;
}
  800cd2:	c9                   	leave  
  800cd3:	c3                   	ret    

00800cd4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800cd4:	55                   	push   %ebp
  800cd5:	89 e5                	mov    %esp,%ebp
  800cd7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800cda:	80 3a 00             	cmpb   $0x0,(%edx)
  800cdd:	74 0e                	je     800ced <strlen+0x19>
  800cdf:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800ce4:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800ce5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800ce9:	75 f9                	jne    800ce4 <strlen+0x10>
  800ceb:	eb 05                	jmp    800cf2 <strlen+0x1e>
  800ced:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800cf2:	5d                   	pop    %ebp
  800cf3:	c3                   	ret    

00800cf4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800cf4:	55                   	push   %ebp
  800cf5:	89 e5                	mov    %esp,%ebp
  800cf7:	53                   	push   %ebx
  800cf8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800cfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cfe:	85 c9                	test   %ecx,%ecx
  800d00:	74 1a                	je     800d1c <strnlen+0x28>
  800d02:	80 3b 00             	cmpb   $0x0,(%ebx)
  800d05:	74 1c                	je     800d23 <strnlen+0x2f>
  800d07:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800d0c:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d0e:	39 ca                	cmp    %ecx,%edx
  800d10:	74 16                	je     800d28 <strnlen+0x34>
  800d12:	42                   	inc    %edx
  800d13:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800d18:	75 f2                	jne    800d0c <strnlen+0x18>
  800d1a:	eb 0c                	jmp    800d28 <strnlen+0x34>
  800d1c:	b8 00 00 00 00       	mov    $0x0,%eax
  800d21:	eb 05                	jmp    800d28 <strnlen+0x34>
  800d23:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800d28:	5b                   	pop    %ebx
  800d29:	5d                   	pop    %ebp
  800d2a:	c3                   	ret    

00800d2b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d2b:	55                   	push   %ebp
  800d2c:	89 e5                	mov    %esp,%ebp
  800d2e:	53                   	push   %ebx
  800d2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d35:	89 c2                	mov    %eax,%edx
  800d37:	42                   	inc    %edx
  800d38:	41                   	inc    %ecx
  800d39:	8a 59 ff             	mov    -0x1(%ecx),%bl
  800d3c:	88 5a ff             	mov    %bl,-0x1(%edx)
  800d3f:	84 db                	test   %bl,%bl
  800d41:	75 f4                	jne    800d37 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800d43:	5b                   	pop    %ebx
  800d44:	5d                   	pop    %ebp
  800d45:	c3                   	ret    

00800d46 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d46:	55                   	push   %ebp
  800d47:	89 e5                	mov    %esp,%ebp
  800d49:	53                   	push   %ebx
  800d4a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d4d:	53                   	push   %ebx
  800d4e:	e8 81 ff ff ff       	call   800cd4 <strlen>
  800d53:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800d56:	ff 75 0c             	pushl  0xc(%ebp)
  800d59:	01 d8                	add    %ebx,%eax
  800d5b:	50                   	push   %eax
  800d5c:	e8 ca ff ff ff       	call   800d2b <strcpy>
	return dst;
}
  800d61:	89 d8                	mov    %ebx,%eax
  800d63:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d66:	c9                   	leave  
  800d67:	c3                   	ret    

00800d68 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d68:	55                   	push   %ebp
  800d69:	89 e5                	mov    %esp,%ebp
  800d6b:	56                   	push   %esi
  800d6c:	53                   	push   %ebx
  800d6d:	8b 75 08             	mov    0x8(%ebp),%esi
  800d70:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d73:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d76:	85 db                	test   %ebx,%ebx
  800d78:	74 14                	je     800d8e <strncpy+0x26>
  800d7a:	01 f3                	add    %esi,%ebx
  800d7c:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800d7e:	41                   	inc    %ecx
  800d7f:	8a 02                	mov    (%edx),%al
  800d81:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800d84:	80 3a 01             	cmpb   $0x1,(%edx)
  800d87:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d8a:	39 cb                	cmp    %ecx,%ebx
  800d8c:	75 f0                	jne    800d7e <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800d8e:	89 f0                	mov    %esi,%eax
  800d90:	5b                   	pop    %ebx
  800d91:	5e                   	pop    %esi
  800d92:	5d                   	pop    %ebp
  800d93:	c3                   	ret    

00800d94 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d94:	55                   	push   %ebp
  800d95:	89 e5                	mov    %esp,%ebp
  800d97:	53                   	push   %ebx
  800d98:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d9b:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800d9e:	85 c0                	test   %eax,%eax
  800da0:	74 30                	je     800dd2 <strlcpy+0x3e>
		while (--size > 0 && *src != '\0')
  800da2:	48                   	dec    %eax
  800da3:	74 20                	je     800dc5 <strlcpy+0x31>
  800da5:	8a 0b                	mov    (%ebx),%cl
  800da7:	84 c9                	test   %cl,%cl
  800da9:	74 1f                	je     800dca <strlcpy+0x36>
  800dab:	8d 53 01             	lea    0x1(%ebx),%edx
  800dae:	01 c3                	add    %eax,%ebx
  800db0:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
  800db3:	40                   	inc    %eax
  800db4:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800db7:	39 da                	cmp    %ebx,%edx
  800db9:	74 12                	je     800dcd <strlcpy+0x39>
  800dbb:	42                   	inc    %edx
  800dbc:	8a 4a ff             	mov    -0x1(%edx),%cl
  800dbf:	84 c9                	test   %cl,%cl
  800dc1:	75 f0                	jne    800db3 <strlcpy+0x1f>
  800dc3:	eb 08                	jmp    800dcd <strlcpy+0x39>
  800dc5:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc8:	eb 03                	jmp    800dcd <strlcpy+0x39>
  800dca:	8b 45 08             	mov    0x8(%ebp),%eax
			*dst++ = *src++;
		*dst = '\0';
  800dcd:	c6 00 00             	movb   $0x0,(%eax)
  800dd0:	eb 03                	jmp    800dd5 <strlcpy+0x41>
  800dd2:	8b 45 08             	mov    0x8(%ebp),%eax
	}
	return dst - dst_in;
  800dd5:	2b 45 08             	sub    0x8(%ebp),%eax
}
  800dd8:	5b                   	pop    %ebx
  800dd9:	5d                   	pop    %ebp
  800dda:	c3                   	ret    

00800ddb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ddb:	55                   	push   %ebp
  800ddc:	89 e5                	mov    %esp,%ebp
  800dde:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800de1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800de4:	8a 01                	mov    (%ecx),%al
  800de6:	84 c0                	test   %al,%al
  800de8:	74 10                	je     800dfa <strcmp+0x1f>
  800dea:	3a 02                	cmp    (%edx),%al
  800dec:	75 0c                	jne    800dfa <strcmp+0x1f>
		p++, q++;
  800dee:	41                   	inc    %ecx
  800def:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800df0:	8a 01                	mov    (%ecx),%al
  800df2:	84 c0                	test   %al,%al
  800df4:	74 04                	je     800dfa <strcmp+0x1f>
  800df6:	3a 02                	cmp    (%edx),%al
  800df8:	74 f4                	je     800dee <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800dfa:	0f b6 c0             	movzbl %al,%eax
  800dfd:	0f b6 12             	movzbl (%edx),%edx
  800e00:	29 d0                	sub    %edx,%eax
}
  800e02:	5d                   	pop    %ebp
  800e03:	c3                   	ret    

00800e04 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800e04:	55                   	push   %ebp
  800e05:	89 e5                	mov    %esp,%ebp
  800e07:	56                   	push   %esi
  800e08:	53                   	push   %ebx
  800e09:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800e0c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e0f:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800e12:	85 f6                	test   %esi,%esi
  800e14:	74 23                	je     800e39 <strncmp+0x35>
  800e16:	8a 03                	mov    (%ebx),%al
  800e18:	84 c0                	test   %al,%al
  800e1a:	74 2b                	je     800e47 <strncmp+0x43>
  800e1c:	3a 02                	cmp    (%edx),%al
  800e1e:	75 27                	jne    800e47 <strncmp+0x43>
  800e20:	8d 43 01             	lea    0x1(%ebx),%eax
  800e23:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800e25:	89 c3                	mov    %eax,%ebx
  800e27:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800e28:	39 c6                	cmp    %eax,%esi
  800e2a:	74 14                	je     800e40 <strncmp+0x3c>
  800e2c:	8a 08                	mov    (%eax),%cl
  800e2e:	84 c9                	test   %cl,%cl
  800e30:	74 15                	je     800e47 <strncmp+0x43>
  800e32:	40                   	inc    %eax
  800e33:	3a 0a                	cmp    (%edx),%cl
  800e35:	74 ee                	je     800e25 <strncmp+0x21>
  800e37:	eb 0e                	jmp    800e47 <strncmp+0x43>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800e39:	b8 00 00 00 00       	mov    $0x0,%eax
  800e3e:	eb 0f                	jmp    800e4f <strncmp+0x4b>
  800e40:	b8 00 00 00 00       	mov    $0x0,%eax
  800e45:	eb 08                	jmp    800e4f <strncmp+0x4b>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e47:	0f b6 03             	movzbl (%ebx),%eax
  800e4a:	0f b6 12             	movzbl (%edx),%edx
  800e4d:	29 d0                	sub    %edx,%eax
}
  800e4f:	5b                   	pop    %ebx
  800e50:	5e                   	pop    %esi
  800e51:	5d                   	pop    %ebp
  800e52:	c3                   	ret    

00800e53 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e53:	55                   	push   %ebp
  800e54:	89 e5                	mov    %esp,%ebp
  800e56:	53                   	push   %ebx
  800e57:	8b 45 08             	mov    0x8(%ebp),%eax
  800e5a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800e5d:	8a 10                	mov    (%eax),%dl
  800e5f:	84 d2                	test   %dl,%dl
  800e61:	74 1a                	je     800e7d <strchr+0x2a>
  800e63:	88 d9                	mov    %bl,%cl
		if (*s == c)
  800e65:	38 d3                	cmp    %dl,%bl
  800e67:	75 06                	jne    800e6f <strchr+0x1c>
  800e69:	eb 17                	jmp    800e82 <strchr+0x2f>
  800e6b:	38 ca                	cmp    %cl,%dl
  800e6d:	74 13                	je     800e82 <strchr+0x2f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e6f:	40                   	inc    %eax
  800e70:	8a 10                	mov    (%eax),%dl
  800e72:	84 d2                	test   %dl,%dl
  800e74:	75 f5                	jne    800e6b <strchr+0x18>
		if (*s == c)
			return (char *) s;
	return 0;
  800e76:	b8 00 00 00 00       	mov    $0x0,%eax
  800e7b:	eb 05                	jmp    800e82 <strchr+0x2f>
  800e7d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e82:	5b                   	pop    %ebx
  800e83:	5d                   	pop    %ebp
  800e84:	c3                   	ret    

00800e85 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e85:	55                   	push   %ebp
  800e86:	89 e5                	mov    %esp,%ebp
  800e88:	53                   	push   %ebx
  800e89:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800e8f:	8a 10                	mov    (%eax),%dl
  800e91:	84 d2                	test   %dl,%dl
  800e93:	74 13                	je     800ea8 <strfind+0x23>
  800e95:	88 d9                	mov    %bl,%cl
		if (*s == c)
  800e97:	38 d3                	cmp    %dl,%bl
  800e99:	75 06                	jne    800ea1 <strfind+0x1c>
  800e9b:	eb 0b                	jmp    800ea8 <strfind+0x23>
  800e9d:	38 ca                	cmp    %cl,%dl
  800e9f:	74 07                	je     800ea8 <strfind+0x23>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800ea1:	40                   	inc    %eax
  800ea2:	8a 10                	mov    (%eax),%dl
  800ea4:	84 d2                	test   %dl,%dl
  800ea6:	75 f5                	jne    800e9d <strfind+0x18>
		if (*s == c)
			break;
	return (char *) s;
}
  800ea8:	5b                   	pop    %ebx
  800ea9:	5d                   	pop    %ebp
  800eaa:	c3                   	ret    

00800eab <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800eab:	55                   	push   %ebp
  800eac:	89 e5                	mov    %esp,%ebp
  800eae:	57                   	push   %edi
  800eaf:	56                   	push   %esi
  800eb0:	53                   	push   %ebx
  800eb1:	8b 7d 08             	mov    0x8(%ebp),%edi
  800eb4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800eb7:	85 c9                	test   %ecx,%ecx
  800eb9:	74 36                	je     800ef1 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ebb:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ec1:	75 28                	jne    800eeb <memset+0x40>
  800ec3:	f6 c1 03             	test   $0x3,%cl
  800ec6:	75 23                	jne    800eeb <memset+0x40>
		c &= 0xFF;
  800ec8:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ecc:	89 d3                	mov    %edx,%ebx
  800ece:	c1 e3 08             	shl    $0x8,%ebx
  800ed1:	89 d6                	mov    %edx,%esi
  800ed3:	c1 e6 18             	shl    $0x18,%esi
  800ed6:	89 d0                	mov    %edx,%eax
  800ed8:	c1 e0 10             	shl    $0x10,%eax
  800edb:	09 f0                	or     %esi,%eax
  800edd:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800edf:	89 d8                	mov    %ebx,%eax
  800ee1:	09 d0                	or     %edx,%eax
  800ee3:	c1 e9 02             	shr    $0x2,%ecx
  800ee6:	fc                   	cld    
  800ee7:	f3 ab                	rep stos %eax,%es:(%edi)
  800ee9:	eb 06                	jmp    800ef1 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800eeb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eee:	fc                   	cld    
  800eef:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ef1:	89 f8                	mov    %edi,%eax
  800ef3:	5b                   	pop    %ebx
  800ef4:	5e                   	pop    %esi
  800ef5:	5f                   	pop    %edi
  800ef6:	5d                   	pop    %ebp
  800ef7:	c3                   	ret    

00800ef8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ef8:	55                   	push   %ebp
  800ef9:	89 e5                	mov    %esp,%ebp
  800efb:	57                   	push   %edi
  800efc:	56                   	push   %esi
  800efd:	8b 45 08             	mov    0x8(%ebp),%eax
  800f00:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f03:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800f06:	39 c6                	cmp    %eax,%esi
  800f08:	73 33                	jae    800f3d <memmove+0x45>
  800f0a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800f0d:	39 d0                	cmp    %edx,%eax
  800f0f:	73 2c                	jae    800f3d <memmove+0x45>
		s += n;
		d += n;
  800f11:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f14:	89 d6                	mov    %edx,%esi
  800f16:	09 fe                	or     %edi,%esi
  800f18:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800f1e:	75 13                	jne    800f33 <memmove+0x3b>
  800f20:	f6 c1 03             	test   $0x3,%cl
  800f23:	75 0e                	jne    800f33 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800f25:	83 ef 04             	sub    $0x4,%edi
  800f28:	8d 72 fc             	lea    -0x4(%edx),%esi
  800f2b:	c1 e9 02             	shr    $0x2,%ecx
  800f2e:	fd                   	std    
  800f2f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f31:	eb 07                	jmp    800f3a <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800f33:	4f                   	dec    %edi
  800f34:	8d 72 ff             	lea    -0x1(%edx),%esi
  800f37:	fd                   	std    
  800f38:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f3a:	fc                   	cld    
  800f3b:	eb 1d                	jmp    800f5a <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f3d:	89 f2                	mov    %esi,%edx
  800f3f:	09 c2                	or     %eax,%edx
  800f41:	f6 c2 03             	test   $0x3,%dl
  800f44:	75 0f                	jne    800f55 <memmove+0x5d>
  800f46:	f6 c1 03             	test   $0x3,%cl
  800f49:	75 0a                	jne    800f55 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
  800f4b:	c1 e9 02             	shr    $0x2,%ecx
  800f4e:	89 c7                	mov    %eax,%edi
  800f50:	fc                   	cld    
  800f51:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f53:	eb 05                	jmp    800f5a <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f55:	89 c7                	mov    %eax,%edi
  800f57:	fc                   	cld    
  800f58:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800f5a:	5e                   	pop    %esi
  800f5b:	5f                   	pop    %edi
  800f5c:	5d                   	pop    %ebp
  800f5d:	c3                   	ret    

00800f5e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f5e:	55                   	push   %ebp
  800f5f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800f61:	ff 75 10             	pushl  0x10(%ebp)
  800f64:	ff 75 0c             	pushl  0xc(%ebp)
  800f67:	ff 75 08             	pushl  0x8(%ebp)
  800f6a:	e8 89 ff ff ff       	call   800ef8 <memmove>
}
  800f6f:	c9                   	leave  
  800f70:	c3                   	ret    

00800f71 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f71:	55                   	push   %ebp
  800f72:	89 e5                	mov    %esp,%ebp
  800f74:	57                   	push   %edi
  800f75:	56                   	push   %esi
  800f76:	53                   	push   %ebx
  800f77:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800f7a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f7d:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f80:	85 c0                	test   %eax,%eax
  800f82:	74 33                	je     800fb7 <memcmp+0x46>
  800f84:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800f87:	8a 13                	mov    (%ebx),%dl
  800f89:	8a 0e                	mov    (%esi),%cl
  800f8b:	38 ca                	cmp    %cl,%dl
  800f8d:	75 13                	jne    800fa2 <memcmp+0x31>
  800f8f:	b8 00 00 00 00       	mov    $0x0,%eax
  800f94:	eb 16                	jmp    800fac <memcmp+0x3b>
  800f96:	8a 54 03 01          	mov    0x1(%ebx,%eax,1),%dl
  800f9a:	40                   	inc    %eax
  800f9b:	8a 0c 06             	mov    (%esi,%eax,1),%cl
  800f9e:	38 ca                	cmp    %cl,%dl
  800fa0:	74 0a                	je     800fac <memcmp+0x3b>
			return (int) *s1 - (int) *s2;
  800fa2:	0f b6 c2             	movzbl %dl,%eax
  800fa5:	0f b6 c9             	movzbl %cl,%ecx
  800fa8:	29 c8                	sub    %ecx,%eax
  800faa:	eb 10                	jmp    800fbc <memcmp+0x4b>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800fac:	39 f8                	cmp    %edi,%eax
  800fae:	75 e6                	jne    800f96 <memcmp+0x25>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800fb0:	b8 00 00 00 00       	mov    $0x0,%eax
  800fb5:	eb 05                	jmp    800fbc <memcmp+0x4b>
  800fb7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800fbc:	5b                   	pop    %ebx
  800fbd:	5e                   	pop    %esi
  800fbe:	5f                   	pop    %edi
  800fbf:	5d                   	pop    %ebp
  800fc0:	c3                   	ret    

00800fc1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800fc1:	55                   	push   %ebp
  800fc2:	89 e5                	mov    %esp,%ebp
  800fc4:	53                   	push   %ebx
  800fc5:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800fc8:	89 d0                	mov    %edx,%eax
  800fca:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800fcd:	39 c2                	cmp    %eax,%edx
  800fcf:	73 1b                	jae    800fec <memfind+0x2b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800fd1:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800fd5:	0f b6 0a             	movzbl (%edx),%ecx
  800fd8:	39 d9                	cmp    %ebx,%ecx
  800fda:	75 09                	jne    800fe5 <memfind+0x24>
  800fdc:	eb 12                	jmp    800ff0 <memfind+0x2f>
  800fde:	0f b6 0a             	movzbl (%edx),%ecx
  800fe1:	39 d9                	cmp    %ebx,%ecx
  800fe3:	74 0f                	je     800ff4 <memfind+0x33>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800fe5:	42                   	inc    %edx
  800fe6:	39 d0                	cmp    %edx,%eax
  800fe8:	75 f4                	jne    800fde <memfind+0x1d>
  800fea:	eb 0a                	jmp    800ff6 <memfind+0x35>
  800fec:	89 d0                	mov    %edx,%eax
  800fee:	eb 06                	jmp    800ff6 <memfind+0x35>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ff0:	89 d0                	mov    %edx,%eax
  800ff2:	eb 02                	jmp    800ff6 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ff4:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ff6:	5b                   	pop    %ebx
  800ff7:	5d                   	pop    %ebp
  800ff8:	c3                   	ret    

00800ff9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ff9:	55                   	push   %ebp
  800ffa:	89 e5                	mov    %esp,%ebp
  800ffc:	57                   	push   %edi
  800ffd:	56                   	push   %esi
  800ffe:	53                   	push   %ebx
  800fff:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801002:	eb 01                	jmp    801005 <strtol+0xc>
		s++;
  801004:	41                   	inc    %ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801005:	8a 01                	mov    (%ecx),%al
  801007:	3c 20                	cmp    $0x20,%al
  801009:	74 f9                	je     801004 <strtol+0xb>
  80100b:	3c 09                	cmp    $0x9,%al
  80100d:	74 f5                	je     801004 <strtol+0xb>
		s++;

	// plus/minus sign
	if (*s == '+')
  80100f:	3c 2b                	cmp    $0x2b,%al
  801011:	75 08                	jne    80101b <strtol+0x22>
		s++;
  801013:	41                   	inc    %ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801014:	bf 00 00 00 00       	mov    $0x0,%edi
  801019:	eb 11                	jmp    80102c <strtol+0x33>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80101b:	3c 2d                	cmp    $0x2d,%al
  80101d:	75 08                	jne    801027 <strtol+0x2e>
		s++, neg = 1;
  80101f:	41                   	inc    %ecx
  801020:	bf 01 00 00 00       	mov    $0x1,%edi
  801025:	eb 05                	jmp    80102c <strtol+0x33>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801027:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80102c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801030:	0f 84 87 00 00 00    	je     8010bd <strtol+0xc4>
  801036:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  80103a:	75 27                	jne    801063 <strtol+0x6a>
  80103c:	80 39 30             	cmpb   $0x30,(%ecx)
  80103f:	75 22                	jne    801063 <strtol+0x6a>
  801041:	e9 88 00 00 00       	jmp    8010ce <strtol+0xd5>
		s += 2, base = 16;
  801046:	83 c1 02             	add    $0x2,%ecx
  801049:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  801050:	eb 11                	jmp    801063 <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
  801052:	41                   	inc    %ecx
  801053:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  80105a:	eb 07                	jmp    801063 <strtol+0x6a>
	else if (base == 0)
		base = 10;
  80105c:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
  801063:	b8 00 00 00 00       	mov    $0x0,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801068:	8a 11                	mov    (%ecx),%dl
  80106a:	8d 5a d0             	lea    -0x30(%edx),%ebx
  80106d:	80 fb 09             	cmp    $0x9,%bl
  801070:	77 08                	ja     80107a <strtol+0x81>
			dig = *s - '0';
  801072:	0f be d2             	movsbl %dl,%edx
  801075:	83 ea 30             	sub    $0x30,%edx
  801078:	eb 22                	jmp    80109c <strtol+0xa3>
		else if (*s >= 'a' && *s <= 'z')
  80107a:	8d 72 9f             	lea    -0x61(%edx),%esi
  80107d:	89 f3                	mov    %esi,%ebx
  80107f:	80 fb 19             	cmp    $0x19,%bl
  801082:	77 08                	ja     80108c <strtol+0x93>
			dig = *s - 'a' + 10;
  801084:	0f be d2             	movsbl %dl,%edx
  801087:	83 ea 57             	sub    $0x57,%edx
  80108a:	eb 10                	jmp    80109c <strtol+0xa3>
		else if (*s >= 'A' && *s <= 'Z')
  80108c:	8d 72 bf             	lea    -0x41(%edx),%esi
  80108f:	89 f3                	mov    %esi,%ebx
  801091:	80 fb 19             	cmp    $0x19,%bl
  801094:	77 14                	ja     8010aa <strtol+0xb1>
			dig = *s - 'A' + 10;
  801096:	0f be d2             	movsbl %dl,%edx
  801099:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  80109c:	3b 55 10             	cmp    0x10(%ebp),%edx
  80109f:	7d 09                	jge    8010aa <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  8010a1:	41                   	inc    %ecx
  8010a2:	0f af 45 10          	imul   0x10(%ebp),%eax
  8010a6:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8010a8:	eb be                	jmp    801068 <strtol+0x6f>

	if (endptr)
  8010aa:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8010ae:	74 05                	je     8010b5 <strtol+0xbc>
		*endptr = (char *) s;
  8010b0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010b3:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  8010b5:	85 ff                	test   %edi,%edi
  8010b7:	74 21                	je     8010da <strtol+0xe1>
  8010b9:	f7 d8                	neg    %eax
  8010bb:	eb 1d                	jmp    8010da <strtol+0xe1>
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8010bd:	80 39 30             	cmpb   $0x30,(%ecx)
  8010c0:	75 9a                	jne    80105c <strtol+0x63>
  8010c2:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8010c6:	0f 84 7a ff ff ff    	je     801046 <strtol+0x4d>
  8010cc:	eb 84                	jmp    801052 <strtol+0x59>
  8010ce:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8010d2:	0f 84 6e ff ff ff    	je     801046 <strtol+0x4d>
  8010d8:	eb 89                	jmp    801063 <strtol+0x6a>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  8010da:	5b                   	pop    %ebx
  8010db:	5e                   	pop    %esi
  8010dc:	5f                   	pop    %edi
  8010dd:	5d                   	pop    %ebp
  8010de:	c3                   	ret    

008010df <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8010df:	55                   	push   %ebp
  8010e0:	89 e5                	mov    %esp,%ebp
  8010e2:	57                   	push   %edi
  8010e3:	56                   	push   %esi
  8010e4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8010ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8010f0:	89 c3                	mov    %eax,%ebx
  8010f2:	89 c7                	mov    %eax,%edi
  8010f4:	89 c6                	mov    %eax,%esi
  8010f6:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8010f8:	5b                   	pop    %ebx
  8010f9:	5e                   	pop    %esi
  8010fa:	5f                   	pop    %edi
  8010fb:	5d                   	pop    %ebp
  8010fc:	c3                   	ret    

008010fd <sys_cgetc>:

int
sys_cgetc(void)
{
  8010fd:	55                   	push   %ebp
  8010fe:	89 e5                	mov    %esp,%ebp
  801100:	57                   	push   %edi
  801101:	56                   	push   %esi
  801102:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801103:	ba 00 00 00 00       	mov    $0x0,%edx
  801108:	b8 01 00 00 00       	mov    $0x1,%eax
  80110d:	89 d1                	mov    %edx,%ecx
  80110f:	89 d3                	mov    %edx,%ebx
  801111:	89 d7                	mov    %edx,%edi
  801113:	89 d6                	mov    %edx,%esi
  801115:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801117:	5b                   	pop    %ebx
  801118:	5e                   	pop    %esi
  801119:	5f                   	pop    %edi
  80111a:	5d                   	pop    %ebp
  80111b:	c3                   	ret    

0080111c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80111c:	55                   	push   %ebp
  80111d:	89 e5                	mov    %esp,%ebp
  80111f:	57                   	push   %edi
  801120:	56                   	push   %esi
  801121:	53                   	push   %ebx
  801122:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801125:	b9 00 00 00 00       	mov    $0x0,%ecx
  80112a:	b8 03 00 00 00       	mov    $0x3,%eax
  80112f:	8b 55 08             	mov    0x8(%ebp),%edx
  801132:	89 cb                	mov    %ecx,%ebx
  801134:	89 cf                	mov    %ecx,%edi
  801136:	89 ce                	mov    %ecx,%esi
  801138:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80113a:	85 c0                	test   %eax,%eax
  80113c:	7e 17                	jle    801155 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80113e:	83 ec 0c             	sub    $0xc,%esp
  801141:	50                   	push   %eax
  801142:	6a 03                	push   $0x3
  801144:	68 ff 2a 80 00       	push   $0x802aff
  801149:	6a 23                	push   $0x23
  80114b:	68 1c 2b 80 00       	push   $0x802b1c
  801150:	e8 19 f5 ff ff       	call   80066e <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801155:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801158:	5b                   	pop    %ebx
  801159:	5e                   	pop    %esi
  80115a:	5f                   	pop    %edi
  80115b:	5d                   	pop    %ebp
  80115c:	c3                   	ret    

0080115d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80115d:	55                   	push   %ebp
  80115e:	89 e5                	mov    %esp,%ebp
  801160:	57                   	push   %edi
  801161:	56                   	push   %esi
  801162:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801163:	ba 00 00 00 00       	mov    $0x0,%edx
  801168:	b8 02 00 00 00       	mov    $0x2,%eax
  80116d:	89 d1                	mov    %edx,%ecx
  80116f:	89 d3                	mov    %edx,%ebx
  801171:	89 d7                	mov    %edx,%edi
  801173:	89 d6                	mov    %edx,%esi
  801175:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801177:	5b                   	pop    %ebx
  801178:	5e                   	pop    %esi
  801179:	5f                   	pop    %edi
  80117a:	5d                   	pop    %ebp
  80117b:	c3                   	ret    

0080117c <sys_yield>:

void
sys_yield(void)
{
  80117c:	55                   	push   %ebp
  80117d:	89 e5                	mov    %esp,%ebp
  80117f:	57                   	push   %edi
  801180:	56                   	push   %esi
  801181:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801182:	ba 00 00 00 00       	mov    $0x0,%edx
  801187:	b8 0b 00 00 00       	mov    $0xb,%eax
  80118c:	89 d1                	mov    %edx,%ecx
  80118e:	89 d3                	mov    %edx,%ebx
  801190:	89 d7                	mov    %edx,%edi
  801192:	89 d6                	mov    %edx,%esi
  801194:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801196:	5b                   	pop    %ebx
  801197:	5e                   	pop    %esi
  801198:	5f                   	pop    %edi
  801199:	5d                   	pop    %ebp
  80119a:	c3                   	ret    

0080119b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80119b:	55                   	push   %ebp
  80119c:	89 e5                	mov    %esp,%ebp
  80119e:	57                   	push   %edi
  80119f:	56                   	push   %esi
  8011a0:	53                   	push   %ebx
  8011a1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011a4:	be 00 00 00 00       	mov    $0x0,%esi
  8011a9:	b8 04 00 00 00       	mov    $0x4,%eax
  8011ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8011b4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011b7:	89 f7                	mov    %esi,%edi
  8011b9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011bb:	85 c0                	test   %eax,%eax
  8011bd:	7e 17                	jle    8011d6 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011bf:	83 ec 0c             	sub    $0xc,%esp
  8011c2:	50                   	push   %eax
  8011c3:	6a 04                	push   $0x4
  8011c5:	68 ff 2a 80 00       	push   $0x802aff
  8011ca:	6a 23                	push   $0x23
  8011cc:	68 1c 2b 80 00       	push   $0x802b1c
  8011d1:	e8 98 f4 ff ff       	call   80066e <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8011d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011d9:	5b                   	pop    %ebx
  8011da:	5e                   	pop    %esi
  8011db:	5f                   	pop    %edi
  8011dc:	5d                   	pop    %ebp
  8011dd:	c3                   	ret    

008011de <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8011de:	55                   	push   %ebp
  8011df:	89 e5                	mov    %esp,%ebp
  8011e1:	57                   	push   %edi
  8011e2:	56                   	push   %esi
  8011e3:	53                   	push   %ebx
  8011e4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011e7:	b8 05 00 00 00       	mov    $0x5,%eax
  8011ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011ef:	8b 55 08             	mov    0x8(%ebp),%edx
  8011f2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011f5:	8b 7d 14             	mov    0x14(%ebp),%edi
  8011f8:	8b 75 18             	mov    0x18(%ebp),%esi
  8011fb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011fd:	85 c0                	test   %eax,%eax
  8011ff:	7e 17                	jle    801218 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801201:	83 ec 0c             	sub    $0xc,%esp
  801204:	50                   	push   %eax
  801205:	6a 05                	push   $0x5
  801207:	68 ff 2a 80 00       	push   $0x802aff
  80120c:	6a 23                	push   $0x23
  80120e:	68 1c 2b 80 00       	push   $0x802b1c
  801213:	e8 56 f4 ff ff       	call   80066e <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801218:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80121b:	5b                   	pop    %ebx
  80121c:	5e                   	pop    %esi
  80121d:	5f                   	pop    %edi
  80121e:	5d                   	pop    %ebp
  80121f:	c3                   	ret    

00801220 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801220:	55                   	push   %ebp
  801221:	89 e5                	mov    %esp,%ebp
  801223:	57                   	push   %edi
  801224:	56                   	push   %esi
  801225:	53                   	push   %ebx
  801226:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801229:	bb 00 00 00 00       	mov    $0x0,%ebx
  80122e:	b8 06 00 00 00       	mov    $0x6,%eax
  801233:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801236:	8b 55 08             	mov    0x8(%ebp),%edx
  801239:	89 df                	mov    %ebx,%edi
  80123b:	89 de                	mov    %ebx,%esi
  80123d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80123f:	85 c0                	test   %eax,%eax
  801241:	7e 17                	jle    80125a <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801243:	83 ec 0c             	sub    $0xc,%esp
  801246:	50                   	push   %eax
  801247:	6a 06                	push   $0x6
  801249:	68 ff 2a 80 00       	push   $0x802aff
  80124e:	6a 23                	push   $0x23
  801250:	68 1c 2b 80 00       	push   $0x802b1c
  801255:	e8 14 f4 ff ff       	call   80066e <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80125a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80125d:	5b                   	pop    %ebx
  80125e:	5e                   	pop    %esi
  80125f:	5f                   	pop    %edi
  801260:	5d                   	pop    %ebp
  801261:	c3                   	ret    

00801262 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801262:	55                   	push   %ebp
  801263:	89 e5                	mov    %esp,%ebp
  801265:	57                   	push   %edi
  801266:	56                   	push   %esi
  801267:	53                   	push   %ebx
  801268:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80126b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801270:	b8 08 00 00 00       	mov    $0x8,%eax
  801275:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801278:	8b 55 08             	mov    0x8(%ebp),%edx
  80127b:	89 df                	mov    %ebx,%edi
  80127d:	89 de                	mov    %ebx,%esi
  80127f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801281:	85 c0                	test   %eax,%eax
  801283:	7e 17                	jle    80129c <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801285:	83 ec 0c             	sub    $0xc,%esp
  801288:	50                   	push   %eax
  801289:	6a 08                	push   $0x8
  80128b:	68 ff 2a 80 00       	push   $0x802aff
  801290:	6a 23                	push   $0x23
  801292:	68 1c 2b 80 00       	push   $0x802b1c
  801297:	e8 d2 f3 ff ff       	call   80066e <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80129c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80129f:	5b                   	pop    %ebx
  8012a0:	5e                   	pop    %esi
  8012a1:	5f                   	pop    %edi
  8012a2:	5d                   	pop    %ebp
  8012a3:	c3                   	ret    

008012a4 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8012a4:	55                   	push   %ebp
  8012a5:	89 e5                	mov    %esp,%ebp
  8012a7:	57                   	push   %edi
  8012a8:	56                   	push   %esi
  8012a9:	53                   	push   %ebx
  8012aa:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012ad:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012b2:	b8 09 00 00 00       	mov    $0x9,%eax
  8012b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8012bd:	89 df                	mov    %ebx,%edi
  8012bf:	89 de                	mov    %ebx,%esi
  8012c1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8012c3:	85 c0                	test   %eax,%eax
  8012c5:	7e 17                	jle    8012de <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012c7:	83 ec 0c             	sub    $0xc,%esp
  8012ca:	50                   	push   %eax
  8012cb:	6a 09                	push   $0x9
  8012cd:	68 ff 2a 80 00       	push   $0x802aff
  8012d2:	6a 23                	push   $0x23
  8012d4:	68 1c 2b 80 00       	push   $0x802b1c
  8012d9:	e8 90 f3 ff ff       	call   80066e <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8012de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012e1:	5b                   	pop    %ebx
  8012e2:	5e                   	pop    %esi
  8012e3:	5f                   	pop    %edi
  8012e4:	5d                   	pop    %ebp
  8012e5:	c3                   	ret    

008012e6 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8012e6:	55                   	push   %ebp
  8012e7:	89 e5                	mov    %esp,%ebp
  8012e9:	57                   	push   %edi
  8012ea:	56                   	push   %esi
  8012eb:	53                   	push   %ebx
  8012ec:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012ef:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012f4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8012f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8012ff:	89 df                	mov    %ebx,%edi
  801301:	89 de                	mov    %ebx,%esi
  801303:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801305:	85 c0                	test   %eax,%eax
  801307:	7e 17                	jle    801320 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801309:	83 ec 0c             	sub    $0xc,%esp
  80130c:	50                   	push   %eax
  80130d:	6a 0a                	push   $0xa
  80130f:	68 ff 2a 80 00       	push   $0x802aff
  801314:	6a 23                	push   $0x23
  801316:	68 1c 2b 80 00       	push   $0x802b1c
  80131b:	e8 4e f3 ff ff       	call   80066e <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801320:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801323:	5b                   	pop    %ebx
  801324:	5e                   	pop    %esi
  801325:	5f                   	pop    %edi
  801326:	5d                   	pop    %ebp
  801327:	c3                   	ret    

00801328 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801328:	55                   	push   %ebp
  801329:	89 e5                	mov    %esp,%ebp
  80132b:	57                   	push   %edi
  80132c:	56                   	push   %esi
  80132d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80132e:	be 00 00 00 00       	mov    $0x0,%esi
  801333:	b8 0c 00 00 00       	mov    $0xc,%eax
  801338:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80133b:	8b 55 08             	mov    0x8(%ebp),%edx
  80133e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801341:	8b 7d 14             	mov    0x14(%ebp),%edi
  801344:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801346:	5b                   	pop    %ebx
  801347:	5e                   	pop    %esi
  801348:	5f                   	pop    %edi
  801349:	5d                   	pop    %ebp
  80134a:	c3                   	ret    

0080134b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80134b:	55                   	push   %ebp
  80134c:	89 e5                	mov    %esp,%ebp
  80134e:	57                   	push   %edi
  80134f:	56                   	push   %esi
  801350:	53                   	push   %ebx
  801351:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801354:	b9 00 00 00 00       	mov    $0x0,%ecx
  801359:	b8 0d 00 00 00       	mov    $0xd,%eax
  80135e:	8b 55 08             	mov    0x8(%ebp),%edx
  801361:	89 cb                	mov    %ecx,%ebx
  801363:	89 cf                	mov    %ecx,%edi
  801365:	89 ce                	mov    %ecx,%esi
  801367:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801369:	85 c0                	test   %eax,%eax
  80136b:	7e 17                	jle    801384 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80136d:	83 ec 0c             	sub    $0xc,%esp
  801370:	50                   	push   %eax
  801371:	6a 0d                	push   $0xd
  801373:	68 ff 2a 80 00       	push   $0x802aff
  801378:	6a 23                	push   $0x23
  80137a:	68 1c 2b 80 00       	push   $0x802b1c
  80137f:	e8 ea f2 ff ff       	call   80066e <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801384:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801387:	5b                   	pop    %ebx
  801388:	5e                   	pop    %esi
  801389:	5f                   	pop    %edi
  80138a:	5d                   	pop    %ebp
  80138b:	c3                   	ret    

0080138c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80138c:	55                   	push   %ebp
  80138d:	89 e5                	mov    %esp,%ebp
  80138f:	56                   	push   %esi
  801390:	53                   	push   %ebx
  801391:	8b 75 08             	mov    0x8(%ebp),%esi
  801394:	8b 45 0c             	mov    0xc(%ebp),%eax
  801397:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");
	int r;
    if (pg != NULL) {
  80139a:	85 c0                	test   %eax,%eax
  80139c:	74 0e                	je     8013ac <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  80139e:	83 ec 0c             	sub    $0xc,%esp
  8013a1:	50                   	push   %eax
  8013a2:	e8 a4 ff ff ff       	call   80134b <sys_ipc_recv>
  8013a7:	83 c4 10             	add    $0x10,%esp
  8013aa:	eb 10                	jmp    8013bc <ipc_recv+0x30>
    } else {
        r = sys_ipc_recv((void *) UTOP);
  8013ac:	83 ec 0c             	sub    $0xc,%esp
  8013af:	68 00 00 c0 ee       	push   $0xeec00000
  8013b4:	e8 92 ff ff ff       	call   80134b <sys_ipc_recv>
  8013b9:	83 c4 10             	add    $0x10,%esp
    }
    if (r < 0) {
  8013bc:	85 c0                	test   %eax,%eax
  8013be:	79 16                	jns    8013d6 <ipc_recv+0x4a>
        // failed
        if (from_env_store != NULL) *from_env_store = 0;
  8013c0:	85 f6                	test   %esi,%esi
  8013c2:	74 06                	je     8013ca <ipc_recv+0x3e>
  8013c4:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL) *perm_store = 0;
  8013ca:	85 db                	test   %ebx,%ebx
  8013cc:	74 2c                	je     8013fa <ipc_recv+0x6e>
  8013ce:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8013d4:	eb 24                	jmp    8013fa <ipc_recv+0x6e>
        return r;
    } else {
        if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  8013d6:	85 f6                	test   %esi,%esi
  8013d8:	74 0a                	je     8013e4 <ipc_recv+0x58>
  8013da:	a1 04 40 80 00       	mov    0x804004,%eax
  8013df:	8b 40 74             	mov    0x74(%eax),%eax
  8013e2:	89 06                	mov    %eax,(%esi)
        if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  8013e4:	85 db                	test   %ebx,%ebx
  8013e6:	74 0a                	je     8013f2 <ipc_recv+0x66>
  8013e8:	a1 04 40 80 00       	mov    0x804004,%eax
  8013ed:	8b 40 78             	mov    0x78(%eax),%eax
  8013f0:	89 03                	mov    %eax,(%ebx)
        return thisenv->env_ipc_value;
  8013f2:	a1 04 40 80 00       	mov    0x804004,%eax
  8013f7:	8b 40 70             	mov    0x70(%eax),%eax
    }
 
	return 0;
}
  8013fa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013fd:	5b                   	pop    %ebx
  8013fe:	5e                   	pop    %esi
  8013ff:	5d                   	pop    %ebp
  801400:	c3                   	ret    

00801401 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801401:	55                   	push   %ebp
  801402:	89 e5                	mov    %esp,%ebp
  801404:	57                   	push   %edi
  801405:	56                   	push   %esi
  801406:	53                   	push   %ebx
  801407:	83 ec 0c             	sub    $0xc,%esp
  80140a:	8b 75 10             	mov    0x10(%ebp),%esi
  80140d:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;
    if (pg == NULL) pg = (void *)UTOP;
  801410:	85 f6                	test   %esi,%esi
  801412:	75 05                	jne    801419 <ipc_send+0x18>
  801414:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
  801419:	57                   	push   %edi
  80141a:	56                   	push   %esi
  80141b:	ff 75 0c             	pushl  0xc(%ebp)
  80141e:	ff 75 08             	pushl  0x8(%ebp)
  801421:	e8 02 ff ff ff       	call   801328 <sys_ipc_try_send>
  801426:	89 c3                	mov    %eax,%ebx
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
  801428:	83 c4 10             	add    $0x10,%esp
  80142b:	85 c0                	test   %eax,%eax
  80142d:	79 17                	jns    801446 <ipc_send+0x45>
  80142f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801432:	74 1d                	je     801451 <ipc_send+0x50>
  801434:	50                   	push   %eax
  801435:	68 2a 2b 80 00       	push   $0x802b2a
  80143a:	6a 40                	push   $0x40
  80143c:	68 3e 2b 80 00       	push   $0x802b3e
  801441:	e8 28 f2 ff ff       	call   80066e <_panic>
        sys_yield();
  801446:	e8 31 fd ff ff       	call   80117c <sys_yield>
    } while (r != 0);
  80144b:	85 db                	test   %ebx,%ebx
  80144d:	75 ca                	jne    801419 <ipc_send+0x18>
  80144f:	eb 07                	jmp    801458 <ipc_send+0x57>
	int r;
    if (pg == NULL) pg = (void *)UTOP;
    do {
        r = sys_ipc_try_send(to_env, val, pg, perm);
        if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
        sys_yield();
  801451:	e8 26 fd ff ff       	call   80117c <sys_yield>
  801456:	eb c1                	jmp    801419 <ipc_send+0x18>
    } while (r != 0);
}
  801458:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80145b:	5b                   	pop    %ebx
  80145c:	5e                   	pop    %esi
  80145d:	5f                   	pop    %edi
  80145e:	5d                   	pop    %ebp
  80145f:	c3                   	ret    

00801460 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801460:	55                   	push   %ebp
  801461:	89 e5                	mov    %esp,%ebp
  801463:	53                   	push   %ebx
  801464:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801467:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  80146c:	39 c1                	cmp    %eax,%ecx
  80146e:	74 21                	je     801491 <ipc_find_env+0x31>
  801470:	ba 01 00 00 00       	mov    $0x1,%edx
  801475:	8d 1c 95 00 00 00 00 	lea    0x0(,%edx,4),%ebx
  80147c:	89 d0                	mov    %edx,%eax
  80147e:	c1 e0 07             	shl    $0x7,%eax
  801481:	29 d8                	sub    %ebx,%eax
  801483:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801488:	8b 40 50             	mov    0x50(%eax),%eax
  80148b:	39 c8                	cmp    %ecx,%eax
  80148d:	75 1b                	jne    8014aa <ipc_find_env+0x4a>
  80148f:	eb 05                	jmp    801496 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801491:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801496:	8d 04 95 00 00 00 00 	lea    0x0(,%edx,4),%eax
  80149d:	c1 e2 07             	shl    $0x7,%edx
  8014a0:	29 c2                	sub    %eax,%edx
  8014a2:	8b 82 48 00 c0 ee    	mov    -0x113fffb8(%edx),%eax
  8014a8:	eb 0e                	jmp    8014b8 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8014aa:	42                   	inc    %edx
  8014ab:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  8014b1:	75 c2                	jne    801475 <ipc_find_env+0x15>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8014b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014b8:	5b                   	pop    %ebx
  8014b9:	5d                   	pop    %ebp
  8014ba:	c3                   	ret    

008014bb <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8014bb:	55                   	push   %ebp
  8014bc:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014be:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c1:	05 00 00 00 30       	add    $0x30000000,%eax
  8014c6:	c1 e8 0c             	shr    $0xc,%eax
}
  8014c9:	5d                   	pop    %ebp
  8014ca:	c3                   	ret    

008014cb <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8014cb:	55                   	push   %ebp
  8014cc:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8014ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8014d1:	05 00 00 00 30       	add    $0x30000000,%eax
  8014d6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8014db:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8014e0:	5d                   	pop    %ebp
  8014e1:	c3                   	ret    

008014e2 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8014e2:	55                   	push   %ebp
  8014e3:	89 e5                	mov    %esp,%ebp
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8014e5:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8014ea:	a8 01                	test   $0x1,%al
  8014ec:	74 34                	je     801522 <fd_alloc+0x40>
  8014ee:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8014f3:	a8 01                	test   $0x1,%al
  8014f5:	74 32                	je     801529 <fd_alloc+0x47>
  8014f7:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8014fc:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8014fe:	89 c2                	mov    %eax,%edx
  801500:	c1 ea 16             	shr    $0x16,%edx
  801503:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80150a:	f6 c2 01             	test   $0x1,%dl
  80150d:	74 1f                	je     80152e <fd_alloc+0x4c>
  80150f:	89 c2                	mov    %eax,%edx
  801511:	c1 ea 0c             	shr    $0xc,%edx
  801514:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80151b:	f6 c2 01             	test   $0x1,%dl
  80151e:	75 1a                	jne    80153a <fd_alloc+0x58>
  801520:	eb 0c                	jmp    80152e <fd_alloc+0x4c>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801522:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801527:	eb 05                	jmp    80152e <fd_alloc+0x4c>
  801529:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  80152e:	8b 45 08             	mov    0x8(%ebp),%eax
  801531:	89 08                	mov    %ecx,(%eax)
			return 0;
  801533:	b8 00 00 00 00       	mov    $0x0,%eax
  801538:	eb 1a                	jmp    801554 <fd_alloc+0x72>
  80153a:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80153f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801544:	75 b6                	jne    8014fc <fd_alloc+0x1a>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801546:	8b 45 08             	mov    0x8(%ebp),%eax
  801549:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  80154f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801554:	5d                   	pop    %ebp
  801555:	c3                   	ret    

00801556 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801556:	55                   	push   %ebp
  801557:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801559:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  80155d:	77 39                	ja     801598 <fd_lookup+0x42>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80155f:	8b 45 08             	mov    0x8(%ebp),%eax
  801562:	c1 e0 0c             	shl    $0xc,%eax
  801565:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80156a:	89 c2                	mov    %eax,%edx
  80156c:	c1 ea 16             	shr    $0x16,%edx
  80156f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801576:	f6 c2 01             	test   $0x1,%dl
  801579:	74 24                	je     80159f <fd_lookup+0x49>
  80157b:	89 c2                	mov    %eax,%edx
  80157d:	c1 ea 0c             	shr    $0xc,%edx
  801580:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801587:	f6 c2 01             	test   $0x1,%dl
  80158a:	74 1a                	je     8015a6 <fd_lookup+0x50>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80158c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80158f:	89 02                	mov    %eax,(%edx)
	return 0;
  801591:	b8 00 00 00 00       	mov    $0x0,%eax
  801596:	eb 13                	jmp    8015ab <fd_lookup+0x55>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801598:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80159d:	eb 0c                	jmp    8015ab <fd_lookup+0x55>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80159f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015a4:	eb 05                	jmp    8015ab <fd_lookup+0x55>
  8015a6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8015ab:	5d                   	pop    %ebp
  8015ac:	c3                   	ret    

008015ad <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8015ad:	55                   	push   %ebp
  8015ae:	89 e5                	mov    %esp,%ebp
  8015b0:	53                   	push   %ebx
  8015b1:	83 ec 04             	sub    $0x4,%esp
  8015b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8015b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8015ba:	3b 05 08 30 80 00    	cmp    0x803008,%eax
  8015c0:	75 1e                	jne    8015e0 <dev_lookup+0x33>
  8015c2:	eb 0e                	jmp    8015d2 <dev_lookup+0x25>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8015c4:	b8 24 30 80 00       	mov    $0x803024,%eax
  8015c9:	eb 0c                	jmp    8015d7 <dev_lookup+0x2a>
  8015cb:	b8 40 30 80 00       	mov    $0x803040,%eax
  8015d0:	eb 05                	jmp    8015d7 <dev_lookup+0x2a>
  8015d2:	b8 08 30 80 00       	mov    $0x803008,%eax
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  8015d7:	89 03                	mov    %eax,(%ebx)
			return 0;
  8015d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8015de:	eb 36                	jmp    801616 <dev_lookup+0x69>
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8015e0:	3b 05 24 30 80 00    	cmp    0x803024,%eax
  8015e6:	74 dc                	je     8015c4 <dev_lookup+0x17>
  8015e8:	3b 05 40 30 80 00    	cmp    0x803040,%eax
  8015ee:	74 db                	je     8015cb <dev_lookup+0x1e>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8015f0:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8015f6:	8b 52 48             	mov    0x48(%edx),%edx
  8015f9:	83 ec 04             	sub    $0x4,%esp
  8015fc:	50                   	push   %eax
  8015fd:	52                   	push   %edx
  8015fe:	68 48 2b 80 00       	push   $0x802b48
  801603:	e8 3e f1 ff ff       	call   800746 <cprintf>
	*dev = 0;
  801608:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80160e:	83 c4 10             	add    $0x10,%esp
  801611:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801616:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801619:	c9                   	leave  
  80161a:	c3                   	ret    

0080161b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80161b:	55                   	push   %ebp
  80161c:	89 e5                	mov    %esp,%ebp
  80161e:	56                   	push   %esi
  80161f:	53                   	push   %ebx
  801620:	83 ec 10             	sub    $0x10,%esp
  801623:	8b 75 08             	mov    0x8(%ebp),%esi
  801626:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801629:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80162c:	50                   	push   %eax
  80162d:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801633:	c1 e8 0c             	shr    $0xc,%eax
  801636:	50                   	push   %eax
  801637:	e8 1a ff ff ff       	call   801556 <fd_lookup>
  80163c:	83 c4 08             	add    $0x8,%esp
  80163f:	85 c0                	test   %eax,%eax
  801641:	78 05                	js     801648 <fd_close+0x2d>
	    || fd != fd2)
  801643:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801646:	74 06                	je     80164e <fd_close+0x33>
		return (must_exist ? r : 0);
  801648:	84 db                	test   %bl,%bl
  80164a:	74 47                	je     801693 <fd_close+0x78>
  80164c:	eb 4a                	jmp    801698 <fd_close+0x7d>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80164e:	83 ec 08             	sub    $0x8,%esp
  801651:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801654:	50                   	push   %eax
  801655:	ff 36                	pushl  (%esi)
  801657:	e8 51 ff ff ff       	call   8015ad <dev_lookup>
  80165c:	89 c3                	mov    %eax,%ebx
  80165e:	83 c4 10             	add    $0x10,%esp
  801661:	85 c0                	test   %eax,%eax
  801663:	78 1c                	js     801681 <fd_close+0x66>
		if (dev->dev_close)
  801665:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801668:	8b 40 10             	mov    0x10(%eax),%eax
  80166b:	85 c0                	test   %eax,%eax
  80166d:	74 0d                	je     80167c <fd_close+0x61>
			r = (*dev->dev_close)(fd);
  80166f:	83 ec 0c             	sub    $0xc,%esp
  801672:	56                   	push   %esi
  801673:	ff d0                	call   *%eax
  801675:	89 c3                	mov    %eax,%ebx
  801677:	83 c4 10             	add    $0x10,%esp
  80167a:	eb 05                	jmp    801681 <fd_close+0x66>
		else
			r = 0;
  80167c:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801681:	83 ec 08             	sub    $0x8,%esp
  801684:	56                   	push   %esi
  801685:	6a 00                	push   $0x0
  801687:	e8 94 fb ff ff       	call   801220 <sys_page_unmap>
	return r;
  80168c:	83 c4 10             	add    $0x10,%esp
  80168f:	89 d8                	mov    %ebx,%eax
  801691:	eb 05                	jmp    801698 <fd_close+0x7d>
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
  801693:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
	return r;
}
  801698:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80169b:	5b                   	pop    %ebx
  80169c:	5e                   	pop    %esi
  80169d:	5d                   	pop    %ebp
  80169e:	c3                   	ret    

0080169f <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80169f:	55                   	push   %ebp
  8016a0:	89 e5                	mov    %esp,%ebp
  8016a2:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016a8:	50                   	push   %eax
  8016a9:	ff 75 08             	pushl  0x8(%ebp)
  8016ac:	e8 a5 fe ff ff       	call   801556 <fd_lookup>
  8016b1:	83 c4 08             	add    $0x8,%esp
  8016b4:	85 c0                	test   %eax,%eax
  8016b6:	78 10                	js     8016c8 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8016b8:	83 ec 08             	sub    $0x8,%esp
  8016bb:	6a 01                	push   $0x1
  8016bd:	ff 75 f4             	pushl  -0xc(%ebp)
  8016c0:	e8 56 ff ff ff       	call   80161b <fd_close>
  8016c5:	83 c4 10             	add    $0x10,%esp
}
  8016c8:	c9                   	leave  
  8016c9:	c3                   	ret    

008016ca <close_all>:

void
close_all(void)
{
  8016ca:	55                   	push   %ebp
  8016cb:	89 e5                	mov    %esp,%ebp
  8016cd:	53                   	push   %ebx
  8016ce:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8016d1:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8016d6:	83 ec 0c             	sub    $0xc,%esp
  8016d9:	53                   	push   %ebx
  8016da:	e8 c0 ff ff ff       	call   80169f <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8016df:	43                   	inc    %ebx
  8016e0:	83 c4 10             	add    $0x10,%esp
  8016e3:	83 fb 20             	cmp    $0x20,%ebx
  8016e6:	75 ee                	jne    8016d6 <close_all+0xc>
		close(i);
}
  8016e8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016eb:	c9                   	leave  
  8016ec:	c3                   	ret    

008016ed <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8016ed:	55                   	push   %ebp
  8016ee:	89 e5                	mov    %esp,%ebp
  8016f0:	57                   	push   %edi
  8016f1:	56                   	push   %esi
  8016f2:	53                   	push   %ebx
  8016f3:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8016f6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8016f9:	50                   	push   %eax
  8016fa:	ff 75 08             	pushl  0x8(%ebp)
  8016fd:	e8 54 fe ff ff       	call   801556 <fd_lookup>
  801702:	83 c4 08             	add    $0x8,%esp
  801705:	85 c0                	test   %eax,%eax
  801707:	0f 88 c2 00 00 00    	js     8017cf <dup+0xe2>
		return r;
	close(newfdnum);
  80170d:	83 ec 0c             	sub    $0xc,%esp
  801710:	ff 75 0c             	pushl  0xc(%ebp)
  801713:	e8 87 ff ff ff       	call   80169f <close>

	newfd = INDEX2FD(newfdnum);
  801718:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80171b:	c1 e3 0c             	shl    $0xc,%ebx
  80171e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801724:	83 c4 04             	add    $0x4,%esp
  801727:	ff 75 e4             	pushl  -0x1c(%ebp)
  80172a:	e8 9c fd ff ff       	call   8014cb <fd2data>
  80172f:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  801731:	89 1c 24             	mov    %ebx,(%esp)
  801734:	e8 92 fd ff ff       	call   8014cb <fd2data>
  801739:	83 c4 10             	add    $0x10,%esp
  80173c:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80173e:	89 f0                	mov    %esi,%eax
  801740:	c1 e8 16             	shr    $0x16,%eax
  801743:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80174a:	a8 01                	test   $0x1,%al
  80174c:	74 35                	je     801783 <dup+0x96>
  80174e:	89 f0                	mov    %esi,%eax
  801750:	c1 e8 0c             	shr    $0xc,%eax
  801753:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80175a:	f6 c2 01             	test   $0x1,%dl
  80175d:	74 24                	je     801783 <dup+0x96>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80175f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801766:	83 ec 0c             	sub    $0xc,%esp
  801769:	25 07 0e 00 00       	and    $0xe07,%eax
  80176e:	50                   	push   %eax
  80176f:	57                   	push   %edi
  801770:	6a 00                	push   $0x0
  801772:	56                   	push   %esi
  801773:	6a 00                	push   $0x0
  801775:	e8 64 fa ff ff       	call   8011de <sys_page_map>
  80177a:	89 c6                	mov    %eax,%esi
  80177c:	83 c4 20             	add    $0x20,%esp
  80177f:	85 c0                	test   %eax,%eax
  801781:	78 2c                	js     8017af <dup+0xc2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801783:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801786:	89 d0                	mov    %edx,%eax
  801788:	c1 e8 0c             	shr    $0xc,%eax
  80178b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801792:	83 ec 0c             	sub    $0xc,%esp
  801795:	25 07 0e 00 00       	and    $0xe07,%eax
  80179a:	50                   	push   %eax
  80179b:	53                   	push   %ebx
  80179c:	6a 00                	push   $0x0
  80179e:	52                   	push   %edx
  80179f:	6a 00                	push   $0x0
  8017a1:	e8 38 fa ff ff       	call   8011de <sys_page_map>
  8017a6:	89 c6                	mov    %eax,%esi
  8017a8:	83 c4 20             	add    $0x20,%esp
  8017ab:	85 c0                	test   %eax,%eax
  8017ad:	79 1d                	jns    8017cc <dup+0xdf>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8017af:	83 ec 08             	sub    $0x8,%esp
  8017b2:	53                   	push   %ebx
  8017b3:	6a 00                	push   $0x0
  8017b5:	e8 66 fa ff ff       	call   801220 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8017ba:	83 c4 08             	add    $0x8,%esp
  8017bd:	57                   	push   %edi
  8017be:	6a 00                	push   $0x0
  8017c0:	e8 5b fa ff ff       	call   801220 <sys_page_unmap>
	return r;
  8017c5:	83 c4 10             	add    $0x10,%esp
  8017c8:	89 f0                	mov    %esi,%eax
  8017ca:	eb 03                	jmp    8017cf <dup+0xe2>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8017cc:	8b 45 0c             	mov    0xc(%ebp),%eax

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8017cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017d2:	5b                   	pop    %ebx
  8017d3:	5e                   	pop    %esi
  8017d4:	5f                   	pop    %edi
  8017d5:	5d                   	pop    %ebp
  8017d6:	c3                   	ret    

008017d7 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8017d7:	55                   	push   %ebp
  8017d8:	89 e5                	mov    %esp,%ebp
  8017da:	53                   	push   %ebx
  8017db:	83 ec 14             	sub    $0x14,%esp
  8017de:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017e1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017e4:	50                   	push   %eax
  8017e5:	53                   	push   %ebx
  8017e6:	e8 6b fd ff ff       	call   801556 <fd_lookup>
  8017eb:	83 c4 08             	add    $0x8,%esp
  8017ee:	85 c0                	test   %eax,%eax
  8017f0:	78 67                	js     801859 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017f2:	83 ec 08             	sub    $0x8,%esp
  8017f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017f8:	50                   	push   %eax
  8017f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017fc:	ff 30                	pushl  (%eax)
  8017fe:	e8 aa fd ff ff       	call   8015ad <dev_lookup>
  801803:	83 c4 10             	add    $0x10,%esp
  801806:	85 c0                	test   %eax,%eax
  801808:	78 4f                	js     801859 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80180a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80180d:	8b 42 08             	mov    0x8(%edx),%eax
  801810:	83 e0 03             	and    $0x3,%eax
  801813:	83 f8 01             	cmp    $0x1,%eax
  801816:	75 21                	jne    801839 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801818:	a1 04 40 80 00       	mov    0x804004,%eax
  80181d:	8b 40 48             	mov    0x48(%eax),%eax
  801820:	83 ec 04             	sub    $0x4,%esp
  801823:	53                   	push   %ebx
  801824:	50                   	push   %eax
  801825:	68 8c 2b 80 00       	push   $0x802b8c
  80182a:	e8 17 ef ff ff       	call   800746 <cprintf>
		return -E_INVAL;
  80182f:	83 c4 10             	add    $0x10,%esp
  801832:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801837:	eb 20                	jmp    801859 <read+0x82>
	}
	if (!dev->dev_read)
  801839:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80183c:	8b 40 08             	mov    0x8(%eax),%eax
  80183f:	85 c0                	test   %eax,%eax
  801841:	74 11                	je     801854 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801843:	83 ec 04             	sub    $0x4,%esp
  801846:	ff 75 10             	pushl  0x10(%ebp)
  801849:	ff 75 0c             	pushl  0xc(%ebp)
  80184c:	52                   	push   %edx
  80184d:	ff d0                	call   *%eax
  80184f:	83 c4 10             	add    $0x10,%esp
  801852:	eb 05                	jmp    801859 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801854:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801859:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80185c:	c9                   	leave  
  80185d:	c3                   	ret    

0080185e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80185e:	55                   	push   %ebp
  80185f:	89 e5                	mov    %esp,%ebp
  801861:	57                   	push   %edi
  801862:	56                   	push   %esi
  801863:	53                   	push   %ebx
  801864:	83 ec 0c             	sub    $0xc,%esp
  801867:	8b 7d 08             	mov    0x8(%ebp),%edi
  80186a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80186d:	85 f6                	test   %esi,%esi
  80186f:	74 31                	je     8018a2 <readn+0x44>
  801871:	b8 00 00 00 00       	mov    $0x0,%eax
  801876:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  80187b:	83 ec 04             	sub    $0x4,%esp
  80187e:	89 f2                	mov    %esi,%edx
  801880:	29 c2                	sub    %eax,%edx
  801882:	52                   	push   %edx
  801883:	03 45 0c             	add    0xc(%ebp),%eax
  801886:	50                   	push   %eax
  801887:	57                   	push   %edi
  801888:	e8 4a ff ff ff       	call   8017d7 <read>
		if (m < 0)
  80188d:	83 c4 10             	add    $0x10,%esp
  801890:	85 c0                	test   %eax,%eax
  801892:	78 17                	js     8018ab <readn+0x4d>
			return m;
		if (m == 0)
  801894:	85 c0                	test   %eax,%eax
  801896:	74 11                	je     8018a9 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801898:	01 c3                	add    %eax,%ebx
  80189a:	89 d8                	mov    %ebx,%eax
  80189c:	39 f3                	cmp    %esi,%ebx
  80189e:	72 db                	jb     80187b <readn+0x1d>
  8018a0:	eb 09                	jmp    8018ab <readn+0x4d>
  8018a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8018a7:	eb 02                	jmp    8018ab <readn+0x4d>
  8018a9:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8018ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018ae:	5b                   	pop    %ebx
  8018af:	5e                   	pop    %esi
  8018b0:	5f                   	pop    %edi
  8018b1:	5d                   	pop    %ebp
  8018b2:	c3                   	ret    

008018b3 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8018b3:	55                   	push   %ebp
  8018b4:	89 e5                	mov    %esp,%ebp
  8018b6:	53                   	push   %ebx
  8018b7:	83 ec 14             	sub    $0x14,%esp
  8018ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018bd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018c0:	50                   	push   %eax
  8018c1:	53                   	push   %ebx
  8018c2:	e8 8f fc ff ff       	call   801556 <fd_lookup>
  8018c7:	83 c4 08             	add    $0x8,%esp
  8018ca:	85 c0                	test   %eax,%eax
  8018cc:	78 62                	js     801930 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018ce:	83 ec 08             	sub    $0x8,%esp
  8018d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018d4:	50                   	push   %eax
  8018d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018d8:	ff 30                	pushl  (%eax)
  8018da:	e8 ce fc ff ff       	call   8015ad <dev_lookup>
  8018df:	83 c4 10             	add    $0x10,%esp
  8018e2:	85 c0                	test   %eax,%eax
  8018e4:	78 4a                	js     801930 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018e9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018ed:	75 21                	jne    801910 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8018ef:	a1 04 40 80 00       	mov    0x804004,%eax
  8018f4:	8b 40 48             	mov    0x48(%eax),%eax
  8018f7:	83 ec 04             	sub    $0x4,%esp
  8018fa:	53                   	push   %ebx
  8018fb:	50                   	push   %eax
  8018fc:	68 a8 2b 80 00       	push   $0x802ba8
  801901:	e8 40 ee ff ff       	call   800746 <cprintf>
		return -E_INVAL;
  801906:	83 c4 10             	add    $0x10,%esp
  801909:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80190e:	eb 20                	jmp    801930 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801910:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801913:	8b 52 0c             	mov    0xc(%edx),%edx
  801916:	85 d2                	test   %edx,%edx
  801918:	74 11                	je     80192b <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80191a:	83 ec 04             	sub    $0x4,%esp
  80191d:	ff 75 10             	pushl  0x10(%ebp)
  801920:	ff 75 0c             	pushl  0xc(%ebp)
  801923:	50                   	push   %eax
  801924:	ff d2                	call   *%edx
  801926:	83 c4 10             	add    $0x10,%esp
  801929:	eb 05                	jmp    801930 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80192b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801930:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801933:	c9                   	leave  
  801934:	c3                   	ret    

00801935 <seek>:

int
seek(int fdnum, off_t offset)
{
  801935:	55                   	push   %ebp
  801936:	89 e5                	mov    %esp,%ebp
  801938:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80193b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80193e:	50                   	push   %eax
  80193f:	ff 75 08             	pushl  0x8(%ebp)
  801942:	e8 0f fc ff ff       	call   801556 <fd_lookup>
  801947:	83 c4 08             	add    $0x8,%esp
  80194a:	85 c0                	test   %eax,%eax
  80194c:	78 0e                	js     80195c <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80194e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801951:	8b 55 0c             	mov    0xc(%ebp),%edx
  801954:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801957:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80195c:	c9                   	leave  
  80195d:	c3                   	ret    

0080195e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80195e:	55                   	push   %ebp
  80195f:	89 e5                	mov    %esp,%ebp
  801961:	53                   	push   %ebx
  801962:	83 ec 14             	sub    $0x14,%esp
  801965:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801968:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80196b:	50                   	push   %eax
  80196c:	53                   	push   %ebx
  80196d:	e8 e4 fb ff ff       	call   801556 <fd_lookup>
  801972:	83 c4 08             	add    $0x8,%esp
  801975:	85 c0                	test   %eax,%eax
  801977:	78 5f                	js     8019d8 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801979:	83 ec 08             	sub    $0x8,%esp
  80197c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80197f:	50                   	push   %eax
  801980:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801983:	ff 30                	pushl  (%eax)
  801985:	e8 23 fc ff ff       	call   8015ad <dev_lookup>
  80198a:	83 c4 10             	add    $0x10,%esp
  80198d:	85 c0                	test   %eax,%eax
  80198f:	78 47                	js     8019d8 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801991:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801994:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801998:	75 21                	jne    8019bb <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80199a:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80199f:	8b 40 48             	mov    0x48(%eax),%eax
  8019a2:	83 ec 04             	sub    $0x4,%esp
  8019a5:	53                   	push   %ebx
  8019a6:	50                   	push   %eax
  8019a7:	68 68 2b 80 00       	push   $0x802b68
  8019ac:	e8 95 ed ff ff       	call   800746 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8019b1:	83 c4 10             	add    $0x10,%esp
  8019b4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8019b9:	eb 1d                	jmp    8019d8 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  8019bb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019be:	8b 52 18             	mov    0x18(%edx),%edx
  8019c1:	85 d2                	test   %edx,%edx
  8019c3:	74 0e                	je     8019d3 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8019c5:	83 ec 08             	sub    $0x8,%esp
  8019c8:	ff 75 0c             	pushl  0xc(%ebp)
  8019cb:	50                   	push   %eax
  8019cc:	ff d2                	call   *%edx
  8019ce:	83 c4 10             	add    $0x10,%esp
  8019d1:	eb 05                	jmp    8019d8 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8019d3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8019d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019db:	c9                   	leave  
  8019dc:	c3                   	ret    

008019dd <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8019dd:	55                   	push   %ebp
  8019de:	89 e5                	mov    %esp,%ebp
  8019e0:	53                   	push   %ebx
  8019e1:	83 ec 14             	sub    $0x14,%esp
  8019e4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019e7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019ea:	50                   	push   %eax
  8019eb:	ff 75 08             	pushl  0x8(%ebp)
  8019ee:	e8 63 fb ff ff       	call   801556 <fd_lookup>
  8019f3:	83 c4 08             	add    $0x8,%esp
  8019f6:	85 c0                	test   %eax,%eax
  8019f8:	78 52                	js     801a4c <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019fa:	83 ec 08             	sub    $0x8,%esp
  8019fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a00:	50                   	push   %eax
  801a01:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a04:	ff 30                	pushl  (%eax)
  801a06:	e8 a2 fb ff ff       	call   8015ad <dev_lookup>
  801a0b:	83 c4 10             	add    $0x10,%esp
  801a0e:	85 c0                	test   %eax,%eax
  801a10:	78 3a                	js     801a4c <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  801a12:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a15:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801a19:	74 2c                	je     801a47 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801a1b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801a1e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801a25:	00 00 00 
	stat->st_isdir = 0;
  801a28:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a2f:	00 00 00 
	stat->st_dev = dev;
  801a32:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801a38:	83 ec 08             	sub    $0x8,%esp
  801a3b:	53                   	push   %ebx
  801a3c:	ff 75 f0             	pushl  -0x10(%ebp)
  801a3f:	ff 50 14             	call   *0x14(%eax)
  801a42:	83 c4 10             	add    $0x10,%esp
  801a45:	eb 05                	jmp    801a4c <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801a47:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801a4c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a4f:	c9                   	leave  
  801a50:	c3                   	ret    

00801a51 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801a51:	55                   	push   %ebp
  801a52:	89 e5                	mov    %esp,%ebp
  801a54:	56                   	push   %esi
  801a55:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a56:	83 ec 08             	sub    $0x8,%esp
  801a59:	6a 00                	push   $0x0
  801a5b:	ff 75 08             	pushl  0x8(%ebp)
  801a5e:	e8 75 01 00 00       	call   801bd8 <open>
  801a63:	89 c3                	mov    %eax,%ebx
  801a65:	83 c4 10             	add    $0x10,%esp
  801a68:	85 c0                	test   %eax,%eax
  801a6a:	78 1d                	js     801a89 <stat+0x38>
		return fd;
	r = fstat(fd, stat);
  801a6c:	83 ec 08             	sub    $0x8,%esp
  801a6f:	ff 75 0c             	pushl  0xc(%ebp)
  801a72:	50                   	push   %eax
  801a73:	e8 65 ff ff ff       	call   8019dd <fstat>
  801a78:	89 c6                	mov    %eax,%esi
	close(fd);
  801a7a:	89 1c 24             	mov    %ebx,(%esp)
  801a7d:	e8 1d fc ff ff       	call   80169f <close>
	return r;
  801a82:	83 c4 10             	add    $0x10,%esp
  801a85:	89 f0                	mov    %esi,%eax
  801a87:	eb 00                	jmp    801a89 <stat+0x38>
}
  801a89:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a8c:	5b                   	pop    %ebx
  801a8d:	5e                   	pop    %esi
  801a8e:	5d                   	pop    %ebp
  801a8f:	c3                   	ret    

00801a90 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a90:	55                   	push   %ebp
  801a91:	89 e5                	mov    %esp,%ebp
  801a93:	56                   	push   %esi
  801a94:	53                   	push   %ebx
  801a95:	89 c6                	mov    %eax,%esi
  801a97:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801a99:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801aa0:	75 12                	jne    801ab4 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801aa2:	83 ec 0c             	sub    $0xc,%esp
  801aa5:	6a 01                	push   $0x1
  801aa7:	e8 b4 f9 ff ff       	call   801460 <ipc_find_env>
  801aac:	a3 00 40 80 00       	mov    %eax,0x804000
  801ab1:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801ab4:	6a 07                	push   $0x7
  801ab6:	68 00 50 80 00       	push   $0x805000
  801abb:	56                   	push   %esi
  801abc:	ff 35 00 40 80 00    	pushl  0x804000
  801ac2:	e8 3a f9 ff ff       	call   801401 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801ac7:	83 c4 0c             	add    $0xc,%esp
  801aca:	6a 00                	push   $0x0
  801acc:	53                   	push   %ebx
  801acd:	6a 00                	push   $0x0
  801acf:	e8 b8 f8 ff ff       	call   80138c <ipc_recv>
}
  801ad4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ad7:	5b                   	pop    %ebx
  801ad8:	5e                   	pop    %esi
  801ad9:	5d                   	pop    %ebp
  801ada:	c3                   	ret    

00801adb <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801adb:	55                   	push   %ebp
  801adc:	89 e5                	mov    %esp,%ebp
  801ade:	53                   	push   %ebx
  801adf:	83 ec 04             	sub    $0x4,%esp
  801ae2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801ae5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae8:	8b 40 0c             	mov    0xc(%eax),%eax
  801aeb:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801af0:	ba 00 00 00 00       	mov    $0x0,%edx
  801af5:	b8 05 00 00 00       	mov    $0x5,%eax
  801afa:	e8 91 ff ff ff       	call   801a90 <fsipc>
  801aff:	85 c0                	test   %eax,%eax
  801b01:	78 2c                	js     801b2f <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801b03:	83 ec 08             	sub    $0x8,%esp
  801b06:	68 00 50 80 00       	push   $0x805000
  801b0b:	53                   	push   %ebx
  801b0c:	e8 1a f2 ff ff       	call   800d2b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801b11:	a1 80 50 80 00       	mov    0x805080,%eax
  801b16:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b1c:	a1 84 50 80 00       	mov    0x805084,%eax
  801b21:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b27:	83 c4 10             	add    $0x10,%esp
  801b2a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b2f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b32:	c9                   	leave  
  801b33:	c3                   	ret    

00801b34 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801b34:	55                   	push   %ebp
  801b35:	89 e5                	mov    %esp,%ebp
  801b37:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801b3a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b3d:	8b 40 0c             	mov    0xc(%eax),%eax
  801b40:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801b45:	ba 00 00 00 00       	mov    $0x0,%edx
  801b4a:	b8 06 00 00 00       	mov    $0x6,%eax
  801b4f:	e8 3c ff ff ff       	call   801a90 <fsipc>
}
  801b54:	c9                   	leave  
  801b55:	c3                   	ret    

00801b56 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801b56:	55                   	push   %ebp
  801b57:	89 e5                	mov    %esp,%ebp
  801b59:	56                   	push   %esi
  801b5a:	53                   	push   %ebx
  801b5b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b5e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b61:	8b 40 0c             	mov    0xc(%eax),%eax
  801b64:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801b69:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b6f:	ba 00 00 00 00       	mov    $0x0,%edx
  801b74:	b8 03 00 00 00       	mov    $0x3,%eax
  801b79:	e8 12 ff ff ff       	call   801a90 <fsipc>
  801b7e:	89 c3                	mov    %eax,%ebx
  801b80:	85 c0                	test   %eax,%eax
  801b82:	78 4b                	js     801bcf <devfile_read+0x79>
		return r;
	assert(r <= n);
  801b84:	39 c6                	cmp    %eax,%esi
  801b86:	73 16                	jae    801b9e <devfile_read+0x48>
  801b88:	68 c5 2b 80 00       	push   $0x802bc5
  801b8d:	68 cc 2b 80 00       	push   $0x802bcc
  801b92:	6a 7a                	push   $0x7a
  801b94:	68 e1 2b 80 00       	push   $0x802be1
  801b99:	e8 d0 ea ff ff       	call   80066e <_panic>
	assert(r <= PGSIZE);
  801b9e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801ba3:	7e 16                	jle    801bbb <devfile_read+0x65>
  801ba5:	68 ec 2b 80 00       	push   $0x802bec
  801baa:	68 cc 2b 80 00       	push   $0x802bcc
  801baf:	6a 7b                	push   $0x7b
  801bb1:	68 e1 2b 80 00       	push   $0x802be1
  801bb6:	e8 b3 ea ff ff       	call   80066e <_panic>
	memmove(buf, &fsipcbuf, r);
  801bbb:	83 ec 04             	sub    $0x4,%esp
  801bbe:	50                   	push   %eax
  801bbf:	68 00 50 80 00       	push   $0x805000
  801bc4:	ff 75 0c             	pushl  0xc(%ebp)
  801bc7:	e8 2c f3 ff ff       	call   800ef8 <memmove>
	return r;
  801bcc:	83 c4 10             	add    $0x10,%esp
}
  801bcf:	89 d8                	mov    %ebx,%eax
  801bd1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bd4:	5b                   	pop    %ebx
  801bd5:	5e                   	pop    %esi
  801bd6:	5d                   	pop    %ebp
  801bd7:	c3                   	ret    

00801bd8 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801bd8:	55                   	push   %ebp
  801bd9:	89 e5                	mov    %esp,%ebp
  801bdb:	53                   	push   %ebx
  801bdc:	83 ec 20             	sub    $0x20,%esp
  801bdf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801be2:	53                   	push   %ebx
  801be3:	e8 ec f0 ff ff       	call   800cd4 <strlen>
  801be8:	83 c4 10             	add    $0x10,%esp
  801beb:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801bf0:	7f 63                	jg     801c55 <open+0x7d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801bf2:	83 ec 0c             	sub    $0xc,%esp
  801bf5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bf8:	50                   	push   %eax
  801bf9:	e8 e4 f8 ff ff       	call   8014e2 <fd_alloc>
  801bfe:	83 c4 10             	add    $0x10,%esp
  801c01:	85 c0                	test   %eax,%eax
  801c03:	78 55                	js     801c5a <open+0x82>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801c05:	83 ec 08             	sub    $0x8,%esp
  801c08:	53                   	push   %ebx
  801c09:	68 00 50 80 00       	push   $0x805000
  801c0e:	e8 18 f1 ff ff       	call   800d2b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801c13:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c16:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801c1b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c1e:	b8 01 00 00 00       	mov    $0x1,%eax
  801c23:	e8 68 fe ff ff       	call   801a90 <fsipc>
  801c28:	89 c3                	mov    %eax,%ebx
  801c2a:	83 c4 10             	add    $0x10,%esp
  801c2d:	85 c0                	test   %eax,%eax
  801c2f:	79 14                	jns    801c45 <open+0x6d>
		fd_close(fd, 0);
  801c31:	83 ec 08             	sub    $0x8,%esp
  801c34:	6a 00                	push   $0x0
  801c36:	ff 75 f4             	pushl  -0xc(%ebp)
  801c39:	e8 dd f9 ff ff       	call   80161b <fd_close>
		return r;
  801c3e:	83 c4 10             	add    $0x10,%esp
  801c41:	89 d8                	mov    %ebx,%eax
  801c43:	eb 15                	jmp    801c5a <open+0x82>
	}

	return fd2num(fd);
  801c45:	83 ec 0c             	sub    $0xc,%esp
  801c48:	ff 75 f4             	pushl  -0xc(%ebp)
  801c4b:	e8 6b f8 ff ff       	call   8014bb <fd2num>
  801c50:	83 c4 10             	add    $0x10,%esp
  801c53:	eb 05                	jmp    801c5a <open+0x82>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c55:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801c5a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c5d:	c9                   	leave  
  801c5e:	c3                   	ret    

00801c5f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c5f:	55                   	push   %ebp
  801c60:	89 e5                	mov    %esp,%ebp
  801c62:	56                   	push   %esi
  801c63:	53                   	push   %ebx
  801c64:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c67:	83 ec 0c             	sub    $0xc,%esp
  801c6a:	ff 75 08             	pushl  0x8(%ebp)
  801c6d:	e8 59 f8 ff ff       	call   8014cb <fd2data>
  801c72:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c74:	83 c4 08             	add    $0x8,%esp
  801c77:	68 f8 2b 80 00       	push   $0x802bf8
  801c7c:	53                   	push   %ebx
  801c7d:	e8 a9 f0 ff ff       	call   800d2b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c82:	8b 46 04             	mov    0x4(%esi),%eax
  801c85:	2b 06                	sub    (%esi),%eax
  801c87:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c8d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c94:	00 00 00 
	stat->st_dev = &devpipe;
  801c97:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  801c9e:	30 80 00 
	return 0;
}
  801ca1:	b8 00 00 00 00       	mov    $0x0,%eax
  801ca6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ca9:	5b                   	pop    %ebx
  801caa:	5e                   	pop    %esi
  801cab:	5d                   	pop    %ebp
  801cac:	c3                   	ret    

00801cad <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801cad:	55                   	push   %ebp
  801cae:	89 e5                	mov    %esp,%ebp
  801cb0:	53                   	push   %ebx
  801cb1:	83 ec 0c             	sub    $0xc,%esp
  801cb4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801cb7:	53                   	push   %ebx
  801cb8:	6a 00                	push   $0x0
  801cba:	e8 61 f5 ff ff       	call   801220 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801cbf:	89 1c 24             	mov    %ebx,(%esp)
  801cc2:	e8 04 f8 ff ff       	call   8014cb <fd2data>
  801cc7:	83 c4 08             	add    $0x8,%esp
  801cca:	50                   	push   %eax
  801ccb:	6a 00                	push   $0x0
  801ccd:	e8 4e f5 ff ff       	call   801220 <sys_page_unmap>
}
  801cd2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cd5:	c9                   	leave  
  801cd6:	c3                   	ret    

00801cd7 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801cd7:	55                   	push   %ebp
  801cd8:	89 e5                	mov    %esp,%ebp
  801cda:	57                   	push   %edi
  801cdb:	56                   	push   %esi
  801cdc:	53                   	push   %ebx
  801cdd:	83 ec 1c             	sub    $0x1c,%esp
  801ce0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ce3:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ce5:	a1 04 40 80 00       	mov    0x804004,%eax
  801cea:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801ced:	83 ec 0c             	sub    $0xc,%esp
  801cf0:	ff 75 e0             	pushl  -0x20(%ebp)
  801cf3:	e8 5b 04 00 00       	call   802153 <pageref>
  801cf8:	89 c3                	mov    %eax,%ebx
  801cfa:	89 3c 24             	mov    %edi,(%esp)
  801cfd:	e8 51 04 00 00       	call   802153 <pageref>
  801d02:	83 c4 10             	add    $0x10,%esp
  801d05:	39 c3                	cmp    %eax,%ebx
  801d07:	0f 94 c1             	sete   %cl
  801d0a:	0f b6 c9             	movzbl %cl,%ecx
  801d0d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801d10:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801d16:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801d19:	39 ce                	cmp    %ecx,%esi
  801d1b:	74 1b                	je     801d38 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801d1d:	39 c3                	cmp    %eax,%ebx
  801d1f:	75 c4                	jne    801ce5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d21:	8b 42 58             	mov    0x58(%edx),%eax
  801d24:	ff 75 e4             	pushl  -0x1c(%ebp)
  801d27:	50                   	push   %eax
  801d28:	56                   	push   %esi
  801d29:	68 ff 2b 80 00       	push   $0x802bff
  801d2e:	e8 13 ea ff ff       	call   800746 <cprintf>
  801d33:	83 c4 10             	add    $0x10,%esp
  801d36:	eb ad                	jmp    801ce5 <_pipeisclosed+0xe>
	}
}
  801d38:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d3e:	5b                   	pop    %ebx
  801d3f:	5e                   	pop    %esi
  801d40:	5f                   	pop    %edi
  801d41:	5d                   	pop    %ebp
  801d42:	c3                   	ret    

00801d43 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d43:	55                   	push   %ebp
  801d44:	89 e5                	mov    %esp,%ebp
  801d46:	57                   	push   %edi
  801d47:	56                   	push   %esi
  801d48:	53                   	push   %ebx
  801d49:	83 ec 18             	sub    $0x18,%esp
  801d4c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801d4f:	56                   	push   %esi
  801d50:	e8 76 f7 ff ff       	call   8014cb <fd2data>
  801d55:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d57:	83 c4 10             	add    $0x10,%esp
  801d5a:	bf 00 00 00 00       	mov    $0x0,%edi
  801d5f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d63:	75 42                	jne    801da7 <devpipe_write+0x64>
  801d65:	eb 4e                	jmp    801db5 <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801d67:	89 da                	mov    %ebx,%edx
  801d69:	89 f0                	mov    %esi,%eax
  801d6b:	e8 67 ff ff ff       	call   801cd7 <_pipeisclosed>
  801d70:	85 c0                	test   %eax,%eax
  801d72:	75 46                	jne    801dba <devpipe_write+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801d74:	e8 03 f4 ff ff       	call   80117c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d79:	8b 53 04             	mov    0x4(%ebx),%edx
  801d7c:	8b 03                	mov    (%ebx),%eax
  801d7e:	83 c0 20             	add    $0x20,%eax
  801d81:	39 c2                	cmp    %eax,%edx
  801d83:	73 e2                	jae    801d67 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d85:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d88:	8a 0c 38             	mov    (%eax,%edi,1),%cl
  801d8b:	89 d0                	mov    %edx,%eax
  801d8d:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801d92:	79 05                	jns    801d99 <devpipe_write+0x56>
  801d94:	48                   	dec    %eax
  801d95:	83 c8 e0             	or     $0xffffffe0,%eax
  801d98:	40                   	inc    %eax
  801d99:	88 4c 03 08          	mov    %cl,0x8(%ebx,%eax,1)
		p->p_wpos++;
  801d9d:	42                   	inc    %edx
  801d9e:	89 53 04             	mov    %edx,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801da1:	47                   	inc    %edi
  801da2:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801da5:	74 0e                	je     801db5 <devpipe_write+0x72>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801da7:	8b 53 04             	mov    0x4(%ebx),%edx
  801daa:	8b 03                	mov    (%ebx),%eax
  801dac:	83 c0 20             	add    $0x20,%eax
  801daf:	39 c2                	cmp    %eax,%edx
  801db1:	73 b4                	jae    801d67 <devpipe_write+0x24>
  801db3:	eb d0                	jmp    801d85 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801db5:	8b 45 10             	mov    0x10(%ebp),%eax
  801db8:	eb 05                	jmp    801dbf <devpipe_write+0x7c>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801dba:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801dbf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dc2:	5b                   	pop    %ebx
  801dc3:	5e                   	pop    %esi
  801dc4:	5f                   	pop    %edi
  801dc5:	5d                   	pop    %ebp
  801dc6:	c3                   	ret    

00801dc7 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801dc7:	55                   	push   %ebp
  801dc8:	89 e5                	mov    %esp,%ebp
  801dca:	57                   	push   %edi
  801dcb:	56                   	push   %esi
  801dcc:	53                   	push   %ebx
  801dcd:	83 ec 18             	sub    $0x18,%esp
  801dd0:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801dd3:	57                   	push   %edi
  801dd4:	e8 f2 f6 ff ff       	call   8014cb <fd2data>
  801dd9:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ddb:	83 c4 10             	add    $0x10,%esp
  801dde:	be 00 00 00 00       	mov    $0x0,%esi
  801de3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801de7:	75 3d                	jne    801e26 <devpipe_read+0x5f>
  801de9:	eb 48                	jmp    801e33 <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801deb:	89 f0                	mov    %esi,%eax
  801ded:	eb 4e                	jmp    801e3d <devpipe_read+0x76>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801def:	89 da                	mov    %ebx,%edx
  801df1:	89 f8                	mov    %edi,%eax
  801df3:	e8 df fe ff ff       	call   801cd7 <_pipeisclosed>
  801df8:	85 c0                	test   %eax,%eax
  801dfa:	75 3c                	jne    801e38 <devpipe_read+0x71>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801dfc:	e8 7b f3 ff ff       	call   80117c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801e01:	8b 03                	mov    (%ebx),%eax
  801e03:	3b 43 04             	cmp    0x4(%ebx),%eax
  801e06:	74 e7                	je     801def <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e08:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801e0d:	79 05                	jns    801e14 <devpipe_read+0x4d>
  801e0f:	48                   	dec    %eax
  801e10:	83 c8 e0             	or     $0xffffffe0,%eax
  801e13:	40                   	inc    %eax
  801e14:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801e18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e1b:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801e1e:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e20:	46                   	inc    %esi
  801e21:	39 75 10             	cmp    %esi,0x10(%ebp)
  801e24:	74 0d                	je     801e33 <devpipe_read+0x6c>
		while (p->p_rpos == p->p_wpos) {
  801e26:	8b 03                	mov    (%ebx),%eax
  801e28:	3b 43 04             	cmp    0x4(%ebx),%eax
  801e2b:	75 db                	jne    801e08 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801e2d:	85 f6                	test   %esi,%esi
  801e2f:	75 ba                	jne    801deb <devpipe_read+0x24>
  801e31:	eb bc                	jmp    801def <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801e33:	8b 45 10             	mov    0x10(%ebp),%eax
  801e36:	eb 05                	jmp    801e3d <devpipe_read+0x76>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e38:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801e3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e40:	5b                   	pop    %ebx
  801e41:	5e                   	pop    %esi
  801e42:	5f                   	pop    %edi
  801e43:	5d                   	pop    %ebp
  801e44:	c3                   	ret    

00801e45 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801e45:	55                   	push   %ebp
  801e46:	89 e5                	mov    %esp,%ebp
  801e48:	56                   	push   %esi
  801e49:	53                   	push   %ebx
  801e4a:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801e4d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e50:	50                   	push   %eax
  801e51:	e8 8c f6 ff ff       	call   8014e2 <fd_alloc>
  801e56:	83 c4 10             	add    $0x10,%esp
  801e59:	85 c0                	test   %eax,%eax
  801e5b:	0f 88 2a 01 00 00    	js     801f8b <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e61:	83 ec 04             	sub    $0x4,%esp
  801e64:	68 07 04 00 00       	push   $0x407
  801e69:	ff 75 f4             	pushl  -0xc(%ebp)
  801e6c:	6a 00                	push   $0x0
  801e6e:	e8 28 f3 ff ff       	call   80119b <sys_page_alloc>
  801e73:	83 c4 10             	add    $0x10,%esp
  801e76:	85 c0                	test   %eax,%eax
  801e78:	0f 88 0d 01 00 00    	js     801f8b <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801e7e:	83 ec 0c             	sub    $0xc,%esp
  801e81:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e84:	50                   	push   %eax
  801e85:	e8 58 f6 ff ff       	call   8014e2 <fd_alloc>
  801e8a:	89 c3                	mov    %eax,%ebx
  801e8c:	83 c4 10             	add    $0x10,%esp
  801e8f:	85 c0                	test   %eax,%eax
  801e91:	0f 88 e2 00 00 00    	js     801f79 <pipe+0x134>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e97:	83 ec 04             	sub    $0x4,%esp
  801e9a:	68 07 04 00 00       	push   $0x407
  801e9f:	ff 75 f0             	pushl  -0x10(%ebp)
  801ea2:	6a 00                	push   $0x0
  801ea4:	e8 f2 f2 ff ff       	call   80119b <sys_page_alloc>
  801ea9:	89 c3                	mov    %eax,%ebx
  801eab:	83 c4 10             	add    $0x10,%esp
  801eae:	85 c0                	test   %eax,%eax
  801eb0:	0f 88 c3 00 00 00    	js     801f79 <pipe+0x134>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801eb6:	83 ec 0c             	sub    $0xc,%esp
  801eb9:	ff 75 f4             	pushl  -0xc(%ebp)
  801ebc:	e8 0a f6 ff ff       	call   8014cb <fd2data>
  801ec1:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ec3:	83 c4 0c             	add    $0xc,%esp
  801ec6:	68 07 04 00 00       	push   $0x407
  801ecb:	50                   	push   %eax
  801ecc:	6a 00                	push   $0x0
  801ece:	e8 c8 f2 ff ff       	call   80119b <sys_page_alloc>
  801ed3:	89 c3                	mov    %eax,%ebx
  801ed5:	83 c4 10             	add    $0x10,%esp
  801ed8:	85 c0                	test   %eax,%eax
  801eda:	0f 88 89 00 00 00    	js     801f69 <pipe+0x124>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ee0:	83 ec 0c             	sub    $0xc,%esp
  801ee3:	ff 75 f0             	pushl  -0x10(%ebp)
  801ee6:	e8 e0 f5 ff ff       	call   8014cb <fd2data>
  801eeb:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ef2:	50                   	push   %eax
  801ef3:	6a 00                	push   $0x0
  801ef5:	56                   	push   %esi
  801ef6:	6a 00                	push   $0x0
  801ef8:	e8 e1 f2 ff ff       	call   8011de <sys_page_map>
  801efd:	89 c3                	mov    %eax,%ebx
  801eff:	83 c4 20             	add    $0x20,%esp
  801f02:	85 c0                	test   %eax,%eax
  801f04:	78 55                	js     801f5b <pipe+0x116>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801f06:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801f0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f0f:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801f11:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f14:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801f1b:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801f21:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f24:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801f26:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f29:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801f30:	83 ec 0c             	sub    $0xc,%esp
  801f33:	ff 75 f4             	pushl  -0xc(%ebp)
  801f36:	e8 80 f5 ff ff       	call   8014bb <fd2num>
  801f3b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f3e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f40:	83 c4 04             	add    $0x4,%esp
  801f43:	ff 75 f0             	pushl  -0x10(%ebp)
  801f46:	e8 70 f5 ff ff       	call   8014bb <fd2num>
  801f4b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f4e:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801f51:	83 c4 10             	add    $0x10,%esp
  801f54:	b8 00 00 00 00       	mov    $0x0,%eax
  801f59:	eb 30                	jmp    801f8b <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801f5b:	83 ec 08             	sub    $0x8,%esp
  801f5e:	56                   	push   %esi
  801f5f:	6a 00                	push   $0x0
  801f61:	e8 ba f2 ff ff       	call   801220 <sys_page_unmap>
  801f66:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801f69:	83 ec 08             	sub    $0x8,%esp
  801f6c:	ff 75 f0             	pushl  -0x10(%ebp)
  801f6f:	6a 00                	push   $0x0
  801f71:	e8 aa f2 ff ff       	call   801220 <sys_page_unmap>
  801f76:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801f79:	83 ec 08             	sub    $0x8,%esp
  801f7c:	ff 75 f4             	pushl  -0xc(%ebp)
  801f7f:	6a 00                	push   $0x0
  801f81:	e8 9a f2 ff ff       	call   801220 <sys_page_unmap>
  801f86:	83 c4 10             	add    $0x10,%esp
  801f89:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  801f8b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f8e:	5b                   	pop    %ebx
  801f8f:	5e                   	pop    %esi
  801f90:	5d                   	pop    %ebp
  801f91:	c3                   	ret    

00801f92 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801f92:	55                   	push   %ebp
  801f93:	89 e5                	mov    %esp,%ebp
  801f95:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f98:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f9b:	50                   	push   %eax
  801f9c:	ff 75 08             	pushl  0x8(%ebp)
  801f9f:	e8 b2 f5 ff ff       	call   801556 <fd_lookup>
  801fa4:	83 c4 10             	add    $0x10,%esp
  801fa7:	85 c0                	test   %eax,%eax
  801fa9:	78 18                	js     801fc3 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801fab:	83 ec 0c             	sub    $0xc,%esp
  801fae:	ff 75 f4             	pushl  -0xc(%ebp)
  801fb1:	e8 15 f5 ff ff       	call   8014cb <fd2data>
	return _pipeisclosed(fd, p);
  801fb6:	89 c2                	mov    %eax,%edx
  801fb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fbb:	e8 17 fd ff ff       	call   801cd7 <_pipeisclosed>
  801fc0:	83 c4 10             	add    $0x10,%esp
}
  801fc3:	c9                   	leave  
  801fc4:	c3                   	ret    

00801fc5 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801fc5:	55                   	push   %ebp
  801fc6:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801fc8:	b8 00 00 00 00       	mov    $0x0,%eax
  801fcd:	5d                   	pop    %ebp
  801fce:	c3                   	ret    

00801fcf <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801fcf:	55                   	push   %ebp
  801fd0:	89 e5                	mov    %esp,%ebp
  801fd2:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801fd5:	68 17 2c 80 00       	push   $0x802c17
  801fda:	ff 75 0c             	pushl  0xc(%ebp)
  801fdd:	e8 49 ed ff ff       	call   800d2b <strcpy>
	return 0;
}
  801fe2:	b8 00 00 00 00       	mov    $0x0,%eax
  801fe7:	c9                   	leave  
  801fe8:	c3                   	ret    

00801fe9 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801fe9:	55                   	push   %ebp
  801fea:	89 e5                	mov    %esp,%ebp
  801fec:	57                   	push   %edi
  801fed:	56                   	push   %esi
  801fee:	53                   	push   %ebx
  801fef:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ff5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ff9:	74 45                	je     802040 <devcons_write+0x57>
  801ffb:	b8 00 00 00 00       	mov    $0x0,%eax
  802000:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802005:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80200b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80200e:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  802010:	83 fb 7f             	cmp    $0x7f,%ebx
  802013:	76 05                	jbe    80201a <devcons_write+0x31>
			m = sizeof(buf) - 1;
  802015:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  80201a:	83 ec 04             	sub    $0x4,%esp
  80201d:	53                   	push   %ebx
  80201e:	03 45 0c             	add    0xc(%ebp),%eax
  802021:	50                   	push   %eax
  802022:	57                   	push   %edi
  802023:	e8 d0 ee ff ff       	call   800ef8 <memmove>
		sys_cputs(buf, m);
  802028:	83 c4 08             	add    $0x8,%esp
  80202b:	53                   	push   %ebx
  80202c:	57                   	push   %edi
  80202d:	e8 ad f0 ff ff       	call   8010df <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802032:	01 de                	add    %ebx,%esi
  802034:	89 f0                	mov    %esi,%eax
  802036:	83 c4 10             	add    $0x10,%esp
  802039:	3b 75 10             	cmp    0x10(%ebp),%esi
  80203c:	72 cd                	jb     80200b <devcons_write+0x22>
  80203e:	eb 05                	jmp    802045 <devcons_write+0x5c>
  802040:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802045:	89 f0                	mov    %esi,%eax
  802047:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80204a:	5b                   	pop    %ebx
  80204b:	5e                   	pop    %esi
  80204c:	5f                   	pop    %edi
  80204d:	5d                   	pop    %ebp
  80204e:	c3                   	ret    

0080204f <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80204f:	55                   	push   %ebp
  802050:	89 e5                	mov    %esp,%ebp
  802052:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  802055:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802059:	75 07                	jne    802062 <devcons_read+0x13>
  80205b:	eb 23                	jmp    802080 <devcons_read+0x31>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80205d:	e8 1a f1 ff ff       	call   80117c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802062:	e8 96 f0 ff ff       	call   8010fd <sys_cgetc>
  802067:	85 c0                	test   %eax,%eax
  802069:	74 f2                	je     80205d <devcons_read+0xe>
		sys_yield();
	if (c < 0)
  80206b:	85 c0                	test   %eax,%eax
  80206d:	78 1d                	js     80208c <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80206f:	83 f8 04             	cmp    $0x4,%eax
  802072:	74 13                	je     802087 <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  802074:	8b 55 0c             	mov    0xc(%ebp),%edx
  802077:	88 02                	mov    %al,(%edx)
	return 1;
  802079:	b8 01 00 00 00       	mov    $0x1,%eax
  80207e:	eb 0c                	jmp    80208c <devcons_read+0x3d>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  802080:	b8 00 00 00 00       	mov    $0x0,%eax
  802085:	eb 05                	jmp    80208c <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802087:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80208c:	c9                   	leave  
  80208d:	c3                   	ret    

0080208e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80208e:	55                   	push   %ebp
  80208f:	89 e5                	mov    %esp,%ebp
  802091:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802094:	8b 45 08             	mov    0x8(%ebp),%eax
  802097:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80209a:	6a 01                	push   $0x1
  80209c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80209f:	50                   	push   %eax
  8020a0:	e8 3a f0 ff ff       	call   8010df <sys_cputs>
}
  8020a5:	83 c4 10             	add    $0x10,%esp
  8020a8:	c9                   	leave  
  8020a9:	c3                   	ret    

008020aa <getchar>:

int
getchar(void)
{
  8020aa:	55                   	push   %ebp
  8020ab:	89 e5                	mov    %esp,%ebp
  8020ad:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8020b0:	6a 01                	push   $0x1
  8020b2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020b5:	50                   	push   %eax
  8020b6:	6a 00                	push   $0x0
  8020b8:	e8 1a f7 ff ff       	call   8017d7 <read>
	if (r < 0)
  8020bd:	83 c4 10             	add    $0x10,%esp
  8020c0:	85 c0                	test   %eax,%eax
  8020c2:	78 0f                	js     8020d3 <getchar+0x29>
		return r;
	if (r < 1)
  8020c4:	85 c0                	test   %eax,%eax
  8020c6:	7e 06                	jle    8020ce <getchar+0x24>
		return -E_EOF;
	return c;
  8020c8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8020cc:	eb 05                	jmp    8020d3 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8020ce:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8020d3:	c9                   	leave  
  8020d4:	c3                   	ret    

008020d5 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8020d5:	55                   	push   %ebp
  8020d6:	89 e5                	mov    %esp,%ebp
  8020d8:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020de:	50                   	push   %eax
  8020df:	ff 75 08             	pushl  0x8(%ebp)
  8020e2:	e8 6f f4 ff ff       	call   801556 <fd_lookup>
  8020e7:	83 c4 10             	add    $0x10,%esp
  8020ea:	85 c0                	test   %eax,%eax
  8020ec:	78 11                	js     8020ff <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8020ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020f1:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8020f7:	39 10                	cmp    %edx,(%eax)
  8020f9:	0f 94 c0             	sete   %al
  8020fc:	0f b6 c0             	movzbl %al,%eax
}
  8020ff:	c9                   	leave  
  802100:	c3                   	ret    

00802101 <opencons>:

int
opencons(void)
{
  802101:	55                   	push   %ebp
  802102:	89 e5                	mov    %esp,%ebp
  802104:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802107:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80210a:	50                   	push   %eax
  80210b:	e8 d2 f3 ff ff       	call   8014e2 <fd_alloc>
  802110:	83 c4 10             	add    $0x10,%esp
  802113:	85 c0                	test   %eax,%eax
  802115:	78 3a                	js     802151 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802117:	83 ec 04             	sub    $0x4,%esp
  80211a:	68 07 04 00 00       	push   $0x407
  80211f:	ff 75 f4             	pushl  -0xc(%ebp)
  802122:	6a 00                	push   $0x0
  802124:	e8 72 f0 ff ff       	call   80119b <sys_page_alloc>
  802129:	83 c4 10             	add    $0x10,%esp
  80212c:	85 c0                	test   %eax,%eax
  80212e:	78 21                	js     802151 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802130:	8b 15 40 30 80 00    	mov    0x803040,%edx
  802136:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802139:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80213b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80213e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802145:	83 ec 0c             	sub    $0xc,%esp
  802148:	50                   	push   %eax
  802149:	e8 6d f3 ff ff       	call   8014bb <fd2num>
  80214e:	83 c4 10             	add    $0x10,%esp
}
  802151:	c9                   	leave  
  802152:	c3                   	ret    

00802153 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802153:	55                   	push   %ebp
  802154:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802156:	8b 45 08             	mov    0x8(%ebp),%eax
  802159:	c1 e8 16             	shr    $0x16,%eax
  80215c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802163:	a8 01                	test   $0x1,%al
  802165:	74 21                	je     802188 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802167:	8b 45 08             	mov    0x8(%ebp),%eax
  80216a:	c1 e8 0c             	shr    $0xc,%eax
  80216d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802174:	a8 01                	test   $0x1,%al
  802176:	74 17                	je     80218f <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802178:	c1 e8 0c             	shr    $0xc,%eax
  80217b:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802182:	ef 
  802183:	0f b7 c0             	movzwl %ax,%eax
  802186:	eb 0c                	jmp    802194 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802188:	b8 00 00 00 00       	mov    $0x0,%eax
  80218d:	eb 05                	jmp    802194 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  80218f:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802194:	5d                   	pop    %ebp
  802195:	c3                   	ret    
  802196:	66 90                	xchg   %ax,%ax

00802198 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802198:	55                   	push   %ebp
  802199:	57                   	push   %edi
  80219a:	56                   	push   %esi
  80219b:	53                   	push   %ebx
  80219c:	83 ec 1c             	sub    $0x1c,%esp
  80219f:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8021a3:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8021a7:	8b 7c 24 38          	mov    0x38(%esp),%edi
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8021ab:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021af:	89 ca                	mov    %ecx,%edx
  const DWunion dd = {.ll = d};
  8021b1:	89 f8                	mov    %edi,%eax
  8021b3:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8021b7:	85 f6                	test   %esi,%esi
  8021b9:	75 2d                	jne    8021e8 <__udivdi3+0x50>
    {
      if (d0 > n1)
  8021bb:	39 cf                	cmp    %ecx,%edi
  8021bd:	77 65                	ja     802224 <__udivdi3+0x8c>
  8021bf:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8021c1:	85 ff                	test   %edi,%edi
  8021c3:	75 0b                	jne    8021d0 <__udivdi3+0x38>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8021c5:	b8 01 00 00 00       	mov    $0x1,%eax
  8021ca:	31 d2                	xor    %edx,%edx
  8021cc:	f7 f7                	div    %edi
  8021ce:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8021d0:	31 d2                	xor    %edx,%edx
  8021d2:	89 c8                	mov    %ecx,%eax
  8021d4:	f7 f5                	div    %ebp
  8021d6:	89 c1                	mov    %eax,%ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8021d8:	89 d8                	mov    %ebx,%eax
  8021da:	f7 f5                	div    %ebp
  8021dc:	89 cf                	mov    %ecx,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8021de:	89 fa                	mov    %edi,%edx
  8021e0:	83 c4 1c             	add    $0x1c,%esp
  8021e3:	5b                   	pop    %ebx
  8021e4:	5e                   	pop    %esi
  8021e5:	5f                   	pop    %edi
  8021e6:	5d                   	pop    %ebp
  8021e7:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8021e8:	39 ce                	cmp    %ecx,%esi
  8021ea:	77 28                	ja     802214 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8021ec:	0f bd fe             	bsr    %esi,%edi
	  if (bm == 0)
  8021ef:	83 f7 1f             	xor    $0x1f,%edi
  8021f2:	75 40                	jne    802234 <__udivdi3+0x9c>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8021f4:	39 ce                	cmp    %ecx,%esi
  8021f6:	72 0a                	jb     802202 <__udivdi3+0x6a>
  8021f8:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8021fc:	0f 87 9e 00 00 00    	ja     8022a0 <__udivdi3+0x108>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802202:	b8 01 00 00 00       	mov    $0x1,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802207:	89 fa                	mov    %edi,%edx
  802209:	83 c4 1c             	add    $0x1c,%esp
  80220c:	5b                   	pop    %ebx
  80220d:	5e                   	pop    %esi
  80220e:	5f                   	pop    %edi
  80220f:	5d                   	pop    %ebp
  802210:	c3                   	ret    
  802211:	8d 76 00             	lea    0x0(%esi),%esi
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802214:	31 ff                	xor    %edi,%edi
  802216:	31 c0                	xor    %eax,%eax
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802218:	89 fa                	mov    %edi,%edx
  80221a:	83 c4 1c             	add    $0x1c,%esp
  80221d:	5b                   	pop    %ebx
  80221e:	5e                   	pop    %esi
  80221f:	5f                   	pop    %edi
  802220:	5d                   	pop    %ebp
  802221:	c3                   	ret    
  802222:	66 90                	xchg   %ax,%ax
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802224:	89 d8                	mov    %ebx,%eax
  802226:	f7 f7                	div    %edi
  802228:	31 ff                	xor    %edi,%edi
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80222a:	89 fa                	mov    %edi,%edx
  80222c:	83 c4 1c             	add    $0x1c,%esp
  80222f:	5b                   	pop    %ebx
  802230:	5e                   	pop    %esi
  802231:	5f                   	pop    %edi
  802232:	5d                   	pop    %ebp
  802233:	c3                   	ret    
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802234:	bd 20 00 00 00       	mov    $0x20,%ebp
  802239:	89 eb                	mov    %ebp,%ebx
  80223b:	29 fb                	sub    %edi,%ebx

	      d1 = (d1 << bm) | (d0 >> b);
  80223d:	89 f9                	mov    %edi,%ecx
  80223f:	d3 e6                	shl    %cl,%esi
  802241:	89 c5                	mov    %eax,%ebp
  802243:	88 d9                	mov    %bl,%cl
  802245:	d3 ed                	shr    %cl,%ebp
  802247:	89 e9                	mov    %ebp,%ecx
  802249:	09 f1                	or     %esi,%ecx
  80224b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
	      d0 = d0 << bm;
  80224f:	89 f9                	mov    %edi,%ecx
  802251:	d3 e0                	shl    %cl,%eax
  802253:	89 c5                	mov    %eax,%ebp
	      n2 = n1 >> b;
  802255:	89 d6                	mov    %edx,%esi
  802257:	88 d9                	mov    %bl,%cl
  802259:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
  80225b:	89 f9                	mov    %edi,%ecx
  80225d:	d3 e2                	shl    %cl,%edx
  80225f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802263:	88 d9                	mov    %bl,%cl
  802265:	d3 e8                	shr    %cl,%eax
  802267:	09 c2                	or     %eax,%edx
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802269:	89 d0                	mov    %edx,%eax
  80226b:	89 f2                	mov    %esi,%edx
  80226d:	f7 74 24 0c          	divl   0xc(%esp)
  802271:	89 d6                	mov    %edx,%esi
  802273:	89 c3                	mov    %eax,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  802275:	f7 e5                	mul    %ebp

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802277:	39 d6                	cmp    %edx,%esi
  802279:	72 19                	jb     802294 <__udivdi3+0xfc>
  80227b:	74 0b                	je     802288 <__udivdi3+0xf0>
  80227d:	89 d8                	mov    %ebx,%eax
  80227f:	31 ff                	xor    %edi,%edi
  802281:	e9 58 ff ff ff       	jmp    8021de <__udivdi3+0x46>
  802286:	66 90                	xchg   %ax,%ax
  802288:	8b 54 24 08          	mov    0x8(%esp),%edx
  80228c:	89 f9                	mov    %edi,%ecx
  80228e:	d3 e2                	shl    %cl,%edx
  802290:	39 c2                	cmp    %eax,%edx
  802292:	73 e9                	jae    80227d <__udivdi3+0xe5>
  802294:	8d 43 ff             	lea    -0x1(%ebx),%eax
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802297:	31 ff                	xor    %edi,%edi
  802299:	e9 40 ff ff ff       	jmp    8021de <__udivdi3+0x46>
  80229e:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8022a0:	31 c0                	xor    %eax,%eax
  8022a2:	e9 37 ff ff ff       	jmp    8021de <__udivdi3+0x46>
  8022a7:	90                   	nop

008022a8 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8022a8:	55                   	push   %ebp
  8022a9:	57                   	push   %edi
  8022aa:	56                   	push   %esi
  8022ab:	53                   	push   %ebx
  8022ac:	83 ec 1c             	sub    $0x1c,%esp
  8022af:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8022b3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8022b7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022bb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8022bf:	89 44 24 0c          	mov    %eax,0xc(%esp)
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8022c3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022c7:	89 f3                	mov    %esi,%ebx
  const DWunion dd = {.ll = d};
  8022c9:	89 fa                	mov    %edi,%edx
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8022cb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  n1 = nn.s.high;
  8022cf:	89 34 24             	mov    %esi,(%esp)

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8022d2:	85 c0                	test   %eax,%eax
  8022d4:	75 1a                	jne    8022f0 <__umoddi3+0x48>
    {
      if (d0 > n1)
  8022d6:	39 f7                	cmp    %esi,%edi
  8022d8:	0f 86 a2 00 00 00    	jbe    802380 <__umoddi3+0xd8>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8022de:	89 c8                	mov    %ecx,%eax
  8022e0:	89 f2                	mov    %esi,%edx
  8022e2:	f7 f7                	div    %edi
  8022e4:	89 d0                	mov    %edx,%eax

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8022e6:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8022e8:	83 c4 1c             	add    $0x1c,%esp
  8022eb:	5b                   	pop    %ebx
  8022ec:	5e                   	pop    %esi
  8022ed:	5f                   	pop    %edi
  8022ee:	5d                   	pop    %ebp
  8022ef:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8022f0:	39 f0                	cmp    %esi,%eax
  8022f2:	0f 87 ac 00 00 00    	ja     8023a4 <__umoddi3+0xfc>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8022f8:	0f bd e8             	bsr    %eax,%ebp
	  if (bm == 0)
  8022fb:	83 f5 1f             	xor    $0x1f,%ebp
  8022fe:	0f 84 ac 00 00 00    	je     8023b0 <__umoddi3+0x108>
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802304:	bf 20 00 00 00       	mov    $0x20,%edi
  802309:	29 ef                	sub    %ebp,%edi
  80230b:	89 fe                	mov    %edi,%esi
  80230d:	89 7c 24 0c          	mov    %edi,0xc(%esp)

	      d1 = (d1 << bm) | (d0 >> b);
  802311:	89 e9                	mov    %ebp,%ecx
  802313:	d3 e0                	shl    %cl,%eax
  802315:	89 d7                	mov    %edx,%edi
  802317:	89 f1                	mov    %esi,%ecx
  802319:	d3 ef                	shr    %cl,%edi
  80231b:	09 c7                	or     %eax,%edi
	      d0 = d0 << bm;
  80231d:	89 e9                	mov    %ebp,%ecx
  80231f:	d3 e2                	shl    %cl,%edx
  802321:	89 14 24             	mov    %edx,(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802324:	89 d8                	mov    %ebx,%eax
  802326:	d3 e0                	shl    %cl,%eax
  802328:	89 c2                	mov    %eax,%edx
	      n0 = n0 << bm;
  80232a:	8b 44 24 08          	mov    0x8(%esp),%eax
  80232e:	d3 e0                	shl    %cl,%eax
  802330:	89 44 24 04          	mov    %eax,0x4(%esp)

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802334:	8b 44 24 08          	mov    0x8(%esp),%eax
  802338:	89 f1                	mov    %esi,%ecx
  80233a:	d3 e8                	shr    %cl,%eax
  80233c:	09 d0                	or     %edx,%eax
  80233e:	d3 eb                	shr    %cl,%ebx
  802340:	89 da                	mov    %ebx,%edx
  802342:	f7 f7                	div    %edi
  802344:	89 d3                	mov    %edx,%ebx
	      umul_ppmm (m1, m0, q0, d0);
  802346:	f7 24 24             	mull   (%esp)
  802349:	89 c6                	mov    %eax,%esi
  80234b:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80234d:	39 d3                	cmp    %edx,%ebx
  80234f:	0f 82 87 00 00 00    	jb     8023dc <__umoddi3+0x134>
  802355:	0f 84 91 00 00 00    	je     8023ec <__umoddi3+0x144>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80235b:	8b 54 24 04          	mov    0x4(%esp),%edx
  80235f:	29 f2                	sub    %esi,%edx
  802361:	19 cb                	sbb    %ecx,%ebx
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802363:	89 d8                	mov    %ebx,%eax
  802365:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  802369:	d3 e0                	shl    %cl,%eax
  80236b:	89 e9                	mov    %ebp,%ecx
  80236d:	d3 ea                	shr    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80236f:	09 d0                	or     %edx,%eax
  802371:	89 e9                	mov    %ebp,%ecx
  802373:	d3 eb                	shr    %cl,%ebx
  802375:	89 da                	mov    %ebx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802377:	83 c4 1c             	add    $0x1c,%esp
  80237a:	5b                   	pop    %ebx
  80237b:	5e                   	pop    %esi
  80237c:	5f                   	pop    %edi
  80237d:	5d                   	pop    %ebp
  80237e:	c3                   	ret    
  80237f:	90                   	nop
  802380:	89 fd                	mov    %edi,%ebp
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802382:	85 ff                	test   %edi,%edi
  802384:	75 0b                	jne    802391 <__umoddi3+0xe9>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802386:	b8 01 00 00 00       	mov    $0x1,%eax
  80238b:	31 d2                	xor    %edx,%edx
  80238d:	f7 f7                	div    %edi
  80238f:	89 c5                	mov    %eax,%ebp

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802391:	89 f0                	mov    %esi,%eax
  802393:	31 d2                	xor    %edx,%edx
  802395:	f7 f5                	div    %ebp
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802397:	89 c8                	mov    %ecx,%eax
  802399:	f7 f5                	div    %ebp
  80239b:	89 d0                	mov    %edx,%eax
  80239d:	e9 44 ff ff ff       	jmp    8022e6 <__umoddi3+0x3e>
  8023a2:	66 90                	xchg   %ax,%ax
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8023a4:	89 c8                	mov    %ecx,%eax
  8023a6:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8023a8:	83 c4 1c             	add    $0x1c,%esp
  8023ab:	5b                   	pop    %ebx
  8023ac:	5e                   	pop    %esi
  8023ad:	5f                   	pop    %edi
  8023ae:	5d                   	pop    %ebp
  8023af:	c3                   	ret    

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8023b0:	3b 04 24             	cmp    (%esp),%eax
  8023b3:	72 06                	jb     8023bb <__umoddi3+0x113>
  8023b5:	3b 7c 24 04          	cmp    0x4(%esp),%edi
  8023b9:	77 0f                	ja     8023ca <__umoddi3+0x122>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8023bb:	89 f2                	mov    %esi,%edx
  8023bd:	29 f9                	sub    %edi,%ecx
  8023bf:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  8023c3:	89 14 24             	mov    %edx,(%esp)
  8023c6:	89 4c 24 04          	mov    %ecx,0x4(%esp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8023ca:	8b 44 24 04          	mov    0x4(%esp),%eax
  8023ce:	8b 14 24             	mov    (%esp),%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8023d1:	83 c4 1c             	add    $0x1c,%esp
  8023d4:	5b                   	pop    %ebx
  8023d5:	5e                   	pop    %esi
  8023d6:	5f                   	pop    %edi
  8023d7:	5d                   	pop    %ebp
  8023d8:	c3                   	ret    
  8023d9:	8d 76 00             	lea    0x0(%esi),%esi
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8023dc:	2b 04 24             	sub    (%esp),%eax
  8023df:	19 fa                	sbb    %edi,%edx
  8023e1:	89 d1                	mov    %edx,%ecx
  8023e3:	89 c6                	mov    %eax,%esi
  8023e5:	e9 71 ff ff ff       	jmp    80235b <__umoddi3+0xb3>
  8023ea:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8023ec:	39 44 24 04          	cmp    %eax,0x4(%esp)
  8023f0:	72 ea                	jb     8023dc <__umoddi3+0x134>
  8023f2:	89 d9                	mov    %ebx,%ecx
  8023f4:	e9 62 ff ff ff       	jmp    80235b <__umoddi3+0xb3>
