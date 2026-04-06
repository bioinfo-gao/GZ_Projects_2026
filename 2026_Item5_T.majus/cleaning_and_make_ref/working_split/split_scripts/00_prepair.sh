mkdir /home/gao/projects/2026_Item5_T.majus/working_split
cd /home/gao/Dropbox/Quote_03062602/
cp WTS4_1 WTS4_2 WTS4_5 WhS4_1 WhS4_4  /home/gao/projects/2026_Item5_T.majus/working_split 
mv WTS4_1 WTS4_2 WTS4_5 WhS4_1 WhS4_4  /home/gao/projects/2026_Item5_T.majus/wrong_raw_data 

cd /home/gao/projects/2026_Item5_T.majus/working_split

mkdir split_scripts/   # 存放以下脚本
cd split_scripts/   # 存放以下脚本
touch 01_assess_insert_size.sh
touch 02_split_by_insert.sh
# touch 03_validate_by_sequence.py
# touch 04_merge_and_output.sh