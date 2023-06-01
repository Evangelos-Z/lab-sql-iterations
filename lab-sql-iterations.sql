use sakila;

# 1. Write a query to find what is the total business done by each store.
# First a look at the various payment amounts submitted
select count(distinct amount) from payment
order by amount asc;
# 19 distinct amounts

# And now to calculate the total business
select s.store_id, sum(p.amount) as total_business from store s
join staff st
using (store_id)
join payment p
using (staff_id)
group by store_id;
# Output:
# store_id	sum(p.amount)
# 	1		33489.47
#	2		33927.04
 

# 2. Convert the previous query into a stored procedure.
delimiter //
create procedure total_buz()
begin
	select s.store_id, sum(p.amount) as total_business from store s
	join staff st
	using (store_id)
	join payment p
	using (staff_id)
	group by store_id;
end //
delimiter ;

call total_buz;
# Output:
# store_id	total_business
#	1			33489.47
#	2			33927.04



# 3. Convert the previous query into a stored procedure that takes the input for store_id and displays the total sales for that store.
# Creating the stored procedure
delimiter //
create procedure store_biz(in which_store int)
begin
	select s.store_id, sum(p.amount) as total_business from store s
	join staff st
	using (store_id)
	join payment p
	using (staff_id)
    where store_id = which_store
	group by store_id;
end //
delimiter ;

# Checking procedure's functionality
call store_biz(1);
# Output:
# store_id	total_business
#	1			33489.47



# 4. Update the previous query. Declare a variable total_sales_value of float type, that will store the returned result (of the total sales amount for the store). Call the stored procedure and print the results.
# Since the previous query will be updated, its name will remain the same
drop procedure if exists store_biz;

# This time a second (output) parameter will be added, which will then be used to store the total sales amount for any store chosen
delimiter //
create procedure store_biz(in param1 int, out param2 float)
begin
	declare total_sales_value float default null;
	select round(sum(amount), 1) into total_sales_value 
    from (
		select s.store_id, p.payment_id, p.amount from store s
		join staff st
		using (store_id)
		join payment p
		using (staff_id)
		where s.store_id = param1
	) as trans_table;
    
    select total_sales_value into param2;
end //
delimiter ;

# Executing the stored procedure for store_id 2 and saving the total sales amount to total_sales_value
call store_biz(2, @total_sales_value);

# Returning the value of total_sales_value with one simple query
select @total_sales_value;
# Output:
# @total_sales_value
#		33927



# 5. In the previous query, add another variable flag. If the total sales value for the store is over 30.000, then label it as green_flag, otherwise label is as red_flag. Update the stored procedure that takes an input as the store_id and returns total sales value for that store and flag value.
# Updating again
drop procedure if exists store_biz;

# A third (output) parameter will be added, which will then be used to store the flag label
delimiter //
create procedure store_biz(in param1 int, out param2 float, out param3 text)
begin
	declare total_sales_value float default null;
    declare flag text default null;
	select round(sum(amount), 1) into total_sales_value 
    from (
		select s.store_id, p.payment_id, p.amount from store s
		join staff st
		using (store_id)
		join payment p
		using (staff_id)
		where s.store_id = param1
	) as trans_table;
    
	case
		when total_sales_value > 30000
			then set flag = "green_flag";
		else
			set flag = "red_flag";
	end case;
    
	select total_sales_value into param2;
	select flag into param3;
end //
delimiter ;

call store_biz(1, @total_sales_value, @label);

# Returning the value of total_sales_value and flag
select @total_sales_value, @label;
# Output:
# @total_sales_value	@label
#	33489.5				green_flag

