# Data processing

# Import xlrd to read Excel files, xlwt to write Excel files, import numpy for
# mean and standard deviation functions
import xlrd, xlwt, numpy

############################## Create Cell class ##############################
class Cell:
    def __init__(self,peakData,cellNo,experimentNo,groupNo,date):
        self.peakData = peakData
        # peakData = [peakNo,time,height,width,relHeight]
        self.cellNo = cellNo        
        self.experimentNo = experimentNo
        self.groupNo = groupNo
        self.date = date
        
        heightTreatment = []
        widthTreatment = []
        relheightTreatment = []
        heightSpontaneous = []
        widthSpontaneous = []
        relheightSpontaneous = []
        heightIonomycin = []
        widthIonomycin = []
        relheightIonomycin = []
        for peakNo in range(len(peakData)):
            time = peakData[peakNo][1] # peak time in seconds
            if time < 510 and time >= 60:
                # Peaks that occur between 60 and 510 seconds are caused by the
                # group-specific treatment. These are the peaks of interest.
                heightTreatment.append(peakData[peakNo][2])
                widthTreatment.append(peakData[peakNo][3])
                relheightTreatment.append(peakData[peakNo][4])
            elif time < 60:
                # Peaks that occur before 60 seconds are spontaneous and due to
                # indeterminate causes
                heightSpontaneous.append(peakData[peakNo][2])
                widthSpontaneous.append(peakData[peakNo][3])
                relheightSpontaneous.append(peakData[peakNo][4])
            elif time > 555:
                # Peaks that occur after 555 seconds are caused by the addition
                # of ionomycin. If such peaks occur, the cell is considered
                # to be capable of calcium signaling regardless of the response
                # to the group-specific treatment
                heightIonomycin.append(peakData[peakNo][2])
                widthIonomycin.append(peakData[peakNo][3])
                relheightIonomycin.append(peakData[peakNo][4])
        self.heightTreatment = heightTreatment
        self.widthTreatment = widthTreatment
        self.relheightTreatment = relheightTreatment
        self.avgHeight = numpy.mean(heightTreatment)
        self.stdHeight = numpy.std(heightTreatment)
        self.avgWidth = numpy.mean(widthTreatment)
        self.stdWidth = numpy.std(widthTreatment)
        self.avgRelheight = numpy.mean(relheightTreatment)
        self.stdRelheight = numpy.std(relheightTreatment)
        if not heightIonomycin:
            self.responsive = False
        else:
            self.responsive = True
        if not heightSpontaneous:
            self.spontaneous = False
        else:
            self.spontaneous = True
        if not heightTreatment:
            self.effectiveTreatment = False
        else:
            self.effectiveTreatment = True
        self.numPeaks = len(heightTreatment)
        if groupNo == 1:
            self.treatment = 'Hypotonic Stress'
        elif groupNo == 2:
            self.treatment = 'GSK205 TRPV4 Inhibition'
        elif groupNo == 3:
            self.treatment = 'GSK101 TRPV4 Activation'
        elif groupNo == 4:
            self.treatment = 'PMA PKC Activation'
        elif groupNo == 5:
            self.treatment = 'PMA PKC Activation + GSK205 TRPV Inhibition'
        elif groupNo == 6:
            self.treatment = 'm-3M3FBS PLC Activation + Thapsigargin Ca2+ Store Depletion'
        elif groupNo == 7:
            self.treatment = 'm-3M3FBS PLC Activation + Calphostin C PKC Inhibition'
        elif groupNo == 8:
            self.treatment = 'm-3M3FBS PLC Activation + Thapsigargin Ca2+ Store Depletion + Calphostin C PKC Inhibition'
        elif groupNo == 9:
            self.treatment = 'm-3M3FBS PLC Activation + Thapsigargin Ca2+ Store Depletion + GSK205 TRPV4 Inhibition'
        elif groupNo == 10:
            self.treatment = 'm-3M3FBS PLC Activation + GSK205 TRPV4 Inhibition'
        elif groupNo == 11:
            self.treatment = 'm-3M3FBS PLC Activation + Xestospongin C IP3R Inibition'
        elif groupNo == 12:
            self.treatment = 'm-3M3FBS PLC Activation + Xestospongin C IP3R Inhibition + Calphostin C PKC Inhibition'
        elif groupNo == 13:
            self.treatment = 'm-3M3FBS PLC Activation + Xestospongin C IP3R Inhibition + GSK205 TRPV4 Inhibition'
        elif groupNo == 14:
            self.treatment = 'Epinephrine'
        elif groupNo == 15:
            self.treatment = 'Norepinephrine'
        elif groupNo == 16:
            self.treatment = 'HBSS Control'
        elif groupNo == 17:
            self.treatment = 'DMSO Control'
        elif groupNo == 18:
            self.treatment = 'Epinephrine + Xestospongin C IP3R Inhibition + GSK205 TRPV4 Inhibition'
