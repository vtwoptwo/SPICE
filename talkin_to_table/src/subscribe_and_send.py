#!/usr/bin/env python3
import rospy
import tf
from geometry_msgs.msg import Pose
from std_msgs.msg import String, Int32
from openai import OpenAI
import socket
import re



client = OpenAI(api_key=rospy.get_param('/api_key'))
current_STEP = 0
def pose_callback(data):
    # Extract quaternion from Pose message
    orientation_q = data.orientation
    quaternion = (
        orientation_q.x,
        orientation_q.y,
        orientation_q.z,
        orientation_q.w
    )

    # Convert quaternion to Euler angles
    euler = tf.transformations.euler_from_quaternion(quaternion)
    
    # Convert Euler angles to degrees and scale by 100
    euler_scaled = [x * 100 for x in euler]
    
    # For simplicity, assume 'rot' is the yaw (third element of euler_scaled)
    rot = euler_scaled[2]
    
    # Determine the step based on 'rot'
    if -300 <= rot < -180:
        show_step = 1
    elif -180 <= rot < -60:
        show_step = 2
    elif -60 <= rot < 60 and rot != 0.0:
        show_step = 3
    elif 60 <= rot < 180:
        show_step = 4
    elif 180 <= rot <= 300:
        show_step = 5
    else:
        show_step = None  # Undefined step for out of range values

    # Publish the step
    if show_step is not None:
        step_pub.publish(show_step)
        print(current_STEP)
        current_STEP = show_step

def message_callback(msg):
    rospy.loginfo("Latest message received: %s", msg.data)
    # Check if 'kitchen' is in the message
    if 'kitchen' in msg.data.lower():
        rospy.loginfo("Message contains 'kitchen', executing GPT-4 query.")
        try:
            data = msg.data  # or some manipulation of msg.data if needed
            rospy.loginfo(f"Current step: {current_STEP}")
            prompt = f"Use logic - currently you are on step {current_STEP} out of 5. The user is asking you for the following: {data}. Follow the users prompt to change the step accordingly. Return an integer number of either 1, 2,3,4 or 5. Only return one integer. "
            response = client.chat.completions.create(
                        model="gpt-4",
                temperature=0,
                seed=42,
                messages=[
                    {
                        "role": "system",
                        "content": "You are a highly skilled AI trained in following instructions. You will be given an instruction and context. Answer as best as you can"
                    },
                    {
                        "role": "user",
                        "content":  prompt
                    }
                ]
            )
            generated_text = response.choices[0].message.content
            rospy.loginfo("Response from GPT-4: %s", generated_text)
            # Create a UDP socket
            # check that the generate
            # Regex pattern to match numbers 1 to 5
            pattern = r'\b[1-5]\b'
            # Search for the pattern in themessage
            match = re.search(pattern, generated_text)


            
            text =  str(match)
            udp_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

            # Send the transcription via UDP to a random port
            port = 1999
            udp_socket.sendto(text.encode(), ('10.205.3.76', port))


        except Exception as e:
            rospy.logerr("Failed to generate response from GPT-4: %s", e)
    else:
        rospy.loginfo("Message does not contain 'kitchen'. No action taken.")
    
    

if __name__ == '__main__':
    rospy.init_node('pose_and_message_processor')

    # Publishers
    step_pub = rospy.Publisher('determined_step', Int32, queue_size=10)

    # Subscribers
    rospy.Subscriber('/optitrack/umh_0/pose', Pose, pose_callback)
    rospy.Subscriber('latest_message', String, message_callback)





    rospy.spin()
