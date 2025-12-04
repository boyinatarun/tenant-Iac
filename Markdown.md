# Multi-Tenant Platform - Customer Documentation

## 📐 High-Level Architecture

### Architecture Overview

Our platform provides **complete tenant isolation** through dedicated infrastructure components:

```
┌─────────────────────────────────────────────────────────────┐
│                    Internet / DNS Layer                      │
│                    (DuckDNS Routing)                         │
└────────────┬────────────────────────────────┬───────────────┘
             │                                │
    ┌────────▼─────────┐            ┌────────▼─────────┐
    │   Tenant20 VPC   │            │   Tenant21 VPC   │
    │  (10.1.0.0/16)   │            │  (10.2.0.0/16)   │
    │                  │            │                  │
    │  ┌────────────┐  │            │  ┌────────────┐  │
    │  │   EC2      │  │            │  │   EC2      │  │
    │  │  Instance  │  │            │  │  Instance  │  │
    │  │            │  │            │  │            │  │
    │  │  • Nginx   │  │            │  │  • Nginx   │  │
    │  │  • SSL/TLS │  │            │  │  • SSL/TLS │  │
    │  │  • App     │  │            │  │  • App     │  │
    │  └────────────┘  │            │  └────────────┘  │
    │                  │            │                  │
    │  ┌────────────┐  │            │  ┌────────────┐  │
    │  │  Security  │  │            │  │  Security  │  │
    │  │   Group    │  │            │  │   Group    │  │
    │  └────────────┘  │            │  └────────────┘  │
    │                  │            │                  │
    │  ┌────────────┐  │            │  ┌────────────┐  │
    │  │   EBS      │  │            │  │   EBS      │  │
    │  │  Storage   │  │            │  │  Storage   │  │
    │  │ (Encrypted)│  │            │  │ (Encrypted)│  │
    │  └────────────┘  │            │  └────────────┘  │
    └──────────────────┘            └──────────────────┘
```

### Key Components

#### 1. **Network Layer (VPC)**
- Each tenant receives a dedicated Virtual Private Cloud (VPC)
- Completely isolated network space with unique CIDR blocks
- No network connectivity between tenants
- Public and private subnets for layered security

#### 2. **Compute Layer**
- Dedicated EC2 instances per tenant
- Configurable instance types based on workload requirements
- Auto-scaling capabilities (production tier)
- Encrypted root volumes (20GB default, expandable)

#### 3. **DNS & Routing**
- Custom subdomain per tenant (e.g., `yourcompany.duckdns.org`)
- Automatic DNS configuration and updates
- HTTPS enforced with SSL/TLS certificates
- Global DNS propagation (1-5 minutes)

#### 4. **Security Layer**
- Tenant-specific security groups
- Network ACLs for additional isolation
- SSL/TLS encryption for all traffic
- Encrypted storage at rest
- IAM-based access controls

#### 5. **Application Layer**
- Nginx reverse proxy with SSL termination
- Containerized applications (Docker)
- Custom application deployments supported
- Zero-downtime deployment capabilities

### Cloud-Agnostic Design Principles

Our architecture is designed to be **cloud-agnostic** with minimal provider-specific dependencies:

| Component | AWS Implementation | Cloud-Agnostic Alternative |
|-----------|-------------------|----------------------------|
| **Networking** | VPC, Subnets | Virtual Networks (Azure), VPC (GCP) |
| **Compute** | EC2 | Virtual Machines (Azure), Compute Engine (GCP) |
| **Storage** | EBS | Managed Disks (Azure), Persistent Disks (GCP) |
| **DNS** | DuckDNS (External) | Any DNS provider (CloudFlare, Route53) |
| **Load Balancing** | Nginx (Self-hosted) | Any reverse proxy/LB solution |
| **Orchestration** | Terraform | Terraform (multi-cloud support) |

**Note:** While this demo uses AWS, the modular Terraform design allows migration to other cloud providers with minimal code changes (primarily in the `modules/` directory).

---

## 🚀 Onboarding New Tenants

### How to Request Onboarding

