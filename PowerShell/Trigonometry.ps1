function Deg2Rad {
    param($Degrees)
    ($Degrees * [math]::PI) / 180
}

function Deg2Local {
    param($Point)
    $y = (250 - ($Point.Y * 50))
    $x = (50 + (400 * $Point.X))
    if ($y -lt 50) { $y = 50}
    if ($y -gt 450) { $y = 450}
    New-Object System.Drawing.PointF( $x, $y )
}

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

function Show-Grid {
    param($Image)
    # Light Axis
    $p = New-Object System.Drawing.Pen( [System.Drawing.Color]::FromArgb(240,240,240) )
    (1..$Image.Size.X) | ?{ $_ % 50 -eq 0} | %{
        $Image.Canvas.DrawLine($p, $_, 0, $_, 500)
        $Image.Canvas.DrawLine($p, 0, $_, 500, $_)
    }
    # Main Axis
    $p = New-Object System.Drawing.Pen( [System.Drawing.Color]::FromArgb(100,100,100) )
    $Image.Canvas.DrawLine($p, 50, 50, 50, 450)
    $Image.Canvas.DrawLine($p, 0, 250, 450, 250)
    # Axis labels
    $p = New-Object System.Drawing.Pen([System.Drawing.Color]::Black)
    $xLabels = @("PI/2", "PI", "3PI/2", "2PI", "")
    $yLabels = @("-2", "-1", "0", "1", "2")
    for ($i=0; $i -lt 5; $i++) {
        $Image.Canvas.DrawString(
            $xLabels[$i],
            (New-Object System.Drawing.Font(([System.Drawing.FontFamily]::Families | ?{ $_.Name -eq "Verdana"}), 4, [System.Drawing.FontStyle]::Regular)), 
            (New-Object system.Drawing.SolidBrush([System.Drawing.Color]::Black)), 135 + ($i * 100), 255
        )
        $Image.Canvas.DrawString(
            $yLabels[$i],
            (New-Object System.Drawing.Font(([System.Drawing.FontFamily]::Families | ?{ $_.Name -eq "Verdana"}), 4, [System.Drawing.FontStyle]::Regular)), 
            (New-Object system.Drawing.SolidBrush([System.Drawing.Color]::Black)), 30, 340 - ( $i * 50)
        )
        $Image.Canvas.DrawLine($p, 48, (350 - ($i*50)), 52, (350 - ($i*50)))
        $Image.Canvas.DrawLine($p, (50 + ($i*100)), 248, (50 + ($i*100)), 252)
    }
}

function DrawLines {
    param($Image, $Points, $Pen)
    for ($i=1; $i -lt $Points.Count; $i++) {
        $Image.Canvas.DrawLine($Pen, $Points[$i-1], $Points[$i] )
    }
}

$Img = New-Image
Show-Grid -Image $img
$pCos = [System.Drawing.PointF[]] @()
$pSin = [System.Drawing.PointF[]] @()
$pTan = [System.Drawing.PointF[]] @()
(0..359) | %{
    $pCos += Deg2Local -Point (New-Object System.Drawing.PointF( ($_ / 360), [math]::Round([math]::Cos((Deg2Rad -Degrees $_)), 15) ))
    $pSin += Deg2Local -Point (New-Object System.Drawing.PointF( ($_ / 360), [math]::Round([math]::Sin((Deg2Rad -Degrees $_)), 15) ))
    $pTan += Deg2Local -Point (New-Object System.Drawing.PointF( ($_ / 360), [math]::Round([math]::Tan((Deg2Rad -Degrees $_)), 15) ))
}
DrawLines -Image $Img -Points $pCos -Pen (New-Object System.Drawing.Pen( [System.Drawing.Color]::FromArgb( 125, 0, 0, 255) ))
DrawLines -Image $Img -Points $pSin -Pen (New-Object System.Drawing.Pen( [System.Drawing.Color]::FromArgb( 125, 255, 165, 0) ) )
DrawLines -Image $Img -Points $pTan -Pen (New-Object System.Drawing.Pen( [System.Drawing.Color]::FromArgb( 125, 0, 128, 0) ) )
Save-Image -Image $Img -Name "TrigonometryGraphs.jpg"
