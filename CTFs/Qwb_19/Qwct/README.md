# 2019 QWB Qwct Writeup

由于已经做过了几道题了，所以就直接省去那些繁文缛节了，直接看启动选项，选项里开了一个qwb设备那就说明出现问题的设备就是它了，直接来看qwb_mmio_write和qwb_mmio_read函数，函数代码如下：

```
qwb_mmio_write:
void __fastcall qwb_mmio_write(QwbState *opaque, hwaddr addr, uint64_t val, unsigned int size)
{
  char v4; // r12
  QemuMutex_0 *v5; // r13
  int v6; // edx

  if ( size == 1 )
  {
    v4 = val;
    if ( addr - 0x1000 <= 0x7FF )               // 往crypto_key中写内容 并且要求crypto.statu的值为3
    {
      v5 = &opaque->crypto_statu_mutex;
      qemu_mutex_lock_func(
        &opaque->crypto_statu_mutex,
        "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c",
        427);
      if ( opaque->crypto.statu == 3 )
      {
        qemu_mutex_unlock_impl(v5, "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c", 430);
        qemu_mutex_lock_func(
          &opaque->crypto_buf_mutex,
          "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c",
          431);
        *(opaque + addr - 1472) = v4;
        qemu_mutex_unlock_impl(
          &opaque->crypto_buf_mutex,
          "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c",
          433);
      }
      v6 = 435;
    }
    else
    {
      if ( addr - 0x2000 > 0x7FF )              // 往input_buf中写内容 并且要求crypto.statu的值为1
        return;
      v5 = &opaque->crypto_statu_mutex;
      qemu_mutex_lock_func(
        &opaque->crypto_statu_mutex,
        "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c",
        439);
      if ( opaque->crypto.statu == 1 )
      {
        qemu_mutex_unlock_impl(v5, "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c", 442);
        qemu_mutex_lock_func(
          &opaque->crypto_buf_mutex,
          "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c",
          443);
        *(opaque + addr - 3520) = v4;
        qemu_mutex_unlock_impl(
          &opaque->crypto_buf_mutex,
          "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c",
          445);
      }
      v6 = 447;
    }
    qemu_mutex_unlock_impl(v5, "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c", v6);
  }
}
```

**write函数很简单，addr在input_buf范围就往input_buf里面写数据，在crypto_key范围就往crypto_key里面写数据**

