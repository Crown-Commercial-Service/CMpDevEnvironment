# Add arguments for the directory and terraform plan files
CURRENT_DIRECTORY=$1
TARGET_DIRECTORY=$2
TERRAFORM_PLAN_FILENAME=$3
TERRAFORM_PLAN_S3_BUCKET_NAME=$4
# CHANGE DIRECTORY INTO THE GIVEN DIRECTORY
cd $TARGET_DIRECTORY
# OBTAIN TERRAFORM PLAN FILE FROM S3
aws s3 cp s3://$TERRAFORM_PLAN_S3_BUCKET_NAME/$TERRAFORM_PLAN_FILENAME .
# RUN TERRAFORM INIT AND TERRAFORM APPLY WITH THE TFPLAN FILE
terraform init
terraform apply $TERRAFORM_PLAN_FILENAME
# CHANGE DIRECTORY BACK TO WORKING DIR
cd $CURRENT_DIRECTORY