###############################################################################

# Filepath to relevant Excel file
filepath = r'C:\Users\Janty\Downloads\alldata.xls'
book = xlrd.open_workbook(filepath) # Read Excel file
numSheets = book.nsheets # Number of sheets in Excel file

cellData = [] # Initialize cellData variable as a list
allCells = [] # Initialize allCells variable as a list
# The cellData variable will store all the peaks for each cell in the
# experiment
for sheetNo in range(numSheets): # For each sheet...
    expNo = sheetNo + 1
    cellNo = 1
    worksheet = book.sheet_by_index(sheetNo) # Read the sheet...
    numRows = worksheet.nrows # And determine the number of rows in that sheet
    for rowNo in range(1,numRows): # For each row in that sheet...
        # If the value of the first column in that row equals 1...
        if worksheet.row(rowNo)[0].value == 1:
        # Each row's header: Peak Number, Time (s), Height, Width, Rel. Height
        # The first column stores values for peak number, so if the peak number
        # equals 1, that indicates the first peak for another cell
            if expNo in (1,2,3,4,5,6,7,57):
                groupNo = 1
                date = '2015-01-23'
            elif expNo in (8,9,10,11):
                groupNo = 3
                date = '2015-01-23'
            elif expNo in (33,34):
                groupNo = 3
                date = '2015-02-11'
            elif expNo in (12,13):
                groupNo = 10
                date = '2015-02-01'
            elif expNo in (14,15,16,17):
                groupNo = 10
                date = '2015-02-04'
            elif expNo == 55:
                groupNo = 10
                date = '2015-02-16'
            elif expNo in (18,19,20):
                groupNo = 9
                date = '2015-02-04'
            elif expNo in (28,29):
                groupNo = 9
                date = '2015-02-11'
            elif expNo == 58:
                groupNo = 9
                date = '2015-02-21'
            elif expNo in (21,22,23,24):
                groupNo = 6
                date = '2015-02-04'
            elif expNo == 30:
                groupNo = 6
                date = '2015-02-11'
            elif expNo in (25,26,27):
                groupNo = 4
                date = '2015-02-04'
            elif expNo in (31,32):
                groupNo = 4
                date = '2015-02-11'
            elif expNo == 56:
                groupNo = 4
                date = '2015-02-21'
            elif expNo in (35,36,37,38,39):
                groupNo = 2
                date = '2015-02-11'
            elif expNo in (40,41,42,43,44):
                groupNo = 5
                date = '2015-02-16'
            elif expNo == 91:
                groupNo = 5
                date = '2015-03-26'
            elif expNo in (45,46,47,48,49):
                groupNo = 7
                date = '2015-02-16'
            elif expNo == 105:
                groupNo = 7
                date = '2015-04-15'
            elif expNo in (50,51,52,53,54):
                groupNo = 8
                date = '2015-02-16'
            elif expNo == 59:
                groupNo = 11
                date = '2015-02-21'
            elif expNo == 80:
                groupNo = 11
                date = '2015-03-11'
            elif expNo in (81,82,83):
                groupNo = 11
                date = '2015-03-25'
            elif expNo == 92:
                groupNo = 11
                date = '2015-03-26'
            elif expNo in (60,61):
                groupNo = 16
                date = '2015-02-21'
            elif expNo in (62,63):
                groupNo = 16
                date = '2015-02-22'
            elif expNo == 69:
                groupNo = 16
                date = '2015-02-22'
            elif expNo in (64,65,66,67,68):
                groupNo = 17
                date = '2015-02-22'
            elif expNo in (70,71,72,73):
                groupNo = 14     
                date = '2015-02-24'
            elif expNo in (74,):
                groupNo = 14
                date = '2015-03-11'
            elif expNo in (93,94,95,96):
                groupNo = 14
                date = '2015-03-26'
            elif expNo in (75,76,77,78,79):
                groupNo = 15
                date = '2015-03-11'
            elif expNo in (84,85):
                groupNo = 12
                date = '2015-03-25'
            elif expNo in (102,103,104):
                groupNo = 12
                date = '2015-04-15'
            elif expNo in (86,87):
                groupNo = 13
                date = '2015-03-25'
            elif expNo in (88,89,90):
                groupNo = 13
                date = '2015-03-26'
            elif expNo in (97,98,99,100,101):
                groupNo = 18
                date = '2015-04-15'
            allCells.append(Cell(cellData,cellNo,expNo,groupNo,date))
            cellData = [] # Reinitialize the cellData variable...
            cellNo += 1
        # Append that row to the list of previously stored rows in cellData
        cellData.append(worksheet.row_values(rowNo))

