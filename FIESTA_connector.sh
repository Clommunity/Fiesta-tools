#!/bin/bash

FILEBASE=$1

counter=0

while [[ $counter -lt 200 ]]
do
	echo "Filebase=$FILEBASE and counter=$counter"
	FILENAME=$FILEBASE$counter
	echo "Filename=$FILENAME"	
	((counter++))


RET=$(curl --request POST --header "Content-Type: application/json" --header "X-OpenAM-Username: <REPLACE>"  --header "X-OpenAM-Password: <REPLACE>" --data "{}"  https://platform.fiesta-iot.eu/openam/json/authenticate)

RETF=$(echo $RET | sed 's/"/ /g')

TOKEN=$(echo $RETF |awk '{print $4}')

REQUEST=$(curl -v -X POST \
-o output.txt  \
  https://platform.fiesta-iot.eu/iot-registry/api/queries/execute/global \
  -H 'accept: application/json' \
  -H 'cache-control: no-cache' \
  -H 'content-type: text/plain' \
  -H 'iplanetdirectorypro: '${TOKEN}'' \
  -d 'Prefix ssn: <http://purl.oclc.org/NET/ssnx/ssn#> 
Prefix iotlite: <http://purl.oclc.org/NET/UNIS/fiware/iot-lite#> 
Prefix dul: <http://www.loa.istc.cnr.it/ontologies/DUL.owl#> 
Prefix geo: <http://www.w3.org/2003/01/geo/wgs84_pos#>
Prefix time: <http://www.w3.org/2006/time#>
PREFIX rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
Prefix m3-lite: <http://purl.org/iot/vocab/m3-lite#>
Prefix xsd: <http://www.w3.org/2001/XMLSchema#>
select ?sensorID (max(?ti) as ?time) ?value ?latitude ?longitude ?qk
where { 
    ?o a ssn:Observation.
    ?o ssn:observedBy ?sensorID.   
    ?o ssn:observedProperty ?qkr.
    ?qkr rdf:type ?qk.
    VALUES ?sensorID {<https://platform.fiesta-iot.eu/iot-registry/api/resources/rYxCOnciK95QeD4iHkAXqqnJ_ncz6Za7B17luPvEoQJaIYEbFnaPRe7g6-EXkkKrEf7wi6q977lhNS4zUeudKnrXvRAsFxFKwNncaVMI57TvLq0N1IdG-q0QW4keLKmkINnhsUFsS8yqOpw-evIOgQ==>}.
    ?o ssn:observationSamplingTime ?t. 
    ?o geo:location ?point. 
    ?point geo:lat ?latitude. 
    ?point geo:long ?longitude. 
    ?t time:inXSDDateTime ?ti. 
    ?o ssn:observationResult ?or. 
    ?or  ssn:hasValue ?v. 
    ?v dul:hasDataValue ?value. 
    {
        select  (max(?dt)as ?ti) ?sensorID
        where {
            ?o a ssn:Observation.
            ?o ssn:observedBy ?sensorID.
            ?o ssn:observedProperty ?qkr.
            ?qkr rdf:type ?qk .
            VALUES ?sensorID {<https://platform.fiesta-iot.eu/iot-registry/api/resources/rYxCOnciK95QeD4iHkAXqqnJ_ncz6Za7B17luPvEoQJaIYEbFnaPRe7g6-EXkkKrEf7wi6q977lhNS4zUeudKnrXvRAsFxFKwNncaVMI57TvLq0N1IdG-q0QW4keLKmkINnhsUFsS8yqOpw-evIOgQ==>}.
            ?o ssn:observationSamplingTime ?t. 
            ?t time:inXSDDateTime ?dt. 
        }group by (?sensorID) 
    }
    FILTER ( 
       (xsd:double(?latitude) >= "-90"^^xsd:double) 
    && (xsd:double(?latitude) <= "90"^^xsd:double) 
    && ( xsd:double(?longitude) >= "-180"^^xsd:double)  
    && ( xsd:double(?longitude) <= "180"^^xsd:double)
    )  
} group by ?sensorID ?time ?value ?latitude ?longitude ?qk 
LIMIT 1')


VAL=$(grep -F 'value" :' output.txt | sed 's/E1/ /g'| sed 's/"/ /g' | awk '{print $3}')

VAL=$(echo $VAL*10 | bc)

mosquitto_pub -t "Fiesta" -m "$VAL"

#python mqtt_publisher.py


cp output.txt $FILENAME

REQUESTLOGOUT=$(curl --verbose --request POST --header "iplanetDirectoryPro: ${TOKEN}"  https://platform.fiesta-iot.eu/openam/json/sessions/?_action=logout)

sleep 10m

done

echo "finished all"

