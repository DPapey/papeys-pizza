--CREATE DATABASE papeys_pizza

--DROP TABLES REVERSE ORDER
DROP TABLE IF EXISTS sale_order;
DROP TABLE IF EXISTS sale_order_item;
DROP TABLE IF EXISTS inventory_transaction;
DROP TABLE IF EXISTS inventory_transaction_type;
DROP TABLE IF EXISTS parlour_inventory;
DROP TABLE IF EXISTS supplier_item;
DROP TABLE IF EXISTS item;
DROP TABLE IF EXISTS item_category;
DROP TABLE IF EXISTS parlour;
DROP TABLE IF EXISTS supplier;
DROP TABLE IF EXISTS arcade_card;
DROP TABLE IF EXISTS staff;
DROP TABLE IF EXISTS role;
DROP TABLE IF EXISTS account;
DROP TABLE IF EXISTS contact_info;
DROP TABLE IF EXISTS contact_type;


CREATE TABLE contact_type(
	ct_type_id SERIAL PRIMARY KEY,
	ct_type_name VARCHAR(20)
);

CREATE TABLE contact_info(
	contact_id SERIAL PRIMARY KEY,
	ct_type_id INT,
	surname VARCHAR(30),
	forename VARCHAR(30),
	street VARCHAR(30),
	town VARCHAR(30),
	postcode VARCHAR(7),
	email_address VARCHAR(80),
	phone_number VARCHAR(13),
	FOREIGN KEY (ct_type_id) REFERENCES contact_type(ct_type_id)
);

-- Staff members can also have a customer account & membership aswell as staff, getting discounts to enforce.
CREATE TABLE account(
	account_id SERIAL PRIMARY KEY,
	username VARCHAR(30),
	password VARCHAR(255) NOT NULL,
	contact_id INT,
	date_of_birth DATE,
	created_at TIMESTAMP,
	FOREIGN KEY (contact_id) REFERENCES contact_info(contact_id)
	ON DELETE CASCADE
);

CREATE TABLE role(
	role_id SERIAL PRIMARY KEY,
	role_name VARCHAR(30) NOT NULL,
	access_level SMALLINT NOT NULL,
	salary DECIMAL(10,2) NOT NULL,
	role_description TEXT
);

CREATE TABLE staff(
	staff_id SERIAL PRIMARY KEY,
	contact_id INT NOT NULL UNIQUE,
	role_id INT NOT NULL,
	FOREIGN KEY (contact_id) REFERENCES contact_info(contact_id) 
	ON DELETE CASCADE,
	FOREIGN KEY (role_id) REFERENCES role(role_id)
);

-- Card active == true, card lost, deactivated or replaced == false
CREATE TABLE arcade_card(
	a_card_id SERIAL PRIMARY KEY,
	account_id INT NOT NULL UNIQUE,
	purchased TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	current_value DECIMAL(10,2) NOT NULL,
	active BOOLEAN,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (account_id) REFERENCES account(account_id) ON DELETE CASCADE
);

--Food Side
CREATE TABLE supplier(
	supplier_id SERIAL PRIMARY KEY,
	supplier_name VARCHAR(50),
	contact_id INT NOT NULL,
	FOREIGN KEY (contact_id) REFERENCES contact_info(contact_id)
	ON DELETE SET NULL
);

-- Contact info applied is admin
CREATE TABLE parlour(
	parlour_id SERIAL PRIMARY KEY,
	parlour_name VARCHAR(30),
	contact_id INT NOT NULL UNIQUE,
	FOREIGN KEY (contact_id) REFERENCES contact_info(contact_id) ON DELETE CASCADE
);


CREATE TABLE item_category(
	category_id SERIAL PRIMARY KEY,
	category_name VARCHAR(50) NOT NULL UNIQUE,
	description TEXT
);

-- Sale Price if the item is sold to customers.
CREATE TABLE item(
	item_id SERIAL PRIMARY KEY,
	item_name VARCHAR(30) NOT NULL UNIQUE,
	category_id INT NOT NULL,
	unit_of_measure VARCHAR(30),
	cost_price DECIMAL(10,2),
	sale_price DECIMAL(10,2)
	FOREIGN KEY (category_id) REFERENCES item_category(category_id)
);

