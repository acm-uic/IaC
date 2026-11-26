# North Central US monthly estimate

**$13.64/month fixed, approximately $13.68/month at the example usage below.** USD pay-as-you-go retail, checked November 25, 2026. This is the incremental cost of adding Umapyoi's gateway to the existing subscription, vault, DNS zone and cluster. A 730-hour month is used for planning. The Microsoft Azure Sponsorship offer may change the invoiced amount.

| Resource or meter | Quantity and retail rate | Monthly USD |
| --- | --- | ---: |
| Linux Standard_B1s | 730 hours × $0.0104 | 7.592 |
| 32 GiB Standard SSD, E4 LRS OS disk | 1 × $2.40 | 2.40 |
| Standard regional static public IPv4 | 730 hours × $0.005 | 3.65 |
| Standard static public IPv6 | 1, free | 0 |
| VNet, subnet, NIC, NSG, managed identity | Included | 0 |
| **Fixed subtotal** | | **13.642** |
| Standard SSD operations | Example 100,000 billable operations × $0.002/10,000 | 0.020 |
| Key Vault Standard secret operations | Example 100 operations × $0.03/10,000 | 0.0003 |
| Existing Azure public DNS zone | Example 50,000 extra queries × $0.40/million | 0.020 |
| Internet outbound | Example 10 GB, with at least 10 GB of the shared free allowance left | 0 |
| **Example total** | | **13.6823** |

These quantities are assumptions. Each request can generate Azure egress on the tunnel leg as well as on the public response leg. Include both in metered traffic. The first 100 GB/month of internet egress is free across eligible usage. At the next North America tier, 50 GB beyond the remaining allowance adds $4.35. The existing zone has no incremental zone fee. The record-set estimate assumes the zone stays in its first 10,000 record sets. An optional resource-group budget can notify recipients at 90% of the configured amount. It cannot cap spending, and shared DNS or vault charges can fall outside its scope. [Azure bandwidth](https://azure.microsoft.com/en-us/pricing/details/bandwidth/) · [Public IPv6 pricing](https://learn.microsoft.com/en-us/azure/virtual-network/ip-services/ipv6-overview#pricing) · [DNS pricing](https://azure.microsoft.com/en-us/pricing/details/dns/)

Before apply, rerun the meter lookups below with the reviewed region and SKU and replace the usage assumptions with the site's expected volumes. Use the Linux on-demand meter, a single non-shared E4 LRS disk and a regional public IPv4. The public IP stays allocated during a VM shutdown. The baseline has no load balancer, NAT gateway or dedicated monitoring service. [Retail Prices API](https://learn.microsoft.com/en-us/rest/api/cost-management/retail-prices/azure-retail-prices) · [Disk billing](https://learn.microsoft.com/en-us/azure/virtual-machines/disks-understand-billing)

```bash
region=northcentralus
for meter in "armSkuName eq 'Standard_B1s'" \
  "productName eq 'Standard SSD Managed Disks' and skuName eq 'E4 LRS'" \
  "productName eq 'IP Addresses' and skuName eq 'Standard'" \
  "serviceName eq 'Key Vault' and skuName eq 'Standard'"; do
  curl -fsSG --retry 3 'https://prices.azure.com/api/retail/prices' \
    --data-urlencode "\$filter=priceType eq 'Consumption' and armRegionName eq '$region' and $meter" |
    jq -r '.Items[] | [.productName,.meterName,.retailPrice,.unitOfMeasure] | @tsv'
done
```