########################### Create Experiment class ###########################
class Experiment:
    def __init__(self,groupNo,numCells,avgHeight,stdHeight,avgWidth,stdWidth,
                 avgRelheight,stdRelheight):
        self.groupNo = groupNo
        self.numCells = numCells
        self.avgHeight = avgHeight
        self.stdHeight = stdHeight
        self.avgWidth = avgWidth
        self.stdWidth = stdWidth
        self.avgRelheight = avgRelheight
        self.stdRelheight = stdRelheight
        if groupNo == 1:
            self.treatment = 'Hypotonic Stress'
        elif groupNo == 2:
            self.treatment = 'GSK205 TRPV4 Inhibition'
        elif groupNo == 3:
            self.treatment = 'GSK101 TRPV4 Activation'
        elif groupNo == 4:
            self.treatment = 'PMA PKC Activation'
        elif groupNo == 5:
            self.treatment = 'PMA PKC Activation + GSK205 TRPV Inhibition'
        elif groupNo == 6:
            self.treatment = 'm-3M3FBS PLC Activation + Thapsigargin Ca2+ Store Depletion'
        elif groupNo == 7:
            self.treatment = 'm-3M3FBS PLC Activation + Calphostin C PKC Inhibition'
        elif groupNo == 8:
            self.treatment = 'm-3M3FBS PLC Activation + Thapsigargin Ca2+ Store Depletion + Calphostin C PKC Inhibition'
        elif groupNo == 9:
            self.treatment = 'm-3M3FBS PLC Activation + Thapsigargin Ca2+ Store Depletion + GSK205 TRPV4 Inhibition'
        elif groupNo == 10:
            self.treatment = 'm-3M3FBS PLC Activation + GSK205 TRPV4 Inhibition'
        elif groupNo == 11:
            self.treatment = 'm-3M3FBS PLC Activation + Xestospongin C IP3R Inibition'
        elif groupNo == 12:
            self.treatment = 'm-3M3FBS PLC Activation + Xestospongin C IP3R Inhibition + Calphostin C PKC Inhibition'
        elif groupNo == 13:
            self.treatment = 'm-3M3FBS PLC Activation + Xestospongin C IP3R Inhibition + GSK205 TRPV4 Inhibition'
        elif groupNo == 14:
            self.treatment = 'Epinephrine'
        elif groupNo == 15:
            self.treatment = 'Norepinephrine'
        elif groupNo == 16:
            self.treatment = 'HBSS Control'
        elif groupNo == 17:
            self.treatment = 'DMSO Control'
        elif groupNo == 18:
            self.treatment = 'Epinephrine + Xestospongin C IP3R Inhibition + GSK205 TRPV4 Inhibition'
###############################################################################

