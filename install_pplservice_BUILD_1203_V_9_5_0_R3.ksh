#!/bin/ksh
#---------------------------------------------------------------------------------------
# Name          : /tmp/v606995/pplservice/install_pplservice_BUILD_1203_V_9_5_0_R3.ksh
# Created       : Wed Sep 20 14:41:37 EDT 2017
# Author        : Syntel, Inc.
# Purpose       : Install pplservice BUILD_1203_V_9_5_0_R3
#---------------------------------------------------------------------------------------

#-----------------------------------------
# FUNCTION: do_initialize
#-----------------------------------------
do_initialize()
{
	export APP=pplservice
	export DEBUG=0
	export ENV=UAT
	export BUILD=1203
	export VERSION=9.5
	export MAJ_VER=9
	export MIN_VER=5
	export SUB_VER=
	export SUB_VER2=
	export BRANCH=3
	export DPS_OPTION=
	export SVN_EXPORT_DIR=/tmp/v606995/pplservice

	export BUILD_NAME=BUILD_1203_V_9_5_0_R3
	export BUILD_FILE=pplservice_BUILD_1203_V_9_5_0_R3.zip
	export ROLLBACK_BUILD=

	export NEW_FOLDER=""

	export db_pkg_install=0

	# If running in test mode, set the app owner & group
	if (( 0 ))
	then
		export app_owner=ppluat
		export app_group=ppluatgrp
	fi


#----------------------------------------------------------------
# Environment File used for PPLService
# CANNOT BE USED STANDALONE
#----------------------------------------------------------------

        # PPL Import Application Directories
        export APP=pplservice
        export aline="******************************************************************************************"
        export aline_star="******************************************************************************************"

	if (( ${DEBUG} ))
	then
		export APP_HOME=/tmp/${LOGNAME}/local/apps/${APP}
		export app_owner=${LOGNAME}
		#export app_group=$(id | awk '{print $2}' | cut -d'(' -f2 | cut -d')' -f1)
		export DIST_LIST="LFerrazzi@statestreet.com"
	else
		export APP_HOME=/local/apps/${APP}
		export DIST_LIST="TradeServices@ifs.statestreet.com,TmanDev@ifs.statestreet.com,Dev-Rel-Automation@statestreet.com"
	fi

	export DIST_DIR=${APP_HOME}/dist
	export DEPLOY_DIR=${APP_HOME}/deploy
	export LOG_DIR=${APP_HOME}/logs

	export APP_STARTUP_MSG_PROD="40 PplService Message Listeners have been started"
	export APP_STARTUP_MSG_UAT="40 PplService Thread Listeners started for build"
	export APP_SHUTDOWN_MSG="pplservice.PplServiceMain - Shutdown was successful"

	if (( ! ${DEBUG} )) 
	then
		export APP_PROGRAM_FILE=${DEPLOY_DIR}/bin/${APP}.jar
	else
		export APP_PROGRAM_FILE=${HOME}/demo.ksh
	fi

	case ${ENV} in
		UAT)
				if (( ! ${DEBUG} ))
				then
					export APP_HOST=svanyc711.imsi.com
					export stop_job=uxsox412_PPLSERVICE_STOP_AVON
					export start_job=uxsox412_PPLSERVICE_START_AVON
					export app_owner=ppluat
					export app_group=ppluatgrp
				else
					export APP_HOST=svanyc804.imsi.com
					# export stop_job=tradebatch3_uxzzz999_sleep
					export stop_job=pplservice_uxzzz999_sleep
					export start_job=pplservice_uxzzz999_sleep
				fi

				export AUTOSERV=UA1
				export AUTOSYS_ENV_FILE=/opt/CA/WorkloadAutomationAE/autouser.UA1/autosys.ksh.svany711
				##export AUTOSYS_ENV_FILE=/opt/CA/WorkloadAutomationAE/autouser.UA1/autosys.ksh.`hostname`
				export APP_LOG_FILE=${LOG_DIR}/pplservice.log

				;;
	
		PROD)
				if (( ! ${DEBUG} ))
				then
					export APP_HOST=pplprod.imsi.com
					export stop_job=uxsox412_PPLSERVICE_STOP_PROD
					export start_job=uxsox412_PPLSERVICE_START_PROD
					export app_owner=ifsppl
					export app_group=pplgrp
				else
					export APP_HOST=svanyc804.imsi.com
					# export stop_job=tradebatch3_uxzzz999_sleep
					export stop_job=pplservice_uxzzz999_sleep
					export start_job=pplservice_uxzzz999_sleep
				fi

				export AUTOSERV=PR1
				export AUTOSYS_ENV_FILE=/opt/CA/WorkloadAutomationAE/autouser.PR1/autosys.ksh.`hostname`
				export APP_LOG_FILE=${LOG_DIR}/pplservice.log
				;;

			*)	echo -e "\a\a\aUnknown Environment.  Must define UAT or PRODCUTION\n\n"
				exit 1
				;;
	esac

	# This is the ID the IBM Folks have to be when they perform the installation
    	# This can be root or $app_owner.  Verify against the AIS Instruction Doc
    	export INSTALL_USER=${app_owner}

	# Add some sleep variables
	if (( ${DEBUG} ))
	then
		export SLEEP5=1
		export SLEEP10=1
		export SLEEP15=1
		export SLEEP20=1
		export SLEEP25=1
		export SLEEP30=1
		export SLEEP60=1
	else
		export SLEEP5=5
		export SLEEP10=10
		export SLEEP15=15
		export SLEEP20=20
		export SLEEP25=25
		export SLEEP30=30
		export SLEEP60=60
	fi

	# Build File used to verify the correct build is installed
	export BuildConfirmationFile=${DEPLOY_DIR}/bin/BUILD

	# Construct the build name based parameters exported from install.sh
	# Build number is always required
	export this_build=BUILD_${BUILD}
	if [[ ! -z ${MAJ_VER} ]]
	then
		this_build=${this_build}_V_${MAJ_VER}
		svn_version_path=V_${MAJ_VER}
	else
		# If no major version number, default the svn path to just the buid number
		svn_version_path=${BUILD}
	fi
	if [[ ! -z ${MIN_VER} ]]
	then
		this_build=${this_build}_${MIN_VER}
		svn_version_path=${svn_version_path}_${MIN_VER}
	fi
        if [[ ! -z ${SUB_VER} ]]
        then
                this_build=${this_build}_${SUB_VER}
                svn_version_path=${svn_version_path}_${SUB_VER}
        fi
	if [[ ! -z ${SUB_VER2} ]]
	then
		this_build=${this_build}_${SUB_VER2}
		svn_version_path=${svn_version_path}_${SUB_VER2}
	fi
	if [[ ! -z ${BRANCH} ]]
	then
		this_build=${this_build}_R${BRANCH}
	fi

	# If BUILD_NAME is null, define it using $this_build
	# Otherwise, it was defined on the command line using the -n option
	if [[ -z ${BUILD_NAME} ]]
	then
		export BUILD_NAME=${this_build}
	fi

	export BUILD_FILE=${APP}_${BUILD_NAME}.zip

	export SVN_TRUNK="https://ifssvn:8443/svn/TradeServices/trunk/PplService"
	export SVN_SOURCE=${SVN_TRUNK}/${svn_version_path}/${BUILD_FILE}

	export INSTALL_SCRIPT=${SVN_EXPORT_DIR}/install_${APP}_${BUILD_NAME}.ksh
	export DRIVER_SCRIPT=${SVN_EXPORT_DIR}/RUNME

	# If JIL files are used, use this variable to perform the insert. Empty if no JIL files
	export JIL_FILES=""

	export temp1=/tmp/temp1.$$.tmp
	export temp2=/tmp/temp2.$$.tmp
	export temp3=/tmp/temp3.$$.tmp
	export date_time=$(date +%Y%m%d_%H%M)
	export date_only=$(date +%Y%m%d)

	# Define Autosys Environment
	export autosys_client=0
	if [[ -s ${AUTOSYS_ENV_FILE} ]]
	then
		. ${AUTOSYS_ENV_FILE}
		export autosys_client=1
	fi
}

