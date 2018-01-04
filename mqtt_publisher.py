#!/usr/bin/python
import paho.mqtt.client as mqtt
import json

# Define Variables
MQTT_HOST = "10.139.40.204"
MQTT_PORT = 1883
MQTT_KEEPALIVE_INTERVAL = 45
MQTT_TOPIC = "Fiesta"

with open('output.txt') as json_file:  
    payload = json.load(json_file)
    for p in payload['items']:
        print('Value: ' + p['value'])

MQTT_MSG=json.dumps(payload)

def on_publish(client, userdata, mid):
    print("Message Published...")

def on_connect(client, userdata, flags, rc):
    client.subscribe(MQTT_TOPIC)
    client.publish(MQTT_TOPIC, MQTT_MSG)

def on_message(client, userdata, msg):
    print(msg.topic)
    print(msg.payload) 
    payload = json.loads(msg.payload) 
    client.disconnect() 

# Initiate MQTT Client
mqttc = mqtt.Client()

# Register publish callback function
mqttc.on_publish = on_publish
mqttc.on_connect = on_connect
mqttc.on_message = on_message

# Connect with MQTT Broker
mqttc.connect(MQTT_HOST, MQTT_PORT, MQTT_KEEPALIVE_INTERVAL)

# Loop forever
mqttc.loop_forever()
