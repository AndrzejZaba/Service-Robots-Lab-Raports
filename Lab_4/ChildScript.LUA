function wait(seconds)
    local start = os.time()
    repeat until os.time() > start + seconds
end


function speedChange_callback(ui,id,newVal)
 speed=minMaxSpeed[1]+(minMaxSpeed[2]-minMaxSpeed[1])*newVal/100
end
if (sim_call_type==sim.syscb_init) then 
 -- This is executed exactly once, the first time this script is executed
 bubbleRobBase=sim.getObjectAssociatedWithScript(sim.handle_self) -- this is bubbleRob's handle
 leftMotor=sim.getObjectHandle("bubbleRob_leftMotor") -- Handle of the left motor
 rightMotor=sim.getObjectHandle("bubbleRob_rightMotor") -- Handle of the right motor
 noseSensor=sim.getObjectHandle("bubbleRob_sensingNose") -- Handle of the proximity sensor
 minMaxSpeed={50*math.pi/180,300*math.pi/180} -- Min and max speeds for each motor
 backUntilTime=-1 -- Tells whether bubbleRob is in forward or backward mode

 colorMode = 2      -- 1 - black | 2 - white
 -- Create the custom UI:
 xml = '<ui title="'..sim.getObjectName(bubbleRobBase)..' speed" closeable="false" resizeable="false" activate="false">'..[[
 <hslider minimum="0" maximum="100" onchange="speedChange_callback"
 id="1"/>
 <label text="" style="* {margin-left: 300px;}"/>
 </ui>
 ]]


 ui=simUI.create(xml)
 speed=(minMaxSpeed[1]+minMaxSpeed[2])*0.5
 simUI.setSliderValue(ui,1,100*(speed-minMaxSpeed[1])/(minMaxSpeed[2]-minMaxSpeed[1]))


    floorSensorHandles = {-1,-1,-1}
    sensorReading={false, false, false}

    floorSensorHandles[1] = sim.getObjectHandle("leftSensor")
    floorSensorHandles[2] = sim.getObjectHandle("middleSensor")
    floorSensorHandles[3] = sim.getObjectHandle("rightSensor")


end
if (sim_call_type==sim.syscb_actuation) then


    sensorReading={false, false, false}

    
        


    for i=1,3,1 do
        result,data = sim.readVisionSensor(floorSensorHandles[i])
        if(result>=0) then
            if colorMode == 1 then
                if data[11] <= 0.33 then-- data[11] - average intense / intensity
                    sensorReading[i] = true
                end
            else
                if data[11] > 0.90 then --and data[11] < 0.69 then-- data[11] - average intense / intensity
                    sensorReading[i] = true
                end
                if i == 2 and data[11] > 0.4 and data[11] <0.6 then 
                    wait(2)
                end
                    
            end
        end
    end

    -- take action based on sensorRiding
    rightV = speed
    leftV = speed
    
    if sensorReading[1] then
        leftV = 0.03*speed
        rightV = 1.7*speed
    end 
    if sensorReading[3] then
        rightV = 0.03*speed
        leftV = 1.7*speed
    end

    if sensorReading[1] and sensorReading[3] then
        backUntilTime=sim.getSimulationTime()+2
    end


 
 result=sim.readProximitySensor(noseSensor) -- Read the proximity sensor
 -- If we detected something, we set the backward mode:
 if (result>0) then backUntilTime=sim.getSimulationTime()+2 end 
 if (backUntilTime<sim.getSimulationTime()) then
 -- When in forward mode, we simply move forward at the desired speed
 sim.setJointTargetVelocity(leftMotor,leftV)
 sim.setJointTargetVelocity(rightMotor,rightV)
 else
 -- When in backward mode, we simply backup in a curve at reduced speed
 sim.setJointTargetVelocity(leftMotor,-speed/2)
 sim.setJointTargetVelocity(rightMotor,-speed/8)
 end
end
if (sim_call_type==sim.syscb_cleanup) then
 simUI.destroy(ui)
end