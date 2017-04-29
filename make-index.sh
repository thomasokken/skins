#!/bin/sh
cat - << EOF
<!DOCTYPE html>
<html>
<head>
  <title>Free42 Skins</title>
</head>
<body>
  <h3>Free42 Skins</h3>
  <a href="README.txt">README</a>
  <p>
  <table border="1" cellpadding="10">
EOF
prevdir=null
for layout in `\ls desktop/*.layout | sort -i ; \ls android/*.layout | sort -i ; \ls iphone/*.layout | sort -i`
do
    dir=`dirname $layout`
    base=`basename $layout .layout`
    gif=$dir/${base}.gif
    if [ ! -f $gif ]
    then
        continue
    fi
    if [ $dir != $prevdir ]
    then
        case $dir in
        desktop)
            title="desktop environments"
            ;;
        android)
            title="Android"
            ;;
        iphone)
            title="iPhone"
            ;;
        esac
        echo "    <tr bgcolor=\"yellow\"><th colspan=\"4\">Skins designed for $title</th></tr>"
        prevdir=$dir
    fi
    thumb=$dir/${base}.thumb.png
    giftopnm $gif | pamscale -xyfit 160 160 | pnmtopng > $thumb
    geom=`file $thumb | sed 's/^.*PNG image data, \([0-9]*\) x \([0-9]*\), .*$/\1 \2/'`
    width=`echo $geom | awk '{print $1}'`
    height=`echo $geom | awk '{print $2}'`
    title=
    while read -r line
    do
        if [ "$line" == "" -o "$line" =~ '^[^#]' ]
        then
            break
        fi
        title="${title}\n${line}"
    done < $layout
    if [ "$title" != "" ]
    then
        title=`echo "$title" | sed 's/&/&amp;/g' | sed 's/</&lt;/g' | sed 's/>/&gt;/g'`
        title=" title=\"${title}\""
    fi
    echo "    <tr><td $title><b>$base</b></td><td align=\"center\"><a href=\"$gif\"><img src=\"$thumb\" width=\"$width\" height=\"$height\"></a></td><td><a href=\"$gif\" download>gif</a></td><td><a href=\"$layout\" download>layout</a></td></tr>"
done
echo << EOF
  </table>
  <p>
  Go <a href="..">back</a>.
</body>
</html>
EOF
