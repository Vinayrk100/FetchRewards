 -- What are the top 5 brands by receipts scanned for most recent month?
Select * from
(	
	select c.name, dense_rank() over (order by c.total desc)ranking from  
		(
			select name, sum(a.totalQuantity) as total from brand b join 
					(
							select barcode, sum(quanitypurchased) as totalQuantity  
                            from purchaseitems p 
                            inner join receipt r 
                            on p.receipt_ID= r.receipt_ID 
							where extract(day from(now()-r.datescanned))<=30
							group by barcode
					)a	
			on b.barcode = a.barcode 
			where Topbrand =1 
			group by name 
		)c
)d where d.ranking <= 5;

-- How does the ranking of the top 5 brands by receipts scanned for the recent month compare to the ranking for the previous month?
select y.name,y.current_month_standing,z.previous_month_standing from 
(
	select name, total, dense_rank() over (order by total desc)current_month_standing from  
		(
			select name, sum(a.totalQuantity) as total from brand b join 
					(
							select barcode, sum(quanitypurchased) as totalQuantity  
                            from itemList i 
                            inner join receipt r 
                            on i.receipt_ID= r.receipt_ID 
							where extract(day from(now()-r.datescanned))<=30
							group by barcode
					)a	
			on b.barcode = a.barcode 
			where Topbrand =1 
			group by name 
		)
)y		
inner join
(
	select name, total, dense_rank() over (order by total desc)previous_month_standing from  
		(
			select name, sum(a.totalQuanity) as total from brand b join 
					(
							select barcode, sum(quanitypurchased) as totalQuanity  
                            from itemList i 
                            inner join receipt r 
                            on i.receipt_ID= r.receipt_ID 
							where extract(day from(now()-datescanned))>30 and extract(day from(now()-datescanned))<=60
							group by barcode
					)a	
			on b.barcode = a.barcode 
			where Topbrand =1 
			group by name 
		) 
)z 
on y.name = z.name;


-- When considering average spend from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?
with cte1 as 
(select AVG(TotalSpent) as accepted_revenue
from Receipt
where rewardsReceiptStatus = 'Accepted')
, cte2 as
(
select AVG(TotalSpent) as rejected_revenue
from Receipt
where rewardsReceiptStatus = 'Rejected'
)

select case 
when accepted_revenue > rejected_revenue then 'Accepted revenue is greater'
when rejected_revenue > accepted_revenue then 'Rejected revenue is greater'
else 'Both are equal' end as revenue_outcome
from cte1, cte2




-- When considering total number of items purchased from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?
with cte1 as
(select SUM(purchasedItemCount) as accepted_revenue
from Receipt
where rewardsReceiptStatus = 'Accepted')
, cte2 as
(
select SUM(purchasedItemCount) as rejected_revenue
from Receipt
where rewardsReceiptStatus = 'Rejected'	
)

select case 
when accepted_revenue > rejected_revenue then 'Accepted revenue is greater'
when rejected_revenue > accepted_revenue then 'Rejected revenue is greater'
else 'Both are equal' end as revenue_outcome
from cte1, cte2

-- Which brand has the most spend among users who were created within the past 6 months?
Select d.name, sum(b.spend)  
from brand d 
join 
     (
            select barcode, sum(itemprice*quanitypurchased) as spend from itemList i 
						inner join 
						  (
                        select userID, receipt ID 
							from receipt r 
							inner join  users u 
							on r.userID= u.userID 
							where extract(month from(now()-u.createdDate))<=6 
                          )a 
						on i.receipt_ID =a.receipt_ID group by barcode
      )b
on d.barcode = b.barcode 
group by d.name
order by sum(b.spend) desc 
limit 1; 


-- Which brand has the most transactions among users who were created within the past 6 months?
Select d.name, sum(b.countquantity)  from brand d 
join 
    (
               select barcode, sum(quanitypurchased) as countquantity 
					from itemList i 
					join 
						  (
                          select userID, receipt ID 
                          from receipt r 
						  join  users u 
						  on r.userID= u.userID 
                          where extract(month from(now()-u.createdDate))<=6 
              )a 
						  on i.receipt_ID =a.receipt_ID group by barcode
     )b
on d.barcode = b.barcode 
group by d.name
order by sum(b.countquantity) desc 
limit 1;