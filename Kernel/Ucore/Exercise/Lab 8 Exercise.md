# Lab 8 Exercise

## Exercise 1

**问题：**

**完成读文件操作的实现（需要编码），首先了解打开文件的处理流程，然后参考本实验后续的文件读写操作的过程分析，编写在sfs_inode.c中sfs_io_nolock读文件中数据的实现代码。**

读文件的处理过程和代码：

1. 检查错误，即检查读取长度是否为0和文件是否可读。

2. 分配buffer空间，即调用kmalloc函数分配4096字节的buffer空间。

3. 读文件过程

   - 实际读文件

     循环读取文件，每次读取buffer大小。每次循环中，先检查剩余部分大小，若其小于4096字节，则只读取剩余部分的大小。然后调用file_read函数（详细分析见后）将文件内容读取到buffer中，alen为实际大小。调用copy_to_user函数将读到的内容拷贝到用户的内存空间中，调整各变量以进行下一次循环读取，直至指定长度读取完成。最后函数调用层层返回至用户程序，用户程序收到了读到的文件内容。

   - file_read函数

     这个函数是读文件的核心函数。函数有4个参数，fd是文件描述符，base是缓存的基地址，len是要读取的长度，copied_store存放实际读取的长度。函数首先调用fd2file函数找到对应的file结构，并检查是否可读。调用filemap_acquire函数使打开这个文件的计数加1。调用vop_read函数将文件内容读到iob中（详细分析见后）。调整文件指针偏移量pos的值，使其向后移动实际读到的字节数iobuf_used(iob)。最后调用filemap_release函数使打开这个文件的计数减1，若打开计数为0，则释放file。

对应代码，代码中也有注释：

