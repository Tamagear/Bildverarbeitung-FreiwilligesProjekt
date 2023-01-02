import cv2
import numpy as np


def hough_circle_detection(coins, min_r, max_r):
    # turn original image to grayscale
    gray = cv2.cvtColor(coins, cv2.COLOR_BGR2GRAY)
    # blur grayscale image
    blurred = cv2.medianBlur(gray, 5)
    return cv2.HoughCircles(
        blurred,  # source image (blurred and grayscaled)
        cv2.HOUGH_GRADIENT,  # type of detection
        1,  # inverse ratio of accumulator res. to image res.
        40,  # minimum distance between the centers of circles
        param1=50,  # Gradient value passed to edge detection
        param2=30,  # accumulator threshold for the circle centers
        minRadius=min_r*2,  # min circle radius
        maxRadius=max_r*2,  # max circle radius
    )


img = cv2.imread('content/muenzenVerdeckung.jpg', cv2.IMREAD_COLOR)

gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

gray_blurred = cv2.blur(gray, (3, 3))

detected_circles = hough_circle_detection(img, 80, 300)
if detected_circles is not None:

    # Convert the circle parameters a, b and r to integers.
    detected_circles = np.uint16(np.around(detected_circles))

    for pt in detected_circles[0, :]:
        a, b, r = pt[0], pt[1], pt[2]

        # Draw the circumference of the circle.
        cv2.circle(img, (a, b), r, (0, 255, 0), 2)

        # Draw a small circle (of radius 1) to show the center.
        cv2.circle(img, (a, b), 1, (0, 0, 255), 3)
        cv2.imshow("Detected Circle", img)
        cv2.waitKey(0)