```
uint64_t __fastcall qwb_mmio_read(QwbState *opaque, hwaddr addr, unsigned int size)
{
  QemuMutex_0 *v3; // rbp
  uint64_t result; // rax
  QemuMutex_0 *v5; // rbp
  QemuMutex_0 *v6; // rbp
  QemuMutex_0 *v7; // rbp
  __uint64_t v8; // rax
  QemuMutex_0 *v9; // rbp
  __uint64_t v10; // rax
  QemuMutex_0 *v11; // rbp
  QemuMutex_0 *v12; // rbp
  QemuMutex_0 *v13; // rbp
  QemuMutex_0 *v14; // rbp
  QemuMutex_0 *v15; // rbp
  QemuMutex_0 *v16; // rbp
  unsigned int v17; // er12
  size_t v18; // rax
  bool v19; // dl
  bool v20; // r12
  QemuMutex_0 *v21; // r13
  unsigned __int8 v22; // bp
  unsigned __int8 v23; // bp
  unsigned __int8 v24; // bl

  switch ( addr )
  {
    case 0uLL:                                  // addr = 0 and crypto.statu != 5
                                                // init crypto_key input_buf crypto_buf
                                                // set crypto.statu = 0
      v6 = &opaque->crypto_statu_mutex;
      qemu_mutex_lock_func(
        &opaque->crypto_statu_mutex,
        "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c",
        160);
      if ( (opaque->crypto.statu & 0xFFFFFFFFFFFFFFFDLL) == 5 )
      {
        qemu_mutex_unlock_impl(v6, "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c", 163);
        result = -1LL;
      }
      else
      {
        qemu_mutex_unlock_impl(v6, "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c", 166);
        qemu_mutex_lock_func(
          &opaque->crypto_buf_mutex,
          "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c",
          168);
        *opaque->crypto.crypt_key = 0LL;
        *&opaque->crypto.crypt_key[2040] = 0LL;
        memset(
          (&opaque->crypto.crypt_key[8] & 0xFFFFFFFFFFFFFFF8LL),
          0,
          8LL * ((opaque - ((opaque + 2632) & 0xFFFFFFF8) + 4672) >> 3));
        *opaque->crypto.input_buf = 0LL;
        *&opaque->crypto.input_buf[2040] = 0LL;
        memset(
          (&opaque->crypto.input_buf[8] & 0xFFFFFFFFFFFFFFF8LL),
          0,
          8LL * ((opaque - ((opaque + 4680) & 0xFFFFFFF8) + 6720) >> 3));
        *opaque->crypto.output_buf = 0LL;
        *&opaque->crypto.output_buf[2040] = 0LL;
        memset(
          (&opaque->crypto.output_buf[8] & 0xFFFFFFFFFFFFFFF8LL),
          0,
          8LL * ((opaque - ((opaque + 6728) & 0xFFFFFFF8) + 8768) >> 3));
        qemu_mutex_unlock_impl(
          &opaque->crypto_buf_mutex,
          "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c",
          172);
        qemu_mutex_lock_func(v6, "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c", 174);
        opaque->crypto.statu = 0LL;
        qemu_mutex_unlock_impl(v6, "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c", 176);
        result = 1LL;
      }
      return result;
    case 1uLL:                                  // addr = 1
                                                // if crypto.statu = 0 or 2 set crypto.statu = 3
      v7 = &opaque->crypto_statu_mutex;
      qemu_mutex_lock_func(
        &opaque->crypto_statu_mutex,
        "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c",
        181);
      v8 = opaque->crypto.statu;
      if ( v8 )
      {
        if ( v8 == 2 )
        {
          opaque->crypto.statu = 3LL;
          qemu_mutex_unlock_impl(v7, "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c", 191);
          result = 1LL;
        }
        else
        {
          qemu_mutex_unlock_impl(v7, "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c", 196);
          result = -1LL;
        }
      }
      else
      {
        opaque->crypto.statu = 3LL;
        qemu_mutex_unlock_impl(v7, "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c", 185);
        result = 1LL;
      }
      return result;
    case 2uLL:                                  // addr = 2
                                                // if crypto.statu = 0 or 4 set crypto.statu = 1
      v9 = &opaque->crypto_statu_mutex;
      qemu_mutex_lock_func(
        &opaque->crypto_statu_mutex,
        "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c",
        202);
      v10 = opaque->crypto.statu;
      if ( v10 )
      {
        if ( v10 == 4 )
        {
          opaque->crypto.statu = 1LL;
          qemu_mutex_unlock_impl(v9, "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c", 212);
          result = 1LL;
        }
        else
        {
          qemu_mutex_unlock_impl(v9, "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c", 217);
          result = -1LL;
        }
      }
      else
      {
        opaque->crypto.statu = 1LL;
        qemu_mutex_unlock_impl(v9, "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c", 206);
        result = 1LL;
      }
      return result;
    case 3uLL:                                  // addr = 3
                                                // if crypto.statu = 3 set crypto.statu = 4
      v11 = &opaque->crypto_statu_mutex;
      qemu_mutex_lock_func(
        &opaque->crypto_statu_mutex,
        "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c",
        223);
      if ( opaque->crypto.statu == 3 )
      {
        opaque->crypto.statu = 4LL;
        qemu_mutex_unlock_impl(v11, "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c", 227);
        result = 1LL;
      }
      else
      {
        qemu_mutex_unlock_impl(v11, "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c", 232);
        result = -1LL;
      }
      return result;
    case 4uLL:                                  // addr = 4
                                                // if crypto.statu = 1 set crypto.statu = 2
      v12 = &opaque->crypto_statu_mutex;
      qemu_mutex_lock_func(
        &opaque->crypto_statu_mutex,
        "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c",
        238);
      if ( opaque->crypto.statu == 1 )
      {
        opaque->crypto.statu = 2LL;
        qemu_mutex_unlock_impl(v12, "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c", 242);
        result = 1LL;
      }
      else
      {
        qemu_mutex_unlock_impl(v12, "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c", 247);
        result = -1LL;
      }
      return result;
    case 5uLL:                                  // addr = 5
                                                // if crypto.statu = 2 or 4 set crypto.encrypt_function = aes_encrypt_function
      v13 = &opaque->crypto_statu_mutex;
      qemu_mutex_lock_func(
        &opaque->crypto_statu_mutex,
        "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c",
        253);
      if ( (opaque->crypto.statu - 2) & 0xFFFFFFFFFFFFFFFDLL )
      {
        qemu_mutex_unlock_impl(v13, "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c", 264);
        result = -1LL;
      }
      else
      {
        qemu_mutex_unlock_impl(v13, "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c", 256);
        qemu_mutex_lock_func(
          &opaque->crypto_buf_mutex,
          "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c",
          257);
        opaque->crypto.encrypt_function = aes_encrypt_function;
        qemu_mutex_unlock_impl(
          &opaque->crypto_buf_mutex,
          "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c",
          259);
        result = 1LL;
      }
      return result;
    case 6uLL:                                  // addr = 6
                                                // if crypto.statu = 2 or 4 set crypto.decrypt_function = aes_decrypto_function
      v14 = &opaque->crypto_statu_mutex;
      qemu_mutex_lock_func(
        &opaque->crypto_statu_mutex,
        "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c",
        270);
      if ( (opaque->crypto.statu - 2) & 0xFFFFFFFFFFFFFFFDLL )
      {
        qemu_mutex_unlock_impl(v14, "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c", 281);
        result = -1LL;
      }
      else
      {
        qemu_mutex_unlock_impl(v14, "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c", 273);
        qemu_mutex_lock_func(
          &opaque->crypto_buf_mutex,
          "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c",
          274);
        opaque->crypto.decrypt_function = aes_decrypto_function;
        qemu_mutex_unlock_impl(
          &opaque->crypto_buf_mutex,
          "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c",
          276);
        result = 1LL;
      }
      return result;
    case 7uLL:                                  // addr = 7
                                                // if crypto.statu = 2 or 4 set crypto.encrypt_function = stream_encrypto_fucntion
      v15 = &opaque->crypto_statu_mutex;
      qemu_mutex_lock_func(
        &opaque->crypto_statu_mutex,
        "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c",
        287);
      if ( (opaque->crypto.statu - 2) & 0xFFFFFFFFFFFFFFFDLL )
      {
        qemu_mutex_unlock_impl(v15, "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c", 298);
        result = -1LL;
      }
      else
      {
        qemu_mutex_unlock_impl(v15, "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c", 290);
        qemu_mutex_lock_func(
          &opaque->crypto_buf_mutex,
          "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c",
          291);
        opaque->crypto.encrypt_function = stream_encrypto_fucntion;
        qemu_mutex_unlock_impl(
          &opaque->crypto_buf_mutex,
          "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c",
          293);
        result = 1LL;
      }
      return result;
    case 8uLL:                                  // addr = 8
                                                // if crypto.statu = 2 or 4 set crypto.decrypt_function = stream_decrypto_fucntion
      v16 = &opaque->crypto_statu_mutex;
      qemu_mutex_lock_func(
        &opaque->crypto_statu_mutex,
        "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c",
        304);
      if ( (opaque->crypto.statu - 2) & 0xFFFFFFFFFFFFFFFDLL )
      {
        qemu_mutex_unlock_impl(v16, "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c", 315);
        result = -1LL;
      }
      else
      {
        qemu_mutex_unlock_impl(v16, "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c", 307);
        qemu_mutex_lock_func(
          &opaque->crypto_buf_mutex,
          "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c",
          308);
        opaque->crypto.decrypt_function = stream_decrypto_fucntion;
        qemu_mutex_unlock_impl(
          &opaque->crypto_buf_mutex,
          "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c",
          310);
        result = 1LL;
      }
      return result;
    case 9uLL:                                  // addr = 9
                                                // if crypto.statu = 2 or 4 create encrypt thread
                                                // set crypto.statu = 5
      v3 = &opaque->crypto_statu_mutex;
      qemu_mutex_lock_func(
        &opaque->crypto_statu_mutex,
        "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c",
        321);
      if ( (opaque->crypto.statu - 2) & 0xFFFFFFFFFFFFFFFDLL )
      {
        qemu_mutex_unlock_impl(v3, "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c", 337);
        result = -1LL;
      }
      else if ( opaque->crypto.encrypt_function )
      {
        opaque->crypto.statu = 5LL;
        qemu_mutex_unlock_impl(v3, "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c", 327);
        qemu_thread_create(&opaque->thread, "qwb_encrypt_thread", qwb_encrypt_processing_thread, opaque, 0);
        result = 1LL;
      }
      else
      {
        qemu_mutex_unlock_impl(v3, "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c", 332);
        result = -1LL;
      }
      return result;
    case 0xAuLL:                                // addr = 10
                                                // if crypto.statu = 2 or 4 create decrypt thread
                                                // set crypto.statu = 7
      v5 = &opaque->crypto_statu_mutex;
      qemu_mutex_lock_func(
        &opaque->crypto_statu_mutex,
        "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c",
        343);
      if ( (opaque->crypto.statu - 2) & 0xFFFFFFFFFFFFFFFDLL )
      {
        qemu_mutex_unlock_impl(v5, "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c", 359);
        result = -1LL;
      }
      else if ( opaque->crypto.decrypt_function )
      {
        opaque->crypto.statu = 7LL;
        qemu_mutex_unlock_impl(v5, "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c", 349);
        qemu_thread_create(&opaque->thread, "qwb_decrypt_thread", qwb_decrypt_processing_thread, opaque, 0);
        result = 1LL;
      }
      else
      {
        qemu_mutex_unlock_impl(v5, "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c", 354);
        result = -1LL;
      }
      return result;
    default:
      v17 = size;
      if ( addr <= 0x2FFF )
      {
        if ( addr <= 0x1FFF )
        {
          v21 = &opaque->crypto_buf_mutex;
          qemu_mutex_lock_func(
            &opaque->crypto_buf_mutex,
            "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c",
            395);
          if ( addr <= 0xFFF )
          {
LABEL_37:
            qemu_mutex_unlock_impl(v21, "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c", 410);
            return -1LL;
          }
          v20 = v17 == 1;
          goto LABEL_35;
        }
        v20 = size == 1;
      }
      else
      {
        v18 = strlen(opaque->crypto.output_buf);
        v19 = v17 == 1;
        v20 = v17 == 1;
        // 当addr的范围在output_buf范围内时,经过这个分支
        // 这里有一个越界读的漏洞点
        // 当我们把input_buf和crypto_key都填满时,经过加密后output_buf也会被填满
        // 因为strlen会被\0截断,但是此时ouput_buf是填满的所以strlen读到的长度就会大于output_buf的长度
        // 所以我们就可以读到output_buf后面的内容,output_buf后面存储的时加密函数的地址
        // 这样我们就可以通过这个地址得到程序基址和system等关键函数的地址
        if ( addr < v18 + 0x3000 && v19 )
        {
          qemu_mutex_lock_func(
            &opaque->crypto_statu_mutex,
            "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c",
            367);
          if ( (opaque->crypto.statu - 6) & 0xFFFFFFFFFFFFFFFDLL )
          {
            qemu_mutex_unlock_impl(
              &opaque->crypto_buf_mutex,
              "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c",
              375);
            qemu_mutex_unlock_impl(
              &opaque->crypto_statu_mutex,
              "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c",
              376);
            result = -1LL;
          }
          else
          {
            qemu_mutex_unlock_impl(
              &opaque->crypto_statu_mutex,
              "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c",
              370);
            v22 = *(opaque + addr - 5568);
            qemu_mutex_unlock_impl(
              &opaque->crypto_buf_mutex,
              "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c",
              372);
            result = v22;
          }
          return result;
        }
      }
      // 当addr的范围在input_buf范围内时,经过这个分支
      if ( addr < strlen(opaque->crypto.input_buf) + 0x2000 && v20 )
      {
        qemu_mutex_lock_func(
          &opaque->crypto_statu_mutex,
          "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c",
          382);
        if ( opaque->crypto.statu == 2 )
        {
          qemu_mutex_unlock_impl(
            &opaque->crypto_statu_mutex,
            "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c",
            385);
          v23 = *(opaque + addr - 3520);
          qemu_mutex_unlock_impl(
            &opaque->crypto_buf_mutex,
            "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c",
            387);
          result = v23;
        }
        else
        {
          qemu_mutex_unlock_impl(
            &opaque->crypto_buf_mutex,
            "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c",
            390);
          qemu_mutex_unlock_impl(
            &opaque->crypto_statu_mutex,
            "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c",
            391);
          result = -1LL;
        }
        return result;
      }
      v21 = &opaque->crypto_buf_mutex;
      qemu_mutex_lock_func(
        &opaque->crypto_buf_mutex,
        "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c",
        395);
LABEL_35:
      // 当addr的范围在crypto_key范围内时,经过这个分支
      if ( addr >= strlen(opaque->crypto.crypt_key) + 0x1000 || !v20 )
        goto LABEL_37;
      qemu_mutex_lock_func(
        &opaque->crypto_statu_mutex,
        "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c",
        398);
      if ( opaque->crypto.statu == 4 )
      {
        qemu_mutex_unlock_impl(
          &opaque->crypto_statu_mutex,
          "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c",
          401);
        v24 = *(opaque + addr - 1472);
        qemu_mutex_unlock_impl(v21, "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c", 403);
        result = v24;
      }
      else
      {
        qemu_mutex_unlock_impl(
          &opaque->crypto_statu_mutex,
          "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c",
          406);
        qemu_mutex_unlock_impl(v21, "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c", 407);
        result = -1LL;
      }
      return result;
  }
}
```

