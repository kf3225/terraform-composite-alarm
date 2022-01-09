# Terraform による AWS CloudWatch Composite Alarm 作成デモ

## 使い方

1. このリポジトリを任意の場所に clone
   ```
   git clone https://github.com/kf3225/terraform-composite-alarm.git
   ```
1. provider.tf を自分の環境に合わせ、編集

   - bucket: state ファイルを保管するバケット名（事前に作成すること）
   - key: state ファイル名
   - region: region 名
   - profile: 使用する profile 名（~/.aws/credentials）

   ```
   terraform {
     required_version = "1.1.3"
     required_providers {
       aws = {
         source  = "hashicorp/aws"
         version = "3.24.0"
       }
     }
     backend "s3" {
       bucket  = "test-terraform-bucket-ap-northeast-1"
       key     = "dev.tfstate"
       region  = "ap-northeast-1"
       profile = "default"
     }
   }
   provider "aws" {
     region  = "ap-northeast-1"
     profile = "default"
   }
   ```

1. terraform init 実行

   ```
   cd terraform-composite-alarm
   terraform init
   ```

1. terraform plan 実行

   ```
   terraform plan
   ```

1. terraform apply 実行
   ```
   terraform apply -auto-approve
   ```

## 片付け方

1. terraform destroy 実行
   ```
   terraform destroy
   ```
