#!/bin/bash

# Copyright 2019 - 2020 Crunchy Data Solutions, Inc.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


function trap_sigterm() {
	echo "Signal trap triggered, beginning shutdown.."
	killall sshd
}

trap 'trap_sigterm' SIGINT SIGTERM

CONFIG=/sshd
REPO=/backrestrepo

if [ ! -d $PGBACKREST_REPO1_PATH ]; then
	echo "creating " $PGBACKREST_REPO1_PATH
	mkdir -p $PGBACKREST_REPO1_PATH
fi

# This is a workaround for changes introduced in pgBackRest v2.24.  Specifically, a pg1-path
# setting must now be visible when another container executes a pgBackRest command via SSH.
# Since env vars, and therefore the PGBACKREST_DB_PATH setting, is not visible when another
# container executes a command via SSH, this adds the pg1-path setting to the pgBackRest config
# file instead, ensuring the setting is always available in the environment during SSH calls.
# Additionally, since the value for pg1-path setting in the repository container is irrelevant
# (i.e. the value specified by the container running the command via SSH is used instead), it is
# simply set to a dummy directory within the config file.
mkdir -p /tmp/pg1path
if ! grep -Fxq "[${PGBACKREST_STANZA}]" "/etc/pgbackrest/pgbackrest.conf"
then
    printf "[%s]\npg1-path=/tmp/pg1path\n" "$PGBACKREST_STANZA" > /etc/pgbackrest/pgbackrest.conf

		# Additionally, if the PGBACKREST S3 variables are set, add them here
		if [[ "${PGBACKREST_REPO1_S3_KEY}" != "" ]]
		then
			printf "repo1-s3-key=%s\n" "${PGBACKREST_REPO1_S3_KEY}" >> /etc/pgbackrest/pgbackrest.conf
		fi

		if [[ "${PGBACKREST_REPO1_S3_KEY_SECRET}" != "" ]]
		then
			printf "repo1-s3-key-secret=%s\n" "${PGBACKREST_REPO1_S3_KEY_SECRET}" >> /etc/pgbackrest/pgbackrest.conf
		fi
fi

mkdir ~/.ssh/
cp $CONFIG/config ~/.ssh/
#cp $CONFIG/authorized_keys ~/.ssh/
cp $CONFIG/id_ed25519 /tmp
chmod 400 /tmp/id_ed25519 ~/.ssh/config

# start sshd which is used by pgbackrest for remote connections
/usr/sbin/sshd -D -f $CONFIG/sshd_config   &

wait