总结一下就是：

1. addr = 0 并且 crypto.statu != 5 就初始化 crypto_key input_buf crypto_buf 然后设置 crypto.statu = 0
2. addr = 1 如果 crypto.statu = 0 或者 2 就设置 crypto.statu = 3
3. addr = 2 如果 crypto.statu = 0 或者 4 就设置 crypto.statu = 1
4. addr = 3 如果 crypto.statu = 3 就设置 crypto.statu = 4
5. addr = 4 如果 crypto.statu = 1 就设置 crypto.statu = 2
6. addr = 5 如果 crypto.statu = 2 或者 4 就设置 crypto.encrypt_function = aes_encrypt_function
7. addr = 6 如果 crypto.statu = 2 或者 4 就设置 crypto.decrypt_function = aes_decrypto_function
8. addr = 7 如果 crypto.statu = 2 或者 4 就设置 crypto.encrypt_function = stream_encrypto_fucntion
9. addr = 8 如果 crypto.statu = 2 或者 4 就设置 crypto.decrypt_function = stream_decrypto_fucntion
10. addr = 9 如果 crypto.statu = 2 或者 4 就创建一个 encrypt thread 并且设置 crypto.statu = 5
11. addr = 10 如果 crypto.statu = 2 或者 4 就创建一个 decrypt thread 并且设置 crypto.statu = 7
12. addr > 10
    - addr的范围在output_buf范围内时，返回output_buf中的内容
    - addr的范围在input_buf范围内时，返回input_buf中的内容
    - addr的范围在crypto_key范围内时，返回crypto_key中的内容

