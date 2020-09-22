# Lab 8

## 基础知识

### ucore 文件系统总体介绍以及数据结构

操作系统中负责管理和存储可长期保存数据的软件功能模块称为文件系统。

ucore的文件系统模型源于Havard的OS161的文件系统和Linux文件系统。但其实这二者都是源于传统的UNIX文件系统设计。UNIX提出了四个文件系统抽象概念：文件(file)、目录项(dentry)、索引节点(inode)和安装点(mount point)。

- 文件：UNIX文件中的内容可理解为是一有序字节buffer，文件都有一个方便应用程序识别的文件名称（也称文件路径名）。典型的文件操作有读、写、创建和删除等。

- 目录项：目录项不是目录（又称文件路径），而是目录的组成部分。在UNIX中目录被看作一种特定的文件，而目录项是文件路径中的一部分。如一个文件路径名是“/test/testfile”，则包含的目录项为：根目录“/”，目录“test”和文件“testfile”，这三个都是目录项。一般而言，目录项包含目录项的名字（文件名或目录名）和目录项的索引节点（见下面的描述）位置，用图表示就是下面这样的

  ![](https://resery-tuchuang.oss-cn-beijing.aliyuncs.com/2020-08-28_10-06-45.png)

- 索引节点：UNIX将文件的相关元数据信息（如访问控制权限、大小、拥有者、创建时间、数据内容等等信息）存储在一个单独的数据结构中，该结构被称为索引节点。

- 安装点：在UNIX中，文件系统被安装在一个特定的文件路径位置，这个位置就是安装点。所有的已安装文件系统都作为根文件系统树中的叶子出现在系统中。

ucore模仿了UNIX的文件系统设计，ucore的文件系统架构主要由四部分组成：

- 通用文件系统访问接口层：对于这个地方ucore文档描述的很晦涩，但是实际上它就是平时我们所用的系统调用之类的东西，open，read，write，close，来让用户可以获得内核服务来队文件进行操作；（ucore文档中的解释：该层提供了一个从用户空间到文件系统的标准访问接口。这一层访问接口让应用程序能够通过一个简单的接口获得ucore内核的文件系统服务）
- 文件系统抽象层：这个主要是为了让不同的文件使用不同的文件系统，可是为什么要有那么多的文件系统，这是因为对于不同的文件使用不同的文件系统能达到最快最适合的目的，比如说硬盘和光盘，硬盘需要多次写入多次读出而光盘一般情况下都是一次写入多次读出，对于这样的不同的特性就需要不同的文件系统来支持以达到效率上的最优；（ucore文档中的解释：向上提供一个一致的接口给内核其他部分（文件系统相关的系统调用实现模块和其他内核功能模块）访问。向下提供一个同样的抽象函数指针列表和数据结构屏蔽不同文件系统的实现细节。）
- Simple FS文件系统层：一个基于索引方式的简单文件系统实例。向上通过各种具体函数实现以对应文件系统抽象层提出的抽象函数。向下访问外设接口
- 外设接口层：（ucore文档中的解释：向上提供device访问接口屏蔽不同硬件细节。向下实现访问各种具体设备驱动的接口，比如disk设备接口/串口设备接口/键盘设备接口等）；这里就涉及了平时写代码的时候遇到的标准输入，标准输出，输入是从键盘获取内容，输出是输出到显示器上 ，所以对应的就有外设接口层

对照上面的层次我们再大致介绍一下文件系统的访问处理过程，加深对文件系统的总体理解。假如应用程序操作文件（打开/创建/删除/读写），首先需要通过文件系统的通用文件系统访问接口层给用户空间提供的访问接口进入文件系统内部，接着由文件系统抽象层把访问请求转发给某一具体文件系统（比如SFS文件系统），具体文件系统（Simple FS文件系统层）把应用程序的访问请求转化为对磁盘上的block的处理请求，并通过外设接口层交给磁盘驱动例程来完成具体的磁盘操作。结合用户态写文件函数write的整个执行过程，我们可以比较清楚地看出ucore文件系统架构的层次和依赖关系。

![](https://resery-tuchuang.oss-cn-beijing.aliyuncs.com/2020-08-28_10-07-45.png)

根据这个图其实就可以理解很多问题了，简略的来说主要就是下面几个步骤，系统调用，访问请求发给具体文件系统，文件系统访问设备执行对应的操作

**ucore文件系统总体结构**

从ucore操作系统不同的角度来看，ucore中的文件系统架构包含四类主要的数据结构, 它们分别是：

- 超级块（SuperBlock），它主要从文件系统的全局角度描述特定文件系统的全局信息。它的作用范围是整个OS空间。

  ```
  struct sfs_super {
      uint32_t magic;                                  /* magic number, should be SFS_MAGIC */
      uint32_t blocks;                                 /* # of blocks in fs */
      uint32_t unused_blocks;                         /* # of unused blocks in fs */
      char info[SFS_MAX_INFO_LEN + 1];                /* infomation for sfs  */
  };
  ```

  - magic：值为0x2f8dbe2a，内核通过它来检查磁盘镜像是否是合法的 SFS img
  - block：文件系统所包含的块的数量
  - unused_blocks：文件系统中没有使用的块的数量
  - info：包含了字符串"simple file system"

- 索引节点（inode）：它主要从文件系统的单个文件的角度它描述了文件的各种属性和数据所在位置。它的作用范围是整个OS空间。

  ```
  struct inode {
      union {                                 
          struct device __device_info; 
          struct sfs_inode __sfs_inode_info;
      } in_info;   
      enum {
          inode_type_device_info = 0x1234,
          inode_type_sfs_inode_info,
      } in_type;                          
      atomic_t ref_count;                 
      atomic_t open_count;                
      struct fs *in_fs;                   
      const struct inode_ops *in_ops;
  };
  ```

  - in_info：包含不同文件系统特定inode信息的union成员变量

    **__device_info：设备文件系统内存inode信息**

    ```
    struct device {
        size_t d_blocks;
        size_t d_blocksize;
        int (*d_open)(struct device *dev, uint32_t open_flags);
        int (*d_close)(struct device *dev);
        int (*d_io)(struct device *dev, struct iobuf *iob, bool write);
        int (*d_ioctl)(struct device *dev, int op, void *data);
    };
    ```

    - d_blocks：设备占用的数据块个数     

    - d_blocksize：数据块的大小

    - d_open：打开设备的函数指针

    - d_close：关闭设备的函数指针

    - d_io：读写设备的函数指针

    - d_ioctl：用ioctl方式控制设备的函数指针

      这个数据结构能够支持对块设备（比如磁盘）、字符设备（比如键盘、串口）的表示，完成对设备的基本操作。ucore虚拟文件系统为了把这些设备链接在一起，还定义了一个设备链表，即双向链表vdev_list，这样通过访问此链表，可以找到ucore能够访问的所有设备文件。但这个设备描述没有与文件系统以及表示一个文件的inode数据结构建立关系，为此，还需要另外一个数据结构把device和inode联通起来，这就是vfs_dev_t数据结构：

      ```
      // device info entry in vdev_list 
      typedef struct {
          const char *devname;
          struct inode *devnode;
          struct fs *fs;
          bool mountable;
          list_entry_t vdev_link;
      } vfs_dev_t;
      ```

      利用vfs_dev_t数据结构，就可以让文件系统通过一个链接vfs_dev_t结构的双向链表找到device对应的inode数据结构，一个inode节点的成员变量in_type的值是0x1234，则此 inode的成员变量in_info将成为一个device结构。这样inode就和一个设备建立了联系，这个inode就是一个设备文件。

    **__sfs_inode_info：SFS文件系统内存inode信息**

    **内存中的索引结点：**

    ```
    /* inode for sfs */
    struct sfs_inode {
        struct sfs_disk_inode *din;                     /* on-disk inode */
        uint32_t ino;                                   /* inode number */
        uint32_t flags;                                 /* inode flags */
        bool dirty;                                     /* true if inode modified */
        int reclaim_count;                              /* kill inode if it hits zero */
        semaphore_t sem;                                /* semaphore for din */
        list_entry_t inode_link;                        /* entry for linked-list in sfs_fs */
        list_entry_t hash_link;                         /* entry for hash linked-list in sfs_fs */
    };
    ```

    - din：磁盘上的inode

      ```
      struct sfs_disk_inode {
          uint32_t size;                              
          uint16_t type;                                  
          uint16_t nlinks;                               
          uint32_t blocks;                              
          uint32_t direct[SFS_NDIRECT];                
          uint32_t indirect;                            
      };
      ```

      - size：如果inode表示常规文件，则size是文件大小
      - type：inode的文件类型
      - nlinks：此inode的硬链接数
      - blocks：此inode的数据块数的个数
      - direct：此inode的直接数据块索引值（有SFS_NDIRECT个）
      - indirect：此inode的一级间接数据块索引值

      通过上表可以看出，如果inode表示的是文件，则成员变量direct[]直接指向了保存文件内容数据的数据块索引值。indirect间接指向了保存文件内容数据的数据块，indirect指向的是间接数据块（indirect block），此数据块实际存放的全部是数据块索引，这些数据块索引指向的数据块才被用来存放文件内容数据。不过这里为什么要分直接索引和间接索引并没有说清楚，不过个人认位这应该是为了效率和空间考虑，如果访问的块少，就不用申请那么多索引页了，就直接用直接索引就可以，如果说数据块多的情况下再使用间接索引

      默认的，ucore 里 SFS_NDIRECT 是 12，即直接索引的数据页大小为 12 * 4k = 48k；当使用一级间接数据块索引时，ucore 支持最大的文件大小为 12 * 4k + 1024 * 4k = 48k + 4m。数据索引表内，0 表示一个无效的索引，inode 里 blocks 表示该文件或者目录占用的磁盘的 block 的个数。indiret 为 0 时，表示不使用一级索引块。（因为 block 0 用来保存 super block，它不可能被其他任何文件或目录使用，所以这么设计也是合理的）。

      对于普通文件，索引值指向的 block 中保存的是文件中的数据。而对于目录，索引值指向的数据保存的是目录下所有的文件名以及对应的索引节点所在的索引块（磁盘块）所形成的数组。数据结构如下（下面也有这个数据结构，不过没有具体的分析，只有数据结构）：

      ```
      struct sfs_disk_entry {
          uint32_t ino;                                   
          char name[SFS_MAX_FNAME_LEN + 1];               
      };
      ```

      - ino：索引节点所占数据块索引值
      - name：文件名
      - 这里这个ino所代表的内容ucore描述的比较难懂，这是文档种的解释操作系统中，每个文件系统下的 inode 都应该分配唯一的 inode 编号。SFS 下，为了实现的简便（偷懒），每个 inode 直接用他所在的磁盘 block 的编号作为 inode 编号。比如，root block 的 inode 编号为 1；每个 sfs_disk_entry 数据结构中，name 表示目录下文件或文件夹的名称，ino 表示磁盘 block 编号，通过读取该 block 的数据，能够得到相应的文件或文件夹的 inode。ino 为0时，表示一个无效的 entry。

    - ino：inode编号

    - flags：inode的属性

    - dirty：修改位

    - reclaim_count：当reclaim_count为0的时候就从内存中删除这个索引节点

    - sem：这个din的信号量

    - inode_link：inode链表

    - hash_link：inode哈希表

    - 可以看到SFS中的内存inode包含了SFS的硬盘inode信息，而且还增加了其他一些信息，这属于是便于进行是判断否改写、互斥操作、回收和快速地定位等作用。需要注意，一个内存inode是在打开一个文件后才创建的，如果关机则相关信息都会消失。而硬盘inode的内容是保存在硬盘中的，只是在进程需要时才被读入到内存中，用于访问文件或目录的具体内容数据

  - in_type：此inode所属文件系统类型

    **inode_type_device_info：**值为0x1234，如果说in_type的值为0x1234的话，则此inode的成员变量in_info将成为一个device结构，这样inode就和一个设备建立了联系，这个inode就是一个设备文件，也就是说in_info指向的就是__device_info（差不多这个意思）

    **inode_type_sfs_inode_info：**如果in_type不是0x1234的话，就代表是ucore中的SFS文件系统

  - ref_count：此inode的引用计数

  - open_count：打开此inode对应文件的个数

  - in_fs：抽象的文件系统，包含访问文件系统的函数指针

  - in_ops：抽象的inode操作，包含访问inode的函数指针     

  - 在inode中，有一成员变量为in_ops，这是对此inode的操作函数指针列表，其数据结构定义如下：

    ```
    struct inode_ops {
        unsigned long vop_magic;
        int (*vop_open)(struct inode *node, uint32_t open_flags);
        int (*vop_close)(struct inode *node);
        int (*vop_read)(struct inode *node, struct iobuf *iob);
        int (*vop_write)(struct inode *node, struct iobuf *iob);
        int (*vop_getdirentry)(struct inode *node, struct iobuf *iob);
        int (*vop_create)(struct inode *node, const char *name, bool excl, struct inode **node_store);
    	int (*vop_lookup)(struct inode *node, char *path, struct inode **node_store);
    ……
     };
    ```

    **对于某一具体的文件系统中的文件或目录，只需实现相关的函数，就可以被用户进程访问具体的文件了，且用户进程无需了解具体文件系统的实现细节**

- 目录项（dentry）：它主要从文件系统的文件路径的角度描述了文件路径中的一个特定的目录项（注：一系列目录项形成目录/文件路径）。它的作用范围是整个OS空间。对于SFS而言，inode(具体为struct sfs_disk_inode)对应于物理磁盘上的具体对象，dentry（具体为struct sfs_disk_entry）是一个内存实体，其中的ino成员指向对应的inode number，另外一个成员是file name(文件名).

  ```
  struct sfs_disk_entry {
      uint32_t ino;
      char name[SFS_MAX_FNAME_LEN + 1];               
  };
  ```

  - ino：索引节点所占数据块索引值
  - name：文件名

- 文件（file），它主要从进程的角度描述了一个进程在访问文件时需要了解的文件标识，文件读写的位置，文件引用情况等信息。它的作用范围是某一具体进程。

  ```
  struct file {
      enum {
          FD_NONE, FD_INIT, FD_OPENED, FD_CLOSED,
      } status;
      bool readable;
      bool writable;
      int fd;
      off_t pos;
      struct inode *node;
      int open_count;
  };
  ```

  - status：访问文件的执行状态
  - readable：文件是否可读
  - writable：文件是否可写
  - fd：文件在filemap中的索引值
  - pos：访问文件的当前位置
  - node：该文件对应的内存inode指针
  - open_count：打开此文件的次数

  而在kern/process/proc.h中的proc_struct结构中描述了进程访问文件的数据接口files_struct，其数据结构定义如下：

  ```
  struct files_struct {
      struct inode *pwd;
      struct file *fd_array;
      atomic_t files_count;
      semaphore_t files_sem;
  };
  ```

  - pwd：进程当前执行目录的内存inode指针
  - fd_array：进程打开文件的数组
  - files_count：访问此文件的线程个数
  - files_sem：确保对进程控制块中fs_struct的互斥访问

  当创建一个进程后，该进程的files_struct将会被初始化或复制父进程的files_struct。当用户进程打开一个文件时，将从fd_array数组中取得一个空闲file项，然后会把此file的成员变量node指针指向一个代表此文件的inode的起始地址。

有很多数据结构，以及对应的概念，不过用图梳理以下就容易理解很多，下面这个图是当进程打开了一个文件，ucore中涉及的数据结构：

![](https://resery-tuchuang.oss-cn-beijing.aliyuncs.com/2020-08-28_17-36-47.png)

### 文件系统的布局

文件系统通常保存在磁盘上。在本实验中，第三个磁盘（即disk0，前两个磁盘分别是 ucore.img 和 swap.img）用于存放一个SFS文件系统（Simple Filesystem）。通常文件系统中，磁盘的使用是以扇区（Sector）为单位的，但是为了实现简便，SFS 中以 block （4K，与内存 page 大小相等）为基本单位。

SFS文件系统的布局如下图所示。

![](https://resery-tuchuang.oss-cn-beijing.aliyuncs.com/2020-08-28_17-55-56.png)

**第0个块（4K）：**是超级块（superblock），它包含了关于文件系统的所有关键参数，当计算机被启动或文件系统被首次接触时，超级块的内容就会被装入内存。其定义如下：

```
struct sfs_super {
    uint32_t magic;
    uint32_t blocks;
    uint32_t unused_blocks;
    char info[SFS_MAX_INFO_LEN + 1];
};
```

上面介绍过了，就不再写了

**第1个块**：放了一个root-dir的inode，用来记录根目录的相关信息。有关inode还将在后续部分介绍。这里只要理解root-dir是SFS文件系统的根结点，通过这个root-dir的inode信息就可以定位并查找到根目录下的所有文件信息。

**从第2个块**：开始，根据SFS中所有块的数量，用1个bit来表示一个块的占用和未被占用的情况。这个区域称为SFS的freemap区域，这将占用若干个块空间。为了更好地记录和管理freemap区域，专门提供了两个文件kern/fs/sfs/bitmap.[ch]来完成根据一个块号查找或设置对应的bit位的值。

**最后**：在剩余的磁盘空间中，存放了所有其他目录和文件的inode信息和内容数据信息。需要注意的是虽然inode的大小小于一个块的大小（4096B），但为了实现简单，每个 inode 都占用一个完整的 block。

在sfs_fs.c文件中的sfs_do_mount函数中，完成了加载位于硬盘上的SFS文件系统的超级块superblock和freemap的工作。这样，在内存中就有了SFS文件系统的全局信息。

### 函数分析

为了方便实现上面提到的多级数据的访问以及目录中 entry 的操作，对 inode SFS实现了一些辅助的函数：

#### sfs_bmap_load_nolock

函数功能是将对应 sfs_inode 的第 index 个索引指向的 block 的索引值取出存到相应的指针指向的单元（ino_store），这个看起来十分的拗口加难懂，不过画出图来就容易一些

![]()

然后这个函数只接受 index <= inode->blocks 的参数，这个是因为index是对应着一个文件块的下标，所以说假如有12个块，但是你index是13，但是没有13这个下标对应的号，所以就不会对应的块，所以index需要小于等于blocks数量，然后当index等于blocks时，需要增加一个block，具体原因需要仔细阅读代码才能理解，然后增加了block之后还需要设置对应的dirty位，即代表这个inode被修改过，这样能保证inode不在使用的时候能被写回到磁盘，因为被修改过磁盘上于内存上的已经不同了所以需要写回到磁盘上，然后这个函数调用了sfs_bmap_get_nolock、sfs_block_inuse这两个函数，现再就来看看这个函数以及调用的这俩个函数的具体功能，具体都写在注释里面了

```
static int
sfs_bmap_load_nolock(struct sfs_fs *sfs, struct sfs_inode *sin, uint32_t index, uint32_t *ino_store) {
    struct sfs_disk_inode *din = sin->din;
    //判断index是否小于等于blocks
    assert(index <= din->blocks);
    int ret;
    uint32_t ino;
    //设置一个create当index==blocks时需要创建一个新的block
    bool create = (index == din->blocks);
    //这个函数就是找到对应的编号，分成两种情况间接索引和直接索引，每种情况都有不同的处理方法，不过功能就是找到对应的编号
    if ((ret = sfs_bmap_get_nolock(sfs, sin, index, create, &ino)) != 0) {
        return ret;
    }
    //根据这个名字就可以很容易的理解，就是检测这个块是不是在使用状态，也就是在freemap里找这个点，如果说这个点上是为0也就代表这个块是使用着的
    assert(sfs_block_inuse(sfs, ino));
    //如果需要创建一个块，对应的blocks数量就应该增加1
    if (create) {
        din->blocks ++;
    }
    //然后把对应的block的编号存在ino_store上
    if (ino_store != NULL) {
        *ino_store = ino;
    }
    return 0;
}
```

然后是sfs_bmap_get_nolock这个函数，sfs_bmap_load_nolock调用了它，然后关于所有的函数就全都写在一个代码块里面了：

```
sfs_bmap_get_nolock：

static int
sfs_bmap_get_nolock(struct sfs_fs *sfs, struct sfs_inode *sin, uint32_t index, bool create, uint32_t *ino_store) {
    struct sfs_disk_inode *din = sin->din;
    int ret;
    uint32_t ent, ino;
	// SFS_NDIRECT的值为12，对应着数据块不多的情况，它首先检测他是不是index是不是11（因为11就是对应着第12个块）并且是否需要创建一个新的block
	// 如果说是对应这种情况，就调用sfs_block_alloc函数，该函数会创建一个新的block，然后把ino也就是编号赋给新创新建的direct[index]，然后direct[index]就是指向内存上对应的那个block了
	// 然后设置dirty位为1，即代表修改过这个页，如果不是上面的那种情况就会跳转到out去执行对应的函数，也就是检测是否使用了，然后把ino赋给ino_store
    if (index < SFS_NDIRECT) {
        if ((ino = din->direct[index]) == 0 && create) {
            if ((ret = sfs_block_alloc(sfs, &ino)) != 0) {
                return ret;
            }
            din->direct[index] = ino;
            sin->dirty = 1;
        }
        goto out;
    }
    // the index of disk block is in the indirect blocks.
    // 然后这种情况就是对应着不是直接索引，对应的是间接索引，所以index就对应的是indirect的下标了，所以index需要减12
    index -= SFS_NDIRECT;
    //对应的间接索引需要一个索引表，索引表的大小为一个页的大小也就是4k，然后是有1024项，所以index需要小于1024
    if (index < SFS_BLK_NENTRY) {
        ent = din->indirect;
        //sfs_bmap_get_sub_nolock这个函数首先会检测是否使用了间接索引，如果使用了，然后就去看在索引表中index对应的那个项
        //这也会存在index=blocks的情况，这种情况也就是先检测create是否为1，为1就直接创建一个block然后把这个编号返回给ino_store
        //然后如果说没有indirect这个项表，会创建一个项表，然后也会更新indirect，也会修改dirty位，然后返回ino编号就可以了
        if ((ret = sfs_bmap_get_sub_nolock(sfs, &ent, index, create, &ino)) != 0) {
            return ret;
        }
        if (ent != din->indirect) {
            assert(din->indirect == 0);
            din->indirect = ent;
            sin->dirty = 1;
        }
        goto out;
    } 
    //????
    else {
		panic ("sfs_bmap_get_nolock - index out of range");
	}
out:
    assert(ino == 0 || sfs_block_inuse(sfs, ino));
    *ino_store = ino;
    return 0;
}

--------------------------------------------------------------------------------------------------------
```

关于sfs_block_alloc和sfs_bmap_get_sub_nolock函数就不贴代码了，函数所做的工作都已经写在注释上了

#### sfs_bmap_truncate_nolock

函数的功能是将多级数据索引表的最后一个 entry 释放掉。他可以认为是 sfs_bmap_load_nolock 中，index == inode->blocks 的逆操作。然后一个文件或者目录被删除的时候回循环调用这个函数把所有的数据块全部都删除掉。函数通过 sfs_bmap_free_nolock 来实现，他应该是 sfs_bmap_get_nolock 的逆操作。和 sfs_bmap_get_nolock 一样，调用 sfs_bmap_free_nolock 也要格外小心。关于函数的具体内容写在注释里面了，代码如下：

```
sfs_bmap_truncate_nolock：

static int
sfs_bmap_truncate_nolock(struct sfs_fs *sfs, struct sfs_inode *sin) {
    struct sfs_disk_inode *din = sin->din;
    //因为对应的是删除的功能所以需要确定inode对应的block数是不能为0的
    assert(din->blocks != 0);
    int ret;
    if ((ret = sfs_bmap_free_nolock(sfs, sin, din->blocks - 1)) != 0) {
        return ret;
    }
    din->blocks --;
    sin->dirty = 1;
    return 0;
}

--------------------------------------------------------------------------------------------------------
sfs_bmap_free_nolock：

static int
sfs_bmap_free_nolock(struct sfs_fs *sfs, struct sfs_inode *sin, uint32_t index) {
    struct sfs_disk_inode *din = sin->din;
    int ret;
    uint32_t ent, ino;
    //可以看到这里其实确实是sfs_bmap_get_nolock和函数的逆函数
    //也是分两种情况第一种对应着blocks<=12，然后直接就删除最后一个entry然后设置dirty位，然后把删除的地方的设置为0
    if (index < SFS_NDIRECT) {
        if ((ino = din->direct[index]) != 0) {
			// free the block
            sfs_block_free(sfs, ino);
            din->direct[index] = 0;
            sin->dirty = 1;
        }
        return 0;
    }
	//这里对应的就是多余12个块，也就是间接索引那种情况，它也是调用了sfs_bmap_free_sub_nolock，前面小于SFS_BLK_NENTRY他也主要是index需要小于1024
	//sfs_bmap_free_sub_nolock函数的功能是
    index -= SFS_NDIRECT;
    if (index < SFS_BLK_NENTRY) {
        if ((ent = din->indirect) != 0) {
			// set the entry item to 0 in the indirect block
            if ((ret = sfs_bmap_free_sub_nolock(sfs, ent, index)) != 0) {
                return ret;
            }
        }
        return 0;
    }
    return 0;
}

--------------------------------------------------------------------------------------------------------
sfs_bmap_free_sub_nolock：

static int
sfs_bmap_free_sub_nolock(struct sfs_fs *sfs, uint32_t ent, uint32_t index) {
    assert(sfs_block_inuse(sfs, ent) && index < SFS_BLK_NENTRY);
    int ret;
    uint32_t ino, zero = 0;
    off_t offset = index * sizeof(uint32_t);
    //读数据
    if ((ret = sfs_rbuf(sfs, &ino, sizeof(uint32_t), ent, offset)) != 0) {
        return ret;
    }
    //读完数据之后检测ino是否为0，如果不为0则代表找到了最后一个块，然后把这个块里的内容清零，然后调用sfs_block_free把这个块删除掉
    if (ino != 0) {
        if ((ret = sfs_wbuf(sfs, &zero, sizeof(uint32_t), ent, offset)) != 0) {
            return ret;
        }
        sfs_block_free(sfs, ino);
    }
    return 0;
}
```

#### sfs_dirent_read_nolock

这个函数的功能是将目录的第slot个entry读到指定的内存空间，也是用上面用过的函数来实现的，代码如下：

```
static int
sfs_dirent_read_nolock(struct sfs_fs *sfs, struct sfs_inode *sin, int slot, struct sfs_disk_entry *entry) {
	//首先就是检测对应的inode类型是目录还是文件，需要是目录，并且slot也是需要小于blocks的
    assert(sin->din->type == SFS_TYPE_DIR && (slot >= 0 && slot < sin->din->blocks));
    int ret;
    uint32_t ino;
	//通过这个目录inode和slot，找到这个对应的block里面存的entry
    if ((ret = sfs_bmap_load_nolock(sfs, sin, slot, &ino)) != 0) {
        return ret;
    }
    //检测这个block是否是被使用的
    assert(sfs_block_inuse(sfs, ino));
	//然后就是把这个项的内容读出来
    if ((ret = sfs_rbuf(sfs, entry, sizeof(struct sfs_disk_entry), ino, 0)) != 0) {
        return ret;
    }
    //设置名字结尾的结束符
    entry->name[SFS_MAX_FNAME_LEN] = '\0';
    return 0;
}
```

#### sfs_dirent_search_nolock

是常用的查找函数。他在目录下查找 name，并且返回相应的搜索结果（文件或文件夹）的 inode 的编号（也是磁盘编号），和相应的 entry 在该目录的 index 编号以及目录下的数据页是否有空闲的 entry。（SFS 实现里文件的数据页是连续的，不存在任何空洞；而对于目录，数据页不是连续的，当某个 entry 删除的时候，SFS 通过设置 entry->ino 为0将该 entry 所在的 block 标记为 free，在需要添加新 entry 的时候，SFS 优先使用这些 free 的 entry，其次才会去在数据页尾追加新的 entry。代码如下：

```
static int
sfs_dirent_search_nolock(struct sfs_fs *sfs, struct sfs_inode *sin, const char *name, uint32_t *ino_store, int *slot, int *empty_slot) {
	//检测名字的长度是否符合标准
    assert(strlen(name) <= SFS_MAX_FNAME_LEN);
    struct sfs_disk_entry *entry;
    //然后为这个entry分配一块空间
    if ((entry = kmalloc(sizeof(struct sfs_disk_entry))) == NULL) {
        return -E_NO_MEM;
    }
//定义一个宏，该宏的功能为如果x的值不是0就把v赋值给x
#define set_pvalue(x, v)            do { if ((x) != NULL) { *(x) = (v); } } while (0)
    int ret, i, nslots = sin->din->blocks;
    //把块数赋给empty_slot
    set_pvalue(empty_slot, nslots);
    //这个循环时把每一项都读出来，然后如果说有一项是0，就设置一下empty_slot的值为i，记录空的项，然后检测到了相同的之后
    //设置对应ino，和slot（也就是index），然后清除这个entry，然后返回就可以了，返回的是要找的entry（如果找到了的话）
    for (i = 0; i < nslots; i ++) {
    	
        if ((ret = sfs_dirent_read_nolock(sfs, sin, i, entry)) != 0) {
            goto out;
        }
        //如果这个项的ino是0，则设置empty_slot的值为i，然后继续循环
        if (entry->ino == 0) {
            set_pvalue(empty_slot, i);
            continue ;
        }
        //如果监测到了与查询的名字相同，就设置slot的值为i，然后设置ino，并且稍后还需要删除entry
        if (strcmp(name, entry->name) == 0) {
            set_pvalue(slot, i);
            set_pvalue(ino_store, entry->ino);
            goto out;
        }
    }
#undef set_pvalue
    ret = -E_NOENT;
out:
    kfree(entry);
    return ret;
}
```

注意，这些后缀为 nolock 的函数，只能在已经获得相应 inode 的semaphore才能调用。

**Inode的文件操作函数**

```
static const struct inode_ops sfs_node_fileops = {
    .vop_magic                      = VOP_MAGIC,
    .vop_open                       = sfs_openfile,
    .vop_close                      = sfs_close,
    .vop_read                       = sfs_read,
    .vop_write                      = sfs_write,
    ……
};
```

上述sfs_openfile、sfs_close、sfs_read和sfs_write分别对应用户进程发出的open、close、read、write操作。其中sfs_openfile不用做什么事；sfs_close需要把对文件的修改内容写回到硬盘上，这样确保硬盘上的文件内容数据是最新的；sfs_read和sfs_write函数都调用了一个函数sfs_io，并最终通过访问硬盘驱动来完成对文件内容数据的读写。

**Inode的目录操作函数**

```
static const struct inode_ops sfs_node_dirops = {
    .vop_magic                      = VOP_MAGIC,
    .vop_open                       = sfs_opendir,
    .vop_close                      = sfs_close,
    .vop_getdirentry                = sfs_getdirentry,
    .vop_lookup                     = sfs_lookup,                           
    ……
};
```

对于目录操作而言，由于目录也是一种文件，所以sfs_opendir、sys_close对应户进程发出的open、close函数。相对于sfs_open，sfs_opendir只是完成一些open函数传递的参数判断，没做其他更多的事情。目录的close操作与文件的close操作完全一致。由于目录的内容数据与文件的内容数据不同，所以读出目录的内容数据的函数是sfs_getdirentry，其主要工作是获取目录下的文件inode信息。

### stdout设备文件

**初始化**

既然stdout设备是设备文件系统的文件，自然有自己的inode结构。在系统初始化时，即只需如下处理过程

```
kern_init-->fs_init-->dev_init-->dev_init_stdout --> dev_create_inode
                 --> stdout_device_init
                 --> vfs_add_dev
```

在dev_init_stdout中完成了对stdout设备文件的初始化。即首先创建了一个inode，然后通过stdout_device_init完成对inode中的成员变量inode->__device_info进行初始：

这里的stdout设备文件实际上就是指的console外设（它其实是串口、并口和CGA的组合型外设）。这个设备文件是一个只写设备，如果读这个设备，就会出错。接下来我们看看stdout设备的相关处理过程。

**初始化**

stdout设备文件的初始化过程主要由stdout_device_init完成，其具体实现如下：

```
static void
stdout_device_init(struct device *dev) {
    dev->d_blocks = 0;
    dev->d_blocksize = 1;
    dev->d_open = stdout_open;
    dev->d_close = stdout_close;
    dev->d_io = stdout_io;
    dev->d_ioctl = stdout_ioctl;
}
```

可以看到，stdout_open函数完成设备文件打开工作，如果发现用户进程调用open函数的参数flags不是只写（O_WRONLY），则会报错。

**访问操作实现**

stdout_io函数完成设备的写操作工作，具体实现如下：

```
static int
stdout_io(struct device *dev, struct iobuf *iob, bool write) {
    if (write) {
        char *data = iob->io_base;
        for (; iob->io_resid != 0; iob->io_resid --) {
            cputchar(*data ++);
        }
        return 0;
    }
    return -E_INVAL;
}
```

可以看到，要写的数据放在iob->io_base所指的内存区域，一直写到iob->io_resid的值为0为止。每次写操作都是通过cputchar来完成的，此函数最终将通过console外设驱动来完成把数据输出到串口、并口和CGA显示器上过程。另外，也可以注意到，如果用户想执行读操作，则stdout_io函数直接返回错误值**-**E_INVAL。

### stdin 设备文件

这里的stdin设备文件实际上就是指的键盘。这个设备文件是一个只读设备，如果写这个设备，就会出错。接下来我们看看stdin设备的相关处理过程。

**初始化**

stdin设备文件的初始化过程主要由stdin_device_init完成了主要的初始化工作，具体实现如下：

```
static void
stdin_device_init(struct device *dev) {
    dev->d_blocks = 0;
    dev->d_blocksize = 1;
    dev->d_open = stdin_open;
    dev->d_close = stdin_close;
    dev->d_io = stdin_io;
    dev->d_ioctl = stdin_ioctl;

    p_rpos = p_wpos = 0;
    wait_queue_init(wait_queue);
}
```

相对于stdout的初始化过程，stdin的初始化相对复杂一些，多了一个stdin_buffer缓冲区，描述缓冲区读写位置的变量p_rpos、p_wpos以及用于等待缓冲区的等待队列wait_queue。在stdin_device_init函数的初始化中，也完成了对p_rpos、p_wpos和wait_queue的初始化。

**访问操作实现**

stdin_io函数负责完成设备的读操作工作，具体实现如下：

```
static int
stdin_io(struct device *dev, struct iobuf *iob, bool write) {
    if (!write) {
        int ret;
        if ((ret = dev_stdin_read(iob->io_base, iob->io_resid)) > 0) {
            iob->io_resid -= ret;
        }
        return ret;
    }
    return -E_INVAL;
}
```

可以看到，如果是写操作，则stdin_io函数直接报错返回。所以这也进一步说明了此设备文件是只读文件。如果此读操作，则此函数进一步调用dev_stdin_read函数完成对键盘设备的读入操作。dev_stdin_read函数的实现相对复杂一些，主要的流程如下：

```
static int
dev_stdin_read(char *buf, size_t len) {
    int ret = 0;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        for (; ret < len; ret ++, p_rpos ++) {
        try_again:
            if (p_rpos < p_wpos) {
                *buf ++ = stdin_buffer[p_rpos % stdin_BUFSIZE];
            }
            else {
                wait_t __wait, *wait = &__wait;
                wait_current_set(wait_queue, wait, WT_KBD);
                local_intr_restore(intr_flag);

                schedule();

                local_intr_save(intr_flag);
                wait_current_del(wait_queue, wait);
                if (wait->wakeup_flags == WT_KBD) {
                    goto try_again;
                }
                break;
            }
        }
    }
    local_intr_restore(intr_flag);
    return ret;
}
```

在上述函数中可以看出，如果p_rpos < p_wpos，则表示有键盘输入的新字符在stdin_buffer中，于是就从stdin_buffer中取出新字符放到iobuf指向的缓冲区中；如果p_rpos >=p_wpos，则表明没有新字符，这样调用read用户态库函数的用户进程就需要采用等待队列的睡眠操作进入睡眠状态，等待键盘输入字符的产生。

键盘输入字符后，如何唤醒等待键盘输入的用户进程呢？回顾lab1中的外设中断处理，可以了解到，当用户敲击键盘时，会产生键盘中断，在trap_dispatch函数中，当识别出中断是键盘中断（中断号为IRQ_OFFSET + IRQ_KBD）时，会调用dev_stdin_write函数，来把字符写入到stdin_buffer中，且会通过等待队列的唤醒操作唤醒正在等待键盘输入的用户进程。

### 读文件

读文件其实就是读出目录中的目录项，首先假定文件在磁盘上且已经打开。用户进程有如下语句：

```
read(fd, data, len);
```

即读取fd对应文件，读取长度为len，存入data中。下面来分析一下读文件的实现。

**通用文件访问接口层的处理流程**

先进入通用文件访问接口层的处理流程，即进一步调用如下用户态函数：read->sys_read->syscall，从而引起系统调用进入到内核态。到了内核态以后，通过中断处理例程，会调用到sys_read内核函数，并进一步调用sysfile_read内核函数，进入到文件系统抽象层处理流程完成进一步读文件的操作。

**文件系统抽象层的处理流程**

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

### 打开文件

**文件系统抽象层的处理流程**

1. 分配一个空闲的file数据结构变量file在文件系统抽象层的处理中，首先调用的是file_open函数，它要给这个即将打开的文件分配一个file数据结构的变量，这个变量其实是当前进程的打开文件数组current->fs_struct->filemap[]中的一个空闲元素（即还没用于一个打开的文件），而这个元素的索引值就是最终要返回到用户进程并赋值给变量fd1。到了这一步还仅仅是给当前用户进程分配了一个file数据结构的变量，还没有找到对应的文件索引节点。

为此需要进一步调用vfs_open函数来找到path指出的文件所对应的基于inode数据结构的VFS索引节点node。vfs_open函数需要完成两件事情：通过vfs_lookup找到path对应文件的inode；调用vop_open函数打开文件。

1. 找到文件设备的根目录“/”的索引节点需要注意，这里的vfs_lookup函数是一个针对目录的操作函数，它会调用vop_lookup函数来找到SFS文件系统中的“/”目录下的“sfs_filetest1”文件。为此，vfs_lookup函数首先调用get_device函数，并进一步调用vfs_get_bootfs函数（其实调用了）来找到根目录“/”对应的inode。这个inode就是位于vfs.c中的inode变量bootfs_node。这个变量在init_main函数（位于kern/process/proc.c）执行时获得了赋值。
2. 通过调用vop_lookup函数来查找到根目录“/”下对应文件sfs_filetest1的索引节点，，如果找到就返回此索引节点。
3. 把file和node建立联系。完成第3步后，将返回到file_open函数中，通过执行语句“file->node=node;”，就把当前进程的current->fs_struct->filemap[fd]（即file所指变量）的成员变量node指针指向了代表sfs_filetest1文件的索引节点inode。这时返回fd。经过重重回退，通过系统调用返回，用户态的syscall->sys_open->open->safe_open等用户函数的层层函数返回，最终把把fd赋值给fd1。自此完成了打开文件操作。但这里我们还没有分析第2和第3步是如何进一步调用SFS文件系统提供的函数找位于SFS文件系统上的sfs_filetest1文件所对应的sfs磁盘inode的过程。下面需要进一步对此进行分析。

**SFS文件系统层的处理流程**

这里需要分析文件系统抽象层中没有彻底分析的vop_lookup函数到底做了啥。下面我们来看看。在sfs_inode.c中的sfs_node_dirops变量定义了“.vop_lookup = sfs_lookup”，所以我们重点分析sfs_lookup的实现。注意：在lab8中，为简化代码，sfs_lookup函数中并没有实现能够对多级目录进行查找的控制逻辑（在ucore_plus中有实现）。

sfs_lookup有三个参数：node，path，node_store。其中node是根目录“/”所对应的inode节点；path是文件sfs_filetest1的绝对路径/sfs_filetest1，而node_store是经过查找获得的sfs_filetest1所对应的inode节点。

sfs_lookup函数以“/”为分割符，从左至右逐一分解path获得各个子目录和最终文件对应的inode节点。在本例中是调用sfs_lookup_once查找以根目录下的文件sfs_filetest1所对应的inode节点。当无法分解path后，就意味着找到了sfs_filetest1对应的inode节点，就可顺利返回了。

当然这里讲得还比较简单，sfs_lookup_once将调用sfs_dirent_search_nolock函数来查找与路径名匹配的目录项，如果找到目录项，则根据目录项中记录的inode所处的数据块索引值找到路径名对应的SFS磁盘inode，并读入SFS磁盘inode对的内容，创建SFS内存inode。

## 项目组成

```
.   
├── boot   
├── kern  
│ ├── debug  
│ ├── driver   
│ │ ├── clock.c   
│ │ ├── clock.h   
│ │ └── ……   
│ ├── fs   
│ │ ├── devs   
│ │ │ ├── dev.c   
│ │ │ ├── dev\_disk0.c   
│ │ │ ├── dev.h   
│ │ │ ├── dev\_stdin.c   
│ │ │ └── dev\_stdout.c    
│ │ ├── file.c   
│ │ ├── file.h   
│ │ ├── fs.c   
│ │ ├── fs.h   
│ │ ├── iobuf.c   
│ │ ├── iobuf.h   
│ │ ├── sfs       
│ │ │ ├── bitmap.c   
│ │ │ ├── bitmap.h   
│ │ │ ├── sfs.c  
│ │ │ ├── sfs\_fs.c    
│ │ │ ├── sfs.h  
│ │ │ ├── sfs\_inode.c   
│ │ │ ├── sfs\_io.c   
│ │ │ └── sfs\_lock.c  
│ │ ├── swap   
│ │ │ ├── swapfs.c   
│ │ │ └── swapfs.h   
│ │ ├── sysfile.c   
│ │ ├── sysfile.h   
│ │ └── vfs   
│ │ ├── inode.c  
│ │ ├── inode.h   
│ │ ├── vfs.c  
│ │ ├── vfsdev.c   
│ │ ├── vfsfile.c  
│ │ ├── vfs.h   
│ │ ├── vfslookup.c    
│ │ └── vfspath.c  
│ ├── init  
│ ├── libs   
│ │ ├── stdio.c   
│ │ ├── string.c    
│ │ └── ……   
│ ├── mm   
│ │ ├── vmm.c  
│ │ └── vmm.h   
│ ├── process   
│ │ ├── proc.c   
│ │ ├── proc.h  
│ │ └── ……   
│ ├── schedule  
│ ├── sync   
│ ├── syscall   
│ │ ├── syscall.c  
│ │ └── ……   
│ └── trap   
│ ├── trap.c  
│ └── ……  
├── libs    
├── tools   
│ ├── mksfs.c   
│ └── ……   
└── user   
├── badarg.c  
├── badsegment.c    
├── divzero.c   
├── exit.c   
├── faultread.c    
├── faultreadkernel.c  
├── forktest.c    
├── forktree.c        
├── hello.c    
├── libs   
│ ├── dir.c   
│ ├── dir.h   
│ ├── file.c  
│ ├── file.h    
│ ├── initcode.S   
│ ├── lock.h   
│ ├── stdio.c   
│ ├── syscall.c   
│ ├── syscall.h   
│ ├── ulib.c   
│ ├── ulib.h   
│ └── umain.c   
├── ls.c   
├── sh.c     
└── ……
```

本次实验主要是理解kern/fs目录中的部分文件，并可用user/*.c测试所实现的Simple FS文件系统是否能够正常工作。本次实验涉及到的代码包括：

- 文件系统测试用例： user/*.c：对文件系统的实现进行测试的测试用例；
- 通用文件系统接口
  n user/libs/file.[ch]|dir.[ch]|syscall.c：与文件系统操作相关的用户库实行；
  n kern/syscall.[ch]：文件中包含文件系统相关的内核态系统调用接口
  n kern/fs/sysfile.[ch]|file.[ch]：通用文件系统接口和实行
- 文件系统抽象层-VFS
  n kern/fs/vfs/*.[ch]：虚拟文件系统接口与实现
- Simple FS文件系统
  n kern/fs/sfs/*.[ch]：SimpleFS文件系统实现
- 文件系统的硬盘IO接口
  n kern/fs/devs/dev.[ch]|dev_disk0.c：disk0硬盘设备提供给文件系统的I/O访问接口和实现
- 辅助工具
  n tools/mksfs.c：创建一个Simple FS文件系统格式的硬盘镜像。（理解此文件的实现细节对理解SFS文件系统很有帮助）
- 对内核其它模块的扩充
  n kern/process/proc.[ch]：增加成员变量 struct fs_struct *fs_struct，用于支持进程对文件的访问；重写了do_execve load_icode等函数以支持执行文件系统中的文件。
  n kern/init/init.c：增加调用初始化文件系统的函数fs_init。