#-----------------------------------------
# FUNCTION: ais_send_email
# LFF 6/17/2017 Set DL for Demo mode to
#               email only that user
#-----------------------------------------
ais_send_email ()
{
	SUBJECT="${email_subject}"
	MESSAGE="${email_message}"
	ATTACHMENT="${email_attachment}"

	if (( $DEBUG )); then
		case $LOGNAME in
			p583607)    export DIST_LIST=LFerrazzi@StateStreet.com ;;
			p585674)    export DIST_LIST=JIImmanuelJeyasingh@StateStreet.com ;;
			e596983)    export DIST_LIST=VDandu@StateStreet.com ;;
			e620800)    export DIST_LIST=PSandeep@StateStreet.com ;;
			      *)    export DIST_LIST=Dev-Rel-Automation@StateStreet.com ;;
		esac
	fi

	if [[ ! -z ${ATTACHMENT} ]]
	then
		print -n "${MESSAGE} \n" > ${temp1}
		print -n "\n" >> ${temp1}
		cat ${ATTACHMENT} >> ${temp1}
		cat "${temp1}" | mailx -s "${SUBJECT}" ${DIST_LIST}
	else
		print -n "${MESSAGE} \n" | mailx -s "${SUBJECT}" ${DIST_LIST}
	fi
		
	mlog info "Notification email sent to '${DIST_LIST}'"
} 

