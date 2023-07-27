# k8s-manifest-repo
AWS CI/CD 테스트
	기본 구성 		후속 작업	
1	eks	terraform	 aws eks update-kubeconfig --region ap-northeast-2 --name eks-test	eks-config-update.sh 
2	codecommit	terraform		
3	argocd 설치		" kubectl create namespace argocd
 kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
 kubectl patch svc argocd-server -n argocd -p '{""spec"": {""type"": ""LoadBalancer""}}'
 kubectl create clusterrolebinding default-admin --clusterrole=admin --serviceaccount=argocd:default
 argocd login 하기 
argocd account update-password"	create_argocd.sh 
4	argocod 연동	k8s		
5	awscodebuild			
6	s3-bucket	terraform		s3.tf
7	s3-mediaLive			
8	sock-shop	yaml 		![image](https://github.com/2023-Cloud-Level3/k8s-manifest-repo/assets/109583750/78e55753-aff9-4301-9d5b-b2c621d9d705)
