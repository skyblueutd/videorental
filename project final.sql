--create tables
CREATE TABLE Manager
(manager_id INT  not null,
Mgr_first VARCHAR(15) not null,
Mgr_last VARCHAR(15) not null,
manager_contact INT not null,
PRIMARY KEY (manager_id));

CREATE TABLE Video_stores
(store_id INT  not null,
store_address VARCHAR(200) not null,
store_phone INT not null,
store_email VARCHAR(30),
Mgr_id INT not null,
PRIMARY KEY (store_id));

CREATE TABLE Video				
(video_id INT  not null,
description VARCHAR(200) not null,
title VARCHAR(30) not null,
release_year INT,
sale_price decimal(6,2) not null,
rent_price decimal(5,2) not null,
format VARCHAR(20),
remain_copy INT not null,
PRIMARY KEY (video_id));

create table Rental_order
(order_id int primary key not null,
day_out date not null,
day_return date not null,
due_date date not null,
order_status varchar(20) not null,
Cus_id int not null);


create table Customer
(customer_id int primary key not null,
Cus_first varchar(15),
Cus_last varchar(15),
membership_date date,
customer_address varchar(200),
customer_phone int,
customer_email varchar(30));

create table Account
(account_id int primary key not null,
credit_score int not null,
discount decimal(2,2),
Cus_id int not null);

create table transaction
(transaction_id int not null,
trans_date date,
trans_amount int,
trans_comment varchar(200),
odr_id int not null,
previous_trans_id int not null,
trans_type_id int not null,
primary key(transaction_id)
);

create table Trans_type
(trans_t_id int not null,
trans_t_desp varchar(200),
primary key(trans_t_id)
);

create table payment_method
(method_code int not null,
method_description varchar(200),
primary key(method_code)
);

create table actor
(actor_id int not null,
actor_first varchar(20),
actor_last varchar(20),
actor_gender varchar(20),
actor_detail varchar(200),
primary key (actor_id)
);

create table Act
(Aact_id int not null,
Vdo_id int not null
);

create table Has
(Aacc_id int not null,
Pmeth_code int not null
);

create table Store
(Ssto_id int not null,
Vdo_id int not null
);

create table Rent
(Oodr_id int not null,
Vdo_id int not null
);

-- add foreign key constraints for tables
alter table Video_stores add foreign key(Mgr_id) references Manager(manager_id);
alter table Rental_order add foreign key(Cus_id) references Customer(customer_id);
alter table Account add foreign key(Cus_id) references Customer(customer_id);
alter table transaction add foreign key(odr_id) references Rental_order(order_id);
alter table transaction add foreign key(previous_trans_id) references transaction(transaction_id);
alter table transaction add foreign key(trans_type_id) references Trans_type(trans_t_id);
alter table Act add foreign key(Aact_id) references actor(actor_id);
alter table Act add foreign key(Vdo_id) references Video(video_id);
alter table Has add foreign key(Aacc_id) references Account(account_id);
alter table Has add foreign key(Pmeth_code) references Payment_method(method_code);
alter table Store add foreign key(Ssto_id) references Video_stores(store_id);
alter table Store add foreign key(Vdo_id) references Video(video_id);
alter table Rent add foreign key(Oodr_id) references Rental_order(order_id);
alter table Rent add foreign key(Vdo_id) references Video(video_id);

create or replace trigger cascade_delete_manager
before delete on manager
for each row
begin
  delete from Video_stores
  where Video_stores.Mgr_id = :old.manager_id; 
end;

create or replace trigger cascade_update_manager
after update of manager_id on manager
for each row
begin
  update Video_stores
  set Video_stores.Mgr_id = :new.manager_id
  where Video_stores.Mgr_id = :old.manager_id;
end;

create or replace trigger cascade_delete_Video_stores
before delete on Video_stores
for each row
begin
  delete from store
  where store.Ssto_id = old.store_id;
end;

create or replace trigger cascade_update_Video_stores
after update of store_id on Video_stores
for each row
begin
  update Store
  set Store.Ssto_id = :new.store_id
  where Store.Ssto_id = :old.store_id;
end;

create or replace trigger cascade_delete_Video
before delete on Video
for each row
begin
  delete from Act
  where Act.Vdo_id = :old.video_id; 
  delete from Store
  where Store.Vdo_id = :old.video_id; 
  delete from Rent
  where Rent.Vdo_id = :old.video_id;  
end;

create or replace trigger cascade_update_Video
after update of Video_id on Video
for each row
begin
  update Act
  set Act.Vdo_id = :new.video_id
  where Act.Vdo_id = :old.video_id; 
  update Store
  set Store.Vdo_id = :new.video_id
  where Store.Vdo_id = :old.video_id; 
  update Rent
  set Rent.Vdo_id = :new.video_id
  where Rent.Vdo_id = :old.video_id;  
end;

create or replace trigger cascade_update_Rental_order
after update of order_id on Rental_order
for each row
begin
 update Rent
 set Rent.Oodr_id = :new.order_id 
 where Rent.Oodr_id = :old.order_id;
end;

create or replace trigger cascade_delete_Rental_order
before delete on Rental_order
for each row
begin
 delete from Rent
 where Rent.Oodr_id = :old.order_id;
end; 