有两个漏洞点，一个越界读，一个越界写，越界读在qwb_mmio_read里，越界写在aes_encrypt_function里，越界读问题代码如下，并且添加了注释：

```
v18 = strlen(opaque->crypto.output_buf);
v19 = v17 == 1;
v20 = v17 == 1;
// 当addr的范围在output_buf范围内时,经过这个分支
// 这里有一个越界读的漏洞点
// 当我们把input_buf和crypto_key都填满时,经过加密后output_buf也会被填满
// 因为strlen会被\0截断,但是此时ouput_buf是填满的所以strlen读到的长度就会大于output_buf的长度
// 所以我们就可以读到output_buf后面的内容,output_buf后面存储的时加密函数的地址
// 这样我们就可以通过这个地址得到程序基址和system等关键函数的地址
if ( addr < v18 + 0x3000 && v19 )
{
  qemu_mutex_lock_func(
    &opaque->crypto_statu_mutex,
    "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c",
    367);
  if ( (opaque->crypto.statu - 6) & 0xFFFFFFFFFFFFFFFDLL )
  {
    qemu_mutex_unlock_impl(
      &opaque->crypto_buf_mutex,
      "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c",
      375);
    qemu_mutex_unlock_impl(
      &opaque->crypto_statu_mutex,
      "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c",
      376);
    result = -1LL;
  }
  else
  {
    qemu_mutex_unlock_impl(
      &opaque->crypto_statu_mutex,
      "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c",
      370);
    v22 = *(opaque + addr - 5568);
    qemu_mutex_unlock_impl(
      &opaque->crypto_buf_mutex,
      "/home/ctflag/Desktop/QWB/online/QMCT/qemu_qwb/hw/misc/qwb.c",
      372);
    result = v22;
  }
  return result;
}
```

