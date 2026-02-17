create database zepto_inventory;
drop table if exists zepto;

create table zepto(
sku_id int auto_increment primary key, -- sku - stock keeping unit 
category varchar(255),
name varchar(255) not null,
MRP decimal(8,2),
discountPercent decimal(8,2),
availableQuantity int,
discountSellingPrice decimal(8,2),
weightInGms int,
outOfStock boolean,
quantity int
);
-- data exploration

-- count of rows
select count(*) from zepto;

-- sample data
select * from zepto limit 10;

-- to check if there is null values for the table
select * from zepto 
where name is not null or
 category is not null or
  MRP is not null or
   discountPercent is not null or
   availableQuantity is not null or
   discountSellingPrice is not null or
   weightInGms is not null or
   outOfStock is not null or
   quantity is not null ;
   
-- different product categories
select distinct category from zepto order by category;

-- products instock vs outofstock
select outofstock,count(sku_id) from zepto
group by outOfStock;

-- product names present in many times
select name,count(sku_id) as "duplicate names" from zepto
group by name having count(sku_id)>1
order by count(sku_id) desc;

-- data cleaning

-- products where price is zero
select * from zepto
where mrp=0 or discountSellingPrice=0;

-- deleting row 3603 as both mrp and discountSP is zero and which is impossible
delete from zepto where sku_id=3603;

-- we are going to convert MRP from paise to rupees
update  zepto set mrp=mrp/100.0,
discountsellingprice=discountsellingprice/100.0;

select * from zepto;

-- find the top 10 value products based on the discount percentage
select distinct name,mrp,discountPercent
from zepto
order by discountPercent desc
limit 10;

-- what are the products with high MRP but out of stock
select distinct name,max(mrp) from zepto
where outOfStock=1
group by name 
order by max(mrp) desc;

-- calculate estimated revenue for each category
select category,sum(discountsellingprice * availablequantity) as total_revenue
from zepto
group by category
order by sum(discountsellingprice * availablequantity);

-- find all the products where mrp is greater than 500 rupees and discount is less than 10%
select distinct name ,discountpercent,mrp from zepto
where mrp>500 and discountPercent<10
order by mrp desc,discountPercent desc;

-- identify the top 5 categories offering the highest average discount percentage
select category,round(avg(discountpercent),2) as average_discount from zepto
group by category
order by average_discount desc
limit 5;

-- find the price per gram for products above 100g and sort by best value
select distinct name,weightInGms,discountSellingPrice, round(discountSellingPrice/weightInGms,2) as price_per_gms from zepto
where weightInGms>=100 
order by price_per_gms;

-- group the products into categories like low,medium and bulk
select distinct name,weightingms,
case
when weightingms<1000 then 'LOW'
when weightingms<5000 then 'MEDIUM'
else 'BULK'
end as weight_category	
from zepto;

-- what is the total inventory weight per category
select category,sum(weightingms*availableQuantity) as total_weight from zepto
group by category
order by total_weight;