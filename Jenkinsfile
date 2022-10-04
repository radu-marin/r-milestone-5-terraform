node{
    
    stage('Clean workspace'){
        cleanWs()
    }
    
    //clone terraform repo
    // stage('Git Prep'){
    //     sh '''
    //     echo "Cloning git repo to following path: $(pwd)"
    //     git clone https://github.com/radu-marin/r-milestone-5-terraform 
    //     ls
    //     '''
    // }
    
//might pe helpful if terraform not in path and kept somewhere on your local jenkins machine (?)
tool name: 'terraform', type: 'terraform'

    stage('Configure terraform'){
        //add terraform tool to path
        env.TERRAFORM_HOME="${tool 'terraform'}"
        env.PATH="${env.TERRAFORM_HOME}:${env.PATH}"
        
        //check
        sh "which terraform"
        
        //authenticate to AWS
        sh '''
        export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
        export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
        '''
        // // if needed
        // sh '''
        // unset AWS_ACCESS_KEY_ID
        // unset AWS_SECRET_ACCESS_KEY
        // '''
    }
    
    // stage('Deploy s3 backend'){
    //     //switch to live/global/s3 and deploy backend S3 for tf state
    //     sh '''
    //     cd "r-milestone-5-terraform/live/global/s3"
    //     echo "Current working directory is: $(pwd)"
    //     terraform init
    //     terraform apply -auto-approve
    //     '''
    // }
    
    stage('Deploy network'){
        //switch to network directory and deploy network
        sh '''
        cd "r-milestone-5-terraform/live/${ENV}/network"
        echo "Current working directory is: $(pwd)"
        terraform init 
        terraform apply -auto-approve
        '''
        //without export can use:
        //terraform init -backend-config="access_key=${AWS_ACCESS_KEY_ID}" -backend-config="secret_key=${AWS_SECRET_ACCESS_KEY}"
    }
    
    stage('Deploy data-storage'){
        
        //switch to data-storage directory and deploy MySQL DB for webapp
        sh '''
        cd r-milestone-5-terraform/live/${ENV}/data-storage
        echo "Current working directory is: $(pwd)"
        terraform init
        terraform apply -auto-approve
        '''
    }
    
    stage('Deploy services'){
        
        //switch to services directory and deploy EC2 instances that host the webapp
        sh '''
        cd r-milestone-5-terraform/live/${ENV}/services
        echo "Current working directory is: $(pwd)"
        terraform init
        terraform apply -auto-approve
        '''
    }
    
    // stage('Destroy everything'){
    //     sh '''
    //     cd r-milestone-5-terraform/live/${ENV}/services
    //     terraform destroy -auto-approve
    //     cd ../data-storage
    //     terraform destroy -auto-approve
    //     cd ../network
    //     terraform destroy -auto-approve
    //     '''
    // }
    
}
