from flask import Flask, request
from flask_cors import CORS
from PIL import Image
import os
from interpreter import ModelInterpreter
import cv2
import numpy as np

app = Flask(__name__)
CORS(app)
model = os.path.join(os.getcwd(), 'Models/epoch50.tflite')
interpreter = ModelInterpreter(model)


@app.route("/image", methods=['POST'])
def acceptImage():
    file = request.files['image']
    img = Image.open(file.stream)
    #img = Image.open(os.path.join(os.getcwd(), f'processedImages/Machines/{str(Number)}.jpg')).convert('RGB')
    cvImage = cv2.cvtColor(np.array(img), cv2.COLOR_RGB2BGR)
    cvImage = cv2.rotate(cvImage, cv2.ROTATE_90_CLOCKWISE)
    cv2.imwrite(os.path.join(os.getcwd(), 'test2.jpg'), cvImage)
    print(interpreter.RunModel(cvImage)[0][0])
    return str(interpreter.RunModel(cvImage)[0][0])

if __name__ == "__main__":
    app.run(debug=True, host='192.168.1.217')