##############################################
# Start of pplservice_template
# Last modified: Wed Aug 19 16:18:02 EDT 2015 JAmes

#-----------------------------------------
# FUNCTION: mlog
#-----------------------------------------
mlog ()
{
	# args 1 and 2 are required.  arg 3 is optional
	if [[ -z ${logfile} ]]
	then
		print "ERROR: The variable ${logfile} is undefined"
		exit 1
	fi

	typeset -u -L10 msg_type

	if [[ ! -z $1 &&  ! -z $2 ]]
	then
		# always covert the message type to uppercase
		msg_type=$(echo "$1" | tr "[a-z]" "[A-Z]")
		msg_text=$2
		msg_opt=$3
		# for now, the only option supported is -n to not print newline character
		now="$(date +'%Y-%m-%d %H:%M:%S')"
		if [[ ! -z $msg_opt ]]
		then
			print -n "${now} : $msg_type : $msg_text" 
		else
			print "${now} : $msg_type : $msg_text" 
		fi
	else
		print "" 
	fi
}

#----------------------------------------------------------------
# FUNCTION: ask_continue_or_exit
#----------------------------------------------------------------
ask_continue_or_exit()
{
        if [[ -z ${message} ]]
        then
                mlog
                message="Please notify TradeServices and TmanDev Teams, then await confirmation to continue the installation"
        fi
	while true
	do
                mlog
                mlog action "${message}"
                mlog wait "When ready, enter 'cont' to continue OR 'exit' to quit: \c" -n
		read ans
		mlog
		if [[ ! -z ${ans} ]]
		then
			if [[ ${ans} == exit ]]
			then
				mlog info "User entered '${ans}'.  Exiting now."
				bail_out
			else
				if [[ ${ans} = cont ]]
				then
                                        mlog info "User entered '${ans}'. Continuing with the installation"
                                        break
                                else
                                        mlog error "Invalid response '${ans}'"
				fi
			fi
		fi
	done
}


#----------------------------------------------------------------
# FUNCTION: shutdown_the_application
#----------------------------------------------------------------
shutdown_the_application()
{
    	mlog info "$aline"
	mlog info "STEP ${STEP_CNT}: STOPPING ${APP} through ${ENV} Autosys"
    	mlog info "$aline"

	# Capture the time now before stopping the application so we can compare with timestamp of the app shutdown message later
	shutdown_begin_ts=$(date +'%Y%m%d%H%M%S')

	# Capture the application process ID in case we have to kill it later
	if [[ ! -f ${APP_PROGRAM_FILE} ]]
	then
		mlog fatal "${APP} jar file '${APP_PROGRAM_FILE}' not found.  Exiting."
		bail_out
	else
		/usr/sbin/fuser ${APP_PROGRAM_FILE} > ${temp1} 2> /dev/null

		if [[ -s ${temp1} ]]
		then
			export APP_PID=$(cat ${temp1} | awk '{print $0}')
		else
			# make it null
			export APP_PID=
		fi
	fi

	if (( ${autosys_client} ))
	then
		# If the autosys client is installed on this server, force start the job
		mlog EXEC "${AUTOSYS}/bin/sendevent -E FORCE_STARTJOB -J ${stop_job}"
		if (( ! ${DEBUG} ))
		then
			${AUTOSYS}/bin/sendevent -E FORCE_STARTJOB -J ${stop_job}
			if (( $? != 0 ))
			then
				mlog error "Error issuing sendevent command"
				bail_out
			fi
		fi
	else
		if (( ! ${DEBUG} ))
		then
			# If NO autosys client and this is NOT debug, instruct to user to force start the job
			message="The Autosys client is not available on this server.  Please FORCE START the ${AUTOSERV} job ${stop_job}"
			mlog action "${message}"
			ask_continue_or_exit
		else
			# If DEBUG mode, just pretend to force start the job
			mlog EXEC "${AUTOSYS}/bin/sendevent -E FORCE_STARTJOB -J ${stop_job}"
		fi
	fi

}