```
int
sysfile_read(int fd, void *base, size_t len) {
    struct mm_struct *mm = current->mm;
    //检测读取长度是不是合法，如果读取的长度为0，就直接返回0
    if (len == 0) {
        return 0;
    }
    //这个是测试这个文件是不是可读的，第二个参数为1代表可读，第三个参数为1代表可写
    if (!file_testfd(fd, 1, 0)) {
        return -E_INVAL;
    }
    void *buffer;
    //然后申请一块空间，空间大小为4k，来存储读出来的内容
    if ((buffer = kmalloc(IOBUF_SIZE)) == NULL) {
        return -E_NO_MEM;
    }

    int ret = 0;
    //alen是实际读取的长度
    size_t copied = 0, alen;
    //先判断一下咱们要读取的长度是不是小于4096的如果说是小于4096的就读len长度，如果说大于4096就读4096
    while (len != 0) {
        if (len < (alen = IOBUF_SIZE)) {
            alen = len;
        }
        //
        ret = file_read(fd, buffer, alen, &alen);
        if (alen != 0) {
            lock_mm(mm);
            {
                if (copy_to_user(mm, base, buffer, alen)) {
                    assert(len >= alen);
                    base += alen, len -= alen, copied += alen;
                }
                else if (ret == 0) {
                    ret = -E_INVAL;
                }
            }
            unlock_mm(mm);
        }
        if (ret != 0 || alen == 0) {
            goto out;
        }
    }

out:
    kfree(buffer);
    if (copied != 0) {
        return copied;
    }
    return ret;
}

--------------------------------------------------------------------------------------------------------
file_read:

int
file_read(int fd, void *base, size_t len, size_t *copied_store) {
    int ret;
    struct file *file;
    *copied_store = 0;
    //先根据fd找到这个文件
    if ((ret = fd2file(fd, &file)) != 0) {
        return ret;
    }
    //检测文件是否可读
    if (!file->readable) {
        return -E_INVAL;
    }
    //文件引用计数加1
    fd_array_acquire(file);
	//初始化iob
    struct iobuf __iob, *iob = iobuf_init(&__iob, base, len, file->pos);
    //读取内容到iob中
    ret = vop_read(file->node, iob);
	//设置copied的值为iob中有效数据的长度
    size_t copied = iobuf_used(iob);
    //然后设置当前文件读取的位置，因为已经读了copied这么长，所以下次再读从pos+copied那个位置开始读
    if (file->status == FD_OPENED) {
        file->pos += copied;
    }
    //然后copied保存读的长度
    *copied_store = copied;
    //引用计数减一
    fd_array_release(file);
    return ret;
}

--------------------------------------------------------------------------------------------------------
vop_read:

vop_read实际就是sfs_read
//sfs_read调用sfs_io，其中包含3个参数，第一个是对应的inode，第二个是存储的iobuff，第三个参数如果是0代表可写，是1代表可读
static int
sfs_read(struct inode *node, struct iobuf *iob) {
    return sfs_io(node, iob, 0);
}

static inline int
sfs_io(struct inode *node, struct iobuf *iob, bool write) {
    //找到node对应的sfs和sin
    struct sfs_fs *sfs = fsop_info(vop_fs(node), sfs);
    struct sfs_inode *sin = vop_info(node, sfs_inode);
    int ret;
    lock_sin(sin);
    {
        //实际长度
        size_t alen = iob->io_resid;
        ret = sfs_io_nolock(sfs, sin, iob->io_base, iob->io_offset, &alen, write);
        if (alen != 0) {
            iobuf_skip(iob, alen);
        }
    }
    unlock_sin(sin);
    return ret;
}

static int
sfs_io_nolock(struct sfs_fs *sfs, struct sfs_inode *sin, void *buf, off_t offset, size_t *alenp, bool write) {
    struct sfs_disk_inode *din = sin->din;
    assert(din->type != SFS_TYPE_DIR);
    //设置最后读取的结尾位置为endpos，值为offset（buffer中的偏移）加上alenp(要读的长度)
    off_t endpos = offset + *alenp, blkoff;
    *alenp = 0;
	// calculate the Rd/Wr end position
	//判断offset是否符合条件，即offset是否小于0或者offset是否是大于最大文件的大小的或者offset是大于结束位置的，如果是就返回一个错误
    if (offset < 0 || offset >= SFS_MAX_FILE_SIZE || offset > endpos) {
        return -E_INVAL;
    }
    //如果说offset等于endpos，也就代表没有东西需要读，所以就直接返回0
    if (offset == endpos) {
        return 0;
    }
    //如果说结束的位置大于SFS_MAX_FILE_SIZE，就截掉大于的部分只读到SFS_MAX_FILE_SIZE这个范围内
    if (endpos > SFS_MAX_FILE_SIZE) {
        endpos = SFS_MAX_FILE_SIZE;
    }
    //检测是否可写，咱们这里sfs_io传的参数是0，也就代表是可读，所以!write也就是1，也就会执行这个if分支
    if (!write) {
        if (offset >= din->size) {
            return 0;
        }
        if (endpos > din->size) {
            endpos = din->size;
        }
    }
	//对应的对buf和block操作的函数，sfs_buf_op是用在开头和结尾，sfs_block_op是用在中间部分
    int (*sfs_buf_op)(struct sfs_fs *sfs, void *buf, size_t len, uint32_t blkno, off_t offset);
    int (*sfs_block_op)(struct sfs_fs *sfs, void *buf, uint32_t blkno, uint32_t nblks);
    //根据读写设置对应的调用的函数
    if (write) {
        sfs_buf_op = sfs_wbuf, sfs_block_op = sfs_wblock;
    }
    else {
        sfs_buf_op = sfs_rbuf, sfs_block_op = sfs_rblock;
    }
	//设置一些变量，blkno是现再读取的第一个块，nblks是这个块的大小
    int ret = 0;
    size_t size, alen = 0;
    uint32_t ino;
    uint32_t blkno = offset / SFS_BLKSIZE;          // The NO. of Rd/Wr begin block
    uint32_t nblks = endpos / SFS_BLKSIZE - blkno;  // The size of Rd/Wr blocks

	//接下来读文件就分成三步，也就是前中后三步，第一步先读前如果说前没有占满一个块那就需要读一个块的一部分而不是一整个块
	//后和前一样，中就是直接读一整块就可以了
	
	//前，首先判断前是否是没有沾满一个块，如果说已经沾满了一个块那就读这个块，不是就有下面的内容了
    if ((blkoff = offset % SFS_BLKSIZE) != 0)  {
    	//计算要读多大
    	//endpos和offset是在一个块内的，那就是offset-endpos
    	//不是在一个块内的，那就需要读blkoff所在块剩余的部分，也就是SFS_BLKSIZE - blkoff
        size = (nblks != 0) ? (SFS_BLKSIZE - blkoff) : (endpos - offset);
        //获取编号
        if ((ret = sfs_bmap_load_nolock(sfs, sin, blkno, &ino)) != 0) {
            goto out;
        }
        //读数据
        if ((ret = sfs_buf_op(sfs, buf, size, ino, blkoff)) != 0) {
            goto out;
        }
        //更新实际读取的长度
        alen += size;
        if (nblks == 0) {
            goto out;
        }
        //更新读取的大小，blkno加1代表读到下一个块了，nblks减1代表要读的块少了一个
        buf += size, blkno++; nblks--;
    }

    size = SFS_BLKSIZE;
    //中，中就是循环读就可以了，因为nblks是除法得到的所以说如果最后一个块是没有占满的话，就会舍掉最后一个，所以这个while循环是不会涉及到最后一个快的
    //(最后一个块是没占满的情况下)
    while (nblks != 0) {
        if ((ret = sfs_bmap_load_nolock(sfs, sin, blkno, &ino)) != 0) {
            goto out;
        }
        if ((ret = sfs_block_op(sfs, buf, ino, 1)) != 0) {
            goto out;
        }
        alen += size, buf += size, blkno++, nblks--;
    }
	//后，检测endpos余一个块大小是否有余数，如果有余数就代表最后一个块没沾满
    if ((size = endpos % SFS_BLKSIZE) != 0) {
    	//获取编号
        if ((ret = sfs_bmap_load_nolock(sfs, sin, blkno, &ino)) != 0) {
            goto out;
        }
        //读最后一个块
        if ((ret = sfs_buf_op(sfs, buf, size, ino, 0)) != 0) {
            goto out;
        }
        //更新实际读取的长度
        alen += size;
    }

out:
    *alenp = alen;
    //这个是对应着写的情况，如果说写完的长度比原来大就代表被修改过了，所以就需要设置dirty位并且更新size
    if (offset + alen > sin->din->size) {
        sin->din->size = offset + alen;
        sin->dirty = 1;
    }
    return ret;
}
```

