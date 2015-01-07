#!/bin/bash
#
# rsimai 2014-08-20
# bwiedemann 2015-01-07
#
# some really basic script to automate pulling data from trello and to create the chart
#
# Note you'll need a ~/.trollolorc including your developer_public_key and member_token
# to access the Trello API through trollolo

BASE=~/trollolo
trollolo=$BASE/bin/trollolo
$trollolo get-board-list --board-id=v1PSNp8O > data/board-list.yaml
( cd $BASE/data ; $trollolo burndowns --plot --board-list=board-list.yaml )
ls -l $BASE/data/*/*.png
bin/upload
