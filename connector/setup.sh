apt update
apt install -y git python3 python3-venv libpq-dev gcc python3-dev
git clone https://github.com/ppkgtmm/hotel-connector.git connector
cd connector
./run.sh
