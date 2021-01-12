#based on https://www.thomas-krenn.com/de/wiki/LVM_vergr%C3%B6%C3%9Fern
pvs
vgs
lvs
df -h
vgextend ubuntu.vg /dev/sda3
lvextend -l +100%FREE /dev/mapper/ubunut--vg-ubuntu--lv 
resize2fs -p /dev/mapper/ubunut--vg-ubuntu--lv
