#######################################################################################
# Makefile for hw01 with each questions separately and a combined call through "make" #
# 										      #
#######################################################################################

###################################
# Q1: 				  #
# generate files		  #
#				  #
###################################

all: q4 q2 q3

str_time = 
end_time = 
tot_time =

q1_dir = pdrm/

q1:
	@echo ""
	@echo "##############################"
	@echo "Running Q1:"
	@echo ""
	@$(MAKE) -C $(q1_dir) setup
	@$(MAKE) -C $(q1_dir) 
	@echo "##############################"
	@echo ""

###################################
# Q2:				  #
# Print 3 args by running p2/make #
#				  #
###################################
# Default arguments

ARGS = 8 13 21

q2_dir = p2/

q2:
	@echo ""
	@echo "##############################"
	@echo "Running Q2:"
	@$(MAKE) -C $(q2_dir) run ARGS="$(ARGS)"
	@echo "##############################"
	@echo ""


#################
# Example usage:
#
#################

# ARGS = 10 20 30
# make q2 ARGS="1 1000000 10"


####################################
# Q3:				   #
# find, grep, wc commands usage    #
#				   #
####################################

q3_dir = pdrm/

q3:
	@echo ""
	@echo "##############################"
	@echo "Running Q3:"
	@echo "total count for report_qor:" 
	@find $(q3_dir) -type f -exec grep -i "report_qor" {} + | wc -l 
	@echo "pdrm/dcrm/ count:"
	@find $(q3_dir)/dcrm/ -type f -exec grep -i "report_qor" {} + | wc -l
	@echo "pdrm/icc2rm/ count:"
	@find $(q3_dir)/icc2rm/ -type f -exec grep -i "report_qor" {} + | wc -l
	@echo "##############################"
	@echo ""


#####################################
# Q1 and Q4:			    #
# total amount of time to exec pdrm #
#				    #
#####################################

q4:
	@echo ""
	@echo "##############################"
	@echo "Running Q1 and Q4:"
	@date +%s > _time_$@.txt
	@echo ""	
	@$(MAKE) -s -C $(q1_dir) setup
	@$(MAKE) -s -C $(q1_dir)
	@echo ""
	@echo ""
	@echo "##############################"
	@echo ""
	@echo "Q4: [pdrm-exec timing]"	
	@echo "Total time elapsed for exec: $$(($$(date +%s)-$$(cat  _time_$@.txt)))s"
	@rm _time_$@.txt	
	@echo "##############################"