heightALLnew = []
widthALLnew = []
relheightALLnew = []
allExperiments = []
for group in range(1,19):
    heightALL = [Cell.heightTreatment for Cell in allCells if Cell.groupNo == group]
    for item in range(len(heightALL)):
        heightALLnew = heightALLnew + heightALL[item]
    avgHeight = numpy.mean(heightALLnew)
    stdHeight = numpy.std(heightALLnew)    
    
    widthALL = [Cell.widthTreatment for Cell in allCells if Cell.groupNo == group]
    for item in range(len(widthALL)):
        widthALLnew = widthALLnew + widthALL[item]
    avgWidth = numpy.mean(widthALLnew)        
    stdWidth = numpy.std(widthALLnew)
        
    relheightALL = [Cell.relheightTreatment for Cell in allCells if Cell.groupNo == group]
    for item in range(len(relheightALL)):
        relheightALLnew = relheightALLnew + relheightALL[item]
    avgRelheight = numpy.mean(relheightALLnew)
    stdRelheight = numpy.std(relheightALLnew)
    
    allExperiments.append(Experiment(group,len(heightALL),avgHeight,stdHeight,avgWidth,stdWidth,avgRelheight,stdRelheight))

# Write data to Excel file finalData.xls
excelFilename = 'finalData.xls'
wb = xlwt.Workbook()
ws1 = wb.add_sheet('CellData')
ws1.write(0,0,'Cell No')
ws1.write(0,1,'Exp No')
ws1.write(0,2,'Group No')
ws1.write(0,3,'Date')
ws1.write(0,4,'Num Peaks')
ws1.write(0,5,'Avg Height')
ws1.write(0,6,'Std Height')
ws1.write(0,7,'Avg Width')
ws1.write(0,8,'Std Width')
ws1.write(0,9,'Avg RelHeight')
ws1.write(0,10,'Std RelHeight')
ws1.write(0,11,'Respond to Ionomycin?')
ws1.write(0,12,'Spontaneous Signaling?')
ws1.write(0,13,'Respond to Treatment?')
ws1.write(0,14,'Treatment')
rowWrite = 1
for group in range(1,19):
    cellsInGroup = [Cell for Cell in allCells if Cell.groupNo == group]
    for cell in range(len(cellsInGroup)):
        if cellsInGroup[cell].cellNo > 0:
            if cellsInGroup[cell].experimentNo != cellsInGroup[cell-1].experimentNo:
                cellNumber = 1
            else:
                cellNumber += 1
        else:
            cellNo = 1
        ws1.write(rowWrite,0,cellNumber)
        ws1.write(rowWrite,1,cellsInGroup[cell].experimentNo)
        ws1.write(rowWrite,2,cellsInGroup[cell].groupNo)
        ws1.write(rowWrite,3,cellsInGroup[cell].date)
        ws1.write(rowWrite,4,cellsInGroup[cell].numPeaks)
        ws1.write(rowWrite,5,cellsInGroup[cell].avgHeight)
        ws1.write(rowWrite,6,cellsInGroup[cell].stdHeight)
        ws1.write(rowWrite,7,cellsInGroup[cell].avgWidth)
        ws1.write(rowWrite,8,cellsInGroup[cell].stdWidth)
        ws1.write(rowWrite,9,cellsInGroup[cell].avgRelheight)
        ws1.write(rowWrite,10,cellsInGroup[cell].stdRelheight)
        ws1.write(rowWrite,11,cellsInGroup[cell].responsive)
        ws1.write(rowWrite,12,cellsInGroup[cell].spontaneous)
        ws1.write(rowWrite,13,cellsInGroup[cell].effectiveTreatment)
        ws1.write(rowWrite,14,cellsInGroup[cell].treatment)
        rowWrite += 1
    
ws2 = wb.add_sheet('ExpData')
ws2.write(0,0,'Group No')
ws2.write(0,1,'Avg Height')
ws2.write(0,2,'Std Height')
ws2.write(0,3,'Avg Width')
ws2.write(0,4,'Std Width')
ws2.write(0,5,'Avg RelHeight')
ws2.write(0,6,'Std RelHeight')
ws2.write(0,7,'Num Cells')
ws2.write(0,8,'Treatment')
for group in range(len(allExperiments)):
    ws2.write(group+1,0,group+1)
    ws2.write(group+1,1,allExperiments[group].avgHeight)
    ws2.write(group+1,2,allExperiments[group].stdHeight)
    ws2.write(group+1,3,allExperiments[group].avgWidth)
    ws2.write(group+1,4,allExperiments[group].stdWidth)
    ws2.write(group+1,5,allExperiments[group].avgRelheight)
    ws2.write(group+1,6,allExperiments[group].stdRelheight)
    ws2.write(group+1,7,allExperiments[group].numCells)
    ws2.write(group+1,8,allExperiments[group].treatment)

wb.save(excelFilename)