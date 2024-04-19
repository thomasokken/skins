#!/bin/sh
exec > index.html
cat - << EOF
<!DOCTYPE html>
<html>
<head>
  <title>Free42 Skins</title>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,user-scalable=no"/>
  <link rel="icon" type="image/png" href="../images/free42-icon.png">
  <style>
    .crumb { color: DeepPink }
    .crumb:link { text-decoration: none; }
    .crumb:visited {text-decoration: none; }
    .crumb:active { text-decoration: none; }
    .crumb:hover { text-decoration: underline; }
  </style>
  <script>
    var lastSortKey = "sk_name";
    var sortDirection = { "sk_name": true, "sk_date": false, "sk_pixels": false, "sk_width": false, "sk_height": false, "sk_aspect": false };

    function sortList(which) {
        var rows = document.getElementsByTagName("tr");
        var header = [];
        var list = [];
        for (var i = 0; i < rows.length; i++) {
            var row = rows[i];
            if (row.bgColor == "yellow") {
                header.push(row);
                list.push([]);
            } else {
                list[list.length - 1].push(row);
            }
        }

        var label = document.getElementById(lastSortKey);
        label.innerText = label.innerText.substring(0, label.innerText.length - 1);
        var ascending = sortDirection[which];
        if (which == lastSortKey) {
            ascending = !ascending;
            sortDirection[which] = ascending;
        }
        label = document.getElementById(which);
        label.innerText += ascending ? "▲" : "▼";
        lastSortKey = which;

        for (var i = 0; i < list.length; i++) {
            list[i].sort(function(a, b) {
                    var pa = getKey(a, which);
                    var pb = getKey(b, which);
                    var res = pa.localeCompare(pb);
                    return ascending ? res : -res;
                });
        }
        var parent = rows[0].parentNode;
        for (var i = 0; i < list.length; i++) {
            parent.appendChild(header[i]);
            for (var j = 0; j < list[i].length; j++) {
                var item = list[i][j];
                item.bgColor = j % 2 == 0 ? "#dddddd" : "#eeeeee";
                parent.appendChild(item);
            }
        }
    }

    function getKey(item, which) {
        if (which == "sk_name")
            return item.childNodes[0].childNodes[0].innerText;
        else if (which == "sk_date")
            return item.childNodes[0].childNodes[3].childNodes[0].innerText;
        var res = item.childNodes[0].childNodes[2].innerText;
        var t = res.indexOf("x");
        var u = res.indexOf(" ");
        var x = +res.substring(0, t);
        var y = +res.substring(t + 1, u);
        var r;
        switch (which) {
            case "sk_pixels": r = x * y; break;
            case "sk_width": r = x; break;
            case "sk_height": r = y; break;
            case "sk_aspect": r = Math.round((1000.0 * x) / y + 0.5); break;
        }
        r = "000000000" + r;
        return r.substring(r.length - 9);
    }
  </script>
</head>
<body>
  <h3>Free42 Skins</h3>
  <pre><a href="../.." class="crumb">Home</a> &gt; <a href=".." class="crumb">Free42</a> &gt; Skins</pre>
  <a href="README.html">README</a>
  <pre>Sort by: <a href="javascript:sortList('sk_name')" class="crumb" id="sk_name">name▲</a> <a href="javascript:sortList('sk_date')" class="crumb" id="sk_date">date</a> <a href="javascript:sortList('sk_pixels')" class="crumb" id="sk_pixels">pixels</a> <a href="javascript:sortList('sk_width')" class="crumb" id="sk_width">width</a> <a href="javascript:sortList('sk_height')" class="crumb" id="sk_height">height</a> <a href="javascript:sortList('sk_aspect')" class="crumb" id="sk_aspect">aspect</a></pre>
  <table border="0" cellpadding="10">
EOF
prevdir=null
for layout in `\ls desktop/*.layout | sort -f ; \ls mobile/*.layout | sort -f`
do
    dir=`dirname $layout`
    base=`basename $layout .layout`
    gif=$dir/${base}.gif
    size=`grep '^Skin:' $layout | sed 's/^Skin: [0-9]*,[0-9]*,\([0-9]*\),\([0-9]*\).*$/\1x\2/'`
    width=`echo $size | sed 's/^\([^x]*\)x.*$/\1/'`
    height=`echo $size | sed 's/^[^x]*x\(.*\)$/\1/'`
    if [ $width -eq $height ]
    then
        size="$size (1:1)"
    elif [ $width -lt $height ]
    then
        size="$size (1:`echo "scale=2; $height / $width" | bc`)"
    else
        size="$size (`echo "scale=2; $width / $height" | bc`:1)"
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
    layout_d=`date -jf 'Date: %a %b %d %H:%M:%S %Y %z' '+%Y-%m-%d' "$layout_ds"`
    gif_ds=`git log --follow $dir/${base}.gif | awk 'BEGIN { d = ""; f = 0 }; /Date:/ { if (d == "") { d = $0 }; f++}; /Created subdirectories/ { if (f == 1) { d = "" }}; END { print d }'`
    gif_d=`date -jf 'Date: %a %b %d %H:%M:%S %Y %z' '+%Y-%m-%d' "$gif_ds"`
    date=`(echo $layout_d; echo $gif_d) | sort | tail -1`
    if [ -f $dir/${base}.zip ]
    then
        zip_link="<p><b><font color=\"red\">Support files:</font> <a href=\"$dir/${base}.zip\">zip</a></b>"
    else
        zip_link=""
    fi
    echo "    <tr bgcolor=\"#$color\" $title><td><b>$base</b><br><font size=\"-1\">$size<p>Last Updated: $date</font>$zip_link</td><td align=\"center\"><a href=\"$gif\"><img src=\"$thumb\" width=\"$width\" height=\"$height\"></a></td><td><a href=\"$gif\">view gif</a><br><a href=\"$layout\">view layout</a><p><a href=\"$gif\" download>download gif</a><br><a href=\"$layout\" download>download layout</a></td></tr>"
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
  <a href="..">Go to Free42 home page</a>
</body>
</html>
EOF