create or replace trigger cascade_update_Customer
after update on Customer
for each row
begin
 update Rental_order
 set Rental_order.Cus_id = :new.customer_id
 where Rental_order.Cus_id = :old.customer_id;
 
 update Account
 set Account.Cus_id = :new.customer_id
 where Account.Cus_id = :old.customer_id;
end;

create or replace trigger cascade_delete_Customer
before delete on Customer
for each row
begin
 delete from Rental_order
 where Rental_order.Cus_id = :old.customer_id;
 
 delete from Account
 where Account.Cus_id = :old.customer_id;
end;

create or replace trigger cascade_update_Account 
after update on Account
for each row
begin
 update Has 
 set Has.Aacc_id = :new.account_id
 where Has.Aacc_id = :old.account_id;
end;

create or replace trigger cascade_delete_Account
before delete on Account
for each row
begin
 delete from Has
 where Has.Aacc_id = :old.account_id;
end;

create or replace trigger cascade_delete_transaction
before delete on transaction
for each row
begin
  update transaction
  set transaction.previous_trans_id = 0000000000
  where transaction.previous_trans_id =:old.transaction_id;
end;

create or replace trigger cascade_update_transaction
after update of transaction_id on transaction
for each row
begin
  update transaction
  set transaction.previous_trans_id = :new.transaction_id
  where transaction.previous_trans_id =:old.transaction_id;
end;

create or replace trigger cascade_insert_transaction
after insert on transaction
for each row
begin
  delete from transaction
  where transaction.odr_id not in(select order_id from rental_order) or
  transaction.previous_trans_id not in(select transaction_id from transaction) or
  transaction.trans_type_id  not in(select trans_t_id from Trans_type);
end;

create or replace trigger cascade_delete_Trans_type
before delete on Trans_type 
for each row
begin
  update Transaction
  set Transaction.trans_type_id = 0000000000
  where Transaction.trans_type_id =:old.trans_t_id;
end;

create or replace trigger cascade_update_Trans_type
after update of trans_t_id on Trans_type
for each row
begin
  update Transaction
  set Transaction.trans_type_id = :new.trans_t_id
  where Transaction.trans_type_id = :old.trans_t_id;
end;

create or replace trigger cascade_delete_payment_method
before delete on payment_method
for each row
begin
  delete from Has
  where Has.Pmeth_code = :old.method_code;
end;

create or replace trigger cascade_update_payment_method
after update of method_code on payment_method
for each row
begin
  update Has
  set Has.Pmeth_code =:new.method_code
  where Has.Pmeth_code = :old.method_code;
end;

create or replace trigger cascade_delete_actor
before delete on actor
for each row
begin
  delete from act
  where act.Aact_id = :old.actor_id;
end;

create or replace trigger cascade_update_actor
after update of actor_id on actor
for each row
begin
  update act
  set act.Aact_id = :new.actor_id
  where act.Aact_id = :old.actor_id;
end;

--find the customer_id who has video overdue
create or replace procedure Overdue (thisdate IN Rental_order.due_date%TYPE) as
Cid Customer.customer_id%TYPE;
CURSOR Videodue IS (SELECT * FROM Rental_order WHERE Due_date <= thisdate); 
due Videodue%ROWTYPE; 
begin
 OPEN Videodue;
  loop
  FETCH Videodue into due;
  EXIT When Videodue %notfound;
  SELECT customer_id into Cid FROM Customer WHERE Customer.customer_id = due.Cus_id;
  sys.dbms_output.put_line (Cid);
  END LOOP;
 CLOSE Videodue;
end;

--find the customer_id who has more than 5 orders as VIP 
create or replace procedure VIP as
Vipidf Customer%ROWTYPE;
CURSOR Vipinfo IS 
(SELECT * FROM Rental_order 
 GROUP BY Cus_id
 HAVING count (order_id)>5
 ); 
info Vipinfo%ROWTYPE; 
begin
 OPEN Vipinfo;
  loop
  FETCH Vipinfo into info;
  EXIT When Vipinfo %notfound;
  SELECT * into Vipidf FROM Customer WHERE Customer.customer_id = info.Cus_id;
  sys.dbms_output.put_line (Vipidf.Cus_first);
  sys.dbms_output.put_line (Vipidf.Cus_last);
  END LOOP;
 CLOSE Vipinfo;
end;


--update discount trigger, credit > 100, discount = 0.20, credit ~(50, 100), discount = 0.10, credit < 50, discount = 0.
create or replace trigger Discount_credit
after insert or update of credit_score on Account
for each row
DECLARE 
update_credit_score Account.credit_score%TYPE;
begin
update_credit_score := :NEW.credit_score;
if(update_credit_score > 100) then  
  update Account
  set Account.discount = 0.20;
  else
  if(update_credit_score < 50) then  
  update Account
  set Account.discount = 0;
  else
  update Account
  set Account.discount = 0.10;
  end if;
end if;
end;

--update remain_copy trigger. if bemain_copy is 0, output message to forbiden rent.
create or replace trigger remain_zero
after insert or update of remain_copy on Video
for each row
DECLARE 
update_remain_copy Video.remain_copy%TYPE;
begin
update_remain_copy := :NEW.remain_copy;
if(update_remain_copy = 0) then  
  sys.dbms_output.put_line ('None left');
end if;
end;
