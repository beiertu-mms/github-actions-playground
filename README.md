# GitHub actions playground

<div align="center">

  <a href="">![example1](https://img.shields.io/badge/example-one-red)</a>
  <a href="">![example2](https://img.shields.io/badge/example-two-green)</a>
  <a href="">![example3](https://img.shields.io/badge/example-three-blue)</a>

</div>

My playground to test the functionality of [GitHub Actions](https://github.com/features/actions).

## GitHub pages test

- [mermaid](./mermaid/index.md)

## Test Liquid syntax error

[//]: # ({% raw %})
```yaml
---
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
spec:
  groups:
    - rules:
        - alert: CanaryRollback
          expr: flagger_canary_status > 1
          for: 1m
          labels:
            severity: critical
          annotations:
            summary: "Canary failed"
            description: >
              Canary deployment of version
              {{ with query (printf "max_over_time(promotion_service_major_version{job=\"%s-canary\"}[2h])" $labels.name) }}{{ . | first | value | humanize }}{{ end }}.{{ with query (printf "max_over_time(promotion_service_minor_version{job=\"%s-canary\"}[2h])" $labels.name) }}{{ . | first | value | humanize }}{{ end }}.{{ with query (printf "max_over_time(promotion_service_patch_version{job=\"%s-canary\"}[2h])" $labels.name) }}{{ . | first | value | humanize }}{{ end }}
              to {{ $labels.name }}.{{ $labels.exported_namespace }} failed.
            canaryVersion: '{{ with query (printf "max_over_time(promotion_service_major_version{job=\"%s-canary\"}[2h])" $labels.name) }}{{ . | first | value | humanize }}{{ end }}.{{ with query (printf "max_over_time(promotion_service_minor_version{job=\"%s-canary\"}[2h])" $labels.name) }}{{ . | first | value | humanize }}{{ end }}.{{ with query (printf "max_over_time(promotion_service_patch_version{job=\"%s-canary\"}[2h])" $labels.name) }}{{ . | first | value | humanize }}{{ end }}'
            primaryVersion: '{{ with query (printf "max(promotion_service_major_version{job=\"%s-primary\"})" $labels.name) }}{{ . | first | value | humanize }}{{ end }}.{{ with query (printf "max(promotion_service_minor_version{job=\"%s-primary\"})" $labels.name) }}{{ . | first | value | humanize }}{{ end }}.{{ with query (printf "max(promotion_service_patch_version{job=\"%s-primary\"})" $labels.name) }}{{ . | first | value | humanize }}{{ end }}'
```
[//]: # ({% endraw %})

## License

Distributed under the MIT License. See [LICENSE](./LICENSE) for more information.
