./qemu-system-x86_64 -m 1G -device strng -hda my-disk.img -hdb my-seed.img -nographic -L pc-bios/ -enable-kvm -device e1000,netdev=net0 -netdev user,id=net0,hostfwd=tcp::5555-:22

