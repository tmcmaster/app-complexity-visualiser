#!/bin/bash


#for j in `for i in \`find -name pom.xml |xargs dirname |xargs printf "%s/src/main/java\n"\`; do test -d $i && echo $i; done`; do echo "----------- $j";   for k in `(cd $j;find . -type d)` ; do echo `echo $k |sed 's/\// /g' |wc -w |awk '{printf("f%d", $1)}'`; done; done

echo "Project Name,Package Name,Package Depth,Line Length,Pachage Files";
for j in `for i in \`find -name pom.xml -printf "%P\n" |xargs dirname |xargs printf "%s/src/main/java\n"\`; do test -d $i && echo $i; done`
do
    echo "";
    echo "$j";
    echo "";
    for k in `(cd $j;find . -type d -printf "%P\n")`
    do
        COUNT=`echo $k |sed 's/\// /g' |wc -w`;
        COUNT=$(($COUNT - 1));
        LENGTH=`echo "$j/$k" |wc -m`;
        FILES=`find $j/$k -maxdepth 1 -type f -name '*.java' |wc -l`;
        if [ $COUNT -gt 15 -o $LENGTH -gt 200 ] || [ $COUNT -gt 5 -a $FILES -lt 1 -o $FILES -gt 100 ] ;
        then
            echo ",$k,$COUNT,$LENGTH,$FILES";
        fi
    done
done 
echo ""
