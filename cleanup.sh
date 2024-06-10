region=us-central1
location=$region-a
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

job=`gcloud dataproc jobs list --region us-central1 | cut -w -f1,1 | tail -n 1`
for job_id in $job 
do
    gcloud dataproc jobs delete $job --region us-central1 -q
done

bq ls --transfer_config --transfer_location us | cut -w -f2,2 | grep "projects/" > temp
while read -r line 
do
    bq rm --transfer_config $line
done < temp

rm temp
