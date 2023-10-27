QEMU := /home/huangber/qemu-4.1.1/riscv64-softmmu/qemu-system-riscv64
.PHONY: qemu 
qemu: $(UCOREIMG) $(SWAPIMG) $(SFSIMG)
 $(V)$(QEMU) -kernel $(UCOREIMG) -nographic
 $(V)$(QEMU) \
 	-machine virt \
 	-nographic \
 	-bios default \
 	-device loader,file=$(UCOREIMG),addr=0x80200000
