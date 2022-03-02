%% Start connection
vrep=remApi('remoteApi');
vrep.simxFinish(-1);

clientID = vrep.simxStart('127.0.0.1',19999,true,true,5000,5);

%% Main program

% vision sensor
[returnCode, sensorHandle]=vrep.simxGetObjectHandle(clientID,'Vision_sensor' ,vrep.simx_opmode_blocking)
[returnCode, resolution, image] = vrep.simxGetVisionSensorImage2(clientID, sensorHandle,0,vrep.simx_opmode_streaming)

% left_Motor
[returnCode, left_Motor] = vrep.simxGetObjectHandle(clientID,'bubbleRob_leftMotor',vrep.simx_opmode_blocking);
[returnCode, right_Motor] = vrep.simxGetObjectHandle(clientID,'bubbleRob_rightMotor',vrep.simx_opmode_blocking);


[returnCode] = vrep.simxSetJointTargetVelocity(clientID,left_Motor,2,vrep.simx_opmode_blocking);
[returnCode] = vrep.simxSetJointTargetVelocity(clientID,right_Motor,2,vrep.simx_opmode_blocking);


% sensing_Nose
[returnCode, front_sensor] = vrep.simxGetObjectHandle(clientID,'bubbleRob_sensingNose', vrep.simx_opmode_blocking);

[returnCode, detectionState, detectedPoint,~,~] = vrep.simxReadProximitySensor(clientID, front_sensor, vrep.simx_opmode_streaming)
for i=1:50
    [returnCode, detectionState, detectedPoint,~,~] = vrep.simxReadProximitySensor(clientID, front_sensor, vrep.simx_opmode_buffer)
    imshow(image);
    [returnCode, resolution, image] = vrep.simxGetVisionSensorImage2(clientID,sensorHandle,0,vrep.simx_opmode_buffer)
    pause(0.001)
end

[returnCode] = vrep.simxSetJointTargetVelocity(clientID,left_Motor,0,vrep.simx_opmode_blocking);
[returnCode] = vrep.simxSetJointTargetVelocity(clientID,right_Motor,0,vrep.simx_opmode_blocking);
%% Close connection
vrep.simxGetPingTime(clientID);

% Now close the connection to V-REP
vrep.simxFinish(clientID);
vrep.delete(); % call the destructor