#----------------------------------------------------------------
# FUNCTION: kill_pids
#----------------------------------------------------------------
kill_pids()
{
	# If the PID is null, try one more time to capture it
	if [[ -z ${APP_PID} ]]
	then
                /usr/sbin/fuser ${APP_PROGRAM_FILE} > ${temp1} 2> /dev/null

		if [[ -s ${temp1} ]]
		then
			APP_PID=$(cat ${temp1} | awk '{print $0}')
		fi
	fi

	if [[ -z ${APP_PID} ]]
	then
                mlog info "${APP} shutdown is complete.  The command '/usr/sbin/fuser ${APP_PROGRAM_FILE}' returned no Process IDs."
                shutdown_detected=1
	else
		ptree ${APP_PID} | egrep -v 'cybAgent|grep' > ${temp1}
		pidLIST=
		while read -r eachline
		do
			thisPID=$(echo "$eachline" | awk '{print $1}')
			pidLIST="${pidLIST} ${thisPID}"
		
		done < ${temp1}

		while true
		do
			tput smso
			mlog info "These ${APP} Process IDs are still running: '${pidLIST} '"
			mlog info "Do you want to kill them ?  Please enter 'YES' or 'NO': \c" -n
			read confirmation
			tput rmso
			ANSWER=$(echo "$confirmation" | tr "[a-z]" "[A-Z]")
			case ${ANSWER} in
				YES) export confirmed=1 ;;
				 NO) export confirmed=0 ;;
				  *) mlog warn "Invalid Response.  Please enter 'YES' or 'NO'" ;;
			esac

			if [[ ${ANSWER} == YES || ${ANSWER} == NO ]]
			then
				mlog info "User entered '${ANSWER}'"
				break
			fi
		done

		if (( ${confirmed} ))
		then
                 	# mlog info "User requested to kill ${APP} Process IDs: ${pidLIST}"
			mlog info "Killing Process IDs: ${pidLIST}"
			kill -9 ${pidLIST}

			# Verify we killed all the PIDs
			searchPidList=$(echo "${pidLIST}" | sed 's/ /|/g')
			pid_count=$(ps -ef | egrep "${searchPidList}" | egrep -v grep | wc -l )
			if (( ${pid_count} != 0 ))
			then
				mlog error "Some ${APP} Process IDs were not killed"
				mlog
				egrep "${searchPidList}"
				mlog
				# message="Please ensure all processes not running before proceeding with the installation"
				ask_continue_or_exit
			else
				mlog info "All ${APP} Process IDs have been killed."
			fi
                else
                        mlog info "User requested to NOT kill ${APP} Process IDs: ${pidLIST}"
		fi
	fi
}
#------------------------ end kill_pids ------------------------------------

			

#----------------------------------------------------------------
# FUNCTION: verify_applicaton_is_shutdown
#----------------------------------------------------------------
verify_applicaton_is_shutdown()
{
        (( STEP_CNT+=1 ))
        mlog info "$aline"
        mlog info "STEP ${STEP_CNT}: VERIFYING THAT ${APP} HAS STOPPED. CHECK THAT /usr/sbin/fuser ${APP_PROGRAM_FILE} RETURNS NO PIDs"
        mlog info "$aline"
        mlog info "Waiting 30 seconds for ${APP} to shutdown"
	shutdown_detected=0
	sleep $SLEEP30

    	# 	mlog EXEC "/usr/sbin/fuser ${APP_PROGRAM_FILE}"

	i=0
	shutdown_detected=0
    	while (( i <= 6 ))
	do
		mlog EXEC "/usr/sbin/fuser ${APP_PROGRAM_FILE}"
		/usr/sbin/fuser ${APP_PROGRAM_FILE} > ${temp1} 2> /dev/null
    		process_count=$(cat ${temp1} | wc -w | awk '{print $0}')
    	if (( ${process_count} == 0 ))
    	then
			mlog info "${APP} shutdown is completed.  The command '/usr/sbin/fuser ${APP_PROGRAM_FILE}' returned no Process IDs."
			shutdown_detected=1
			break
		fi
		mlog info "Waiting for ${APP} to shutdown ...."
		sleep $SLEEP30
		(( i+=1 ))
	done

    if (( ! $shutdown_detected ))
    then
		mlog warn "${APP} shutdown is not completed.  Attempting to kill process IDs"
		kill_pids
	fi

}

