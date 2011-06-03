#!/bin/bash

# 用于列出某一目录中文本并阅读，显示章节列表，按章节阅读

# 功能待添加：目录搜索，阅读进度记忆,书签管理，txt下载？

# 主要依赖： vim，enca，iconv

# Written by Wei Li, Jan 29, 2010 ; Modified May 27,2011



# 小说目录

MAINDIR=~/Public/ebook

#MAINDIR=$1



# 工作目录

DIR=$MAINDIR



# 列表文件

LIST=~/tmp/novel_list



#TXT="$1"

# 目录文件

CONTENTS="/home/luoshu/tmp/contents"



# 阅读进度文件

PROGRESS="/home/luoshu/tmp/progress"



#显示小说列表菜单

get_list (){

 cd "$DIR"

 echo "$DIR 中的小说文件："

 ls -w1 -B | sort  > $LIST

 cat -n $LIST



# 设置可供挑选的最大数量

 MAX=`cat $LIST | grep -v ':' | wc -l`

}



usage (){

    cat <<EOF

 ------------------------------------

 用法：输入数字选取待阅文件或目录

       输入h(H)返回主目录

       输入q(Q)退出程序

 ------------------------------------

EOF

}



menu (){

 get_list

 #echo "请选择文本阅读(请输入序号；Q/q退出;h/H返回主目录)："

 usage

 read CHOICE



# 读取合法的序号

 while true

 do

# 判断是否退出

 if [ "$CHOICE" = 'q' -o "$CHOICE" = 'Q' ];then

   # rm  $LIST  #退出前删除列表文件

    echo "Exit"

    exit 0

 elif [ "$CHOICE" = 'h' -o "$CHOICE" = 'H' ];then

    DIR=$MAINDIR

    CHOICE=''

    get_list

    echo "请重新输入 ："

    read CHOICE;

    continue

 elif ! [ "$CHOICE" -le "$MAX" -a "$CHOICE" -ge "1" ];then

    echo "不合法的序号";

    echo "请重新输入 ："

    read CHOICE;

 else

# 得到结果

  NOVEL=`cat $LIST | sed -n "$CHOICE"p`



# 检测文件编码

  ENCODE=` [ -f "$NOVEL" ] && enca "$NOVEL" | head -1 | cut -d ';' -f2 | awk '{print $1}'`



  break

 fi

 done

}



# 取得文本章节目录

Get_content (){

    if [ "$ENCODE" = "GBK" -o "$ENCODE" = "GB2312" ];then

        mv "$NOVEL" orig_"$NOVEL"

        echo "-----------------------

      $NOVEL 已备份为 orig_$NOVEL

      _______________________"



        iconv  -f GBK -t UTF-8 orig_"$NOVEL" -o "$NOVEL"

    fi

        cat -n "$NOVEL" | grep '第[一二三四五六七八九十0-9 ]' | grep '[一二三四五六七八九十0-9 ][章节回]' > "$CONTENTS"



# 章节数目

CHAP_NUM=`cat $CONTENTS | wc -l`

}



# 取得所选择的章节

Get_chapter (){



cat -n "$CONTENTS"



echo "--------------------

请选择章节(q/Q退出):

--------------------"

read NUM



# 输入不合理，则循环

while ! [ "$NUM" -ge 1 -a "$NUM" -le "$CHAP_NUM" ]

do

    if [ "$NUM" = 'q' -o "$NUM" = 'Q' ];then

        exit 0

    fi

read NUM

done



# 所选章节的行号

CHAPTER=`cat "$CONTENTS" | sed -n "$NUM"p`

LINE=`cat "$CONTENTS" | sed -n "$NUM"p | awk '{print $1}'`

}



#处理选择的结果

while true

do

    menu

    DIR="`pwd`/$NOVEL"

# 判断是否是文件，是则打开

# [ -f "$NOVEL" ] &&  vim "$NOVEL"

if [ -f "$NOVEL" ];then

    Get_content $NOVEL

    Get_chapter

    echo "$NOVEL:$CHAPTER  `date +"%H:%M:%S %Y-%m-%d"`" >> "$PROGRESS"

    vim +"$LINE" "$NOVEL"

fi

done



exit 0


