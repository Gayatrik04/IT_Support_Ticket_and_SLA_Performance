CREATE DATABASE support_ticket_analysis;
USE support_ticket_analysis;

select * from support_tickets;

-- Ticket Volume & Trends
-- 1. How has the number of support tickets changed over time (daily, weekly, monthly)?
select date(Created_time)as Date,count(*)as total_tickets from support_tickets 
group by date(Created_time) order by Date;

-- 2.Which months experience the highest support ticket volume?
select Month,count(Ticket_ID)as ticket_volume from support_tickets 
group by Month order by ticket_volume desc;

-- 3.Which days of the week generate the most support requests?
select Weekday,count(Ticket_ID)as request_genrated from support_tickets 
group by Weekday order by request_genrated desc ;

-- 4.At what hours of the day are customers most likely to create support tickets?
select Hour,count(Ticket_ID)as request_genrated from support_tickets group by Hour  order by request_genrated desc ;

-- 5.Are more tickets created during business hours or after business hours?
select Working_Hours,count(Ticket_ID)as request_genrated from support_tickets group by Working_Hours order by request_genrated desc ;

-- Customer Issues
-- 6.Which product groups generate the highest number of support tickets?
select Product_group,count(Ticket_ID)as request_genrated from support_tickets group by Product_group order by request_genrated desc ;

-- 7.What are the most common customer issues (topics)?
select Topic,count(Ticket_ID)as request_genrated from support_tickets group by Topic order by request_genrated desc ;

-- 8.Which support channels (Email, Chat, Phone) receive the highest ticket volume?
select Source,count(Ticket_ID)as request_genrated from support_tickets group by Source order by request_genrated desc ;

-- SLA Performance
-- 9.How well is the support team meeting the First Response SLA?
select SLA_For_first_response,count(Ticket_ID)as First_Response_SLA from support_tickets 
group by SLA_For_first_response;

-- 10.How well is the support team meeting the Resolution SLA?
select SLA_For_Resolution,count(Ticket_ID)as Resolution_SLA from support_tickets
group by SLA_For_Resolution;

-- 11.Which priority level has the highest SLA violation rate?
select Priority,count(*)as total_tickets,
sum(case when SLA_For_Resolution='SLA Violated' then 1 else 0 end)as violated_tickets,
round(sum(case when SLA_For_Resolution='SLA Violated' then 1 else 0 end)*100/count(*),2)as violation_percent
from support_tickets group by Priority order by violation_percent desc;

-- 12.Which support channel has the highest SLA violation rate?
select Source,count(*)as total_tickets,
sum(case when SLA_For_Resolution='SLA Violated' then 1 else 0 end)as violated_tickets,
round(sum(case when SLA_For_Resolution='SLA Violated' then 1 else 0 end)*100/count(*),2)as violation_percent
from support_tickets group by Source order by violation_percent desc;

-- Agent Performance
-- 13.Which support agents handle the highest number of tickets?
select Agent_Name,count(*)as no_of_tickets from support_tickets 
group by Agent_Name order by no_of_tickets desc;

-- 14.Which agents receive the highest customer satisfaction ratings?
select Agent_Name,round(avg(Survey_results),2)as customer_satisfaction_ratings  from support_tickets 
group by Agent_Name order by customer_satisfaction_ratings desc;

-- 15.Which agents resolve tickets the fastest on average?
select Agent_Name,round(avg(Resolution_Time_Hours),2)as resolve_time from support_tickets 
group by Agent_Name order by resolve_time asc;

-- 16.Which Agent Group (Tier 1 vs Tier 2) performs better in terms of SLA compliance and resolution speed?
select Agent_Group,count(Ticket_ID),round(avg(First_response_time),2),round(avg(Resolution_Time_Hours),2)
from support_tickets group by Agent_Group;

-- Customer Satisfaction
-- 17.Which product groups have the highest and lowest customer satisfaction?
select Product_group,round(avg(Survey_results),2)as customer_satisfaction from support_tickets 
group by Product_group order by customer_satisfaction desc ;

-- 18.Which support topics lead to the lowest customer satisfaction?
select Topic,round(avg(Survey_results),2)as customer_satisfaction from support_tickets 
group by Topic order by customer_satisfaction asc ;

-- 19.Does meeting the Resolution SLA improve customer satisfaction?
select SLA_For_Resolution,round(avg(Survey_results),2)as customer_satisfaction from support_tickets 
group by SLA_For_Resolution;

-- Geographic Analysis
-- 20.Which countries generate the highest number of support requests, and where should additional support resources be allocated?
select Country,count(Ticket_ID)as no_of_support_requests from support_tickets 
group by Country order by no_of_support_requests desc;

-- 21Status Distribution
select Status,count(*)as total_tickets from support_tickets group by Status;

-- 22 Average Resolution Time by Priority
select Priority,round(avg(Resolution_Time_Hours),2)as avg_time 
from support_tickets group by Priority;

-- 23 Average Customer Satisfaction by Source
select Source,round(avg(Survey_results),2)as avg_rating from support_tickets 
group by Source order by avg_rating desc;

-- 24 Product Groups with Most SLA Violations
select Product_group,count(*)as violated_tickets from support_tickets
where SLA_For_Resolution='SLA Violated' group by Product_group order by violated_tickets desc;

-- 25 Rank Agents by Number of Tickets Handled+
select Agent_Name,count(*)as tickets_handled,
rank() over(order by count(*) desc)as agent_rank
from support_tickets group by Agent_Name;

-- 26 Month-over-Month Ticket Growth
select Month_Number,Month,
count(*)as total_tickets,
lag(count(*))over(order by Month_Number)as prev_month,
count(*)-lag(count(*))over(order by Month_Number)as ticket_growth
from support_tickets group by Month_Number,month
order by Month_Number;

-- 27 Top Agent in Each Agent Group
select Agent_Group,Agent_Name,tickets_handled from
(select Agent_Group,Agent_Name,count(*)as tickets_handled,
row_number()over(partition by Agent_Group order by count(*) desc)as rnk
from support_tickets group by Agent_Group,Agent_Name)as ranked_agents
where rnk=1