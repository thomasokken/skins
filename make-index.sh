#!/bin/sh
exec > index.html
cat - << EOF
<!DOCTYPE html>
<html>
<head>
  <title>Free42 Skins</title>
  <meta charset="UTF-8">
</head>
<body>
  <h3>Free42 Skins</h3>
  <a href="README.txt">README</a>
  <p>
  <table border="0" cellpadding="10">
EOF
prevdir=null
for layout in `\ls desktop/*.layout | sort -f ; \ls android/*.layout | sort -f ; \ls iphone/*.layout | sort -f`
do
    dir=`dirname $layout`
    base=`basename $layout .layout`
    gif=$dir/${base}.gif
    size=`grep '^Skin:' $layout | sed 's/^Skin: 0,0,\([^,]*\),\([^,]*\).*$/\1x\2/'`
    scale=`grep '^Display:' $layout | sed 's/^Display:  *[^ ][^ ]*  *\([^ ][^ ]*\)  *\([^ ][^ ]*\) .*$/\1\2/'`
    if [[ $scale =~ [^0-9] ]]
    then
        scale="<br><a href="#nonint">uses non-integer display scale</a>"
    else
        scale=""
    fi
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
        echo "    <tr bgcolor=\"yellow\"><th colspan=\"2\">Skins designed for $title</th><td><a href="$dir-skins.zip">download all</a></tr>"
        zip -j -q $dir-skins.zip `\ls $dir/*.gif $dir/*.layout | sort -f`
        prevdir=$dir
        color=dddddd
    fi
    thumb=$dir/${base}.thumb.png
    giftopnm $gif | pamscale -xyfit 160 160 | pnmtopng > $thumb
    geom=`file $thumb | sed 's/^.*PNG image data, \([0-9]*\) x \([0-9]*\), .*$/\1 \2/'`
    width=`echo $geom | awk '{print $1}'`
    height=`echo $geom | awk '{print $2}'`
    title=
    while read -r line
    do
        line=`echo $line | tr -d '\r'`
        if [[ "$line" = "" || "$line" =~ '^[^#]' ]]
        then
            break
        fi
        line=`echo $line | sed -e 's/^# \{0,1\}//'`
        if [ "$title" = "" ]
        then
            title="${line}"
        else
            title="${title}\n${line}"
        fi
    done < $layout
    if [ "$title" != "" ]
    then
        title=`echo "$title" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g'`
        title="title=\"${title}\""
    fi
    echo "    <tr bgcolor=\"#$color\" $title><td><b>$base</b><br><font size=\"-1\">$size$scale</font></td><td align=\"center\"><a href=\"$gif\"><img src=\"$thumb\" width=\"$width\" height=\"$height\"></a></td><td><a href=\"$gif\">view gif</a><br><a href=\"$layout\">view layout</a><p><a href=\"$gif\" download>download gif</a><br><a href=\"$layout\" download>download layout</a></td></tr>"
    if [ $color = "dddddd" ]
    then
        color=eeeeee
    else
        color=dddddd
    fi
done
cat - << EOF
  </table>
  <p>
  <a name="nonint">Non-integer display scales are supported in Free42 for Android, iOS, and MacOS, release 2.0.24g and later.</a>
</body>
  <p>
  <a href="..">Go to Free42 home page</a>
</html>
EOF
