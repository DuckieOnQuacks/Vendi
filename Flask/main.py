import tensorflow as tf
from keras.applications.mobilenet import MobileNet
from keras.utils.image_dataset import image_dataset_from_directory

# Global variables
imgSize = (224,224)
batchSize = 32

# Declaring the base model that will be edited
baseModel = MobileNet(
    input_shape=(224, 224, 3),
    alpha=1.0,
    depth_multiplier=1,
    dropout=0.001,
    include_top=False,
    weights='imagenet',
    input_tensor=None,
    pooling=None,
    classes=2,
    classifier_activation='softmax'
)

# Create a training and validation dataset from vending machine images
datasetDir = "F:\Capstone\Tensorflow\processedImages"
testDir = "F:\Capstone\Tensorflow\Test\Post"
train = image_dataset_from_directory(
    directory=datasetDir,
    validation_split=0.1,
    subset="training",
    labels='inferred',
    seed=123,
    image_size=imgSize,
    batch_size=batchSize
)
val = image_dataset_from_directory(
    directory=datasetDir,
    validation_split=0.1,
    subset="validation",
    labels='inferred',
    seed=123,
    image_size=imgSize,
    batch_size=batchSize
)

# Test just so I can get a better idea of model accuracy
test = image_dataset_from_directory(
    directory=testDir,
    validation_split=None,
    subset=None,
    labels='inferred',
    seed=123,
    image_size=imgSize,
    batch_size=batchSize
)



# Initialize the new model instance
globalAverageLayer = tf.keras.layers.GlobalAveragePooling2D()
predictionLayer = tf.keras.layers.Dense(1, activation='sigmoid')
baseModel.trainable = False
model = tf.keras.Sequential([
    baseModel,
    globalAverageLayer,
    predictionLayer,
])

# Setup variables and model config
baseLearningRate = 0.0001
model.compile(optimizer=tf.keras.optimizers.RMSprop(learning_rate=baseLearningRate),
              loss=tf.keras.losses.BinaryCrossentropy(from_logits=True),
              metrics=['accuracy'])

# Train the model
epoch = 1
fittedModel = model.fit(train, validation_data=val, epochs=epoch)

# Test the model
pred = model.evaluate(test, return_dict=True)
print(pred)

# Save the model
model.save('F:\Capstone\Tensorflow\Models\epochTest'+str(epoch))

# Convert to tflite and save the tflite file
converter = tf.lite.TFLiteConverter.from_keras_model(model)
liteModel = converter.convert()

with open('F:\Capstone\Tensorflow\Models\epoch' + str(epoch) + '.tflite', 'wb') as f:
    f.write(liteModel)
