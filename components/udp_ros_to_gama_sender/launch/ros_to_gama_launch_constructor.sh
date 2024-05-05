#!/bin/bash
# Get the script's directory and then set LAUNCH_FILE relative to this directory
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
LAUNCH_FILE="$SCRIPT_DIR/../launch/objects_ros.launch"

args=$(getopt -l "number:base_id:ip:port:rate" -o "n:b:i:p:r:h" -- "$@")

eval set -- "$args"

while [ $# -ge 1 ]; do
    case "$1" in
        --)
            # No more options left.
            shift
            break
            ;;
        -n|--number_of_markers)
            number="$2"
            shift
            ;;
        -b|--base_id)
            base_id="$2"
            shift
            ;;
        -i|--ip)
            ip="$2"
            shift
            ;;
        -p|--port)
            base_port="$2"
            shift
            ;;
        -r|--rate)
            rate="$2"
            shift
            ;;
        -h)
            echo "Display some help"
            exit 0
            ;;
    esac
    shift
done

echo "<launch>" > $LAUNCH_FILE
namespace="optitrack"
echo -e "\t<group ns=\"$namespace\">" >> $LAUNCH_FILE
for ((i=$base_id; i<$((base_id+number)); i++)); do
    current_agent_port=$((base_port+i))
    echo -e "\t\t<node pkg=\"udp_ros_to_gama_sender\" type=\"udp_ros_to_gama_sender.py\" name=\"udp_ros_to_gama_sender_$i\" output=\"screen\">"
    echo -e "\t\t\t<param name=\"host\" value=\"$ip\" />"
    echo -e "\t\t\t<param name=\"port\" value=\"$current_agent_port\" />"
    echo -e "\t\t\t<param name=\"body\" value=\"umh_$i\" />"
    echo -e "\t\t</node>"
done >> $LAUNCH_FILE

echo -e "\t</group>" >> $LAUNCH_FILE
echo -e "</launch>" >> $LAUNCH_FILE

roslaunch $LAUNCH_FILE