越界写问题代码如下并且添加了注释：

```
if ( len_of_input_tmp1 )
{
  output_buf_index = output_buf;
  v18 = &input[((len_of_input_tmp1 - 1) & 0xFFFFFFFFFFFFFFF0LL) + 16];
  do
  {
    output_buf_tmp = output_buf_index;
    input_buf_tmp = input_buf_index;
    input_buf_index += 16;
    output_buf_index += 16;
    AES_ecb_encrypt(input_buf_tmp, output_buf_tmp, &aes, 1LL);
  }
  while ( v18 != input_buf_index );
  overflow_data = 0LL;
  v28 = 0;
  tmp_1 = 0;
  for ( i = 0LL; ; tmp_1 = *(&overflow_data + (i & 7)) )
  {
    tmp_2 = output_buf[i] ^ tmp_1;
    index = i++;
    *(&overflow_data + (index & 7)) = tmp_2;
    if ( i == len_of_input_tmp1 )
      break;
  }
  overdata_or_zero = overflow_data;
  // 这里有一个越界写的漏洞点
  // 当len_of_input的值为0x800时(len_of_input_tmp1的值也为0x800),会经过这个分支
  // 这个分支里面会生成一个overflow_data并且在最后会把这个overflow_data赋给output_buf
  // 而此时写就相当于往output_buf[0x800]中写内容,如果以0x800作为下标那么就会写到output_buf后面的加密函数地址
  // 从而就可以控制程序执行流程了
}
```

利用方法：

首先通过越界读泄露出基址以及system等关键信息，然后利用越界写把system的地址写入到crypto.encrypt_function，然后在input_buf里面填入想要执行的命令，再执行加密函数的时候就会执行system("command")了

exp代码：[exp.c]()

exp执行之后的效果如下：

![](1.gif)