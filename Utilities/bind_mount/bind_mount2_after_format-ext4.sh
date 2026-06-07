# 复制所有内容从备份到 SSD（注意结尾的斜杠）
sudo cp -r /home/gao/projects_2026H2_original/. /mnt/ex_8T_SSD/

# 或者  使用 rsync（更可靠，显示进度）
sudo rsync -av --progress /home/gao/projects_2026H2_original/ /mnt/ex_8T_SSD/