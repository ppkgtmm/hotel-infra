apt update
apt install -y git python3 python3-venv wget
git clone https://github.com/ppkgtmm/hotel-datagen.git datagen
cd datagen
wget -O .env https://raw.githubusercontent.com/ppkgtmm/hotel-infra/main/.env
./run.sh
