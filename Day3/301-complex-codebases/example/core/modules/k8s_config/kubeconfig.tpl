apiVersion: v1
kind: Config
clusters:
- name: main
  cluster:
    certificate-authority-data: ${ base64encode(cert) }
    server: "https://${ cluster_fqdn }:443"
contexts:
- name: main
  context:
    cluster: main
    namespace: ${ namespace }
    user: ${ service_account }
current-context: main
users:
- name: ${ service_account }
  user:
    token: ${ token }
