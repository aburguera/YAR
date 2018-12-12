import math
import random

def create_sintable_table():
    allLines="""
; -----------------------------------------------------------------------------
; RCTSINTB CONTAINS THE SINUS OF ANGLES FROM 0 TO 360+90 WITH A RESOLUTION OF
; 360/256 DEGREES, SO THAT RCTSINTB[0]=SIN(0) AND RCTSINTB[256]=SIN(360).
; THE VALUES ARE FORMATED IN FIXED POINT 8.8.
; THE ADDITIONAL 90 DEGREES ALLOW RESUSING THE SAME TABLE TO COMPUTE THE
; COSINUS. THAT IS WHY RCTCOSTB IS DEFINED AS RCTSINTB+90 DEGREES.
; -----------------------------------------------------------------------------\n
"""[1:]
    curLine='RCTSINTB    DC.W    '
    for a in range(256+int(256/4)):
        theValue=int(math.sin(a*math.pi/128)*pow(2,8))
        hexString=format(theValue,'04X')
        if hexString[0]=='-':
            curString='-$'+hexString[1:]+','
        else:
            curString='$'+hexString+','
        if (len(curLine)+len(curString))<80:
            curLine+=curString
        else:
            allLines+=(curLine[:-1]+'\n')
            curLine='            DC.W    '+curString

    allLines+=(curLine[:-1]+'\n\n')+'RCTCOSTB    EQU     RCTSINTB+64*2'
    return allLines

def create_pixelangle_table(screenWidth,distanceToScreen):
    allLines="""
; -----------------------------------------------------------------------------
; RCTPXANG CONTAINS FINE ANGLES EXPRESSED IN 256 BASE FOR EACH SCREEN COLUMN
; FROM 0 TO """+str(screenWidth-1)+""" ASSUMING A DISTANCE TO SCREEN OF """+str(distanceToScreen)+"""
; THAT IS RCTPXANG[20]=ATAN((20-"""+str(screenWidth)+"""/2)/"""+str(distanceToScreen)+""") AND THIS ANGLE IS EXPRESSED AS A
; VALUE BETWEEN 0 AND 255 SO THAT 0 DENOTES 0 DEG, 128 DENOTES 180 DEG, ...
; IN OTHER WORDS, IT TELLS THE ANGLE AT WHICH EACH SCREEN COLUMN IS LOCATED
; WITH RESPECT TO THE PLAYER POINT OF VIEW.
; -----------------------------------------------------------------------------\n
"""[1:]
    curLine='RCTPXANG    DC.W    '
    for x in range(screenWidth):
        xLocal=x-screenWidth/2
        curAngle=math.atan2(xLocal,distanceToScreen)
        hexString=format(int(curAngle*8.0*128.0/math.pi),'04X')
        if hexString[0]=='-':
            curString='-$'+hexString[1:]+','
        else:
            curString='$'+hexString+','
        if (len(curLine)+len(curString))<80:
            curLine+=curString
        else:
            allLines+=(curLine[:-1]+'\n')
            curLine='            DC.W    '+curString
    allLines+=(curLine[:-1]+'\n')
    return allLines


def create_finetangent_table():
    allLines="""
; -----------------------------------------------------------------------------
; RCTFNTAN CONTAINS THE TANGENTS OF ANGLES FROM 0 TO 90 IN FIXED POINT 8.8
; WITH A RESOLUTION OF A 1/2048 OF DEGREE. FOR EXAMPLE, POSITION 100 CONTAINS
; THE TANGENT OF 360*(100/2048)=17.6 DEGREES. VALUES LARGER THAN 255 HAVE BEEN
; CHANGED TO 255. THIS ONLY HAPPENS FOR THE LAST ORIENTATION.
; -----------------------------------------------------------------------------\n
"""[1:]
    curLine='RCTFNTAN    DC.W    '
    for a in range(int(8*256/4)):
        curAngle=((a+0.5)/8.0)*math.pi/128
        curTan=int(math.tan(curAngle)*math.pow(2,8))
        if curTan>0xFFFF:
            curTan=0xFFFF
        hexString=format(curTan,'04X')
        if hexString[0]>='8':
            curString='$7'+hexString[1:]+','
        else:
            curString='$'+hexString+','
        if (len(curLine)+len(curString))<80:
            curLine+=curString
        else:
            allLines+=(curLine[:-1]+'\n')
            curLine='            DC.W    '+curString

    allLines+=(curLine[:-1]+'\n')
    return allLines

def create_stars(screenHeight,numStars,maxSize):
    allLines="""
; -----------------------------------------------------------------------------
; RCTSTAR CONTAINS RANDOMLY GENERATED DATA TO PLOT BACKGROUND STARS. FOR EACH
; STAR THERE IS A WORD STATING INITIAL X, A WORD STATING Y AND A WORD STATING
; SIZE. X COORDINATES ARE FROM 0 TO 1023 TO EASE THE MODULUS OPERATION IN THE
; DRAWING SUBROUTINE.
; -----------------------------------------------------------------------------\n
"""[1:]
    curLine='RCTSTAR     DC.W    '
    for i in range(numStars):
        curSize=random.randint(1,maxSize)
        xCoord=random.randint(0,1023)
        yCoord=random.randint(0,(screenHeight/2)-1-curSize)
        curString='$'+format(xCoord,'04X')+','
        if (len(curLine)+len(curString))<80:
            curLine+=curString
        else:
            allLines+=(curLine[:-1]+'\n')
            curLine='            DC.W    '+curString
        curString='$'+format(yCoord,'04X')+','
        if (len(curLine)+len(curString))<80:
            curLine+=curString
        else:
            allLines+=(curLine[:-1]+'\n')
            curLine='            DC.W    '+curString
        curString='$'+format(curSize,'04X')+','
        if (len(curLine)+len(curString))<80:
            curLine+=curString
        else:
            allLines+=(curLine[:-1]+'\n')
            curLine='            DC.W    '+curString
    allLines+=(curLine[:-1]+'\n')
    return allLines

def create_data(fileName,screenWidth,distanceToScreen):
    RCTsintbLines=create_sintable_table()
    RCTpxangLines=create_pixelangle_table(screenWidth,distanceToScreen)
    RCTfntanLines=create_finetangent_table()
    RCTstarLines=create_stars(480,50,4)

    with open(fileName,'w') as outFile:
        outFile.writelines(RCTsintbLines+'\n')
        outFile.writelines(RCTpxangLines+'\n')
        outFile.writelines(RCTfntanLines+'\n')
        outFile.writelines(RCTstarLines)

create_data('../DATA/RCTDATA.X68',640,350)