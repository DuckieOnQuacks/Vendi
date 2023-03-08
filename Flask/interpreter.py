import tensorflow as tf
import os
import cv2
import numpy as np

# Class to make things easier for the flask connection
class ModelInterpreter:
    def __init__(self, modelPath):
        self.interpreter = tf.lite.Interpreter(modelPath)
        self.interpreter.allocate_tensors()

    # Resizes and converts the image, so it can be handled by the interpreter
    def __ConvertImage(self, img):

        img = cv2.resize(img, (224, 224), interpolation=cv2.INTER_AREA)

        convImg = np.array(img, dtype=np.float32)
        # Add batch dimension
        validImg = np.expand_dims(convImg, axis=0)
        return validImg

    # Run the prediction on the image given
    def RunModel(self, img):
        cv2.imwrite(os.path.join(os.getcwd(), 'test.jpg'), img)
        data = self.__ConvertImage(img)
        input_tensors = self.interpreter.get_input_details()
        output_tensors = self.interpreter.get_output_details()

        self.interpreter.set_tensor(input_tensors[0]['index'], data)

        self.interpreter.invoke()

        output_tensors = self.interpreter.get_tensor(output_tensors[0]['index'])
        return output_tensors


#model = os.path.join(os.getcwd(), 'Models/epoch50.tflite')
#testImageMachinePath = os.path.join(os.getcwd(), 'processedImages/Machines/48.jpg')
#testImageNotMachinePath = os.path.join(os.getcwd(), 'processedImages/Not Machines/300.jpg')
#testImageMachine = cv2.imread(testImageMachinePath, cv2.IMREAD_UNCHANGED)
#testImageNotMachine = cv2.imread(testImageNotMachinePath, cv2.IMREAD_UNCHANGED)
#interpreter = ModelInterpreter(model)
#interpreter.RunModel(testImageMachine)
#interpreter.RunModel(testImageNotMachine)[0][0]
