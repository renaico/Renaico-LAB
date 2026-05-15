talos-k8s-devsecops/
│
├── README.md
├── LICENSE
├── SECURITY.md
├── CONTRIBUTING.md
├── Makefile
│
├── infrastructure/
│   ├── terraform/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── talos/
│       ├── controlplane.yaml.tmpl
│       ├── worker.yaml.tmpl
│       └── patch/
│           ├── storage.yaml
│           └── security.yaml
│
├── kubernetes/
│   ├── storage/
│   │   ├── storageclass.yaml
│   │   ├── pvc-example.yaml
│   │   └── csi-config.yaml
│   ├── security/
│   │   ├── namespaces.yaml
│   │   ├── networkpolicies.yaml
│   │   ├── podsecuritypolicies.yaml (o PSA config)
│   │   ├── opa-gatekeeper/
│   │   │   ├── constraints.yaml
│   │   │   └── templates.yaml
│   │   └── falco/
│   │       ├── falco-rules.yaml
│   │       └── falco-config.yaml
│   ├── monitoring/
│   │   ├── prometheus/
│   │   └── grafana/
│   └── apps/
│       └── demo-app/
│           ├── deployment.yaml
│           ├── service.yaml
│           └── pvc.yaml
│
├── security/
│   ├── scan/
│   │   ├── trivy-config.yaml
│   │   └── grype-config.yaml
│   ├── policies/
│   │   └── opa-policies.rego
│   └── benchmarks/
│       └── cis-results.md
│
├── docs/
│   ├── architecture.md
│   ├── security-hardening.md
│   ├── storage-design.md
│   ├── disaster-recovery.md
│   └── troubleshooting.md
│
├── scripts/
│   ├── deploy-cluster.sh
│   ├── security-scan.sh
│   ├── backup-pvs.sh
│   └── test-persistence.sh
│
├── tests/
│   ├── integration/
│   └── security/
│
├── .github/ (o .gitlab/)
│   ├── workflows/
│   │   ├── ci.yml
│   │   ├── security-scan.yml
│   │   └── deploy.yml
│   └── ISSUE_TEMPLATE/
│
└── examples/
    ├── basic-app/
    └── stateful-app/