## Exercise 2

**问题：**

**完成基于文件系统的执行程序机制的实现（需要编码），改写proc.c中的load_icode函数和其他相关函数，实现基于文件系统的执行程序机制。执行：make qemu。如果能看看到sh用户程序的执行界面，则基本成功了。如果在sh用户界面上可以执行”ls”,”hello”等其他放置在sfs文件系统中的其他执行程序，则可以认为本实验基本成功。**

先分析一下这里的load_icode和之前实验中的load_icode有什么区别，之前实验中load_icode读elf是从内存中读，而这里的load_icode是从磁盘上读了，而且还涉及到了一个参数的问题，不过大部分内容还是和之前的load_icode相似的，可以在之前load_icode的基础上进行修改

主要需要添加几部分内容，代码如下：

alloc_proc函数：

```
static struct proc_struct *
alloc_proc(void) {
		.........
        proc->filesp = NULL;

}
```

整体代码：

```
static int
load_icode(int fd, int argc, char **kargv) {
	//与之前lab相同
    if (current->mm != NULL) {
        panic("load_icode: current->mm must be empty.\n");
    }
    //与之前lab相同
    int ret = -E_NO_MEM;
	//与之前lab相同
    struct mm_struct *mm;
    //与之前lab相同
    if ((mm = mm_create()) == NULL) {
        goto bad_mm;
    }
    //与之前lab相同
    if (setup_pgdir(mm) != 0) {
        goto bad_pgdir_cleanup_mm;
    }
    //与之前lab相同
    struct Page *page;
    //进行了修改，因为之前load_icode传的参数是binary，而这次我们传的参数是fd，所以需要用一个elfhdr来存储读进来的内容
    struct elfhdr __elf, *elf = &__elf;
    //这里调用了load_icode_read函数，它调用的read和seek函数，这些函数在笔记里都分析过，seek是找到咱们要读的这个文件，read就是具体的读操作
    if ((ret = load_icode_read(fd, elf, sizeof(struct elfhdr), 0)) != 0) {
        goto bad_elf_cleanup_pgdir;
    }
    //与之前lab相同
    if (elf->e_magic != ELF_MAGIC) {
        ret = -E_INVAL_ELF;
        goto bad_elf_cleanup_pgdir;
    }
    struct proghdr __ph, *ph = &__ph;

    uint32_t i;
    uint32_t vm_flags, perm;
	//这里也进行了修改，但是大致的思想和之前的lab是一样的，循环读每个段，然后给每个段分配物理内存并和虚拟地址建立映射再初始化栈空间
    for (i = 0; i < elf->e_phnum; ++i) {
        if ((ret = load_icode_read(fd, ph, sizeof(struct proghdr), elf->e_phoff + sizeof(struct proghdr) * i)) != 0) {
            goto bad_elf_cleanup_pgdir;
        }
        if (ph->p_type != ELF_PT_LOAD) {
            continue ;
        }
        if (ph->p_filesz > ph->p_memsz) {
            ret = -E_INVAL_ELF;
            goto bad_cleanup_mmap;
        }
        if (ph->p_filesz == 0) {
            continue ;
        }
        vm_flags = 0, perm = PTE_U;
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
        if (vm_flags & VM_WRITE) perm |= PTE_W;
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
            goto bad_cleanup_mmap;
        }
        off_t offset = ph->p_offset;
        size_t off, size;
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);

        ret = -E_NO_MEM;

        end = ph->p_va + ph->p_filesz;

        while (start < end) {
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
                goto bad_cleanup_mmap;
            }
            off = start - la, size = PGSIZE - off, la += PGSIZE;
            if (end < la) {
                size -= la - end;
            }

            if ((ret = load_icode_read(fd, page2kva(page) + off, size, offset)) != 0) {
                goto bad_cleanup_mmap;
            }
            start += size, offset += size;
        }

        end = ph->p_va + ph->p_memsz;
        if (start < la) {
            if (start == end) {
                continue ;
            }
            off = start + PGSIZE - la, size = PGSIZE - off;
            if (end < la) {
                size -= la - end;
            }
            memset(page2kva(page) + off, 0, size);
            start += size;
            assert((end < la && start == end) || (end >= la && start == la));
        }
        while (start < end) {
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
                goto bad_cleanup_mmap;
            }
            off = start - la, size = PGSIZE - off, la += PGSIZE;
            if (end < la) {
                size -= la - end;
            }
            memset(page2kva(page) + off, 0, size);
            start += size;
        }
    
    }
    vm_flags = VM_READ | VM_WRITE | VM_STACK;
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
        goto bad_cleanup_mmap;
    }
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
    mm_count_inc(mm);
    current->mm = mm;
    current->cr3 = PADDR(mm->pgdir);
    lcr3(PADDR(mm->pgdir));
	
	下面这个是参数在栈中的存放方法
-------------------------------------------------------------------------------------------------------

	----------------
    | High Address |
	----------------
	|   Argument   |
	|      n       |
	----------------
	|     ...      |
	----------------
	|   Argument   |
	|      1       |
	----------------
	|    padding   |
	----------------
	|   null ptr   |
	----------------
	|  Ptr Arg n   |
	----------------
	|     ...      |
	----------------
	|  Ptr  Arg 1  |
	----------------
	|  Arg  Count  | <-- user esp
	----------------
	| Low  Address |
	----------------
	
-------------------------------------------------------------------------------------------------------
	
	//然后这里就是需要设置参数再栈中存储的位置了
    //首先先算一下传递的参数一共是需要多少空间
    uint32_t total_len = 0;
    for (i = 0; i < argc; ++i) {
        total_len += strnlen(kargv[i], EXEC_MAX_ARG_LEN) + 1;
    }
    //现再知道了用多少空间，但是这个空间大小可能不是4字节对齐的，所以我们需要让他4字节对齐，然后用栈顶减去它，就可以知道我们的参数应该放在栈中的什么位置了
    char *arg_str = (USTACKTOP - total_len) & 0xfffffffc;
    //然后对应着上面的图我们发现，在参数字符串下面有对应的参数指针，所以说我们还需要给参数指针流出空间
    int32_t *arg_ptr = (int32_t *)arg_str - argc;
    //还是上面的图，参数指针下面还有一个参数的个数，所以说还需要一个存参数个数的空间
    int32_t *stacktop = arg_ptr - 1;
    *stacktop = argc;
    //现再已经知道参数，参数指针，参数个数都存在哪里了，就只剩下把这些东西存在栈空间里面了
    //首先确定每个参数的大小，然后把字符参数存进我们之前保留的字符参数栈内
    //然后再把参数的指针存在之前保留的位置
    //最后把栈中存的参数长度加1
    for (i = 0; i < argc; ++i) {
        uint32_t arg_len = strnlen(kargv[i], EXEC_MAX_ARG_LEN);
        strncpy(arg_str, kargv[i], arg_len);
        *arg_ptr = arg_str;
        arg_str += arg_len + 1;
        ++arg_ptr;
    }
	//设置中断帧就和之前的lab一样了
    struct trapframe *tf = current->tf;
    memset(tf, 0, sizeof(struct trapframe));

    tf->tf_cs = USER_CS;
    tf->tf_ds = tf->tf_es = tf->tf_ss = USER_DS;
    tf->tf_esp = stacktop;
    tf->tf_eip = elf->e_entry;
    tf->tf_eflags |= FL_IF;
    ret = 0;
out:
    return ret;
bad_cleanup_mmap:
    exit_mmap(mm);
bad_elf_cleanup_pgdir:
    put_pgdir(mm);
bad_pgdir_cleanup_mm:
    mm_destroy(mm);
bad_mm:
    goto out;

}
```

