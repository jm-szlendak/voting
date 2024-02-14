# Prerequisites

- docker installed
- minikube cluster installed & running
- terraform installed

# Build
```
sh build_and_push.sh --registry yourimageregistry
```

This will build docker images and push them, tagging with current commit hash.

# Deploy:
```
sh deploy.sh --env yourenv --tag 123abc456efg
```