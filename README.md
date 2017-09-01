# klsmith/remote-file-sync

A Docker utility to perform a one-way file sync from a remote server (SFTP or SSH) to a local filesystem, with support for multiple source-destination pairs.

## Usage

There are several ways to run `klsmith/remote-file-sync`.

Regardless how you run it, be sure to mount a host volume at `/dest` so the files persist after the container shuts down.

Stand-alone:

```
docker run --privileged -v /path/to/docker/volume:/dest \
    -e HOST=sourcehost.example.com \
    -e USER=remote_user \
    -e PASS=remote_user_pass \
    -e SYNC_1_SRC=wordress/wp-content/uploads/ \
    -e SYNC_1_DEST=uploads/ \
    -e SYNC_2_SRC=path/to/another/uploads/folder/ \
    -e SYNC_2_DEST=second/uploads/destination/ \
    -e DEST_DIR_PERMS=755 \
    -e DEST_FILE_PERMS=644 \
    -e DEST_GROUP=www-data \
    -e DEST_USER=www-data \
    klsmith/remote-file-sync
```

Docker Compose:

```
version: '2'

services:
  file-sync:
    image: 'klsmith/remote-file-sync:latest'
    environment:
      - HOST=sourcehost.example.com
      - USER=remote_user
      - PASS=remote_user_pass
      - SYNC_1_SRC=wordress/wp-content/uploads/
      - SYNC_1_DEST=uploads/
      - SYNC_2_SRC=path/to/another/uploads/folder/
      - SYNC_2_DEST=second/uploads/destination/
      - DEST_DIR_PERMS=755
      - DEST_FILE_PERMS=644
      - DEST_GROUP=www-data
      - DEST_USER=www-data
    privileged: true
    volumes:
      - '/path/to/docker/volume:/dest'
```

### Environment Variables

| Environment Variable | Required? | Description |
|----------------------|-----------|-------------|
| HOST | Yes | Remote server's hostname. |
| USER | Yes | Username to connect to remote server. |
| PASS |  | Password to connect to remote server. Required if `IDENTITY_FILE` is not set. |
| IDENTITY_FILE |  | Path to private key for authenticating with remote server. Required if `PASS` is not set. e.g. `/path/to/id_rsa` |
| REMOTE_PATH |  | Default: `~` |
| SYNC_#_SRC | Yes | Remote source path, where # is a positive integer. At least one (`SYNC_1_SRC`) is required. e.g. `wordpress/wp-content/uploads/` |
| SYNC_#_DEST | Yes | Local destination path, where # is a positive integer. At least one (`SYNC_1_DEST`) is required. e.g. `uploads/`, which means destination files will be located in the container at `/dest/uploads/`. You should mount a host volume at `/dest` in order for the files to persist after the container shuts down. |
| DEST_DIR_PERMS |  | Sets Unix permissions on destination directories. e.g. `755` |
| DEST_FILE_PERMS |  | Sets Unix permissions on destination files. e.g. `644` |
| DEST_USER |  | Sets the owner on all destination files and directories. e.g. `www-data` |
| DEST_GROUP |  | Sets the group on all destination files and directories. e.g. `www-data` Requires `DEST_USER` to be set. |

The container will exit with code 0 when the sync finishes.

## Bug Reports

If you think you've found a bug, please post a good quality bug report in [this project's GitHub Issues](https://github.com/kevinsmith/docker-remote-file-sync/issues). Quoting from [Coen Jacobs](https://coenjacobs.me/2013/12/06/effective-bug-reports-on-github/), this is how you can best help me understand and fix the issue:

- The title **explains the issue** in just a couple words
- The description **is detailed enough** and contains at least:
  - **steps to reproduce** the issue
  - what the expected result is and **what actually happens**
  - the **version** of the software being used
  - versions of **relevant external software** (e.g. hosting platform, orchestrator, etc.)
- Explain **what you’ve already done** trying to fix this issue
- The report is **written in proper English**

## License

Copyright 2017 Kevin Smith

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