CREATE TABLE supplier_item(
	supplier_id INT NOT NULL,
	item_id INT NOT NULL,
	supplier_item_code VARCHAR(50),
	purchase_price DECIMAL(10,2) NOT NULL,
	min_order_quantity DECIMAL(10,2) DEFAULT 1,
	is_preferred_supplier BOOLEAN DEFAULT FALSE,
	contract_start_date DATE,
	contract_end_date DATE,
	notes TEXT,
	PRIMARY KEY (supplier_id, item_id)
	FOREIGN KEY (supplier_id) REFERENCES supplier(supplier_id) ON DELETE CASCADE,
	FOREIGN KEY (item_id) REFERENCES item(item_id) ON DELETE CASCADE
);

CREATE TABLE parlour_inventory(
	parlour_inventory_id SERIAL PRIMARY KEY,
	parlour_id INT NOT NULL,
	item_id INT NOT NULL,
	current_stock_quantity DECIMAL(10,2) NOT NULL DEFAULT 0,
	min_stock_level DECIMAL(10,2) DEFAULT 0,
	max_stock_level DECIMAL(10,2) DEFAULT 0,
	last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	UNIQUE (parlour_id, item_id),
	FOREIGN KEY (parlour_id) REFERENCES parlour(parlour_id) ON DELETE CASCADE,
	FOREIGN KEY (item_id) REFERENCES item(item_id) ON DELETE CASCADE
);

CREATE TABLE inventory_transaction_type(
	trans_type_id SERIAL PRIMARY KEY,
	trans_type_name VARCHAR(50) NOT NULL UNIQUE, --purchase, sale, waste, transfer (in/out), initial
	is_increase BOOLEAN NOT NULL --true for adding stock, false for removing
);

-- Account ID Nullable incase guest purchase
CREATE TABLE sale_order(
	sale_order_id SERIAL PRIMARY KEY,
	account_id INT,
	parlour_id INT NOT NULL,
	purchase_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	total_item_price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
	discount_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
	final_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
	payment_status BOOLEAN NOT NULL DEFAULT FALSE,
	notes TEXT,
	FOREIGN KEY (account_id) REFERENCES account(account_id) ON DELETE SET NULL,
	FOREIGN KEY (parlour_id) REFERENCES parlour(parlour_id) ON DELETE SET NULL
);

CREATE TABLE sale_order_item(
	sale_order_item_id SERIAL PRIMARY KEY,
	sale_order_id INT NOT NULL,
	item_id INT NOT NULL,
	quantity INT NOT NULL CHECK (quantity > 0),
	unit_price DECIMAL(10,2) NOT NULL,
	item_total_price DECIMAL(10,2) NOT NULL,
	notes TEXT,
	FOREIGN KEY (sale_order_id) REFERENCES sale_order(sale_order_id) ON DELETE CASCADE,
	FOREIGN KEY (item_id) REFERENCES item(item_id) ON DELETE RESTRICT

);

CREATE TABLE inventory_transaction(
	inv_transaction_id SERIAL PRIMARY KEY,
	trans_type_id INT NOT NULL,
	parlour_inventory_id INT NOT NULL,
	quantity DECIMAL(10.2),
	transaction_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	sale_order_item_id INT,
	staff_id INT,
	FOREIGN KEY (trans_type_id) REFERENCES inventory_transaction_type(trans_type_id) ON DELETE RESTRICT,
	FOREIGN KEY (parlour_inventory_id) REFERENCES parlour_inventory(parlour_inventory_id) ON DELETE RESTRICT
	FOREIGN KEY (sale_order_item_id) REFERENCES sale_order_item(sale_order_item_id) ON DELETE SET NULL,
	FOREIGN KEY (staff_id) REFERENCES staff(staff_id) ON DELETE SET NULL
);

-- Enforcing contact-info validation.

-- Validation Logic Function
--CREATE OR REPLACE FUNCTION validate_staff_contact_info()
--RETURNS TRIGGER as $$
--DECLARE 
	