#----------------------------------------------------------------
# FUNCTION: unzip_and_rename
#----------------------------------------------------------------
unzip_and_rename()
{
	(( STEP_CNT+=1 ))
	mlog
    mlog info "$aline"
	mlog info "STEP ${STEP_CNT}: Getting distribution from SVN repository"
    mlog info "$aline"

	# Copy from the SVN EXPORT DIR to the ${APP} Distribution Dir
	mlog info "Copying ${SVN_EXPORT_DIR}/${BUILD_FILE} to ${DIST_DIR}"    
	mlog EXEC "cp -p ${SVN_EXPORT_DIR}/${BUILD_FILE} ${DIST_DIR}"
	cp -p ${SVN_EXPORT_DIR}/${BUILD_FILE} ${DIST_DIR}
	if (( $? != 0 ))
	then
		mlog error "Error copying  ${SVN_EXPORT_DIR}/${BUILD_FILE} to ${DIST_DIR}"
		bail_out
	else
		mlog info "${BUILD_FILE} successfully copied"
	fi

	# Clean out old files from the deploy directory
	(( STEP_CNT+=1 ))
    	mlog info "$aline"
	mlog info "STEP ${STEP_CNT}: Removing previous ${APP} installations:"
    	mlog info "$aline"
	mlog EXEC "rm -Rf ${DEPLOY_DIR}"
	$(rm -Rf ${DEPLOY_DIR}) 
	if (( $? != 0 ))
	then
		mlog error "Error removing files from ${DEPLOY_DIR}"
		bail_out
	#else
		#ls -l ${HOME} 
	fi

	# Unzip the distribution
	mlog EXEC "Unzipping ${DIST_DIR}/${BUILD_FILE} -d ${APP_HOME}"
	(( STEP_CNT+=1 ))
    	mlog info "$aline"
	mlog info "STEP ${STEP_CNT}: Unzipping and renaming the distribution to deploy directory"
    	mlog info "$aline"
    	unzip ${DIST_DIR}/${BUILD_FILE} -d ${APP_HOME}
	if (( $? != 0 ))
	then
		mlog error "Error unzipping ${DIST_DIR}/${BUILD_FILE} to ${APP_HOME}"
		bail_out
	fi

	# Move to the deployment directory
	mlog
	mlog info "Moving build to deployment directory"
	mlog EXEC "mv ${APP_HOME}/${APP} ${DEPLOY_DIR}"
	mv ${APP_HOME}/${APP} ${DEPLOY_DIR} 
	if (( $? != 0 ))
	then
		mlog error "Error moving ${APP_HOME}/${APP} ${DEPLOY_DIR}"
		bail_out
	fi
}

#----------------------------------------------------------------
# FUNCTION: startup_the_application
#----------------------------------------------------------------
startup_the_application()
{
	(( STEP_CNT+=1 ))
	mlog
    	mlog info "$aline"
	mlog info "STEP ${STEP_CNT}: STARTING ${APP} through ${ENV} Autosys"
    	mlog info "$aline"

	if (( ${autosys_client} ))
	then
		# If the autosys client is installed on this server, force start the job
		mlog EXEC "${AUTOSYS}/bin/sendevent -E FORCE_STARTJOB -J ${start_job}"
		if (( ! ${DEBUG} ))
		then
			${AUTOSYS}/bin/sendevent -E FORCE_STARTJOB -J ${start_job}
			if (( $? != 0 ))
			then
				mlog error "Error issuing sendevent command"
				bail_out
			fi
		fi
	else
		if (( ! ${DEBUG} ))
		then
			# If NO autosys client and this is NOT debug, instruct to user to force start the job
			message="The Autosys client is not available on this server.  Please FORCE START the ${AUTOSERV} job ${start_job}"
			ask_continue_or_exit
		else
			# If DEBUG mode, just pretend to force start the job
			mlog EXEC "${AUTOSYS}/bin/sendevent -E FORCE_STARTJOB -J ${start_job}"
		fi
	fi

}

