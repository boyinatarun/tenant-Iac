# 🌐 Multi-Tenant Deployment Platform — Customer Guide

---

## 1. High-Level Overview

Our platform provides fully isolated environments for each tenant, deployed automatically using Infrastructure-as-Code (Terraform).

**Key components per tenant**
- **Networking:** Dedicated VPC, public/private subnets, route tables, optional NAT.
- **Compute:** One or more EC2 instances (demo), can be migrated to autoscaled fleets or containers.
- **DNS:** Tenant DNS entries (e.g. tenant.duckdns.org) managed externally (DuckDNS used in demo).
- **SSL/TLS:** Accepts customer-provided certificates (PEM + KEY) or auto-generates a self-signed certificate for demo.
- **Secrets:** Private SSH key stored in Secrets Manager (or equivalent).

---

## 2. Architecture Diagram

A simple visual (also included in the repo as `architecture.svg`):

```
                        ┌─────────────────────────────┐
                        │   Public Internet            │
                        └─────────────┬───────────────┘
                                      │ HTTPS
                          DNS: tenant.duckdns.org
                                      │
                     ┌────────────────▼────────────────┐
                     │     Tenant VPC (10.0.0.0/16)    │
                     └─────────────┬───────────────┘
                                   │
                     ┌────────────▼─────────────┐
                     │      Public Subnets      │
                     │ (10.0.1.0/24, 10.0.2.0/24)│
                     └─────────────┬────────────┘
                                   │
                    ┌──────────────▼──────────────┐
                    │    EC2 Instance (Nginx)     │
                    │ Generates or uploads SSL    │
                    │ Runs containerized app      │
                    └──────────────┬──────────────┘
```

---

## 3. Tenant Onboarding Process

**Steps for customers**
1. Submit a tenant request with required fields:
   - Tenant name (e.g., `tenant21`)
   - SSH allowed CIDR (e.g., `203.0.113.4/32`)
   - Instance size preference (optional)
   - Optionally provide SSL certificate files (PEM + KEY)
2. The operations team validates the request and creates a tenant entry in `tenants` variable for Terraform.
3. Terraform is executed to provision resources.
4. System updates DNS (DuckDNS in demo) and the site becomes available.

**Estimated provisioning time**
- Typical: **5–10 minutes** (Terraform plan + apply, instance boot, Nginx startup, DNS update).
- Factors affecting time: AMI retrieval, network slowness, cloud provider rate limits.

---

## 4. Tenant Isolation

**Isolation guarantees in this design**
- **Network isolation:** Each tenant gets a dedicated VPC (no peering by default).
- **Compute isolation:** Tenant workloads run on tenant-dedicated EC2 instances.
- **Secrets isolation:** Private keys and secrets stored per-tenant in Secrets Manager.
- **Access control:** SSH restricted via per-tenant security group CIDR rules.

**Shared vs. Dedicated resource tiers**
- **Dedicated tier (demo default):** Strong isolation, recommended for regulated or high-security tenants.
- **Shared tier (optional future):** Shared load balancer and multi-tenant backends to reduce costs for low-risk customers.

---

## 5. DNS Propagation & What Customers Need To Know

**DNS provider (demo):** DuckDNS (public free provider). In production, we recommend Route53 or other enterprise DNS.

**Propagation expectations**
- DNS change (DuckDNS update): usually visible within seconds to a few minutes.
- Certificate availability: If you provided your own cert, TLS is immediate after apply. If system generates self-signed cert, it’s created during provisioning (~seconds).

**Validation checks**
- Run: `nslookup <tenant>.duckdns.org`
- Check HTTP headers: `curl -I https://<tenant>.duckdns.org`

---

## 6. Scaling & Production Considerations

**Demo defaults**
- Single EC2 instance per tenant (t2.micro by default).
- Not designed for high-traffic production workloads.

**Production scaling roadmap**
1. **Stateless workloads** → Move to Auto Scaling Groups + Application Load Balancer (ALB).
2. **Containerization** → Migrate app to EKS for easier horizontal scaling.
3. **Database & Storage** → Use managed DB services (RDS/Aurora), S3 for object storage, and EBS for persistent volumes.
4. **Multi-AZ and Multi-Region** → Deploy across AZs for HA; use multi-region for DR.
5. **Observability** → Centralized logs (CloudWatch/ELK), metrics (Prometheus/Grafana), and tracing.
6. **Network** -> create the resources in private subnet

**High-traffic tenant pattern**
- Fronted by ALB + autoscaling instances or container replicas.
- Use caching (CDN) to reduce origin load.

---

## 7. Limitations (Demo vs Production)

- **Single-instance demo**: No HA, limited throughput.
- **Self-signed certs fallback**: For production, replace with CA-signed certs (ACM or Let's Encrypt).
- **DuckDNS**: Suitable for PoC only — use enterprise DNS (Route53, Cloudflare) in prod.
- **Manual scaling**: Autoscaling not included in demo; production must add ASG or container orchestration.

---

## 8. FAQs

**Q: Can I bring my own SSL certificate?**  
A: Yes — provide PEM and KEY during the tenant request. The provisioning process will upload and use them.

**Q: How long will provisioning take?**  
A: ~5–10 minutes typically.

**Q: What happens if my tenant needs more compute resources?**  
A: You can request instance type change or choose autoscaling production tier; we will schedule a migration/resize.

**Q: Can I access my environment using VPN?**  
A: For demo, direct SSH from allowed CIDR is supported. For production, we support site-to-site VPN solutions using vgw .

**Q: Is my data isolated from other customers?**  
A: Yes — VPC-level isolation and per-tenant resource boundaries ensure separation.

---

## 9. Assumptions & Trade-offs

- **EC2 chosen for demo**: faster to get working PoC. Trade-off: less flexible than containers for scaling.
- **Per-tenant VPC**: stronger isolation, increased operational overhead. Trade-off: easier security compliance.
- **DuckDNS**: used to avoid DNS provisioning complexity for demo; replace with Route53 in production.
- **Secrets Manager**: used for private keys; in production add KMS key policy and rotation.

---

## 10. Deliverables Included

1. Terraform repository with `modules/tenant` and sample `tenants` map.  
2. Customer-facing documentation (this file).  
3. Suggested script for Loom demo and screenshots.

---

