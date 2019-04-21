import RPi.GPIO as GPIO
import time
import pyrebase
import l293d as controller
import KEYS

IRsensor = 37


firebase = pyrebase.initialize_app(KEYS.config)
db = firebase.database()

GPIO.setmode(GPIO.BOARD)
GPIO.setup(IRsensor, GPIO.IN)


def isObstacle():
    return GPIO.input(IRsensor)


try:
    leftMotor = controller.DC(15, 13, 11)
    rightMotor = controller.DC(22, 16, 18)

    while True:
        if isObstacle():
            leftMotor.stop()
            rightMotor.stop()

        current = db.child("robot").child("action").get().val()

        if current == 'forward' and not isObstacle():
            leftMotor.anticlockwise(duration=1.5, wait=False)
            rightMotor.anticlockwise(duration=1.5, wait=False)
            db.child("robot").update({"action": "stop"})
        elif current == 'backward':
            leftMotor.clockwise(duration=1.5, wait=False)
            rightMotor.clockwise(duration=1.5, wait=False)
            db.child("robot").update({"action": "stop"})
        elif current == 'left' and not isObstacle():
            rightMotor.anticlockwise(duration=0.75, wait=False)
            leftMotor.clockwise(duration=0.75, wait=False)
            db.child("robot").update({"action": "stop"})
        elif current == 'right' and not isObstacle():
            leftMotor.anticlockwise(duration=0.75, wait=False)
            rightMotor.clockwise(duration=0.75, wait=False)
            db.child("robot").update({"action": "stop"})
        elif current == 'stop':
            leftMotor.stop()
            rightMotor.stop()
        time.sleep(0.5)
except KeyboardInterrupt:
    pass
finally:
    GPIO.cleanup()