#-----------------------------------------
# FUNCTION: bail_out
#-----------------------------------------
bail_out()
{
        mlog fatal "Exiting on Fatal Error.  See ${logfile} for more information"
		export email_subject="${APP} ${BUILD_NAME} Installation Failed."
		export email_message="${APP} ${BUILD_NAME} Installation Failed\n"
		export email_message="${email_message} Log File is `hostname`:${logfile}"
		export email_attachment=${logfile}
                show_environment_variables
		ais_send_email
	        rm -f ${temp1} ${temp2} ${temp3}
        exit 1
}

#----------------------------------------------------------------
# FUNCTION: verify_app_is_running
# 10/21/2015 LFF Modified to determine if the app is up using the
# fuser command instead of searching the log file for messages
#----------------------------------------------------------------
verify_app_is_running()
{
	(( STEP_CNT+=1 ))
	mlog info "$aline"
	mlog info "STEP ${I}: VERIFYING ${APP} IS RUNNING ON ${APP_HOST}"
	mlog info "$aline"

	mlog info "Waiting $SLEEP30 seconds for ${APP} to startup ..."
	sleep ${SLEEP30}

	application_started=0
	i=1
	while (( i <= 5 ))
	do
		mlog EXEC "Checking for ${APP} Process IDs using the command: /usr/sbin/fuser ${APP_PROGRAM_FILE}"
		/usr/sbin/fuser ${APP_PROGRAM_FILE} > ${temp1} 2> /dev/null
		APP_PID=$(cat ${temp1} | awk '{print $0}')
        if [[ ! -z ${APP_PID} ]]
        then
			mlog info "${APP} is running.  "
			mlog info "The command '/usr/sbin/fuser ${APP_PROGRAM_FILE}' returned Process ID: '${APP_PID}'"
			mlog
			ptree ${APP_PID} | egrep -v cybAgent
			mlog
			application_started=1
			break
		fi
		mlog info "Waiting $SLEEP30 seconds for ${APP} to startup ..."
		sleep ${SLEEP30}
		(( i+=1 ))
	done

	rm -f ${temp1}

	if (( ! ${application_started} ))
	then
		mlog warn "The command '/usr/sbin/fuser ${APP_PROGRAM_FILE}' returned no Process IDs."
		mlog warn "${APP} has not started after 5 minutes"
		ask_continue_or_exit
	fi
}

#----------------------------------------------------------------
# FUNCTION: execute_the_redeployment_script
#----------------------------------------------------------------
execute_the_redeployment_script()
{
	(( STEP_CNT+=1 ))
	mlog
    mlog info "$aline"
    mlog info "STEP ${STEP_CNT}: Executing the redeployment script" 
    mlog info "$aline"

    # Copy from the SVN EXPORT DIR to the ${APP} Distribution Dir
    mlog info "Copying ${SVN_EXPORT_DIR}/${BUILD_FILE} to ${DIST_DIR}"
    mlog EXEC "cp -p ${SVN_EXPORT_DIR}/${BUILD_FILE} ${DIST_DIR}"
    cp -p ${SVN_EXPORT_DIR}/${BUILD_FILE} ${DIST_DIR}
    if (( $? != 0 ))
    then
        mlog error "Error copying  ${SVN_EXPORT_DIR}/${BUILD_FILE} to ${DIST_DIR}"
        bail_out
    else
        mlog info "${BUILD_FILE} successfully copied"
    fi

	mlog EXEC "bash ${DIST_DIR}/redeploy.sh ${BUILD_NAME}"
	bash ${DIST_DIR}/redeploy.sh ${BUILD_NAME}
	if (( $? != 0 ))
	then
		mlog error "Error executing ${DIST_DIR}/redeploy.sh"
		bail_out
	else
		mlog info "Redeploy script completed successfully"
	fi
}

