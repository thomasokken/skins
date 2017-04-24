<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Free42 Skins</title>
</head>
<body>
  <h3>Free42 Skins</h3>
  <a href="README.txt">README</a>
  <p>
  <table border="1" cellpadding="10">
<?php
    $labels = array(
            "desktop" => "Skins designed for desktop environments",
            "android" => "Skins designed for Android",
            "iphone" => "Skins designed for iPhone"
        );
    $topdir = dirname(__FILE__);
    foreach ($labels as $dir => $title) {
        $subdir = $topdir . "/" . $dir;

        $list = scandir($subdir);
        if ($list === FALSE)
            continue;
        $printed_title = FALSE;
        foreach ($list as $gif) {
            if (!is_file($subdir . "/" . $gif))
                continue;
            $len = strlen($gif);
            if ($len < 4 || substr($gif, $len - 4) != ".gif")
                continue;
            $base = substr($gif, 0, $len - 4);
            $layout = $base . ".layout";
            if (!is_file($subdir . "/" . $layout))
                continue;
            $thumb = $base . ".thumb.png";
            $size = getimagesize($subdir . "/" . $thumb);
            if ($size === FALSE)
                continue;
            if (!$printed_title) {
                print "    <tr bgcolor=\"yellow\"><th colspan=\"4\">" . $title . "</th></tr>\n";
                print "    <tr><th>name</th><th>preview</th><th colspan=\"2\">download</th></tr>\n";
                $printed_title = TRUE;
            }
            $lf = fopen($subdir . "/" . $layout, "r");
            $title = "";
            while (($line = fgets($lf)) !== FALSE) {
                if (strlen($line) == 0 || substr($line, 0, 1) != "#")
                    break;
                $line = substr($line, 1);
                if (strlen($line > 0) && substr($line, 0, 1) == " ")
                    $line = substr($line, 1);
                $title .= $line;
            }
            fclose($lf);
            print "    <tr" . ($title == "" ? "" : (" title=\"" . htmlspecialchars($title) . "\"")) . "><td><b>" . $base . "</b></td>"
                . "<td align=\"center\"><a href=\"" . $dir . "/" . $gif . "\"><img src=\"" . $dir . "/" . $thumb
                            . "\" width=\"" . $size[0] . "\" height=\"" . $size[1] .  "\"></a></td>"
                . "<td><a href=\"" . $dir . "/" . $gif . "\" download>gif</a></td>"
                . "<td><a href=\"" . $dir . "/" . $layout . "\" download>layout</a></td></tr>\n";
        }
    }
?>
  </table>
  <p>
  Go <a href="..">back</a>.
</body>
</html>
