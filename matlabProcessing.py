# Data processing

# Import xlrd to read Excel files, xlwt to write Excel files, import numpy for
# mean and standard deviation functions
import xlrd, xlwt, numpy

############################## Create Cell class ##############################
class Cell:
    def __init__(self,peakData,cellNo,experimentNo):
        self.peakData = peakData
        # peakData = [peakNo,time,height,width,relHeight]
        self.numPeaks = len(peakData)
        self.cellNo = cellNo        
        self.experimentNo = experimentNo
        
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
###############################################################################


# Filepath to relevant Excel file
filepath = r'C:\Users\Janty\Downloads\alldata.xls'
book = xlrd.open_workbook(filepath) # Read Excel file
numSheets = book.nsheets # Number of sheets in Excel file

#excelFilename = 'finalData.xls'
#wb = xlwt.Workbook()
#ws = wb.add_sheet('DataSheet')

cellData = [] # Initialize cellData variable as a list
dataStruct = [] # Initialize dataStruct variable as a list
# The cellData variable will store all the peaks for each cell in the
# experiment
for sheetNo in range(0,numSheets): # For each sheet...
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
            newCell = Cell(cellData,cellNo,expNo)
            dataStruct.append(newCell)
            cellData = [] # Reinitialize the cellData variable...
            cellNo += 1
        # Append that row to the list of previously stored rows in cellData
        cellData.append(worksheet.row_values(rowNo))

#for rowNo in range(len(cellData)):
#    for colNo in range(len(cellData[rowNo])):
#        ws.write(rowNo,colNo,cellData[rowNo][colNo])
#        
#wb.save('newExcel.xls')