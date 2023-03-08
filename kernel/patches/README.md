Applies patches for a system that boots, reboots, and has network support, and doesn't have completely broken Kconfigs/makefiles/code copied in from random kernel versions.  No GPU.

Ref: https://rvspace.org/en/project/JH7110_Upstream_Plan

These patches are from the following:

* Minimal system - clock/reset/dts
  * https://patchwork.kernel.org/project/linux-riscv/cover/20230221024645.127922-1-hal.feng@starfivetech.com/
* SDIO/EMMC
  * https://patchwork.kernel.org/project/linux-riscv/cover/20230215113249.47727-1-william.qiu@starfivetech.com/
  * **Different link than wiki provides**
* GMAC
  * https://patchwork.kernel.org/project/netdevbpf/cover/20230303085928.4535-1-samin.guo@starfivetech.com/

They were applied with "git am -3 ..."

The first two patch-sets required some manual work to deal with some empty commits, and minor conflict resolution.
