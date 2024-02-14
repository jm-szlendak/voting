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

# TODO

- k8s namespaces
- k8s service accounts
- dont use postgres root user
- dont use redis root user