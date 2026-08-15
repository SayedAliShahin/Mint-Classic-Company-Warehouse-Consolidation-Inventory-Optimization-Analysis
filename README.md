# Mint-Classic-Company Warehouse Consolidation Inventory Optimization Analysis
## Business scenario
Mint Classic Company, a retailer of classic model cars and vehicles is evaluating whether it can close one of its warehouses to reduce operational costs while maintaining sufficient inventory and its regular fulfillment service which they want to shop an order in 24 hours. The main goal of this project is to analyze the inventory and warehouse utilization capacities and identify the best candidate warehouse for closure.
## Skills demonstrated
- SQL Data Analysis
- Exploratory Data Analysis (EDA)
- Inventory Analysis
- Business Problem Solving 
## Tools used
- MySQL
- MySQL Workbench
- Chat GPT

## Summary
Evaluated the feasibility of closing one warehouse by analyzing inventory levels, product demand, warehouse capacity, customer demand, and fulfillment performance. The analysis identified Warehouse C as the strongest closure candidate, while highlighting the inventory reduction and redistribution required to maintain operational capacity and customer service.
## Solution
First of all, **warehouse C emerged as the strongest candidate for consolidation** due to its relatively **low utilization and substantial excess inventory**, operating at only 50% capacity and holding the lowest inventory level among the four warehouses. However, Warehouse C's inventory **cannot be transferred entirely to any single** remaining warehouse without exceeding estimated capacity. Moving its 124,880 units to Warehouse B alone would increase estimated utilization to 105.17%, while transfers to Warehouses A and D would result in substantially higher utilization. While a combination of two warehouses like A and B can make it physically possible for relocation.

On the other hand, its overstocked products should be evaluated for potential inventory reduction before relocation, as **23 out of 24 products reviewed were classified as overstocked**, with several holding more than 200 months of average sales coverage items. **Reducing unnecessary inventory first** would lower the volume requiring relocation. And the remaining stock can then be redistributed across multiple warehouses without exceeding estimated capacity. 

The analysis also indicates that inventory is concentrated in particular product scales, especially **the 1:18 scale**, with Warehouses B and C holding 118,929 and 82,016 units respectively. This concentration should be considered when designing the redistribution plan because transferring large quantities of similar products to already concentrated warehouses could create additional capacity or inventory-management pressures.

Finally, products currently assigned to Warehouse C serve customers across multiple countries and cities, with Madrid and San Rafael representing the largest observed order markets. This geographic dispersion means that inventory redistribution should not be based solely on available warehouse capacity; destination warehouses should also be assessed in terms of their ability to maintain customer service. The business's 24-hour fulfillment requirement makes this particularly important.

## Approach 
Firstly, the warehouse capacity and inventory distribution were analyzed to identify inefficiently utilized facilities. Then inventory levels compared to 29 months of average product demand to identify understocked, reasonable, and overstocked products. Continued to evaluated Warehouse C's inventory composition, excess-stock reduction opportunities, product demand, and customer geography. then, tested whether the remaining warehouses could absorb its inventory individually or collectively. Finally, identified customers in different geographical locations who served by warehouse C to evaluate if the Mint Classic Company can serve their warehouse C respected customers using other warehouses after closure.
