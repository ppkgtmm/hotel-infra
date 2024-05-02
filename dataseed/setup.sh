apt update
apt install -y git python3 python3-venv wget postgresql15
git clone https://github.com/ppkgtmm/hotel-seed.git dataseed
cd dataseed
wget -O .env https://raw.githubusercontent.com/ppkgtmm/hotel-infra/main/.env
./run.sh