#----------------------------------------------------------------
# FUNCTION: chmod_owner_group
#----------------------------------------------------------------
chmod_owner_group()
{
	(( STEP_CNT+=1 ))
	mlog
    mlog info "$aline"
	mlog info "STEP ${STEP_CNT}: Changing owner:group for the installation to '${app_owner}:${app_group}'"
    mlog info "$aline"

	# Instructions say to chown ALL files with proper owner:group
	mlog EXEC "chown -fR ${app_owner}:${app_group} ${DEPLOY_DIR}"
	chown -fR ${app_owner}:${app_group} ${DEPLOY_DIR}
	if (( $? != 0 ))
	then
		mlog fatal "Error setting owner:group to '${app_owner}:${app_group}'"
		bail_out
	fi

	mlog info "Sucessfully changed owner:group of ${DEPLOY_DIR} to '${app_owner}:${app_group}'"
	mlog

	# If the log file exists, set owner:group
	if [[ -f ${APP_LOG_FILE} ]]
	then
		mlog info "Changing owner:group for ${APP_LOG_FILE} to '${app_owner}:${app_group}'"
		mlog EXEC "chown -fR ${app_owner}:${app_group} ${APP_LOG_FILE}"
		chown -fR ${app_owner}:${app_group} ${APP_LOG_FILE}
		if (( $? != 0 ))
		then
			mlog error "Error running chown -fR ${app_owner}:${app_group} on ${APP_LOG_DIR}"
			bail_out
		else
			mlog info "Sucessfully changed owner:group of ${APP_LOG_FILE} to '${app_owner}:${app_group}'"
			applicationlog="$(ls -l ${APP_LOG_FILE})"
			mlog info "${applicationlog}"
		fi
	fi
} 

#----------------------------------------------------------------
# FUNCTION: verify_one_app_instance
#----------------------------------------------------------------
verify_one_app_instance()
{
	(( STEP_CNT+=1 ))
	mlog
	mlog info "$aline"
    mlog info "STEP $STEP_CNT: VERIFY ONLY 1 INSTANCE OF $APP IS RUNNING"
	mlog info "$aline"
    mlog info "Confirming only 1 instance of ${APP} is running using the command: /usr/sbin/fuser ${APP_PROGRAM_FILE}"
	mlog EXEC "/usr/sbin/fuser ${APP_PROGRAM_FILE}"
    /usr/sbin/fuser ${APP_PROGRAM_FILE} > ${temp1} 2> /dev/null

    process_count=$(cat ${temp1} | wc -w | awk '{print $0}')
    if (( ${process_count} != 1 ))
	then
		if (( ${process_count} == 0 ))
		then
                        ##message="No ${APP} Process IDs are running.  Please investigate."
                        mlog
                        mlog warn "The '/usr/sbin/fuser ${APP_PROGRAM_FILE}' command returned NO ${APP} Process IDs."
                        mlog warn "It appears ${APP} is not running."
                        mlog warn "Please open a new session on ${APP_HOST} investigate"
                        ask_continue_or_exit
		else
			if (( ${process_count} > 1 ))
			then
                                mlog
                                mlog warn "More than one instance of ${APP} is running. The Process IDs are:"
                                mlog
                                pidList=$(cat ${temp1} | awk '{print $0}')
                                ptree ${pidList}
                                mlog
                                export message="Please open a new session on ${APP_HOST} to investigate"
                                ask_continue_or_exit
			fi
		fi
	else
		proc_id=$(cat ${temp1} | awk '{print $1}')
		mlog info "Confirmed that only one instance of ${APP} is running. Process ID is $proc_id"
		mlog info "Output from ptree ${proc_id} is:"
		mlog
		ptree ${proc_id}
		mlog
		rm -f ${temp1}
	fi
} 

