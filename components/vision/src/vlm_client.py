#!/usr/bin/env python3
import rospy
from sensor_msgs.msg import Image
from cv_bridge import CvBridge, CvBridgeError
import cv2
from vlm_vision_service.srv import ProcessImage, ProcessImageRequest

class ImageClient:
    def __init__(self):
        rospy.init_node('image_client_node')
        self.service_name = 'vlm_process_image'
        self.image_service = rospy.ServiceProxy(self.service_name, ProcessImage)
        self.bridge = CvBridge()
        self.last_image = None
        # Subscribe to the raw image topic instead of compressed images
        self.subscriber = rospy.Subscriber('usb_cam/image_rect_color', Image, self.image_callback)

    def image_callback(self, data):
        try:
            # Convert the ROS image message to an OpenCV image
            image_np = self.bridge.imgmsg_to_cv2(data, "bgr8")
            self.last_image = self.bridge.cv2_to_imgmsg(image_np, "bgr8")
        except CvBridgeError as e:
            rospy.logerr("Could not convert image: %s" % e)

    def send_image_to_service(self):
        if self.last_image is None:
            rospy.logwarn("No image received yet.")
            return

        try:
            response = self.image_service(self.last_image)
            rospy.loginfo(f"Detected items: {response.detected_items}")
        except rospy.ServiceException as e:
            rospy.logerr("Service call failed: %s" % e)

if __name__ == "__main__":
    ic = ImageClient()
    rospy.sleep(2)  
    ic.send_image_to_service()
