import os
import cv2
import shutil
import glob

# Load images from an input folder directory into a list
def LoadImages(dir):
    objects = []
    for file in glob.glob(os.path.join(dir, '*.jpg')):
        img = cv2.imread(file, cv2.IMREAD_UNCHANGED)
        objects.append(img)
    return objects

# Resizes the images in the input list
def ResizeImages(objects, dir):
    count = 0
    for thing in objects:
        thing = cv2.resize(thing, (224, 224), interpolation = cv2.INTER_AREA)
        cv2.imwrite(os.path.join(dir + '/' + str(count) + '.jpg'), thing)
        count += 1


# Get the directories we'll be working in
processedDir = os.path.join(os.getcwd(), 'processedImages')
testDir = os.path.join(os.getcwd(), 'Test/Post')

machineDir = os.path.join(os.getcwd(), 'Images/Machines')
notMachineDir = os.path.join(os.getcwd(), 'Images/Not Machines')
pMachineDir = os.path.join(os.getcwd(), 'processedImages/Machines')
pNotMachineDir = os.path.join(os.getcwd(), 'processedImages/Not Machines')
tPreMachineDir = os.path.join(os.getcwd(), 'Test/Pre/Machines')
tPreNotMachineDir = os.path.join(os.getcwd(), 'Test/Pre/Not Machines')
tPostMachineDir = os.path.join(os.getcwd(), 'Test/Post/Machines')
tPostNotMachineDir = os.path.join(os.getcwd(), 'Test/Post/Not Machines')

# Recursively remove all files in these directories, so they can be built from scratch (if they exist)
if os.path.exists(processedDir):
    shutil.rmtree(processedDir)
if os.path.exists(testDir):
    shutil.rmtree(testDir)

# Make the directories
os.mkdir(processedDir)
os.mkdir(pMachineDir)
os.mkdir(pNotMachineDir)

os.mkdir(testDir)
os.mkdir(tPostMachineDir)
os.mkdir(tPostNotMachineDir)

# Make Empty Lists
machines = []
notMachines = []

# Load all the images
machines = LoadImages(machineDir)
notMachines = LoadImages(notMachineDir)
machinesTest = LoadImages(tPreMachineDir)
notMachinesTest = LoadImages(tPreNotMachineDir)

# Process images then write them to a file
ResizeImages(machines, pMachineDir)
ResizeImages(notMachines, pNotMachineDir)
ResizeImages(machinesTest, tPostMachineDir)
ResizeImages(notMachinesTest, tPostNotMachineDir)