#----------------------------------------------------------------
# FUNCTION: verify_the_correct_build_is_installed
#----------------------------------------------------------------
verify_the_correct_build_is_installed()
{
	(( STEP_CNT+=1 ))
    mlog info "$aline"
    mlog info "STEP ${I}: VERIFYING THE CORRECT BUILD IS INSTALLED"
    mlog info "$aline"
    mlog info "Verify the correct build is installed"
    mlog info "Comparing the build name '${BUILD_NAME}' against the contents of ${BuildConfirmationFile}"
    mlog info "BUILD_NAME = ${BUILD_NAME}"
    mlog info "Contents of ${BuildConfirmationFile} are: $(cat ${BuildConfirmationFile} | awk '{print $0}')"
    build=$(cat ${BuildConfirmationFile} | awk '{print $1}')
    if [[ ${BUILD_NAME} == ${build} ]]
    then
        mlog info "Confirmed build '${BUILD_NAME}' is installed"
    else
        mlog error "Incorrect build has been installed"
        mlog error "Build Name = ${BUILD_NAME}"
        mlog error "This Build = ${build}"
        bail_out
    fi
}

#----------------------------------------------------------------
# FUNCTION: show_environment_variables
#----------------------------------------------------------------
show_environment_variables()
{
        # Show the environment variables should they be needed for trouble shooting
        mlog info "DISPLAYING ENVIRONMENT VARIABLES"
        env | sort >> ${logfile}
}


#==================================================================================
# MAIN LOGIC
#==================================================================================

do_initialize

STEP_CNT=1

MY_ID=$(id | cut -d\( -f2 | cut -d\) -f1)

if [[ ${MY_ID} == ${LOGNAME} ]]
then
        mlog
        mlog INFO "Starting ${APP} installation using ${LOGNAME}."
        mlog
else
        mlog
        mlog FATAL "${APP} MUST be started on sunray-1 with your VID then completed on the application server by root."
        mlog FATAL "Please use your VID for this first step on sunray-1 to run this script."
        mlog FATAL "Exiting."
        mlog
        bail_out
fi

mlog STARTED "$0"

mlog info "User ${LOGNAME} is performing this installation as the user ${MY_ID}"

if (( ${DEBUG} ))
then
	mlog
	shutdown_the_application
	echo ""
	print -n "press <RETURN> to continue "
	read ans

	mlog
	verify_applicaton_is_shutdown
	echo ""
	print -n "press <RETURN> to continue "
	read ans

	##mlog
	##unzip_and_rename
	##echo ""
	##print -n "press <RETURN> to continue "
	##read ans

	mlog
	execute_the_redeployment_script
	echo ""
	print -n "press <RETURN> to continue "
	read ans

	mlog
	chmod_owner_group
	echo ""
	print -n "press <RETURN> to continue "
	read ans

	mlog
	verify_the_correct_build_is_installed
	echo ""

	# If there are any db pkgs being installed, don't start the application
	# Display a message and exit, we're finished.
	if (( ${db_pkg_install} ))
	then
		mlog
		mlog info "DB Packages must be installed with build '${BUILD_NAME}' of '${APP}'"
		mlog info "Do not start ${APP} until after the DB Packages are successfully installed"
		mlog
	else
		mlog
		startup_the_application
		echo ""
		print -n "press <RETURN> to continue "
		read ans

		mlog
		verify_app_is_running
		echo ""
		print -n "press <RETURN> to continue "
		read ans

		mlog
		verify_one_app_instance
		echo ""
		print -n "press <RETURN> to continue "
		read ans
	fi
else
	mlog
	shutdown_the_application

	mlog
	verify_applicaton_is_shutdown

	##mlog
	##unzip_and_rename

	mlog
	execute_the_redeployment_script

	mlog
	chmod_owner_group

	mlog
	verify_the_correct_build_is_installed

	# If there are any db pkgs being installed, don't start the application
	# Display a message and exit, we're finished.
	if (( ${db_pkg_install} ))
	then
		mlog
		mlog info "DB Packages must be installed with build '${BUILD_NAME}' of '${APP}'"
		mlog info "Do not start ${APP} until after the DB Packages are successfully installed"
		mlog
	else
		mlog
		startup_the_application

		mlog
		verify_app_is_running

		mlog
		verify_one_app_instance
	fi
fi

mlog info "Sending email notification to '${DIST_LIST}'"
mlog
mlog COMPLETED "$0 `date`"

export email_subject="${APP} ${BUILD_NAME} Installation Completed Successfully."
export email_message="${APP} ${BUILD_NAME} Installation Completed Successfully."
export email_message="${email_message} Log File is `hostname`:${logfile}"
export email_attachment=${logfile}
show_environment_variables
ais_send_email

rm -f ${temp1} ${temp2} ${temp3}
exit $exit_code

#eof ${APP}_template
