def is_blurry(img, threshold=100):
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    lap_var = cv2.Laplacian(gray, cv2.CV_64F).var()
    return lap_var < threshold

def has_glare(img, threshold=240, max_white_ratio=0.05):
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    bright = np.sum(gray > threshold)
    total = gray.size
    white_ratio = bright / total
    return white_ratio > max_white_ratio

def check_quality(img):
    return (not is_blurry(img)) and (not has_glare(img))