#!/bin/bash
java -Dlogback.configurationFile=$PROCESS_SIP_HOME/cfg/logback.xml -Dconfig.file=$PROCESS_SIP_HOME/cfg/application.conf -jar $PROCESS_SIP_HOME/bin/process-sip.jar $@
