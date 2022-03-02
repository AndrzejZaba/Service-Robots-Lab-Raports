-- if you wish to execute code contained in an external file instead,
-- use the require-directive, e.g.:
--
-- require 'myExternalFile'
--
-- Above will look for <V-REP executable path>/myExternalFile.lua or
-- <V-REP executable path>/lua/myExternalFile.lua
-- (the file can be opened in this editor with the popup menu over
-- the file name)

function sysCall_threadmain()
   
 -- Put some initialization code here
    
    -- motor assignment
    left_motor=sim.getObjectHandle("bubbleRob_leftMotor") -- Handle of the left motor
    right_motor=sim.getObjectHandle("bubbleRob_rightMotor") -- Handle of the right motor

    -- path assignment 
    robot_handle = sim.getObjectHandle('bubbleRob')
    path_handle = sim.getObjectHandle('Path_route')

    position_on_path = 0    -- determines to which point on the path robot should go
    distance = 0    -- distance form the robot to the point on the path

    start_dummy_handle = sim.getObjectHandle('Start')


    -- Valocity calculations
    v_desired = 0.1
    om_desired = 0.1
    d = 0.2     -- wheels separation
    r_w = 0.04  -- wheel radius

    v_r = (v_desired + d*om_desired)
    v_l = (v_desired - d*om_desired)

    omega_right = v_r / r_w
    omega_left = v_l / r_w

    


-- End of initialization code


-- While(1) loop
while sim.getSimulationState()~=sim.simulation_advancing_abouttostop do
    
    -- set speed on both motors
    sim.setJointTargetVelocity(right_motor, omega_right)
    sim.setJointTargetVelocity(left_motor, omega_left)

    -- set current robot position
    robot_position = sim.getObjectPosition(robot_handle, -1)

    -- position of point on the path robot is going to
    path_position = sim.getPositionOnPath(path_handle, position_on_path)

    sim.setObjectPosition(start_dummy_handle,-1, path_position)

    m = sim.getObjectMatrix(robot_handle, -1)
    m = simGetInvertedMatrix(m)     -- try this if doesn't work:     sim.invertMatrix


    path_position = sim.multiplyVector(m,path_position) 

    -- distance from robot to target point
    distance = math.sqrt( (path_position[1])^2 + (path_position[2])^2)    --path_position[1] -> x coord   [2] -> y coord 

    -- angle between robot heading and the path piont
    phi_angle = math.atan2(path_position[2], path_position[1])


    if position_on_path<1 then
        v_desired = 0.18
        om_desired = 1.85 * phi_angle
        
    else
        v_desired = 0
        om_desired = 0
        sim.setJointTargetVelocity(right_motor, 0)
        sim.setJointTargetVelocity(left_motor, 0)
    end

    
    v_r = (v_desired + d*om_desired)
    v_l = (v_desired - d*om_desired)

    omega_right = v_r / r_w
    omega_left = v_l / r_w

    -- points on the path are numbered from 0 to 1.  So when distance from one point is 
    -- really small -> we add 0.01 to the position_on_path untill position on path 
    -- would be equall the value of next point on the path
   
    if(distance<0.1) then   
        if(position_on_path<1) then
            position_on_path=position_on_path+0.01     
        end
    end

    sim.wait(0.025, true)


end -- end while loop


    -- Put your main loop here, e.g.:
    --
    -- while sim.getSimulationState()~=sim.simulation_advancing_abouttostop do
    --     local p=sim.getObjectPosition(objHandle,-1)
    --     p[1]=p[1]+0.001
    --     sim.setObjectPosition(objHandle,-1,p)
    --     sim.switchThread() -- resume in next simulation step
    -- end


end -- end SysCall function (main())

function sysCall_cleanup()
    -- Put some clean-up code here
end


-- ADDITIONAL DETAILS:
-- -------------------------------------------------------------------------
-- If you wish to synchronize a threaded loop with each simulation pass,
-- enable the explicit thread switching with 
--
-- sim.setThreadAutomaticSwitch(false)
--
-- then use
--
-- sim.switchThread()
--
-- When you want to resume execution in next simulation step (i.e. at t=t+dt)
--
-- sim.switchThread() can also be used normally, in order to not waste too much
-- computation time in a given simulation step
-- -------------------------------------------------------------------------