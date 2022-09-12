GITOPS PROJECT

This repository contains examples for the ArgoCD/GitOps project.

    1. We have to install argocd into the kubernetes cluster .
         
           kubectl create ns argocd		
	  
	   kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml 	
	    
	   kubectl port-forward svc/argocd-server -n argocd 8080:443

	   To login into argocd

		Username: admin

	   To get password apply the following command.

		kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
        
    2. Install grafana, mongodb, mosquitto as helm chart through argocd .
       Run the following command.
          
	  kubectl apply -f ./
