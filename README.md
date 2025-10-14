### backend
aws s3api create-bucket \
  --bucket adcash-terraform-state-bucket \
  --region eu-central-1 \
  --create-bucket-configuration LocationConstraint=eu-central-1 \
  --profile myself

aws s3api put-bucket-versioning \
  --bucket adcash-terraform-state-bucket \
  --versioning-configuration Status=Enabled \
  --profile myself

aws s3api put-bucket-encryption \
  --bucket adcash-terraform-state-bucket \
  --profile myself \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'

## terraform
terraform init -backend-config="key=eks/dev/terraform.tfstate" -migrate-state
terraform init -backend-config="key=eks/dev/terraform.tfstate" -upgrade
##true: terraform init -backend-config="environments/dev/backend.hcl"
terraform init \
  -migrate-state \
terraform plan  -var-file="environments/dev/terraform.tfvars"
terraform apply -var-file="environments/dev/terraform.tfvars" --auto-approve
terraform destroy -var-file="environments/dev/terraform.tfvars" --auto-approve


## kubectl
aws eks update-kubeconfig --region eu-central-1 --name adcash-dev-cluster

##app
docker run --rm --name adcash-test -p 5000:5000 -p 9100:9100 adcash-test
curl http://localhost:5000/gandalf
curl http://localhost:5000/colombo
curl http://localhost:9100
http://91.98.134.89:9100/

for 
readinessProbe in deployment you should add another routes otherwise its count it.

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=adcash-dev \
  --set region=eu-central-1 \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller

kubectl get pods -n kube-system -o wide | grep aws-load-balancer-controller

####note
lb-controller-sa.tf shoub be change
## ami
aws ssm get-parameter --name /aws/service/eks/optimized-ami/1.34/amazon-linux-2023/x86_64/standard/recommended/image_id     --region eu-central-1 --query "Parameter.Value" --output text --profile myself

https://docs.aws.amazon.com/eks/latest/userguide/retrieve-ami-id.html

##extra
میشد زد که اگر میخوای دوتا ip ها بگیره باید topology رو عوض کنی توی deployment.yml و کل استک رو روی دوتا node ران کنی

##prometheus
should create key

http://3.123.137.57/metrics

curl -s "http://localhost:9090/api/v1/query?query=gandalf_requests_total"