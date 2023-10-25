#!/bin/sh
exec > index.html
cat - << EOF
<!DOCTYPE html>
<html>
<head>
  <title>Plus42 Skins</title>
  <meta charset="UTF-8">
  <link rel="icon" type="image/png" href="../images/plus42-icon.png">
  <style>
    .crumb { color: DeepPink }
    .crumb:link { text-decoration: none; }
    .crumb:visited {text-decoration: none; }
    .crumb:active { text-decoration: none; }
    .crumb:hover { text-decoration: underline; }
  </style>
</head>
<body>
  <h3>Plus42 Skins</h3>
  <pre><a href="../.." class="crumb">Home</a> &gt; <a href=".." class="crumb">Plus42</a> &gt; Skins</pre>
  <a href="README.html">README</a> &mdash; <a href="../../free42/skins/">Free42 Skins</a>
  <p>
  <table border="0" cellpadding="10">
EOF
prevdir=null
for layout in `\ls desktop/*.layout | sort -f ; \ls mobile/*.layout | sort -f`
do
    dir=`dirname $layout`
    base=`basename $layout .layout`
    gif=$dir/${base}.gif
    size=`grep '^Skin:' $layout | sed 's/^Skin: 0,0,\([^,]*\),\([^,]*\).*$/\1x\2/'`
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
        mobile)
            title="Android and iOS"
            ;;
        esac
        echo "    <tr bgcolor=\"yellow\"><th colspan=\"3\">Skins designed for $title</th></tr>"
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
    layout_ds=`git log --follow $dir/${base}.layout | awk 'BEGIN { d = ""; f = 0 }; /Date:/ { if (d == "") { d = $0 }; f++}; /Created subdirectories/ { if (f == 1) { d = "" }}; END { print d }'`
    layout_d=`date -jf 'Date: %a %b %d %H:%M:%S %Y %z' '+%Y-%d-%m' "$layout_ds"`
    gif_ds=`git log --follow $dir/${base}.gif | awk 'BEGIN { d = ""; f = 0 }; /Date:/ { if (d == "") { d = $0 }; f++}; /Created subdirectories/ { if (f == 1) { d = "" }}; END { print d }'`
    gif_d=`date -jf 'Date: %a %b %d %H:%M:%S %Y %z' '+%Y-%d-%m' "$gif_ds"`
    date=`(echo $layout_d; echo $gif_d) | sort | tail -1`
    echo "    <tr bgcolor=\"#$color\" $title><td><b>$base</b><br><font size=\"-1\">$size<p>Last Updated: $date</font></td><td align=\"center\"><a href=\"$gif\"><img src=\"$thumb\" width=\"$width\" height=\"$height\"></a></td><td><a href=\"$gif\">view gif</a><br><a href=\"$layout\">view layout</a><p><a href=\"$gif\" download>download gif</a><br><a href=\"$layout\" download>download layout</a></td></tr>"
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
  <a href="..">Go to Plus42 home page</a>
</body>
</html>
EOF
