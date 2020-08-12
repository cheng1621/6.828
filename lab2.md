Reference: https://github.com/SimpCosm/6.828/tree/master/lab2

Note:
kernel bss segment: a memory used to store the uninitialized parameter.
end: point to the end of the used kernel memory.
upages: the maximum read-only address user can use.

## Part 1:
### boot_alloc (initialize nextfree first and allocate n bytes to it, return the bottom address of the page.)
end: which is to identify the end of the kernel.

### mem_init()
Map the 'UPAGES' 'KSTACKTOP' to physical address, then map the other virtual addresses to the physical addresses.

### page_init()
set the 'pp_ref' to 0; set 'pp_link' to the 'page_free_list'; set the page_free_list to the address of the page