#### Step 1: Submit Request
Contact our DevOps team with the following information:
- **Company Name**: Your organization name
- **Preferred Subdomain**: Desired subdomain (e.g., `acmecorp`)
- **Instance Size**: Workload requirements (we'll recommend appropriate sizing)
- **Custom Domain** (Optional): If you want to use your own domain
- **SSL Certificate** (Optional): Bring your own certificate if needed
- **Compliance Requirements**: Any specific compliance needs (HIPAA, SOC2, etc.)

#### Step 2: Configuration Review
Our team will:
1. Review your requirements
2. Provision your isolated environment
3. Configure DNS routing
4. Set up SSL certificates
5. Deploy your application

#### Step 3: Environment Delivery
You'll receive:
- **Access URL**: `https://yourcompany.duckdns.org`
- **SSH Access** (if requested): Private key and connection instructions
- **Admin Dashboard**: Management interface credentials
- **API Keys**: For programmatic access
- **Monitoring**: Access to your environment metrics

### Provisioning Timeline

| Phase | Duration | Details |
|-------|----------|---------|
| **Request Review** | 1-2 hours | Business hours only |
| **Infrastructure Provisioning** | 5-10 minutes | Automated via Terraform |
| **DNS Propagation** | 1-5 minutes | Global DNS updates |
| **Application Deployment** | 5-15 minutes | Depends on complexity |
| **Testing & Validation** | 15-30 minutes | Our QA process |
| **Total Time** | **2-4 hours** | From request to delivery |

**Expedited Onboarding**: Available for enterprise customers (under 1 hour)

### Self-Service Onboarding (Enterprise Tier)

Enterprise customers can use our **self-service portal**:
1. Log in to the customer portal
2. Click "New Environment"
3. Configure tenant settings
4. Submit for automatic provisioning
5. Receive access details via email

---

## 🔒 Tenant Isolation

### Network Isolation

#### VPC-Level Isolation
- Each tenant operates in a completely separate VPC
- No direct network connectivity between tenants
- Unique CIDR blocks prevent IP conflicts
- Separate routing tables and gateways

#### Security Groups
- Tenant-specific firewall rules
- Only necessary ports exposed (80, 443, 22)
- Ingress/egress rules strictly controlled
- No cross-tenant communication allowed

#### Network ACLs
- Additional stateless firewall layer
- Defense-in-depth security model
- Protocol-level filtering
- DDoS mitigation capabilities

### Compute Isolation

#### Dedicated Resources
- **No resource sharing** between tenants
- Dedicated CPU, memory, and storage
- Guaranteed performance (no "noisy neighbor" effect)
- Configurable instance types per tenant

#### Storage Isolation
- Encrypted EBS volumes per tenant
- Separate storage accounts
- Automated backups (production tier)
- No shared storage volumes

### Data Isolation

#### At Rest
- AES-256 encryption for all storage
- Tenant-specific encryption keys (production tier)
- Encrypted database volumes
- Secure key management (AWS KMS)

#### In Transit
- TLS 1.2+ for all connections
- End-to-end encryption
- Certificate pinning available
- Secure API communications

### Shared vs. Dedicated Resource Tiers

We offer flexible resource allocation models:

#### **Starter Tier** (Shared Infrastructure)
- Shared control plane
- Dedicated VPC and compute
- Shared monitoring and logging
- Best for: Development, testing, small workloads
- **Cost**: $X/month

#### **Professional Tier** (Hybrid)
- Dedicated VPC and compute
- Dedicated database instances
- Shared Kubernetes cluster (dedicated namespaces)
- Isolated storage
- Best for: Production workloads, growing businesses
- **Cost**: $Y/month

#### **Enterprise Tier** (Fully Dedicated)
- Dedicated VPC, compute, storage
- Dedicated Kubernetes cluster
- Dedicated monitoring stack
- Custom security controls
- SLA guarantees
- Best for: Large enterprises, compliance requirements
- **Cost**: Custom pricing

### Isolation Guarantees

| Aspect | Starter | Professional | Enterprise |
|--------|---------|--------------|------------|
| **Network** | ✅ Isolated | ✅ Isolated | ✅ Isolated |
| **Compute** | ✅ Isolated | ✅ Isolated | ✅ Isolated |
| **Storage** | ✅ Isolated | ✅ Isolated | ✅ Isolated |
| **Database** | ⚠️ Shared | ✅ Isolated | ✅ Isolated |
| **Control Plane** | ⚠️ Shared | ⚠️ Shared | ✅ Isolated |
| **Monitoring** | ⚠️ Shared | ⚠️ Shared | ✅ Isolated |

---

## 🌐 DNS Propagation

### How DNS Works in Our Platform

When we provision your tenant:
1. **Record Creation**: We create a DNS A record pointing your subdomain to your instance IP
2. **DuckDNS Update**: Changes propagate through DuckDNS infrastructure
3. **Global Distribution**: DNS updates spread to global resolvers
4. **Client Cache**: Your browser/system DNS cache updates

### Expected Timing

| Stage | Duration | Details |
|-------|----------|---------|
| **Initial Setup** | Instant | Record created in our system |
| **DuckDNS Propagation** | 10-60 seconds | DuckDNS updates their servers |
| **ISP DNS Caching** | 1-5 minutes | Your ISP's DNS updates |
| **Local DNS Cache** | 0-5 minutes | Your device's DNS cache |
| **Total Time** | **1-5 minutes** | Usually under 2 minutes |

### Validation Steps

#### 1. Check DNS Resolution
```bash
# Linux/Mac
nslookup yourcompany.duckdns.org

# Windows
nslookup yourcompany.duckdns.org

# Should return your instance IP address
```

#### 2. Test with Different DNS Servers
```bash
# Google DNS
nslookup yourcompany.duckdns.org 8.8.8.8

# Cloudflare DNS
nslookup yourcompany.duckdns.org 1.1.1.1
```

#### 3. Browser Test
```
https://yourcompany.duckdns.org
```

### Troubleshooting DNS Issues

#### Problem: "Cannot resolve hostname"
**Solutions:**
- Wait 2-3 more minutes for propagation
- Clear your DNS cache:
  ```bash
  # Windows
  ipconfig /flushdns
  
  # Mac
  sudo dscacheutil -flushcache
  
  # Linux
  sudo systemd-resolve --flush-caches
  ```
- Try accessing via direct IP (temporary workaround)

#### Problem: "Old IP address returned"
**Cause:** DNS caching from previous deployment

**Solutions:**
- Clear local DNS cache (see above)
- Wait for TTL expiration (60 seconds for DuckDNS)
- Use incognito/private browsing mode

#### Problem: "Works on some devices, not others"
**Cause:** Different DNS cache states

**Solutions:**
- Each device needs DNS cache cleared individually
- Wait for natural cache expiration (5 minutes max)

### DNS Best Practices

1. **Bookmark IP address** initially, switch to domain once verified
2. **Clear DNS cache** if you encounter issues
3. **Test from multiple locations** to verify global propagation
4. **Use monitoring tools** to track DNS health
5. **Report persistent issues** (> 10 minutes) to support

---

## 📈 Scaling & Production Considerations

### Current Demo Limitations vs. Production

| Feature | Demo Environment | Production Environment |
|---------|------------------|------------------------|
| **SSL Certificates** | Self-signed | Let's Encrypt / Custom CA |
| **High Availability** | Single AZ | Multi-AZ deployment |
| **Auto-Scaling** | Manual | Automatic based on metrics |
| **Load Balancing** | Single instance | Application Load Balancer |
| **Database** | On-instance | Managed RDS/Aurora |
| **Monitoring** | Basic logging | CloudWatch + Datadog/NewRelic |
| **Backup** | Manual | Automated daily backups |
| **Disaster Recovery** | None | Multi-region replication |
| **CDN** | None | CloudFront distribution |
| **WAF** | None | AWS WAF / CloudFlare |

### Scaling Strategy for High-Traffic Tenants

#### Phase 1: Vertical Scaling (Quick wins)
- **Upgrade instance type**: t2.micro → t3.large → t3.xlarge
- **Increase storage**: 20GB → 100GB+ SSD
- **Optimize application**: Caching, connection pooling
- **Timeline**: 5-10 minutes (requires restart)
- **Cost**: Linear increase with instance size

#### Phase 2: Horizontal Scaling (Medium-term)
- **Multiple instances**: Behind load balancer
- **Auto-scaling groups**: Scale based on CPU/memory/requests
- **Database separation**: Dedicated RDS instance
- **Redis/ElastiCache**: For session management
- **Timeline**: 2-4 hours for initial setup
- **Cost**: 2-5x base cost depending on scale

#### Phase 3: Advanced Architecture (Long-term)
- **Kubernetes deployment**: Container orchestration
- **Microservices**: Break monolith into services
- **Service mesh**: Istio/Linkerd for traffic management
- **Multi-region**: Global presence
- **Timeline**: 2-4 weeks for migration
- **Cost**: Custom based on requirements

### Capacity Planning

#### Traffic Tiers

**Low Traffic** (< 1000 requests/day)
- Instance: t3.micro
- Estimated capacity: 10 concurrent users
- Cost: ~$10/month

**Medium Traffic** (1K-100K requests/day)
- Instance: t3.small - t3.medium
- Estimated capacity: 50-200 concurrent users
- Cost: ~$30-100/month

**High Traffic** (100K-1M requests/day)
- Instance: t3.large - t3.xlarge + auto-scaling
- Estimated capacity: 500-2000 concurrent users
- Cost: ~$200-500/month

**Enterprise Scale** (> 1M requests/day)
- Custom architecture with load balancing
- Estimated capacity: 5000+ concurrent users
- Cost: Custom pricing (starting $1000/month)

### Production-Grade Evolution Roadmap

#### Quarter 1: Foundation
- [ ] Implement Let's Encrypt for SSL
- [ ] Set up CloudWatch monitoring
- [ ] Configure automated backups
- [ ] Deploy to multiple AZs
- [ ] Implement health checks

#### Quarter 2: Reliability
- [ ] Add Application Load Balancer
- [ ] Implement auto-scaling groups
- [ ] Set up RDS with read replicas
- [ ] Configure CloudFront CDN
- [ ] Implement disaster recovery

#### Quarter 3: Security & Compliance
- [ ] Deploy AWS WAF
- [ ] Implement VPN access
- [ ] Set up AWS GuardDuty
- [ ] Enable VPC Flow Logs
- [ ] SOC2/ISO27001 compliance

#### Quarter 4: Advanced Features
- [ ] Kubernetes migration
- [ ] Multi-region deployment
- [ ] Advanced observability (Datadog)
- [ ] CI/CD pipelines
- [ ] Blue-green deployments

---

## ⚠️ Current Limitations

### Demo Environment Constraints

#### 1. SSL Certificates
**Limitation**: Self-signed certificates require manual browser acceptance

**Impact**: 
- Browser security warnings
- Not suitable for public-facing production
- No certificate trust chain

**Mitigation**:
- Use for internal testing only
- Production uses Let's Encrypt or commercial certificates

#### 2. Single Availability Zone
**Limitation**: All resources in one AZ

**Impact**:
- No redundancy if AZ fails
- Maintenance requires downtime
- Not suitable for mission-critical apps

**Mitigation**:
- Production spans multiple AZs
- Enterprise tier has 99.99% SLA

#### 3. Manual Scaling
**Limitation**: No auto-scaling configured

**Impact**:
- Manual intervention needed for traffic spikes
- Potential performance degradation under load
- No automatic failover

**Mitigation**:
- Monitor traffic patterns
- Plan capacity upgrades
- Production includes auto-scaling

#### 4. Basic Monitoring
**Limitation**: Limited to basic AWS CloudWatch metrics

**Impact**:
- No application-level insights
- Reactive rather than proactive monitoring
- Limited debugging capabilities

**Mitigation**:
- Upgrade to Professional tier for enhanced monitoring
- Enterprise tier includes full observability stack

#### 5. Network Security
**Limitation**: Simplified security group rules

**Impact**:
- Port 22 (SSH) exposed to internet
- No Web Application Firewall (WAF)
- Basic DDoS protection

**Mitigation**:
- Production uses bastion hosts
- WAF deployed in higher tiers
- Advanced DDoS protection available

#### 6. Backup & Recovery
**Limitation**: No automated backup system

**Impact**:
- Manual backup procedures required
- No point-in-time recovery
- Extended recovery time

**Mitigation**:
- Manual snapshots recommended
- Production includes automated daily backups
- Enterprise tier has continuous backup

#### 7. DNS Provider
**Limitation**: DuckDNS free service

**Impact**:
- No SLA guarantees
- Limited to DuckDNS subdomains
- No advanced DNS features

**Mitigation**:
- Use for demos and testing
- Production supports custom domains
- Route53/CloudFlare available for production

### Production Readiness Checklist

To move from demo to production, address:

- [ ] **SSL**: Implement Let's Encrypt or commercial certificates
- [ ] **High Availability**: Multi-AZ deployment
- [ ] **Monitoring**: Full observability stack (CloudWatch + Datadog)
- [ ] **Security**: WAF, GuardDuty, Security Hub
- [ ] **Backup**: Automated daily backups with retention policy
- [ ] **Networking**: Private subnets, NAT gateways, bastion hosts
- [ ] **DNS**: Custom domain with Route53 or CloudFlare
- [ ] **Scaling**: Auto-scaling groups configured
- [ ] **Database**: Separate RDS instance with replicas
- [ ] **CI/CD**: Automated deployment pipelines
- [ ] **Compliance**: SOC2, HIPAA, or required certifications
- [ ] **Documentation**: Runbooks and incident response plans

---

## ❓ Frequently Asked Questions

### General Questions

#### Q: Can I bring my own SSL certificate?
**A:** Yes! We support:
- **Self-signed certificates** (demo/development)
- **Let's Encrypt** (automatic renewal, production recommended)
- **Commercial certificates** (Digicert, GlobalSign, etc.)
- **Extended Validation (EV)** certificates for enterprise

**Process:**
1. Provide certificate file (.crt/.pem)
2. Provide private key (securely encrypted)
3. Provide certificate chain (if applicable)
4. We'll deploy within 1 business day

**Cost:** No additional charge for certificate deployment

---

#### Q: How long will provisioning take?
**A:** Provisioning timelines vary by tier:

| Tier | Infrastructure | Full Deployment | Details |
|------|---------------|-----------------|---------|
| **Starter** | 5-10 min | 2-4 hours | Automated provisioning |
| **Professional** | 10-15 min | 3-6 hours | Includes database setup |
| **Enterprise** | 15-30 min | 1-2 days | Custom configuration |

**Factors affecting timing:**
- Business hours vs. after hours
- Complexity of application
- Custom requirements
- Compliance validation needed

---

#### Q: What happens if my tenant needs more compute resources?
**A:** We offer flexible scaling options:

**Immediate (within 5-10 minutes):**
- Vertical scaling: Upgrade instance type
- Requires brief downtime (2-5 minutes)
- Available 24/7 for enterprise customers

**Planned (within 1-2 hours):**
- Horizontal scaling: Add more instances
- Zero-downtime deployment
- Load balancer configuration
- Requires 1 business day notice

**Process:**
1. Submit scaling request via portal or email
2. We review resource requirements
3. Execute during your maintenance window (or off-peak)
4. Validate performance post-scaling
5. Monitor for 24 hours

**Cost:** 
- Vertical scaling: Pay for new instance type
- Horizontal scaling: Pay per additional instance
- No scaling fees or penalties

---

#### Q: Can I access my environment using VPN?
**A:** Yes, VPN access is available:

**Site-to-Site VPN** (Professional/Enterprise)
- Connect your office network to your tenant VPC
- IPsec VPN tunnels
- Setup time: 2-4 hours
- Cost: $50/month + $0.05/GB transfer

**Client VPN** (Enterprise only)
- Individual user access via OpenVPN
- Multi-factor authentication supported
- Access control per user
- Setup time: 4-8 hours
- Cost: $100/month + $5/user/month

**Bastion Host** (All tiers)
- SSH jump server for secure access
- Key-based authentication
- Session recording available
- Setup time: 30 minutes
- Cost: Included in all tiers

**Direct Connect** (Enterprise only)
- Dedicated network connection
- Lower latency, higher bandwidth
- Setup time: 2-4 weeks
- Cost: Custom pricing

---

#### Q: Is my data isolated from other customers?
**A:** Absolutely. We implement multiple layers of isolation:

**Network Isolation:**
- Separate VPC per tenant (no shared network)
- Unique IP ranges (no conflicts possible)
- Separate routing tables
- No cross-tenant traffic allowed

**Compute Isolation:**
- Dedicated EC2 instances (no sharing)
- No "noisy neighbor" effects
- Guaranteed CPU/memory allocation
- Separate security groups per tenant

**Storage Isolation:**
- Dedicated EBS volumes per tenant
- Encrypted at rest (AES-256)
- Tenant-specific encryption keys available
- No shared storage volumes

**Data Isolation:**
- Logical separation in databases
- Separate database instances (Professional+)
- Row-level security where applicable
- Automated data segregation

**Access Isolation:**
- Separate IAM roles per tenant
- No cross-tenant API access
- Audit logging per tenant
- Isolated SSH keys

**Compliance:**
- GDPR compliant data handling
- SOC2 Type II certified (Enterprise)
- HIPAA compliant architecture available
- Regular third-party security audits

**Verification:** We provide quarterly isolation reports to enterprise customers showing complete network and data segregation.

---

### Technical Questions

#### Q: What operating system is used?
**A:** Ubuntu Server 22.04 LTS (Jammy)
- 5 years of security updates
- Well-documented and widely supported
- Compatible with most applications

Other options available: Amazon Linux 2, RHEL, Debian

---

#### Q: Can I install custom software?
**A:** Yes! You have full control:

**Starter Tier:**
- SSH access with sudo privileges
- Install any packages via apt/yum
- Docker available for containerized apps

**Professional/Enterprise:**
- Same as Starter, plus:
- Configuration management (Ansible/Chef)
- Custom AMI support
- Pre-installed software bundles

**Restrictions:**
- No cryptocurrency mining
- No malicious software
- Comply with AWS acceptable use policy

---

#### Q: How do I deploy my application?
**A:** Multiple deployment methods supported:

**Method 1: SSH + Manual Deployment**
```bash
ssh ubuntu@your-tenant.duckdns.org
git clone your-repo
docker-compose up -d
```

**Method 2: CI/CD Pipeline** (Recommended)
- GitHub Actions / GitLab CI
- Automatic deployment on push
- We provide pipeline templates

**Method 3: Docker Registry**
- Push images to Docker Hub / ECR
- We pull and deploy automatically

**Method 4: Terraform / IaC**
- Infrastructure as code for your app
- Version controlled deployments

---

#### Q: What about database support?
**A:** Database options by tier:

**Starter:**
- Docker-based databases (PostgreSQL, MySQL, MongoDB)
- On-instance installation
- Manual backups

**Professional:**
- Managed RDS (PostgreSQL, MySQL, MariaDB)
- Automated backups (7-day retention)
- Point-in-time recovery

**Enterprise:**
- Amazon Aurora (99.99% availability)
- Read replicas for scalability
- Cross-region replication
- 35-day backup retention

---

#### Q: How is monitoring handled?
**A:** Monitoring capabilities by tier:

**Starter:**
- AWS CloudWatch basic metrics
- CPU, Memory, Disk, Network
- Email alerts for critical issues

**Professional:**
- Enhanced CloudWatch metrics
- Application performance monitoring
- Custom dashboards
- Slack/PagerDuty integration

**Enterprise:**
- Full observability stack (Datadog/NewRelic)
- Distributed tracing
- Log aggregation and search
- Custom SLIs/SLOs
- Dedicated SRE support

---

### Billing & Support

#### Q: How am I billed?
**A:** Transparent, usage-based billing:

**Monthly Base Fee:**
- Starter: $50/month per tenant
- Professional: $200/month per tenant
- Enterprise: Custom pricing

**Additional Usage Charges:**
- Data transfer: $0.09/GB (first 10GB free)
- Extra storage: $0.10/GB/month
- Additional compute: Per instance hour
- Backup storage: $0.05/GB/month

**Billing Cycle:**
- Monthly in advance
- Accepted payments: Credit card, ACH, wire transfer
- Enterprise: Annual contracts available (10% discount)

---

#### Q: What support is included?
**A:** Support levels by tier:

**Starter:**
- Email support (business hours)
- Response time: 24 hours
- Community forum access

**Professional:**
- Email + Chat support (business hours)
- Response time: 4 hours
- Phone support available
- Monthly check-in calls

**Enterprise:**
- 24/7 phone + email support
- Response time: 1 hour (critical), 4 hours (non-critical)
- Dedicated account manager
- Quarterly business reviews
- Custom SLA available

---

#### Q: Can I change tiers later?
**A:** Yes, upgrading/downgrading is straightforward:

**Upgrading:**
- Instant online upgrade
- Pro-rated billing for current month
- Zero downtime migration
- New features available immediately

**Downgrading:**
- Requires 30-day notice
- Data export assistance provided
- Graceful migration to lower tier
- Refund of unused time

---

## 📊 Assumptions & Trade-offs

### Assumptions Made

#### Infrastructure Assumptions
1. **AWS as Primary Cloud**: Demo uses AWS for initial implementation
   - **Rationale**: Widest adoption, comprehensive services, mature ecosystem
   - **Future**: Architecture supports Azure, GCP, or on-premise deployment

2. **Public Internet Access**: Tenants accessed via public internet
   - **Rationale**: Simplifies demo, covers 80% of use cases
   - **Future**: VPN/Direct Connect available for enterprise

3. **DuckDNS for DNS**: Using free DuckDNS service
   - **Rationale**: Cost-effective for demo, no domain purchase needed
   - **Future**: Production uses Route53, CloudFlare, or custom domains

4. **Self-Signed SSL**: Demo uses self-signed certificates
   - **Rationale**: Immediate deployment, no certificate authority needed
   - **Future**: Let's Encrypt or commercial certificates in production

5. **Single Region**: All resources in one AWS region
   - **Rationale**: Reduces complexity and cost for demo
   - **Future**: Multi-region deployment for high availability

#### Security Assumptions
1. **Basic Security Groups**: Simplified firewall rules
   - **Rationale**: Demo-friendly, easy to understand
   - **Trade-off**: Production requires stricter rules

2. **SSH Public Access**: Port 22 open to internet (with key auth)
   - **Rationale**: Direct access for troubleshooting
   - **Trade-off**: Production uses bastion hosts

3. **No WAF Deployed**: Web Application Firewall not included
   - **Rationale**: Additional cost and complexity
   - **Trade-off**: Production needs WAF for security

#### Operational Assumptions
1. **Manual Scaling**: No auto-scaling configured initially
   - **Rationale**: Cost control, predictable resource usage
   - **Trade-off**: Requires monitoring and manual intervention

2. **Basic Monitoring**: CloudWatch default metrics only
   - **Rationale**: Included free with AWS
   - **Trade-off**: Limited visibility into application performance

3. **No Disaster Recovery**: Single AZ deployment
   - **Rationale**: Acceptable for non-critical demos
   - **Trade-off**: Downtime during AZ outages

### Key Trade-offs Explained

#### Trade-off 1: S3 vs. EBS for Storage

**Decision**: Using EBS (Block Storage)

**Reasoning:**
- **For**: Direct attachment to instances, better performance for databases, simpler for demo
- **Against S3**: Requires application changes, eventual consistency, more complex for structured data
- **Best Use**: S3 for object storage (backups, logs), EBS for live data

**Production Consideration**: Hybrid approach with EBS for databases, S3 for static assets and backups

---

#### Trade-off 2: Ingress Controller vs. Nginx Reverse Proxy

**Decision**: Using Nginx Reverse Proxy

**Reasoning:**
- **For**: Simpler setup, well-understood, works without Kubernetes, lower resource overhead
- **Against Ingress**: Requires Kubernetes, more complex configuration, heavier resource usage
- **Best Use**: Nginx for single-instance deployments, Ingress for Kubernetes

**Production Consideration**: Migrate to Kubernetes + Ingress controller for multi-service applications

---

#### Trade-off 3: Dedicated VPC vs. Shared VPC with Isolated Subnets

**Decision**: Dedicated VPC per Tenant

**Reasoning:**
- **For**: Maximum isolation, clearer security boundaries, separate route tables, easier compliance
- **Against Shared**: More AWS resources (VPC limits: 5 default, 100 max), slightly higher cost, more complex networking
- **Security**: Dedicated VPC provides strongest isolation guarantee

**Cost Impact**: ~$5/month per VPC for NAT Gateway (if used)

**Production Consideration**: Cost-effective at scale, justifiable for enterprise customers

---

#### Trade-off 4: DuckDNS vs. Route53 vs. Custom Domain

**Decision**: DuckDNS for Demo

**Reasoning:**
- **For**: Free, no domain purchase needed, instant setup, API-based updates
- **Against Route53**: Requires AWS account configuration, ~$0.50/month per hosted zone
- **Against Custom Domain**: Requires domain ownership, DNS configuration knowledge

**Limitations**: 
- DuckDNS subdomains only (no full custom domains)
- No SLA guarantees
- Limited to 5 subdomains per token (free tier)

**Production Path**: 
- Professional tier: Route53 with custom domain support
- Enterprise tier: Multi-domain support with AWS ACM certificates

---

#### Trade-off 5: EC2 vs. Fargate vs. Kubernetes

**Decision**: EC2 Instances

**Reasoning:**
- **For**: Full control,