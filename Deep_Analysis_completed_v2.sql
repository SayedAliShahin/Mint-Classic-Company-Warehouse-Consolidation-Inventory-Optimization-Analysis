-- WHere are items stored? if they were rearranged, could a warehouse be eliminated?
-- warehouses total items stored and used capicity
SELECT
    p.warehouseCode,
    w.warehousename,
    SUM(p.quantityInStock) AS total_units,
    MAX(w.warehousepctcap) AS capacity_pct
FROM products p 
join warehouses w 
	on p.warehouseCode = w.warehouseCode
GROUP BY warehouseCode
ORDER BY capacity_pct desc;
-- Warehouse c (west) with half available (50%) and 79380 total items, accounts for highest available capicity. 
-- While warehuuse d (south) is the most used warehouses with 75% occopied and 124880 itmes.

-- best condidiate warehouse for closure
SELECT
    w.warehouseCode,
    SUM(p.quantityInStock) AS current_inventory,
    MAX(w.warehousePctCap) AS current_utilization_pct,
    ROUND(
        SUM(p.quantityInStock) / (MAX(w.warehousePctCap) / 100),
        0
    ) AS estimated_total_capacity,
    100 - MAX(w.warehousePctCap) AS capacity_available_pct,
    ROUND(
        SUM(p.quantityInStock) / (MAX(w.warehousePctCap) / 100)
        - SUM(p.quantityInStock),
        0
    ) AS available_capacity_items
FROM warehouses w
join products p 
	on w.warehouseCode = p.warehouseCode
GROUP BY warehouseCode
order by available_capacity_items desc;
-- Warehouse 'c' with 50% space empty and lowest current inventory items (124880)  is a potentioal closure condidite, 
-- since the total other warehouses available capicity is totaly 202552 
-- which is way higher than warehouse 'c' current inventory to relocate

-- How are inventory numbers related to sales figurs? 
-- Revenue based on each warehouses 
WITH warehouse_analysis AS (
    SELECT
        p.warehouseCode,
        SUM(p.quantityInStock) AS inventory,
        SUM(od.quantityOrdered) AS units_sold,
        SUM(od.quantityOrdered * od.priceEach) AS revenue
    FROM products p
    LEFT JOIN orderdetails od
        ON p.productCode = od.productCode
    GROUP BY p.warehouseCode
)
SELECT
    warehouseCode,
    inventory,
    units_sold,
    revenue
FROM warehouse_analysis
ORDER BY revenue ASC;
-- warehouses 'c' and 'd' has generated the lowest revenue among all, and warehouse 'c' has the lowest current inventory
-- however the warehouse 'd' has the lowest items sold followed by warehouse as the second least itmes sold warehouse 
-- with 22933 itmes sold, selling 600 items less than warehouse 'd' making it the potential closue option


-- are we storing items that are not in cycle or not selling?
-- Are any condidiate for being dropped from the productline?
SELECT
    p.productCode,
    p.productName,
    p.quantityInStock
FROM products p
WHERE p.quantityInStock > 0
AND NOT EXISTS (
    SELECT 1
    FROM orderdetails od
    WHERE od.productCode = p.productCode
)
ORDER BY p.quantityInStock DESC;
-- 1985 Toyota Supra with productcode of S18_3233 sold nothing and has 7733 items in stock, making this product a 
-- good condidiate to review before relocation

-- how many of the not selling product exist in potential closure condidite warehouse
SELECT
    p.productCode,
    p.productName,
    p.quantityInStock,
    w.warehouseCode
FROM products p
join warehouses w
	on p.warehouseCode = w.warehouseCode
WHERE p.productcode = 'S18_3233';
-- Product S18_3233 is unsold with 7733 items in stock storing in warehouse 'b', needs to be evaluated


-- Do inventory counts seem appropriate for each item?
WITH product_sales AS (
    SELECT
        p.productCode,
        p.productName,
        p.warehouseCode,
        p.quantityInStock,
        SUM(od.quantityOrdered) AS total_units_sold
    FROM products p
    JOIN orderdetails od
        ON p.productCode = od.productCode
    JOIN orders o
        ON od.orderNumber = o.orderNumber
    GROUP BY
        p.productCode,
        p.productName,
        p.warehouseCode,
        p.quantityInStock
),
inventory_analysis AS (
    SELECT
        productCode,
        productName,
        warehouseCode,
        quantityInStock,
        total_units_sold,
        ROUND(total_units_sold / 29, 2) AS avg_monthly_sales,
        ROUND(
            quantityInStock /
            NULLIF(total_units_sold / 29, 0), 2
        ) AS inventory_coverage_months
    FROM product_sales
)
SELECT
    productCode,
    productName,
    warehouseCode,
    quantityInStock,
    total_units_sold,
    avg_monthly_sales,
    inventory_coverage_months,
    CASE
        WHEN inventory_coverage_months < 0.70
            THEN 'Understocked'
        WHEN inventory_coverage_months <= 10
            THEN 'Reasonable'
        ELSE 'Overstocked'
    END AS inventory_status
FROM inventory_analysis
ORDER BY inventory_coverage_months;
-- Inventory levels appear significantly misaligned with observed demand, with only one product classified as 
-- understocked and two products within the reasonable range, while the remaining 107 products are classified 
-- as overstocked, including several products holding more than 200 months of inventory coverage; this suggests 
-- substantial excess inventory that may tie up working capital and increase storage costs.


