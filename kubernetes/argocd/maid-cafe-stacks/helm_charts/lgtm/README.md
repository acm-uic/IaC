# Monitoring 

Basically the LGTM stack. But we are using `grafana-community` charts due to deprecation otherwise

> [!CAUTION]
> Do **NOT** change the file extension in `values/` from `.yaml` to `.yml` due to we don't want ArgoCD to grab and apply. The value files are only there for helm templating files into `charts/` folder.

## Helm templating
This is the helm template rendering of each of LGTM components we want for ArgoCD to grab alongside appropriate values.

Assuming we are at `kubernetes/argocd/maid-cafe-stacks/helm_charts/lgtm/`, run these to produce the charts
```
helm template grafana-community/<l,g,t> -f values/<l,g,t>-values.yml \
                --namespace monitoring > <l,g,t>.yaml
```

For Mimir specifically,
<!-- TODO -->