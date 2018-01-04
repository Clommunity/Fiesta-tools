#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright (c) 2010-2013 Roger Light <roger@atchoo.org>
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Distribution License v1.0
# which accompanies this distribution.
#
# The Eclipse Distribution License is available at
#   http://www.eclipse.org/org/documents/edl-v10.php.
#
# Contributors:
#    Roger Light - initial implementation
# Copyright (c) 2010,2011 Roger Light <roger@atchoo.org>
# All rights reserved.

# This shows a simple example of an MQTT subscriber.

import paho.mqtt.client as mqtt
import paho.mqtt.subscribe as subscribe
import urllib2
import time
import logging
import os
import datetime
import pickle
import requests


THINGSPEAKKEY='xxx'
#THINGSPEAKURL='http://localhost:3000'
THINGSPEAKURL='https://api.thingspeak.com/update'


def sendThingspeak(url,key,field1,field2,temp1,temp2):
  if url=='' or key=='':
    return
  # Send event to internet site
  payload = {'key' : key,'field1' : temp1,'field2' : temp2}
  print("payload iss",payload)
  try:
    r = requests.post(url,data=payload,timeout=5)
    if r.status_code==200:
      print("Sent data to Thingspeak success")
    else:    
      print("Error 1 sending data to Thingspeak (status code:"+str(r.status_code)+")")  
  except:
    print("Error sending data to Thingspeak")


def print_msg(client, userdata, message):
    print("%s : %s" % (message.topic, message.payload))

def on_connect(mqttc, obj, flags, rc):
    print("rc: " + str(rc))

def multiply(a,b,c):
    c=a*b
    print("multiply is ", c) 

def on_message(mqttc, obj, msg):
    print(msg.topic + " Msg is " + str(msg.payload))
    #sendThingspeak(THINGSPEAKURL,THINGSPEAKKEY,'field1',temp1,msg)
    sendThingspeak(THINGSPEAKURL,THINGSPEAKKEY,'field1','field2',temp1,temp2)


def on_publish(mqttc, obj, mid):
    print("mid: " + str(mid))


def on_subscribe(mqttc, obj, mid, granted_qos):
    print("Subscribed: " + str(mid) + " " + str(granted_qos))


def on_log(mqttc, obj, level, string):
    print(string)


# If you want to use a specific client id, use
# mqttc = mqtt.Client("client-id")
# but note that the client id must be unique on the broker. Leaving the client
# id parameter empty will generate a random id for you.
mqttc = mqtt.Client()
mqttc.on_message = on_message
mqttc.on_connect = on_connect
mqttc.on_publish = on_publish
mqttc.on_subscribe = on_subscribe
# Uncomment to enable debug messages
# mqttc.on_log = on_log
#mqttc.connect("localhost", 1883, 60)
mqttc.connect("10.139.40.204", 1883, 60)
mqttc.subscribe('Fiesta/#', 0)

#sendThingspeak(THINGSPEAKURL,THINGSPEAKKEY,'field1','field2',temp1,temp2)

mqttc.loop_forever()
