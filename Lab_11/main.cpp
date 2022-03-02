#include "ros/ros.h"
#include "std_msgs/Float64.h"
#include "geometry_msgs/Twist.h"

#include <iostream>
#include <cstdlib>
#include <ctime>

#define MIN_VAL -10.0
#define MAX_VAL 10.0


// Function generating random float number
float get_random_num(float min, float max){
	srand((unsigned int)time(NULL));
	return (float(rand()) / float((RAND_MAX)) * 2*max) + min;
}
int main(int argc, char **argv) {
	ros::init(argc, argv, "vrep_motor_controller_node");
	ros::NodeHandle node_handle("~");
	std::cout << "Hello world x" << std::endl;
	ros::Rate loop_rate(2);
	
	// Publisher object declaration
	ros::Publisher pub = node_handle.advertise<geometry_msgs::Twist>("/turtle1/cmd_vel" , 1 );
	
	// Data to be published
	geometry_msgs::Twist vel_msg;
	float divide_by = get_random_num(-2.0, 5.0);
	
	// main loop
	while (ros::ok() ) {
		ros::spinOnce();
		
		// Generating new random values to being published
		vel_msg.linear.x = get_random_num(MIN_VAL,MAX_VAL) /1.77;
		vel_msg.angular.z = get_random_num(MIN_VAL, MAX_VAL) / divide_by;
		
		// Publishing velocity message (Twist type)
		pub.publish(vel_msg);
		
		std::cout << "Linear x: "<< vel_msg.linear.x << std::endl;
		std::cout << "Angular z: "<< vel_msg.angular.z << std::endl;
		
		loop_rate.sleep();
		divide_by = get_random_num(-2.0, 5.0);
	}
}

