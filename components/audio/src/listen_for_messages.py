#!/usr/bin/env python3
import socket
import rospy
from std_msgs.msg import String

def udp_listener():
    # Initialize ROS node
    rospy.init_node('udp_to_ros_publisher')
    # Create a publisher on the 'latest_message' topic
    pub = rospy.Publisher('latest_message', String, queue_size=10)
    # Set the rate of publishing (optional, depends on your specific needs)
    rate = rospy.Rate(10)  # 10 Hz

    # Set up UDP socket
    udp_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    udp_socket.bind(('', 6968))

    rospy.loginfo("UDP Listener Initialized on port 6969")

    while not rospy.is_shutdown():
        try:
            # Receive messages; 1024 bytes buffer size
            data, addr = udp_socket.recvfrom(1024)
            message = data.decode()
            rospy.loginfo(f"Received message from {addr}: {message}")
            # Publish the message to the ROS topic
            pub.publish(message)
            rate.sleep()
        except KeyboardInterrupt:
            rospy.loginfo("Shutting down UDP listener")
            break
        except Exception as e:
            rospy.logerr(f"An error occurred: {e}")

    udp_socket.close()

if __name__ == '__main__':
    try:
        udp_listener()
    except rospy.ROSInterruptException:
        pass
