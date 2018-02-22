function New-Image {
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
    $bitmap = New-Object System.Drawing.Bitmap(500, 500)
    [System.Drawing.Graphics]::FromImage($bitmap).FillRectangle((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)), 0, 0, 500, 500)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $Size = New-Object System.Drawing.PointF( 500.0, 500.0 )
    @{Bitmap = $bitmap; Canvas = $graphics; Size = $Size}
}

function Save-Image {
    param($Image, $Name)
    $qualityParam = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, 100)
    $jpegCodec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() |Where-Object {$_.MimeType -eq "image/jpeg"}
    $encoderParams = New-Object System.Drawing.Imaging.EncoderParameters(1)-Property @{Param = $qualityParam}       
    $Image.Bitmap.Save($Name, $jpegCodec, $encoderParams);
}

$Img = New-Image

$max_iteration=100
$e=5*$max_iteration
$d = 4./$e
$v = 2
for($x = 1; $x -le $e; $x++){
    $v -= $d
    $w = 2
    for($y = 0; $y -lt $e;$y++){
        $w -= $d;
        $a = $b = $c = 0;
        $iteration = -1;
        while( (($a*$a + $b*$b) -lt 4) -band (++$iteration -lt $max_iteration) ) {
            $c = ($a*$a - $b*$b + $v)
            $b = (2*$a*$b + $w)
            $a = $c;
        }
        if ($iteration -lt $max_iteration) {
            $color = [System.Drawing.Color]::White
        } else {
            $color = [System.Drawing.Color]::Black
        }
        $brush = New-Object System.Drawing.SolidBrush($color)
        $Img.Canvas.FillRectangle($brush, $x, $y, 1, 1);
    }
}

Save-Image -Image $Img -Name "Mandelbrot.jpg"

