location="us-central1-a"
gcloud pubsub lite-subscriptions list --location $location | grep "name: " > temp
while read -r line 
do
    gcloud pubsub lite-subscriptions delete `echo $line | cut -w -f2,2` --location $location -q
done < temp
gcloud pubsub lite-topics list --location $location | grep "name: " > temp
while read -r line 
do
    gcloud pubsub lite-topics delete `echo $line | cut -w -f2,2` --location $location -q
done < temp
