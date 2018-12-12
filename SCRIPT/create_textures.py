import sys
import os
from PIL import Image

def create_texture(fileName,txNum):
    allLines=''
    theTag='.TEX'+format(txNum,'02d')
    curLine=theTag+'      DC.L    '
    theImage=Image.open(fileName).convert('RGB')
    if theImage.size[0]!=256:
        sys.exit('[ERROR] TEXTURE FILES MUST HAVE 256 COLUMNS.')
    for y in range(theImage.size[0]):
        r,g,b=theImage.getpixel((y,0))
        curValue=int(b)<<16|int(g)<<8|int(r)
        curString='$'+format(curValue,'08X')+','
        if (len(curLine)+len(curString))<80:
            curLine+=curString
        else:
            allLines+=(curLine[:-1]+'\n')
            curLine='            DC.L    '+curString
    allLines+=(curLine[:-1]+'\n')
    return allLines

def create_textures(fileList,outPath):
    allLines="""
; -----------------------------------------------------------------------------
; TEXDATA CONTAINS A LIST OF TEXTURE DATA. EACH TEXTURE IS A SET OF 256 COLORS
; CORRESPONDING TO COLUMNS. ALL ROWS WILL BE DRAWN WITH THE SAME COLORS. USING
; FULL FLEDGED TEXTURES WOULD REQUIRE TOO MANY EASY68K TRAP #15 CALLS, SO THIS
; SIMPLIFIED TEXTURES ARE USED INSTEAD.
; -----------------------------------------------------------------------------\n
"""[1:]
    curLine='TEXDATA     DC.L    '
    for txNum in range(len(fileList)):
        curString='.TEX'+format(txNum,'02d')+','
        if (len(curLine)+len(curString))<80:
            curLine+=curString
        else:
            allLines+=(curLine[:-1]+'\n')
            curLine='            DC.L    '+curString
    allLines+=(curLine[:-1]+'\n')
    for txNum in range(len(fileList)):
        allLines+=create_texture(fileList[txNum],txNum)

    outFName=os.path.join(outPath,'TEXDATA.X68')
    with open(outFName,'w') as outFile:
        outFile.writelines(allLines)

create_textures(['../RES/TEXT1.PNG','../RES/TEXT2.PNG','../RES/TEXT3.PNG'],'../DATA/')