-- How many products and inventory units of each product scale are currently held by each warehouse? 
SELECT 
    p.warehouseCode,
    p.productScale,
    COUNT(p.productCode) AS unique_products,
    SUM(p.quantityInStock) AS total_units
FROM products p
GROUP BY p.warehouseCode, p.productScale
ORDER BY p.warehouseCode, p.productScale;
-- Inventory is highly concentrated in 1:18-scale products, particularly in Warehouses B and C, 
-- which hold 118,929 and 82,016 units respectively. This indicates that the 1:18 product scale 
-- represents a major share of inventory in these warehouses.


-- Can the remaining warehouses absorb warehouse 'c' inventory after closure?
WITH warehouse_capacity AS (
    SELECT
        w.warehouseCode,
        SUM(p.quantityInStock) AS current_inventory,
        MAX(w.warehousePctCap) AS utilization_pct,
        ROUND(
            SUM(p.quantityInStock) / (MAX(w.warehousePctCap) / 100),
            0
        ) AS total_capacity,
        ROUND(
            SUM(p.quantityInStock) / (MAX(w.warehousePctCap) / 100)
            - SUM(p.quantityInStock),
            0
        ) AS available_capacity
    FROM products p
    JOIN warehouses w
        ON p.warehouseCode = w.warehouseCode
    GROUP BY w.warehouseCode
), warehouse_c_inventory AS (
    SELECT
        SUM(quantityInStock) AS inventory_to_relocate
    FROM products
    WHERE warehouseCode = 'c'
)
SELECT
    wc.warehouseCode,
    wc.current_inventory,
    wc.available_capacity,
    wci.inventory_to_relocate,
    ROUND(
        wc.current_inventory + wci.inventory_to_relocate,
        0
    ) AS inventory_after_relocation,
    ROUND(
        (wc.current_inventory + wci.inventory_to_relocate)
        / wc.total_capacity * 100,
        2
    ) AS estimated_utilization_after_relocation
FROM warehouse_capacity wc
CROSS JOIN warehouse_c_inventory wci
WHERE wc.warehouseCode <> 'c'
ORDER BY estimated_utilization_after_relocation;
-- None of the remaining warehouses can absorb Warehouse C's 124,880 units without exceeding their estimated capacity: 
-- Warehouse B would reach 105.17% utilization, while Warehouses A and D would reach 140.28% and 192.99%, respectively. 
-- This indicates that Warehouse C's inventory would need to be substantially reduced or redistributed before closure.



-- Which products from warehouse 'c' should be reviewed before relocation or closure?
WITH product_sales AS (
    SELECT
        p.productCode,
        SUM(od.quantityOrdered) AS total_units_sold
    FROM products p
    JOIN orderdetails od
        ON p.productCode = od.productCode
    JOIN orders o
        ON od.orderNumber = o.orderNumber
    WHERE p.warehouseCode = 'c'
    GROUP BY p.productCode
)
SELECT
    p.productCode,
    p.productName,
    p.quantityInStock,
    COALESCE(ps.total_units_sold, 0) AS total_units_sold,
    ROUND(COALESCE(ps.total_units_sold, 0) / 29, 2) AS avg_monthly_sales,
    CASE
        WHEN COALESCE(ps.total_units_sold, 0) = 0
            THEN 'No recorded sales - review'
        WHEN p.quantityInStock / NULLIF(COALESCE(ps.total_units_sold, 0) / 29, 0) > 10
            THEN 'Overstocked - review for reduction'
        ELSE 'Regular inventory'
    END AS inventory_review_status
FROM products p
LEFT JOIN product_sales ps
    ON p.productCode = ps.productCode
WHERE p.warehouseCode = 'c'
ORDER BY p.quantityInStock DESC;
-- Inventory analysis indicates substantial overstocking, with 23 of 24 reviewed products classified as requiring 
-- inventory reduction and only one within the regular inventory range. Several products hold inventory equivalent 
-- to more than 200 months of average monthly sales, suggesting significant opportunities to reduce inventory before 
-- reallocating stock or closing a warehouse.


-- Where are customers buying products currently assigned to warehouse 'c'?
WITH warehouse_c_products AS (
    SELECT productCode
    FROM products
    WHERE warehouseCode = 'c'
)
SELECT
    c.country,
    c.city,
    COUNT(DISTINCT o.orderNumber) AS total_orders,
    SUM(od.quantityOrdered) AS total_units_sold,
    SUM(od.quantityOrdered * od.priceEach) AS total_revenue
FROM warehouse_c_products wcp
JOIN orderdetails od
    ON wcp.productCode = od.productCode
JOIN orders o
    ON od.orderNumber = o.orderNumber
JOIN customers c
    ON o.customerNumber = c.customerNumber
GROUP BY c.country, c.city
ORDER BY total_orders DESC;
-- Warehouse C's products serve customers across multiple countries and cities, with Madrid and San Rafael 
-- accounting for the highest order volumes; therefore, closing the warehouse may create service risks if 
-- relocated inventory cannot be positioned to maintain the required 24-hour fulfillment standard.


