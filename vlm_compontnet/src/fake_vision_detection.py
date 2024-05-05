#!/usr/bin/env python3
import rospy
from sensor_msgs.msg import Image
from std_msgs.msg import String
from vlm_vision_service.srv import ProcessImage, ProcessImageResponse
import cv2
from cv_bridge import CvBridge, CvBridgeError
import base64
import requests
import json
import re
import ast
from typing import List
import os
from openai import OpenAI
import socket
import time

client = OpenAI(api_key=rospy.get_param('/api_key'))




step1 = [
    "1,Dice 145g of avocadoes and put them in the bowl.; Once in the bowl smash the avocadoes to your liking.,avocado,0,6.0,Guacamole",
    "2,Dice 30g of the tomato into tiny cubes.; Put them in the bowl.,tomato,0,3.5,Guacamole",
    "3,Dice 10g of the onion.; Put them in the bowl.,onion,0,3.0,Guacamole",
    "4,Squeeze 1/4th of the lemon into the bowl.,lemon,1,0.0,Guacamole",
    "5,Mix the ingredients in the bowl well until it is at the consistency you prefer.,avocado;tomato;onion;lemon,1,0.0,Guacamole",
]

def udp_server_for_ingredients(host='10.205.3.76', port=4242, message: str = None):
    i = 0
    for step in step1:
        # random = input("just a natural pause to control it")
        with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as s:
            s.sendto(str(step).encode(), (host, 4242 + i))
            send_message = f"Message sent: {step}"
            print(f"Message sent: {step}")
            i += 1
            print("Sent to port ", 4242 + i)
            time.sleep(2)

def instruction_response(prompt):
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
    return response.choices[0].message.content

def make_api_call_to_clean_res(detected_items) -> List:
    try:
        prompt = f"The following food items were detected on the table. : {detected_items}\n\n Write only the food items in a list as follows: ['item1', 'item2', 'item3', 'item4']"
        response = instruction_response(prompt)
        print(prompt)
        print("Actual response from cleaning:", response)
    except Exception as e:
        print(e)
   
    reg_list = re.findall(r'\[.*?\]', response)
    if reg_list:
        # check that the word tomato, onion lemon is in the req_list[0], 
         # Keywords to check in the first element of req_list
        keywords = ['tomato', 'onion', 'lemon', 'avocado']


        
        if all(keyword in reg_list[0].lower() for keyword in keywords):
            
            return reg_list[0]
        else:
            print("Going for failsafe option")
            return "['lemon','onion','tomato','avocado']"
    else:
        return "['lemon','onion','tomato','avocado']"


def is_last_step(item ,items: list):
    
    if item == items[-1]:
        return 1
    return 0


def send_detected_food_items(items: list):
    i=0
    for item in items:
        message = f"{item},✌️,{is_last_step(item, items)}"
        with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as s:
            s.sendto(message.encode(), ('10.205.3.76', 666 + i))
            print(f"Message sent: {message}")
            print("Sent to port ", 666 + i)
            i += 1
    return True

def image_to_base64(image):
                                                                                                
    _, buffer = cv2.imencode('.jpg', image)
    
    return base64.b64encode(buffer).decode('utf-8')

def process_image(request):
   
    try:
        bridge = CvBridge()
        cv_image = bridge.imgmsg_to_cv2(request.image, "bgr8")
    except CvBridgeError as e:
        print(e)
    image_data = image_to_base64(cv_image)
    gpt_vision_response = make_api_call_gpt_vision(image_data)
    print(gpt_vision_response)
    res = make_api_call_to_clean_res(gpt_vision_response)
    print(res)
    detected_items = ast.literal_eval(res)
    send_detected_food_items(detected_items)
    time.sleep(5)
    udp_server_for_ingredients()
    time.sleep(1)
    
    # create a publisher that publishes a topic with the food results 
    rospy.set_param('/detected_items', detected_items)

    return ProcessImageResponse(detected_items=detected_items)

def make_api_call_gpt_vision(base64_image):
        
    try:
        response = client.chat.completions.create(
            model="gpt-4-vision-preview",
            temperature=0,
            seed=42,
            messages= [
                {
                    "role": "user",
                    "content": [
                        {
                            "type": "text",
                            "text": "Describe any food items you see in this image."
                        },
                        {
                            "type": "image_url",
                            "image_url": {
                                "url": f"data:image/jpeg;base64,{base64_image}"
                            }
                        }
                    ]
                }
            ],
        )
        print(base64_image)
        return response.choices[0].message.content
    
    except Exception as e:
        print("API call to GPT Vision failed:")
        print(e)
        
        
def vision_service():
    rospy.init_node('vision_service_node')
    s = rospy.Service('vlm_process_image', ProcessImage, process_image)
    pub = rospy.Publisher('detected_items_topic', String, queue_size=10)
    rospy.spin()

if __name__ == "__main__":
    vision_service()

