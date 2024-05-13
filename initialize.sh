#!/bin/bash
apt update && apt install -y git
git clone ${GIT_REPO} source_code
cd source_code

%{ for NAME, VALUE in ENVIRONMENT }
export ${NAME}=${VALUE}
%{ endfor ~}

chmod +x run.sh && ./run.sh
