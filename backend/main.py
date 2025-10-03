from fastapi import FastAPI, File, UploadFile
import cv2
import numpy as np
from utils import check_quality

app = FastAPI()

@app.post("/check_id_quality")
async def check_id_quality(file: UploadFile = File(...)):
    # Read image as numpy array
    contents = await file.read()
    np_arr = np.frombuffer(contents, np.uint8)
    img = cv2.imdecode(np_arr, cv2.IMREAD_COLOR)

    good = check_quality(img)

    return {"good": good}