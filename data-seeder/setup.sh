apt update
apt install -y git python3 python3-venv wget libpq-dev postgresql-client gcc python3-dev
git clone https://github.com/ppkgtmm/hotel-seed.git dataseed
cd dataseed
wget -O .env https://raw.githubusercontent.com/ppkgtmm/hotel-infra/main/.env
./run.sh
shutdown -h +10s
