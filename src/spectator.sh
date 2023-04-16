#!/bin/bash

api="https://api-hueue.panfilov.tech"
sign=null
vk_user_id=null
vk_ts=null
vk_ref=null
user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.5060.114 Safari/537.36"

function authenticate() {
	# 1 - sign: (string): <sign>
	# 2 - vk_user_id: (integer): <vk_user_id>
	# 3 - vk_ts: (integer): <vk_ts>
	# 4 - vk_ref: (string): <vk_ref>
	# 5 - access_token_settings: (string): <access_token_settings - default: >
	# 6 - are_notifications_enabled: (integer): <are_notifications_enabled: default: 0>
	# 7 - is_app_user: (integer): <is_app_user - default: 0>
	# 8 - is_favorite: (integer): <is_favorite - default: 0>
	# 9 - language: (string): <language - default: ru>
	# 10 - platform: (string): <platform - default: desktop_web>
	sign=$1
	vk_user_id=$2
	vk_ts=$3
	vk_ref=$4
	params="vk_access_token_settings=${5:-}&vk_app_id=8040721&vk_are_notifications_enabled=${6:-0}&vk_is_app_user=${7:-0}&vk_is_favorite=${8:-0}&vk_language=${9:-ru}&vk_platform=${10:-desktop_web}&vk_ref=$vk_ref&vk_ts=$vk_ts&vk_user_id=$vk_user_id&sign=$sign"
	generate_jwk_token
}

function generate_jwk_token() {
	response=$(curl --request POST \
		--url "$api/generate_jwt/vk/" \
		--user-agent "$user_agent" \
		--header "content-type: application/json" \
		--data '{
			"query": "'$params'"
		}')
	if [ -n $(jq -r ".token" <<< "$response") ]; then
		access_token=$(jq -r ".token" <<< "$response")
	fi
	echo $response
}

function get_tasks() {
	curl --request GET \
		--url "$api/owner/tasks/?access_token=$access_token" \
		--user-agent "$user_agent" \
		--header "content-type: application/json"
}

function get_badges() {
	curl --request GET \
		--url "$api/owner/badges/?access_token=$access_token" \
		--user-agent "$user_agent" \
		--header "content-type: application/json"
}

function create_task() {
	# 1 - type: (string): <type>
	# 2 - url: (string): <url>
	# 3 - cron: (string): <cron>
	# 4 - notifications: (string): <notifications>
	# 5 - name: (string): <name>
	curl --request POST \
		--url "$api/owner/tasks/?access_token=$access_token" \
		--user-agent "$user_agent" \
		--header "content-type: application/json" \
		--data '{
			"task": {
				"type": "'$1'",
				"url": "'$2'"
			},
			"cron": "'$3'",
			"notifications": "'$4'",
			"name": "'$5'",
			"owner_id": 'vk_$vk_user_id'
		}'
}

function edit_task() {
	# 1 - type: (string): <type>
	# 2 - url: (string): <url>
	# 3 - cron: (string): <cron>
	# 4 - notifications: (string): <notifications>
	# 5 - task_id: (string): <task_id>
	# 6 - name: (string): <name>
	curl --request POST \
		--url "$api/owner/tasks/?access_token=$access_token" \
		--user-agent "$user_agent" \
		--header "content-type: application/json" \
		--data '{
			"task": {
				"type": "'$1'",
				"url": "'$2'"
			},
			"cron": "'$3'",
			"notifications": "'$4'",
			"id": "'$5'",
			"name": "'$6'",
			"owner_id": 'vk_$vk_user_id'
		}'
}
