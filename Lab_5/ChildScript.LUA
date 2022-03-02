
function wait(seconds)
    local start = os.time()
    repeat until os.time() > start + seconds
end


-- DEFINE
tresh_red = 0.39
tresh_green = 0.28
tresh_blue = 0.61
tresh_black = 0.09

-- We may try to lower it, but it requires testing
stop_mode_ticks = 50


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

proximity_sensor_result = 0

-- Movemet mode variables
forward_mode = 1
backward_mode = 0

-- Variables connceted with avoiding obstackles.
-- Mode currently doesn't work
avoid_obstackle_mode = 0       -- 1 -> turn left  | 2 -> go forward | 3 -> turn right 
avoid_obstackle_counter = 0

-- Color mode variables
 colorMode = 2          -- 1 - black | 2 - white
 whichColorToStop = 1   -- 0 - black | 1 - red | 2 - green | 3 - blue
 
-- Stop mode and time variables 
 stopTime = 1           -- how many seconds to wait()
 stopFlag = 0           -- gives a signal to enter stop mode  
 stopUntillTime = -1    -- wheather stop mode is active or not

 stop_mode_debouncing_counter = 50

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

 leftV = speed
 rightV = speed


    floorSensorHandles = {-1,-1,-1}
    sensorReading={false, false, false}

    floorSensorHandles[1] = sim.getObjectHandle("leftSensor")
    floorSensorHandles[2] = sim.getObjectHandle("middleSensor")
    floorSensorHandles[3] = sim.getObjectHandle("rightSensor")


end
if (sim_call_type==sim.syscb_actuation) then

    --result=sim.readProximitySensor(noseSensor)
    --if (result>0) then backUntilTime=sim.getSimulationTime()+4 end

    sensorReading={false, false, false}

    rightV = speed
    leftV = speed
    
        

    if stopFlag == 0 then
        for i=1,3,1 do
            vision_result,data = sim.readVisionSensor(floorSensorHandles[i])
            if(vision_result>=0) then
                if data[11] > .90 then
                    sensorReading[i] = true
                elseif whichColorToStop == 1 and i == 2 and data[11] > tresh_red - 0.06 and data[11] < tresh_red + 0.06 and stop_mode_debouncing_counter >= stop_mode_ticks then 
                    stopFlag = 1
                    stopUntillTime = sim.getSimulationTime() + 1
                    stop_mode_debouncing_counter = 0
                
                elseif whichColorToStop == 2 and i == 2 and data[11] > tresh_green - 0.06 and data[11] < tresh_green + 0.06 and stop_mode_debouncing_counter >= stop_mode_ticks then 
                    stopFlag = 1
                    stopUntillTime = sim.getSimulationTime() + 1
                    stop_mode_debouncing_counter = 0
                elseif whichColorToStop == 3 and i == 2 and data[11] > tresh_blue - 0.06 and data[11] < tresh_blue + 0.06 and stop_mode_debouncing_counter >= stop_mode_ticks then 
                    stopFlag = 1
                    stopUntillTime = sim.getSimulationTime() + 1
                    stop_mode_debouncing_counter = 0
                elseif i == 2 and data[11] > tresh_black - 0.06 and data[11] < tresh_black + 0.06 and stop_mode_debouncing_counter >= stop_mode_ticks then 
                    stopFlag = 1
                    stopUntillTime = sim.getSimulationTime() + 1
                    stop_mode_debouncing_counter = 0
           
           
                end
           end
        end       
    end
    

    -- take action based on sensorRiding

    if stopFlag == 0 then
        rightV = speed
        leftV = speed
        
        if sensorReading[1] then
            leftV = 0.2*speed
            rightV = 1.8*speed
        end 
        if sensorReading[3] then
            rightV = 0.2*speed
            leftV = 1.8*speed
        end    
    end

    

    -- if same color seen on left and right sensor
    if sensorReading[1] and sensorReading[3] and data[11] > 0.90 then
            backUntilTime=sim.getSimulationTime()+2
    end

    
    stop_mode_debouncing_counter = stop_mode_debouncing_counter + 1
    if stop_mode_debouncing_counter > 100000 then
        stop_mode_debouncing_counter = stop_mode_ticks
    end

 proximity_sensor_result=sim.readProximitySensor(noseSensor) -- Read the proximity sensor

    if proximity_sensor_result > 0 then   
        avoid_obstackle_mode = 1
        avoid_obstackle_counter = 0
        forward_mode = 0
    end


 
 



-- Avoiding obstackles
-- Mode currently doesn't work
    if avoid_obstackle_mode > 0 then
        
        avoid_obstackle_couter = avoid_obstackle_counter + 1
        if avoid_obstackle_mode == 1 then
                
            if avoid_obstackle_counter<= 10 then
                sim.setJointTargetVelocity(leftMotor,0)
                sim.setJointTargetVelocity(rightMotor,speed)
            else
                avoid_obstackle_mode = 2
            end
        elseif avoid_obstackle_mode == 2 then
            if avoid_obstackle_counter >= 10 and avoid_obstackle_counter <= 50 then
                --forward_mode = 1
                sim.setJointTargetVelocity(leftMotor,speed)
                sim.setJointTargetVelocity(rightMotor,speed)
            else
                forward_mode = 0
                avoid_obstackle_mode = 3
            end
        elseif avoid_obstackle_mode == 3 then
            if avoid_obstackle_counter <= 60 then
                sim.setJointTargetVelocity(leftMotor,speed)
                sim.setJointTargetVelocity(rightMotor,0)
            
            end
        else
                avoid_obstackle_counter = 0
                avoid_obstackle_mode = 0
        
        end
            
    end

    -- Driving forward
    if forward_mode == 1 and stopFlag == 0 then
        -- When in forward mode, we simply move forward at the desired speed
            sim.setJointTargetVelocity(leftMotor,leftV)
            sim.setJointTargetVelocity(rightMotor,rightV)
    end

    -- Stop mode
    if (stopUntillTime < sim.getSimulationTime()) then
            stopFlag = 0
        else
        -- When in stop mode, both engines are off
            sim.setJointTargetVelocity(leftMotor,0)
            sim.setJointTargetVelocity(rightMotor,0)
    end

    -- Backward mode 
    if (backUntilTime>sim.getSimulationTime()) then
     
        -- When in backward mode, we simply backup in a curve at reduced speed
            if (stopFlag == 0) then
                sim.setJointTargetVelocity(leftMotor,-speed/2)
                sim.setJointTargetVelocity(rightMotor,-speed/8)
            end
    end

end

if (sim_call_type==sim.syscb_cleanup) then
 simUI.destroy(ui)
end