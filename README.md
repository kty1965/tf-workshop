# tf-workshop

Terraform Provider 설정

## Prerequsites

```zsh
brew install awscli
brew install tfenv
brew cask install aws-vault
```

### aws 계정 셋팅

1. AWS root 계정 로그인
1. `IAM` > `Users` 이동
1. `Add user` 이동
1. User name: `tf-admin`, Access type: `Programmatic access` 설정
1. `Attach exsisting policies directly` > `AdministratorAccess` 설정 후 Next: tags
1. key: `Owner`, value: `tf-admin` 태그 설정
1. `Access key ID`, `Secrect access key` 확인
1. `~/.aws/credentials`에 `aws_profile` 추가 [참조](https://docs.aws.amazon.com/ko_kr/cli/latest/userguide/cli-configure-profiles.html)
    ```
    ...
    [tf-admin]
    aws_access_key_id = <ACCESS_KEY_ID>
    aws_secret_access_key = <SECRECT_ACCESS_KEY>
    ...
    ```
1. `~/.aws/config`에 `aws_profile` 추가 [참조](https://docs.aws.amazon.com/ko_kr/cli/latest/userguide/cli-configure-profiles.html)
    ```
    ...
    [tf-admin]
    region = ap-northeast-2
    output = json
    ...
    ```
1. `aws sts get-caller-identity`로 `Account`, `Arn` 확인

> aws-vault로도 셋팅이 가능
> aws-vault add tf-admin
> aws-vault list로 추가 되었는지 확인

### terraform state & lock 셋팅

> 추후에 `prod`에서 state, dynamodb KMS 암호화 진행 </br>
> [멀티 계정관리](https://www.terraform.io/docs/backends/types/s3.html#delegating-access)

- Create terraform s3 bucket
    ```zsh
    aws s3api create-bucket --acl private --bucket tf-state.example.com --region ap-northeast-2 --create-bucket-configuration LocationConstraint=ap-northeast-2
    aws s3api put-bucket-versioning --bucket tf-state.example.com --versioning-configuration Status=Enabled
    aws s3api put-bucket-encryption \
    --bucket tf-state.example.com \
    --server-side-encryption-configuration '{"Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]}'
    ```
- Create dynamodb table
    ```zsh
    aws dynamodb create-table \
    --table-name tf-state.example.com \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
    --tags Key=Owner,Value=tf-admin
    ```
- tfstate bucket `backend.tf`에 입력
    ```tf
    terraform {
      backend "s3" {
        bucket = "tf-state.example.com"
        key    = "terraform/stage.tfstate"
        region = "ap-northeast-2"
        dynamodb_table = "tf-state.example.com"
      }
      required_version = ">= 0.12"
    }
    ```